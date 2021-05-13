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

unit SCWin32;
// Surcouche a l'api Win32 permettant de gérer l'unicode, win9x et les int64
// (je maudis Microsoft sur 7 generations pour etre oblige de faire ça :)

interface

uses
  Windows,Shellapi,ShlObj;

const
  IOCTL_STORAGE_BASE=$2D;
  METHOD_BUFFERED=0;
  FILE_ANY_ACCESS=0;
  IOCTL_STORAGE_GET_DEVICE_NUMBER = (IOCTL_STORAGE_BASE shl 16) or (FILE_ANY_ACCESS shl 14) or ($0420 shl 2) or (METHOD_BUFFERED);

type
  TGetVolumePathNameW=function(lpszFileName,lpszVolumePathName:PWideChar;cchBufferLength:Cardinal):LongBool;stdcall;
  TGetVolumeNameForVolumeMountPointW=function(lpszVolumeMountPoint,lpszVolumeName:PWideChar;cchBufferLength:Cardinal):LongBool;stdcall;
  TGetSystemDefaultUILanguage=function:LANGID;stdcall;

  TStorageDeviceNumber=record
		DeviceType:DWORD;
		DeviceNumber:cardinal;
		PartitionNumber:cardinal;
	end;

function GetFileSize(TheFile:THandle):Int64;
function SetFilePointer(TheFile:THandle;DistanceToMove:Int64;MoveMethod:Cardinal):Int64;
function GetFileAttributes(FileName:PWideChar):Integer;
function SetFileAttributes(FileName:PWideChar;Attr:Cardinal):Boolean;
function DeleteFile(FileName:PWideChar):Boolean;
function CreateDirectory(DirName:PWideChar;PSA:PSecurityAttributes):Boolean;
function RemoveDirectory(DirName:PWideChar):Boolean;
function GetDiskFreeSpaceEx(DirName:PWideChar;var FreeBytesAvailable;var TotalNumberOfBytes;TotalNumberOfFreeBytes:PLargeInteger):Boolean;
function MoveFile(Source,Dest:PWideChar):Boolean;
function DragQueryFile(hDrop:HDROP;iFile:Cardinal;lpszFile:PWideChar;cch:Cardinal):Cardinal;
function FindFirstFile(lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle;
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindDataW): Boolean;
function SHGetPathFromIDList(pidl:PItemIDList;pszPath:PWideChar):LongBool;
function SHBrowseForFolder(var lpbi:_browseinfoW):PItemIDList;
function GetVolumeInformation(lpRootPathName: PWideChar;
  lpVolumeNameBuffer: PWideChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PWideChar; nFileSystemNameSize: DWORD): BOOL;
function MessageBox(hWnd: HWND; lpText, lpCaption: WideString; uType: UINT): Integer;
function GetTempPath:WideString;
function CopyFile(lpExistingFileName, lpNewFileName: PWideChar; bFailIfExists: BOOL): BOOL;
function PathIsUNC(pszPath:PWideChar):LongBool;

var
  HKernel32_dll:Cardinal;

  // fonctions non déclarées sous tous les windows, appel dynamique obligatoire
  GetVolumePathName:TGetVolumePathNameW;
  GetVolumeNameForVolumeMountPoint:TGetVolumeNameForVolumeMountPointW;
  GetSystemDefaultUILanguage:TGetSystemDefaultUILanguage;

implementation

uses TntWindows,Sysutils,SCCommon;

function PathIsUNCA(pszPath:PChar):LongBool;stdcall;external 'shlwapi.dll' name 'PathIsUNCA';
function PathIsUNCW(pszPath:PWideChar):LongBool;stdcall;external 'shlwapi.dll' name 'PathIsUNCW';

//******************************************************************************
// GetFileSize
//******************************************************************************
function GetFileSize(TheFile:THandle):Int64;
var SizeHigh:cardinal;
    ResRec:Int64Rec absolute Result;
begin
  Result:=0;
  ResRec.Lo:=Windows.GetFileSize(TheFile,@SizeHigh);
  ResRec.Hi:=SizeHigh;

  if ResRec.Lo=INVALID_FILE_SIZE then Result:=0;
end;


//******************************************************************************
// SetFilePointer
//******************************************************************************
function SetFilePointer(TheFile:THandle;DistanceToMove:Int64;MoveMethod:Cardinal):Int64;
var HiPart,LoPart:Cardinal;
    ResRec:Int64Rec absolute Result;
begin
  LoPart:=Int64Rec(DistanceToMove).Lo;
  HiPart:=Int64Rec(DistanceToMove).Hi;

  ResRec.Lo:=Windows.SetFilePointer(TheFile,LoPart,@HiPart,MoveMethod);
  ResRec.Hi:=HiPart;
end;

//******************************************************************************
// GetFileAttributes
//******************************************************************************
function GetFileAttributes(FileName:PWideChar):Integer;
begin
  Result:=Tnt_GetFileAttributesW(FileName);
end;

//******************************************************************************
// SetFileAttributes
//******************************************************************************
function SetFileAttributes(FileName:PWideChar;Attr:Cardinal):Boolean;
begin
  Result:=Tnt_SetFileAttributesW(FileName,Attr);
end;

//******************************************************************************
// DeleteFile
//******************************************************************************
function DeleteFile(FileName:PWideChar):Boolean;
begin
  Tnt_SetFileAttributesW(FileName,FILE_ATTRIBUTE_NORMAL);
  Result:=Tnt_DeleteFileW(FileName);
end;

//******************************************************************************
// CreateDirectory
//******************************************************************************
function CreateDirectory(DirName:PWideChar;PSA:PSecurityAttributes):Boolean;
begin
  Result:=Tnt_CreateDirectoryW(DirName,PSA);
end;

//******************************************************************************
// RemoveDirectory
//******************************************************************************
function RemoveDirectory(DirName:PWideChar):Boolean;
begin
  Result:=Tnt_RemoveDirectoryW(DirName);
end;

//******************************************************************************
// GetDiskFreeSpaceEx
//******************************************************************************
function GetDiskFreeSpaceEx(DirName:PWideChar;var FreeBytesAvailable;var TotalNumberOfBytes;TotalNumberOfFreeBytes:PLargeInteger):Boolean;
begin
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    Result:=Windows.GetDiskFreeSpaceExW(DirName,FreeBytesAvailable,TotalNumberOfBytes,TotalNumberOfFreeBytes)
  else
    Result:=Windows.GetDiskFreeSpaceEx(PChar(String(DirName)),FreeBytesAvailable,TotalNumberOfBytes,TotalNumberOfFreeBytes);
end;

//******************************************************************************
// MoveFile
//******************************************************************************
function MoveFile(Source,Dest:PWideChar):Boolean;
begin
  Result:=Tnt_MoveFileW(Source,Dest);
end;

//******************************************************************************
// DragQueryFile
//******************************************************************************
function DragQueryFile(hDrop:HDROP;iFile:Cardinal;lpszFile:PWideChar;cch:Cardinal):Cardinal;
var Tmp:array of Char;
begin
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    Result:=ShellApi.DragQueryFileW(hDrop,iFile,lpszFile,cch)
  else
  begin
    SetLength(Tmp,cch);
    Result:=ShellApi.DragQueryFile(hDrop,iFile,@Tmp[0],cch);
    MultiByteToWideChar(CP_ACP,0,@Tmp[0],cch,lpszFile,cch*2);
    SetLength(Tmp,0);
  end;
end;

//******************************************************************************
// FindFirstFile
//******************************************************************************
function FindFirstFile(lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle;
begin
  Result:=Tnt_FindFirstFileW(lpFileName,lpFindFileData);
end;

//******************************************************************************
// FindNextFile
//******************************************************************************
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindDataW): Boolean;
begin
  Result:=Tnt_FindNextFileW(hFindFile,lpFindFileData);
end;

//******************************************************************************
// SHGetPathFromIDList
//******************************************************************************
function SHGetPathFromIDList(pidl:PItemIDList;pszPath:PWideChar):LongBool;
begin
  Result:=Tnt_SHGetPathFromIDListW(pidl,pszPath);
end;

//******************************************************************************
// SHBrowseForFolder
//******************************************************************************
function SHBrowseForFolder(var lpbi:_browseinfoW):PItemIDList;
begin
  Result:=Tnt_SHBrowseForFolderW(lpbi);
end;

//******************************************************************************
// GetVolumeInformation
//******************************************************************************
function GetVolumeInformation(lpRootPathName: PWideChar;
  lpVolumeNameBuffer: PWideChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PWideChar; nFileSystemNameSize: DWORD): BOOL;
var Tmp,Tmp2:array of Char;
begin
  if Win32Platform=VER_PLATFORM_WIN32_NT then
  begin
    Result:=GetVolumeInformationW(lpRootPathName,lpVolumeNameBuffer,nVolumeNameSize,
                          lpVolumeSerialNumber,lpMaximumComponentLength,lpFileSystemFlags,
                          lpFileSystemNameBuffer,nFileSystemNameSize);
  end
  else
  begin
    SetLength(Tmp,nVolumeNameSize);
    SetLength(Tmp2,nFileSystemNameSize);

    Result:=GetVolumeInformationA(PChar(String(lpRootPathName)),@Tmp[0],nVolumeNameSize,
                         lpVolumeSerialNumber,lpMaximumComponentLength,lpFileSystemFlags,
                         @Tmp2[0],nFileSystemNameSize);

    MultiByteToWideChar(CP_ACP,0,@Tmp[0],nVolumeNameSize,lpVolumeNameBuffer,nVolumeNameSize*2);
    MultiByteToWideChar(CP_ACP,0,@Tmp2[0],nFileSystemNameSize,lpFileSystemNameBuffer,nFileSystemNameSize*2);
    SetLength(Tmp,0);
    SetLength(Tmp2,0);
  end;
end;

//******************************************************************************
// MessageBox
//******************************************************************************
function MessageBox(hWnd: HWND; lpText, lpCaption: WideString; uType: UINT): Integer;
begin
  Result:=MessageBoxW(hWnd,PWideChar(lpText),PWideChar(lpCaption),uType); // fonction implémentée sous Win9x
end;

//******************************************************************************
// GetTempPath
//******************************************************************************
function GetTempPath:WideString;
var Buf:array[0..MAX_PATH] of WideChar;
begin
  if Tnt_GetTempPathW(MAX_PATH,Buf)<>0 then Result:=Buf;
end;

//******************************************************************************
// CopyFile
//******************************************************************************
function CopyFile(lpExistingFileName, lpNewFileName: PWideChar; bFailIfExists: BOOL): BOOL;
begin
  Result:=Tnt_CopyFileW(lpExistingFileName,lpNewFileName,bFailIfExists);
end;

//******************************************************************************
// PathIsUNC
//******************************************************************************
function PathIsUNC(pszPath:PWideChar):LongBool;
begin
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    Result:=PathIsUNCW(pszPath)
  else
    Result:=PathIsUNCA(PChar(String(pszPath)));
end;

initialization
  HKernel32_dll:=LoadLibrary('kernel32.dll');
  GetVolumePathName:=GetProcAddress(HKernel32_dll,'GetVolumePathNameW');
  GetVolumeNameForVolumeMountPoint:=GetProcAddress(HKernel32_dll,'GetVolumeNameForVolumeMountPointW');
  GetSystemDefaultUILanguage:=GetProcAddress(HKernel32_dll,'GetSystemDefaultUILanguage');

finalization
  FreeLibrary(HKernel32_dll);

end.
