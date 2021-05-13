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

unit SCFileNameLabel;

interface

uses
  Windows,SysUtils, Classes, Controls, StdCtrls;

type
  TSCFileNameLabel = class(TLabel)
  private
    { Déclarations privées }
    FMinimizedName:string;
    procedure UpdateMinimizedName;
  protected
    { Déclarations protégées }
    procedure DoDrawText(var Rect: TRect; Flags: Integer);override;
    function GetCaption:string;
    procedure SetCaption(Value:string);
    procedure Resize;override;
  public
    { Déclarations publiques }
  published
    { Déclarations publiées }
    property Caption: string read GetCaption write SetCaption; // le Setter du compo TNT est en private, donc je redéclare la prop Caption
  end;

procedure Register;

implementation

uses StrUtils;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCFileNameLabel]);
end;

procedure TSCFileNameLabel.UpdateMinimizedName;
  procedure CutFirstDirectory(var S: string);
  var
    Root: Boolean;
    P: Integer;
  begin
    if S = '\' then
      S := ''
    else
    begin
      if S[1] = '\' then
      begin
        Root := True;
        Delete(S, 1, 1);
      end
      else
        Root := False;
      if S[1] = '.' then
        Delete(S, 1, 4);
      P := Pos('\',S);
      if P <> 0 then
      begin
        Delete(S, 1, P);
        S := '...\' + S;
      end
      else
        S := '';
      if Root then
        S := '\' + S;
    end;
  end;

var
  Drive: string;
  Dir: string;
  Name: string;
begin
  FMinimizedName := Caption;
  Dir := ExtractFilePath(FMinimizedName);
  Name := ExtractFileName(FMinimizedName);

  if (Length(Dir) >= 2) and (Dir[2] = ':') then
  begin
    Drive := Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive := '';
  while ((Dir <> '') or (Drive <> '')) and (Canvas.TextWidth(FMinimizedName) > Width) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then
      Drive := ''
    else
      CutFirstDirectory(Dir);
    FMinimizedName := Drive + Dir + Name;
  end;
end;

function TSCFileNameLabel.GetCaption:string;
begin
  Result:=inherited Caption;
end;

procedure TSCFileNameLabel.SetCaption(Value:string);
begin
  inherited Caption:=Value;

  UpdateMinimizedName;
end;

procedure TSCFileNameLabel.Resize;
begin
  inherited;

  UpdateMinimizedName;
end;

procedure TSCFileNameLabel.DoDrawText(var Rect: TRect; Flags: Integer);
begin
  DrawText(Canvas.Handle,FMinimizedName,Length(FMinimizedName),Rect,Flags);
end;

end.
