unit SCMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,  TntForms,
  Dialogs, StdCtrls,filectrl,tntsysutils,TntStdCtrls,ShellApi, Controls,
  ComCtrls, TntComCtrls, XPMan, ScSystray, Menus, TntMenus, ImgList;

type
  TMainForm = class(TTntForm)
    XPManifest: TXPManifest;
    Systray: TScSystray;
    pmSystray: TTntPopupMenu;
    miActivate: TTntMenuItem;
    N1: TTntMenuItem;
    miConfig: TTntMenuItem;
    miAbout: TTntMenuItem;
    miExit: TTntMenuItem;
    N2: TTntMenuItem;
    miNewThread: TTntMenuItem;
    miNewCopyThread: TTntMenuItem;
    miNewMoveThread: TTntMenuItem;
    miThreadList: TTntMenuItem;
    miNoThreadList: TTntMenuItem;
    miDeactivate: TTntMenuItem;
    ilGlobal: TImageList;
    TntButton1: TTntButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miConfigClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miNewCopyThreadClick(Sender: TObject);
    procedure miNewMoveThreadClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miThreadListClick(Sender: TObject);
    procedure miActivateClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  CopyHandlingActive:Boolean;

implementation
uses SCConfig,SCCommon,SCWin32,SCCopyThread,SCBaseList,SCFileList,SCDirList,SCHookShared,SCWorkThreadList,madCodeHook,
  Forms,SCConfigForm,SCAboutForm;
{$R *.dfm}

//******************************************************************************
// HookCallback
//******************************************************************************
procedure HookCallback(name:pchar;messageBuf:pointer;messageLen:dword;
                       answerBuf:pointer;answerLen:dword);stdcall;
var Handled:Boolean;
    HookData:TSCHookData;
    RawProcessName:array[0..MAX_PATH] of char;
    ProcessName:String;
    Source,Destination:PWideChar;
    FileName:WideString;
    BaseList:TBaseList;
    Item:TBaseItem;
begin
  Handled:=False;
  if CopyHandlingActive then
  begin
    // on récup les données qui étaient collées les unes apres les autres
    Move(messageBuf^,HookData,SizeOf(TSCHookData));
    Destination:=Pointer(Cardinal(messageBuf)+SizeOf(TSCHookData));
    Source:=Pointer(Integer(messageBuf)+SizeOf(TSCHookData)+HookData.DestinationSize);

    // le processus ayant lancé la copie doit-it être pris en charge?
    ProcessIdToFileName(HookData.ProcessId,RawProcessName);
    ProcessName:=LowerCase(ExtractFileName(RawProcessName));
    if Pos(ProcessName,Config.Values.HandledProcesses)<>0 then
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

          Inc(Source,StrLenW(Source)+1);
        end;

        Handled:=WorkThreadList.ProcessBaseList(BaseList,Operation,Destination);
      end;
  end;

  Boolean(answerBuf^):=Handled;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  Windows.SetParent(Handle,THandle(HWND_MESSAGE)); // cacher la form

  Systray.Hint:='SuperCopier 2';

  OpenConfig;

  CopyHandlingActive:=Config.Values.ActivateOnStart;
  miActivate.Visible:=not CopyHandlingActive;
  miDeactivate.Visible:=CopyHandlingActive;

  WorkThreadList:=TWorkThreadList.Create;

  if not InjectLibrary(ALL_SESSIONS and not CURRENT_PROCESS,DLL_NAME) or
     not CreateIpcQueue(IPC_NAME,HookCallback) then
  begin
    ShowMessage('hook foiré');
    Application.Terminate;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;

  DestroyIpcQueue(IPC_NAME);
  UninjectLibrary(ALL_SESSIONS,DLL_NAME);

  WorkThreadList.Free;

  CloseConfig;
end;

procedure TMainForm.miConfigClick(Sender: TObject);
begin
  if Assigned(ConfigForm) then
  begin
    ConfigForm.BringToFront;
  end
  else
  begin
    Application.CreateForm(TConfigForm,ConfigForm);
    ConfigForm.Show;
  end;
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  if Assigned(AboutForm) then
  begin
    AboutForm.BringToFront;
  end
  else
  begin
    Application.CreateForm(TAboutForm,AboutForm);
    AboutForm.Show;
  end;
end;

procedure TMainForm.miNewCopyThreadClick(Sender: TObject);
begin
  WorkThreadList.CreateEmptyCopyThread(False);
end;

procedure TMainForm.miNewMoveThreadClick(Sender: TObject);
begin
  WorkThreadList.CreateEmptyCopyThread(True);
end;

procedure TMainForm.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.miThreadListClick(Sender: TObject);
var i:Integer;
    MenuItem:TMenuItem;
begin
  for i:=0 to WorkThreadList.Count-1 do
  begin
    MenuItem:=TMenuItem.Create(pmSystray);
    MenuItem.Caption:=WorkThreadList[i].DisplayName;
    MenuItem.Tag:=i;
    miThreadList.Add(MenuItem);
  end;

  // enlever les anciens items
  while miThreadList.Count>(WorkThreadList.Count+1) do miThreadList.Delete(1);
end;

procedure TMainForm.miActivateClick(Sender: TObject);
begin
  CopyHandlingActive:=not CopyHandlingActive;

  miActivate.Visible:=not CopyHandlingActive;
  miDeactivate.Visible:=CopyHandlingActive;
end;

end.








































