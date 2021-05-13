
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntClipBrd;

{$INCLUDE TntCompilers.inc}

interface

uses
  Classes, Windows, Clipbrd;

type
  TTntClipboard = class(TObject)
  private
    function GetAsWideText: WideString;
    procedure SetAsWideText(const Value: WideString);
  public
    property AsWideText: WideString read GetAsWideText write SetAsWideText;
  end;

function TntClipboard: TTntClipboard;

implementation

type TAccessClipboard = class(TClipboard);

procedure Clipboard_SetBuffer(Format{TNT-ALLOW Format}: Word; var Buffer; Size: Integer);
{$IFDEF COMPILER_6_UP}
begin
  TAccessClipboard(Clipboard).SetBuffer(Format{TNT-ALLOW Format}, Buffer, Size);
end;
{$ELSE}
var
  Data: THandle;
  DataPtr: Pointer;
begin
  with Clipboard do begin
    Open;
    try
      Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
      try
        DataPtr := GlobalLock(Data);
        try
          Move(Buffer, DataPtr^, Size);
          Clear;
          SetClipboardData(Format{TNT-ALLOW Format}, Data);
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    finally
      Close;
    end;
  end;
end;
{$ENDIF}

{ TTntClipboard }

function TTntClipboard.GetAsWideText: WideString;
var
  Data: THandle;
begin
  with Clipboard do begin
    Open;
    Data := GetClipboardData(CF_UNICODETEXT);
    try
      if Data <> 0 then
        Result := PWideChar(GlobalLock(Data))
      else
        Result := '';
    finally
      if Data <> 0 then GlobalUnlock(Data);
      Close;
    end;
    if (Data = 0) or (Result = '') then
      Result := Clipboard.AsText
  end;
end;

procedure TTntClipboard.SetAsWideText(const Value: WideString);
begin
  Clipboard.Open;
  try
    Clipboard.AsText := Value; {Ensures ANSI compatiblity across platforms.}
    Clipboard_SetBuffer(CF_UNICODETEXT,
      PWideChar(Value)^, (Length(Value) + 1) * SizeOf(WideChar));
  finally
    Clipboard.Close;
  end;
end;

//------------------------------------------

var
  GTntClipboard: TTntClipboard;

function TntClipboard: TTntClipboard;
begin
  if GTntClipboard = nil then
    GTntClipboard := TTntClipboard.Create;
  Result := GTntClipboard;
end;

initialization

finalization
  GTntClipboard.Free;

end.
