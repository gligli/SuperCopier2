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

unit ScPopupButton;

interface

uses
  Windows,SysUtils, Classes, Controls,TNTMenus,Messages,Types,Themes,StdCtrls,Graphics,ExtCtrls;

type

  TClickPopupButton = Procedure (Sender:TObject;ItemIndex:Integer) of object;

  TStatusButton=(SBButtonOver,SBButtonDown,SBNormal,SBDisabled);
  TScPopupButton = class(TCustomControl)
  private
    { Déclarations privées }
    FItemIndex:integer;
    FPopup:TTntPopupMenu;
    FOnClick:TClickPopupButton;
    FCaption:WideString;
    FImageIndex:Integer;
    FImageList:TImageList;
    StatusButton:TStatusButton;
    ReleaseTimer:TTimer;
  protected
    { Déclarations protégées }
    procedure Loaded;override;
    procedure Paint;override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure PopupChange(Sender: TObject; Source: TTNTMenuItem; Rebuild: Boolean);
    procedure ClickPopup(Sender: TObject);
    procedure OnReleaseTimer(Sender: TObject);
    procedure DoPopup;
    procedure DoClick(Index:integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure KeyUp(var Key: Word; Shift: TShiftState);override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetItemIndex(const Value:Integer);
    procedure SetPopup(const Value:TTntPopupMenu);
    procedure SetCaption(const Value:WideString);
    procedure SetImageIndex(const Value:Integer);
    procedure SetImageList(const Value:TImageList);
  public
    { Déclarations publiques }
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
  published
    { Déclarations publiées }
    property Visible;
    property Enabled;
    property TabOrder;
    property TabStop;
    property Anchors;
    property ItemIndex : Integer read FItemIndex write SetItemIndex;
    property Popup : TTntPopupMenu read FPopup write SetPopup;
    property Caption : WideString read FCaption write SetCaption;
    property ImageIndex : Integer read FImageIndex write SetImageIndex;
    property ImageList : TImageList read FImageList write SetImageList;
    property OnClick:TClickPopupButton read FOnClick write FOnClick;
  end;

procedure Register;

implementation

uses Menus;

type
  TEndMenu=function:LongBool;stdcall;

var
  HUser32_dll:Cardinal;
  DynEndMenu:TEndMenu;

procedure Register;
begin
  RegisterComponents('SFX Team', [TScPopupButton]);
end;

{ TScPopupButton }

constructor TScPopupButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FPopup:=nil;
  FCaption:='';
  FImageIndex:=-1;
  FImageList:=nil;

  Self.Constraints.MinWidth:=30;
  Self.Constraints.MinHeight:=15;
  ControlStyle := ControlStyle + [csReflector,csOpaque];
  StatusButton:=SBNormal;
  TabStop:=True;

  // ce timer ca servir à simuler l'évènement de relachage de la souris sur le
  // bouton lorsque le popup est ouvert
  ReleaseTimer:=TTimer.Create(Parent);
  ReleaseTimer.Enabled:=False;
  ReleaseTimer.Interval:=50;
  ReleaseTimer.OnTimer:=OnReleaseTimer;
end;

destructor TScPopupButton.Destroy;
begin
  inherited;

  ReleaseTimer.Free;
  FPopup.Free;
end;

procedure TScPopupButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'SCPOPUPBUTTON');
end;

procedure TScPopupButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var PMHwnd:THandle;
begin
  inherited;

  // on ferme le popup menu
  if Assigned(FPopup) then
  begin
    if (Win32MajorVersion>4) and // Win98/Me ou Win2000 et >
       ((Win32Platform=VER_PLATFORM_WIN32_NT) or
       ((Win32Platform=VER_PLATFORM_WIN32_WINDOWS) and (Win32MinorVersion>0))) then
    begin
      DynEndMenu;
    end
    else if (Win32MajorVersion=4) and (Win32Platform=VER_PLATFORM_WIN32_NT) then //Win NT4
    begin
      PMHwnd:=FindWindow('#32768',nil);
      SendMessage(PMHwnd,WM_CLOSE,0,0);
    end;
  end;

  StatusButton:=SBNormal;
  if (Y>=0) and (Y<=Height) and (X>=0) and (X<=Width) then
  begin
    StatusButton:=SBButtonOver;

    DoClick(ItemIndex);
  end;

  Invalidate;
end;

procedure TScPopupButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Button=mbLeft then
  begin
    if Assigned(FPopup) then ReleaseTimer.Enabled:=True;
    StatusButton:=SBButtonDown;
    Invalidate;
  end;

  DoPopup;
end;

procedure TScPopupButton.SetEnabled(Value: Boolean);
begin
  inherited;
  if Enabled then
  begin
    if StatusButton=SBDisabled then
    begin
      StatusButton:=SBNormal;
      Invalidate;
    end;
  end
  else
  begin
    if StatusButton<>SBDisabled then
    begin
      StatusButton:=SBDisabled;
      Invalidate;
    end;
  end;
end;


procedure TScPopupButton.SetItemIndex(const Value: Integer);
var
  Id:Integer;
begin
  if value<>FItemIndex then
  begin
    Id:=Value;
    if assigned(FPopup) then
    begin
      if Value>FPopup.Items.Count-1 then Id:=FPopup.Items.Count-1;
      if Value<0 then Id:=0;
      FPopup.Items[ItemIndex].Visible:=True;
      FPopup.Items[Id].Visible:=false;
     end;
    FItemIndex:=Id;
  end;
  invalidate;
end;

procedure TScPopupButton.SetPopup(const Value: TTntPopupMenu);
begin
  if value<>FPopup then
  begin
    FPopup:=Value;
    PopupChange(nil,nil,true);
    Invalidate;
  end;
end;

procedure TScPopupButton.SetCaption(const Value:WideString);
begin
  if Value<>FCaption then
  begin
    FCaption:=Value;
    Invalidate;
  end;
end;

procedure TScPopupButton.SetImageIndex(const Value:Integer);
begin
  if FImageIndex<>Value then
  begin
    FImageIndex:=Value;
    Invalidate;
  end;
end;

procedure TScPopupButton.SetImageList(const Value:TImageList);
begin
  if FImageList<>Value then
  begin
    FImageList:=Value;
    Invalidate;
  end;
end;

procedure TScPopupButton.Paint;
  procedure BtDrawText(pCaption:WideString;Rect:TRect);
  begin
    if Win32Platform=VER_PLATFORM_WIN32_NT then
    begin
      DrawTextW(Canvas.Handle,Pwidechar(pCaption),length(pCaption),Rect,DT_CENTER+DT_VCENTER+DT_SINGLELINE);
    end else
    begin
      DrawText(Canvas.Handle,PChar(String(pCaption)),length(pCaption),Rect,DT_CENTER+DT_VCENTER+DT_SINGLELINE);
    end;
  end;
var
  BtCaption:WideString;
  BtImageList:TImageList;
  BtImageIndex:Integer;

  TxtRect,BtnRect:TRect;
begin
  BtnRect:=rect(0,0,Width,Height);
  Perform(WM_ERASEBKGND,Canvas.Handle,1);
  if ThemeServices.ThemesEnabled then
  begin
    Case StatusButton of
      SBNormal:
        begin
          if Focused then
            ThemeServices.DrawElement(Canvas.Handle,ThemeServices.GetElementDetails(tbPushButtonDefaulted),BtnRect)
          else
            ThemeServices.DrawElement(Canvas.Handle,ThemeServices.GetElementDetails(tbPushButtonNormal),BtnRect);
        end;
      SBButtonDown:
        begin
          ThemeServices.DrawElement(Canvas.Handle,ThemeServices.GetElementDetails(tbPushButtonPressed),BtnRect);
        end;
      SBButtonOver:
        begin
          ThemeServices.DrawElement(Canvas.Handle,ThemeServices.GetElementDetails(tbPushButtonHot),BtnRect);
        end;
      SBDisabled:
        begin
          ThemeServices.DrawElement(Canvas.Handle,ThemeServices.GetElementDetails(tbPushButtonDisabled),BtnRect);
        end;
    end;
  end else
  begin
   Case StatusButton of
      SBButtonOver,
      SBNormal:
        DrawFrameControl(Canvas.Handle, BtnRect, DFC_BUTTON	, DFCS_BUTTONPUSH);
      SBButtonDown:
        DrawFrameControl(Canvas.Handle, BtnRect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED);
      SBDisabled:
        DrawFrameControl(Canvas.Handle, BtnRect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_INACTIVE);
    end;
  end;

  Canvas.Brush.Style:=bsClear;

  BtCaption:=FCaption;
  BtImageIndex:=FImageIndex;
  BtImageList:=FImageList;
  if Assigned(FPopup) and (FItemIndex<FPopup.Items.Count) and (FPopup.Items[FItemIndex]<>nil) then
  begin
    BtImageIndex:=FPopup.Items[FItemIndex].ImageIndex;
    BtImageList:=FPopup.Images as TImageList;
    BtCaption:=(FPopup.Items[FItemIndex] as TTntMenuItem).Caption;
  end;

  // Dessine l'icone
  if (BtImageIndex>=0) and (BtImageList<>nil) then
  begin
    BtImageList.Draw(Canvas,5,(Height-BtImageList.Height) div 2,BtImageIndex);
    TxtRect:=Rect(BtImageList.Width,0,Width,height);
  end else
    TxtRect:=Rect(0,0,Width,height);

  // Affiche le text
  if StatusButton<>SBDisabled then
  begin
    Canvas.Font.Color:=clBtnText;
    BtDrawText(BtCaption,TxtRect);
  end
  else
  begin
    Inc(TxtRect.Top,2);
    Inc(TxtRect.Left,2);
    Canvas.Font.Color:=clBtnHighlight;
    BtDrawText(BtCaption,TxtRect);
    Dec(TxtRect.Top,2);
    Dec(TxtRect.Left,2);
    Canvas.Font.Color:=clBtnShadow;
    BtDrawText(BtCaption,TxtRect);
  end;

  // Dessine le focus
  if Focused then
  begin
    Canvas.Brush.Style:=bsSolid;
    Canvas.DrawFocusRect(Rect(3,3,Width-3,Height-3));
  end;
end;


procedure TScPopupButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if StatusButton=SBNormal then
  begin
    StatusButton:=SBButtonOver;
    Invalidate;
  end;
end;

procedure TScPopupButton.CMMouseLeave(var Message: TMessage);
begin
  if not (StatusButton in [SBButtonDown,SBDisabled]) then
  begin
    StatusButton:=SBNormal;
    Invalidate;
  end;
end;

procedure TScPopupButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  Invalidate;
end;


procedure TScPopupButton.PopupChange(Sender: TObject; Source: TTNTMenuItem;
  Rebuild: Boolean);
var
  i:integer;
begin
  if Assigned(FPopup) then
  begin
    FPopup.AutoHotkeys:=maManual;
    FPopup.TrackButton:=tbLeftButton;
    for i:=0 to FPopup.Items.Count-1 do
    begin
      FPopup.Items[i].OnClick:=ClickPopup;
      FPopup.Items[i].AutoHotkeys:=maParent;
    end;
    if FPopup.Items[FItemIndex]<>nil then FPopup.Items[FItemIndex].Visible:=false;
  end;
end;

procedure TScPopupButton.loaded;
begin
  inherited;
  PopupChange(nil,nil,true);
end;

procedure TScPopupButton.ClickPopup(Sender: TObject);
var
  IdClick:Integer;
begin
  StatusButton:=SBNormal;
  Invalidate;
  IdClick:=FPopup.Items.IndexOf(Sender as TTntMenuItem);
  DoClick(IdClick);
end;

procedure TScPopupButton.OnReleaseTimer(Sender: TObject);
var X,Y:Word;
begin
  if GetAsyncKeyState(VK_LBUTTON)=0 then
  begin
    X:=Mouse.CursorPos.X-ClientOrigin.X;
    Y:=Mouse.CursorPos.Y-ClientOrigin.Y;

    SendMessage(Handle,WM_LBUTTONUP,0,MakeLParam(X,Y));

    ReleaseTimer.Enabled:=False;
  end;
end;

procedure TScPopupButton.DoPopup;
begin
  if Assigned(FPopup) then
    FPopup.Popup(Self.ClientOrigin.X,Self.ClientOrigin.Y+Self.Height-1);
end;

procedure TScPopupButton.DoClick(Index:Integer);
begin
  if Assigned(FOnClick) then
    FOnClick(Self,Index);
end;

procedure TScPopupButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key=VK_RETURN then DoClick(ItemIndex);
  if Key=VK_SPACE then DoPopup;
end;

procedure TScPopupButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
end;

initialization
  HUser32_dll:=LoadLibrary('user32.dll');
  DynEndMenu:=GetProcAddress(HUser32_dll,'EndMenu');

finalization
  FreeLibrary(HUser32_dll);

end.
