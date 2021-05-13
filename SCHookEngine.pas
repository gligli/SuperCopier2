unit SCHookEngine;

interface
uses
  Windows,Classes,SysUtils,TntSysUtils,madCodeHook,SCCommon,SCConfig,SCLocStrings,SCBaseList,SCWorkThreadList,SCHookShared;

type
  EHookEngineInitFailed=class(Exception);
  EHookingFailed=class(Exception);

  THookEngine=class
  private
    App2HookData:TSCApp2HookData;
  public
    CopyHandlingActive:Boolean;
    IsUserHook:Boolean;

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
  if HookEngine.CopyHandlingActive then
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
  if not CreateIpcQueue(IPC_NAME,HookCallback) then
  begin
    raise EHookEngineInitFailed.Create(lsHookEngineNoIPC);
  end;

  
end;

destructor THookEngine.Destroy;
begin
  DestroyIpcQueue(IPC_NAME);

end;

procedure THookEngine.InstallHook;
begin
end;

procedure THookEngine.RefreshHook;
begin
end;

procedure THookEngine.UninstallHook;
begin
end;

end.
