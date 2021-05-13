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

{$WARN SYMBOL_DEPRECATED OFF}

unit SCTitleBarBt;
// ce composant à été développé a partir du composant TWidget de Robert R. Marsh, SJ (rrm@sprynet.com)
interface

uses
  Windows,SysUtils,Classes,Controls,Messages,Forms,Themes;

Const
  WM_REPAINTSCTBB=WM_USER+$1F;
  WM_RECALCSIZE=WM_USER+$20;
type
  TWndProc=Pointer;
  TBtStatus=(bsNormal,bsOver,bsPressed,bsDisabled);

  TSCTitleBarBt = class(TComponent)
  private
    { Déclarations privées }
    OldWndProc:TWndProc; // On accroche le windows proc de la form.
    NewWndProc:TWndProc;
    TitleBarBtArea:TRect;  // Zone où le bouton doit etre situé.
    BtStatus:TBtStatus;

    FOnClick : TNotifyEvent;
    procedure CalculZoneBt;
  protected
    { Déclarations protégées }
    procedure WMEvent(var msg : TMessage);
    procedure DrawTitleBarBt;
  public
    { Déclarations publiques }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Refresh;
  published
    { Déclarations publiées }
    property OnClick : TNotifyEvent Read FOnClick Write FOnClick;
  end;

procedure Register;

implementation

uses Math, Types;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCTitleBarBt]);
end;

{ TSCTitleBarBt }

constructor TSCTitleBarBt.Create(AOwner: TComponent);
begin
  if (AOwner = nil) or not (AOwner is TForm) then
    raise Exception.Create('Le parent d''un SCTitleBarBt doit être une Form');
  inherited;
  NewWndProc := MakeObjectInstance(WMEvent);
  OldWndProc := pointer(SetWindowLong((Owner as Tform).Handle, gwl_WndProc, longint(NewWndProc)));
  CalculZoneBt;
  BtStatus:=bsNormal;
end;

destructor TSCTitleBarBt.Destroy;
begin
 // enlever la redirectionde la window proc
  inherited Destroy;
end;

procedure TSCTitleBarBt.CalculZoneBt;
var
  xframe : integer;
  yFrame : integer;
  xsize : integer;
  ysize : integer;
  Icons : TBorderIcons;
  Style : TFormBorderStyle;
  Ecart:integer;
begin
  xsize:=0;
  ysize:=0;
  xframe:=0;
  yFrame:=0;
  Ecart:=8;
  if (Owner as TForm) = nil then
    exit;
  with (Owner as TForm) do
  begin
    if (csDesigning in ComponentState) then
    begin
      Icons := [biSystemMenu, biMinimize, biMaximize];
      Style := bsSizeable;
    end
    else
    begin
      Icons := BorderIcons;
      Style := BorderStyle;
    end;
    if Style in [bsSizeToolWin, bsToolWindow] then
    begin
      Ecart:=2;
      if Style = bsToolWindow then
        xframe := GetSystemMetrics(SM_CXFIXEDFRAME)
      else
        xframe := GetSystemMetrics(SM_CXSIZEFRAME);
      if biSystemMenu in Icons then
        inc(xframe, GetSystemMetrics(SM_CXSMSIZE));
      if Style = bsToolWindow then
        yframe := GetSystemMetrics(SM_CYFIXEDFRAME)
      else
        yframe := GetSystemMetrics(SM_CYSIZEFRAME);
      ysize := GetSystemMetrics(SM_CYSMSIZE);
      xsize := GetSystemMetrics(SM_CXSMSIZE);
    end
    else
    begin
      if Style in [bsSingle, bsSizeable, bsDialog] then
      begin
        if Style = bsSingle then
          xframe := GetSystemMetrics(SM_CYFIXEDFRAME)
        else
          xframe := GetSystemMetrics(SM_CXSIZEFRAME);
        if biSystemMenu in Icons then
        begin
          inc(xframe, GetSystemMetrics(SM_CXSIZE));
          if (Style <> bsDialog) and (Icons * [biMinimize, biMaximize] <> []) then
            inc(xframe, GetSystemMetrics(SM_CXSIZE) * 2)
          else
            if biHelp in Icons then
              inc(xframe, GetSystemMetrics(SM_CXSIZE));
        end;
        if Style in [bsSingle, bsDialog] then
          yframe := GetSystemMetrics(SM_CYFIXEDFRAME)
        else
          yframe := GetSystemMetrics(SM_CYSIZEFRAME);
        ysize := GetSystemMetrics(SM_CYSIZE);
        xsize := GetSystemMetrics(SM_CXSIZE);
      end;
    end;
    if ThemeServices.ThemesEnabled then
      TitleBarBtArea := Bounds(Width - xFrame - xSize + Ecart , yFrame + 2, xSize - 4, ySize - 4)
    else
      TitleBarBtArea := Bounds(Width - xFrame - xSize + 2 , yFrame + 2, xSize - 2, ySize - 4)
  end;
end;

//---- Dessin du bouton
procedure TSCTitleBarBt.DrawTitleBarBt;
var
  Details: TThemedElementDetails;
  DC:HDC;
begin
  DC:= GetWindowDC((Owner as Tform).Handle);
  if ThemeServices.ThemesEnabled then // Si le theme est activé
  begin
    Case BtStatus of
      bsNormal:
          Details := ThemeServices.GetElementDetails(twMinButtonNormal);
      bsOver :
          Details := ThemeServices.GetElementDetails(twMinButtonHot);
      bsPressed :
          Details := ThemeServices.GetElementDetails(twMinButtonPushed);
      bsDisabled : ;
    end;
    ThemeServices.DrawElement(DC,Details,TitleBarBtArea);
  end
  else // dessin manuel du bouton (pas de theme)
  begin
   Case BtStatus of
      bsNormal,bsOver:
           DrawFrameControl(DC, TitleBarBtArea, DFC_CAPTION	, DFCS_CAPTIONMIN	);
      bsPressed :
           DrawFrameControl(DC, TitleBarBtArea, DFC_CAPTION, DFCS_CAPTIONMIN or DFCS_PUSHED);
      bsDisabled : ;
    end;
  end;
  ReleaseDC((Owner as TForm).Handle,DC);
end;

//---- detournement des messages pour les traiter avant la fenêtre
procedure TSCTitleBarBt.WMEvent(var msg: TMessage);
    function InArea(InClient : boolean) : boolean;
    var
        p : TPoint;
    begin
       p.X := Msg.lParamLo;
       p.Y := smallint(Msg.lParamHi);
       if InClient then
         ClientToScreen(TForm(Owner).Handle, p);
       dec(p.X, TForm(Owner).Left);
       dec(p.Y, TForm(Owner).Top);
       Result := PtInRect(TitleBarBtArea, p);
    end;
begin
  case Msg.Msg of
     WM_NCLBUTTONDOWN, WM_NCLBUTTONDBLCLK :
      begin
        if InArea(false) then
        begin
          SetCapture(TForm(Owner).Handle);
          BtStatus:=bsPressed;
          PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);//DrawTitleBarBt;
          Msg.Result := 1;
        end
        else
          msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
      end;

     WM_LBUTTONUP, WM_LBUTTONDBLCLK:
        begin
          if BtStatus=bsPressed then
          begin
            if InArea(true) then
            begin
               BtStatus:=bsOver;
               if Assigned(FOnClick) then FOnClick(Self);
            end
            else
            begin
              BtStatus:=bsNormal;
            end;
            PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);//DrawTitleBarBt;
            msg.Result := 1;
          end
          else
             msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
          ReleaseCapture;
       end;

    WM_NCMOUSEMOVE :
          begin
            if InArea(true) then
            begin
              if (BtStatus<>bsPressed) and (BtStatus<>bsOver) then
              begin
                BtStatus:=bsOver;
                PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);//DrawTitleBarBt;
                Msg.Result := 1;
              end
            end
            else
            begin
              if (BtStatus=bsPressed) or (BtStatus=bsOver) then
              begin
                BtStatus:=bsNormal;
                PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);//DrawTitleBarBt;
              end;
              Msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
            end;
          end;

    WM_MOUSEMOVE:
        begin
          if not InArea(true) then
          begin
            if (BtStatus=bsPressed) or (BtStatus=bsOver) then
            begin
              BtStatus:=bsNormal;
              PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);//DrawTitleBarBt;
            end;
          end;
          msg.Result:=CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
        end;

    WM_PAINT,WM_NCPAINT,WM_NCACTIVATE:
        begin
          msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
          PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);
          // on fait appel a un message pour dessiner car sinon on dessine avant que la barre ne soit redessiné
          DrawTitleBarBt;
        end;
    WM_REPAINTSCTBB:
        begin
          DrawTitleBarBt;
        end;

    WM_SIZE,WM_WINDOWPOSCHANGED,WM_WINDOWPOSCHANGING,WM_SETTINGCHANGE,WM_STYLECHANGED,WM_NCCALCSIZE:
        begin
          msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
          CalculZoneBt;
          PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);
        end;

    WM_THEMECHANGED:
        begin
          ThemeServices.UpdateThemes;
          msg.Result:=1;
          PostMessage((Owner as TForm).Handle, WM_RECALCSIZE,0,0);
          PostMessage((Owner as TForm).Handle, WM_REPAINTSCTBB,0,0);
        end;

    WM_RECALCSIZE:
        begin
          CalculZoneBt;
        end;
   else
    msg.Result := CallWindowProc(OldWndProc, (Owner as TForm).Handle, msg.Msg, msg.wParam, msg.lParam);
  end;
end;


procedure TSCTitleBarBt.Refresh;
begin
  NewWndProc := MakeObjectInstance(WMEvent);
  OldWndProc := pointer(SetWindowLong((Owner as Tform).Handle, gwl_WndProc, longint(NewWndProc)));
  CalculZoneBt;
end;

end.
