
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntForms;

{$INCLUDE TntCompilers.inc}

interface

uses
  Classes, TntClasses, Windows, Messages, Controls, Forms, TntControls;

type
{TNT-WARN TScrollBox}
  TTntScrollBox = class(TScrollBox{TNT-ALLOW TScrollBox})
  private
    FWMSizeCallCount: Integer;
    function IsHintStored: Boolean;
    function GetHint: WideString;
    procedure SetHint(const Value: WideString);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DefineProperties(Filer: TFiler); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
  published
    property Hint: WideString read GetHint write SetHint stored IsHintStored;
  end;

{TNT-WARN TCustomFrame}
  TTntCustomFrame = class(TCustomFrame{TNT-ALLOW TCustomFrame})
  private
    function IsHintStored: Boolean;
    function GetHint: WideString;
    procedure SetHint(const Value: WideString);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DefineProperties(Filer: TFiler); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
  published
    property Hint: WideString read GetHint write SetHint stored IsHintStored;
  end;

{TNT-WARN TFrame}
  TTntFrame{TNT-ALLOW TTntFrame} = class(TTntCustomFrame)
  published
    property Align;
    property Anchors;
    property AutoScroll;
    property AutoSize;
    property BiDiMode;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Color nodefault;
    property Ctl3D;
    property Font;
{$IFDEF COMPILER_7_UP}
    property ParentBackground default True;
{$ENDIF}
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

{TNT-WARN TForm}
  TTntForm{TNT-ALLOW TTntForm} = class(TForm{TNT-ALLOW TForm})
  private
    function GetCaption: TWideCaption;
    procedure SetCaption(const Value: TWideCaption);
    function GetHint: WideString;
    procedure SetHint(const Value: WideString);
    function IsCaptionStored: Boolean;
    function IsHintStored: Boolean;
    procedure WMMenuSelect(var Message: TWMMenuSelect); message WM_MENUSELECT;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure WMWindowPosChanging(var Message: TMessage); message WM_WINDOWPOSCHANGING;
  protected
    procedure UpdateActions; override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure DefineProperties(Filer: TFiler); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DefaultHandler(var Message); override;
  published
    property Caption: TWideCaption read GetCaption write SetCaption stored IsCaptionStored;
    property Hint: WideString read GetHint write SetHint stored IsHintStored;
  end;

  TTntApplication = class(TComponent)
  private
    FMainFormChecked: Boolean;
    FHint: WideString;
    FTntAppIdleEventControl: TControl;
    FSettingChangeTime: Cardinal;
    FTitle: WideString;
    function GetHint: WideString;
    procedure SetAnsiAppHint(const Value: AnsiString);
    procedure SetHint(const Value: WideString);
    function GetExeName: WideString;
    function IsDlgMsg(var Msg: TMsg): Boolean;
    procedure DoIdle;
    function GetTitle: WideString;
    procedure SetTitle(const Value: WideString);
    procedure SetAnsiApplicationTitle(const Value: AnsiString);
  protected
    function WndProc(var Message: TMessage): Boolean;
    function ProcessMessage(var Msg: TMsg): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Hint: WideString read GetHint write SetHint;
    property ExeName: WideString read GetExeName;
    property SettingChangeTime: Cardinal read FSettingChangeTime;
    property Title: WideString read GetTitle write SetTitle;
  end;

{TNT-WARN IsAccel}
function IsWideCharAccel(CharCode: Word; const Caption: WideString): Boolean;

{TNT-WARN PeekMessage}
{TNT-WARN PeekMessageA}
{TNT-WARN PeekMessageW}
procedure EnableManualPeekMessageWithRemove;
procedure DisableManualPeekMessageWithRemove;

procedure ConstructBaseClassForm(Self: TTntForm{TNT-ALLOW TTntForm}; FormClass: TCustomFormClass; AOwner: TComponent);

var
  TntApplication: TTntApplication;

procedure InitTntEnvironment;
  
implementation

uses
  SysUtils, Consts, {$IFDEF COMPILER_6_UP} RTLConsts, {$ENDIF} Menus, FlatSB, StdActns,
  Graphics, TntSystem, TntSysUtils, TntWindows, TntMenus, TntActnList, TntStdActns;

function IsWideCharAccel(CharCode: Word; const Caption: WideString): Boolean;
var
  W: WideChar;
begin
  W := KeyUnicode(CharCode);
  Result := WideSameText(W, WideGetHotKey(Caption));
end;

procedure ConstructBaseClassForm(Self: TTntForm{TNT-ALLOW TTntForm}; FormClass: TCustomFormClass; AOwner: TComponent);
begin
  with Self do begin
    GlobalNameSpace.BeginWrite;
    try
      CreateNew(AOwner);
      if (ClassType <> FormClass) and not (csDesigning in ComponentState) then
      begin
        Include(FFormState, fsCreating);
        try
          if not InitInheritedComponent(Self, FormClass) then
            raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
        finally
          Exclude(FFormState, fsCreating);
        end;
        if OldCreateOrder then DoCreate;
      end;
    finally
      GlobalNameSpace.EndWrite;
    end;
  end;
end;

{ TTntScrollBox }

procedure TTntScrollBox.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle(Self, Params, '');
end;

procedure TTntScrollBox.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

function TTntScrollBox.IsHintStored: Boolean;
begin
  Result := TntControl_IsHintStored(Self);
end;

function TTntScrollBox.GetHint: WideString;
begin
  Result := TntControl_GetHint(Self);
end;

procedure TTntScrollBox.SetHint(const Value: WideString);
begin
  TntControl_SetHint(Self, Value);
end;

procedure TTntScrollBox.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  TntControl_BeforeInherited_ActionChange(Self, Sender, CheckDefaults);
  inherited;
end;

function TTntScrollBox.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TntControl_GetActionLinkClass(Self, inherited GetActionLinkClass);
end;

procedure TTntScrollBox.WMSize(var Message: TWMSize);
begin
  Inc(FWMSizeCallCount);
  try
    if FWMSizeCallCount < 32 then { Infinite recursion was encountered on Win 9x. }
      inherited;
  finally
    Dec(FWMSizeCallCount);
  end;
end;

{ TTntCustomFrame }

procedure TTntCustomFrame.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle(Self, Params, '');
end;

procedure TTntCustomFrame.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

function TTntCustomFrame.IsHintStored: Boolean;
begin
  Result := TntControl_IsHintStored(Self);
end;

function TTntCustomFrame.GetHint: WideString;
begin
  Result := TntControl_GetHint(Self);
end;

procedure TTntCustomFrame.SetHint(const Value: WideString);
begin
  TntControl_SetHint(Self, Value);
end;

procedure TTntCustomFrame.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  TntControl_BeforeInherited_ActionChange(Self, Sender, CheckDefaults);
  inherited;
end;

function TTntCustomFrame.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TntControl_GetActionLinkClass(Self, inherited GetActionLinkClass);
end;

{ TTntForm }

constructor TTntForm{TNT-ALLOW TTntForm}.Create(AOwner: TComponent);
begin
  ConstructBaseClassForm(Self, TTntForm{TNT-ALLOW TTntForm}, AOwner);
end;

procedure TTntForm{TNT-ALLOW TTntForm}.CreateWindowHandle(const Params: TCreateParams);
var
  NewParams: TCreateParams;
  WideWinClassName: WideString;
begin
  if (not Win32PlatformIsUnicode) then
    inherited
  else if (FormStyle = fsMDIChild) and not (csDesigning in ComponentState) then
  begin
    if (Application.MainForm = nil) or
      (Application.MainForm.ClientHandle = 0) then
        raise EInvalidOperation.Create(SNoMDIForm);
    RegisterUnicodeClass(Params, WideWinClassName);
    DefWndProc := @DefMDIChildProcW;
    WindowHandle := CreateMDIWindowW(PWideChar(WideWinClassName),
      nil, Params.style, Params.X, Params.Y, Params.Width, Params.Height,
        Application.MainForm.ClientHandle, hInstance, Longint(Params.Param));
    if WindowHandle = 0 then
      RaiseLastOSError;
    SubClassUnicodeControl(Self, Params.Caption);
    Include(FFormState, fsCreatedMDIChild);
  end else
  begin
    NewParams := Params;
    NewParams.ExStyle := NewParams.ExStyle and not WS_EX_LAYERED;
    CreateUnicodeHandle(Self, NewParams, '');
    Exclude(FFormState, fsCreatedMDIChild);
  end;
  {$IFDEF COMPILER_6_UP}
  if AlphaBlend then begin
    // toggle AlphaBlend to force update
    AlphaBlend := False;
    AlphaBlend := True;
  end else if TransparentColor then begin
    // toggle TransparentColor to force update
    TransparentColor := False;
    TransparentColor := True;
  end;
  {$ENDIF}
end;

procedure TTntForm{TNT-ALLOW TTntForm}.DestroyWindowHandle;
begin
  if Win32PlatformIsUnicode then
    UninitializeFlatSB(Handle); { Bug in VCL: Without this there might be a resource leak. }
  inherited;
end;

procedure TTntForm{TNT-ALLOW TTntForm}.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

procedure TTntForm{TNT-ALLOW TTntForm}.DefaultHandler(var Message);
begin
  if (ClientHandle <> 0)
  and (Win32PlatformIsUnicode) then
    with TMessage(Message) do
      if Msg = WM_SIZE then
        Result := DefWindowProcW(Handle, Msg, wParam, lParam)
      else
        Result := DefFrameProcW(Handle, ClientHandle, Msg, wParam, lParam)
  else
    inherited DefaultHandler(Message)
end;

function TTntForm{TNT-ALLOW TTntForm}.IsCaptionStored: Boolean;
begin
  Result := TntControl_IsCaptionStored(Self);
end;

function TTntForm{TNT-ALLOW TTntForm}.GetCaption: TWideCaption;
begin
  Result := TntControl_GetText(Self)
end;

procedure TTntForm{TNT-ALLOW TTntForm}.SetCaption(const Value: TWideCaption);
begin
  TntControl_SetText(Self, Value)
end;

function TTntForm{TNT-ALLOW TTntForm}.IsHintStored: Boolean;
begin
  Result := TntControl_IsHintStored(Self);
end;

function TTntForm{TNT-ALLOW TTntForm}.GetHint: WideString;
begin
  Result := TntControl_GetHint(Self)
end;

procedure TTntForm{TNT-ALLOW TTntForm}.SetHint(const Value: WideString);
begin
  TntControl_SetHint(Self, Value);
end;

procedure TTntForm{TNT-ALLOW TTntForm}.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  TntControl_BeforeInherited_ActionChange(Self, Sender, CheckDefaults);
  inherited;
end;

function TTntForm{TNT-ALLOW TTntForm}.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TntControl_GetActionLinkClass(Self, inherited GetActionLinkClass);
end;

procedure TTntForm{TNT-ALLOW TTntForm}.WMMenuSelect(var Message: TWMMenuSelect);
var
  MenuItem: TMenuItem{TNT-ALLOW TMenuItem};
  ID: Integer;
  FindKind: TFindItemKind;
begin
  if Menu <> nil then
    with Message do
    begin
      MenuItem := nil;
      if (MenuFlag <> $FFFF) or (IDItem <> 0) then
      begin
        FindKind := fkCommand;
        ID := IDItem;
        if MenuFlag and MF_POPUP <> 0 then
        begin
          FindKind := fkHandle;
          ID := Integer(GetSubMenu(Menu, ID));
        end;
        MenuItem := Self.Menu.FindItem(ID, FindKind);
      end;
      if MenuItem <> nil then
        TntApplication.Hint := WideGetLongHint(WideGetMenuItemHint(MenuItem))
      else
        TntApplication.Hint := '';
    end;
end;

procedure TTntForm{TNT-ALLOW TTntForm}.UpdateActions;
begin
  inherited;
  TntApplication.DoIdle;
end;

procedure TTntForm{TNT-ALLOW TTntForm}.CMBiDiModeChanged(var Message: TMessage);
var
  Loop: Integer;
begin
  inherited;
  for Loop := 0 to ComponentCount - 1 do
    if Components[Loop] is TMenu then
      FixMenuBiDiProblem(TMenu(Components[Loop]));
end;

procedure TTntForm{TNT-ALLOW TTntForm}.WMWindowPosChanging(var Message: TMessage);
begin
  inherited;
  // This message *sometimes* means that the Menu.BiDiMode changed.
  FixMenuBiDiProblem(Menu);
end;

{ TTntApplication }

constructor TTntApplication.Create(AOwner: TComponent);
begin
  inherited;
  Application.HookMainWindow(WndProc);
  FSettingChangeTime := GetTickCount;
  TntSysUtils._SettingChangeTime := GetTickCount;
end;

destructor TTntApplication.Destroy;
begin
  FreeAndNil(FTntAppIdleEventControl);
  Application.UnhookMainWindow(WndProc);
  inherited;
end;

function TTntApplication.GetHint: WideString;
begin
  Result := GetSyncedWideString(FHint, Application.Hint)
end;

procedure TTntApplication.SetAnsiAppHint(const Value: AnsiString);
begin
  Application.Hint := Value;
end;

procedure TTntApplication.SetHint(const Value: WideString);
begin
  SetSyncedWideString(Value, FHint, Application.Hint, SetAnsiAppHint);
end;

function TTntApplication.GetExeName: WideString;
begin
  Result := WideParamStr(0);
end;

function TTntApplication.GetTitle: WideString;
begin
  if (Application.Handle <> 0) and Win32PlatformIsUnicode then begin
    SetLength(Result, DefWindowProcW(Application.Handle, WM_GETTEXTLENGTH, 0, 0) + 1);
    DefWindowProcW(Application.Handle, WM_GETTEXT, Length(Result), Integer(PWideChar(Result)));
    SetLength(Result, Length(Result) - 1);
  end else
    Result := GetSyncedWideString(FTitle, Application.Title);
end;

procedure TTntApplication.SetAnsiApplicationTitle(const Value: AnsiString);
begin
  Application.Title := Value;
end;

procedure TTntApplication.SetTitle(const Value: WideString);
begin
  if (Application.Handle <> 0) and Win32PlatformIsUnicode then begin
    if (GetTitle <> Value) or (FTitle <> '') then begin
      DefWindowProcW(Application.Handle, WM_SETTEXT, 0, lParam(PWideChar(WideString(Value))));
      FTitle := '';
    end
  end else
    SetSyncedWideString(Value, FTitle, Application.Title, SetAnsiApplicationTitle);
end;

{$IFDEF COMPILER_5} // verified against VCL source in Delphi 5 and BCB 5
type
  THackApplication = class(TComponent)
  protected
    FxxxxxxxxxHandle: HWnd;
    FxxxxxxxxxBiDiMode: TBiDiMode;
    FxxxxxxxxxBiDiKeyboard: AnsiString;
    FxxxxxxxxxNonBiDiKeyboard: AnsiString;
    FxxxxxxxxxObjectInstance: Pointer;
    FxxxxxxxxxMainForm: TForm{TNT-ALLOW TForm};
    FMouseControl: TControl;
  end;
{$ENDIF}
{$IFDEF COMPILER_6} // verified against VCL source in Delphi 6 and BCB 6
type
  THackApplication = class(TComponent)
  protected
    FxxxxxxxxxHandle: HWnd;
    FxxxxxxxxxBiDiMode: TBiDiMode;
    FxxxxxxxxxBiDiKeyboard: AnsiString;
    FxxxxxxxxxNonBiDiKeyboard: AnsiString;
    FxxxxxxxxxObjectInstance: Pointer;
    FxxxxxxxxxMainForm: TForm{TNT-ALLOW TForm};
    FMouseControl: TControl;
  end;
{$ENDIF}
{$IFDEF DELPHI_7}
type
  THackApplication = class(TComponent)
  protected
    FxxxxxxxxxHandle: HWnd;
    FxxxxxxxxxBiDiMode: TBiDiMode;
    FxxxxxxxxxBiDiKeyboard: AnsiString;
    FxxxxxxxxxNonBiDiKeyboard: AnsiString;
    FxxxxxxxxxObjectInstance: Pointer;
    FxxxxxxxxxMainForm: TForm{TNT-ALLOW TForm};
    FMouseControl: TControl;
  end;
{$ENDIF}
{$IFDEF DELPHI_9}
type
  THackApplication = class(TComponent)
  protected
    FxxxxxxxxxHandle: HWnd;
    FxxxxxxxxxBiDiMode: TBiDiMode;
    FxxxxxxxxxBiDiKeyboard: AnsiString;
    FxxxxxxxxxNonBiDiKeyboard: AnsiString;
    FxxxxxxxxxObjectInstance: Pointer;
    FxxxxxxxxxMainForm: TForm{TNT-ALLOW TForm};
    FMouseControl: TControl;
  end;
{$ENDIF}

procedure TTntApplication.DoIdle;
var
  MouseControl: TControl;
begin
  MouseControl := THackApplication(Application).FMouseControl;
  Hint := WideGetLongHint(WideGetHint(MouseControl));
end;

function TTntApplication.IsDlgMsg(var Msg: TMsg): Boolean;
begin
  Result := (Application.DialogHandle <> 0)
        and (IsDialogMessage(Application.DialogHandle, Msg))
end;

type
  TTntAppIdleEventControl = class(TControl)
  protected
    procedure OnIdle(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

constructor TTntAppIdleEventControl.Create(AOwner: TComponent);
begin
  inherited;
  ParentFont := False; { This allows Parent (Application) to be in another module. }
  Parent := Application.MainForm;
  Visible := True;
  Action := TTntAction.Create(Self);
  Action.OnExecute := OnIdle;
  Action.OnUpdate := OnIdle;
  TntApplication.FTntAppIdleEventControl := Self;
end;

destructor TTntAppIdleEventControl.Destroy;
begin
  if TntApplication <> nil then
    TntApplication.FTntAppIdleEventControl := nil;
  inherited;
end;

procedure TTntAppIdleEventControl.OnIdle(Sender: TObject);
begin
  TntApplication.DoIdle;
end;

function TTntApplication.ProcessMessage(var Msg: TMsg): Boolean;
var
  Handled: Boolean;
begin
  Result := False;
  // Check Main Form
  if (not FMainFormChecked) and (Application.MainForm <> nil) then begin
    if not (Application.MainForm is TTntForm{TNT-ALLOW TTntForm}) then begin
      // This control will help ensure that DoIdle is called
      TTntAppIdleEventControl.Create(Application.MainForm);
    end;
    FMainFormChecked := True;
  end;
  // Check for Unicode char messages
  if (Msg.message = WM_CHAR)
  and (Msg.wParam > Integer(High(AnsiChar)))
  and IsWindowUnicode(Msg.hwnd)
  and ((not IsDlgMsg(Msg)) or IsWindowUnicode(Application.DialogHandle))
  then begin
    Result := True;
    // more than 8-bit WM_CHAR destined for Unicode window
    Handled := False;
    if Assigned(Application.OnMessage) then
      Application.OnMessage(Msg, Handled);
    Application.CancelHint;
    // dispatch msg if not a dialog message
    if (not Handled) and (not IsDlgMsg(Msg)) then
      DispatchMessageW(Msg);
  end;
end;

function TTntApplication.WndProc(var Message: TMessage): Boolean;
var
  BasicAction: TBasicAction;
begin
  Result := False; { not handled }
  if (Message.Msg = WM_SETTINGCHANGE) then begin
    FSettingChangeTime := GetTickCount;
    TntSysUtils._SettingChangeTime := FSettingChangeTime;
  end;
  if (Message.Msg = WM_CREATE)
  and (FTitle <> '') then begin
    SetTitle(FTitle);
    FTitle := '';
  end;
  if (Message.Msg = CM_ACTIONEXECUTE) then begin
    BasicAction := TBasicAction(Message.LParam);
    if (BasicAction.ClassType = THintAction{TNT-ALLOW THintAction})
    and (THintAction{TNT-ALLOW THintAction}(BasicAction).Hint = AnsiString(Hint))
    then begin
      Result := True;
      Message.Result := 1;
      with TTntHintAction.Create(Self) do
      begin
        Hint := Self.Hint;
        try
          Execute;
        finally
          Free;
        end;
      end;
    end;
  end;
end;

//===========================================================================
//   The NT GetMessage Hook is needed to support entering Unicode
//     characters directly from the keyboard (bypassing the IME).
//   Special thanks go to Francisco Leong for developing this solution.
//
//  Example:
//    1. Install "Turkic" language support.
//    2. Add "Azeri (Latin)" as an input locale.
//    3. In an EDIT, enter Shift+I.  (You should see a capital "I" with dot.)
//    4. In an EDIT, enter single quote (US Keyboard).  (You should see an upturned "e".)
//
var
  ManualPeekMessageWithRemove: Integer = 0;

procedure EnableManualPeekMessageWithRemove;
begin
  Inc(ManualPeekMessageWithRemove);
end;

procedure DisableManualPeekMessageWithRemove;
begin
  if (ManualPeekMessageWithRemove > 0) then
    Dec(ManualPeekMessageWithRemove);
end;

var
  NTGetMessageHook: HHOOK;

function GetMessageForNT(Code: Integer; wParam: Integer; lParam: Integer): LRESULT; stdcall;
var
  ThisMsg: PMSG;
begin
  if (Code >= 0)
  and (wParam = PM_REMOVE)
  and (ManualPeekMessageWithRemove = 0) then
  begin
    ThisMsg := PMSG(lParam);
    if (TntApplication <> nil)
    and TntApplication.ProcessMessage(ThisMsg^) then
      ThisMsg.message := WM_NULL; { clear for further processing }
  end;
  Result := CallNextHookEx(NTGetMessageHook, Code, wParam, lParam);
end;

procedure CreateGetMessageHookForNT;
begin
  Assert(Win32Platform = VER_PLATFORM_WIN32_NT);
  NTGetMessageHook := SetWindowsHookExW(WH_GETMESSAGE, GetMessageForNT, 0, GetCurrentThreadID);
  if NTGetMessageHook = 0 then
    RaiseLastOSError;
end;

function UnhookIsKnownToFail: Boolean;
begin
  Result := (Pos('W3WP.',    Tnt_WideUpperCase(WideExtractFileName(WideParamStr(0)))) = 1) // for IIS 6.0
         or (Pos('DLLHOST.', Tnt_WideUpperCase(WideExtractFileName(WideParamStr(0)))) = 1) // for IIS 5.0
end;

//---------------------------------------------------------------------------------------------
//                                 Tnt Environment Setup
//---------------------------------------------------------------------------------------------

procedure InitTntEnvironment;

    function GetDefaultFont: WideString;

        function RunningUnderIDE: Boolean;
        begin
          Result := ModuleIsPackage and
            (    WideSameText(WideExtractFileName(WideGetModuleFileName(0)), 'delphi32.exe')
              or WideSameText(WideExtractFileName(WideGetModuleFileName(0)), 'bcb.exe'));
        end;

        function GetProfileStr(const Section, Key, Default: AnsiString; MaxLen: Integer): AnsiString;
        var
          Len: Integer;
        begin
          SetLength(Result, MaxLen + 1);
          Len := GetProfileString(PAnsiChar(Section), PAnsiChar(Key), PAnsiChar(Default),
            PAnsiChar(Result), Length(Result));
          SetLength(Result, Len);
        end;

        procedure SetProfileStr(const Section, Key, Value: AnsiString);
        var
          DummyResult: Cardinal;
        begin
          try
            Win32Check(WriteProfileString(PAnsiChar(Section), PAnsiChar(Key), PAnsiChar(Value)));
            if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
              WriteProfileString(nil, nil, nil); {this flushes the WIN.INI cache}
            SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, Integer(PAnsiChar(Section)),
              SMTO_NORMAL, 250, DummyResult);
          except
            on E: Exception do begin
              E.Message := 'Couldn''t create font substitutes.' + CRLF + E.Message;
              Application.ShowException(E);
            end;
          end;
        end;

    var
      ShellDlgFontName_1: WideString;
      ShellDlgFontName_2: WideString;
    begin
      ShellDlgFontName_1 := GetProfileStr('FontSubstitutes', 'MS Shell Dlg', '', LF_FACESIZE);
      if ShellDlgFontName_1 = '' then begin
        ShellDlgFontName_1 := 'MS Sans Serif';
        SetProfileStr('FontSubstitutes', 'MS Shell Dlg', ShellDlgFontName_1);
      end;
      ShellDlgFontName_2 := GetProfileStr('FontSubstitutes', 'MS Shell Dlg 2', '', LF_FACESIZE);
      if ShellDlgFontName_2 = '' then begin
        if Screen.Fonts.IndexOf('Tahoma') <> -1 then
          ShellDlgFontName_2 := 'Tahoma'
        else
          ShellDlgFontName_2 := ShellDlgFontName_1;
        SetProfileStr('FontSubstitutes', 'MS Shell Dlg 2', ShellDlgFontName_2);
      end;
      if RunningUnderIDE then begin
        Result := 'MS Shell Dlg 2' {Delphi is running}
      end else
        Result := ShellDlgFontName_2;
    end;

begin
  // Tnt Environment Setup
  InstallTntSystemUpdates;
  DefFontData.Name := GetDefaultFont;
  Forms.HintWindowClass := TntControls.TTntHintWindow;
end;

initialization
  TntApplication := TTntApplication.Create(nil);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    CreateGetMessageHookForNT;

finalization
  if NTGetMessageHook <> 0 then begin
    if UnhookIsKnownToFail then
      UnhookWindowsHookEx(NTGetMessageHook) // no Win32Check!
    else
      Win32Check(UnhookWindowsHookEx(NTGetMessageHook));
  end;
  FreeAndNil(TntApplication);

end.
