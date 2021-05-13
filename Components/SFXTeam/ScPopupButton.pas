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
  Windows,SysUtils, Classes, Controls,Menus,Messages,Types,Themes,StdCtrls,Graphics,ExtCtrls;

type

  TClickPopupButton = Procedure (Sender:TObject;ItemIndex:Integer) of object;

  TStatusButton=(SBButtonOver,SBButtonDown,SBNormal,SBDisabled);
  TScPopupButton = class(TCustomControl)
  private
    { Déclarations privées }
    FItemIndex:integer;
    FPopup:TPopupMenu;
    FOnClick:TClickPopupButton;
    FCaption:WideString;
    FImageIndex:Integer;
    FImageList:TImageList;
    StatusButton:TStatusButton;
    PopupTimer:TTimer;
  protected
    { Déclarations protégées }
    procedure Loaded;override;
    procedure Paint;override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure PopupChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    procedure ClickPopup(Sender: TObject);
    procedure OnPopupTimer(Sender: TObject);
    procedure DoPopup(AWithTimer:Boolean);
    procedure EndPopup;
    procedure DoClick(Index:integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure KeyUp(var Key: Word; Shift: TShiftState);override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetItemIndex(const Value:Integer);
    procedure SetPopup(const Value:TPopupMenu);
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
    property Popup : TPopupMenu read FPopup write SetPopup;
    property Caption : WideString read FCaption write SetCaption;
    property ImageIndex : Integer read FImageIndex write SetImageIndex;
    property ImageList : TImageList read FImageList write SetImageList;
    property OnClick:TClickPopupButton read FOnClick write FOnClick;
  end;

procedure Register;

implementation

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

  // ce timer ca servir détecter si la souris a quittée la zone du bouton
  // lorsque le popup est ouvert (pour fermer le popup après un certain temps)
  PopupTimer:=TTimer.Create(Parent);
  PopupTimer.Enabled:=False;
  PopupTimer.Interval:=50;
  PopupTimer.OnTimer:=OnPopupTimer;
end;

destructor TScPopupButton.Destroy;
begin
  inherited;

  PopupTimer.Free;
end;

procedure TScPopupButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'SCPOPUPBUTTON');
end;

procedure TScPopupButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  StatusButton:=SBNormal;
  if (Y>=0) and (Y<=Height) and (X>=0) and (X<=Width) then
  begin
    StatusButton:=SBButtonOver;

    EndPopup;

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
    StatusButton:=SBButtonDown;
    Invalidate;
  end;
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

procedure TScPopupButton.SetPopup(const Value: TPopupMenu);
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
  Perform(WM_ERASEBKGND,Handle,1);
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
    BtCaption:=(FPopup.Items[FItemIndex] as TMenuItem).Caption;
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


procedure TScPopupButton.PopupChange(Sender: TObject; Source: TMenuItem;
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
  IdClick:=FPopup.Items.IndexOf(Sender as TMenuItem);
  DoClick(IdClick);
end;

procedure TScPopupButton.OnPopupTimer(Sender: TObject);
var PMRect:TRect;

  function PointInRect(APoint:TPoint;ARect:TRect):Boolean;
  begin
    Result:=(APoint.X>=ARect.Left) and
            (APoint.Y>=ARect.Top) and
            (APoint.X<=ARect.Right) and
            (APoint.Y<=ARect.Bottom);
  end;

begin
  GetWindowRect(FindWindow('#32768',nil),PMRect);

  if not (PointInRect(ScreenToClient(Mouse.CursorPos),ClientRect) or PointInRect(Mouse.CursorPos,PMRect)) then
    EndPopup;
end;

procedure TScPopupButton.DoPopup(AWithTimer:Boolean);
begin
  if Assigned(FPopup) then
  begin
    PopupTimer.Enabled:=AWithTimer;
    FPopup.Popup(Self.ClientOrigin.X,Self.ClientOrigin.Y+Self.Height-1);
  end;
end;

procedure TScPopupButton.EndPopup;
var PMHwnd:THandle;
begin
  if Assigned(FPopup) then
  begin
    PopupTimer.Enabled:=False;

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
  if Key=VK_SPACE then DoPopup(False);
end;

procedure TScPopupButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
end;

procedure TScPopupButton.CMMouseEnter(var Message: TMessage);
begin
  if not (csDesigning in ComponentState) then DoPopup(True);
end;

initialization
  HUser32_dll:=LoadLibrary('user32.dll');
  DynEndMenu:=GetProcAddress(HUser32_dll,'EndMenu');

finalization
  FreeLibrary(HUser32_dll);

end.
