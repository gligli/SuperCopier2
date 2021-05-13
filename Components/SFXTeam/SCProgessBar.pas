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

unit SCProgessBar;

interface

uses
  Windows,Controls,Messages,SysUtils,Classes,Graphics,TntWindows;

type

  TSCProgessBar = class(TGraphicControl)
  private
    { Déclarations privées }
    FBorderColor:TColor;
    FFrontColor1:TColor;
    FFrontColor2:TColor;
    FBackColor1:TColor;
    FBackColor2:TColor;
    FFontProgress:TFont;
    FFontProgressColor:TColor;
    FMax:Int64;
    FMin:Int64;
    FPosition:Int64;
    FFontTxtColor: TColor;
    FFontTxt: TFont;
    FTimeRemaining:Widestring;
    FFrontColorPalette:Array of TColor;
    FBackColorPalette:Array of TColor;

    TmpBmp:Tbitmap;
    DoitRepeindre:Boolean;
    WidthProgress,PourcentProgress:Integer;

    Procedure SetBorderColor(const Value:TColor);
    Procedure SetFrontColor1(const Value:TColor);
    Procedure SetFrontColor2(const Value:TColor);
    Procedure SetBackColor1(const Value:TColor);
    Procedure SetBackColor2(const Value:TColor);
    Procedure SetFontProgressColor(const Value:TColor);
    Procedure SetFontProgress(const Value:TFont);
    Procedure SetFontTxtColor(const Value:TColor);
    Procedure SetFontTxt(const Value:TFont);
    Procedure SetMax(const Value:Int64);
    Procedure SetMin(const Value:Int64);
    Procedure SetPosition(const Value:Int64);
    Procedure SetTimeRemaining(const Value:WideString);
    Procedure ResizeMsg(var Message:TWMWindowPosChanging);message WM_WINDOWPOSCHANGED;
    Procedure CalculPalette;

    Procedure RecreerTmpBmp;
    Procedure CalculPourcent;
  protected
    { Déclarations protégées }
    procedure Paint;override;
  public
    { Déclarations publiques }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    Procedure SetAvancement(Position:Int64;TimeRemaining:WideString);
  published
    { Déclarations publiées }
    property Anchors;
    property BorderColor:TColor read FBorderColor write SetBorderColor;
    property FrontColor1:TColor read FFrontColor1 write SetFrontColor1;
    property FrontColor2:TColor read FFrontColor2 write SetFrontColor2;
    property BackColor1:TColor read FBackColor1 write SetBackColor1;
    property BackColor2:TColor read FBackColor2 write SetBackColor2;
    property FontProgress:TFont read FFontProgress write SetFontProgress;
    property FontProgressColor:TColor read FFontProgressColor write SetFontProgressColor;
    property FontTxt:TFont read FFontTxt write SetFontTxt;
    property FontTxtColor:TColor read FFontTxtColor write SetFontTxtColor;
    property Max:Int64 read FMax write SetMax;
    property Min:Int64 read FMin write SetMin;
    property Position:Int64 read FPosition write SetPosition;
    property TimeRemaining:Widestring read FTimeRemaining write SetTimeRemaining;
    //property Height:Integer read FHeight write SetHeight;
  end;

procedure Register;

implementation

uses Types;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCProgessBar]);
end;

{ TSCProgessBar }

//##############################################################################
//                            CREATE
//
// Reçois: AOwner
// But: Création du composant et initialisation
constructor TSCProgessBar.Create(AOwner: TComponent);
begin
  inherited;

  FMin:=0; // Valeur mini de la progressbar
  Fmax:=100; // valeur max de la progressbar

  TmpBmp:=nil;
  RecreerTmpBmp;
  CalculPourcent;

  ControlStyle := [csOpaque,csFramed];
  Height:=15;
  Width:=200;
  FFontProgress:=TFont.Create;
  FFontTxt:=TFont.Create;
  FFontProgress.Color:=clWhite;
  FFontTxt.Color:=clWhite;
  Self.Constraints.MinHeight:=10;  // on limite la taille mini
  Self.Constraints.MinWidth:=10;
  FPosition:=0; // Fposition est la position de l progressbar par rapport a Fmax
  FFrontColor1:=clNavy;
  FFrontColor2:=clCream;
  FBackColor1:=$00685758;
  FBackColor2:=clWhite;
  FFontProgressColor:=clBlack;
  FFontTxtColor:=clBlack;
  CalculPalette;
  Invalidate;
end;

destructor TSCProgessBar.Destroy;
begin
  SetLength(FFrontColorPalette,0);
  SetLength(FBackColorPalette,0);
  FFontProgress.Free;
  FFontTxt.Free;

  TmpBmp.Free;

  inherited;
end;

//##############################################################################
//                            Paint
//
// Reçois: Rien
// But: Dessine la progressbar
procedure TSCProgessBar.Paint;
Const
  MargeDroite=8;
  DT_TEXTPERSO=DT_CENTER+DT_VCENTER+DT_SINGLELINE;
var
  Y:Integer;
  Textsize:TSize;
  TxtRect,TxtRectB:TRect;
  PourcentProgressStr:String;
begin
  if DoitRepeindre then
  begin
    DoitRepeindre:=False;

    With TmpBmp.Canvas do
    begin
      {dessine la progress bar}

      for y:=0 to TmpBmp.Height-1 do
      begin
        pen.Color:=FFrontColorPalette[Y];
        MoveTo(0,y);
        LineTo(WidthProgress,y);
        pen.Color:=FBackColorPalette[Y];
        MoveTo(WidthProgress,y);
        LineTo(TmpBmp.Width,y);
      end;

      {Dessine le % de progression et la widestring}

      Font:=FFontProgress;
      PourcentProgressStr:=IntToStr(PourcentProgress)+' %';
      GetTextExtentPoint32(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),Textsize);
      Brush.Style:=bsClear;
      //on dessine le contoure du texte
      Font.Color:=FFontProgressColor;
      With TxtRect do
      begin
        Left:=(TmpBmp.Width div 2)-(Textsize.cx div 2)-1 ;
        Top:=(TmpBmp.Height Div 2)-(Textsize.Cy+2) div 2;
        Right:=left+Textsize.cx+2;
        Bottom:=Top+Textsize.cy+2;
        TxtRectB:=Rect(left-1,Top-1,Right-1,Bottom-1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top+1,Right+1,Bottom+1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left-1,Top+1,Right-1,Bottom+1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top-1,Right+1,Bottom-1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left,Top-1,Right,Bottom-1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left-1,Top,Right-1,Bottom);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left,Top+1,Right,Bottom+1);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top,Right+1,Bottom);
        DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRectB,DT_TEXTPERSO);
      end;
      // on dessine le texte
      Font.Color:=FFontProgress.Color;
      DrawText(Handle,PChar(PourcentProgressStr),length(PourcentProgressStr),TxtRect,DT_TEXTPERSO);

      Font:=FFontTxt;
      if Win32Platform=VER_PLATFORM_WIN32_NT then
        GetTextExtentPoint32W(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),Textsize)
      else
        GetTextExtentPoint32(Handle,PChar(String(FTimeRemaining)),length(FTimeRemaining),Textsize);

      Brush.Style:=bsClear;
      Font.Color:=FFontTxtColor;
      With TxtRect do
      begin
        Left:=TmpBmp.Width-(Textsize.cx+2)-MargeDroite;
        Top:=(TmpBmp.Height Div 2)-(Textsize.Cy+2) div 2;
        Right:=left+Textsize.cx+2;
        Bottom:=Top+Textsize.cy+2;
        TxtRectB:=Rect(left-1,Top-1,Right-1,Bottom-1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top+1,Right+1,Bottom+1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left-1,Top+1,Right-1,Bottom+1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top-1,Right+1,Bottom-1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left,Top-1,Right,Bottom-1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left-1,Top,Right-1,Bottom);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left,Top+1,Right,Bottom+1);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
        TxtRectB:=Rect(left+1,Top,Right+1,Bottom);
        Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRectB,DT_TEXTPERSO);
      end;
      Font.Color:=FFontTxt.Color;
      Tnt_DrawTextW(Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRect,DT_TEXTPERSO);

      {dessine le cadre}
      Pen.Color:=FBorderColor;
      Brush.Style:=bsClear;
      Rectangle(0,0,Width,height);
    end;
  end;

  {dessine sur le composant}
  Canvas.Draw(0,0,TmpBmp);
end;

//##############################################################################
//                            CalculPalette
//
// Reçois: Rien
// But: Calcul le dégradé de couleur, lors d'un changement de couleur ou resize en hauteur
procedure TSCProgessBar.CalculPalette;
    procedure ColorToRVB(Color:TColor;var R,V,B:Integer);
    begin
      R:=Color and $000000FF;
      V:=(Color and $0000FF00) shr 8;
      B:=(Color and $00FF0000) shr 16;
    end;
var
  y:Integer;
  R1,V1,B1,R2,V2,B2:Integer;
  R1b,V1b,B1b,R2b,V2b,B2b:Integer;
begin
  SetLength(FFrontColorPalette,Height);
  SetLength(FBackColorPalette,Height);
  ColorToRVB(FFrontColor1,R1,V1,B1);
  ColorToRVB(FFrontColor2,R2,V2,B2);
  ColorToRVB(FBackColor1,R1b,V1b,B1b);
  ColorToRVB(FBackColor2,R2b,V2b,B2b);
  for y:=0 to (Height div 2) do
  begin
    {Couleur d'avant plan}
    FFrontColorPalette[y]:=RGB((R1+ MulDiv(y,R2-R1,Height)) mod 256,
                               (V1+ MulDiv(y,V2-V1,Height)) mod 256,
                               (B1+ MulDiv(y,B2-b1,Height)) mod 256);
    FFrontColorPalette[Height-Y-1]:=FFrontColorPalette[y];
    {Couleur d'arrière plan}
    FBackColorPalette[y]:=RGB( (R1b+ MulDiv(y,R2b-R1b,Height)) mod 256,
                               (V1b+ MulDiv(y,V2b-V1b,Height)) mod 256,
                               (B1b+ MulDiv(y,B2b-B1b,Height)) mod 256);
    FBackColorPalette[Height-Y-1]:=FBackColorPalette[y];
  end;
end;

//##############################################################################
//                            RecreerTmpBmp
//
//
//
//
procedure TSCProgessBar.RecreerTmpBmp;
begin
  if TmpBmp<>nil then TmpBmp.Free;

  TmpBmp:=TBitmap.Create;
  TmpBmp.Width:=Width;
  TmpBmp.Height:=Height;
  TmpBmp.PixelFormat:=pfDevice;

  DoitRepeindre:=True;
end;

//##############################################################################
//                            CalculPourcent
//
//
//
//
procedure TSCProgessBar.CalculPourcent;
var PP,WP:Integer;
begin
  PP:=(FPosition*100) div FMax;
  WP:=(FPosition*Width) div FMax;

  if (PP<>PourcentProgress) or (WP<>WidthProgress) then
  begin
    PourcentProgress:=PP;
    WidthProgress:=WP;

    DoitRepeindre:=True;
  end;
end;

//##############################################################################
//                            SetAvancement
//
// Reçois: Reçois Position entier sur 64bit et TimeRemaining une widestring
// But: définir la position de la trackbar et le texte à afficher
//      celà permet de faire un seul repaint en entrant deux informations
procedure TSCProgessBar.SetAvancement(Position: Int64;
  TimeRemaining: WideString);
var Modified:Boolean;
begin
   Modified:=False;

   If (Position<>FPosition) and (Position<=FMax) and (Position>=Fmin) then
   begin
     FPosition:=Position;
     Modified:=True;
   end;

   if (TimeRemaining<>FTimeRemaining) then
   begin
     FTimeRemaining:=TimeRemaining;
     Modified:=True;
   end;

   if Modified then
   begin
     CalculPourcent;
     Invalidate;
   end;
end;

//##############################################################################
//                            Resize
//
// Reçois: Rien
// But: Appeler lors du resize de la progressbar il permet de recalculer la palette
//      qui change lorsque la hauteur de la progressbar change
procedure TSCProgessBar.ResizeMsg(var Message: TWMWindowPosChanging);
begin
  inherited;

  CalculPalette;
  RecreerTmpBmp;
  CalculPourcent;
  Message.Result:=1;
end;


//--------------------- Definition des propriétés ------------------------------
procedure TSCProgessBar.SetBorderColor(const Value: TColor);
begin
  If Value<>FBorderColor then
  begin
    FBorderColor:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;


procedure TSCProgessBar.SetBackColor1(const Value: TColor);
begin
  if Value<>FBackColor1 then
  begin
    FBackColor1:=Value;
    DoitRepeindre:=True;
    CalculPalette;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetBackColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FBackColor2:=Value;
    DoitRepeindre:=True;
    CalculPalette;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFrontColor1(const Value: TColor);
begin
  if value<>FFrontColor1 then
  begin
    FFrontColor1:=Value;
    DoitRepeindre:=True;
    CalculPalette;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFrontColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FFrontColor2:=Value;
    DoitRepeindre:=True;
    CalculPalette;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontProgress(const Value: TFont);
begin
  if value<>FFontProgress then
  begin
    FFontProgress:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontProgressColor(const Value: TColor);
begin
  if value<>FFontProgressColor then
  begin
    FFontProgressColor:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontTxt(const Value: TFont);
begin
  if value<>FFontProgress then
  begin
    FFontTxt:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontTxtColor(const Value: TColor);
begin
  if value<>FFontTxtColor then
  begin
    FFontTxtColor:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetTimeRemaining(const Value: WideString);
begin
  if value<>FTimeRemaining then
  begin
    FTimeRemaining:=Value;
    DoitRepeindre:=True;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetMax(const Value: Int64);
begin
  If (Value<>FMax) and (Value>Fmin) then
  begin
    FMax:=Value;
    CalculPourcent;
    invalidate;
  end;
end;

procedure TSCProgessBar.SetMin(const Value: Int64);
begin
  If (Value<>FMin) and (FMax>Value) then
  begin
    FMin:=Value;
    CalculPourcent;
    invalidate;
  end;
end;

procedure TSCProgessBar.SetPosition(const Value: Int64);
begin
  If (Value<>FPosition) and (Value<=FMax) and (Position>=Fmin) then
  begin
    FPosition:=Value;
    CalculPourcent;
    invalidate;
  end;
end;


end.
