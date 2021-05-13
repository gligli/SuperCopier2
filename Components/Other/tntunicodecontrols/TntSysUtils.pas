
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntSysUtils;

{$INCLUDE TntCompilers.inc}

interface

uses
  {$IFDEF COMPILER_6_UP} Types, {$ENDIF} SysUtils, Windows;

//---------------------------------------------------------------------------------------------
//                                 Tnt - Types
//---------------------------------------------------------------------------------------------

{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
type
  TWideStringDynArray = array of WideString;
{$ENDIF}
// ......... introduced .........
type
  // The user of the application did something plainly wrong.
  ETntUserError = class(Exception);
  // A general error occured. (ie. file didn't exist, server didn't return data, etc.)
  ETntGeneralError = class(Exception);
  // Like Assert().  An error occured that should never have happened, send me a bug report now!
  ETntInternalError = class(Exception);

//---------------------------------------------------------------------------------------------
//                                 Tnt - SysUtils
//---------------------------------------------------------------------------------------------

// ......... compatibility .........
{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
resourcestring
  SInvalidCurrency = '''%s'' is not a valid currency value';

const sLineBreak = #13#10;
const PathDelim = '\';
const DriveDelim = ':';
const PathSep = ';';

procedure RaiseLastOSError;
function WideFormat(const FormatStr: WideString; const Args: array of const): WideString;
function WideCompareStr(const W1, W2: WideString): Integer;
function WideSameStr(const W1, W2: WideString): Boolean;
function WideCompareText(const W1, W2: WideString): Integer;
function WideSameText(const W1, W2: WideString): Boolean;
function Supports(const Instance: TObject; const IID: TGUID): Boolean;
{$ENDIF}

// ......... SBCS and MBCS functions with WideString replacements in SysUtils.pas .........

{TNT-WARN CompareStr}                   {TNT-WARN AnsiCompareStr}
{TNT-WARN SameStr}                      {TNT-WARN AnsiSameStr}
{TNT-WARN SameText}                     {TNT-WARN AnsiSameText}
{TNT-WARN CompareText}                  {TNT-WARN AnsiCompareText}
{TNT-WARN UpperCase}                    {TNT-WARN AnsiUpperCase}
{TNT-WARN LowerCase}                    {TNT-WARN AnsiLowerCase}

{TNT-WARN AnsiPos}  { --> Pos() supports WideString. }
{TNT-WARN FmtStr}
{TNT-WARN Format}
{TNT-WARN FormatBuf}

// ......... MBCS Byte Type Procs .........

{TNT-WARN ByteType}
{TNT-WARN StrByteType}
{TNT-WARN ByteToCharIndex}
{TNT-WARN ByteToCharLen}
{TNT-WARN CharToByteIndex}
{TNT-WARN CharToByteLen}

// ........ null-terminated string functions .........

{TNT-WARN StrEnd}
function StrEndW(Str: PWideChar): PWideChar;
{TNT-WARN StrLen}
function StrLenW(Str: PWideChar): Cardinal;
{TNT-WARN StrLCopy}
function StrLCopyW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar;
{TNT-WARN StrCopy}
function StrCopyW(Dest, Source: PWideChar): PWideChar;
{TNT-WARN StrECopy}
function StrECopyW(Dest, Source: PWideChar): PWideChar;
{TNT-WARN StrPLCopy}
{TNT-WARN StrPLCopyW}  // <-- accepts ansi string parameter
function StrPLCopyW{TNT-ALLOW StrPLCopyW}(Dest: PWideChar; const Source: AnsiString; MaxLen: Cardinal): PWideChar;
{TNT-WARN StrPCopy}
{TNT-WARN StrPCopyW}   // < -- accepts ansi string parameter
function StrPCopyW{TNT-ALLOW StrPCopyW}(Dest: PWideChar; const Source: AnsiString): PWideChar;
{TNT-WARN StrLComp}
{TNT-WARN AnsiStrLComp}
function StrLCompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
{TNT-WARN StrComp}
{TNT-WARN AnsiStrComp}
function StrCompW(Str1, Str2: PWideChar): Integer;
{TNT-WARN StrLIComp}
{TNT-WARN AnsiStrLIComp}
function StrLICompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
{TNT-WARN StrIComp}
{TNT-WARN AnsiStrIComp}
function StrICompW(Str1, Str2: PWideChar): Integer;
{TNT-WARN StrLower}
{TNT-WARN AnsiStrLower}
function StrLowerW(Str: PWideChar): PWideChar;
{TNT-WARN StrUpper}
{TNT-WARN AnsiStrUpper}
function StrUpperW(Str: PWideChar): PWideChar;
{TNT-WARN StrPos}
{TNT-WARN AnsiStrPos}
function StrPosW(Str, SubStr: PWideChar): PWideChar;
{TNT-WARN StrScan}
{TNT-WARN AnsiStrScan}
function StrScanW(const Str: PWideChar; Chr: WideChar): PWideChar;
{TNT-WARN StrRScan}
{TNT-WARN AnsiStrRScan}
function StrRScanW(const Str: PWideChar; Chr: WideChar): PWideChar;
{TNT-WARN StrLCat}
function StrLCatW(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
{TNT-WARN StrCat}
function StrCatW(Dest: PWideChar; const Source: PWideChar): PWideChar;
{TNT-WARN StrMove}
function StrMoveW(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar;
{TNT-WARN StrPas}
function StrPasW(const Str: PWideChar): WideString;
{TNT-WARN StrAlloc}
function StrAllocW(Size: Cardinal): PWideChar;
{TNT-WARN StrBufSize}
function StrBufSizeW(const Str: PWideChar): Cardinal;
{TNT-WARN StrNew}
function StrNewW(const Str: PWideChar): PWideChar;
{TNT-WARN StrDispose}
procedure StrDisposeW(Str: PWideChar);

// ........ string functions .........

{$IFDEF COMPILER_7_UP}
type
  PFormatSettings= ^TFormatSettings;
{$ENDIF}

{$IFDEF COMPILER_6_UP}
{TNT-WARN WideFormatBuf} // SysUtils.WideFormatBuf doesn't correctly handle numeric specifiers.
function Tnt_WideFormatBuf(var Buffer; BufLen: Cardinal; const FormatStr;
  FmtLen: Cardinal; const Args: array of const): Cardinal; {$IFDEF COMPILER_7_UP} overload; {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER_7_UP}
function Tnt_WideFormatBuf(var Buffer; BufLen: Cardinal; const FormatStr;
  FmtLen: Cardinal; const Args: array of const;
    const FormatSettings: TFormatSettings): Cardinal; overload;
{$ENDIF}

{$IFDEF COMPILER_6_UP}
{TNT-WARN WideFmtStr} // SysUtils.WideFmtStr doesn't handle string lengths > 4096.
procedure Tnt_WideFmtStr(var Result: WideString; const FormatStr: WideString;
  const Args: array of const); {$IFDEF COMPILER_7_UP} overload; {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER_7_UP}
procedure Tnt_WideFmtStr(var Result: WideString; const FormatStr: WideString;
  const Args: array of const; const FormatSettings: TFormatSettings); overload;
{$ENDIF}

{$IFDEF COMPILER_6_UP}
{----------------------------------------------------------------------------------------
  Without the FormatSettings parameter, Tnt_WideFormat is *NOT* necessary...
    TntSystem.InstallTntSystemUpdates([tsFixWideFormat]);
      will fix WideFormat as well as WideFmtStr.
----------------------------------------------------------------------------------------}
function Tnt_WideFormat(const FormatStr: WideString; const Args: array of const): WideString; {$IFDEF COMPILER_7_UP} overload; {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER_7_UP}
function Tnt_WideFormat(const FormatStr: WideString; const Args: array of const;
  const FormatSettings: TFormatSettings): WideString; overload;
{$ENDIF}

{TNT-WARN WideUpperCase} // SysUtils.WideUpperCase is broken on Win9x.
function Tnt_WideUpperCase(const S: WideString): WideString;

{TNT-WARN WideLowerCase} // SysUtils.WideLowerCase is broken on Win9x.
function Tnt_WideLowerCase(const S: WideString): WideString;

{TNT-WARN AnsiLastChar}
{TNT-WARN AnsiStrLastChar}
function WideLastChar(W: WideString): WideChar;

{TNT-WARN StringReplace}
function WideStringReplace(const S, OldPattern, NewPattern: WideString;
  Flags: TReplaceFlags; WholeWord: Boolean = False): WideString;

{TNT-WARN AdjustLineBreaks}
type TTntTextLineBreakStyle = (tlbsLF, tlbsCRLF, tlbsCR);
function TntAdjustLineBreaksLength(const S: WideString; Style: TTntTextLineBreakStyle = tlbsCRLF): Integer;
function TntAdjustLineBreaks(const S: WideString; Style: TTntTextLineBreakStyle = tlbsCRLF): WideString;

{TNT-WARN QuotedStr}
{TNT-WARN AnsiQuotedStr}
function WideQuotedStr(const S: WideString; Quote: WideChar = '"'): WideString;

{TNT-WARN AnsiExtractQuotedStr}
function WideExtractQuotedStr(var Src: PWideChar; Quote: WideChar = '"'): WideString;

{TNT-WARN AnsiDequotedStr}
function WideDequotedStr(const S: WideString; AQuote: WideChar): WideString;

{TNT-WARN WrapText}
function WideWrapText(const Line, BreakStr: WideString; const BreakChars: TSysCharSet;
  MaxCol: Integer): WideString; overload;
function WideWrapText(const Line: WideString; MaxCol: Integer): WideString; overload;

// ........ filename manipulation .........

{TNT-WARN SameFileName}           // doesn't apply to Unicode filenames, use WideSameText
{TNT-WARN AnsiCompareFileName}    // doesn't apply to Unicode filenames, use WideCompareText
{TNT-WARN AnsiLowerCaseFileName}  // doesn't apply to Unicode filenames, use WideLowerCase
{TNT-WARN AnsiUpperCaseFileName}  // doesn't apply to Unicode filenames, use WideUpperCase

{TNT-WARN IncludeTrailingBackslash}
function WideIncludeTrailingBackslash(const S: WideString): WideString;
{TNT-WARN ExcludeTrailingBackslash}
function WideExcludeTrailingBackslash(const S: WideString): WideString;
{TNT-WARN IsDelimiter}
function WideIsDelimiter(const Delimiters, S: WideString; Index: Integer): Boolean;
{TNT-WARN IsPathDelimiter}
function WideIsPathDelimiter(const S: WideString; Index: Integer): Boolean;
{TNT-WARN LastDelimiter}
function WideLastDelimiter(const Delimiters, S: WideString): Integer;
{TNT-WARN ChangeFileExt}
function WideChangeFileExt(const FileName, Extension: WideString): WideString;
{TNT-WARN ExtractFilePath}
function WideExtractFilePath(const FileName: WideString): WideString;
{TNT-WARN ExtractFileDir}
function WideExtractFileDir(const FileName: WideString): WideString;
{TNT-WARN ExtractFileDrive}
function WideExtractFileDrive(const FileName: WideString): WideString;
{TNT-WARN ExtractFileName}
function WideExtractFileName(const FileName: WideString): WideString;
{TNT-WARN ExtractFileExt}
function WideExtractFileExt(const FileName: WideString): WideString;
{TNT-WARN ExtractRelativePath}
function WideExtractRelativePath(const BaseName, DestName: WideString): WideString;

// ........ file management routines .........

{TNT-WARN ExpandFileName}
function WideExpandFileName(const FileName: WideString): WideString;
{TNT-WARN ExtractShortPathName}
function WideExtractShortPathName(const FileName: WideString): WideString;
{TNT-WARN FileCreate}
function WideFileCreate(const FileName: WideString): Integer;
{TNT-WARN FileOpen}
function WideFileOpen(const FileName: WideString; Mode: LongWord): Integer;
{TNT-WARN FileAge}
function WideFileAge(const FileName: WideString): Integer;
{TNT-WARN DirectoryExists}
function WideDirectoryExists(const Name: WideString): Boolean;
{TNT-WARN FileExists}
function WideFileExists(const Name: WideString): Boolean;
{TNT-WARN FileGetAttr}
function WideFileGetAttr(const FileName: WideString): Cardinal;
{TNT-WARN FileSetAttr}
function WideFileSetAttr(const FileName: WideString; Attr: Integer): Boolean;
{TNT-WARN ForceDirectories}
function WideForceDirectories(Dir: WideString): Boolean;
{TNT-WARN FileSearch}
function WideFileSearch(const Name, DirList: WideString): WideString;
{TNT-WARN RenameFile}
function WideRenameFile(const OldName, NewName: WideString): Boolean;
{TNT-WARN DeleteFile}
function WideDeleteFile(const FileName: WideString): Boolean;
{TNT-WARN CopyFile}
function WideCopyFile(FromFile, ToFile: WideString; FailIfExists: Boolean): Boolean;

{TNT-WARN TSearchRec} // <-- FindFile - warning on TSearchRec is all that is necessary
type
  TSearchRecW = record
    Time: Integer;
    Size: Int64;
    Attr: Integer;
    Name: WideString;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindDataW;
  end;
function WideFindFirst(const Path: WideString; Attr: Integer; var F: TSearchRecW): Integer;
function WideFindNext(var F: TSearchRecW): Integer;
procedure WideFindClose(var F: TSearchRecW);
function WideRemoveDir(const Dir: WideString): Boolean;

// ........ date/time functions .........

function ValidDateTimeStr(Str: WideString): Boolean;
function ValidDateStr(Str: WideString): Boolean;
function ValidTimeStr(Str: WideString): Boolean;

{TNT-WARN StrToDateTime}
function TntStrToDateTime(Str: WideString): TDateTime;
{TNT-WARN StrToDate}
function TntStrToDate(Str: WideString): TDateTime;
{TNT-WARN StrToTime}
function TntStrToTime(Str: WideString): TDateTime;
{TNT-WARN StrToDateTimeDef}
function TntStrToDateTimeDef(Str: WideString; Default: TDateTime): TDateTime;
{TNT-WARN StrToDateDef}
function TntStrToDateDef(Str: WideString; Default: TDateTime): TDateTime;
{TNT-WARN StrToTimeDef}
function TntStrToTimeDef(Str: WideString; Default: TDateTime): TDateTime;

{TNT-WARN CurrToStr}
{TNT-WARN CurrToStrF}
function TntCurrToStr(Value: Currency; lpFormat: PCurrencyFmtW = nil): WideString;
{TNT-WARN StrToCurr}
function TntStrToCurr(const S: WideString): Currency;
{TNT-WARN StrToCurrDef}
function ValidCurrencyStr(const S: WideString): Boolean;
function TntStrToCurrDef(const S: WideString; const Default: Currency): Currency;
function GetDefaultCurrencyFmt: TCurrencyFmtW;

// ........ misc functions .........

{TNT-WARN GetLocaleStr}
function WideGetLocaleStr(LocaleID: LCID; LocaleType: Integer; const Default: WideString): WideString;

// ......... introduced .........

const
  CR = WideChar(#13);
  LF = WideChar(#10);
  CRLF = WideString(#13#10);
  WideLineSeparator = WideChar($2028);

var
  Win32PlatformIsUnicode: Boolean;
  Win32PlatformIsXP: Boolean;

{$IFNDEF COMPILER_7_UP}
function CheckWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;
{$ENDIF}
function WinCheckH(RetVal: Cardinal): Cardinal;
function WinCheckFileH(RetVal: Cardinal): Cardinal;
function WinCheckP(RetVal: Pointer): Pointer;

function WideGetModuleFileName(Instance: HModule): WideString;
function WideSafeLoadLibrary(const Filename: Widestring;
  ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;
function WideLoadPackage(const Name: Widestring): HMODULE;

function IsWideCharUpper(WC: WideChar): Boolean;
function IsWideCharLower(WC: WideChar): Boolean;
function IsWideCharDigit(WC: WideChar): Boolean;
function IsWideCharSpace(WC: WideChar): Boolean;
function IsWideCharPunct(WC: WideChar): Boolean;
function IsWideCharCntrl(WC: WideChar): Boolean;
function IsWideCharBlank(WC: WideChar): Boolean;
function IsWideCharXDigit(WC: WideChar): Boolean;
function IsWideCharAlpha(WC: WideChar): Boolean;
function IsWideCharAlphaNumeric(WC: WideChar): Boolean;

function WideTextPos(const SubStr, S: WideString): Integer;

function ExtractStringArrayStr(P: PWideChar): WideString;
function ExtractStringFromStringArray(var P: PWideChar; Separator: WideChar = #0): WideString;
function ExtractStringsFromStringArray(P: PWideChar; Separator: WideChar = #0): TWideStringDynArray;

function IsWideCharMappableToAnsi(const WC: WideChar): Boolean;
function IsWideStringMappableToAnsi(const WS: WideString): Boolean;
function IsRTF(const Value: WideString): Boolean;

function ENG_US_FloatToStr(Value: Extended): WideString;
function ENG_US_StrToFloat(const S: WideString): Extended;

//---------------------------------------------------------------------------------------------
//                                 Tnt - Variants
//---------------------------------------------------------------------------------------------

// ......... compatibility .........
{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
function VarToWideStr(const V: Variant): WideString;
function VarToWideStrDef(const V: Variant; const ADefault: WideString): WideString;
{$ENDIF}

// ........ Variants.pas has WideString versions of these functions .........
{TNT-WARN VarToStr}
{TNT-WARN VarToStrDef}

var
  _SettingChangeTime: Cardinal;

implementation

uses
  ActiveX, ComObj, Math, SysConst, Consts,
  TntSystem, TntWindows, TntFormatStrUtils;

//---------------------------------------------------------------------------------------------
//                                 Tnt - SysUtils
//---------------------------------------------------------------------------------------------

{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
procedure RaiseLastOSError;
begin
  RaiseLastWin32Error;
end;

function WideFormat(const FormatStr: WideString; const Args: array of const): WideString;
begin
  Result := Format{TNT-ALLOW Format}(FormatStr, Args);
end;

function WideCompareStr(const W1, W2: WideString): Integer;
begin
  Result := Tnt_CompareStringW(GetThreadLocale, 0,
      PWideChar(W1), Length(W1), PWideChar(W2), Length(W2)) - 2;
end;

function WideSameStr(const W1, W2: WideString): Boolean;
begin
  Result := WideCompareStr(W1, W2) = 0;
end;

function WideCompareText(const W1, W2: WideString): Integer;
begin
  Result := Tnt_CompareStringW(GetThreadLocale, NORM_IGNORECASE,
    PWideChar(W1), Length(W1), PWideChar(W2), Length(W2)) - 2;
end;

function WideSameText(const W1, W2: WideString): Boolean;
begin
  Result := WideCompareText(W1, W2) = 0;
end;

function Supports(const Instance: TObject; const IID: TGUID): Boolean;
var
  Temp: IUnknown;
begin
  Result := Instance.GetInterface(IID, Temp);
end;
{$ENDIF}

function StrEndW(Str: PWideChar): PWideChar;
begin
  // returns a pointer to the end of a null terminated string
  Result := Str;
  While Result^ <> #0 do
    Inc(Result);
end;

function StrLenW(Str: PWideChar): Cardinal;
begin
  Result := StrEndW(Str) - Str;
end;

function StrLCopyW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar;
var
  Count: Cardinal;
begin
  // copies a specified maximum number of characters from Source to Dest
  Result := Dest;
  Count := 0;
  While (Count < MaxLen) and (Source^ <> #0) do begin
    Dest^ := Source^;
    Inc(Source);
    Inc(Dest);
    Inc(Count);
  end;
  Dest^ := #0;
end;

function StrCopyW(Dest, Source: PWideChar): PWideChar;
begin
  Result := StrLCopyW(Dest, Source, MaxInt);
end;

function StrECopyW(Dest, Source: PWideChar): PWideChar;
begin
  Result := StrEndW(StrCopyW(Dest, Source));
end;

function StrPLCopyW{TNT-ALLOW StrPLCopyW}(Dest: PWideChar; const Source: AnsiString; MaxLen: Cardinal): PWideChar;
begin
  Result := StrLCopyW(Dest, PWideChar(WideString(Source)), MaxLen);
end;

function StrPCopyW{TNT-ALLOW StrPCopyW}(Dest: PWideChar; const Source: AnsiString): PWideChar;
begin
  Result := StrPLCopyW{TNT-ALLOW StrPLCopyW}(Dest, Source, MaxInt);
end;

function StrCompW_EX(Str1, Str2: PWideChar; MaxLen: Cardinal; dwCmpFlags: Cardinal): Integer;
var
  Len1, Len2: Integer;
begin
  if MaxLen = Cardinal(MaxInt) then begin
    Len1 := -1;
    Len2 := -1;
  end else begin
    Len1 := Min(StrLenW(Str1), MaxLen);
    Len2 := Min(StrLenW(Str2), MaxLen);
  end;
  Result := Tnt_CompareStringW(GetThreadLocale, dwCmpFlags, Str1, Len1, Str2, Len2) - 2;
end;

function StrLCompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
begin
  Result := StrCompW_EX(Str1, Str2, MaxLen, 0);
end;

function StrCompW(Str1, Str2: PWideChar): Integer;
begin
  Result := StrLCompW(Str1, Str2, MaxInt);
end;

function StrLICompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
begin
  Result := StrCompW_EX(Str1, Str2, MaxLen, NORM_IGNORECASE);
end;

function StrICompW(Str1, Str2: PWideChar): Integer;
begin
  Result := StrLICompW(Str1, Str2, MaxInt);
end;

function StrLowerW(Str: PWideChar): PWideChar;
begin
  Result := Str;
  Tnt_CharLowerBuffW(Str, StrLenW(Str))
end;

function StrUpperW(Str: PWideChar): PWideChar;
begin
  Result := Str;
  Tnt_CharUpperBuffW(Str, StrLenW(Str))
end;

function StrPosW(Str, SubStr: PWideChar): PWideChar;
var
  PSave: PWideChar;
  P: PWideChar;
  PSub: PWideChar;
begin
  // returns a pointer to the first occurance of SubStr in Str
  Result := nil;
  if (Str <> nil) and (Str^ <> #0) and (SubStr <> nil) and (SubStr^ <> #0) then begin
    P := Str;
    While P^ <> #0 do begin
      if P^ = SubStr^ then begin
        // investigate possibility here
        PSave := P;
        PSub := SubStr;
        While (P^ = PSub^) do begin
          Inc(P);
          Inc(PSub);
          if (PSub^ = #0) then begin
            Result := PSave;
            exit; // found a match
          end;
          if (P^ = #0) then
            exit; // no match, hit end of string
        end;
        P := PSave;
      end;
      Inc(P);
    end;
  end;
end;

function StrScanW(const Str: PWideChar; Chr: WideChar): PWideChar;
begin
  Result := Str;
  while Result^ <> Chr do
  begin
    if Result^ = #0 then
    begin
      Result := nil;
      Exit;
    end;
    Inc(Result);
  end;
end;

function StrRScanW(const Str: PWideChar; Chr: WideChar): PWideChar;
var
  MostRecentFound: PWideChar;
begin
  if Chr = #0 then
    Result := StrEndW(Str)
  else
  begin
    Result := nil;
    MostRecentFound := Str;
    while True do
    begin
      while MostRecentFound^ <> Chr do
      begin
        if MostRecentFound^ = #0 then
          Exit;
        Inc(MostRecentFound);
      end;
      Result := MostRecentFound;
      Inc(MostRecentFound);
    end;
  end;
end;

function StrLCatW(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
begin
  Result := Dest;
  StrLCopyW(StrEndW(Dest), Source, MaxLen - StrLenW(Dest));
end;

function StrCatW(Dest: PWideChar; const Source: PWideChar): PWideChar;
begin
  Result := Dest;
  StrCopyW(StrEndW(Dest), Source);
end;

function StrMoveW(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar;
var
  Length: Integer;
begin
  Result := Dest;
  Length := Count * SizeOf(WideChar);
  Move(Source^, Dest^, Length);
end;

function StrPasW(const Str: PWideChar): WideString;
begin
  Result := Str;
end;

function StrAllocW(Size: Cardinal): PWideChar;
begin
  Size := SizeOf(Cardinal) + (Size * SizeOf(WideChar));
  GetMem(Result, Size);
  PCardinal(Result)^ := Size;
  Inc(PAnsiChar(Result), SizeOf(Cardinal));
end;

function StrBufSizeW(const Str: PWideChar): Cardinal;
var
  P: PWideChar;
begin
  P := Str;
  Dec(PAnsiChar(P), SizeOf(Cardinal));
  Result := PCardinal(P)^ - SizeOf(Cardinal);
  Result := Result div SizeOf(WideChar);
end;

function StrNewW(const Str: PWideChar): PWideChar;
var
  Size: Cardinal;
begin
  if Str = nil then Result := nil else
  begin
    Size := StrLenW(Str) + 1;
    Result := StrMoveW(StrAllocW(Size), Str, Size);
  end;
end;

procedure StrDisposeW(Str: PWideChar);
begin
  if Str <> nil then
  begin
    Dec(PAnsiChar(Str), SizeOf(Cardinal));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

{$IFDEF COMPILER_6_UP}
function _Tnt_WideFormatBuf(var Buffer; BufLen: Cardinal; const FormatStr;
  FmtLen: Cardinal; const Args: array of const
    {$IFDEF COMPILER_7_UP}; const FormatSettings: PFormatSettings {$ENDIF}): Cardinal;
var
  OldFormat: WideString;
  NewFormat: WideString;
begin
  SetString(OldFormat, PWideChar(@FormatStr), FmtLen);
  { The reason for this is that WideFormat doesn't correctly format floating point specifiers.
    See QC#4254. }
  NewFormat := ReplaceFloatingArgumentsInFormatString(OldFormat, Args{$IFDEF COMPILER_7_UP}, FormatSettings{$ENDIF});
  {$IFDEF COMPILER_7_UP}
  if FormatSettings <> nil then
    Result := WideFormatBuf{TNT-ALLOW WideFormatBuf}(Buffer, BufLen, Pointer(NewFormat)^,
      Length(NewFormat), Args, FormatSettings^)
  else
  {$ENDIF}
    Result := WideFormatBuf{TNT-ALLOW WideFormatBuf}(Buffer, BufLen, Pointer(NewFormat)^,
      Length(NewFormat), Args);
end;

function Tnt_WideFormatBuf(var Buffer; BufLen: Cardinal; const FormatStr;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result := _Tnt_WideFormatBuf(Buffer, BufLen, FormatStr, FmtLen, Args{$IFDEF COMPILER_7_UP}, nil{$ENDIF});
end;
{$ENDIF}

{$IFDEF COMPILER_7_UP}
function Tnt_WideFormatBuf(var Buffer; BufLen: Cardinal; const FormatStr;
  FmtLen: Cardinal; const Args: array of const; const FormatSettings: TFormatSettings): Cardinal;
begin
  Result := _Tnt_WideFormatBuf(Buffer, BufLen, FormatStr, FmtLen, Args, @FormatSettings);
end;
{$ENDIF}

{$IFDEF COMPILER_6_UP}
procedure _Tnt_WideFmtStr(var Result: WideString; const FormatStr: WideString;
  const Args: array of const{$IFDEF COMPILER_7_UP}; const FormatSettings: PFormatSettings{$ENDIF});
var
  Len, BufLen: Integer;
  Buffer: array[0..4095] of WideChar;
begin
  BufLen := Length(Buffer); // Fixes buffer overwrite issue. (See QC #4703, #4744)
  if Length(FormatStr) < (Length(Buffer) - (Length(Buffer) div 4)) then
    Len := _Tnt_WideFormatBuf(Buffer, Length(Buffer) - 1, Pointer(FormatStr)^,
      Length(FormatStr), Args{$IFDEF COMPILER_7_UP}, FormatSettings{$ENDIF})
  else
  begin
    BufLen := Length(FormatStr);
    Len := BufLen;
  end;
  if Len >= BufLen - 1 then
  begin
    while Len >= BufLen - 1 do
    begin
      Inc(BufLen, BufLen);
      Result := '';          // prevent copying of existing data, for speed
      SetLength(Result, BufLen);
      Len := _Tnt_WideFormatBuf(Pointer(Result)^, BufLen - 1, Pointer(FormatStr)^,
        Length(FormatStr), Args{$IFDEF COMPILER_7_UP}, FormatSettings{$ENDIF});
    end;
    SetLength(Result, Len);
  end
  else
    SetString(Result, Buffer, Len);
end;

procedure Tnt_WideFmtStr(var Result: WideString; const FormatStr: WideString;
  const Args: array of const);
begin
  _Tnt_WideFmtStr(Result, FormatStr, Args{$IFDEF COMPILER_7_UP}, nil{$ENDIF});
end;
{$ENDIF}

{$IFDEF COMPILER_7_UP}
procedure Tnt_WideFmtStr(var Result: WideString; const FormatStr: WideString;
  const Args: array of const; const FormatSettings: TFormatSettings);
begin
  _Tnt_WideFmtStr(Result, FormatStr, Args, @FormatSettings);
end;
{$ENDIF}

{$IFDEF COMPILER_6_UP}
{----------------------------------------------------------------------------------------
  Without the FormatSettings parameter, Tnt_WideFormat is *NOT* necessary...
    TntSystem.InstallTntSystemUpdates([tsFixWideFormat]);
      will fix WideFormat as well as WideFmtStr.
----------------------------------------------------------------------------------------}
function Tnt_WideFormat(const FormatStr: WideString; const Args: array of const): WideString;
begin
  Tnt_WideFmtStr(Result, FormatStr, Args);
end;
{$ENDIF}

{$IFDEF COMPILER_7_UP}
function Tnt_WideFormat(const FormatStr: WideString; const Args: array of const;
  const FormatSettings: TFormatSettings): WideString;
begin
  Tnt_WideFmtStr(Result, FormatStr, Args, FormatSettings);
end;
{$ENDIF}

function Tnt_WideUpperCase(const S: WideString): WideString;
begin
  { SysUtils.WideUpperCase is broken for Win9x. }
  Result := S;
  if Length(Result) > 0 then
    Tnt_CharUpperBuffW(PWideChar(Result), Length(Result));
end;

function Tnt_WideLowerCase(const S: WideString): WideString;
begin
  { SysUtils.WideLowerCase is broken for Win9x. }
  Result := S;
  if Length(Result) > 0 then
    Tnt_CharLowerBuffW(PWideChar(Result), Length(Result));
end;

function WideLastChar(W: WideString): WideChar;
begin
  if Length(W) = 0 then
    Result := #0
  else
    Result := W[Length(W)];
end;

function WideStringReplace(const S, OldPattern, NewPattern: WideString;
  Flags: TReplaceFlags; WholeWord: Boolean = False): WideString;

  function IsWordSeparator(WC: WideChar): Boolean;
  begin
    Result := (WC = WideChar(#0))
           or IsWideCharSpace(WC)
           or IsWideCharPunct(WC);
  end;

var
  SearchStr, Patt, NewStr: WideString;
  Offset: Integer;
  PrevChar, NextChar: WideChar;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := Tnt_WideUpperCase(S);
    Patt := Tnt_WideUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := Pos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end; // done

    if (WholeWord) then
    begin
      if (Offset = 1) then
        PrevChar := WideLastChar(Result)
      else
        PrevChar := NewStr[Offset - 1];

      if Offset + Length(OldPattern) <= Length(NewStr) then
        NextChar := NewStr[Offset + Length(OldPattern)]
      else
        NextChar := WideChar(#0);

      if (not IsWordSeparator(PrevChar))
      or (not IsWordSeparator(NextChar)) then
      begin
        Result := Result + Copy(NewStr, 1, Offset + Length(OldPattern) - 1);
        NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
        SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
        continue;
      end;
    end;

    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function TntAdjustLineBreaksLength(const S: WideString; Style: TTntTextLineBreakStyle = tlbsCRLF): Integer;
var
  Source, SourceEnd: PWideChar;
begin
  Source := Pointer(S);
  SourceEnd := Source + Length(S);
  Result := Length(S);
  while Source < SourceEnd do
  begin
    case Source^ of
      #10, WideLineSeparator:
        if Style = tlbsCRLF then
          Inc(Result);
      #13:
        if Style = tlbsCRLF then
          if Source[1] = #10 then
            Inc(Source)
          else
            Inc(Result)
        else
          if Source[1] = #10 then
            Dec(Result);
    end;
    Inc(Source);
  end;
end;

function TntAdjustLineBreaks(const S: WideString; Style: TTntTextLineBreakStyle = tlbsCRLF): WideString;
var
  Source, SourceEnd, Dest: PWideChar;
  DestLen: Integer;
begin
  Source := Pointer(S);
  SourceEnd := Source + Length(S);
  DestLen := TntAdjustLineBreaksLength(S, Style);
  SetString(Result, nil, DestLen);
  Dest := Pointer(Result);
  while Source < SourceEnd do begin
    case Source^ of
      #10, WideLineSeparator:
        begin
          if Style in [tlbsCRLF, tlbsCR] then
          begin
            Dest^ := #13;
            Inc(Dest);
          end;
          if Style in [tlbsCRLF, tlbsLF] then
          begin
            Dest^ := #10;
            Inc(Dest);
          end;
          Inc(Source);
        end;
      #13:
        begin
          if Style in [tlbsCRLF, tlbsCR] then
          begin
            Dest^ := #13;
            Inc(Dest);
          end;
          if Style in [tlbsCRLF, tlbsLF] then
          begin
            Dest^ := #10;
            Inc(Dest);
          end;
          Inc(Source);
          if Source^ = #10 then Inc(Source);
        end;
    else
      Dest^ := Source^;
      Inc(Dest);
      Inc(Source);
    end;
  end;
end;

function WideQuotedStr(const S: WideString; Quote: WideChar = '"'): WideString;
var
  P, Src,
  Dest: PWideChar;
  AddCount: Integer;
begin
  AddCount := 0;
  P := StrScanW(PWideChar(S), Quote);
  while (P <> nil) do
  begin
    Inc(P);
    Inc(AddCount);
    P := StrScanW(P, Quote);
  end;

  if AddCount = 0 then
    Result := Quote + S + Quote
  else
  begin
    SetLength(Result, Length(S) + AddCount + 2);
    Dest := PWideChar(Result);
    Dest^ := Quote;
    Inc(Dest);
    Src := PWideChar(S);
    P := StrScanW(Src, Quote);
    repeat
      Inc(P);
      Move(Src^, Dest^, 2 * (P - Src));
      Inc(Dest, P - Src);
      Dest^ := Quote;
      Inc(Dest);
      Src := P;
      P := StrScanW(Src, Quote);
    until P = nil;
    P := StrEndW(Src);
    Move(Src^, Dest^, 2 * (P - Src));
    Inc(Dest, P - Src);
    Dest^ := Quote;
  end;
end;

function WideExtractQuotedStr(var Src: PWideChar; Quote: WideChar = '"'): WideString;
var
  P, Dest: PWideChar;
  DropCount: Integer;
begin
  Result := '';
  if (Src = nil) or (Src^ <> Quote) then
    Exit;

  Inc(Src);
  DropCount := 1;
  P := Src;
  Src := StrScanW(Src, Quote);

  while Src <> nil do   // count adjacent pairs of quote chars
  begin
    Inc(Src);
    if Src^ <> Quote then
      Break;
    Inc(Src);
    Inc(DropCount);
    Src := StrScanW(Src, Quote);
  end;

  if Src = nil then
    Src := StrEndW(P);
  if (Src - P) <= 1 then
    Exit;

  if DropCount = 1 then
    SetString(Result, P, Src - P - 1)
  else
  begin
    SetLength(Result, Src - P - DropCount);
    Dest := PWideChar(Result);
    Src := StrScanW(P, Quote);
    while Src <> nil do
    begin
      Inc(Src);
      if Src^ <> Quote then
        Break;
      Move(P^, Dest^, 2 * (Src - P));
      Inc(Dest, Src - P);
      Inc(Src);
      P := Src;
      Src := StrScanW(Src, Quote);
    end;
    if Src = nil then
      Src := StrEndW(P);
    Move(P^, Dest^, 2 * (Src - P - 1));
  end;
end;

function WideDequotedStr(const S: WideString; AQuote: WideChar): WideString;
var
  LText : PWideChar;
begin
  LText := PWideChar(S);
  Result := WideExtractQuotedStr(LText, AQuote);
  if Result = '' then
    Result := S;
end;

function WideWrapText(const Line, BreakStr: WideString; const BreakChars: TSysCharSet;
  MaxCol: Integer): WideString;

  function WideCharIn(C: WideChar; SysCharSet: TSysCharSet): Boolean;
  begin
    Result := (C <= High(AnsiChar)) and (AnsiChar(C) in SysCharSet);
  end;

const
  QuoteChars = ['''', '"'];
var
  Col, Pos: Integer;
  LinePos, LineLen: Integer;
  BreakLen, BreakPos: Integer;
  QuoteChar, CurChar: WideChar;
  ExistingBreak: Boolean;
begin
  Col := 1;
  Pos := 1;
  LinePos := 1;
  BreakPos := 0;
  QuoteChar := ' ';
  ExistingBreak := False;
  LineLen := Length(Line);
  BreakLen := Length(BreakStr);
  Result := '';
  while Pos <= LineLen do
  begin
    CurChar := Line[Pos];
    if CurChar = BreakStr[1] then
    begin
      if QuoteChar = ' ' then
      begin
        ExistingBreak := WideSameText(BreakStr, Copy(Line, Pos, BreakLen));
        if ExistingBreak then
        begin
          Inc(Pos, BreakLen-1);
          BreakPos := Pos;
        end;
      end
    end
    else if WideCharIn(CurChar, BreakChars) then
    begin
      if QuoteChar = ' ' then BreakPos := Pos
    end
    else if WideCharIn(CurChar, QuoteChars) then
    begin
      if CurChar = QuoteChar then
        QuoteChar := ' '
      else if QuoteChar = ' ' then
        QuoteChar := CurChar;
    end;
    Inc(Pos);
    Inc(Col);
    if not (WideCharIn(QuoteChar, QuoteChars)) and (ExistingBreak or
      ((Col > MaxCol) and (BreakPos > LinePos))) then
    begin
      Col := Pos - BreakPos;
      Result := Result + Copy(Line, LinePos, BreakPos - LinePos + 1);
      if not (WideCharIn(CurChar, QuoteChars)) then
        while Pos <= LineLen do
        begin
          if WideCharIn(Line[Pos], BreakChars) then
            Inc(Pos)
          else if Copy(Line, Pos, Length(sLineBreak)) = sLineBreak then
            Inc(Pos, Length(sLineBreak))
          else
            break;
        end;
      if not ExistingBreak and (Pos < LineLen) then
        Result := Result + BreakStr;
      Inc(BreakPos);
      LinePos := BreakPos;
      ExistingBreak := False;
    end;
  end;
  Result := Result + Copy(Line, LinePos, MaxInt);
end;

function WideWrapText(const Line: WideString; MaxCol: Integer): WideString;
begin
  Result := WideWrapText(Line, sLineBreak, [' ', '-', #9], MaxCol); { do not localize }
end;

function WideIncludeTrailingBackslash(const S: WideString): WideString;
begin
  Result := S;
  if not WideIsPathDelimiter(Result, Length(Result)) then Result := Result + PathDelim;
end;

function WideExcludeTrailingBackslash(const S: WideString): WideString;
begin
  Result := S;
  if WideIsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result)-1);
end;

function WideIsDelimiter(const Delimiters, S: WideString; Index: Integer): Boolean;
begin
  Result := False;
  if (Index <= 0) or (Index > Length(S)) then exit;
  Result := StrScanW(PWideChar(Delimiters), S[Index]) <> nil;
end;

function WideIsPathDelimiter(const S: WideString; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = PathDelim);
end;

function WideLastDelimiter(const Delimiters, S: WideString): Integer;
var
  P: PWideChar;
begin
  Result := Length(S);
  P := PWideChar(Delimiters);
  while Result > 0 do
  begin
    if (S[Result] <> #0) and (StrScanW(P, S[Result]) <> nil) then
      Exit;
    Dec(Result);
  end;
end;

function WideChangeFileExt(const FileName, Extension: WideString): WideString;
var
  I: Integer;
begin
  I := WideLastDelimiter('.\:',Filename);
  if (I = 0) or (FileName[I] <> '.') then I := MaxInt;
  Result := Copy(FileName, 1, I - 1) + Extension;
end;

function WideExtractFilePath(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := WideLastDelimiter('\:', FileName);
  Result := Copy(FileName, 1, I);
end;

function WideExtractFileDir(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := WideLastDelimiter(DriveDelim + PathDelim,Filename);
  if (I > 1) and (FileName[I] = PathDelim) and
    (not (FileName[I - 1] in [WideChar(PathDelim), WideChar(DriveDelim)])) then Dec(I);
  Result := Copy(FileName, 1, I);
end;

function WideExtractFileDrive(const FileName: WideString): WideString;
var
  I, J: Integer;
begin
  if (Length(FileName) >= 2) and (FileName[2] = DriveDelim) then
    Result := Copy(FileName, 1, 2)
  else if (Length(FileName) >= 2) and (FileName[1] = PathDelim) and
    (FileName[2] = PathDelim) then
  begin
    J := 0;
    I := 3;
    While (I < Length(FileName)) and (J < 2) do
    begin
      if FileName[I] = PathDelim then Inc(J);
      if J < 2 then Inc(I);
    end;
    if FileName[I] = PathDelim then Dec(I);
    Result := Copy(FileName, 1, I);
  end else Result := '';
end;

function WideExtractFileName(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := WideLastDelimiter('\:', FileName);
  Result := Copy(FileName, I + 1, MaxInt);
end;

function WideExtractFileExt(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := WideLastDelimiter('.\:', FileName);
  if (I > 0) and (FileName[I] = '.') then
    Result := Copy(FileName, I, MaxInt) else
    Result := '';
end;

function WideExtractRelativePath(const BaseName, DestName: WideString): WideString;
var
  BasePath, DestPath: WideString;
  BaseLead, DestLead: PWideChar;
  BasePtr, DestPtr: PWideChar;

  function WideExtractFilePathNoDrive(const FileName: WideString): WideString;
  begin
    Result := WideExtractFilePath(FileName);
    Delete(Result, 1, Length(WideExtractFileDrive(FileName)));
  end;

  function Next(var Lead: PWideChar): PWideChar;
  begin
    Result := Lead;
    if Result = nil then Exit;
    Lead := StrScanW(Lead, PathDelim);
    if Lead <> nil then
    begin
      Lead^ := #0;
      Inc(Lead);
    end;
  end;

begin
  if WideSameText(WideExtractFileDrive(BaseName), WideExtractFileDrive(DestName)) then
  begin
    BasePath := WideExtractFilePathNoDrive(BaseName);
    DestPath := WideExtractFilePathNoDrive(DestName);
    BaseLead := Pointer(BasePath);
    BasePtr := Next(BaseLead);
    DestLead := Pointer(DestPath);
    DestPtr := Next(DestLead);
    while (BasePtr <> nil) and (DestPtr <> nil) and WideSameText(BasePtr, DestPtr) do
    begin
      BasePtr := Next(BaseLead);
      DestPtr := Next(DestLead);
    end;
    Result := '';
    while BaseLead <> nil do
    begin
      Result := Result + '..' + PathDelim;             { Do not localize }
      Next(BaseLead);
    end;
    if (DestPtr <> nil) and (DestPtr^ <> #0) then
      Result := Result + DestPtr + PathDelim;
    if DestLead <> nil then
      Result := Result + DestLead;     // destlead already has a trailing backslash
    Result := Result + WideExtractFileName(DestName);
  end
  else
    Result := DestName;
end;

function WideExpandFileName(const FileName: WideString): WideString;
var
  FName: PWideChar;
  Buffer: array[0..MAX_PATH - 1] of WideChar;
begin
  SetString(Result, Buffer, Tnt_GetFullPathNameW(PWideChar(FileName), MAX_PATH, Buffer, FName));
end;

function WideExtractShortPathName(const FileName: WideString): WideString;
var
  Buffer: array[0..MAX_PATH - 1] of WideChar;
begin
  SetString(Result, Buffer, Tnt_GetShortPathNameW(PWideChar(FileName), Buffer, MAX_PATH));
end;

function WideFileCreate(const FileName: WideString): Integer;
begin
  Result := Integer(Tnt_CreateFileW(PWideChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0))
end;

function WideFileOpen(const FileName: WideString; Mode: LongWord): Integer;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := Integer(Tnt_CreateFileW(PWideChar(FileName), AccessMode[Mode and 3],
    ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
end;

function WideFileAge(const FileName: WideString): Integer;
var
  Handle: THandle;
  FindData: TWin32FindDataW;
  LocalFileTime: TFileTime;
begin
  Handle := Tnt_FindFirstFileW(PWideChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
        LongRec(Result).Lo) then Exit;
    end;
  end;
  Result := -1;
end;

function WideDirectoryExists(const Name: WideString): Boolean;
var
  Code: Cardinal;
begin
  Code := WideFileGetAttr(Name);
  Result := (Code <> INVALID_FILE_ATTRIBUTES) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function WideFileExists(const Name: WideString): Boolean;
var
  Code: Cardinal;
begin
  Code := WideFileGetAttr(Name);
  Result := (Code <> INVALID_FILE_ATTRIBUTES) and ((FILE_ATTRIBUTE_DIRECTORY and Code) = 0);
end;

function WideFileGetAttr(const FileName: WideString): Cardinal;
begin
  Result := Tnt_GetFileAttributesW(PWideChar(FileName));
end;

function WideFileSetAttr(const FileName: WideString; Attr: Integer): Boolean;
begin
  Result := Tnt_SetFileAttributesW(PWideChar(FileName), Attr)
end;

function WideForceDirectories(Dir: WideString): Boolean;
begin
  Result := True;
  if Length(Dir) = 0 then
    raise ETntGeneralError.Create(SCannotCreateDir);
  Dir := WideExcludeTrailingBackslash(Dir);
  if (Length(Dir) < 3) or WideDirectoryExists(Dir)
    or (WideExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
  Result := WideForceDirectories(WideExtractFilePath(Dir));
  if Result then
    Result := Tnt_CreateDirectoryW(PWideChar(Dir), nil)
end;

function WideFileSearch(const Name, DirList: WideString): WideString;
var
  I, P, L: Integer;
  C: WideChar;
begin
  Result := Name;
  P := 1;
  L := Length(DirList);
  while True do
  begin
    if WideFileExists(Result) then Exit;
    while (P <= L) and (DirList[P] = PathSep) do Inc(P);
    if P > L then Break;
    I := P;
    while (P <= L) and (DirList[P] <> PathSep) do
      Inc(P);
    Result := Copy(DirList, I, P - I);
    C := WideLastChar(Result);
    if (C <> DriveDelim) and (C <> PathDelim) then
      Result := Result + PathDelim;
    Result := Result + Name;
  end;
  Result := '';
end;

function WideRenameFile(const OldName, NewName: WideString): Boolean;
begin
  Result := Tnt_MoveFileW(PWideChar(OldName), PWideChar(NewName))
end;

function WideDeleteFile(const FileName: WideString): Boolean;
begin
  Result := Tnt_DeleteFileW(PWideChar(FileName))
end;

function WideCopyFile(FromFile, ToFile: WideString; FailIfExists: Boolean): Boolean;
begin
  Result := Tnt_CopyFileW(PWideChar(FromFile), PWideChar(ToFile), FailIfExists)
end;

function _WideFindMatchingFile(var F: TSearchRecW): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not Tnt_FindNextFileW(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := (Int64(FindData.nFileSizeHigh) shl 32) + FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function WideFindFirst(const Path: WideString; Attr: Integer; var F: TSearchRecW): Integer;
const
  faSpecial = faHidden or faSysFile {$IFNDEF COMPILER_9_UP} or faVolumeID {$ENDIF} or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := Tnt_FindFirstFileW(PWideChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := _WideFindMatchingFile(F);
    if Result <> 0 then WideFindClose(F);
  end else
    Result := GetLastError;
end;

function WideFindNext(var F: TSearchRecW): Integer;
begin
  if Tnt_FindNextFileW(F.FindHandle, F.FindData) then
    Result := _WideFindMatchingFile(F) else
    Result := GetLastError;
end;

procedure WideFindClose(var F: TSearchRecW);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;

function WideRemoveDir(const Dir: WideString): Boolean;
begin
  Result := Tnt_RemoveDirectoryW(PWideChar(Dir));
end;

function _ValidDateTimeStrEx(Str: WideString; Flags: Integer): Boolean;
var
  TheDateTime: Double;
begin
  Result := Succeeded(VarDateFromStr(Str, GetThreadLocale, Flags, TheDateTime));
end;

function ValidDateTimeStr(Str: WideString): Boolean;
begin
  Result := _ValidDateTimeStrEx(Str, 0);
end;

function ValidDateStr(Str: WideString): Boolean;
begin
  Result := _ValidDateTimeStrEx(Str, VAR_DATEVALUEONLY);
end;

function ValidTimeStr(Str: WideString): Boolean;
begin
  Result := _ValidDateTimeStrEx(Str, VAR_TIMEVALUEONLY);
end;

function IntStrToDateTime(Str: WideString; Flags: Integer; ErrorFormatStr: WideString): TDateTime;
var
  TheDateTime: Double;
begin
  try
    OleCheck(VarDateFromStr(Str, GetThreadLocale, Flags, TheDateTime));
    Result := TheDateTime;
  except
    on E: Exception do begin
      E.Message := E.Message + CRLF + WideFormat(ErrorFormatStr, [Str]);
      raise EConvertError.Create(E.Message);
    end;
  end;
end;

function TntStrToDateTime(Str: WideString): TDateTime;
begin
  Result := IntStrToDateTime(Str, 0, SInvalidDateTime);
end;

function TntStrToDate(Str: WideString): TDateTime;
begin
  Result := IntStrToDateTime(Str, VAR_DATEVALUEONLY, SInvalidDate);
end;

function TntStrToTime(Str: WideString): TDateTime;
begin
  Result := IntStrToDateTime(Str, VAR_TIMEVALUEONLY, SInvalidTime);
end;

function TryStrToDateTime(Str: WideString; Flags: Integer; out DateTime: TDateTime): Boolean;
var
  ADouble: Double;
begin
  Result := Succeeded(VarDateFromStr(Str, GetThreadLocale, Flags, ADouble));
  if Result then
    DateTime := ADouble;
end;

function TntStrToDateTimeDef(Str: WideString; Default: TDateTime): TDateTime;
begin
  if not TryStrToDateTime(Str, 0, Result) then
    Result := Default;
end;

function TntStrToDateDef(Str: WideString; Default: TDateTime): TDateTime;
begin
  if not TryStrToDateTime(Str, VAR_DATEVALUEONLY, Result) then
    Result := Default;
end;

function TntStrToTimeDef(Str: WideString; Default: TDateTime): TDateTime;
begin
  if not TryStrToDateTime(Str, VAR_TIMEVALUEONLY, Result) then
    Result := Default;
end;

function TntCurrToStr(Value: Currency; lpFormat: PCurrencyFmtW = nil): WideString;
const
  MAX_BUFF_SIZE = 64; // can a currency string actually be larger?
var
  ValueStr: WideString;
begin
  // format lpValue using ENG-US settings
  ValueStr := ENG_US_FloatToStr(Value);
  // get currency format
  SetLength(Result, MAX_BUFF_SIZE);
  if 0 = Tnt_GetCurrencyFormatW(GetThreadLocale, 0, PWideChar(ValueStr),
    lpFormat, PWideChar(Result), Length(Result))
  then begin
    RaiseLastOSError;
  end;
  Result := PWideChar(Result);
end;

function TntStrToCurr(const S: WideString): Currency;
begin
  try
    OleCheck(VarCyFromStr(S, GetThreadLocale, 0, Result));
  except
    on E: Exception do begin
      E.Message := E.Message + CRLF + WideFormat(SInvalidCurrency, [S]);
      raise EConvertError.Create(E.Message);
    end;
  end;
end;

function ValidCurrencyStr(const S: WideString): Boolean;
var
  Dummy: Currency;
begin
  Result := Succeeded(VarCyFromStr(S, GetThreadLocale, 0, Dummy));
end;

function TntStrToCurrDef(const S: WideString; const Default: Currency): Currency;
begin
  if not Succeeded(VarCyFromStr(S, GetThreadLocale, 0, Result)) then
    Result := Default;
end;

threadvar
  Currency_DecimalSep: WideString;
  Currency_ThousandSep: WideString;
  Currency_CurrencySymbol: WideString;

function GetDefaultCurrencyFmt: TCurrencyFmtW;
begin
  ZeroMemory(@Result, SizeOf(Result));
  Result.NumDigits := StrToIntDef(WideGetLocaleStr(GetThreadLocale, LOCALE_ICURRDIGITS, '2'), 2);
  Result.LeadingZero := StrToIntDef(WideGetLocaleStr(GetThreadLocale, LOCALE_ILZERO, '1'), 1);
  Result.Grouping := StrToIntDef(Copy(WideGetLocaleStr(GetThreadLocale, LOCALE_SMONGROUPING, '3;0'), 1, 1), 3);
  Currency_DecimalSep := WideGetLocaleStr(GetThreadLocale, LOCALE_SMONDECIMALSEP, '.');
  Result.lpDecimalSep := PWideChar(Currency_DecimalSep);
  Currency_ThousandSep := WideGetLocaleStr(GetThreadLocale, LOCALE_SMONTHOUSANDSEP, ',');
  Result.lpThousandSep := PWideChar(Currency_ThousandSep);
  Result.NegativeOrder := StrToIntDef(WideGetLocaleStr(GetThreadLocale, LOCALE_INEGCURR, '0'), 0);
  Result.PositiveOrder := StrToIntDef(WideGetLocaleStr(GetThreadLocale, LOCALE_ICURRENCY, '0'), 0);
  Currency_CurrencySymbol := WideGetLocaleStr(GetThreadLocale, LOCALE_SCURRENCY, '');
  Result.lpCurrencySymbol := PWideChar(Currency_CurrencySymbol);
end;

function WideGetLocaleStr(LocaleID: LCID; LocaleType: Integer; const Default: WideString): WideString;
var
  L: Integer;
begin
  if (not Win32PlatformIsUnicode) then
    Result := GetLocaleStr{TNT-ALLOW GetLocaleStr}(LocaleID, LocaleType, Default)
  else begin
    SetLength(Result, 255);
    L := GetLocaleInfoW(LocaleID, LocaleType, PWideChar(Result), Length(Result));
    if L > 0 then
      SetLength(Result, L - 1)
    else
      Result := Default;
  end;
end;

{$IFNDEF COMPILER_7_UP}
function CheckWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;
begin
  Result := (Win32MajorVersion > AMajor) or
            ((Win32MajorVersion = AMajor) and
             (Win32MinorVersion >= AMinor));
end;
{$ENDIF}

function WinCheckH(RetVal: Cardinal): Cardinal;
begin
  if RetVal = 0 then RaiseLastOSError;
  Result := RetVal;
end;

function WinCheckFileH(RetVal: Cardinal): Cardinal;
begin
  if RetVal = INVALID_HANDLE_VALUE then RaiseLastOSError;
  Result := RetVal;
end;

function WinCheckP(RetVal: Pointer): Pointer;
begin
  if RetVal = nil then RaiseLastOSError;
  Result := RetVal;
end;

function WideGetModuleFileName(Instance: HModule): WideString;
begin
  SetLength(Result, MAX_PATH);
  WinCheckH(Tnt_GetModuleFileNameW(Instance, PWideChar(Result), Length(Result)));
  Result := PWideChar(Result)
end;

function WideSafeLoadLibrary(const Filename: Widestring; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode := SetErrorMode(ErrorMode);
  try
    asm
      FNSTCW  FPUControlWord
    end;
    try
      Result := Tnt_LoadLibraryW(PWideChar(Filename));
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function WideLoadPackage(const Name: Widestring): HMODULE;
begin
  Result := WideSafeLoadLibrary(Name);
  if Result = 0 then
  begin
    raise EPackageError.CreateFmt(sErrorLoadingPackage, [Name, SysErrorMessage(GetLastError)]);
  end;
  try
    InitializePackage(Result);
  except
    FreeLibrary(Result);
    raise;
  end;
end;

function _WideCharType(WC: WideChar; dwInfoType: Cardinal): Word;
begin
  Win32Check(Tnt_GetStringTypeExW(GetThreadLocale, dwInfoType, PWideChar(@WC), 1, Result))
end;

function IsWideCharUpper(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_UPPER) <> 0;
end;

function IsWideCharLower(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_LOWER) <> 0;
end;

function IsWideCharDigit(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_DIGIT) <> 0;
end;

function IsWideCharSpace(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_SPACE) <> 0;
end;

function IsWideCharPunct(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_PUNCT) <> 0;
end;

function IsWideCharCntrl(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_CNTRL) <> 0;
end;

function IsWideCharBlank(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_BLANK) <> 0;
end;

function IsWideCharXDigit(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_XDIGIT) <> 0;
end;

function IsWideCharAlpha(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_ALPHA) <> 0;
end;

function IsWideCharAlphaNumeric(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and (C1_ALPHA + C1_DIGIT)) <> 0;
end;

function WideTextPos(const SubStr, S: WideString): Integer;
begin
  Result := Pos(Tnt_WideUpperCase(SubStr), Tnt_WideUpperCase(S));
end;

function FindDoubleTerminator(P: PWideChar): PWideChar;
begin
  Result := P;
  while True do begin
    Result := StrScanW(Result, #0);
    Inc(Result);
    if Result^ = #0 then begin
      Dec(Result);
      break;
    end;
  end;
end;

function ExtractStringArrayStr(P: PWideChar): WideString;
var
  PEnd: PWideChar;
begin
  PEnd := FindDoubleTerminator(P);
  Inc(PEnd, 2); // move past #0#0
  SetString(Result, P, PEnd - P);
end;

function ExtractStringFromStringArray(var P: PWideChar; Separator: WideChar = #0): WideString;
var
  Start: PWideChar;
begin
  Start := P;
  P := StrScanW(Start, Separator);
  if P = nil then begin
    Result := Start;
    P := StrEndW(Start);
  end else begin
    SetString(Result, Start, P - Start);
    Inc(P);
  end;
end;

function ExtractStringsFromStringArray(P: PWideChar; Separator: WideChar = #0): TWideStringDynArray;
const
  GROW_COUNT = 256;
var
  Count: Integer;
  Item: WideString;
begin
  Count := 0;
  SetLength(Result, GROW_COUNT);
  Item := ExtractStringFromStringArray(P, Separator);
  While Item <> '' do begin
    if Count > High(Result) then
      SetLength(Result, Length(Result) + GROW_COUNT);
    Result[Count] := Item;
    Inc(Count);
    Item := ExtractStringFromStringArray(P, Separator);
  end;
  SetLength(Result, Count);
end;

function IsWideCharMappableToAnsi(const WC: WideChar): Boolean;
var
  UsedDefaultChar: BOOL;
begin
  WideCharToMultiByte(DefaultUserCodePage, 0, PWideChar(@WC), 1, nil, 0, nil, @UsedDefaultChar);
  Result := not UsedDefaultChar;
end;

function IsWideStringMappableToAnsi(const WS: WideString): Boolean;
var
  UsedDefaultChar: BOOL;
begin
  WideCharToMultiByte(DefaultUserCodePage, 0, PWideChar(WS), Length(WS), nil, 0, nil, @UsedDefaultChar);
  Result := not UsedDefaultChar;
end;

function IsRTF(const Value: WideString): Boolean;
const
  RTF_BEGIN_1  = WideString('{\RTF');
  RTF_BEGIN_2  = WideString('{URTF');
begin
  Result := (WideTextPos(RTF_BEGIN_1, Value) = 1)
         or (WideTextPos(RTF_BEGIN_2, Value) = 1);
end;

{$IFDEF COMPILER_7_UP}
var
  Cached_ENG_US_FormatSettings: TFormatSettings;
  Cached_ENG_US_FormatSettings_Time: Cardinal;

function ENG_US_FormatSettings: TFormatSettings;
begin
  if Cached_ENG_US_FormatSettings_Time = _SettingChangeTime then
    Result := Cached_ENG_US_FormatSettings
  else begin
    GetLocaleFormatSettings(MAKELCID(MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US)), Result);
    Result.DecimalSeparator := '.'; // ignore overrides
    Cached_ENG_US_FormatSettings := Result;
    Cached_ENG_US_FormatSettings_Time := _SettingChangeTime;
  end;
 end;

function ENG_US_FloatToStr(Value: Extended): WideString;
begin
  Result := FloatToStr(Value, ENG_US_FormatSettings);
end;

function ENG_US_StrToFloat(const S: WideString): Extended;
begin
  if not TextToFloat(PAnsiChar(AnsiString(S)), Result, fvExtended, ENG_US_FormatSettings) then
    Result := StrToFloat(S); // try using native format
end;

{$ELSE}

function ENG_US_FloatToStr(Value: Extended): WideString;
var
  SaveDecimalSep: AnsiChar;
begin
  SaveDecimalSep := SysUtils.DecimalSeparator;
  try
    SysUtils.DecimalSeparator := '.';
    Result := FloatToStr(Value);
  finally
    SysUtils.DecimalSeparator := SaveDecimalSep;
  end;
end;

function ENG_US_StrToFloat(const S: WideString): Extended;
var
  SaveDecimalSep: AnsiChar;
begin
  try
    SaveDecimalSep := SysUtils.DecimalSeparator;
    try
      SysUtils.DecimalSeparator := '.';
      Result := StrToFloat(S);
    finally
      SysUtils.DecimalSeparator := SaveDecimalSep;
    end;
  except
    if SysUtils.DecimalSeparator <> '.' then
      Result := StrToFloat(S) // try using native format
    else
      raise;
  end;
end;
{$ENDIF}

//---------------------------------------------------------------------------------------------
//                                 Tnt - Variants
//---------------------------------------------------------------------------------------------

{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
function VarToWideStr(const V: Variant): WideString;
begin
  Result := VarToWideStrDef(V, '');
end;

function VarToWideStrDef(const V: Variant; const ADefault: WideString): WideString;
begin
  if not VarIsNull(V) then
    Result := V
  else
    Result := ADefault;
end;
{$ENDIF}

initialization
  Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  Win32PlatformIsXP := ((Win32MajorVersion = 5) and (Win32MinorVersion >= 1))
                    or  (Win32MajorVersion > 5);

finalization
  Currency_DecimalSep := ''; {make memory sleuth happy}
  Currency_ThousandSep := ''; {make memory sleuth happy}
  Currency_CurrencySymbol := ''; {make memory sleuth happy}

end.
