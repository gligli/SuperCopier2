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

unit SCCopyForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, TntForms,Forms,
  Dialogs, StdCtrls,TntStdCtrls, ComCtrls, TntComCtrls, Controls,
  ExtCtrls, TntExtCtrls, Spin, Menus, TntMenus,SCFilelist,ScBaseList,ShellApi,
  TntDialogs,TntClasses,SCCommon, SCProgessBar, ScSystray,
  SCFileNameLabel, Buttons, TntButtons, ToolWin, ScPopupButton,SCLocEngine,Themes,
  ScTrackBar;

const
  WIDTH_DPI_MULTIPLIER=408/96;
  FOLDED_HEIGHT_DPI_MULTIPLIER=145/96;
  UNFOLDED_HEIGHT_DPI_MULTIPLIER=409/96;

type
  TLvFileListAction=procedure(FileList:TFileList;Item:TListItem);

  TCopyForm = class(TTntForm)
    llAll: TTntLabel;
    llSpeed: TTntLabel;
    llFromTitle: TTntLabel;
    llToTitle: TTntLabel;
    pcPages: TTntPageControl;
    tsCopyList: TTntTabSheet;
    tsErrors: TTntTabSheet;
    tsOptions: TTntTabSheet;
    lvFileList: TTntListView;
    lvErrorList: TTntListView;
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
    pmNewFiles: TTntPopupMenu;
    miChooseDest: TTntMenuItem;
    miDefaultDest: TTntMenuItem;
    miCancel: TTntMenuItem;
    N3: TTntMenuItem;
    odCopyList: TTntOpenDialog;
    sdCopyList: TTntSaveDialog;
    miChooseSetDefault: TTntMenuItem;
    gbSpeedLimit: TTntGroupBox;
    chSpeedLimit: TTntCheckBox;
    llCustomSpeedLimit: TTntLabel;
    gbCollisions: TTntGroupBox;
    llCollisions: TTntLabel;
    cbCollisions: TTntComboBox;
    gbCopyErrors: TTntGroupBox;
    llCopyErrors: TTntLabel;
    cbCopyError: TTntComboBox;
    gbCopyEnd: TTntGroupBox;
    llCopyEnd: TTntLabel;
    cbCopyEnd: TTntComboBox;
    sdErrorLog: TTntSaveDialog;
    btSaveDefaultCfg: TTntButton;
    odFileAdd: TTntOpenDialog;
    pmFileAdd: TTntPopupMenu;
    miAddFiles: TTntMenuItem;
    miAddFolder: TTntMenuItem;
    ggFile: TSCProgessBar;
    ggAll: TSCProgessBar;
    Systray: TScSystray;
    tiSystray: TTimer;
    llTo: TSCFileNameLabel;
    llFrom: TSCFileNameLabel;
    btFileTop: TTntSpeedButton;
    btFileUp: TTntSpeedButton;
    btFileDown: TTntSpeedButton;
    btFileBottom: TTntSpeedButton;
    btFileAdd: TTntSpeedButton;
    btFileRemove: TTntSpeedButton;
    btFileSave: TTntSpeedButton;
    btFileLoad: TTntSpeedButton;
    btErrorClear: TTntSpeedButton;
    btErrorSaveLog: TTntSpeedButton;
    btCancel: TScPopupButton;
    btSkip: TScPopupButton;
    btPause: TScPopupButton;
    btResume: TScPopupButton;
    btUnfold: TScPopupButton;
    btFold: TScPopupButton;
    pmSystray: TTntPopupMenu;
    miStCancel: TTntMenuItem;
    miStPause: TTntMenuItem;
    miStResume: TTntMenuItem;
    llFile: TSCFileNameLabel;
    N4: TTntMenuItem;
    miSort: TTntMenuItem;
    miBySrcFullPath: TTntMenuItem;
    miByDestFullPath: TTntMenuItem;
    miBySize: TTntMenuItem;
    miBySrcName: TTntMenuItem;
    miBySrcExt: TTntMenuItem;
    tbSpeedLimit: TScTrackBar;
    edCustomSpeedLimit: TTntEdit;
    llSpeedLimit: TTntLabel;
    procedure FormCreate(Sender: TObject);
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
    procedure edCustomSpeedLimitKeyPress(Sender: TObject; var Key: Char);
    procedure cbCollisionsChange(Sender: TObject);
    procedure cbCopyErrorChange(Sender: TObject);
    procedure btErrorSaveLogClick(Sender: TObject);
    procedure pcPagesChange(Sender: TObject);
    procedure btSaveDefaultCfgClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btFileAddClick(Sender: TObject);
    procedure miAddFilesClick(Sender: TObject);
    procedure miAddFolderClick(Sender: TObject);
    procedure SystrayMouseDown(Sender: TObject);
    procedure tiSystrayTimer(Sender: TObject);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btSkipClick(Sender: TObject; ItemIndex: Integer);
    procedure btPauseClick(Sender: TObject; ItemIndex: Integer);
    procedure btUnfoldClick(Sender: TObject; ItemIndex: Integer);
    procedure miStPauseClick(Sender: TObject);
    procedure miStCancelClick(Sender: TObject);
    procedure lvFileListColumnClick(Sender: TObject; Column: TListColumn);
    procedure miBySrcFullPathClick(Sender: TObject);
    procedure miBySrcNameClick(Sender: TObject);
    procedure miByDestFullPathClick(Sender: TObject);
    procedure miBySizeClick(Sender: TObject);
    procedure miBySrcExtClick(Sender: TObject);
    procedure tbSpeedLimitChange(Sender: TObject);
    procedure edCustomSpeedLimitChange(Sender: TObject);
  private
    { Déclarations privées }
    SystrayBmp:TBitmap;
 		NewBaseList:TBaseList;
    FState:TCopyWindowState;
    FConfigData:TCopyWindowConfigData;
    FUnfolded:Boolean;
    FMinimized:Boolean;
    FMinimizedToTray:Boolean;

    procedure ProcessLvFileListAction(Action:TLvFileListAction;SelectedOnly:Boolean;BackwardScan:Boolean=True);
    procedure OpenNewFilesMenu;
    procedure SortFileList(Mode:TFileListSortMode);
    procedure OnDropFiles(var Msg:TMessage); message WM_DROPFILES;
    procedure OnWindowPosChanged(var Msg:TMessage); message WM_ACTIVATE;
    procedure OnSysCommand(var Msg:TMessage); message WM_SYSCOMMAND;

    procedure SetState(Value:TCopyWindowState);
    procedure SetConfigData(Value:TCopyWindowConfigData);
    procedure SetUnfolded(Value:Boolean);
    procedure SetMinimized(Value:Boolean);
  public
    { Déclarations publiques }
    Paused,SkipPending,CancelPending:Boolean;
    
    CopyThread:TThread; // déclaré en tant que TThread pour éviter la référence circulaire
    UnfoldedHeight,NonClientHeight:Integer;
    NotificationTargetForm:TTntForm;

    property State:TCopyWindowState read FState write SetState;
    property ConfigData:TCopyWindowConfigData read FConfigData write SetConfigData;
    property Unfolded:Boolean read FUnfolded write SetUnfolded;
    property Minimized:Boolean read FMinimized write SetMinimized;
    property MinimizedToTray:Boolean read FMinimizedToTray;

    procedure SaveCopyErrorLog(FileName:WideString);
  end;

var
  CopyForm: TCopyForm;

implementation

uses DateUtils,SCLocStrings,SCCopyThread, SCCopier,SCWin32,SCConfig, StrUtils,TntSysutils,
  SCMainForm, ImgList;

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
  Filelist.Delete(Item.Index+1,True);
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
  if Item.Index>0 then
  begin
    Filelist.Move(Item.Index+1,Item.Index-1+1);
    MoveSelectionInfo(Item,Item.Index-1);
  end;
end;

procedure MoveDownAction(Filelist:TFileList;Item:TListItem);
begin
  if Item.Index<Filelist.Count-2 then
  begin
    Filelist.Move(Item.Index+1,Item.Index+1+1);
    MoveSelectionInfo(Item,Item.Index+1);
  end;
end;

procedure MoveTopAction(Filelist:TFileList;Item:TListItem);
begin
  Filelist.Move(Item.Index+1,DestIndex+1);
  MoveSelectionInfo(Item,DestIndex);
  Inc(DestIndex);
end;

procedure MoveBottomAction(Filelist:TFileList;Item:TListItem);
begin
  Filelist.Move(Item.Index+1,DestIndex+1);
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
              for i:=lvFileList.Items.Count-1 downto 0 do
                if lvFileList.Items[i].Selected then Action(FileList,lvFileList.Items[i]);
            end
            else
            begin
              for i:=0 to lvFileList.Items.Count-1 do
                if lvFileList.Items[i].Selected then Action(FileList,lvFileList.Items[i]);
            end;
          end;
        end;
      end
      else
      begin
        if BackwardScan then
        begin
          for i:=lvFileList.Items.Count-1 downto 0 do
            Action(FileList,lvFileList.Items[i]);
        end
        else
        begin
          for i:=0 to lvFileList.Items.Count-1 do
            Action(FileList,lvFileList.Items[i]);
        end;
      end;

      //maj info
      TCopyThread(CopyThread).UpdateCopyWindow;

      //maj listview
      lvFileList.Invalidate;
      lvFileList.Items.Count:=FileList.Count-1;
    end;
  finally
    Screen.Cursor:=crDefault;
    TCopyThread(CopyThread).UnlockCopier
  end;
end;

//******************************************************************************
// OpenNewFilesMenu : open le menu permettant de choisir la destination
//******************************************************************************
procedure TCopyForm.OpenNewFilesMenu;
begin
  // On ouvre le menu pour le choix de l'action
  miDefaultDest.Enabled:=TCopyThread(CopyThread).DefaultDir<>'?';
  miDefaultDest.Caption:=LeftStr(miDefaultDest.Caption,Pos('(',miDefaultDest.Caption))+TCopyThread(CopyThread).DefaultDir+')';
  pmNewFiles.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

//******************************************************************************
// SetState : appelée quand la thread fait changer la fenêtre d'état
//******************************************************************************
procedure TCopyForm.SetState(Value:TCopyWindowState);
begin
  FState:=Value;

  case FState of
    cwsWaiting,
    cwsRecursing,
    cwsCopyEnd:
    begin
      btPause.Enabled:=True;
      btResume.Enabled:=True;
      btSkip.Enabled:=False;
      btCancel.Enabled:=True;
    end;
    cwsCopying:
    begin
      btPause.Enabled:=True;
      btResume.Enabled:=True;
      btSkip.Enabled:=True;
      btCancel.Enabled:=True;
    end;
    cwsPaused:
    begin
      btPause.Enabled:=True;
      btResume.Enabled:=True;
      btCancel.Enabled:=True;
    end;
    cwsCancelling,
    cwsWaitingActionResult:
    begin
      btPause.Enabled:=False;
      btResume.Enabled:=False;
      btSkip.Enabled:=False;
      btCancel.Enabled:=False;
    end;
  end;

  // menu systray
  miStPause.Enabled:=btPause.Enabled;
  miStResume.Enabled:=btResume.Enabled;
  miStCancel.Enabled:=btCancel.Enabled;
end;

//******************************************************************************
// SetConfigData : appelée quand la thread change la config de la fenêtre
//******************************************************************************
procedure TCopyForm.SetConfigData(Value:TCopyWindowConfigData);
begin
  FConfigData:=Value;

  with FConfigData do
  begin
    cbCopyEnd.ItemIndex:=Integer(CopyEndAction);
    chSpeedLimit.Checked:=ThrottleEnabled;

    edCustomSpeedLimit.Text:=IntToStr(ThrottleSpeedLimit);
    tbSpeedLimit.Position:=SpeedLimitToIndex(ThrottleSpeedLimit);

    cbCollisions.ItemIndex:=Integer(CollisionAction);
    cbCopyError.ItemIndex:=Integer(CopyErrorAction);
  end;
end;

//******************************************************************************
// SetUnfolded : change les paramêtres de la fenêtre pour passer en mode développé ou non
//******************************************************************************
procedure TCopyForm.SetUnfolded(Value:Boolean);
var NewClientHeight:Integer;
begin
  FUnfolded:=Value;

  if FUnfolded then
  begin
    NewClientHeight:=Round(UNFOLDED_HEIGHT_DPI_MULTIPLIER*PixelsPerInch);

    Constraints.MinHeight:=NewClientHeight+NonClientHeight;
    Constraints.MaxHeight:=0;

    ClientHeight:=UnfoldedHeight;
    btUnfold.Visible:=False;
    btFold.Visible:=True;
  end
  else
  begin
    UnfoldedHeight:=ClientHeight;

    NewClientHeight:=Round(FOLDED_HEIGHT_DPI_MULTIPLIER*PixelsPerInch);

    Constraints.MinHeight:=NewClientHeight+NonClientHeight;
    Constraints.MaxHeight:=NewClientHeight+NonClientHeight;

    ClientHeight:=NewClientHeight;
    btUnfold.Visible:=True;
    btFold.Visible:=False;
  end;
end;

//******************************************************************************
// SetMinimized : permets de minimiser la fenêtre dans la taskbar/le systray selon la config
//******************************************************************************
procedure TCopyForm.SetMinimized(Value:Boolean);
begin
  FMinimized:=Value;
  FMinimizedToTray:=False;

  if FMinimized then
  begin
    if Config.Values.MinimizeToTray then
    begin
      WindowState:=wsMinimized;

      FMinimizedToTray:=True;
      Visible:=False;
      tiSystray.Enabled:=True;
      Systray.Visible:=True;
      tiSystrayTimer(nil);
    end
    else
    begin
      //HACK: en utilisant WindowState, toutes les fenêtres de copies sont réduites
      //      j'utilise donc direct l'API
      SetForegroundWindow(Handle);
      ShowWindow(Handle,SW_SHOWMINIMIZED);

      if not Visible then Visible:=True;
    end;
  end
  else
  begin
    WindowState:=wsNormal;

    Visible:=True;
    Systray.Visible:=False;
    tiSystray.Enabled:=False;

    // si une form est en attente après une notification, l'afficher
    if Assigned(NotificationTargetForm) then NotificationTargetForm.Visible:=True;
    NotificationTargetForm:=nil;
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
    try
      // entete
      Log.Add(Format('*** %s: %s ***',[DateToStr(Date),TCopyThread(CopyThread).DisplayName]));

      // liste des erreurs
      for i:=0 to lvErrorList.Items.Count-1 do
        with lvErrorList.Items[i] do
        begin
          Log.Add(Format('%s %s %s : %s',[Caption,SubItems[0],SubItems[1],SubItems[2]]));
        end;

      // on s'assure que le rep du log existe
      WideForceDirectories(WideExtractFilePath(FileName));

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
  except
    on E:Exception do SCWin32.MessageBox(Handle,E.Message,Caption,MB_ICONERROR);
  end;
end;

//******************************************************************************
// SortFileList : tri de la liste de fichiers
//******************************************************************************
procedure TCopyForm.SortFileList(Mode: TFileListSortMode);
begin
  with TCopyThread(CopyThread).LockCopier do
    try
      if FileList.SortMode=Mode then
        FileList.SortReverse:=not FileList.SortReverse
      else
        FileList.SortReverse:=False;

      FileList.SortMode:=Mode;

      FileList.Sort;

      //maj listview
      lvFileList.Invalidate;
      lvFileList.Items.Count:=FileList.Count-1;

    finally
      TCopyThread(CopyThread).UnlockCopier
    end;
end;

procedure TCopyForm.FormCreate(Sender: TObject);
var ExStyle:Cardinal;
begin
  LocEngine.TranslateForm(Self);

  //HACK: correction d'un bug de taille de police sous NT4
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion=4) and (PixelsPerInch=96) then
    PixelsPerInch:=Round(PixelsPerInch*Width/(WIDTH_DPI_MULTIPLIER*96));

  //HACK: ne pas mettre directement la fenêtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeable;

  //HACK: fix temporaire pour les pb de scintillement des barres de progression
  //      avec les thèmes activés
  DoubleBuffered:=ThemeServices.ThemesEnabled;

  // init variables
  NonClientHeight:=Height-ClientHeight;
  UnfoldedHeight:=Round(UNFOLDED_HEIGHT_DPI_MULTIPLIER*PixelsPerInch);
  Constraints.MinWidth:=Round(WIDTH_DPI_MULTIPLIER*PixelsPerInch);

  CancelPending:=False;
  SkipPending:=False;
  Paused:=False;
  State:=cwsWaiting;
  NotificationTargetForm:=nil;

  NewBaseList:=nil;

  // charger la config par défaut
  ConfigData:=Config.Values.DefaultCopyWindowConfig;

  // chargement taille/position
  if Config.Values.CopyWindowSaveSize then
  begin
    Width:=Config.Values.CopyWindowWidth;
    UnfoldedHeight:=Config.Values.CopyWindowHeight;
    Unfolded:=Config.Values.CopyWindowUnfolded;
  end
  else
  begin
    Unfolded:=False;
  end;

  if Config.Values.CopyWindowSavePosition then
  begin
    Position:=poDesigned;
    Top:=Config.Values.CopyWindowTop;
    Left:=Config.Values.CopyWindowLeft;
  end;

  // chargement apparence des progress
  with Config.Values do
  begin
    ggFile.FontTxt.Color:=ProgressTextColor;
    ggFile.FontProgress.Color:=ProgressTextColor;
    ggFile.FontTxtColor:=ProgressOutlineColor;
    ggFile.FontProgressColor:=ProgressOutlineColor;
    ggFile.FrontColor1:=ProgressForegroundColor1;
    ggFile.FrontColor2:=ProgressForegroundColor2;
    ggFile.BackColor1:=ProgressBackgroundColor1;
    ggFile.BackColor2:=ProgressBackgroundColor2;
    ggFile.BorderColor:=ProgressBorderColor;
    ggAll.FontTxt.Color:=ProgressTextColor;
    ggAll.FontProgress.Color:=ProgressTextColor;
    ggAll.FontTxtColor:=ProgressOutlineColor;
    ggAll.FontProgressColor:=ProgressOutlineColor;
    ggAll.FrontColor1:=ProgressForegroundColor1;
    ggAll.FrontColor2:=ProgressForegroundColor2;
    ggAll.BackColor1:=ProgressBackgroundColor1;
    ggAll.BackColor2:=ProgressBackgroundColor2;
    ggAll.BorderColor:=ProgressBorderColor;
  end;

  // chargement des glyphs des boutons
  with MainForm.ilGlobal do
  begin
    GetBitmap(12,btFileTop.Glyph);
    GetBitmap(10,btFileUp.Glyph);
    GetBitmap(11,btFileDown.Glyph);
    GetBitmap(13,btFileBottom.Glyph);
    GetBitmap(14,btFileAdd.Glyph);
    GetBitmap(15,btFileRemove.Glyph);
    GetBitmap(17,btFileLoad.Glyph);
    GetBitmap(16,btFileSave.Glyph);
    GetBitmap(18,btErrorClear.Glyph);
    GetBitmap(16,btErrorSaveLog.Glyph);
  end;

  // si on ne minimise pas dans le systray, afficher un tab dans la
  // barre des tâches sinon passer la form en always on top
  if not Config.Values.MinimizeToTray then
  begin
    ExStyle:=GetWindowLong(Handle,GWL_EXSTYLE);
    SetWindowLong(Handle,GWL_EXSTYLE,ExStyle or WS_EX_APPWINDOW);
  end
  else
  begin
    FormStyle:=fsStayOnTop;
  end;

  // init du bitmap qui servira pour le systray
  SystrayBmp:=TBitmap.Create;
  with SystrayBmp do
  begin
    PixelFormat:=pf24bit;
    Width:=16;
    Height:=16;
    Canvas.Brush.Color:=clBlack;
    Canvas.FillRect(Canvas.ClipRect);
    Canvas.Font.Size:=9;
    Canvas.Font.Name:='Arial';
    Canvas.Font.Color:=clWhite;
  end;
  tiSystray.Enabled:=True;

  // accepter le drag & drop
  DragAcceptFiles(Handle,True);

  pcPages.ActivePage:=tsCopyList;

  if Config.Values.CopyWindowStartMinimized then Minimized:=True;
end;

procedure TCopyForm.btSaveDefaultCfgClick(Sender: TObject);
begin
  Config.Values.DefaultCopyWindowConfig:=ConfigData;
end;

procedure TCopyForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  btCancelClick(nil,0);

  CanClose:=False;
end;

procedure TCopyForm.FormDestroy(Sender: TObject);
begin
  // sauvegarde taille/position
  if Config.Values.CopyWindowSaveSize then
  begin
    Config.Values.CopyWindowWidth:=Width;
    if Unfolded then
      Config.Values.CopyWindowHeight:=Height
    else
      Config.Values.CopyWindowHeight:=UnfoldedHeight;
    Config.Values.CopyWindowUnfolded:=Unfolded;
  end;

  if Config.Values.CopyWindowSavePosition then
  begin
    Config.Values.CopyWindowTop:=Top;
    Config.Values.CopyWindowLeft:=Left;
  end;

  // libération
  SystrayBmp.Free;
end;

procedure TCopyForm.pcPagesChange(Sender: TObject);
begin
  if pcPages.ActivePage=tsErrors then tsErrors.Highlighted:=False;
end;

procedure TCopyForm.lvFileListData(Sender: TObject; Item: TListItem);
begin
  try
    with TCopyThread(CopyThread).LockCopier,TTntListItem(Item) do
    begin
      if Index<FileList.Count-1 then
        with FileList[Item.Index+1] do
        begin
          Caption:=SrcFullName;
          SubItems.Add(SizeToString(SrcSize,Config.Values.SizeUnit));
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
  FixParentBugs;

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
  DestIndex:=0;
  ProcessLvFileListAction(MoveTopAction,True,False);
end;

procedure TCopyForm.btFileBottomClick(Sender: TObject);
begin
  DestIndex:=lvFileList.Items.Count-1;
  ProcessLvFileListAction(MoveBottomAction,True);
end;

procedure TCopyForm.btFileAddClick(Sender: TObject);
begin
  pmFileAdd.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TCopyForm.btFileSaveClick(Sender: TObject);
var FS:TTntFileStream;
begin
  FixParentBugs;

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
  FixParentBugs;

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
        lvFileList.Invalidate;
        lvFileList.Items.Count:=FileList.Count-1;
      end;
    finally
      TCopyThread(CopyThread).UnlockCopier;
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure TCopyForm.miDefaultDestClick(Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(NewBaseList,amDefaultDir);
  NewBaseList:=nil;
end;

procedure TCopyForm.miChooseDestClick(Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(NewBaseList,amPromptForDest);
  NewBaseList:=nil;
end;

procedure TCopyForm.miChooseSetDefaultClick(
  Sender: TObject);
begin
  TCopyThread(CopyThread).AddBaseList(NewBaseList,amPromptForDestAndSetDefault);
  NewBaseList:=nil;
end;

procedure TCopyForm.miCancelClick(Sender: TObject);
begin
  // on libère la baselist vu qu'elle ne vas pas être traitée
  NewBaseList.Free;
  NewBaseList:=nil;
end;

procedure TCopyForm.cbCopyEndChange(Sender: TObject);
begin
  FConfigData.CopyEndAction:=TCopyWindowCopyEndAction(cbCopyEnd.ItemIndex);
end;

procedure TCopyForm.chSpeedLimitClick(Sender: TObject);
begin
  tbSpeedLimit.Enabled:=chSpeedLimit.Checked;
  edCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llSpeedLimit.Enabled:=chSpeedLimit.Checked;

  FConfigData.ThrottleEnabled:=chSpeedLimit.Checked;
end;

procedure TCopyForm.edCustomSpeedLimitChange(Sender: TObject);
begin
   FConfigData.ThrottleSpeedLimit:=StrToIntDef(edCustomSpeedLimit.Text,-1);
end;

procedure TCopyForm.edCustomSpeedLimitKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) and (Key>#31) then Key:=#0; // autoriser seulement les chiffres et les caractères de contrôle
end;

procedure TCopyForm.tbSpeedLimitChange(Sender: TObject);
var IsCustom:Boolean;
begin
  IsCustom:=tbSpeedLimit.Position=0;

  edCustomSpeedLimit.Visible:=IsCustom;
  llCustomSpeedLimit.Visible:=IsCustom;
  llSpeedLimit.Visible:=not IsCustom;

  if not IsCustom then
  begin
    FConfigData.ThrottleSpeedLimit:=IndexToSpeedLimit(tbSpeedLimit.Position);
    llSpeedLimit.Caption:=SizeToString(FConfigData.ThrottleSpeedLimit*1024);
  end
  else
    edCustomSpeedLimitChange(nil);
end;

procedure TCopyForm.cbCollisionsChange(Sender: TObject);
begin
  FConfigData.CollisionAction:=TCollisionAction(cbCollisions.ItemIndex);
end;

procedure TCopyForm.cbCopyErrorChange(Sender: TObject);
begin
  FConfigData.CopyErrorAction:=TCopyErrorAction(cbCopyError.ItemIndex);
end;

procedure TCopyForm.miAddFilesClick(Sender: TObject);
var i:integer;
		BaseItem:TBaseItem;
begin
  FixParentBugs;

  if odFileAdd.Execute then
  begin
    if Assigned(NewBaseList) then NewBaseList.Free;
    NewBaseList:=TBaseList.Create;

    for i:=0 to odFileAdd.Files.Count-1 do
    begin
      BaseItem:=TBaseItem.Create;
      BaseItem.SrcName:=odFileAdd.Files[i];
      BaseItem.IsDirectory:=WideDirectoryExists(BaseItem.SrcName);
      NewBaseList.Add(BaseItem);
    end;

    // HACK²: le hack précedent empèche le popupmenu de s'ouvrir, ceci corrige le problème
    Windows.SetParent(TntPopupList.Window,THandle(HWND_DESKTOP));

    OpenNewFilesMenu;
  end;
end;

procedure TCopyForm.miAddFolderClick(Sender: TObject);
var Folder:WideString;
		BaseItem:TBaseItem;
begin
  if BrowseForFolder(lsChooseFolderToAdd,Folder,Handle) then
  begin
    if Assigned(NewBaseList) then NewBaseList.Free;
    NewBaseList:=TBaseList.Create;

    BaseItem:=TBaseItem.Create;
    BaseItem.SrcName:=Folder;
    BaseItem.IsDirectory:=True;
    NewBaseList.Add(BaseItem);

    OpenNewFilesMenu;
  end;
end;


procedure TCopyForm.SystrayMouseDown(Sender: TObject);
begin
  Minimized:=False;
end;

procedure TCopyForm.tiSystrayTimer(Sender: TObject);
var PrgHeight,PrgPercent:integer;
begin
  if Systray.Visible then
  begin
    // dessin de la mini-progressbar
    PrgPercent:=Round( (ggAll.Position / ggAll.Max) * 100 );
    PrgHeight:=16 - Round( (ggAll.Position / ggAll.Max) * 16 );

    with SystrayBmp.Canvas do
    begin
      Brush.Color:=Config.Values.ProgressBackgroundColor1;
      Brush.Style:=bsSolid;
      FillRect(ClipRect);
      Brush.Color:=Config.Values.ProgressForegroundColor1;
      FillRect(Rect(0,PrgHeight,16,16));

      Brush.Style:=bsClear;
      if State<>cwsPaused then
      begin
        if PrgPercent<100 then
          TextOut(1,0,PaddedIntToStr(PrgPercent,2))
        else
          TextOut(3,0,':-)');
      end
      else
      begin
        MainForm.ilGlobal.GetBitmap(27,SystrayBmp);
      end;
    end;

    Systray.Bitmap:=SystrayBmp;

    //hint
    Systray.Hint:=Caption+#13+llSpeed.Caption;
  end;
end;

procedure TCopyForm.btCancelClick(Sender: TObject; ItemIndex: Integer);
begin
  Caption:=WideFormat(lsCopyWindowCancellingCaption,[TCopyThread(CopyThread).DisplayName]);
  
  CancelPending:=True;
  State:=cwsWaitingActionResult;
end;

procedure TCopyForm.btSkipClick(Sender: TObject;
  ItemIndex: Integer);
begin
  SkipPending:=True;
  if Paused then btPauseClick(nil,0); // appuyer sur 'passer' enlève la pause
  State:=cwsWaitingActionResult;
end;

procedure TCopyForm.btPauseClick(Sender: TObject; ItemIndex: Integer);
var PFoc,RFoc:Boolean;
begin
  PFoc:=btPause.Focused;
  RFoc:=btResume.Focused;

  Paused:=not Paused;

  btPause.Visible:=not Paused;
  btResume.Visible:=Paused;
  miStPause.Visible:=btPause.Visible;
  miStResume.Visible:=btResume.Visible;

  if PFoc then FocusControl(btResume);
  if RFoc then FocusControl(btPause);
end;

procedure TCopyForm.btUnfoldClick(Sender: TObject; ItemIndex: Integer);
var FFoc,UFFoc:Boolean;
begin
  FFoc:=btFold.Focused;
  UFFoc:=btUnfold.Focused;

  Unfolded:=not Unfolded;

  if FFoc then FocusControl(btUnfold);
  if UFFoc then FocusControl(btFold);
end;

procedure TCopyForm.miStPauseClick(Sender: TObject);
begin
  btPauseClick(nil,0);
end;

procedure TCopyForm.miStCancelClick(Sender: TObject);
begin
  btCancelClick(nil,0);
end;

procedure TCopyForm.lvFileListColumnClick(Sender: TObject;
  Column: TListColumn);
var NewMode:TFileListSortMode;
begin
  NewMode:=fsmNone;
  case Column.Index of
    0: NewMode:=fsmBySrcFullName;
    1: NewMode:=fsmBySrcSize;
    2: NewMode:=fsmByDestFullName;
  end;

  SortFileList(NewMode);
end;

procedure TCopyForm.miBySrcFullPathClick(Sender: TObject);
begin
  SortFileList(fsmBySrcFullName);
end;

procedure TCopyForm.miBySrcNameClick(Sender: TObject);
begin
  SortFileList(fsmBySrcName);
end;

procedure TCopyForm.miByDestFullPathClick(Sender: TObject);
begin
  SortFileList(fsmByDestFullName);
end;

procedure TCopyForm.miBySizeClick(Sender: TObject);
begin
  SortFileList(fsmBySrcSize);
end;

procedure TCopyForm.miBySrcExtClick(Sender: TObject);
begin
  SortFileList(fsmBySrcExt);
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

    if Assigned(NewBaseList) then NewBaseList.Free;

    // on construit la BaseList
		NumFiles:=SCWin32.DragQueryFile(Msg.WParam,$FFFFFFFF,nil,0);
		if NumFiles=0 then exit;

		NewBaseList:=TBaseList.Create;

		for i:=0 to NumFiles-1 do
		begin
			SCWin32.DragQueryFile(Msg.WParam,i,FN,MAX_PATH);
			BaseItem:=TBaseItem.Create;
      BaseItem.SrcName:=FN;
      BaseItem.IsDirectory:=WideDirectoryExists(FN);
      NewBaseList.Add(BaseItem);
    end;

    DragFinish(Msg.WParam);

    OpenNewFilesMenu;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TCopyForm.OnWindowPosChanged(var Msg:TMessage);
begin
  inherited;

  // gérer la propriété Minimized lorsque l'on réduit dans la taskbar
  if (Msg.WParamLo<>WA_INACTIVE) and (GetForegroundWindow=Handle) and IsIconic(Handle) then
  begin
    Minimized:=False;
  end;
end;

procedure TCopyForm.OnSysCommand(var Msg: TMessage);
begin
  if Msg.WParam=SC_MINIMIZE then
  begin
    Minimized:=True;
    Msg.Result:=0;
  end
  else
    inherited;
end;

end.
