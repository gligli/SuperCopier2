unit SCCommon;

//{$include 'SCBuildConfig.inc'}
{$DEFINE DEBUG}

interface

uses
  Windows,SCWin32;

type
  TConfigLocation=(clRegistry,clIniFile);

  TBaselistAddMode=(amDefaultDir,amSpecifyDest,amPromptForDest,amPromptForDestAndSetDefault);

  TCopyListHandlingMode=(chmNever,chmAlways,chmSameSource,chmSameDestination,chmSameSourceAndDestination,chmSameSourceorDestination);

  TCopyAction=(cpaNextFile,cpaRetry,cpaCancel);
  TCollisionAction=(claNone,claCancel,claSkip,claResume,claOverwrite,claOverwriteIfDifferent,claRenameNew,claRenameOld);
  TCopyErrorAction=(ceaNone,ceaCancel,ceaSkip,ceaRetry,ceaEndOfList);
  TDiskSpaceAction=(dsaNone,dsaCancel,dsaForce);

  TCopyWindowState=(cwsWaiting,cwsRecursing,cwsCopying,cwsPaused,cwsWaitingActionResult,cwsCancelling);
  TCopyWindowCopyEndAction=(cweClose,cweDontClose,cweDontCloseIfErrors);

  TCopyWindowConfigData=record
    CopyEndAction:TCopyWindowCopyEndAction;
    ThrottleEnabled:Boolean;
    ThrottleSpeedLimit:Integer;
    CollisionAction:TCollisionAction;
    CopyErrorAction:TCopyErrorAction;
  end;

  TErrorLogAutoSaveMode=(eamToDestDir,eamToSrcDir,eamCustomDir);

  TDiskSpaceWarningVolume=record
    Volume:WideString;
    VolumeSize:Int64;
    FreeSize:Int64;
    LackSize:Int64;
  end;
  TDiskSpaceWarningVolumeArray=array of TDiskSpaceWarningVolume;

  TSizeUnit=(suAuto,suBytes,suKB,suMB,suGB);

  TMinimizedEventHandling=(mehDoNothing,mehShowBalloon,mehPopupWindow);

const
  DEFAULT_WAIT=20; //ms
  SCL_SIGNATURE='SC2 CopyList    ';
  SCL_SIGNATURE_LENGTH=Length(SCL_SIGNATURE);

function GetFileSizeByName(FileName:WideString):Int64;
function SetFileSize(TheFile:THandle;Size:Int64):Boolean;
function BrowseForFolder(Caption:WideString;var Folder:WideString;OwnerWindowHandle:THandle):boolean;
function GetLastErrorText:WideString;
function SizeToString(Size:int64;SizeUnit:TSizeUnit=suAuto):WideString;
function PaddedIntToStr(Int,Width:Integer):WideString;
function PatternRename(FileName,Path,Pattern:WideString):WideString;
function GetVolumeReadableName(Volume:WideString):WideString;
function GetStorageDeviceNumber(Path:WideString;var SDN:TStorageDeviceNumber):Boolean;
function GetVolumeNameString(Path:WideString):WideString;
function SameVolume(Path1,Path2:WideString):boolean;
function SamePhysicalDrive(Path1,Path2:WideString):boolean;
procedure SetProcessPriority(Priority:Cardinal);
function CopySecurity(const SourceFile:WideString;const DestFile:WideString):Boolean;
function GetOSLanguageName:String;

procedure dbg(msg:string);overload;
procedure dbg(val:cardinal);overload;
procedure dbgln(msg:string='');overload;
procedure dbgln(val:cardinal);overload;
procedure dbgmem(buf:pointer;size:integer);

implementation

uses
  SysUtils,TntSysutils, StrUtils,ShellApi,ShlObj,Classes,Forms, Math,SCLocStrings;

{$ifdef DEBUG}
var
  DbgLock:TRTLCriticalSection;
{$endif}

//******************************************************************************
// GetFileSizeByName: renvoie la taille d'un fichier � partir de son nom
//******************************************************************************
function GetFileSizeByName(FileName:WideString):Int64;
var FindData:TWin32FindDataW;
    FindHandle:THandle;
begin
  Result:=0;
  FindHandle:=SCWin32.FindFirstFile(PWideChar(FileName),FindData);
  if FindHandle = INVALID_HANDLE_VALUE then exit;
  Result:=FindData.nFileSizeLow;
  Result:=(Result and $FFFFFFFF) or (FindData.nFileSizeHigh * $100000000);
  Windows.FindClose(FindHandle);
end;

//******************************************************************************
// SetFileSize: Fixe la taille d'un fichier ouvert
//******************************************************************************
function SetFileSize(TheFile:THandle;Size:Int64):Boolean;
var PrevPos:Int64;
begin
  Result:=False;
  SetLastError(ERROR_SUCCESS);

  // on r�cup la position courrante dans le fichier
  PrevPos:=SetFilePointer(TheFile,0,FILE_CURRENT);
  if GetLastError<>ERROR_SUCCESS then Exit;

  // on se positionne a l'endroit ou on veut marquer la fin du fichier
  SetFilePointer(TheFile,Size,FILE_BEGIN);
  if GetLastError<>ERROR_SUCCESS then Exit;

  // on marque la fin du fichier
  if not SetEndOfFile(TheFile) then Exit;

  // on revient � la pos pr�c�dente
  SetFilePointer(TheFile,PrevPos,FILE_BEGIN);
  if GetLastError<>ERROR_SUCCESS then Exit;

  Result:=True;
end;

//******************************************************************************
// BrowseForFolder: afficher un dialogue permettant de s�lectionner un r�pertoire
//******************************************************************************

  function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  var Msg:Cardinal;
  begin
    if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    begin
      Msg:=IfThen(Win32Platform=VER_PLATFORM_WIN32_NT,BFFM_SETSELECTIONW,BFFM_SETSELECTIONA);
      SendMessage(Wnd, Msg, Integer(True), lpdata);
    end;
    result := 0;
  end;

function BrowseForFolder(Caption:WideString;var Folder:WideString;OwnerWindowHandle:THandle):boolean;
var BrowseInfo:_browseinfoW;
    Item:PItemIDList;
    Buffer:array[0..MAX_PATH] of WideChar;
begin
  Result:=False;

  with BrowseInfo do
  begin
    hwndOwner:=OwnerWindowHandle;
    pidlRoot:=nil;
    pszDisplayName:=nil;
    lpszTitle:=PWideChar(Caption);
    ulFlags:=BIF_RETURNONLYFSDIRS or BIF_EDITBOX or BIF_NEWDIALOGSTYLE;
    lpfn:=nil;

    if Folder <> '' then
    begin
      lpfn := SelectDirCB;
      lParam := Integer(PWideChar(Folder));
    end;
  end;

  Item:=SCWin32.SHBrowseForFolder(BrowseInfo);

  if Item<>nil then
  begin
    Result:=SCWin32.SHGetPathFromIDList(Item,Buffer);
    if Result then Folder:=Buffer;
  end;
end;

//******************************************************************************
// GetLastErrorText: renvoie la derni�re erreur windows sous forme de texte
//******************************************************************************
function GetLastErrorText:WideString;
begin
  Result:=SysErrorMessage(GetLastError); //TODO: gestion ansi/wide (FormatMessage)
end;

//*********************************************************************************
// SizeToString: renvoie en chaine une taille sp�cifi�e en octets
//*********************************************************************************
function SizeToString(Size:int64;SizeUnit:TSizeUnit=suAuto):WideString;
const
  SIZE_FORMAT=',0.00 ';
begin
  if SizeUnit=suAuto then
  begin
    if Size>=1024*1024*1024 then // >= 1Go
    begin
      SizeUnit:=suGB;
    end
    else if Size>=1024*1024 then // >= 1Mo
    begin
      SizeUnit:=suMB;
    end
    else if Size>=1024 then // >= 1Ko
    begin
      SizeUnit:=suKB;
    end
    else
    begin
      SizeUnit:=suBytes;
    end;
  end;

  case SizeUnit of
    suGB:
      Result:=FormatFloat(SIZE_FORMAT,Size/(1024*1024*1024))+lsGBytes;
    suMB:
      Result:=FormatFloat(SIZE_FORMAT,Size/(1024*1024))+lsMBytes;
    suKB:
      Result:=FormatFloat(SIZE_FORMAT,Size/1024)+lsKBytes;
    suBytes:
      Result:=FormatFloat(',0 ',Size)+lsBytes;
  end;
end;

//*********************************************************************************
// PaddedIntToStr: renvoie en chaine de taille fixe compl�t�e par des 0 un entier
//*********************************************************************************
function PaddedIntToStr(Int,Width:Integer):WideString;
var StrInt:WideString;
begin
  StrInt:=IntToStr(Int);
  Result:=StringOfChar('0',Width-Length(StrInt))+StrInt;
end;

//******************************************************************************
// PatternRename: trouve un nouveau nom au fichier en fonction du pattern
//******************************************************************************
function PatternRename(FileName,Path,Pattern:WideString):WideString;
var TmpStr,Tag:WideString;
    i,SharpCount,NumberWidth:Integer;
    Found,InTag:Boolean;
    C:WideChar;
begin
  // on remplace les tags qui ont une valeur 'fixe' et on marque la position du num�ro incr�mentiel
  i:=1;
  InTag:=False;
  TmpStr:='';
  NumberWidth:=0;
  SharpCount:=0;
  while (i<=Length(Pattern))do
  begin
    C:=Pattern[i];
    case C of
      '<':
      begin
        InTag:=True;
        Tag:='';
        SharpCount:=0;
      end;
      '>':
      begin
        InTag:=False;

        if SharpCount>0 then
        begin
          TmpStr:=TmpStr+'?';
          NumberWidth:=SharpCount;
        end
        else if Tag='full' then
          TmpStr:=TmpStr+FileName
        else if Tag='name' then
        begin
          if Pos('.',FileName)>0 then // le fichier a une extension?
            TmpStr:=TmpStr+LeftStr(FileName,Pos('.',FileName)-1)
          else
            TmpStr:=FileName;
        end
        else if Tag='ext' then
          TmpStr:=TmpStr+MidStr(WideExtractFileExt(FileName),2,MaxInt); // enlever le '.' de l'extension
      end;
      '#':
      begin
        if InTag then Inc(SharpCount);
      end;
      else
      begin
        if not InTag then
          TmpStr:=TmpStr+C
        else
          Tag:=Tag+WideLowerCase(C);
      end;
    end;
    Inc(i);
  end;

  dbgln(TmpStr);

  // on cherche maintenant un nom incr�mentiel libre si besoin
  if NumberWidth>0 then
  begin
    i:=1;
    Found:=True;
    while Found do
    begin
      Result:=StringReplace(TmpStr,'?',PaddedIntToStr(i,NumberWidth),[rfReplaceAll]);
      Found:=WideFileExists(Path+Result);
      Inc(i);
    end;
  end
  else
  begin
    Result:=TmpStr;
  end;

  dbgln(Result);
end;

//*********************************************************************************
// GetVolumeReadableName: renvoie une forme 'user friendly' du nom de volume
//*********************************************************************************
function GetVolumeReadableName(Volume:WideString):WideString;
var Buf:array[0..64] of WideChar;
    Dummy:cardinal;
    Ok:Boolean;
begin
  Result:=Volume;
  if Pos('\\',Volume)=0 then
  begin
    Ok:=SCWin32.GetVolumeInformation(PWideChar(WideIncludeTrailingBackslash(Volume)),@Buf,64,nil,Dummy,Dummy,nil,0);
    if Ok then Result:=Buf+' ('+UpperCase(Volume)+')';
  end;
end;

//******************************************************************************
// GetStorageDeviceNumber: r�cup�re le num�ro du p�riph�rique sur lequel pointe Path
//                         renvoie false si �choue
//******************************************************************************
function GetStorageDeviceNumber(Path:WideString;var SDN:TStorageDeviceNumber):Boolean;
var Handle:THandle;
    Dummy:Cardinal;
    TmpBuf:array[0..MAX_PATH] of WideChar;
begin
  Result:=False;

  if GetVolumePathName(PWideChar(Path),TmpBuf,MAX_PATH) and
     GetVolumeNameForVolumeMountPoint(TmpBuf,TmpBuf,MAX_PATH) then // on r�cup�re d'abord le guid de volume
  begin
    Handle:=CreateFileW(PWideChar(WideExcludeTrailingBackslash(TmpBuf)),0,FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_EXISTING,0,0);
    if Handle<>INVALID_HANDLE_VALUE then
    begin
      Result:=DeviceIoControl(Handle,IOCTL_STORAGE_GET_DEVICE_NUMBER,nil,0,@SDN,SizeOf(TStorageDeviceNumber),Dummy,nil);
      CloseHandle(Handle);
    end;
  end;
end;

//******************************************************************************
// GetVolumeNameString: renvoie le nom de volume d'un chemin
//******************************************************************************
function GetVolumeNameString(Path:WideString):WideString;
var TmpBuf:array[0..MAX_PATH] of WideChar;
begin
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=5) and
     GetVolumePathName(PWideChar(Path),TmpBuf,MAX_PATH) then
  begin
    // pour windows 2000 et sup�rieurs
    Result:=TmpBuf;
  end
  else
  begin
    // pour Win NT4/9x ou si probl�me
    Result:=WideExtractFileDrive(Path);
  end;
end;

//******************************************************************************
// SameVolume: renvoie true si les 2 chemins sont situ�s sur le m�me volume
//******************************************************************************
function SameVolume(Path1,Path2:WideString):boolean;
var TmpBuf,TmpBuf2:array[0..MAX_PATH] of WideChar;
begin
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=5) and
     GetVolumePathName(PWideChar(Path1),TmpBuf,MAX_PATH) and
     GetVolumePathName(PWideChar(Path2),TmpBuf2,MAX_PATH) and
     GetVolumeNameForVolumeMountPoint(TmpBuf,TmpBuf,MAX_PATH) and
     GetVolumeNameForVolumeMountPoint(TmpBuf2,TmpBuf2,MAX_PATH) then
  begin
    // pour windows 2000 et sup�rieurs, on compare le guid de volume
    Result:=StrCompW(TmpBuf,TmpBuf2)=0;
  end
  else
  begin
    // pour Win NT4/9x ou si probl�me, on fait une simple comparaison de texte
    Result:=WideExtractFileDrive(Path1)=WideExtractFileDrive(Path2);
  end;
end;

//******************************************************************************
// SamePhysicalDrive: renvoie true si les 2 chemins sont situ�s sur le m�me emplacement physique
//******************************************************************************
function SamePhysicalDrive(Path1,Path2:WideString):boolean;
var SDN1,SDN2:TStorageDeviceNumber;
begin
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=5) and
     GetStorageDeviceNumber(Path1,SDN1) and
     GetStorageDeviceNumber(Path2,SDN2) then
  begin
    // pour windows 2000 et sup�rieurs, on compare le num�ro de pr�riph�rique
    Result:=(SDN1.DeviceType=SDN2.DeviceType) and (SDN1.DeviceNumber=SDN2.DeviceNumber);
  end
  else
  begin
    // pour Win NT4/9x ou si probl�me, on fait une simple comparaison de texte
    Result:=WideExtractFileDrive(Path1)=WideExtractFileDrive(Path2);
  end;
end;

//******************************************************************************
// SetProcessPriority: channde la priorit� du processus
//******************************************************************************
procedure SetProcessPriority(Priority:Cardinal);
var ph:THandle;
begin
  ph:=OpenProcess(PROCESS_SET_INFORMATION,False,GetCurrentProcessId);
  if ph=0 then exit;
  SetPriorityClass(ph,Priority);
  CloseHandle(ph);
end;

//******************************************************************************
// CopySecurity: copie les infos de s�curit� d'un fichier ou dossier vers un autre
//******************************************************************************
function CopySecurity(const SourceFile:WideString;const DestFile:WideString):Boolean;
var SD:array of byte;
    SDR:TSecurityDescriptor;
    LengthNeeded:Cardinal;
    LastError:Cardinal;
begin
  // on tente de lire le SecutityDescriptor avec un buffer de 256 octets
  SetLength(SD,256);
  Result:=GetFileSecurityW(PWideChar(SourceFile),
                    DACL_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or
                    OWNER_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
                    @SD[0],
                    Length(SD),
                    LengthNeeded);

  // si le buffer �tait trop petit, on donne au buffer la taille n�cessaire
  if (not Result) and (GetLastError=ERROR_INSUFFICIENT_BUFFER) then
  begin
    SetLength(SD,LengthNeeded);
    Result:=GetFileSecurityW(PWideChar(SourceFile),
                      DACL_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or
                      OWNER_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
                      @SD[0],
                      Length(SD),
                      LengthNeeded);
  end;

  // on peut maintenant copier le SD vers le fichier destination
  if Result then
  begin
    SDR:=PSecurityDescriptor(@SD[0])^;
    if (SDR.Sacl<>nil) or (SDR.Dacl<>nil) then
    begin
      Result:=SetFileSecurityW(PWideChar(DestFile),
                        DACL_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or
                        OWNER_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
                        @SD[0]);
    end;
  end;

  // �chouer silencieusmeent si l'on a pas le droit de lire ou �crire la s�curit�
  LastError:=GetLastError;
  if not Result and
      (LastError=ERROR_ACCESS_DENIED) or
      (LastError=ERROR_PRIVILEGE_NOT_HELD) or
      (LastError=ERROR_INVALID_OWNER) or
      (LastError=ERROR_INVALID_PRIMARY_GROUP) then Result:=True;


  SetLength(SD,0);
end;

//******************************************************************************
// GetOSLanguageName: renvoie le nom de la langue de l'OS dans la langue de l'OS
//******************************************************************************
function GetOSLanguageName:String;
var LID:LANGID;
    TmpBuf:array[0..254] of char;
begin
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=5) then
    LID:=GetSystemDefaultUILanguage
  else
    LID:=GetSystemDefaultLangID;

  VerLanguageName(LID,TmpBuf,Length(TmpBuf));
  Result:=TmpBuf;
  Result:=LeftStr(Result,Pos(' (',Result)-1);
end;

//******************************************************************************
//******************************************************************************
// Proc�dures de debug
//******************************************************************************
//******************************************************************************

procedure dbg(msg:string);overload;
begin
{$ifdef DEBUG}
  EnterCriticalSection(DbgLock);
  try
    Write(msg);
  finally
    LeaveCriticalSection(DbgLock);
  end;
{$endif}
end;

procedure dbg(val:cardinal);overload;
begin
{$ifdef DEBUG}
  dbg(inttostr(val));
{$endif}
end;

procedure dbgln(msg:string='');overload;
begin
{$ifdef DEBUG}
  dbg(msg+#13#10);
{$endif}
end;

procedure dbgln(val:cardinal);overload;
begin
{$ifdef DEBUG}
  dbg(inttostr(val)+#13#10);
{$endif}
end;

procedure dbgmem(buf:pointer;size:integer);
{$ifdef DEBUG}
var
    i,j:integer;
    ptr:pbyte;
    outstr:string;
{$endif}
begin
{$ifdef DEBUG}
  outstr:='';
  i:=0;
  ptr:=PByte(buf);
  while i<size do
  begin
    for j:=0 to 15 do
    begin
      outstr:=outstr+inttohex(ptr^,2)+' ';
      ptr:=pointer(cardinal(ptr)+1);
    end;
    ptr:=pointer(cardinal(ptr)-16);
    for j:=0 to 15 do
    begin
      if ptr^>=32 then outstr:=outstr+char(ptr^) else outstr:=outstr+'.';
      ptr:=pointer(cardinal(ptr)+1);
    end;
    outstr:=outstr+#13#10;
    Inc(i,16);
  end;

  dbg(outstr);
{$endif}
end;

initialization
{$ifdef DEBUG}
  AllocConsole;
  InitializeCriticalSection(DbgLock);
{$endif}

finalization
{$ifdef DEBUG}
  DeleteCriticalSection(DbgLock);
{$endif}

end.
