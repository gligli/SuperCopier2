{
    This file is part of SuperCopier2.

    SuperCopier2 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    SuperCopier2 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
}

unit SCAPI;

interface

uses Windows,Classes,Contnrs,SysUtils,TntSysUtils,
     SCCommon,SCWin32,SCLocStrings,SCAPICommon,SCBaseList,SCWorkThreadList,
       SCWorkThread,SCCopyThread,SCLocEngine;

type
  EAPIError=class(Exception);
  EAPIAlreadyRunning=class(EAPIError);

  TAPI=class(TThread)
  private
    FSemaphore:THandle;
    FMutex:THandle;
    FFileMapping:THandle;
    FClientEvent:THandle;
    FAPIEvent:THandle;
    FFileMappingStream:TFileMappingStream;
    FShutdown:Boolean;
    FHandleList:TObjectList; //TODO: le système actuel où le handle est l'index d'item leake un peu de mémoire
                             //      en effet, on ne peut pas faire de Delete() sur la liste sinon les handles se décalent ...
                             //      (on mets l'item à nil, ce qui leake 4 octets par handle libéré)
    FLastError:TApiError;
    FEnabled:Boolean;

    function CheckHandle(AHandle:THandle;AClass:TClass):Boolean;

    // Fonctions de l'API

    procedure APIObjectFree(AHandle:Integer);
    function APIGetLastError:TApiError;
    function APIErrorMessage(AError:TApiError):WideString;
    function APIObjectExists(AHandle:Integer):Boolean;
    function APIGetLocString(ALocStringID:Integer):WideString;

    function APINewBaseList:Integer;
    procedure APIBaselistAddItem(ABaseListHandle:Integer;AItemName:WideString);

    function APIIsEnabled:Boolean;
    function APIProcessBaseList(ABaseListHandle:Integer;AOperation:Integer;ADestDir:WideString):Integer;
    function APIIsSameVolumeMove(ABaseListHandle:Integer;ADestDir:WideString):Boolean;

    function APINewCopy(AIsMove:Boolean):Integer;
    procedure APICopyAddBaseList(ACopyHandle,ABaseListHandle:Integer;AMode:TBaselistAddMode;ADestDir:WideString);

  protected
    procedure Execute;override;
  public
    constructor Create;
    destructor Destroy;override;

    procedure RemoveHandle(AObject:TObject);

    property Enabled:Boolean read FEnabled write FEnabled; 
  end;

var
  API:TAPI=nil;

implementation

uses Math;

{ TAPI }

procedure TAPI.APIBaselistAddItem(ABaseListHandle: Integer;
  AItemName: WideString);
var Item:TBaseItem;
begin
  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  Item:=TBaseItem.Create;
  Item.SrcName:=AItemName;
  Item.IsDirectory:=WideDirectoryExists(AItemName);

  (FHandleList[ABaseListHandle] as TBaseList).Add(Item);

  FLastError:=aeNone;
end;

procedure TAPI.APICopyAddBaseList(ACopyHandle, ABaseListHandle: Integer;
  AMode: TBaselistAddMode; ADestDir: WideString);
begin
  if not CheckHandle(ACopyHandle,TCopyThread) or not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  (FHandleList[ACopyHandle] as TCopyThread).AddBaseList(FHandleList[ABaseListHandle] as TBaseList,AMode,ADestDir);

  FLastError:=aeNone;
end;

function TAPI.APIErrorMessage(AError: TApiError): WideString;
begin
  Result:='';
  if (AError>=Low(TApiError)) and (AError<=High(TApiError)) then
    Result:=SC2_API_ERRORS_NAMES[AError];
end;

function TAPI.APIGetLastError: TApiError;
begin
  Result:=FLastError;
end;

function TAPI.APIGetLocString(ALocStringID: Integer): WideString;
begin
  Result:='';
  FLastError:=aeBadLocStringId;

  if (ALocStringID>=Low(LOC_STRINGS_ARRAY)) and (ALocStringID<=High(LOC_STRINGS_ARRAY)) then
  begin
    Result:=LOC_STRINGS_ARRAY[ALocStringID]^;
    FLastError:=aeNone;
  end;
end;

function TAPI.APIIsEnabled: Boolean;
begin
  Result:=FEnabled;
end;

function TAPI.APIIsSameVolumeMove(ABaseListHandle: Integer;
  ADestDir: WideString): Boolean;
var GuessedSrcDir:WideString;
    BaseList:TBaseList;
begin
  Result:=False;

  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  BaseList:=FHandleList[ABaseListHandle] as TBaseList;

  if BaseList.Count=0 then
  begin
    FLastError:=aeEmptyBaseList;
    Exit;
  end;

  GuessedSrcDir:=WideExtractFilePath(BaseList[0].SrcName);
  Result:=SameVolume(GuessedSrcDir,ADestDir);

  FLastError:=aeNone;
end;

function TAPI.APINewBaseList: Integer;
begin
  Result:=FHandleList.Add(TBaseList.Create);

  FLastError:=aeNone;
end;

function TAPI.APINewCopy(AIsMove: Boolean): Integer;
begin
  Result:=FHandleList.Add(TCopyThread.Create(AIsMove));

  FLastError:=aeNone;
end;

function TAPI.APIObjectExists(AHandle: Integer): Boolean;
begin
  Result:=CheckHandle(AHandle,TObject);

  FLastError:=aeNone;
end;

procedure TAPI.APIObjectFree(AHandle: Integer);
begin
  if not CheckHandle(AHandle,TObject) then Exit;

  FHandleList[AHandle].Free;
  FHandleList[AHandle]:=nil;

  FLastError:=aeNone;
end;

function TAPI.APIProcessBaseList(ABaseListHandle: Integer; AOperation: Integer;
  ADestDir: WideString): Integer;
var WorkThread:TWorkThread;
begin
  Result:=SC2_API_INVALID_HANDLE;
  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  WorkThread:=WorkThreadList.ProcessBaseList(FHandleList[ABaseListHandle] as TBaseList,AOperation,ADestDir);
  if WorkThread=nil then
    Result:=SC2_API_INVALID_HANDLE
  else
  begin
    Result:=FHandleList.IndexOf(WorkThread);
    if Result=SC2_API_INVALID_HANDLE then
      Result:=FHandleList.Add(WorkThread);
  end;

  FLastError:=aeNone;
end;

function TAPI.CheckHandle(AHandle: THandle;AClass:TClass): Boolean;
begin
  Result:=InRange(AHandle,0,FHandleList.Count-1) and (FHandleList[AHandle]<>nil);
  if not Result then
    FLastError:=aeBadHandle
  else
  begin
    Result:=FHandleList[AHandle] is AClass;
    if not Result then
      FLastError:=aeWrongHandleType;
  end;
end;

constructor TAPI.Create;
var Error:Integer;
begin
  inherited Create(True);
  FSemaphore:=0;
  FMutex:=0;
  FFileMapping:=0;
  FClientEvent:=0;
  FAPIEvent:=0;
  FFileMappingStream:=nil;

  // Sémaphore
  FSemaphore:=SCWin32.CreateSemaphore(nil,0,MaxInt,PWideChar(SessionUniqueAPIIdentifier(SC2_API_SEMAPHORE_ID)));
  Error:=GetLastError;
  if (Error=ERROR_ALREADY_EXISTS) or (Error=ERROR_ACCESS_DENIED) then
    raise EAPIAlreadyRunning.Create(lsAPIAlreadyRunning);
  if FSemaphore=0 then
    raise EAPIError.Create(lsAPINoSemaphore);

  // Mutex
  FMutex:=SCWin32.CreateMutex(nil,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_MUTEX_ID)));
  if FMutex=0 then
    raise EAPIError.Create(lsAPINoMutex);

  // File mapping
  FFileMapping:=SCWin32.CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SC2_API_FILEMAPPING_SIZE,PWideChar(SessionUniqueAPIIdentifier(SC2_API_FILEMAPPING_ID)));
  if FFileMapping=0 then
    raise EAPIError.Create(lsAPINoFileMapping);

  // Client event
  FClientEvent:=SCWin32.CreateEvent(nil,False,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_CLIENTEVENT_ID)));
  if FClientEvent=0 then
    raise EAPIError.Create(lsAPINoEvent);

  // API event
  FAPIEvent:=SCWin32.CreateEvent(nil,False,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_APIEVENT_ID)));
  if FAPIEvent=0 then
    raise EAPIError.Create(lsAPINoEvent);

  FFileMappingStream:=TFileMappingStream.Create(FFileMapping,SC2_API_FILEMAPPING_SIZE);

  FShutdown:=False;
  FreeOnTerminate:=False;

  FHandleList:=TObjectList.Create(False);
  FLastError:=aeNone;

  FEnabled:=False;

  Resume;
end;

destructor TAPI.Destroy;
begin
  if FMutex<>0 then
  begin
    // simuler un évènement d'un client pour pouvoir fermer la thread
    WaitForSingleObject(FMutex,INFINITE);
    try
      FFileMappingStream.Seek(0,soFromBeginning);
      FFileMappingStream.WriteInteger(Integer(afNone));

      FShutdown:=True;
      SetEvent(FClientEvent);
      WaitForSingleObject(FAPIEvent,INFINITE);

      WaitFor;
    finally
      ReleaseMutex(FMutex);
    end;
  end;

  FHandleList.Free;
  FFileMappingStream.Free;
  CloseHandle(FAPIEvent);
  CloseHandle(FClientEvent);
  CloseHandle(FFileMapping);
  CloseHandle(FMutex);
  CloseHandle(FSemaphore);
  inherited;
end;

procedure TAPI.Execute;
var ApiFunction:TApiFunction;
    s:WideString;
    i,j,k:Integer;
    b:boolean;
begin
  dbgln('API thread starting');

  while not FShutdown do
  begin
    WaitForSingleObject(FClientEvent,INFINITE);
    try
      try
        with FFileMappingStream do
        begin
          Seek(0,soBeginning);
          ApiFunction:=TApiFunction(ReadInteger);

          dbgln('Received API call #'+IntToStr(Ord(ApiFunction)));

          // /!\ ne pas appeler plusieurs fois Read... dans les paramètres d'une fonction, car Delphi evalue les params de droite à gauche !!!
          case ApiFunction of
            afObjectFree:
              APIObjectFree(ReadInteger);
            afGetLastError:
            begin
              Seek(0,soBeginning);
              WriteInteger(Ord(APIGetLastError));
            end;
            afErrorMessage:
            begin
              s:=APIErrorMessage(TApiError(ReadInteger));
              Seek(0,soBeginning);
              WriteWideString(s);
            end;
            afObjectExists:
            begin
              b:=APIObjectExists(ReadInteger);
              Seek(0,soBeginning);
              WriteInteger(Ord(b));
            end;
            afGetLocString:
            begin
              s:=APIGetLocString(ReadInteger);
              Seek(0,soBeginning);
              WriteWideString(s);
            end;
            afNewBaseList:
            begin
              Seek(0,soBeginning);
              WriteInteger(APINewBaseList);
            end;
            afBaselistAddItem:
            begin
              i:=ReadInteger;
              APIBaselistAddItem(i,ReadWideString);
            end;
            afIsEnabled:
            begin
              Seek(0,soBeginning);
              WriteInteger(Ord(APIIsEnabled));
            end;
            afProcessBaseList:
            begin
              i:=ReadInteger;
              j:=ReadInteger;
              i:=APIProcessBaseList(i,j,ReadWideString);
              Seek(0,soBeginning);
              WriteInteger(i);
            end;
            afIsSameVolumeMove:
            begin
              i:=ReadInteger;
              b:=APIIsSameVolumeMove(i,ReadWideString);
              Seek(0,soBeginning);
              WriteInteger(Ord(b));
            end;
            afNewCopy:
            begin
              i:=APINewCopy(ReadInteger<>0);
              Seek(0,soBeginning);
              WriteInteger(i);
            end;
            afCopyAddBaseList:
            begin
              i:=ReadInteger;
              j:=ReadInteger;
              k:=ReadInteger;
              APICopyAddBaseList(i,j,TBaseListAddMode(k),ReadWideString);
            end;
          end;
        end;
      finally
        SetEvent(FAPIEvent);
      end;
    except // ne pas laisser les exceptions tuer l'API
      on E:Exception do dbgln('API Exception: '+E.Message);
    end;
  end;

  dbgln('API thread ending');
end;

procedure TAPI.RemoveHandle(AObject: TObject);
var Idx:Integer;
begin
  Idx:=FHandleList.IndexOf(AObject);
  if Idx<>-1 then
    FHandleList[Idx]:=nil;
end;

end.
