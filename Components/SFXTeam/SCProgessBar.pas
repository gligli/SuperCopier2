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
  Windows,Controls,Messages,SysUtils,Classes,Graphics,ComCtrls,SCOutlinedLabel;

type

  TSCProgessBar = class(TProgressBar)
  private
    FPercentLabel: TSCOutlinedLabel;
    FRemainingLabel: TSCOutlinedLabel;
    FMax: Int64;
    FMin: Int64;
    FPosition: Int64;
    procedure UpdateProgress;
    procedure SetMax(const Value: Int64);
    procedure SetMin(const Value: Int64);
    procedure SetPosition(const Value: Int64);
  public
    constructor Create(AOwner:TComponent);override;
  published
    property PercentLabel:TSCOutlinedLabel read FPercentLabel;
    property RemainingLabel:TSCOutlinedLabel read FRemainingLabel;

    property Min: Int64 read FMin write SetMin;
    property Max: Int64 read FMax write SetMax;
    property Position: Int64 read FPosition write SetPosition;
  end;

procedure Register;

implementation

uses Types;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCProgessBar]);
end;

{ TSCProgessBar }

constructor TSCProgessBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPercentLabel:=TSCOutlinedLabel.Create(Self);
  FRemainingLabel:=TSCOutlinedLabel.Create(Self);

  PercentLabel.Name:='PercentLabel';
  PercentLabel.Align:=alClient;
  PercentLabel.Transparent:=True;
  PercentLabel.Alignment:=taCenter;
  PercentLabel.Parent:=Self;

  RemainingLabel.Name:='RemainingLabel';
  RemainingLabel.Align:=alClient;
  RemainingLabel.Transparent:=True;
  RemainingLabel.Alignment:=taRightJustify;
  RemainingLabel.Parent:=Self;

  inherited Max:=MaxInt;

  FMin:=0;
  FMax:=100;
  FPosition:=0;
  UpdateProgress;
end;

procedure TSCProgessBar.SetMax(const Value: Int64);
begin
  FMax := Value;
  UpdateProgress;
end;

procedure TSCProgessBar.SetMin(const Value: Int64);
begin
  FMin := Value;
  UpdateProgress;
end;

procedure TSCProgessBar.SetPosition(const Value: Int64);
begin
  FPosition := Value;
  UpdateProgress;
end;

procedure TSCProgessBar.UpdateProgress;
var Pct:Double;
begin
  Pct:=0.0;
  if (FPosition>=FMin) and (FMax>FMin) then
    Pct:=(FPosition-FMin)/(FMax-FMin);

  inherited Position:=Round(Pct*inherited Max);
  PercentLabel.Caption:=IntToStr(Round(Pct*100))+' %';
end;

end.
