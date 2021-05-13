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
    FMax:Int64;
    FMin:Int64;
    FPosition:Int64;

    Procedure SetBorderColor(const Value:TColor);
    Procedure SetFrontColor1(const Value:TColor);
    Procedure SetFrontColor2(const Value:TColor);
    Procedure SetBackColor1(const Value:TColor);
    Procedure SetBackColor2(const Value:TColor);
    Procedure SetMax(const Value:Int64);
    Procedure SetMin(const Value:Int64);
    Procedure SetPosition(const Value:Int64);
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
    property BorderColor:TColor read FBorderColor write SetBorderColor;
    property FrontColor1:TColor read FFrontColor1 write SetFrontColor1;
    property FrontColor2:TColor read FFrontColor2 write SetFrontColor2;
    property BackColor1:TColor read FBackColor1 write SetBackColor1;
    property BackColor2:TColor read FBackColor2 write SetBackColor2;
    property Max:Int64 read FMax write SetMax;
    property Min:Int64 read FMin write SetMin;
    property Position:Int64 read FPosition write SetPosition;
    property Anchors;
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
  FMin:=0;
  Fmax:=100;
  FPosition:=0;
  FFrontColor1:=clRed;
  FFrontColor2:=clBlue;
  FBackColor1:=clGray;
  FBackColor2:=clWhite;
  ControlStyle := ControlStyle + [csFramed, csOpaque];
end;

destructor TSCProgessBar.Destroy;
begin

  inherited;
end;

procedure TSCProgessBar.SetMax(const Value: Int64);
begin
  If (Value<>FMax) and (Value>Fmin) then
  begin
    FMax:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetMin(const Value: Int64);
begin
  If (Value<>FMin) and (FMax>Value) then
  begin
    FMin:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetPosition(const Value: Int64);
begin
  If (Value<>FPosition) and (Value<=FMax) then
  begin
    FPosition:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.Paint;
    procedure ColorToRVB(Color:TColor;var R,V,B:Integer);
    begin
      R:=Color and $000000FF;
      V:=(Color and $0000FF00) shr 8;
      B:=(Color and $00FF0000) shr 16;
    end;
var
  X,Y,WidthProgress,PourcentProgress:Integer;
  Textsize:TSize;
  PourcentProgressStr:String;
  R1,V1,B1,R2,V2,B2:Integer;
  R1b,V1b,B1b,R2b,V2b,B2b:Integer;
  Bmp,BmpText:Tbitmap;
begin
  if (Width<=0) or (Height<=0) then Exit;

  Bmp:=TBitmap.Create;
  Bmp.Width:=Width;
  Bmp.Height:=Height;
  Bmp.PixelFormat:=pfDevice;
  ColorToRVB(FFrontColor1,R1,V1,B1);
  ColorToRVB(FFrontColor2,R2,V2,B2);
  ColorToRVB(FBackColor1,R1b,V1b,B1b);
  ColorToRVB(FBackColor2,R2b,V2b,B2b);
  PourcentProgress:=(FPosition*100) div FMax;
  WidthProgress:=(PourcentProgress*Width) div 100;

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
    BmpText:=TBitmap.Create;

    PourcentProgressStr:=IntToStr(PourcentProgress)+' %';
    textsize:=BmpText.Canvas.TextExtent(PourcentProgressStr);
    BmpText.Width:=textsize.cx+1;
    BmpText.Height:=textsize.cy+1;
    BmpText.Canvas.Brush.Color:=clFuchsia;
    BmpText.Canvas.FillRect(BmpText.Canvas.ClipRect);
    BmpText.Canvas.Font.Color:=clWhite;
    BmpText.Canvas.Font.Size:=9;
    BmpText.Canvas.TextOut(0,0,PourcentProgressStr);
    For X:=0 to BmpText.Width-1 do
    begin
      for y:=0 to BmpText.Height-1 do
      begin
        if BmpText.Canvas.Pixels[X,Y]=Clwhite then
        begin
          if BmpText.Canvas.Pixels[X+1,Y+1]=clFuchsia then BmpText.Canvas.Pixels[X+1,Y+1]:=clBlack;
          if BmpText.Canvas.Pixels[X-1,Y-1]=clFuchsia then BmpText.Canvas.Pixels[X-1,Y-1]:=clBlack;
          if BmpText.Canvas.Pixels[X+1,Y-1]=clFuchsia then BmpText.Canvas.Pixels[X+1,Y-1]:=clBlack;
          if BmpText.Canvas.Pixels[X-1,Y+1]=clFuchsia then BmpText.Canvas.Pixels[X-1,Y+1]:=clBlack;
          if BmpText.Canvas.Pixels[X+1,Y]=clFuchsia then BmpText.Canvas.Pixels[X+1,Y]:=clBlack;
          if BmpText.Canvas.Pixels[X-1,Y]=clFuchsia then BmpText.Canvas.Pixels[X-1,Y]:=clBlack;
          if BmpText.Canvas.Pixels[X,Y+1]=clFuchsia then BmpText.Canvas.Pixels[X,Y+1]:=clBlack;
          if BmpText.Canvas.Pixels[X,Y-1]=clFuchsia then BmpText.Canvas.Pixels[X,Y-1]:=clBlack;
        end;
      end;
    end;
  BmpText.TransparentColor:=clFuchsia;
  BmpText.Transparent:=true;
  bmp.Canvas.Draw((bmp.Width div 2)-BmpText.Width div 2,(bmp.Height div 2)-BmpText.Height div 2,BmpText);
  BmpText.Free;

  Bmp.Canvas.Pen.Color:=clBlack;
  Bmp.Canvas.Brush.Style:=bsClear;
  bmp.Canvas.Rectangle(0,0,Width,height);

  Canvas.Draw(0,0,Bmp);
  Canvas.Pen.Color:=FBorderColor;
  Bmp.Free;
end;

procedure TSCProgessBar.SetAvancement(Position: Int64;
  TimeRemaining: WideString);
begin

end;

procedure TSCProgessBar.SetBorderColor(const Value: TColor);
begin
  If Value<>FBorderColor then
  begin
    FBorderColor:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetBackColor1(const Value: TColor);
begin
  if Value<>FBackColor1 then
  begin
    FBackColor1:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetBackColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FBackColor2:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetFrontColor1(const Value: TColor);
begin
  if value<>FFrontColor1 then
  begin
    FFrontColor1:=Value;
    Self.Repaint;
  end;
end;

procedure TSCProgessBar.SetFrontColor2(const Value: TColor);
begin
  if value<>FFrontColor2 then
  begin
    FFrontColor2:=Value;
    Self.Repaint;
  end;
end;

end.
