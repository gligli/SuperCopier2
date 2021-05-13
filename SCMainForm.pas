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

unit SCMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,  TntForms,
  Dialogs, StdCtrls,filectrl,tntsysutils,TntStdCtrls,ShellApi, Controls,
  ComCtrls, TntComCtrls, XPMan, ScSystray, Menus, TntMenus, ImgList,
  Buttons, TntButtons,SCConfigShared,SCLocEngine;

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
    miCancelAll: TTntMenuItem;
    miCancelThread: TTntMenuItem;
    ilGlobal: TImageList;
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
    procedure SystrayBallonClick(Sender: TObject);
  private
    { D�clarations priv�es }
    procedure UpdateSystrayIcon;
    procedure OpenDialog(var AMsg:TMessage); message WM_OPENDIALOG;
  public
    { D�clarations publiques }
    NotificationSourceForm:TTntForm;
    NotificationSourceThread:TThread;
  end;

var
  MainForm: TMainForm;

implementation
uses SCConfig,SCCommon,SCWin32,SCCopyThread,SCBaseList,SCFileList,SCDirList,SCHookShared,SCWorkThreadList,madCodeHook,
  Forms,SCConfigForm,SCAboutForm,SCLocStrings,SCCopyForm,SCHookEngine, Math;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Windows.SetParent(Handle,THandle(HWND_MESSAGE)); // cacher la form
  Caption:=SC2_MAINFORM_CAPTION;

  WorkThreadList:=TWorkThreadList.Create;

  LocEngine:=TLocEngine.Create;

  OpenConfig;
  ApplyConfig;

  Systray.Hint:='SuperCopier 2';
  UpdateSystrayIcon;

  try
    HookEngine:=THookEngine.Create;
    HookEngine.InstallHook;
    HookEngine.CopyHandlingActive:=Config.Values.ActivateOnStart;
  except
    on E:EHookEngineInitFailed do
    begin
        SCWin32.MessageBox(Handle,lsHookErrorText+e.Message,lsHookErrorCaption,MB_OK or MB_ICONERROR);
        Application.Terminate;
    end;
    on E:EHookingFailed do
    begin
        SCWin32.MessageBox(Handle,lsHookErrorText+e.Message,lsHookErrorCaption,MB_OK or MB_ICONERROR);
        Application.Terminate;
    end;
  end;

  miActivate.Visible:=not HookEngine.CopyHandlingActive;
  miDeactivate.Visible:=HookEngine.CopyHandlingActive;

  UpdateSystrayIcon;

  NotificationSourceForm:=nil;

  LocEngine.TranslateForm(Self);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;

  HookEngine.UninstallHook;
  HookEngine.Free;

  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);
  WorkThreadList.Free;

  CloseConfig;

  LocEngine.Free;
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
    MenuItem,CancelSubItem:TTntMenuItem;
begin
  for i:=0 to WorkThreadList.Count-1 do
  begin
    MenuItem:=TTntMenuItem.Create(pmSystray);
    MenuItem.Caption:=WorkThreadList[i].DisplayName;
    MenuItem.ImageIndex:=miThreadList.ImageIndex;
    MenuItem.Tag:=i;
    miThreadList.Add(MenuItem);

    CancelSubItem:=TTntMenuItem.Create(pmSystray);
    CancelSubItem.Caption:=miCancelThread.Caption;
    CancelSubItem.OnClick:=miCancelThread.OnClick;
    CancelSubItem.ImageIndex:=miCancelThread.ImageIndex;
    CancelSubItem.Tag:=i;
    MenuItem.Add(CancelSubItem);
  end;

  // enlever les anciens items
  while miThreadList.Count>(WorkThreadList.Count+1) do miThreadList.Delete(1);
end;

procedure TMainForm.miActivateClick(Sender: TObject);
begin
  HookEngine.CopyHandlingActive:=not HookEngine.CopyHandlingActive;

  miActivate.Visible:=not HookEngine.CopyHandlingActive;
  miDeactivate.Visible:=HookEngine.CopyHandlingActive;

  UpdateSystrayIcon;
end;

procedure TMainForm.miCancelAllClick(Sender: TObject);
begin
  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);
end;

procedure TMainForm.miCancelThreadClick(Sender: TObject);
begin
  WorkThreadList[(Sender as TMenuItem).Tag].Cancel;
end;

procedure TMainForm.SystrayBallonClick(Sender: TObject);
begin
  if (WorkThreadList.IndexOf(NotificationSourceThread)<>-1) and (NotificationSourceForm is TCopyForm) then
  begin
    (NotificationSourceForm as TCopyForm).Minimized:=False;
  end;
end;

//******************************************************************************
// UpdateSystrayIcon: change l'ic�ne du systray en fonction de l'�tat d'activation
//******************************************************************************
procedure TMainForm.UpdateSystrayIcon;
var TmpIcon:TIcon;
    Idx:Integer;
begin
  TmpIcon:=TIcon.Create;
  try
    if Assigned(HookEngine) and HookEngine.CopyHandlingActive then Idx:=28 else Idx:=29;
    ilGlobal.GetIcon(Idx,TmpIcon);
    Systray.Icone:=TmpIcon;
  finally
    TmpIcon.Free;
  end;
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








































