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

unit SCAPICommon;

interface

uses Windows,Classes,SysUtils,
     SCWin32;

type
  TApiError=(aeNone=0,aeBadHandle=1,aeWrongHandleType=2,aeEmptyBaseList=3,aeBadLocStringId=4);

  TApiFunction=(afNone=0,afObjectFree=1,afGetLastError=2,afErrorMessage=3,afObjectExists=4,afGetLocString=5,
                afNewBaseList=10,afBaselistAddItem=11,
                afIsEnabled=20,afProcessBaseList=21,afIsSameVolumeMove=22,
                afNewCopy=30,afCopyAddBaseList=31);

  TFileMappingStream=class(TStream)
  private
    FFileMapping:Pointer;
    FSize,FPosition:Integer;
  public
    constructor Create(AHandle:THandle;ASize:Integer);
    destructor Destroy;override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteInteger(AValue:Integer);
    procedure WriteWideString(AValue:WideString);
    function ReadInteger:Integer;
    function ReadWideString:WideString;
  end;

const
  SC2_API_ID='SuperCopier2 API';
  SC2_API_SEMAPHORE_ID='Semaphore'; // le sémaphore est utilisé pour s'assurer qu'une seule instance de l'API tourne pour une session
  SC2_API_MUTEX_ID='Mutex'; // le mutex est utilisé pour empécher 2 clients utilisant l'API de se corrompre mutuellement
  SC2_API_FILEMAPPING_ID='FileMapping'; // le filemapping est utilisé pour transférer des données depuis et vers les clients utilisant l'API
  SC2_API_CLIENTEVENT_ID='ClientEvent'; // l'event est utilisé pour notifier que des données d'un client sont prêtes dans le filemapping
  SC2_API_APIEVENT_ID='APIEvent'; // l'event est utilisé pour notifier que des données de l'API sont prêtes dans le filemapping

  SC2_API_FILEMAPPING_SIZE=128*1024;

  SC2_API_ERRORS_NAMES:array[TApiError] of WideString=('No error','Bad handle','Wrong handle type','Empty Baselist','Bad LocString ID');

  SC2_API_INVALID_HANDLE=-1;

function SessionUniqueAPIIdentifier(AObject:WideString):WideString;

implementation

{ TFileMappingStream }

constructor TFileMappingStream.Create(AHandle: THandle; ASize: Integer);
begin
  inherited Create;
  FFileMapping:=nil;
  if AHandle<>0 then
    FFileMapping:=MapViewOfFile(AHandle,FILE_MAP_ALL_ACCESS,0,0,ASize);

  Assert(FFileMapping<>nil);
  
  FPosition:=0;
  FSize:=ASize;
end;

destructor TFileMappingStream.Destroy;
begin
  UnmapViewOfFile(FFileMapping);
  inherited;
end;

function TFileMappingStream.Read(var Buffer; Count: Integer): Longint;
var EndPos:Integer;
begin
  Result:=Count;
  EndPos:=FPosition+Count;
  Assert((Count>=0) and (EndPos<=FSize));
  Move(Pointer(Longint(FFileMapping)+FPosition)^,Buffer,Result);
  FPosition:=EndPos;
end;

function TFileMappingStream.ReadInteger: Integer;
begin
  Read(Result,SizeOf(Result));
end;

function TFileMappingStream.ReadWideString: WideString;
var Len:Integer;
begin
  Read(Len,SizeOf(Len));
  SetLength(Result,Len);
  Read(Result[1],Len*SizeOf(WideChar));
end;

function TFileMappingStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition:=Offset;
    soFromCurrent:   Inc(FPosition,Offset);
    soFromEnd:       FPosition:=FSize+Offset;
  end;
  Result := FPosition;
  Assert((FPosition>=0) and (FPosition<=FSize));
end;

function TFileMappingStream.Write(const Buffer; Count: Integer): Longint;
var EndPos:Integer;
begin
  Result:=Count;
  EndPos:=FPosition+Count;
  Assert((Count>=0) and (EndPos<=FSize));
  Move(Buffer,Pointer(Longint(FFileMapping)+FPosition)^,Result);
  FPosition:=EndPos;
end;

procedure TFileMappingStream.WriteInteger(AValue: Integer);
begin
  Write(AValue,SizeOf(AValue));
end;

procedure TFileMappingStream.WriteWideString(AValue: WideString);
begin
  WriteInteger(Length(AValue));
  Write(AValue[1],Length(AValue)*SizeOf(WideChar));
end;

//******************************************************************************

function SessionUniqueAPIIdentifier(AObject:WideString): WideString;
var UserName:array of WideChar;
    Size:Cardinal;
begin
  Result:='';
  UserName:=nil;
  Size:=0;

  if SCWin32.GetUserName(nil,Size) or (GetLastError<>ERROR_INSUFFICIENT_BUFFER) then
    Exit;

  SetLength(UserName,Size);
  try
    if not SCWin32.GetUserName(@UserName[0],Size) then
      Exit;

    Result:=SC2_API_ID+' '+AObject+' '+PWideChar(@UserName[0]);
  finally
    SetLength(UserName,0);
  end;
end;

end.
