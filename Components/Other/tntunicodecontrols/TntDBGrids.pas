
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntDBGrids;

{$INCLUDE TntCompilers.inc}

interface

uses
  Classes, TntClasses, Controls, Windows, Grids, DBGrids, Messages, DBCtrls, DB, TntStdCtrls;

type
{TNT-WARN TColumnTitle}
  TTntColumnTitle = class(TColumnTitle{TNT-ALLOW TColumnTitle})
  private
    FCaption: WideString;
    procedure SetInheritedCaption(const Value: AnsiString);
    function GetCaption: WideString;
    procedure SetCaption(const Value: WideString);
    function IsCaptionStored: Boolean;
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; override;
  published
    property Caption: WideString read GetCaption write SetCaption stored IsCaptionStored;
  end;

{TNT-WARN TColumn}
type
  TTntColumn = class(TColumn{TNT-ALLOW TColumn})
  private
    FWidePickList: TTntStrings;
    function GetWidePickList: TTntStrings;
    procedure SetWidePickList(const Value: TTntStrings);
    procedure HandlePickListChange(Sender: TObject);
    function GetTitle: TTntColumnTitle;
    procedure SetTitle(const Value: TTntColumnTitle);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function  CreateTitle: TColumnTitle{TNT-ALLOW TColumnTitle}; override;
  public
    destructor Destroy; override;
    property WidePickList: TTntStrings read GetWidePickList write SetWidePickList;
  published
{TNT-WARN PickList}
    property PickList{TNT-ALLOW PickList}: TTntStrings read GetWidePickList write SetWidePickList;
    property Title: TTntColumnTitle read GetTitle write SetTitle;
  end;

  { TDBGridInplaceEdit adds support for a button on the in-place editor,
    which can be used to drop down a table-based lookup list, a stringlist-based
    pick list, or (if button style is esEllipsis) fire the grid event
    OnEditButtonClick.  }

{$IFDEF COMPILER_6_UP}
type
  TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit} = class(TInplaceEditList)
  private
    {$IFDEF COMPILER_6} // verified against VCL source in Delphi 6 and BCB 6
    FDataList: TDBLookupListBox; // 1st field - Delphi/BCB 6 TCustomDBGrid assumes this
    FUseDataList: Boolean;       // 2nd field - Delphi/BCB 6 TCustomDBGrid assumes this
    {$ENDIF}
    {$IFDEF DELPHI_7}
    FDataList: TDBLookupListBox; // 1st field - Delphi 7 TCustomDBGrid assumes this
    FUseDataList: Boolean;       // 2nd field - Delphi 7 TCustomDBGrid assumes this
    {$ENDIF}
    {$IFDEF DELPHI_9}
    FDataList: TDBLookupListBox; // 1st field - Delphi 9 TCustomDBGrid assumes this
    FUseDataList: Boolean;       // 2nd field - Delphi 9 TCustomDBGrid assumes this
    {$ENDIF}
    FLookupSource: TDatasource;
    FWidePickListBox: TTntCustomListbox;
    function GetWidePickListBox: TTntCustomListbox;
  protected
    procedure CloseUp(Accept: Boolean); override;
    procedure DoEditButtonClick; override;
    procedure DropDown; override;
    procedure UpdateContents; override;
    property UseDataList: Boolean read FUseDataList;
  public
    constructor Create(Owner: TComponent); override;
    property DataList: TDBLookupListBox read FDataList;
    property WidePickListBox: TTntCustomListbox read GetWidePickListBox;
  end;
{$ELSE} // Delphi 5 and lower
type
  TEditStyle = (esSimple, esEllipsis, esPickList, esDataList);
  TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit} = class(TInplaceEdit{TNT-ALLOW TInplaceEdit})
  private
    FButtonWidth: Integer;
    FDataList: TDBLookupListBox;
    FWidePickListBox: TTntCustomListbox;
    FActiveList: TWinControl;
    FLookupSource: TDatasource;
    FEditStyle: TEditStyle;
    FListVisible: Boolean;
    FTracking: Boolean;
    FPressed: Boolean;
    function GetWidePickListBox: TTntCustomListbox;
    procedure ListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetEditStyle(Value: TEditStyle);
    procedure StopTracking;
    procedure TrackButton(X,Y: Integer);
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;
    procedure WMCancelMode(var Message: TMessage); message WM_CancelMode;
    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message wm_LButtonDblClk;
    procedure WMPaint(var Message: TWMPaint); message wm_Paint;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SetCursor;
    function OverButton(const P: TPoint): Boolean;
    function ButtonRect: TRect;
  protected
    procedure BoundsChanged; override;
    procedure CloseUp(Accept: Boolean);
    procedure DoDropDownKeys(var Key: Word; Shift: TShiftState);
    procedure DropDown;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure PaintWindow(DC: HDC); override;
    procedure UpdateContents; override;
    procedure WndProc(var Message: TMessage); override;
    property  EditStyle: TEditStyle read FEditStyle write SetEditStyle;
    property  ActiveList: TWinControl read FActiveList write FActiveList;
    property  DataList: TDBLookupListBox read FDataList;
    property WidePickListBox: TTntCustomListbox read GetWidePickListBox;
  public
    constructor Create(Owner: TComponent); override;
  end;
{$ENDIF}

type
{TNT-WARN TDBGridInplaceEdit}
  TTntDBGridInplaceEdit = class(TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit})
  private
    FInDblClick: Boolean;
    FBlockSetText: Boolean;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;
  protected
    function GetText: WideString; virtual;
    procedure SetText(const Value: WideString); virtual;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure UpdateContents; override;
    procedure DblClick; override;
  public
    property Text: WideString read GetText write SetText;
  end;

{TNT-WARN TDBGridColumns}
  TTntDBGridColumns = class(TDBGridColumns{TNT-ALLOW TDBGridColumns})
  private
    function GetColumn(Index: Integer): TTntColumn;
    procedure SetColumn(Index: Integer; const Value: TTntColumn);
  public
    function Add: TTntColumn;
    property Items[Index: Integer]: TTntColumn read GetColumn write SetColumn; default;
  end;

{TNT-WARN TCustomDBGrid}
  TTntCustomDBGrid = class(TCustomDBGrid{TNT-ALLOW TCustomDBGrid})
  private
    FEditText: WideString;
    function GetHint: WideString;
    procedure SetHint(const Value: WideString);
    function IsHintStored: Boolean;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    function GetColumns: TTntDBGridColumns;
    procedure SetColumns(const Value: TTntDBGridColumns);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure ShowEditorChar(Ch: WideChar); dynamic;
    procedure DefineProperties(Filer: TFiler); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function CreateColumns: TDBGridColumns{TNT-ALLOW TDBGridColumns}; override;
    property Columns: TTntDBGridColumns read GetColumns write SetColumns;
    function CreateEditor: TInplaceEdit{TNT-ALLOW TInplaceEdit}; override;
    {$IFDEF COMPILER_6_UP}
    function CreateDataLink: TGridDataLink; override;
    {$ENDIF}
    function GetEditText(ACol, ARow: Longint): WideString; reintroduce;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
    procedure SetEditText(ACol, ARow: Longint; const Value: AnsiString); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DefaultDrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TTntColumn; State: TGridDrawState); dynamic;
    procedure DefaultDrawDataCell(const Rect: TRect; Field: TField;
      State: TGridDrawState);
  published
    property Hint: WideString read GetHint write SetHint stored IsHintStored;
  end;

{TNT-WARN TDBGrid}
  TTntDBGrid = class(TTntCustomDBGrid)
  public
    property Canvas;
    property SelectedRows;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

implementation

uses
  SysUtils, TntControls, Math, {$IFDEF COMPILER_6_UP} Variants, {$ENDIF} Forms, TntDBCtrls,
  TntGraphics, Graphics, TntDB, TntActnList, TntSysUtils, TntWindows;

{ TTntColumnTitle }

procedure TTntColumnTitle.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

function TTntColumnTitle.IsCaptionStored: Boolean;
begin
  Result := (cvTitleCaption in Column.AssignedValues) and
    (FCaption <> WideString(DefaultCaption));
end;

procedure TTntColumnTitle.SetInheritedCaption(const Value: AnsiString);
begin
  inherited Caption := Value;
end;

function TTntColumnTitle.GetCaption: WideString;
begin
  if cvTitleCaption in Column.AssignedValues then
    Result := GetSyncedWideString(FCaption, inherited Caption)
  else
    Result := inherited Caption;
end;

procedure TTntColumnTitle.SetCaption(const Value: WideString);
begin
  if not (Column as TTntColumn).IsStored then
    inherited Caption := Value
  else begin
    if (cvTitleCaption in Column.AssignedValues) and (Value = FCaption) then Exit;
    SetSyncedWideString(Value, FCaption, inherited Caption, SetInheritedCaption);
  end;
end;

procedure TTntColumnTitle.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TTntColumnTitle then
  begin
    if cvTitleCaption in TTntColumnTitle(Source).Column.AssignedValues then
      Caption := TTntColumnTitle(Source).Caption;
  end;
end;

procedure TTntColumnTitle.RestoreDefaults;
begin
  FCaption := '';
  inherited;
end;

{ TTntColumn }

procedure TTntColumn.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

function TTntColumn.CreateTitle: TColumnTitle{TNT-ALLOW TColumnTitle};
begin
  Result := TTntColumnTitle.Create(Self);
end;

function TTntColumn.GetTitle: TTntColumnTitle;
begin
  Result := (inherited Title) as TTntColumnTitle;
end;

procedure TTntColumn.SetTitle(const Value: TTntColumnTitle);
begin
  inherited Title := Value;
end;

function TTntColumn.GetWidePickList: TTntStrings;
begin
  if FWidePickList = nil then begin
    FWidePickList := TTntStringList.Create;
    TTntStringList(FWidePickList).OnChange := HandlePickListChange;
  end;
  Result := FWidePickList;
end;

procedure TTntColumn.SetWidePickList(const Value: TTntStrings);
begin
  if Value = nil then
  begin
    FWidePickList.Free;
    FWidePickList := nil;
    (inherited PickList{TNT-ALLOW PickList}).Clear;
    Exit;
  end;
  WidePickList.Assign(Value);
end;

procedure TTntColumn.HandlePickListChange(Sender: TObject);
begin
  inherited PickList{TNT-ALLOW PickList}.Assign(WidePickList);
end;

destructor TTntColumn.Destroy;
begin
  inherited;
  FWidePickList.Free;
end;

{ TTntPopupListbox }
type
  TTntPopupListbox = class(TTntCustomListbox)
  private
    FSearchText: WideString;
    FSearchTickCount: Longint;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure KeyPressW(var Key: WideChar);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

procedure TTntPopupListbox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TTntPopupListbox.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TTntPopupListbox.WMChar(var Message: TWMChar);
var
  Key: WideChar;
begin
  Key := GetWideCharFromWMCharMsg(Message);
  KeyPressW(Key);
  SetWideCharForWMCharMsg(Message, Key);
  inherited;
end;

procedure TTntPopupListbox.KeypressW(var Key: WideChar);
var
  TickCount: Integer;
begin
  case Key of
    #8, #27: FSearchText := '';
    #32..High(WideChar):
      begin
        TickCount := GetTickCount;
        if TickCount - FSearchTickCount > 2000 then FSearchText := '';
        FSearchTickCount := TickCount;
        if Length(FSearchText) < 32 then FSearchText := FSearchText + Key;
        if IsWindowUnicode(Handle) then
          SendMessageW(Handle, LB_SelectString, WORD(-1), Longint(PWideChar(FSearchText)))
        else
          SendMessageA(Handle, LB_SelectString, WORD(-1), Longint(PAnsiChar(AnsiString(FSearchText))));
        Key := #0;
      end;
  end;
end;

procedure TTntPopupListbox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  (Owner as TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}).CloseUp((X >= 0) and (Y >= 0) and
      (X < Width) and (Y < Height));
end;

{ TTntPopupDataList }
type
  TTntPopupDataList = class(TPopupDataList)
  protected
    procedure Paint; override;
  end;

procedure TTntPopupDataList.Paint;
var
  FRecordIndex: Integer;
  FRecordCount: Integer;
  FKeySelected: Boolean;
  FKeyField: TField;

  procedure UpdateListVars;
  begin
    if ListActive then
    begin
      FRecordIndex := ListLink.ActiveRecord;
      FRecordCount := ListLink.RecordCount;
      FKeySelected := not VarIsNull(KeyValue) or
        not ListLink.DataSet.BOF;
    end else
    begin
      FRecordIndex := 0;
      FRecordCount := 0;
      FKeySelected := False;
    end;

    FKeyField := nil;
    if ListLink.Active and (KeyField <> '') then
      FKeyField := GetFieldProperty(ListLink.DataSet, Self, KeyField);
  end;

  function VarEquals(const V1, V2: Variant): Boolean;
  begin
    Result := False;
    try
      Result := V1 = V2;
    except
    end;
  end;

var
  I, J, W, X, TxtWidth, TxtHeight, LastFieldIndex: Integer;
  S: WideString;
  R: TRect;
  Selected: Boolean;
  Field: TField;
  AAlignment: TAlignment;
begin
  UpdateListVars;
  Canvas.Font := Font;
  TxtWidth := WideCanvasTextWidth(Canvas, '0');
  TxtHeight := WideCanvasTextHeight(Canvas, '0');
  LastFieldIndex := ListFields.Count - 1;
  if ColorToRGB(Color) <> ColorToRGB(clBtnFace) then
    Canvas.Pen.Color := clBtnFace else
    Canvas.Pen.Color := clBtnShadow;
  for I := 0 to RowCount - 1 do
  begin
    if Enabled then
      Canvas.Font.Color := Font.Color else
      Canvas.Font.Color := clGrayText;
    Canvas.Brush.Color := Color;
    Selected := not FKeySelected and (I = 0);
    R.Top := I * TxtHeight;
    R.Bottom := R.Top + TxtHeight;
    if I < FRecordCount then
    begin
      ListLink.ActiveRecord := I;
      if not VarIsNull(KeyValue) and
        VarEquals(FKeyField.Value, KeyValue) then
      begin
        Canvas.Font.Color := clHighlightText;
        Canvas.Brush.Color := clHighlight;
        Selected := True;
      end;
      R.Right := 0;
      for J := 0 to LastFieldIndex do
      begin
        Field := ListFields[J];
        if J < LastFieldIndex then
          W := Field.DisplayWidth * TxtWidth + 4 else
          W := ClientWidth - R.Right;
        S := GetWideDisplayText(Field);
        X := 2;
        AAlignment := Field.Alignment;
        if UseRightToLeftAlignment then ChangeBiDiModeAlignment(AAlignment);
        case AAlignment of
          taRightJustify: X := W - WideCanvasTextWidth(Canvas, S) - 3;
          taCenter: X := (W - WideCanvasTextWidth(Canvas, S)) div 2;
        end;
        R.Left := R.Right;
        R.Right := R.Right + W;
        if SysLocale.MiddleEast then TControlCanvas(Canvas).UpdateTextFlags;
        WideCanvasTextRect(Canvas, R, R.Left + X, R.Top, S);
        if J < LastFieldIndex then
        begin
          Canvas.MoveTo(R.Right, R.Top);
          Canvas.LineTo(R.Right, R.Bottom);
          Inc(R.Right);
          if R.Right >= ClientWidth then Break;
        end;
      end;
    end;
    R.Left := 0;
    R.Right := ClientWidth;
    if I >= FRecordCount then Canvas.FillRect(R);
    if Selected then
      Canvas.DrawFocusRect(R);
  end;
  if FRecordCount <> 0 then ListLink.ActiveRecord := FRecordIndex;
end;

{$IFDEF COMPILER_6_UP}
//-----------------------------------------------------------------------------------------
//                   TDBGridInplaceEdit - Delphi 6 and higher
//-----------------------------------------------------------------------------------------

constructor TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FLookupSource := TDataSource.Create(Self);
end;

function TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.GetWidePickListBox: TTntCustomListBox;
var
  PopupListbox: TTntPopupListbox;
begin
  if not Assigned(FWidePickListBox) then
  begin
    PopupListbox := TTntPopupListbox.Create(Self);
    PopupListbox.Visible := False;
    PopupListbox.Parent := Self;
    PopupListbox.OnMouseUp := ListMouseUp;
    PopupListbox.IntegralHeight := True;
    PopupListbox.ItemHeight := 11;
    FWidePickListBox := PopupListBox;
  end;
  Result := FWidePickListBox;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.CloseUp(Accept: Boolean);
var
  MasterField: TField;
  ListValue: Variant;
begin
  if ListVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    if ActiveList = DataList then
      ListValue := DataList.KeyValue
    else
      if WidePickListBox.ItemIndex <> -1 then
        ListValue := WidePickListBox.Items[WidePickListBox.ItemIndex];
    SetWindowPos(ActiveList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    ListVisible := False;
    if Assigned(FDataList) then
      FDataList.ListSource := nil;
    FLookupSource.Dataset := nil;
    Invalidate;
    if Accept then
      if ActiveList = DataList then
        with Grid as TTntCustomDBGrid, Columns[SelectedIndex].Field do
        begin
          MasterField := DataSet.FieldByName(KeyFields);
          if MasterField.CanModify and DataLink.Edit then
            MasterField.Value := ListValue;
        end
      else
        if (not VarIsNull(ListValue)) and EditCanModify then
          with Grid as TTntCustomDBGrid do
            SetWideText(Columns[SelectedIndex].Field, ListValue)
  end;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.DoEditButtonClick;
begin
  (Grid as TTntCustomDBGrid).EditButtonClick;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.DropDown;
var
  Column: TTntColumn;
begin
  if not ListVisible then
  begin
    with (Grid as TTntCustomDBGrid) do
      Column := Columns[SelectedIndex] as TTntColumn;
    if ActiveList = FDataList then
      with Column.Field do
      begin
        FDataList.Color := Color;
        FDataList.Font := Font;
        FDataList.RowCount := Column.DropDownRows;
        FLookupSource.DataSet := LookupDataSet;
        FDataList.KeyField := LookupKeyFields;
        FDataList.ListField := LookupResultField;
        FDataList.ListSource := FLookupSource;
        FDataList.KeyValue := DataSet.FieldByName(KeyFields).Value;
      end
    else if ActiveList = WidePickListBox then
    begin
      WidePickListBox.Items.Assign(Column.WidePickList);
      DropDownRows := Column.DropDownRows;
    end;
  end;
  inherited DropDown;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.UpdateContents;
var
  Column: TTntColumn;
begin
  inherited UpdateContents;
  if EditStyle = esPickList then
    ActiveList := WidePickListBox;
  if FUseDataList then
  begin
    if FDataList = nil then
    begin
      FDataList := TTntPopupDataList.Create(Self);
      FDataList.Visible := False;
      FDataList.Parent := Self;
      FDataList.OnMouseUp := ListMouseUp;
    end;
    ActiveList := FDataList;
  end;
  with (Grid as TTntCustomDBGrid) do
    Column := Columns[SelectedIndex] as TTntColumn;
  Self.ReadOnly := Column.ReadOnly;
  Font.Assign(Column.Font);
  ImeMode := Column.ImeMode;
  ImeName := Column.ImeName;
end;

{$ELSE}
//-----------------------------------------------------------------------------------------
//                   TDBGridInplaceEdit - Delphi 5 and lower
//-----------------------------------------------------------------------------------------

constructor TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FLookupSource := TDataSource.Create(Self);
  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
  FEditStyle := esSimple;
end;

function TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.GetWidePickListBox: TTntCustomListBox;
var
  PopupListbox: TTntPopupListbox;
begin
  if not Assigned(FWidePickListBox) then
  begin
    PopupListbox := TTntPopupListbox.Create(Self);
    PopupListbox.Visible := False;
    PopupListbox.Parent := Self;
    PopupListbox.OnMouseUp := ListMouseUp;
    PopupListbox.IntegralHeight := True;
    PopupListbox.ItemHeight := 11;
    FWidePickListBox := PopupListBox;
  end;
  Result := FWidePickListBox;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.BoundsChanged;
var
  R: TRect;
begin
  SetRect(R, 2, 2, Width - 2, Height);
  if FEditStyle <> esSimple then
    if not (Owner as TTntCustomDBGrid).UseRightToLeftAlignment then
      Dec(R.Right, FButtonWidth)
    else
      Inc(R.Left, FButtonWidth - 2);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@R));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  if SysLocale.FarEast then
    SetImeCompositionWindow(Font, R.Left, R.Top);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.CloseUp(Accept: Boolean);
var
  MasterField: TField;
  ListValue: Variant;
begin
  if FListVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    if FActiveList = FDataList then
      ListValue := FDataList.KeyValue
    else
      if WidePickListBox.ItemIndex <> -1 then
        ListValue := WidePickListBox.Items[WidePickListBox.ItemIndex];
    SetWindowPos(FActiveList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FListVisible := False;
    if Assigned(FDataList) then
      FDataList.ListSource := nil;
    FLookupSource.Dataset := nil;
    Invalidate;
    if Accept then
      if FActiveList = FDataList then
        with Grid as TTntCustomDBGrid, Columns[SelectedIndex].Field do
        begin
          MasterField := DataSet.FieldByName(KeyFields);
          if MasterField.CanModify and DataLink.Edit then
            MasterField.Value := ListValue;
        end
      else
        if (not VarIsNull(ListValue)) and EditCanModify then
          with Grid as TTntCustomDBGrid do
            SetWideText(Columns[SelectedIndex].Field, ListValue);
  end;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.DoDropDownKeys(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP, VK_DOWN:
      if ssAlt in Shift then
      begin
        if FListVisible then CloseUp(True) else DropDown;
        Key := 0;
      end;
    VK_RETURN, VK_ESCAPE:
      if FListVisible and not (ssAlt in Shift) then
      begin
        CloseUp(Key = VK_RETURN);
        Key := 0;
      end;
  end;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.DropDown;
var
  P: TPoint;
  I,J,Y: Integer;
  Column: TTntColumn;
  FPickList: TTntPopupListbox;
begin
  if not FListVisible and Assigned(FActiveList) then
  begin
    FActiveList.Width := Width;
    with Grid as TTntCustomDBGrid do
      Column := Columns[SelectedIndex];
    if FActiveList = FDataList then
    with Column.Field do
    begin
      FDataList.Color := Color;
      FDataList.Font := Font;
      FDataList.RowCount := Column.DropDownRows;
      FLookupSource.DataSet := LookupDataSet;
      FDataList.KeyField := LookupKeyFields;
      FDataList.ListField := LookupResultField;
      FDataList.ListSource := FLookupSource;
      FDataList.KeyValue := DataSet.FieldByName(KeyFields).Value;
{      J := Column.DefaultWidth;
      if J > FDataList.ClientWidth then
        FDataList.ClientWidth := J;
}    end
    else
    begin
      FPickList := WidePickListBox as TTntPopupListbox;
      FPickList.Color := Color;
      FPickList.Font := Font;
      FPickList.Items := Column.PickList{TNT-ALLOW PickList};
      if FPickList.Items.Count >= Integer(Column.DropDownRows) then
        FPickList.Height := Integer(Column.DropDownRows) * FPickList.ItemHeight + 4
      else
        FPickList.Height := FPickList.Items.Count * FPickList.ItemHeight + 4;
      if Column.Field.IsNull then
        FPickList.ItemIndex := -1
      else
        FPickList.ItemIndex := FPickList.Items.IndexOf(Column.Field.Text);
      J := FPickList.ClientWidth;
      for I := 0 to FPickList.Items.Count - 1 do
      begin
        Y := WideCanvasTextWidth(FPickList.Canvas, FPickList.Items[I]);
        if Y > J then J := Y;
      end;
      FPickList.ClientWidth := J;
    end;
    P := Parent.ClientToScreen(Point(Left, Top));
    Y := P.Y + Height;
    if Y + FActiveList.Height > Screen.Height then Y := P.Y - FActiveList.Height;
    SetWindowPos(FActiveList.Handle, HWND_TOP, P.X, Y, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
    FListVisible := True;
    Invalidate;
    Windows.SetFocus(Handle);
  end;
end;

procedure KillMessage(Wnd: HWnd; Msg: Integer);
// Delete the requested message from the queue, but throw back
// any WM_QUIT msgs that PeekMessage may also return
var
  M: TMsg;
begin
  M.Message := 0;
  if PeekMessage{TNT-ALLOW PeekMessage}(M, Wnd, Msg, Msg, pm_Remove) and (M.Message = WM_QUIT) then
    PostQuitMessage(M.wparam);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (EditStyle = esEllipsis) and (Key = VK_RETURN) and (Shift = [ssCtrl]) then
  begin
    (Grid as TTntCustomDBGrid).EditButtonClick;
    KillMessage(Handle, WM_CHAR);
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.ListMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    CloseUp(PtInRect(FActiveList.ClientRect, Point(X, Y)));
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and (FEditStyle <> esSimple) and
    OverButton(Point(X,Y)) then
  begin
    if FListVisible then
      CloseUp(False)
    else
    begin
      MouseCapture := True;
      FTracking := True;
      TrackButton(X, Y);
      if Assigned(FActiveList) then
        DropDown;
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ListPos: TPoint;
  MousePos: TSmallPoint;
begin
  if FTracking then
  begin
    TrackButton(X, Y);
    if FListVisible then
    begin
      ListPos := FActiveList.ScreenToClient(ClientToScreen(Point(X, Y)));
      if PtInRect(FActiveList.ClientRect, ListPos) then
      begin
        StopTracking;
        MousePos := PointToSmallPoint(ListPos);
        SendMessage(FActiveList.Handle, WM_LBUTTONDOWN, 0, Integer(MousePos));
        Exit;
      end;
    end;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := FPressed;
  StopTracking;
  if (Button = mbLeft) and (FEditStyle = esEllipsis) and WasPressed then
    (Grid as TTntCustomDBGrid).EditButtonClick;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.PaintWindow(DC: HDC);
var
  R: TRect;
  Flags: Integer;
  W, X, Y: Integer;
begin
  if FEditStyle <> esSimple then
  begin
    R := ButtonRect;
    Flags := 0;
    if FEditStyle in [esDataList, esPickList] then
    begin
      if FActiveList = nil then
        Flags := DFCS_INACTIVE
      else if FPressed then
        Flags := DFCS_FLAT or DFCS_PUSHED;
      DrawFrameControl(DC, R, DFC_SCROLL, Flags or DFCS_SCROLLCOMBOBOX);
    end
    else   { esEllipsis }
    begin
      if FPressed then Flags := BF_FLAT;
      DrawEdge(DC, R, EDGE_RAISED, BF_RECT or BF_MIDDLE or Flags);
      X := R.Left + ((R.Right - R.Left) shr 1) - 1 + Ord(FPressed);
      Y := R.Top + ((R.Bottom - R.Top) shr 1) - 1 + Ord(FPressed);
      W := FButtonWidth shr 3;
      if W = 0 then W := 1;
      PatBlt(DC, X, Y, W, W, BLACKNESS);
      PatBlt(DC, X - (W * 2), Y, W, W, BLACKNESS);
      PatBlt(DC, X + (W * 2), Y, W, W, BLACKNESS);
    end;
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
  end;
  inherited PaintWindow(DC);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.SetEditStyle(Value: TEditStyle);
begin
  if Value = FEditStyle then Exit;
  FEditStyle := Value;
  case Value of
    esPickList:
      begin
        FActiveList := WidePickListBox;
      end;
    esDataList:
      begin
        if FDataList = nil then
        begin
          FDataList := TTntPopupDataList.Create(Self);
          FDataList.Visible := False;
          FDataList.Parent := Self;
          FDataList.OnMouseUp := ListMouseUp;
        end;
        FActiveList := FDataList;
      end;
  else  { cbsNone, cbsEllipsis, or read only field }
    FActiveList := nil;
  end;
  with (Grid as TTntCustomDBGrid) do
    Self.ReadOnly := Columns[SelectedIndex].ReadOnly;
  Repaint;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
  end;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.TrackButton(X,Y: Integer);
var
  NewState: Boolean;
  R: TRect;
begin
  R := ButtonRect;
  NewState := PtInRect(R, Point(X, Y));
  if FPressed <> NewState then
  begin
    FPressed := NewState;
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.UpdateContents;
var
  Column: TTntColumn;
  NewStyle: TEditStyle;
  MasterField: TField;
begin
  with (Grid as TTntCustomDBGrid) do
    Column := Columns[SelectedIndex];
  NewStyle := esSimple;
  case Column.ButtonStyle of
   cbsEllipsis: NewStyle := esEllipsis;
   cbsAuto:
     if Assigned(Column.Field) then
     with Column.Field do
     begin
       { Show the dropdown button only if the field is editable }
       if FieldKind = fkLookup then
       begin
         MasterField := Dataset.FieldByName(KeyFields);
         { Column.DefaultReadonly will always be True for a lookup field.
           Test if Column.ReadOnly has been assigned a value of True }
         if Assigned(MasterField) and MasterField.CanModify and
           not ((cvReadOnly in Column.AssignedValues) and Column.ReadOnly) then
           with (Grid as TTntCustomDBGrid) do
             if not ReadOnly and DataLink.Active and not Datalink.ReadOnly then
               NewStyle := esDataList
       end
       else
       if Assigned(Column.PickList{TNT-ALLOW PickList})
       and (Column.PickList{TNT-ALLOW PickList}.Count > 0)
       and (not Column.Readonly) then
         NewStyle := esPickList
       else if DataType in [ftDataset, ftReference] then
         NewStyle := esEllipsis;
     end;
  end;
  EditStyle := NewStyle;
  inherited UpdateContents;
  Font.Assign(Column.Font);
  ImeMode := Column.ImeMode;
  ImeName := Column.ImeName;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and (Message.Sender <> FActiveList) then
    CloseUp(False);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WMCancelMode(var Message: TMessage);
begin
  StopTracking;
  inherited;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WMKillFocus(var Message: TMessage);
begin
  if not SysLocale.FarEast then inherited
  else
  begin
    ImeName := Screen.DefaultIme;
    ImeMode := imDontCare;
    inherited;
    if HWND(Message.WParam) <> (Grid as TTntCustomDBGrid).Handle then
      ActivateKeyboardLayout(Screen.DefaultKbLayout, KLF_ACTIVATE);
  end;
  CloseUp(False);
end;

function TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.ButtonRect: TRect;
begin
  if not (Owner as TTntCustomDBGrid).UseRightToLeftAlignment then
    Result := Rect(Width - FButtonWidth, 0, Width, Height)
  else
    Result := Rect(0, 0, FButtonWidth, Height);
end;

function TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.OverButton(const P: TPoint): Boolean;
begin
  Result := PtInRect(ButtonRect, P);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  with Message do
  if (FEditStyle <> esSimple) and OverButton(Point(XPos, YPos)) then
    Exit;
  inherited;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WMPaint(var Message: TWMPaint);
begin
  PaintHandler(Message);
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  if (FEditStyle <> esSimple) and OverButton(P) then
    Windows.SetCursor(LoadCursor(0, idc_Arrow))
  else
    inherited;
end;

procedure TDBGridInplaceEdit{TNT-ALLOW TDBGridInplaceEdit}.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    wm_KeyDown, wm_SysKeyDown, wm_Char:
      if EditStyle in [esPickList, esDataList] then
      with TWMKey(Message) do
      begin
        DoDropDownKeys(CharCode, KeyDataToShiftState(KeyData));
        if (CharCode <> 0) and FListVisible then
        begin
          with TMessage(Message) do
            SendMessage(FActiveList.Handle, Msg, WParam, LParam);
          Exit;
        end;
      end
  end;
  inherited;
end;
{$ENDIF}
//-----------------------------------------------------------------------------------------

{ TTntDBGridInplaceEdit }

procedure TTntDBGridInplaceEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  TntCustomEdit_CreateWindowHandle(Self, Params);
end;

function TTntDBGridInplaceEdit.GetText: WideString;
begin
  Result := TntControl_GetText(Self);
end;

procedure TTntDBGridInplaceEdit.SetText(const Value: WideString);
begin
  TntControl_SetText(Self, Value);
end;

procedure TTntDBGridInplaceEdit.WMSetText(var Message: TWMSetText);
begin
  if (not FBlockSetText) then
    inherited;
end;

procedure TTntDBGridInplaceEdit.UpdateContents;
var
  Grid: TTntCustomDBGrid;
begin
  Grid := Self.Grid as TTntCustomDBGrid;
  EditMask  := Grid.GetEditMask(Grid.Col, Grid.Row);
  Text      := Grid.GetEditText(Grid.Col, Grid.Row);
  MaxLength := Grid.GetEditLimit;

  FBlockSetText := True;
  try
    inherited;
  finally
    FBlockSetText := False;
  end;
end;

procedure TTntDBGridInplaceEdit.DblClick;
begin
  FInDblClick := True;
  try
    inherited;
  finally
    FInDblClick := False;
  end;
end;

{ TTntGridDataLink }
type
  TTntGridDataLink = class(TGridDataLink)
  private
    OriginalSetText: TFieldSetTextEvent;
    procedure GridUpdateFieldText(Sender: TField; const Text: AnsiString);
    {$IFNDEF COMPILER_6_UP}
    function Grid: TCustomDBGrid{TNT-ALLOW TCustomDBGrid};
    {$ENDIF}
  protected
    procedure UpdateData; override;
    procedure RecordChanged(Field: TField); override;
  end;

{$IFDEF COMPILER_5} // verified against VCL source in Delphi 5 and BCB 5
type
  THackGridDataLink = class(TDataLink)
  protected
    FGrid: TCustomDBGrid{TNT-ALLOW TCustomDBGrid};
  end;
{$ENDIF}

{$IFNDEF COMPILER_6_UP}
function TTntGridDataLink.Grid: TCustomDBGrid{TNT-ALLOW TCustomDBGrid};
begin
  Result := THackGridDataLink(Self).FGrid;
end;
{$ENDIF}

procedure TTntGridDataLink.GridUpdateFieldText(Sender: TField; const Text: AnsiString);
begin
  Sender.OnSetText := OriginalSetText;
  if Assigned(Sender) then
    SetWideText(Sender, (Grid as TTntCustomDBGrid).FEditText);
end;

procedure TTntGridDataLink.RecordChanged(Field: TField);
var
  CField: TField;
begin
  inherited;
  if Grid.HandleAllocated then begin
    CField := Grid.SelectedField;
    if ((Field = nil) or (CField = Field)) and
      (Assigned(CField) and (GetWideText(CField) <> (Grid as TTntCustomDBGrid).FEditText)) then
    begin
      with (Grid as TTntCustomDBGrid) do begin
        InvalidateEditor;
        if InplaceEditor <> nil then InplaceEditor.Deselect;
      end;
    end;
  end;
end;

procedure TTntGridDataLink.UpdateData;
var
  Field: TField;
begin
  Field := (Grid as TTntCustomDBGrid).SelectedField;
  // remember "set text"
  if Field <> nil then
    OriginalSetText := Field.OnSetText;
  try
    // redirect "set text" to self
    if Field <> nil then
      Field.OnSetText := GridUpdateFieldText;
    inherited; // clear modified !
  finally
    // redirect "set text" to field
    if Field <> nil then
      Field.OnSetText := OriginalSetText;
    // forget original "set text"
    OriginalSetText := nil;
  end;
end;

{ TTntDBGridColumns }

function TTntDBGridColumns.Add: TTntColumn;
begin
  Result := inherited Add as TTntColumn;
end;

function TTntDBGridColumns.GetColumn(Index: Integer): TTntColumn;
begin
  Result := inherited Items[Index] as TTntColumn;
end;

procedure TTntDBGridColumns.SetColumn(Index: Integer; const Value: TTntColumn);
begin
  inherited Items[Index] := Value;
end;

{$IFDEF COMPILER_5} // verified against VCL source in Delphi 5 and BCB 5
type
  THackCustomDBGrid = class(TCustomGrid)
  protected
    FIndicators: TImageList;
    FTitleFont: TFont;
    FReadOnly: Boolean;
    FOriginalImeName: TImeName;
    FOriginalImeMode: TImeMode;
    FUserChange: Boolean;
    FIsESCKey: Boolean;
    FLayoutFromDataset: Boolean;
    FOptions: TDBGridOptions;
    FTitleOffset, FIndicatorOffset: Byte;
    FUpdateLock: Byte;
    FLayoutLock: Byte;
    FInColExit: Boolean;
    FDefaultDrawing: Boolean;
    FSelfChangingTitleFont: Boolean;
    FSelecting: Boolean;
    FSelRow: Integer;
    FDataLink: TGridDataLink;
  end;
{$ENDIF}

{ TTntCustomDBGrid }

constructor TTntCustomDBGrid.Create(AOwner: TComponent);
begin
  inherited;
  {$IFNDEF COMPILER_6_UP}
  DataLink.Free;
  THackCustomDBGrid(Self).FDataLink := TTntGridDataLink.Create(Self);
  {$ENDIF}
end;

procedure TTntCustomDBGrid.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle(Self, Params, '');
end;

type TAccessCustomGrid = class(TCustomGrid);

procedure TTntCustomDBGrid.WMChar(var Msg: TWMChar);
begin
  if (goEditing in TAccessCustomGrid(Self).Options)
  and (AnsiChar(Msg.CharCode) in [^H, #32..#255]) then begin
    RestoreWMCharMsg(TMessage(Msg));
    ShowEditorChar(WideChar(Msg.CharCode));
  end else
    inherited;
end;

procedure TTntCustomDBGrid.ShowEditorChar(Ch: WideChar);
begin
  ShowEditor;
  if InplaceEditor <> nil then begin
    if Win32PlatformIsUnicode then
      PostMessageW(InplaceEditor.Handle, WM_CHAR, Word(Ch), 0)
    else
      PostMessageA(InplaceEditor.Handle, WM_CHAR, Word(Ch), 0);
  end;
end;

procedure TTntCustomDBGrid.DefineProperties(Filer: TFiler);
begin
  inherited;
  TntPersistent_AfterInherited_DefineProperties(Filer, Self);
end;

function TTntCustomDBGrid.IsHintStored: Boolean;
begin
  Result := TntControl_IsHintStored(Self);
end;

function TTntCustomDBGrid.GetHint: WideString;
begin
  Result := TntControl_GetHint(Self)
end;

procedure TTntCustomDBGrid.SetHint(const Value: WideString);
begin
  TntControl_SetHint(Self, Value);
end;

function TTntCustomDBGrid.CreateColumns: TDBGridColumns{TNT-ALLOW TDBGridColumns};
begin
  Result := TTntDBGridColumns.Create(Self, TTntColumn);
end;

function TTntCustomDBGrid.GetColumns: TTntDBGridColumns;
begin
  Result := inherited Columns as TTntDBGridColumns;
end;

procedure TTntCustomDBGrid.SetColumns(const Value: TTntDBGridColumns);
begin
  inherited Columns := Value;
end;

function TTntCustomDBGrid.CreateEditor: TInplaceEdit{TNT-ALLOW TInplaceEdit};
begin
  Result := TTntDBGridInplaceEdit.Create(Self);
end;

{$IFDEF COMPILER_6_UP}
function TTntCustomDBGrid.CreateDataLink: TGridDataLink;
begin
  Result := TTntGridDataLink.Create(Self);
end;
{$ENDIF}

function TTntCustomDBGrid.GetEditText(ACol, ARow: Integer): WideString;
var
  Field: TField;
begin
  Field := GetColField(RawToDataColumn(ACol));
  if Field = nil then
    Result := ''
  else
    Result := GetWideText(Field);
  FEditText := Result;
end;

procedure TTntCustomDBGrid.SetEditText(ACol, ARow: Integer; const Value: AnsiString);
begin
  if (InplaceEditor as TTntDBGridInplaceEdit).FInDblClick then
    FEditText := Value
  else
    FEditText := (InplaceEditor as TTntDBGridInplaceEdit).Text;
  inherited;
end;

//----------------- DRAW CELL PROCS --------------------------------------------------
var
  DrawBitmap: TBitmap = nil;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: WideString; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOutW for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - WideCanvasTextWidth(ACanvas, Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (WideCanvasTextWidth(ACanvas, Text) shr 1);
    end;
    WideCanvasTextRect(ACanvas, ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        Tnt_DrawTextW(Handle, PWideChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then  
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

procedure TTntCustomDBGrid.DefaultDrawDataCell(const Rect: TRect; Field: TField;
  State: TGridDrawState);
var
  Alignment: TAlignment;
  Value: WideString;
begin
  Alignment := taLeftJustify;
  Value := '';
  if Assigned(Field) then
  begin
    Alignment := Field.Alignment;
    Value := GetWideDisplayText(Field);
  end;
  WriteText(Canvas, Rect, 2, 2, Value, Alignment,
    UseRightToLeftAlignmentForField(Field, Alignment));
end;

procedure TTntCustomDBGrid.DefaultDrawColumnCell(const Rect: TRect;
  DataCol: Integer; Column: TTntColumn; State: TGridDrawState);
var
  Value: WideString;
begin
  Value := '';
  if Assigned(Column.Field) then
    Value := GetWideDisplayText(Column.Field);
  WriteText(Canvas, Rect, 2, 2, Value, Column.Alignment,
    UseRightToLeftAlignmentForField(Column.Field, Column.Alignment));
end;

procedure TTntCustomDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  FrameOffs: Byte;

  procedure DrawTitleCell(ACol, ARow: Integer; Column: TTntColumn; var AState: TGridDrawState);
  const
    ScrollArrows: array [Boolean, Boolean] of Integer =
      ((DFCS_SCROLLRIGHT, DFCS_SCROLLLEFT), (DFCS_SCROLLLEFT, DFCS_SCROLLRIGHT));
  var
    MasterCol: TColumn{TNT-ALLOW TColumn};
    TitleRect, TxtRect, ButtonRect: TRect;
    I: Integer;
    InBiDiMode: Boolean;
  begin
    TitleRect := CalcTitleRect(Column, ARow, MasterCol);

    if MasterCol = nil then
    begin
      Canvas.FillRect(ARect);
      Exit;
    end;

    Canvas.Font := MasterCol.Title.Font;
    Canvas.Brush.Color := MasterCol.Title.Color;
    if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
      InflateRect(TitleRect, -1, -1);
    TxtRect := TitleRect;
    I := GetSystemMetrics(SM_CXHSCROLL);
    if ((TxtRect.Right - TxtRect.Left) > I) and MasterCol.Expandable then
    begin
      Dec(TxtRect.Right, I);
      ButtonRect := TitleRect;
      ButtonRect.Left := TxtRect.Right;
      I := SaveDC(Canvas.Handle);
      try
        Canvas.FillRect(ButtonRect);
        InflateRect(ButtonRect, -1, -1);
        IntersectClipRect(Canvas.Handle, ButtonRect.Left,
          ButtonRect.Top, ButtonRect.Right, ButtonRect.Bottom);
        InflateRect(ButtonRect, 1, 1);
        { DrawFrameControl doesn't draw properly when orienatation has changed.
          It draws as ExtTextOutW does. }
        InBiDiMode := Canvas.CanvasOrientation = coRightToLeft;
        if InBiDiMode then { stretch the arrows box }
          Inc(ButtonRect.Right, GetSystemMetrics(SM_CXHSCROLL) + 4);
        DrawFrameControl(Canvas.Handle, ButtonRect, DFC_SCROLL,
          ScrollArrows[InBiDiMode, MasterCol.Expanded] or DFCS_FLAT);
      finally
        RestoreDC(Canvas.Handle, I);
      end;
    end;
    with (MasterCol.Title as TTntColumnTitle) do
      WriteText(Canvas, TxtRect, FrameOffs, FrameOffs, Caption, Alignment, IsRightToLeft);
    if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
    begin
      InflateRect(TitleRect, 1, 1);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_TOPLEFT);
    end;
    AState := AState - [gdFixed];  // prevent box drawing later
  end;

var
  OldActive: Integer;
  Highlight: Boolean;
  Value: WideString;
  DrawColumn: TTntColumn;
begin
  if csLoading in ComponentState then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
    Exit;
  end;

  if (gdFixed in AState) and (RawToDataColumn(ACol) < 0) then
  begin
    inherited;
    exit;
  end;

  Dec(ARow, FixedRows);
  ACol := RawToDataColumn(ACol);

  if (gdFixed in AState) and ([dgRowLines, dgColLines] * Options =
    [dgRowLines, dgColLines]) then
  begin
    InflateRect(ARect, -1, -1);
    FrameOffs := 1;
  end
  else
    FrameOffs := 2;

  with Canvas do
  begin
    DrawColumn := Columns[ACol] as TTntColumn;
    if not DrawColumn.Showing then Exit;
    if not (gdFixed in AState) then
    begin
      Font := DrawColumn.Font;
      Brush.Color := DrawColumn.Color;
    end;
    if ARow < 0 then
      DrawTitleCell(ACol, ARow + FixedRows, DrawColumn, AState)
    else if (DataLink = nil) or not DataLink.Active then
      FillRect(ARect)
    else
    begin
      Value := '';
      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := ARow;
        if Assigned(DrawColumn.Field) then
          Value := GetWideDisplayText(DrawColumn.Field);
        Highlight := HighlightCell(ACol, ARow, Value, AState);
        if Highlight then
        begin
          Brush.Color := clHighlight;
          Font.Color := clHighlightText;
        end;
        if not Enabled then
          Font.Color := clGrayText;
        if DefaultDrawing then
          DefaultDrawColumnCell(ARect, ACol, DrawColumn, AState);
        if Columns.State = csDefault then
          DrawDataCell(ARect, DrawColumn.Field, AState);
        DrawColumnCell(ARect, ACol, DrawColumn, AState);
      finally
        DataLink.ActiveRecord := OldActive;
      end;
      if DefaultDrawing and (gdSelected in AState)
        and ((dgAlwaysShowSelection in Options) or Focused)
        and not (csDesigning in ComponentState)
        and not (dgRowSelect in Options)
        and (UpdateLock = 0)
        and (ValidParentForm(Self).ActiveControl = Self) then
        Windows.DrawFocusRect(Handle, ARect);
    end;
  end;
  if (gdFixed in AState) and ([dgRowLines, dgColLines] * Options =
    [dgRowLines, dgColLines]) then
  begin
    InflateRect(ARect, 1, 1);
    DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
    DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_TOPLEFT);
  end;
end;

procedure TTntCustomDBGrid.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  TntControl_BeforeInherited_ActionChange(Self, Sender, CheckDefaults);
  inherited;
end;

function TTntCustomDBGrid.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TntControl_GetActionLinkClass(Self, inherited GetActionLinkClass);
end;

initialization
  DrawBitmap := TBitmap.Create;

finalization
  DrawBitmap.Free;

end.
