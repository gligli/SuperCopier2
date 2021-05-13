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

unit ScSystray;
{
  ScSystray V1.0
   - Support des différents Windows 95 98 Me NT 2000 XP 2003
   - Support de l'unicode
   - Gere les bulles info pour windows 2000 XP et Me
   - Le redémarrage de l'explorer

  Composant de gestion du systray (icone a coté de l'horloge) écrit par [SFX]-ZeuS et [SFX]-Gligli

  Ce composant nécessite le pack TNT composant pour l'unicode
  zeus@sfxteam.org
  gligli@sfxteam.org
  www.sfxteam.org
}

interface

uses
  windows,SysUtils,Classes,messages,Shellapi,graphics,Forms,TntMenus;
Const
   WM_TRAYICON = WM_USER + $2000;
   NIM_SETVERSION = $00000004;
   NIN_BALLOONSHOW = WM_USER + 2;
   NIN_BALLOONHIDE = WM_USER + 3;
   NIN_BALLOONTIMEOUT = WM_USER + 4;
   NIN_BALLOONUSERCLICK = WM_USER + 5;
   NIF_INFO = $10;

   NIIF_NONE =$0; // Icone dans le ballon
   NIIF_INFO = $00000001;
   NIIF_WARNING = $00000002;
   NIIF_ERROR = $00000003;
type

  TIcoBalloon=(IBNone,IBInfo,IBWarning,IBError);
  TWinVer=(Win9x,WinMe,WinNT,Win2kXP);



  TDUMMYUNIONNAME    = record
  case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;
  TNotifyIconDataV5A = record
    cbSize: Cardinal;
    Wnd: HWND;
    uID: Cardinal;
    uFlags: Cardinal;
    uCallbackMessage: Cardinal;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: Cardinal;
    dwStateMask: Cardinal;
    szInfo: array [0..254] of WideChar;
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array [0..63] of WideChar;
    dwInfoFlags: Cardinal;
  end;

  TNotifyIconDataV5W = record
    cbSize: Cardinal;
    Wnd: HWND;
    uID: Cardinal;
    uFlags: Cardinal;
    uCallbackMessage: Cardinal;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: Cardinal;
    dwStateMask: Cardinal;
    szInfo: array [0..254] of WideChar;
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array [0..63] of WideChar;
    dwInfoFlags: Cardinal;
  end;

  TScSystray = class(TComponent)
  private
    { Déclarations privées }
    FBitmapIco: Tbitmap;
    FMaskBitmap: TBitmap;
    FHint:WideString;
    FIcon:TIcon;
    FPopup:TTNTPopupMenu;
    FVisible: Boolean;
    FDblClick:TNotifyEvent;
    FMouseDown:TNotifyEvent;
    FOnBallonShow:TNotifyEvent;
    FOnBallonHide:TNotifyEvent;
    FOnBallonTimeOut:TNotifyEvent;
    FOnBallonClick:TNotifyEvent;
    WM_TASKBARCREATED:Cardinal;// Message
    HIconBmp:HICON;
    procedure SetBitmap(const Value:TBitmap);
    procedure SetHint(const Value:WideString);
    procedure SetIcon(const Value:TIcon);
    procedure SetVisible(const Value:Boolean);

  protected
    { Déclarations protégées }
    SysIconStruc9x:TNotifyIconDataA;     // Structure pour windows 9X                (ne gère pas les bulles ni l'unicode)
    SysIconStrucMe:TNotifyIconDataV5A;   // Structure pour windows ME                (gère les bulles mais pas l'unicode)
    SysIconStrucNt:TNotifyIconDataW;     // Structure pour windows NT 4 et inferieur (ne gère pas les bulles)
    SysIconStruc2kXp:TNotifyIconDataV5W; // Structure pour windows 2000 et >

    procedure HideIcon; // affiche l'icone
    procedure ShowIcon; // masque l'icone
    procedure SysTrayMessages(var Msg: TMessage); message WM_TRAYICON; // procédure de réception des messages de windows

  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent);override; // Initialisation
    destructor Destroy; override; // déstruction
    procedure LoadIconFromFile(Filename:TFileName); // charge une icone a partir d'un fichier
    procedure ShowBalloon(Text:WideString);overload; // Affiche une bulle info dans le systray
    procedure ShowBalloon(Title,Text:WideString);overload;
    procedure ShowBalloon(Title,Text:WideString;IconType:TIcoBalloon);overload;

    property Bitmap:Tbitmap read FBitmapIco write SetBitmap; // charge une icone a partir d'un bitmap
    property Hint:WideString read FHint write SetHint; // Définit le bulle d'aide de l'icone du systray
    property Icone:TIcon read FIcon write SetIcon; // charge une icone a partir d'un Ticon

  published
    { Déclarations publiées }
    property Popup:TTNTPopupMenu read FPopup write FPopup; // PopupMenu associé au clic droit sur l'icone du systray
    property Visible:Boolean read FVisible write SetVisible; // Affiche ou masque l'icone du systray
    property OnDblClick  : TNotifyEvent read FDblClick write FDblClick; // évenement double clic gauche sur l'icone du systray
    property OnMouseDown : TNotifyEvent read FMouseDown write FMouseDown; // évenement clic gauche sur l'icone du systray
    property OnBallonShow : TNotifyEvent read FOnBallonShow write FOnBallonShow; //
    property OnBallonHide : TNotifyEvent read FOnBallonHide write FOnBallonHide; //
    property OnBallonTimeOut : TNotifyEvent read FOnBallonTimeOut write FOnBallonTimeOut; //
    property OnBallonClick : TNotifyEvent read FOnBallonClick write FOnBallonClick; //

  end;

var
    WinVer:TWinVer;
    HndDll:Cardinal;
    ShellNotifyIconA:function (dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL; stdcall;
    ShellNotifyIconW:function (dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL; stdcall;
procedure Register;

implementation
uses Math;

procedure Register;
begin
  RegisterComponents('SFX Team', [TScSystray]);
end;

{ TScSystray }

//##############################################################################
//                             CONSTRUCTOR
//
// But: initialisation du composant choix de la structure selon la platforme
constructor TScSystray.Create(AOwner: TComponent);
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin

    Case Winver of
      Win9x:{WINDOWS 9x}
        begin
          SysIconStruc9x.cbSize:=Sizeof(SysIconStruc9x);
          SysIconStruc9x.Wnd:=AllocateHWnd(SysTrayMessages);
          SysIconStruc9x.uID:=0;
          SysIconStruc9x.uFlags:=NIF_ICON or NIF_MESSAGE or NIF_TIP;
          SysIconStruc9x.hIcon:=0;
          SysIconStruc9x.szTip[0]:=#0;
          SysIconStruc9x.uCallbackMessage:=WM_TRAYICON;
        end;
      WinMe:{WINDOWS Me}
        begin
          SysIconStrucMe.cbSize:=sizeof(SysIconStrucMe);
          SysIconStrucMe.Wnd := AllocateHWnd(SysTrayMessages);
          SysIconStrucMe.uID := 0;
          SysIconStrucMe.uFlags:= NIF_ICON or NIF_MESSAGE or NIF_TIP;
          SysIconStrucMe.uCallbackMessage := WM_TRAYICON;
          SysIconStrucMe.hIcon:=0;
          SysIconStrucMe.szTip[0]:=#0;
          SysIconStrucMe.szInfo[0]:=#0;
          SysIconStrucMe.szInfoTitle[0]:=#0;
        end;
      WinNT:{WINDOWS NT <=4}
        begin
          SysIconStrucNt.cbSize:=Sizeof(SysIconStrucNt);
          SysIconStrucNt.Wnd:=AllocateHWnd(SysTrayMessages);
          SysIconStrucNt.uID:=0;
          SysIconStrucNt.uFlags:=NIF_ICON or NIF_MESSAGE or NIF_TIP;
          SysIconStrucNt.hIcon:=0;
          SysIconStrucNt.szTip[0]:=#0;
          SysIconStrucNt.uCallbackMessage:=WM_TRAYICON;
        end;
      Win2kXP:{WINDOWS 2000 et >}
        begin
          SysIconStruc2kXp.cbSize:=sizeof(SysIconStruc2kXp);
          SysIconStruc2kXp.Wnd := AllocateHWnd(SysTrayMessages);
          SysIconStruc2kXp.uID := 0;
          SysIconStruc2kXp.uFlags:= NIF_ICON or NIF_MESSAGE or NIF_TIP;
          SysIconStruc2kXp.uCallbackMessage := WM_TRAYICON;
          SysIconStruc2kXp.hIcon:=0;
          SysIconStruc2kXp.szTip[0]:=#0;
          SysIconStruc2kXp.szInfo[0]:=#0;
          SysIconStruc2kXp.szInfoTitle[0]:=#0;
        end;
      end;{case}

    HIconBmp:=0;

    WM_TASKBARCREATED:=RegisterWindowMessage('TaskbarCreated');

    // création du masque pour les icônes
    FMaskBitmap:=TBitmap.Create;
    With FMaskBitmap do
    begin
      Width:=16;
      Height:=16;
      Canvas.Brush.Color:=clBlack;
      Canvas.Brush.Style:=bsSolid;
      Canvas.FillRect(Canvas.ClipRect);
      PixelFormat:=pf4bit;
    end;
  end
  else
  begin
    FVisible:=true;
  end;
end;


//##############################################################################
//                            HideIcon
//
// Reçois: Rien
// But: Masque l'icone
procedure TScSystray.HideIcon;
begin
  case WinVer of
    Win9x:   ShellNotifyIconA(NIM_DELETE, @SysIconStruc9x);
    WinMe:   ShellNotifyIconA(NIM_DELETE, @SysIconStrucMe);
    WinNT:   ShellNotifyIconW(NIM_DELETE, @SysIconStrucNT);
    Win2kXP: ShellNotifyIconW(NIM_DELETE, @SysIconStruc2kXp);
  end;
end;


//##############################################################################
//                            ShowIcon
//
// Reçois: Rien
// But: Affiche l'icone
procedure TScSystray.ShowIcon;
begin
  case WinVer of
    Win9x:   ShellNotifyIconA(NIM_ADD, @SysIconStruc9x);
    WinMe:   ShellNotifyIconA(NIM_ADD, @SysIconStrucMe);
    WinNT:   ShellNotifyIconW(NIM_ADD, @SysIconStrucNT);
    Win2kXP: ShellNotifyIconW(NIM_ADD, @SysIconStruc2kXp);
  end;
end;

//##############################################################################
//                            LoadIconFromFile
//
// Reçois: Tfilename chemin de l'icone à charger
// But: Charger une icone àpartir d'un fichier ico
procedure TScSystray.LoadIconFromFile(Filename: TFileName);
var
  Icon:TIcon;
begin
  Icon:=TIcon.Create;
  Icon.LoadFromFile(Filename);
  SetIcon(Icon);
  Icon.Free;
end;

//##############################################################################
//                            SetBitmap
//
// Reçois: Un TBitmap
// But: Créer une icone pour le systray à partir d'un Tbitmap et change l'icone
procedure TScSystray.SetBitmap(const Value: TBitmap);
var
  IconBmp:TIconInfo;
begin
  FBitmapIco:=Value;

  with IconBmp do
  begin
    fIcon:=true;
    xHotspot:=0;
    yHotspot:=0;
    hbmMask:=FMaskBitmap.Handle;
    hbmColor:=FBitmapIco.Handle;
  end;

  if HIconBmp<>0 then DestroyIcon(HIconBmp);
  HIconBmp:=CreateIconIndirect(IconBmp);

  case WinVer of // Selon les versions de windows
    Win9x:
      begin
        SysIconStruc9x.hIcon:=HIconBmp;
        if FVisible then
          ShellNotifyIconA(NIM_MODIFY, @SysIconStruc9x);
      end;
    WinMe:
      begin
        SysIconStrucMe.hIcon:=HIconBmp;
        SysIconStrucMe.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
        if FVisible then
          ShellNotifyIconA(NIM_MODIFY, @SysIconStrucMe);
      end;
    WinNT:
      begin
        SysIconStrucNt.hIcon:=HIconBmp;
        if FVisible then
          ShellNotifyIconW(NIM_MODIFY, @SysIconStrucNt)
      end;
    Win2kXP:
      begin
        SysIconStruc2kXp.hIcon:=HIconBmp;
        SysIconStruc2kXp.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
        if FVisible then
          ShellNotifyIconW(NIM_MODIFY, @SysIconStruc2kXp)
      end;
  end;
end;

//##############################################################################
//                            SetIcon
//
// Reçois: un Ticon
// But: Change ou affecte la nouvelle icone au systray
procedure TScSystray.SetIcon(const Value: TIcon);
begin
  If Value<>FIcon then
  begin
    if FIcon=nil then FIcon:=TIcon.create;
    FIcon.Assign(Value);

    case WinVer of // Selon les versions de windows
      Win9x:
        begin
          SysIconStruc9x.hIcon:=FIcon.Handle;
          if FVisible then
            ShellNotifyIconA(NIM_MODIFY, @SysIconStruc9x);
        end;
      WinMe:
        begin
          SysIconStrucMe.hIcon:=FIcon.Handle;
          SysIconStrucMe.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
          if FVisible then
            ShellNotifyIconA(NIM_MODIFY, @SysIconStrucMe);
        end;
      WinNT:
        begin
          SysIconStrucNt.hIcon:=FIcon.Handle;
          if FVisible then
            ShellNotifyIconW(NIM_MODIFY, @SysIconStrucNt)
        end;
      Win2kXP:
        begin
          SysIconStruc2kXp.hIcon:=FIcon.Handle;
          SysIconStruc2kXp.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
          if FVisible then
            ShellNotifyIconW(NIM_MODIFY, @SysIconStruc2kXp)
        end;
      end;

  end;
end;

//##############################################################################
//                              SetVisible
//
// Reçois: un boolean
// But: Afficher ou masquer l'icone du systray
procedure TScSystray.SetVisible(const Value: Boolean);
begin
  if Value<>FVisible then
  begin
    FVisible:=Value;
    if not (csDesigning in ComponentState) then
    begin
      if FVisible then
        ShowIcon
      else
        HideIcon;
    end;
  end;
end;

//##############################################################################
//                              SysTrayMessages
//
//  Reçois: Tmessage
//  But: procédure de réception des messages windows
procedure TScSystray.SysTrayMessages(var Msg: TMessage);
var
  MousePos:TPoint;
begin
  //********** Redémarrage de l'explorateur ************************************
  if (Msg.Msg=WM_TASKBARCREATED) and FVisible then
  begin
    case WinVer of
      Win9x:   ShellNotifyIconA(NIM_ADD, @SysIconStruc9x);
      WinMe:   ShellNotifyIconA(NIM_ADD, @SysIconStrucMe);
      WinNT:   ShellNotifyIconW(NIM_ADD, @SysIconStrucNT);
      Win2kXP: ShellNotifyIconW(NIM_ADD, @SysIconStruc2kXp);
    end;
  end
  //----------------------------------------------------------------------------

  //********** GESTIOON DES MESSAGES SOURIS SUR LE SYSTRAY *********************
  else If Msg.Msg=WM_TRAYICON then // Traitement des messages du Systray
  begin
    case Msg.LParam of
      WM_LBUTTONDOWN: if Assigned(FMouseDown) then FMouseDown(Self);

      WM_LBUTTONDBLCLK:
        begin
          case WinVer of
            Win9x:   SetForegroundWindow(SysIconStruc9x.Wnd);
            WinMe:   SetForegroundWindow(SysIconStrucMe.Wnd);
            WinNT:   SetForegroundWindow(SysIconStrucNt.Wnd);
            Win2kXP: SetForegroundWindow(SysIconStruc2kXp.Wnd);
          end;
          if Assigned(FDblClick) then FDblClick(Self);
        end;

      WM_RBUTTONDOWN:
        begin
          if Assigned(FPopup) then
          begin
            GetCursorPos(MousePos); // récupère la position du curseur
            case WinVer of
              Win9x:   SetForegroundWindow(SysIconStruc9x.Wnd);
              WinMe:   SetForegroundWindow(SysIconStrucMe.Wnd);
              WinNT:   SetForegroundWindow(SysIconStrucNt.Wnd);
              Win2kXP: SetForegroundWindow(SysIconStruc2kXp.Wnd);
            end;
            {permet au popup de se cacher tout seul}
            FPopup.PopupComponent := Self;
            FPopup.Popup(MousePos.X, MousePos.Y);
            case WinVer of
              Win9x:   PostMessage(SysIconStruc9x.Wnd, WM_NULL, 0, 0);
              WinMe:   PostMessage(SysIconStrucMe.Wnd, WM_NULL, 0, 0);
              WinNT:   PostMessage(SysIconStrucNt.Wnd, WM_NULL, 0, 0);
              Win2kXP: PostMessage(SysIconStruc2kXp.Wnd, WM_NULL, 0, 0);
            end;
          end;
        end;

      WM_MOUSEMOVE:;
      WM_LBUTTONUP:;
      WM_RBUTTONUP:;
      WM_RBUTTONDBLCLK:;
      NIN_BALLOONSHOW:if Assigned(FOnBallonShow) then FOnBallonShow(Self);
      NIN_BALLOONHIDE:begin
                        if not FVisible then
                        case WinVer of
                          WinMe : ShellNotifyIconA(NIM_DELETE, @SysIconStrucMe);
                          Win2kXP: ShellNotifyIconW(NIM_DELETE, @SysIconStruc2kXp);
                        end;
                        if Assigned(FOnBallonHide) then FOnBallonHide(Self);
                      end;
      NIN_BALLOONTIMEOUT:if Assigned(FOnBallonTimeOut) then FOnBallonTimeOut(Self);
      NIN_BALLOONUSERCLICK:if Assigned(FOnBallonClick) then FOnBallonClick(Self);
     end;
  end;
  //----------------------------------------------------------------------------

  msg.Result:=1;
end;

//##############################################################################
//                                 SetHint
//
// Recois : String coresspondant au hint à afficher
// But: Change le Hint de l'icone du systray
procedure TScSystray.SetHint(const Value: WideString);
var
  size:integer;
  TmpStr:String;
begin
  if Value<>FHint then
  begin
    FHint:=value;
    case WinVer of
      Win9x:
        begin
          TmpStr:=WideCharToString(PWidechar(Value));
          size:=length(Fhint);
          if size>63 then size:=63;
          move(TmpStr[1],SysIconStruc9x.szTip,size+1);
          SysIconStruc9x.szTip[63]:=#0;
          if FVisible then
            ShellNotifyIconA(NIM_MODIFY, @SysIconStruc9x);
        end;
      WinMe:
        begin
          TmpStr:=WideCharToString(@Value);
          size:=length(Fhint);
          if size>127 then size:=127;
          move(TmpStr[1],SysIconStrucMe.szTip,size+1);
          SysIconStrucMe.szTip[127]:=#0;
          if FVisible then
            ShellNotifyIconA(NIM_MODIFY, @SysIconStrucMe);
        end;
      WinNT:
        begin
          size:=length(FHint);
          if size>63 then size:=63; // vérifie la taille de la chaine
          Move(FHint[1],SysIconStrucNt.szTip,size*2+2); // copie la widestring
          SysIconStrucNt.szTip[63]:=#0;  // marque le caractère de terminaison
          if FVisible then
            ShellNotifyIconW(NIM_MODIFY, @SysIconStrucNt);
        end;
      Win2kXP:
        begin
          Size:=length(FHint);
          if size>127 then size:=127; // vérifie la taille de la chaine
          Move(FHint[1],SysIconStruc2kXp.szTip,size*2+2); // copie la widestring
          SysIconStruc2kXp.szTip[127]:=#0; // marque le caractère de terminaison
          SysIconStruc2kXp.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
          if FVisible then
            ShellNotifyIconW(NIM_MODIFY, @SysIconStruc2kXp);
        end;
    end;{fin de case}
  end;
end;

//##############################################################################
//                                 ShowBalloon
//
// Recois : une string ou 2 string ou 2 string et un IconType
// But: Affiche une bulle info a partir du systray ces fonctions ne sont valide
// que pour windows 2000 et >
procedure TScSystray.ShowBalloon(Text: WideString);
begin
  ShowBalloon('',Text,IBNone);
end;

procedure TScSystray.ShowBalloon(Title,Text: WideString);
begin
  ShowBalloon(Title,Text,IBNone);
end;

procedure TScSystray.ShowBalloon(Title,Text: WideString; IconType: TIcoBalloon);
var
  Size:integer;
  TmpStr:String;
begin

  {Seulement valable pour windows 2000/Me et >}
//  if (FVisible)then
//  begin
    case WinVer of
      WinMe :
        begin
          {titre}
          TmpStr:=WideCharToString(PWideChar(Title));
          size:=length(Fhint);
          if size>63 then size:=63;
          move(TmpStr[1],SysIconStrucMe.szInfoTitle,size+1);
          SysIconStrucMe.szInfoTitle[63]:=#0;
          {texte}
          TmpStr:=WideCharToString(PWideChar(Text));
          size:=length(Fhint);
          if size>254 then size:=254;
          move(TmpStr[1],SysIconStrucMe.szInfo,size+1);
          SysIconStrucMe.szInfo[254]:=#0;
          SysIconStrucMe.uCallbackMessage := WM_TRAYICON;
          {icon}
          case IconType of
            IBNone:     SysIconStrucMe.dwInfoFlags:=NIIF_NONE;
            IBInfo:     SysIconStrucMe.dwInfoFlags:=NIIF_INFO;
            IBWarning:  SysIconStrucMe.dwInfoFlags:=NIIF_WARNING;
            IBError:    SysIconStrucMe.dwInfoFlags:=NIIF_ERROR;
          end;
          SysIconStrucMe.uFlags:=NIF_INFO;
          SysIconStrucMe.DUMMYUNIONNAME.uTimeout:=500;
          if FVisible then  ShellNotifyIconW(NIM_MODIFY, @SysIconStrucMe) else ShellNotifyIconW(NIM_ADD, @SysIconStrucMe)
        end;
      Win2kXP:
        begin
          SysIconStruc2kXp.szInfo[0]:=#0;
          SysIconStruc2kXp.szInfoTitle[0]:=#0;
          Size:=length(Text);
          if size>254 then size:=254;
            Move(Text[1],SysIconStruc2kXp.szInfo,size*2+2);
          SysIconStruc2kXp.szInfo[254]:=#0;

          Size:=length(Title);
          if size>63 then size:=63;
            Move(Title[1],SysIconStruc2kXp.szInfoTitle,size*2+2);
          SysIconStruc2kXp.szInfoTitle[63]:=#0;
          SysIconStruc2kXp.uCallbackMessage := WM_TRAYICON;
         case IconType of
            IBNone:     SysIconStruc2kXp.dwInfoFlags:=NIIF_NONE;
            IBInfo:     SysIconStruc2kXp.dwInfoFlags:=NIIF_INFO;
            IBWarning:  SysIconStruc2kXp.dwInfoFlags:=NIIF_WARNING;
            IBError:    SysIconStruc2kXp.dwInfoFlags:=NIIF_ERROR;
          end;
          SysIconStruc2kXp.uFlags:=NIF_INFO;
          SysIconStruc2kXp.DUMMYUNIONNAME.uTimeout:=500;
          if FVisible then  ShellNotifyIconW(NIM_MODIFY, @SysIconStruc2kXp) else ShellNotifyIconW(NIM_ADD, @SysIconStruc2kXp)
      end;
    end;{fin case}
  //end;
end;

//##############################################################################
//                             DESTRUCTOR
//
// But: Libération de la mémoire supression de la fenêtre invisble des messages
destructor TScSystray.Destroy; // Libération du systray
begin
  if FVisible then HideIcon; // enlève l'icone du systray
  if FIcon<>nil then FreeAndNil(FIcon); // libération de l'icone
  if FMaskBitmap<>nil then FreeAndNil(FMaskBitmap);
  if HIconBmp<>0 then DestroyIcon(HIconBmp);

  Case WinVer of {déstruction de la fenêtre des messages}
    Win9x:   DeallocateHWnd(SysIconStruc9x.wnd);
    WinMe:   DeallocateHWnd(SysIconStrucMe.wnd);
    WinNT:   DeallocateHWnd(SysIconStrucNt.wnd);
    Win2kXP: DeallocateHWnd(SysIconStruc2kXp.wnd);
  end;
  inherited;
end;
initialization
    {détermine la version de Windows}
    if Win32Platform=VER_PLATFORM_WIN32_NT then
    begin
      if Win32MajorVersion>4 then
        WinVer:=Win2kXP
      else
        WinVer:=WinNT;
    end else
    begin
      if (Win32MajorVersion=4) and (Win32MinorVersion=9) then
        WinVer:=WinMe
      else
        WinVer:=Win9x;
    end;

    HndDll:=LoadLibraryA(shell32);
    if HndDll<>0 then
      case Winver of
        Win9x,WinMe: ShellNotifyIconA:=GetProcAddress(HndDll,'Shell_NotifyIconA');
        WinNT,Win2kXp: ShellNotifyIconW:=GetProcAddress(HndDll,'Shell_NotifyIconW');
      end;

Finalization
  if HndDll<>0 then
    FreeLibrary(HndDll);


end.

