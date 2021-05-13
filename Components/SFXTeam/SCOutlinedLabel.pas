unit SCOutlinedLabel;

interface

uses
  Windows,SysUtils, Classes, Controls, StdCtrls,Graphics;

type
  TSCOutlinedLabel = class(TLabel)
  private
    { Déclarations privées }
  protected
    { Déclarations protégées }
    procedure DoDrawText(var Rect: TRect; Flags: Integer);override;
    property Transparent;
  public
    { Déclarations publiques }
  end;

procedure Register;

implementation

uses StrUtils;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCOutlinedLabel]);
end;

procedure TSCOutlinedLabel.DoDrawText(var Rect: TRect; Flags: Integer);
var x,y:Integer;
    R,MRect:TRect;
    F:Integer;
begin
  F:=Flags or DT_VCENTER or DT_SINGLELINE or DT_NOCLIP;

  Canvas.Brush.Style:=bsClear;

  Canvas.Font.Color:=Color;

  for x:=0 to 2 do
    for y:=0 to 2 do
    begin
      R:=Rect;
      Inc(R.Left,x);
      Inc(R.Right,x);
      Inc(R.Top,y);
      Inc(R.Bottom,y);

      if (x=1) and (y=1) then
        MRect:=R // texte prinpal, dessiné après le contour
      else
        DrawText(Canvas.Handle,Caption,Length(Caption),R,F);
    end;

  Canvas.Font.Color:=Font.Color;

  DrawText(Canvas.Handle,Caption,Length(Caption),MRect,F);
end;

end.
