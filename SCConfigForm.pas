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

unit SCConfigForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, ExtCtrls, TntExtCtrls, ComCtrls, TntComCtrls, StdCtrls,
  TntStdCtrls, TntDialogs, SCProgessBar,SCLocEngine, ScTrackBar;

type
  TConfigForm = class(TTntForm)
    lvSections: TTntListView;
    pcSections: TTntPageControl;
    tsStartup: TTntTabSheet;
    tsCWDefaults: TTntTabSheet;
    tsProcesses: TTntTabSheet;
    tsAdvanced: TTntTabSheet;
    btCancel: TTntButton;
    btOk: TTntButton;
    tsUI: TTntTabSheet;
    tsLog: TTntTabSheet;
    tsCopy: TTntTabSheet;
    gbCopyEnd: TTntGroupBox;
    llCopyEnd: TTntLabel;
    cbCopyEnd: TTntComboBox;
    gbSpeedLimit: TTntGroupBox;
    gbCollisions: TTntGroupBox;
    llCollisions: TTntLabel;
    cbCollisions: TTntComboBox;
    gbCopyErrors: TTntGroupBox;
    llCopyErrors: TTntLabel;
    cbCopyError: TTntComboBox;
    gbStartup: TTntGroupBox;
    chStartWithWindows: TTntCheckBox;
    chActivateOnStart: TTntCheckBox;
    gbTaskbar: TTntGroupBox;
    chTrayIcon: TTntCheckBox;
    gbCWAppearance: TTntGroupBox;
    chCWSavePosition: TTntCheckBox;
    chCWSaveSize: TTntCheckBox;
    chCWStartMinimized: TTntCheckBox;
    gbSizeUnit: TTntGroupBox;
    llSizeUnit: TTntLabel;
    cbSizeUnit: TTntComboBox;
    gbCLHandling: TTntGroupBox;
    llCLHandling: TTntLabel;
    cbCLHandling: TTntComboBox;
    chCLHandlingConfirm: TTntCheckBox;
    llCLHandlingInfo: TTntLabel;
    gbAttributes: TTntGroupBox;
    chSaveAttributesOnCopy: TTntCheckBox;
    chSaveAttributesOnMove: TTntCheckBox;
    gbDeleting: TTntGroupBox;
    chDeleteUnfinishedCopies: TTntCheckBox;
    chDontDeleteOnCopyError: TTntCheckBox;
    gbRenaming: TTntGroupBox;
    llRenameOld: TTntLabel;
    llRenameNew: TTntLabel;
    edRenameOldPattern: TTntEdit;
    edRenameNewPattern: TTntEdit;
    gbErrorLog: TTntGroupBox;
    llErrorLogAutoSaveMode: TTntLabel;
    cbErrorLogAutoSaveMode: TTntComboBox;
    chErrorLogAutoSave: TTntCheckBox;
    edErrorLogFileName: TTntEdit;
    btELFNBrowse: TTntButton;
    llErrorLogFileName: TTntLabel;
    gbHandledProcesses: TTntGroupBox;
    lvHandledProcesses: TTntListView;
    llHandledProcessses: TTntLabel;
    btAddProcess: TTntButton;
    btRemoveProcess: TTntButton;
    llRetryInterval: TTntLabel;
    edCopyErrorRetry: TTntEdit;
    llRetryIntervalUnit: TTntLabel;
    gbPriority: TTntGroupBox;
    llPriority: TTntLabel;
    cbPriority: TTntComboBox;
    gbAdvanced: TTntGroupBox;
    llCopyBufferSize: TTntLabel;
    edCopyBufferSize: TTntEdit;
    llCopyBufferSizeUnit: TTntLabel;
    llCopyWindowUpdateInterval: TTntLabel;
    edCopyWindowUpdateInterval: TTntEdit;
    llCopyWindowUpdateIntervalUnit: TTntLabel;
    llCopySpeedAveragingInterval: TTntLabel;
    edCopySpeedAveragingInterval: TTntEdit;
    llCopySpeedAveragingIntervalUnit: TTntLabel;
    llCopyThrottleInterval: TTntLabel;
    edCopyThrottleInterval: TTntEdit;
    llCopyThrottleIntervalUnit: TTntLabel;
    chFastFreeSpaceCheck: TTntCheckBox;
    gbProgressrar: TTntGroupBox;
    btProgressFG1: TTntButton;
    bgProgressFG2: TTntButton;
    btProgressBG1: TTntButton;
    btProgressBG2: TTntButton;
    llProgressFG: TTntLabel;
    llProgressBG: TTntLabel;
    cbMinimize: TTntComboBox;
    gbConfigLocation: TTntGroupBox;
    llConfigLocation: TTntLabel;
    cbConfigLocation: TTntComboBox;
    odLog: TTntOpenDialog;
    odProcesses: TTntOpenDialog;
    llProgressBorder: TTntLabel;
    ggProgress: TSCProgessBar;
    cdProgress: TColorDialog;
    btRenamingHelp: TTntButton;
    btAdvancedHelp: TTntButton;
    llMinimizedEventHandling: TTntLabel;
    cbMinimizedEventHandling: TTntComboBox;
    btApply: TTntButton;
    btProgressBorder: TTntButton;
    btProgressOutline: TTntButton;
    btProgressText: TTntButton;
    llProgressText: TTntLabel;
    tsLanguage: TTntTabSheet;
    gbLanguage: TTntGroupBox;
    llLanguage: TTntLabel;
    cbLanguage: TTntComboBox;
    llLanguageInfo: TTntLabel;
    chFailSafeCopier: TTntCheckBox;
    chCopyResumeNoAgeVerification: TTntCheckBox;
    llAttributesAndSecurityForCopies: TTntLabel;
    llAttributesAndSecurityForMoves: TTntLabel;
    chSaveSecurityOnCopy: TTntCheckBox;
    chSaveSecurityOnMove: TTntCheckBox;
    llCustomSpeedLimit: TTntLabel;
    chSpeedLimit: TTntCheckBox;
    tbSpeedLimit: TScTrackBar;
    edCustomSpeedLimit: TTntEdit;
    llSpeedLimit: TTntLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvSectionsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure chSpeedLimitClick(Sender: TObject);
    procedure chDeleteUnfinishedCopiesClick(Sender: TObject);
    procedure chErrorLogAutoSaveClick(Sender: TObject);
    procedure cbErrorLogAutoSaveModeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btRenamingHelpClick(Sender: TObject);
    procedure btAddProcessClick(Sender: TObject);
    procedure btRemoveProcessClick(Sender: TObject);
    procedure btELFNBrowseClick(Sender: TObject);
    procedure NumbersOnly(Sender: TObject; var Key: Char);
    procedure FileNameOnly(Sender: TObject; var Key: Char);
    procedure TntFormShow(Sender: TObject);
    procedure btProgressFG1Click(Sender: TObject);
    procedure bgProgressFG2Click(Sender: TObject);
    procedure btProgressBG1Click(Sender: TObject);
    procedure btProgressBG2Click(Sender: TObject);
    procedure btProgressBorderClick(Sender: TObject);
    procedure btAdvancedHelpClick(Sender: TObject);
    procedure cbMinimizeClick(Sender: TObject);
    procedure btApplyClick(Sender: TObject);
    procedure btProgressTextClick(Sender: TObject);
    procedure btProgressOutlineClick(Sender: TObject);
    procedure tbSpeedLimitChange(Sender: TObject);
  private
    { Private declarations }

    procedure UpdateControlsState;
    procedure GetConfig;
    procedure UpdateConfig;
  public
    { Public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.dfm}

uses SCConfig,SCWin32,SCLocStrings,TntSysutils, Math, SCCommon, SCMainForm,
  StrUtils;

//******************************************************************************
// UpdateControlsState : fixe l'état d'activation des controles
//******************************************************************************
procedure TConfigForm.UpdateControlsState;
var IsCustom:Boolean;
begin
  tbSpeedLimit.Enabled:=chSpeedLimit.Checked;
  edCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llSpeedLimit.Enabled:=chSpeedLimit.Checked;

  IsCustom:=tbSpeedLimit.Position=0;
  edCustomSpeedLimit.Visible:=IsCustom;
  llCustomSpeedLimit.Visible:=IsCustom;
  llSpeedLimit.Visible:=not IsCustom;
  if not IsCustom then llSpeedLimit.Caption:=SizeToString(IndexToSpeedLimit(tbSpeedLimit.Position)*1024);

  chDontDeleteOnCopyError.Enabled:=chDeleteUnfinishedCopies.Checked;
  cbErrorLogAutoSaveMode.Enabled:=chErrorLogAutoSave.Checked;
  edErrorLogFileName.Enabled:=chErrorLogAutoSave.Checked;
  btELFNBrowse.Enabled:=chErrorLogAutoSave.Checked and (cbErrorLogAutoSaveMode.ItemIndex=2);
  btRemoveProcess.Enabled:=lvHandledProcesses.Items.Count>0;
  chFailSafeCopier.Enabled:=Win32Platform=VER_PLATFORM_WIN32_NT;
end;

//******************************************************************************
// GetConfig : charge la configuration dans la fenêtre
//******************************************************************************
procedure TConfigForm.GetConfig;
var i:Integer;
    ProcList:TStringList;
    FindData:TWin32FindDataW;
    FindHandle:THandle;
    FileName:WideString;
begin
  with Config.Values do
  begin
    //tsLanguage
    cbLanguage.Items.Add(DEFAULT_LANGUAGE);
    FindHandle:=SCWin32.FindFirstFile(PWideChar(WideExtractFilePath(TntApplication.ExeName)+LANG_SUBDIR+'*.lng'),FindData);
    if FindHandle<>INVALID_HANDLE_VALUE then
    begin
      repeat
        if (WideString(FindData.cFileName)<>'.') and (WideString(FindData.cFileName)<>'..') then
        begin
          FileName:=FindData.cFileName;
          FileName:=LeftStr(FileName,Pos('.',FileName)-1);
          cbLanguage.Items.Add(FileName);
        end;
      until not SCWin32.FindNextFile(FindHandle,FindData);

      Windows.FindClose(FindHandle);
    end;
    cbLanguage.ItemIndex:=cbLanguage.Items.IndexOf(Language);
    if cbLanguage.ItemIndex=-1 then cbLanguage.ItemIndex:=0;
    //tsStartup
    chStartWithWindows.Checked:=StartWithWindows;
    chActivateOnStart.Checked:=ActivateOnStart;
    //tsUI
    chTrayIcon.Checked:=TrayIcon;
    cbMinimize.ItemIndex:=IfThen(MinimizeToTray,0,1);
    cbMinimizedEventHandling.ItemIndex:=Integer(MinimizedEventHandling);
    chCWStartMinimized.Checked:=CopyWindowStartMinimized;
    chCWSaveSize.Checked:=CopyWindowSaveSize;
    chCWSavePosition.Checked:=CopyWindowSavePosition;
    cbSizeUnit.ItemIndex:=Integer(SizeUnit);
    ggProgress.BackColor1:=ProgressBackgroundColor1;
    ggProgress.BackColor2:=ProgressBackgroundColor2;
    ggProgress.FrontColor1:=ProgressForegroundColor1;
    ggProgress.FrontColor2:=ProgressForegroundColor2;
    ggProgress.BorderColor:=ProgressBorderColor;
    ggProgress.FontTxt.Color:=ProgressTextColor;
    ggProgress.FontProgress.Color:=ProgressTextColor;
    ggProgress.FontProgressColor:=ProgressOutlineColor;
    ggProgress.FontTxtColor:=ProgressOutlineColor;
    //tsCWDefaults
    with DefaultCopyWindowConfig do
    begin
      cbCopyEnd.ItemIndex:=Integer(CopyEndAction);
      chSpeedLimit.Checked:=ThrottleEnabled;
      edCustomSpeedLimit.Text:=IntToStr(ThrottleSpeedLimit);
      tbSpeedLimit.Position:=SpeedLimitToIndex(ThrottleSpeedLimit);
      cbCollisions.ItemIndex:=Integer(CollisionAction);
      cbCopyError.ItemIndex:=Integer(CopyErrorAction);
    end;
    edCopyErrorRetry.Text:=IntToStr(CopyErrorRetryInterval);
    //tsCopy
    cbCLHandling.ItemIndex:=Integer(CopyListHandlingMode);
    chCLHandlingConfirm.Checked:=CopyListHandlingConfirm;
    chSaveAttributesOnCopy.Checked:=SaveAttributesOnCopy;
    chSaveSecurityOnCopy.Checked:=SaveSecurityOnCopy;
    chSaveAttributesOnMove.Checked:=SaveAttributesOnMove;
    chSaveSecurityOnMove.Checked:=SaveSecurityOnMove;
    chDeleteUnfinishedCopies.Checked:=DeleteUnfinishedCopies;
    chDontDeleteOnCopyError.Checked:=DontDeleteOnCopyError;
    edRenameOldPattern.Text:=RenameOldPattern;
    edRenameNewPattern.Text:=RenameNewPattern;
    //tsLog
    chErrorLogAutoSave.Checked:=ErrorLogAutoSave;
    cbErrorLogAutoSaveMode.ItemIndex:=Integer(ErrorLogAutoSaveMode);
    edErrorLogFileName.Text:=ErrorLogFileName;
    //tsProcesses
    ProcList:=TStringList.Create;
    try
      ExtractStrings(['|'],[' '],PChar(HandledProcesses),ProcList);
      for i:=0 to ProcList.Count-1 do
        lvHandledProcesses.AddItem(ProcList[i],nil);
    finally
      ProcList.Free;
    end;
    //tsAdvanced
    case Priority of
      IDLE_PRIORITY_CLASS: cbPriority.ItemIndex:=0;
      NORMAL_PRIORITY_CLASS: cbPriority.ItemIndex:=1;
      HIGH_PRIORITY_CLASS: cbPriority.ItemIndex:=2;
    end;
    cbConfigLocation.ItemIndex:=Integer(ConfigLocation);
    edCopyBufferSize.Text:=IntToStr(CopyBufferSize);
    edCopyWindowUpdateInterval.Text:=IntToStr(CopyWindowUpdateInterval);
    edCopySpeedAveragingInterval.Text:=IntToStr(CopySpeedAveragingInterval);
    edCopyThrottleInterval.Text:=IntToStr(CopyThrottleInterval);
    chFastFreeSpaceCheck.Checked:=FastFreeSpaceCheck;
    chFailSafeCopier.Checked:=FailSafeCopier;
    chCopyResumeNoAgeVerification.Checked:=CopyResumeNoAgeVerification;
  end;
end;

//******************************************************************************
// UpdateConfig : mets à jour la configuration
//******************************************************************************
procedure TConfigForm.UpdateConfig;
var i:Integer;
begin
  with Config.Values do
  begin
    //tsLanguage
    Language:=cbLanguage.Text;
    //tsStartup
    StartWithWindows:=chStartWithWindows.Checked;
    ActivateOnStart:=chActivateOnStart.Checked;
    //tsUI
    TrayIcon:=chTrayIcon.Checked;
    MinimizeToTray:=cbMinimize.ItemIndex=0;
    MinimizedEventHandling:=TMinimizedEventHandling(cbMinimizedEventHandling.ItemIndex);
    CopyWindowStartMinimized:=chCWStartMinimized.Checked;
    CopyWindowSaveSize:=chCWSaveSize.Checked;
    CopyWindowSavePosition:=chCWSavePosition.Checked;
    SizeUnit:=TSizeUnit(cbSizeUnit.ItemIndex);
    ProgressBackgroundColor1:=ggProgress.BackColor1;
    ProgressBackgroundColor2:=ggProgress.BackColor2;
    ProgressForegroundColor1:=ggProgress.FrontColor1;
    ProgressForegroundColor2:=ggProgress.FrontColor2;
    ProgressBorderColor:=ggProgress.BorderColor;
    ProgressTextColor:=ggProgress.FontTxt.Color;
    ProgressOutlineColor:=ggProgress.FontTxtColor;
    //tsCWDefaults
    with DefaultCopyWindowConfig do
    begin
      CopyEndAction:=TCopyWindowCopyEndAction(cbCopyEnd.ItemIndex);
      ThrottleEnabled:=chSpeedLimit.Checked;

      if tbSpeedLimit.Position=0 then
        ThrottleSpeedLimit:=StrToIntDef(edCustomSpeedLimit.Text,CONFIG_DEFAULT_VALUES.DefaultCopyWindowConfig.ThrottleSpeedLimit)
      else
        ThrottleSpeedLimit:=IndexToSpeedLimit(tbSpeedLimit.Position);

      CollisionAction:=TCollisionAction(cbCollisions.ItemIndex);
      CopyErrorAction:=TCopyErrorAction(cbCopyError.ItemIndex);
    end;
    CopyErrorRetryInterval:=StrToIntDef(edCopyErrorRetry.Text,CONFIG_DEFAULT_VALUES.CopyErrorRetryInterval);
    //tsCopy
    CopyListHandlingMode:=TCopyListHandlingMode(cbCLHandling.ItemIndex);
    CopyListHandlingConfirm:=chCLHandlingConfirm.Checked;
    SaveAttributesOnCopy:=chSaveAttributesOnCopy.Checked;
    SaveSecurityOnCopy:=chSaveSecurityOnCopy.Checked;
    SaveAttributesOnMove:=chSaveAttributesOnMove.Checked;
    SaveSecurityOnMove:=chSaveSecurityOnMove.Checked;
    DeleteUnfinishedCopies:=chDeleteUnfinishedCopies.Checked;
    DontDeleteOnCopyError:=chDontDeleteOnCopyError.Checked;
    RenameOldPattern:=edRenameOldPattern.Text;
    RenameNewPattern:=edRenameNewPattern.Text;
    //tsLog
    ErrorLogAutoSave:=chErrorLogAutoSave.Checked;
    ErrorLogAutoSaveMode:=TErrorLogAutoSaveMode(cbErrorLogAutoSaveMode.ItemIndex);
    ErrorLogFileName:=edErrorLogFileName.Text;
    //tsProcesses
    HandledProcesses:='';
    for i:=0 to lvHandledProcesses.Items.Count-1 do
      HandledProcesses:=HandledProcesses+lvHandledProcesses.Items[i].Caption+'|';
    //tsAdvanced
    case cbPriority.ItemIndex of
      0: Priority:=IDLE_PRIORITY_CLASS;
      1: Priority:=NORMAL_PRIORITY_CLASS;
      2: Priority:=HIGH_PRIORITY_CLASS;
    end;
    ConfigLocation:=TConfigLocation(cbConfigLocation.ItemIndex);
    CopyBufferSize:=StrToIntDef(edCopyBufferSize.Text,CONFIG_DEFAULT_VALUES.CopyBufferSize);
    CopyWindowUpdateInterval:=StrToIntDef(edCopyWindowUpdateInterval.Text,CONFIG_DEFAULT_VALUES.CopyWindowUpdateInterval);
    CopySpeedAveragingInterval:=StrToIntDef(edCopySpeedAveragingInterval.Text,CONFIG_DEFAULT_VALUES.CopySpeedAveragingInterval);
    CopyThrottleInterval:=StrToIntDef(edCopyThrottleInterval.Text,CONFIG_DEFAULT_VALUES.CopyThrottleInterval);
    FastFreeSpaceCheck:=chFastFreeSpaceCheck.Checked;
    FailSafeCopier:=chFailSafeCopier.Checked;
    CopyResumeNoAgeVerification:=chCopyResumeNoAgeVerification.Checked;
  end;
end;

procedure TConfigForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  lvSections.OnChange:=nil; //HACK: empèche l'erreur Win32 #87 de se déclencher sur Windows 7
  CanClose:=False;
  Hide;
  Release;
  ConfigForm:=nil;
end;

procedure TConfigForm.lvSectionsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  pcSections.ActivePageIndex:=Item.Index;
end;

procedure TConfigForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TConfigForm.btOkClick(Sender: TObject);
begin
  btApply.Click;
  Close;
end;

procedure TConfigForm.btApplyClick(Sender: TObject);
begin
  UpdateConfig;
  CloseConfig;
  OpenConfig;
  ApplyConfig;
  lvSectionsChange(nil,lvSections.ItemFocused,ctState); // la localisation change la page active
  ggProgress.TimeRemaining:=WideFormat(lsRemaining,['00:00:00']);
end;

procedure TConfigForm.chSpeedLimitClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.tbSpeedLimitChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.chDeleteUnfinishedCopiesClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.chErrorLogAutoSaveClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.cbErrorLogAutoSaveModeChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.cbMinimizeClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  GetConfig;
  UpdateControlsState;

  LocEngine.TranslateForm(Self);

  ggProgress.TimeRemaining:=WideFormat(lsRemaining,['00:00:00']);
end;

procedure TConfigForm.btRenamingHelpClick(Sender: TObject);
begin
  MessageBox(Handle,lsRenamingHelpText,lsRenamingHelpCaption,0);
end;

procedure TConfigForm.btELFNBrowseClick(Sender: TObject);
begin
  FixParentBugs;

  if odLog.Execute then
  begin
    edErrorLogFileName.Text:=odLog.FileName;
  end;
end;

procedure TConfigForm.btAddProcessClick(Sender: TObject);
begin
  FixParentBugs;

  if odProcesses.Execute then
  begin
    lvHandledProcesses.AddItem(WideExtractFileName(odProcesses.FileName),nil);
    UpdateControlsState;
  end;
end;

procedure TConfigForm.btRemoveProcessClick(Sender: TObject);
begin
  if lvHandledProcesses.ItemIndex>=0 then
  begin
    lvHandledProcesses.Items.Delete(lvHandledProcesses.ItemIndex);
    UpdateControlsState;
  end;
end;

procedure TConfigForm.NumbersOnly(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) and (Key>#31) then Key:=#0; // autoriser seulement les chiffres et les caractères de contrôle
end;

procedure TConfigForm.FileNameOnly(Sender: TObject; var Key: Char);
begin
  if Key in ['/','?','*','"','<','>','|'] then Key:=#0; //caractères interdits dans un nom de fichier
end;

procedure TConfigForm.TntFormShow(Sender: TObject);
begin
  lvSections.Items[0].Focused:=True;
  lvSections.Items[0].Selected:=True;
end;

procedure TConfigForm.btProgressFG1Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FrontColor1;
  if cdProgress.Execute then ggProgress.FrontColor1:=cdProgress.Color;
end;

procedure TConfigForm.bgProgressFG2Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FrontColor2;
  if cdProgress.Execute then ggProgress.FrontColor2:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBG1Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BackColor1;
  if cdProgress.Execute then ggProgress.BackColor1:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBG2Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BackColor2;
  if cdProgress.Execute then ggProgress.BackColor2:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBorderClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BorderColor;
  if cdProgress.Execute then ggProgress.BorderColor:=cdProgress.Color;
end;

procedure TConfigForm.btAdvancedHelpClick(Sender: TObject);
begin
  MessageBox(Handle,lsAdvancedHelpText,lsAdvancedHelpCaption,0);
end;

procedure TConfigForm.btProgressTextClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FontTxt.Color;
  if cdProgress.Execute then
  begin
    ggProgress.FontTxt.Color:=cdProgress.Color;
    ggProgress.FontProgress.Color:=cdProgress.Color;
    ggProgress.Refresh;
  end;
end;

procedure TConfigForm.btProgressOutlineClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FontTxtColor;
  if cdProgress.Execute then
  begin
    ggProgress.FontTxtColor:=cdProgress.Color;
    ggProgress.FontProgressColor:=cdProgress.Color;
    ggProgress.Refresh;
  end;
end;

end.
