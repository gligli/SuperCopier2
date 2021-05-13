unit SCCopyForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, TntForms,Forms,
  Dialogs, StdCtrls, Gauges, TntStdCtrls, ComCtrls, TntComCtrls, Controls,
  ExtCtrls, TntExtCtrls, Spin, Menus, TntMenus,SCFilelist,ScBaseList,ShellApi,
  TntDialogs,TntClasses,SCCommon;


type
  TLvFileListAction=procedure(FileList:TFileList;Item:TListItem);

  TCopyForm = class(TTntForm)
    ggFile: TGauge;
    ggAll: TGauge;
    llFrom: TTntLabel;
    llFile: TTntLabel;
    llAll: TTntLabel;
    btCancel: TTntButton;
    btSkip: TTntButton;
    btPause: TTntButton;
    llSpeed: TTntLabel;
    llTo: TTntLabel;
    llFromTitle: TTntLabel;
    llToTitle: TTntLabel;
    pcPages: TTntPageControl;
    tsFileList: TTntTabSheet;
    tsErrors: TTntTabSheet;
    tsOptions: TTntTabSheet;
    pnFileListButtons: TTntPanel;
    lvFileList: TTntListView;
    llAllRemaining: TTntLabel;
    llFileRemaining: TTntLabel;
    pnErrorListButtons: TTntPanel;
    lvErrorList: TTntListView;
    btErrorClear: TTntButton;
    btFileUp: TTntButton;
    btFileRemove: TTntButton;
    btFileDown: TTntButton;
    btFileBottom: TTntButton;
    btFileTop: TTntButton;
    pmFileContext: TTntPopupMenu;
    miTop: TTntMenuItem;
    miUp: TTntMenuItem;
    miDown: TTntMenuItem;
    miBottom: TTntMenuItem;
    miRemove: TTntMenuItem;
    miSelectAll: TTntMenuItem;
    miInvert: TTntMenuItem;
    N1: TTntMenuItem;
    N2: TTntMenuItem;
    pmDropFiles: TTntPopupMenu;
    miChooseDest: TTntMenuItem;
    miDefaultDest: TTntMenuItem;
    miCancel: TTntMenuItem;
    N3: TTntMenuItem;
    btFileSave: TTntButton;
    btFileLoad: TTntButton;
    odCopyList: TTntOpenDialog;
    sdCopyList: TTntSaveDialog;
    miChooseSetDefault: TTntMenuItem;
    gbSpeedLimit: TTntGroupBox;
    chSpeedLimit: TTntCheckBox;
    cbSpeedLimit: TTntComboBox;
    llSpeedLimitKB: TTntLabel;
    gbCollisions: TTntGroupBox;
    llCollisions: TTntLabel;
    cbCollisions: TTntComboBox;
    gbCopyErrors: TTntGroupBox;
    llCopyErrors: TTntLabel;
    cbCopyError: TTntComboBox;
    gbGeneral: TTntGroupBox;
    llCopyEnd: TTntLabel;
    cbCopyEnd: TTntComboBox;
    btErrorSaveLog: TTntButton;
    sdErrorLog: TTntSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure btSkipClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chSpeedLimitClick(Sender: TObject);
    procedure lvFileListData(Sender: TObject; Item: TListItem);
    procedure btErrorClearClick(Sender: TObject);
    procedure btFileRemoveClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure miInvertClick(Sender: TObject);
    procedure btFileUpClick(Sender: TObject);
    procedure btFileDownClick(Sender: TObject);
    procedure btFileTopClick(Sender: TObject);
    procedure btFileBottomClick(Sender: TObject);
    procedure miDefaultDestClick(Sender: TObject);
    procedure miChooseDestClick(Sender: TObject);
    procedure miCancelClick(Sender: TObject);
    procedure btFileSaveClick(Sender: TObject);
    procedure btFileLoadClick(Sender: TObject);
    procedure miChooseSetDefaultClick(
      Sender: TObject);
    procedure cbCopyEndChange(Sender: TObject);
    procedure cbSpeedLimitChange(Sender: TObject);
    procedure cbSpeedLimitKeyPress(Sender: TObject; var Key: Char);
    procedure cbCollisionsChange(Sender: TObject);
    procedure cbCopyErrorChange(Sender: TObject);
    procedure btErrorSaveLogClick(Sender: TObject);
  private
    { Déclarations privées }
 		DroppedBaseList:TBaseList;
    FState:TCopyWindowState;
    FConfigData:TCopyWindowConfigData;

    procedure ProcessLvFileListAction(Action:TLvFileListAction;SelectedOnly:Boolean;BackwardScan:Boolean=True);
    procedure OnDropFiles(var Msg:TMessage); message WM_DROPFILES;

    procedure SetState(Value:TCopyWindowState);
    procedure SetConfigData(Value:TCopyWindowConfigData);
  public
    { Déclarations publiques }
    Action:TCopyWindowAction;
    CopyThread:TThread; // déclaré en tant que TThread pour éviter la référence circulaire

    property State:TCopyWindowState read FState write SetState;
    property ConfigData:TCopyWindowConfigData read FConfigData write SetConfigData;

    procedure SaveCopyErrorLog(FileName:WideString);
  end;

var
  CopyForm: TCopyForm;

implementation

uses DateUtils,SCCopyThread, SCCopier,SCWin32,SCConfig, StrUtils,TntSysutils;

var DestIndex:Integer;

{$R *.dfm}

//******************************************************************************
// MoveSelectionInfo: passe les infos de sélection et de focus d'un item à un autre
//******************************************************************************
procedure MoveSelectionInfo(Item:TListItem;DestIndex:Integer);
var Focused:Boolean;
    Destination:TListItem;
begin
  Focused:=Item.Focused;
  Item.Selected:=False;
  Destination:=Item.Owner.Item[DestIndex];
  Destination.Selected:=True;
  Destination.Focused:=Focused;
end;

//******************************************************************************
//******************************************************************************
// Actions sur lvFileList
//******************************************************************************
//******************************************************************************

procedure RemoveAction(Filelist:TFileList;Item:TListItem);
begin
  Filelist.Delete(Item.Index,True);
end;

procedure SelectAction(Filelist:TFileList;Item:TListItem);
begin
  Item.Selected:=True;
end;

procedure InvertAction(Filelist:TFileList;Item:TListItem);
begin
  Item.Selected:=not Item.Selected;
end;

procedure MoveUpAction(Filelist:TFileList;Item:TListItem);
begin
  if Item.Index>1 then
  begin
    Filelist.Move(Item.Index,Item.Index-1);
    MoveSelectionInfo(Item,Item.Index-1);
  end;
end;

procedure MoveDownAction(Filelist:TFileList;Item:TListItem);
begin
  if Item.Index<Filelist.Count-1 then
  begin
    Filelist.Move(Item.Index,Item.Index+1);
    MoveSelectionInfo(Item,Item.Index+1);
  end;
end;

procedure MoveTopAction(Filelist:TFileList;Item:TListItem);
begin
  Filelist.Move(Item.Index,DestIndex);
  MoveSelectionInfo(Item,DestIndex);
  Inc(DestIndex);
end;

procedure MoveBottomAction(Filelist:TFileList;Item:TListItem);
begin
  Filelist.Move(Item.Index,DestIndex);
  MoveSelectionInfo(Item,DestIndex);
  Dec(DestIndex);
end;

//******************************************************************************
// ProcessLvFileListAction : exécute une action sur les éléments de lvFileList
//******************************************************************************
procedure TCopyForm.ProcessLvFileListAction(Action:TLvFileListAction;SelectedOnly:Boolean;BackwardScan:Boolean=True);
var i:Integer;
begin
  Assert(Assigned(Action),'No action to do');

  try
    with TCopyThread(CopyThread).LockCopier do
    begin
      Screen.Cursor:=crHourGlass;

      // l'item 0 n'est pas traité car c'est l'item en train d'être copié et il ne peut être altéré
      if SelectedOnly then
      begin
        if (lvFileList.SelCount=1) and (lvFileList.Selected.Index>1) then
        begin
          Action(FileList,lvFileList.Selected);
        end
        else
        begin
          if lvFileList.SelCount>0 then
          begin
            if BackwardScan then
            begin
              for i:=lvFileList.Items.Count-1 downto 1 do
                if lvFileList.Items[i].Selected then Action(FileList,lvFileList.Items[i]);
            end
            else
            begin
              for i:=1 to lvFileList.Items.Count-1 do
                if lvFileList.Items[i].Selected then Action(FileList,lvFileList.Items[i]);
            end;
          end;
        end;
      end
      else
      begin
        if BackwardScan then
        begin
          for i:=lvFileList.Items.Count-1 downto 1 do
            Action(FileList,lvFileList.Items[i]);
        end
        else
        begin
          for i:=1 to lvFileList.Items.Count-1 do
            Action(FileList,lvFileList.Items[i]);
        end;
      end;

      //maj info
      TCopyThread(CopyThread).UpdateCopyWindow;

      //maj listview
      lvFileList.Refresh;
      lvFileList.Items.Count:=FileList.Count;
    end;
  finally
    Screen.Cursor:=crDefault;
    TCopyThread(CopyThread).UnlockCopier
  end;
end;

//******************************************************************************
// SetState : appelée quand la thread fait changer la fenêtre d'état
//******************************************************************************
procedure TCopyForm.SetState(Value:TCopyWindowState);
begin
  FState:=Value;

  case FState of
    cwsWaiting,
    cwsRecursing:
    begin
      btPause.Enabled:=False;
      btSkip.Enabled:=False;
      btCancel.Enabled:=True;
    end;
    cwsCopying:
    begin
      btPause.Enabled:=True;
      btSkip.Enabled:=True;
      btCancel.Enabled:=True;
    end;
    cwsPaused:
    begin
      llSpeed.Caption:='Paused';

      btPause.Enabled:=True;
      btSkip.Enabled:=True;
      btCancel.Enabled:=True;
    end;
    cwsWaitingActionResult:
    begin
      btPause.Enabled:=False;
      btSkip.Enabled:=False;
      btCancel.Enabled:=False;
    end;
  end;
end;

//******************************************************************************
// SetState : appelée quand la thread change la config de la fenêtre
//******************************************************************************
procedure TCopyForm.SetConfigData(Value:TCopyWindowConfigData);
begin
  FConfigData:=Value;

  with FConfigData do
  begin
    cbCopyEnd.ItemIndex:=Integer(CopyEndAction);
    chSpeedLimit.Checked:=ThrottleEnabled;
    cbSpeedLimit.Text:=IntToStr(ThrottleSpeedLimit);
    cbCollisions.ItemIndex:=Integer(CollisionAction);
    cbCopyError.ItemIndex:=Integer(CopyErrorAction);
  end;
end;

//******************************************************************************
// SaveCopyErrorLog : écrit le log des erreurs dans un fichier
//******************************************************************************
procedure TCopyForm.SaveCopyErrorLog(FileName:WideString);
var Log:TStringList;
    FS:TFileStream;
    i:integer;
begin
  Log:=TStringList.Create;
  try
    // entete
    Log.Add(Format('*** %s: %s ***',[DateToStr(Date),TCopyThread(CopyThread).DisplayName]));

    // liste des erreurs
    for i:=0 to lvErrorList.Items.Count-1 do
      with lvErrorList.Items[i] do
      begin
        Log.Add(Format('%s %s %s : %s',[Caption,SubItems[0],SubItems[1],SubItems[2]]));
      end;

    // on crée le fichier si il n'existe pas et on l'ouvre si il existe
    if WideFileExists(FileName) then
      FS:=TFileStream.Create(FileName,fmOpenReadWrite)
    else
      FS:=TFileStream.Create(FileName,fmCreate);

    try
      // on se place a la fin du fichier
      FS.Seek(0,soEnd);

      Log.SaveToStream(FS);
    finally
      FS.Free;
    end;
  finally
    Log.Free;
  end;
end;

procedure TCopyForm.FormCreate(Sender: TObject);
begin
  // init variables
  Action:=cwaNone;
  State:=cwsWaiting;

  DroppedBaseList:=nil;

  // accepter le drag & drop
  DragAcceptFiles(Handle,True);

  // charger la config par défaut
  ConfigData:=Config.Values.DefaultCopyWindowConfig;
end;

procedure TCopyForm.btPauseClick(Sender: TObject);
begin
  // ne pas perturber les autres actions
  if Action=cwaPause then
  begin
    Action:=cwaNone;
  end
  else
  begin
    if Action=cwaNone then
    begin
      Action:=cwaPause;
    end;
  end;
end;

procedure TCopyForm.btSkipClick(Sender: TObject);
begin
  Action:=cwaSkip;
  State:=cwsWaitingActionResult;
end;

procedure TCopyForm.btCancelClick(Sender: TObject);
begin
  Action:=cwaCancel;
  State:=cwsWaitingActionResult;
end;

procedure TCopyForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Action:=cwaCancel;
  State:=cwsWaitingActionResult;

  CanClose:=False;
end;

procedure TCopyForm.lvFileListData(Sender: TObject; Item: TListItem);
begin
//  btCancel.Caption:=IntToStr(StrToIntDef(btCancel.Caption,0)+1);
  try
    with TCopyThread(CopyThread).LockCopier,TTntListItem(Item) do
    begin
      if Index<FileList.Count then
        with FileList[Item.Index] do
        begin
          Caption:=SrcFullName;
          SubItems.Add(SizeToString(SrcSize));
          SubItems.Add(Directory.Destpath);
        end;
    end;
  finally
    TCopyThread(CopyThread).UnlockCopier
  end;
end;

procedure TCopyForm.btErrorClearClick(Sender: TObject);
begin
  lvErrorList.Clear;
end;

procedure TCopyForm.btErrorSaveLogClick(Sender: TObject);
begin
  sdErrorLog.InitialDir:=TCopyThread(CopyThread).DefaultDir;
  sdErrorLog.FileName:=WideExtractFileName(Config.Values.ErrorLogFileName);

  if sdErrorLog.Execute then
    try
      Screen.Cursor:=crHourGlass;
      SaveCopyErrorLog(sdErrorLog.FileName);
    finally
      Screen.Cursor:=crDefault;
    end;
end;

procedure TCopyForm.btFileRemoveClick(Sender: TObject);
begin
  ProcessLvFileListAction(RemoveAction,True);
end;

procedure TCopyForm.miSelectAllClick(Sender: TObject);
begin
  ProcessLvFileListAction(SelectAction,False);
end;

procedure TCopyForm.miInvertClick(Sender: TObject);
begin
  ProcessLvFileListAction(InvertAction,False);
end;

procedure TCopyForm.btFileUpClick(Sender: TObject);
begin
  ProcessLvFileListAction(MoveUpAction,True,False);
end;

procedure TCopyForm.btFileDownClick(Sender: TObject);
begin
  ProcessLvFileListAction(MoveDownAction,True);
end;

procedure TCopyForm.btFileTopClick(Sender: TObject);
begin
  DestIndex:=1;
  ProcessLvFileListAction(MoveTopAction,True,False);
end;

procedure TCopyForm.btFileBottomClick(Sender: TObject);
begin
  DestIndex:=lvFileList.Items.Count-1;
  ProcessLvFileListAction(MoveBottomAction,True);
end;

procedure TCopyForm.btFileSaveClick(Sender: TObject);
var FS:TTntFileStream;
begin
  if sdCopyList.Execute then
  begin
    try
      Screen.Cursor:=crHourGlass;
      with TCopyThread(CopyThread).LockCopier do
      begin
        FS:=TTntFileStream.Create(sdCopyList.FileName,fmCreate);
        try
          SaveToStream(FS);
        finally
          FS.Free;
        end;
      end;
    finally
      TCopyThread(CopyThread).UnlockCopier;
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure TCopyForm.btFileLoadClick(Sender: TObject);
var FS:TTntFileStream;
begin
  if odCopyList.Execute then
  begin
    try
      Screen.Cursor:=crHourGlass;
      with TCopyThread(CopyThread).LockCopier do
      begin
        FS:=TTntFileStream.Create(odCopyList.FileName,fmOpenRead);
        try
          LoadFromStream(FS);
        finally
          FS.Free;
        end;

        //maj info
        TCopyThread(CopyThread).UpdateCopyWindow;

        //maj listview
        lvFileList.Refresh;
        lvFileList.Items.Count:=FileList.Count;
      end;
    finally
      TCopyThread(CopyThread).UnlockCopier;
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure TCopyForm.miDefaultDestClick(Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(DroppedBaseList,amDefaultDir);
  DroppedBaseList:=nil;
end;

procedure TCopyForm.miChooseDestClick(Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(DroppedBaseList,amPromptForDest);
  DroppedBaseList:=nil;
end;

procedure TCopyForm.miChooseSetDefaultClick(
  Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(DroppedBaseList,amPromptForDestAndSetDefault);
  DroppedBaseList:=nil;
end;

procedure TCopyForm.miCancelClick(Sender: TObject);
begin
  // on libère la baselist vu qu'elle ne vas pas être traitée
  DroppedBaseList.Free;
  DroppedBaseList:=nil;
end;

procedure TCopyForm.cbCopyEndChange(Sender: TObject);
begin
  FConfigData.CopyEndAction:=TCopyWindowCopyEndAction(cbCopyEnd.ItemIndex);
end;

procedure TCopyForm.chSpeedLimitClick(Sender: TObject);
begin
  cbSpeedLimit.Enabled:=chSpeedLimit.Checked;
  FConfigData.ThrottleEnabled:=chSpeedLimit.Checked;
end;
procedure TCopyForm.cbSpeedLimitChange(Sender: TObject);
begin
  FConfigData.ThrottleSpeedLimit:=StrToIntDef(cbSpeedLimit.Text,-1);
end;

procedure TCopyForm.cbSpeedLimitKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) and (Key>#31) then Key:=#0; // autoriser seulement les chiffres et les caractères de contrôle
end;

procedure TCopyForm.cbCollisionsChange(Sender: TObject);
begin
  FConfigData.CollisionAction:=TCollisionAction(cbCollisions.ItemIndex);
end;

procedure TCopyForm.cbCopyErrorChange(Sender: TObject);
begin
  FConfigData.CopyErrorAction:=TCopyErrorAction(cbCopyError.ItemIndex);
end;

//*******************************************************************************
// Procédures de message
//*******************************************************************************

procedure TCopyForm.OnDropFiles(var Msg:TMessage);
var i,NumFiles:integer;
		FN: array[0..MAX_PATH] of WideChar;
		BaseItem:TBaseItem;
begin
	try
		Screen.Cursor:=crHourGlass;

    if Assigned(DroppedBaseList) then DroppedBaseList.Free;

    // on construit la BaseList
		NumFiles:=SCWin32.DragQueryFile(Msg.WParam,$FFFFFFFF,nil,0);
		if NumFiles=0 then exit;

		DroppedBaseList:=TBaseList.Create;

		for i:=0 to NumFiles-1 do
		begin
			SCWin32.DragQueryFile(Msg.WParam,i,FN,MAX_PATH);
			BaseItem:=TBaseItem.Create;
      BaseItem.SrcName:=FN;
      BaseItem.IsDirectory:=WideDirectoryExists(FN);
      DroppedBaseList.Add(BaseItem);
    end;

    DragFinish(Msg.WParam);

    // On ouvre le menu pour le choix de l'action
    miDefaultDest.Enabled:=TCopyThread(CopyThread).DefaultDir<>'?';
    miDefaultDest.Caption:=LeftStr(miDefaultDest.Caption,Pos('(',miDefaultDest.Caption))+TCopyThread(CopyThread).DefaultDir+')';
    pmDropFiles.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
  finally
    Screen.Cursor:=crDefault;
  end;
end;

end.
