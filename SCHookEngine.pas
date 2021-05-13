unit SCHookEngine;

interface
uses
  Windows,Classes,SysUtils,TntSysUtils,madCodeHook,SCCommon,SCConfig,SCLocStrings,SCBaseList,SCWorkThreadList,SCHookShared;

type
  EHookEngineInitFailed=class(Exception);
  EHookingFailed=class(Exception);

  THookEngine=class
  private
    App2HookData:PSCApp2HookData;
    App2HookMapping:THandle;

    FCopyHandlingActive:Boolean;
    FIsUserHook:Boolean;
    FProcessList:String;
  protected
    set
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
    // on r�cup les donn�es qui �taient coll�es les unes apres les autres
    Move(messageBuf^,HookData,SizeOf(TSCHook2AppData));
    Destination:=Pointer(Cardinal(messageBuf)+SizeOf(TSCHook2AppData));
    Source:=Pointer(Integer(messageBuf)+SizeOf(TSCHook2AppData)+HookData.DestinationSize);

    // le processus ayant lanc� la copie doit-it �tre pris en charge?
    ProcessIdToFileName(HookData.ProcessId,RawProcessName);
    ProcessName:=LowerCase(ExtractFileName(RawProcessName));
    if Pos(ProcessName,LowerCase(Config.Values.HandledProcesses))<>0 then
      with HookData do
      begin
        BaseList:=TBaseList.Create;

        // on parcours la liste des Sources et on ajoute les �l�ments � la BaseList
        while Source^<>#0 do //Source est termin�e par un double #0, je me serts du deuxi�me #0 pour tester la fin de la liste
        begin
          FileName:=Source;

          // windows rajoute parfois *.* a la fin d'un nom de r�pertoire
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
// THookEngine: classe g�rant le hooking des processus et le d�marrage des threads
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
end;

destructor THookEngine.Destroy;
begin
  DestroyIpcQueue(IPC_NAME);
  UnmapViewOfFile(App2HookData); 
  CloseHandle(App2HookMapping);
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
