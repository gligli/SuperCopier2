unit SCMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,  TntForms,
  Dialogs, StdCtrls,filectrl,tntsysutils,TntStdCtrls,ShellApi, Controls,
  ComCtrls, TntComCtrls, XPMan, ScSystray, Menus, TntMenus, ImgList,
  Buttons, TntButtons,SCConfigShared;

const
  CANCEL_TIMEOUT=5000; //ms

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
    miCancelAll: TTntMenuItem;
    miCancelThread: TTntMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miConfigClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miNewCopyThreadClick(Sender: TObject);
    procedure miNewMoveThreadClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miThreadListClick(Sender: TObject);
    procedure miActivateClick(Sender: TObject);
    procedure miCancelAllClick(Sender: TObject);
    procedure miCancelThreadClick(Sender: TObject);
  private
    { D�clarations priv�es }
    procedure OpenDialog(var AMsg:TMessage); message WM_OPENDIALOG;
  public
    { D�clarations publiques }
  end;

var
  MainForm: TMainForm;
  CopyHandlingActive:Boolean;

implementation
uses SCConfig,SCCommon,SCWin32,SCCopyThread,SCBaseList,SCFileList,SCDirList,SCHookShared,SCWorkThreadList,madCodeHook,
  Forms,SCConfigForm,SCAboutForm,SCLocStrings;
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
    // on r�cup les donn�es qui �taient coll�es les unes apres les autres
    Move(messageBuf^,HookData,SizeOf(TSCHookData));
    Destination:=Pointer(Cardinal(messageBuf)+SizeOf(TSCHookData));
    Source:=Pointer(Integer(messageBuf)+SizeOf(TSCHookData)+HookData.DestinationSize);

    // le processus ayant lanc� la copie doit-it �tre pris en charge?
    ProcessIdToFileName(HookData.ProcessId,RawProcessName);
    ProcessName:=LowerCase(ExtractFileName(RawProcessName));
    if Pos(ProcessName,Config.Values.HandledProcesses)<>0 then
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

          Inc(Source,StrLenW(Source)+1);
        end;

        Handled:=WorkThreadList.ProcessBaseList(BaseList,Operation,Destination);
      end;
  end;

  Boolean(answerBuf^):=Handled;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption:=SC2_MAINFORM_CAPTION;

  Windows.SetParent(Handle,THandle(HWND_MESSAGE)); // cacher la form

  Systray.Hint:='SuperCopier 2';
  Systray.Icone:=Application.Icon;

  OpenConfig;

  CopyHandlingActive:=Config.Values.ActivateOnStart;
  miActivate.Visible:=not CopyHandlingActive;
  miDeactivate.Visible:=CopyHandlingActive;

  WorkThreadList:=TWorkThreadList.Create;

  if not InjectLibrary(ALL_SESSIONS and not CURRENT_PROCESS,DLL_NAME) or
     not CreateIpcQueue(IPC_NAME,HookCallback) then
  begin
    SCWin32.MessageBox(Handle,lsHookErrorText,lsHookErrorCaption,MB_OK or MB_ICONERROR);
    Application.Terminate;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;

  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);

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
    MenuItem,CancelSubItem:TMenuItem;
begin
  for i:=0 to WorkThreadList.Count-1 do
  begin
    MenuItem:=TMenuItem.Create(pmSystray);
    MenuItem.Caption:=WorkThreadList[i].DisplayName;
    MenuItem.ImageIndex:=miThreadList.ImageIndex;
    MenuItem.Tag:=i;
    miThreadList.Add(MenuItem);

    CancelSubItem:=TMenuItem.Create(pmSystray);
    CancelSubItem.Caption:=miCancelThread.Caption;
    CancelSubItem.OnClick:=miCancelThread.OnClick;
    CancelSubItem.ImageIndex:=miCancelThread.ImageIndex;
    MenuItem.Add(CancelSubItem);
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

procedure TMainForm.miCancelAllClick(Sender: TObject);
begin
  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);
end;

procedure TMainForm.miCancelThreadClick(Sender: TObject);
begin
  WorkThreadList[(Sender as TMenuItem).Tag].Cancel;
end;

//******************************************************************************
// OpenDialog: g�re les messages envoy�s par SC2Config
//******************************************************************************
procedure TMainForm.OpenDialog(var AMsg:TMessage);
var APoint: TPoint;
begin
  case AMsg.WParam of
    OD_CONFIG:
    begin
      miConfig.Click;
    end;
    OD_ABOUT:
    begin
      miAbout.Click;
    end;
    OD_QUIT:
    begin
      miExit.Click;
    end;
    OD_ONOFF:
    begin
      miActivate.Click;
    end;
    OD_SHOWMENU:
    begin
      GetCursorPos(APoint);
      Application.ProcessMessages;
      SetForegroundWindow(Handle);

      pmSystray.PopupComponent := Self;
      pmSystray.Popup(APoint.X, APoint.Y);

      PostMessage(Handle, WM_NULL, 0, 0);
    end;
  end;
end;

end.








































