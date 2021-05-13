unit SCFileNameLabel;

interface

uses
  Windows,SysUtils, Classes, Controls, StdCtrls, TntStdCtrls;

type
  TSCFileNameLabel = class(TTntLabel)
  private
    { Déclarations privées }
    FMinimizedName:WideString;
    procedure UpdateMinimizedName;
  protected
    { Déclarations protégées }
    procedure DoDrawText(var Rect: TRect; Flags: Integer);override;
    function GetCaption:WideString;
    procedure SetCaption(Value:WideString);
    procedure Resize;override;
  public
    { Déclarations publiques }
  published
    { Déclarations publiées }
    property Caption: WideString read GetCaption write SetCaption; // le Setter du compo TNT est en private, donc je redéclare la prop Caption
  end;

procedure Register;

implementation

uses TntSysutils,StrUtils;

procedure Register;
begin
  RegisterComponents('SFX Team', [TSCFileNameLabel]);
end;

procedure TSCFileNameLabel.UpdateMinimizedName;
  procedure CutFirstDirectory(var S: WideString);
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
      P := WideTextPos('\',S);
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
  Drive: WideString;
  Dir: WideString;
  Name: WideString;
begin
  FMinimizedName := Caption;
  Dir := WideExtractFilePath(FMinimizedName);
  Name := WideExtractFileName(FMinimizedName);

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

function TSCFileNameLabel.GetCaption:WideString;
begin
  Result:=inherited Caption;
end;

procedure TSCFileNameLabel.SetCaption(Value:WideString);
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
  TntLabel_DoDrawText(Self,Rect,Flags,FMinimizedName);
end;

end.
