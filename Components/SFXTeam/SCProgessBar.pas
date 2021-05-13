unit SCProgessBar;

interface

uses
  Windows,Controls,Messages,SysUtils,Classes,Graphics;

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

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCProgessBar]);
end;

{ TSCProgessBar }

constructor TSCProgessBar.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csOpaque,csFramed];
  FMin:=0;
  Fmax:=100;
  FFontProgress:=TFont.Create;
  FFontTxt:=TFont.Create;
  FFontProgress.Color:=clWhite;
  FFontTxt.Color:=clWhite;

  Self.Constraints.MinHeight:=10;
  Self.Constraints.MinWidth:=10;
  FPosition:=0;
  FFrontColor1:=clNavy;
  FFrontColor2:=clCream;
  FBackColor1:=$00685758;
  FBackColor2:=clWhite;
  FFontProgressColor:=clBlack;
  FFontTxtColor:=clBlack;
end;

destructor TSCProgessBar.Destroy;
begin
  FFontProgress.Free;
  FFontTxt.Free;
  inherited;
end;

procedure TSCProgessBar.SetMax(const Value: Int64);
begin
  If (Value<>FMax) and (Value>Fmin) then
  begin
    FMax:=Value;
    invalidate;
  end;
end;

procedure TSCProgessBar.SetMin(const Value: Int64);
begin
  If (Value<>FMin) and (FMax>Value) then
  begin
    FMin:=Value;
    invalidate;
  end;
end;

procedure TSCProgessBar.SetPosition(const Value: Int64);
begin
  If (Value<>FPosition) and (Value<=FMax) then
  begin
    FPosition:=Value;
    invalidate;
  end;
end;

procedure TSCProgessBar.Paint;
    procedure ColorToRVB(Color:TColor;var R,V,B:Integer);
    begin
      R:=Color and $000000FF;
      V:=(Color and $0000FF00) shr 8;
      B:=(Color and $00FF0000) shr 16;
    end;
    procedure OutlineText(var Bmp:Tbitmap;TextColor,TextOutline:TColor);
    var
      x,y:integer;
    begin
      For X:=0 to Bmp.Width-1 do
      begin
        for y:=0 to Bmp.Height-1 do
        begin
          With Bmp.Canvas do
          begin
            if Pixels[X,Y]=TextColor then
            begin
              if Pixels[X+1,Y+1]=clFuchsia then Pixels[X+1,Y+1]:=TextOutline;
              if Pixels[X-1,Y-1]=clFuchsia then Pixels[X-1,Y-1]:=TextOutline;
              if Pixels[X+1,Y-1]=clFuchsia then Pixels[X+1,Y-1]:=TextOutline;
              if Pixels[X-1,Y+1]=clFuchsia then Pixels[X-1,Y+1]:=TextOutline;
              if Pixels[X+1,Y]=clFuchsia then Pixels[X+1,Y]:=TextOutline;
              if Pixels[X-1,Y]=clFuchsia then Pixels[X-1,Y]:=TextOutline;
              if Pixels[X,Y+1]=clFuchsia then Pixels[X,Y+1]:=TextOutline;
              if Pixels[X,Y-1]=clFuchsia then Pixels[X,Y-1]:=TextOutline;
            end;
          end;
        end;
      end;
    end;
var
  Y,WidthProgress,PourcentProgress:Integer;
  Textsize:TSize;
  TxtRect:TRect;
  PourcentProgressStr:String;
  R1,V1,B1,R2,V2,B2:Integer;
  R1b,V1b,B1b,R2b,V2b,B2b:Integer;
  Bmp,BmpText:Tbitmap;
begin
  {efface le fond}
  Perform(WM_ERASEBKGND,Canvas.Handle,1);
  {dessine la progresse bar}
  Bmp:=TBitmap.Create;
  Bmp.Width:=Width;
  Bmp.Height:=Height;
  Bmp.PixelFormat:=pfDevice;
  ColorToRVB(FFrontColor1,R1,V1,B1);
  ColorToRVB(FFrontColor2,R2,V2,B2);
  ColorToRVB(FBackColor1,R1b,V1b,B1b);
  ColorToRVB(FBackColor2,R2b,V2b,B2b);
  PourcentProgress:=(FPosition*100) div FMax;
  //WidthProgress:=(PourcentProgress*Width) div 100;
  WidthProgress:=(FPosition*Width) div FMAX;
  for y:=0 to (Bmp.Height div 2) do
  begin
    Bmp.Canvas.pen.Color:=RGB( (R1+ MulDiv(y,R2-R1,bmp.Height)) mod 256,
                               (V1+ MulDiv(y,V2-V1,bmp.Height)) mod 256,
                               (B1+ MulDiv(y,B2-b1,bmp.Height)) mod 256);
    Bmp.Canvas.MoveTo(0,y);
    Bmp.Canvas.LineTo(WidthProgress,y);
    Bmp.Canvas.MoveTo(0,Bmp.Height-Y);
    Bmp.Canvas.LineTo(WidthProgress,Bmp.Height-Y);
    Bmp.Canvas.pen.Color:=RGB( (R1b+ MulDiv(y,R2b-R1b,bmp.Height)) mod 256,
                               (V1b+ MulDiv(y,V2b-V1b,bmp.Height)) mod 256,
                               (B1b+ MulDiv(y,B2b-B1b,bmp.Height)) mod 256);
    Bmp.Canvas.MoveTo(WidthProgress,y);
    Bmp.Canvas.LineTo(Bmp.Width,y);
    Bmp.Canvas.MoveTo(WidthProgress,Bmp.Height-Y);
    Bmp.Canvas.LineTo(Bmp.Width,Bmp.Height-Y);
  end;

  {Dessine le % de progression et la widestring}
  BmpText:=TBitmap.Create;
  PourcentProgressStr:=IntToStr(PourcentProgress)+' %';
  With BmpText do
  begin
    TransparentColor:=clFuchsia;
    Transparent:=true;

    {dessine le %}
    Canvas.Font:=FFontProgress;
    textsize:=Canvas.TextExtent(PourcentProgressStr);
    Width:=textsize.cx+1;
    Height:=textsize.cy+1;
    Canvas.Brush.Color:=clFuchsia;
    Canvas.FillRect(Canvas.ClipRect);
    Canvas.TextOut(0,0,PourcentProgressStr);
    OutlineText(BmpText,FFontProgress.Color,FFontProgressColor);
    bmp.Canvas.Draw((bmp.Width div 2)-Width div 2,(bmp.Height div 2)-Height div 2 +1,BmpText);
    {dessine le widestring}
    Canvas.Font:=FFontTxt;
    GetTextExtentPoint32W(Canvas.Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),Textsize);
    Width:=textsize.cx+1;
    Height:=textsize.cy+1;
    Canvas.FillRect(Canvas.ClipRect);
    TxtRect:=Rect(0,0,Width,Height);
    DrawTextW(Canvas.Handle,PWidechar(FTimeRemaining),length(FTimeRemaining),TxtRect,DT_CENTER+DT_VCENTER+DT_SINGLELINE);
    OutlineText(BmpText,FFontTxt.Color,FFontTxtColor);
    bmp.Canvas.Draw(Bmp.Width-Width-5,(bmp.Height div 2)-Height div 2 +1,BmpText);
    Free;
  end;

  Bmp.Canvas.Pen.Color:=FBorderColor;
  Bmp.Canvas.Brush.Style:=bsClear;
  bmp.Canvas.Rectangle(0,0,Width,height);
  Canvas.Draw(0,0,Bmp);
  Canvas.Pen.Color:=FBorderColor;
  Bmp.Free;
end;

procedure TSCProgessBar.SetAvancement(Position: Int64;
  TimeRemaining: WideString);
begin
   If (Position<>FPosition) and (Position<=FMax) then
     FPosition:=Position;
   FTimeRemaining:=TimeRemaining;
   invalidate;
end;

procedure TSCProgessBar.SetBorderColor(const Value: TColor);
begin
  If Value<>FBorderColor then
  begin
    FBorderColor:=Value;
    Invalidate;
  end;
end;


procedure TSCProgessBar.SetBackColor1(const Value: TColor);
begin
  if Value<>FBackColor1 then
  begin
    FBackColor1:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetBackColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FBackColor2:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFrontColor1(const Value: TColor);
begin
  if value<>FFrontColor1 then
  begin
    FFrontColor1:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFrontColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FFrontColor2:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontProgress(const Value: TFont);
begin
  if value<>FFontProgress then
  begin
    FFontProgress:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontProgressColor(const Value: TColor);
begin
  if value<>FFontProgressColor then
  begin
    FFontProgressColor:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontTxt(const Value: TFont);
begin
  if value<>FFontProgress then
  begin
    FFontTxt:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetFontTxtColor(const Value: TColor);
begin
  if value<>FFontTxtColor then
  begin
    FFontTxtColor:=Value;
    Invalidate;
  end;
end;

procedure TSCProgessBar.SetTimeRemaining(const Value: WideString);
begin
  if value<>FTimeRemaining then
  begin
    FTimeRemaining:=Value;
    Invalidate;
  end;
end;

end.
