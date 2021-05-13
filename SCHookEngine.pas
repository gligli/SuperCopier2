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

unit SCHookEngine;

interface
uses
  Windows,Classes,SysUtils,TntSysUtils,madCodeHook,SCCommon,SCConfig,SCLocStrings,SCBaseList,SCWorkThreadList,SCHookShared;

type
  EHookEngineInitFailed=class(Exception);
  EHookingFailed=class(Exception);

  THookEngine=class
  private
    FCopyHandlingActive:Boolean;

{$IFDEF NEW_HOOK_ENGINE}
    App2HookData:PSCApp2HookData;
    App2HookMapping:THandle;

    FIsUserHook:Boolean;
    FProcessList:String;
{$ENDIF}
  protected
  public
    IsUserHook:Boolean;

    property CopyHandlingActive:Boolean read FCopyHandlingActive write FCopyHandlingActive;

    constructor Create;
    destructor Destroy;override;

    procedure InstallHook;
    procedure RefreshHook;
    procedure UninstallHook;
  end;

var
  HookEngine:THookEngine=nil;

implementation

//******************************************************************************
// HookCallback
//******************************************************************************
procedure HookCallback(name:pchar;messageBuf:pointer;messageLen:dword;
                       answerBuf:pointer;answerLen:dword);stdcall;
var Handled:Boolean;
    HookData:TSCHook2AppData;
    RawProcessName:array[0..MAX_PATH] of char;
    ProcessName:String;
    Source,Destination:PWideChar;
    FileName:WideString;
    BaseList:TBaseList;
    Item:TBaseItem;
begin
  Assert(Assigned(HookEngine));

  Handled:=False;
  if HookEngine.FCopyHandlingActive then
  begin
    // on récup les données qui étaient collées les unes apres les autres
    Move(messageBuf^,HookData,SizeOf(TSCHook2AppData));
    Destination:=Pointer(Cardinal(messageBuf)+SizeOf(TSCHook2AppData));
    Source:=Pointer(Integer(messageBuf)+SizeOf(TSCHook2AppData)+HookData.DestinationSize);

    // le processus ayant lancé la copie doit-it être pris en charge?
    ProcessIdToFileName(HookData.ProcessId,RawProcessName);
    ProcessName:=LowerCase(ExtractFileName(RawProcessName));
    if Pos(ProcessName,LowerCase(Config.Values.HandledProcesses))<>0 then
      with HookData do
      begin
        BaseList:=TBaseList.Create;

        // on parcours la liste des Sources et on ajoute les éléments à la BaseList
        while Source^<>#0 do //Source est terminée par un double #0, je me serts du deuxième #0 pour tester la fin de la liste
        begin
          FileName:=Source;

          // windows rajoute parfois *.* a la fin d'un nom de répertoire
          if WideExtractFileName(FileName)='*.*' then
          begin
            FileName:=WideExcludeTrailingBackslash(WideExtractFilePath(FileName));
          end;

          Item:=TBaseItem.Create;
          Item.SrcName:=FileName;
          Item.IsDirectory:=WideDirectoryExists(FileName);

          BaseList.Add(Item);

          Inc(Source,Length(Source)+1);
        end;

        Handled:=WorkThreadList.ProcessBaseList(BaseList,Operation,Destination);
      end;
  end;

  Boolean(answerBuf^):=Handled;
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// THookEngine: classe gérant le hooking des processus et le démarrage des threads
//              de travail
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor THookEngine.Create;
begin
  // creation du lien IPC
  if not CreateIpcQueue(IPC_NAME,HookCallback) then
  begin
    raise EHookEngineInitFailed.Create(lsHookEngineNoIPC);
  end;

{$IFDEF NEW_HOOK_ENGINE}
  // creation du filemapping
  App2HookMapping:=CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SizeOf(App2HookData),FILE_MAPING_NAME);
  App2HookData:=nil;
  if App2HookMapping<>0 then
  begin
    App2HookData:=MapViewOfFile(App2HookMapping,FILE_MAP_ALL_ACCESS,0,0,0);
  end;

  if (App2HookMapping=0) or (App2HookData=nil) then
  begin
    raise EHookEngineInitFailed.Create(lsHookEngineNoFileMapping);
  end;
{$ENDIF}
end;

destructor THookEngine.Destroy;
begin
  DestroyIpcQueue(IPC_NAME);
{$IFDEF NEW_HOOK_ENGINE}
  UnmapViewOfFile(App2HookData);
  CloseHandle(App2HookMapping);
{$ENDIF}
end;

procedure THookEngine.InstallHook;
begin
  if not InjectLibrary(CURRENT_USER,DLL_NAME) then raise EHookingFailed.Create(lsGlobalHookingFailed);
end;

procedure THookEngine.RefreshHook;
begin
  InstallHook;
end;

procedure THookEngine.UninstallHook;
begin
  UninjectLibrary(CURRENT_USER,DLL_NAME);
end;

end.
