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

unit SCDirList;

interface
uses Classes,SCObjectThreadList;

const
  DIRLIST_DATA_VERSION=001;

type
  TDirList = class;

	TDirItem=class
  private
    Owner:TDirList;
    FAttributesCopied:Boolean;
    FSecurityCopied:Boolean;
	public
    BaseListId:Integer;

		SrcPath,
		Destpath:WideString;
		ParentDir:TDirItem;
		Created:Boolean;

    constructor Create;

    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream;Version:integer;BaseDirListIndex:Integer);
		procedure DestCopyAge;
    function DestCopyAttributes:boolean;
		function DestCopySecurity:boolean;
		procedure VerifyOrCreate;
    function SrcDelete:Boolean;
	end;

	TDirList = class (TObjectThreadList)
	protected
		function Get(Index: Integer): TDirItem;
		procedure Put(Index: Integer; Item: TDirItem);
	public
    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream);
    function FindDirItem(SrcPath,DestPath:WideString):TDirItem;
		function Add(Item: TDirItem): Integer;

		property Items[Index: Integer]: TDirItem read Get write Put; default;
	end;

implementation

uses Windows,SCCommon,SCWin32, SysUtils,TntSysUtils;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TDirItem: répertoire à copier, gère la création récursive
//******************************************************************************
//******************************************************************************
//******************************************************************************

procedure TDirItem.SaveToStream(TheStream:TStream);
var Len,Idx:Integer;
begin
  // version 1
    //On ne peut pas sauvegarder un pointeur, on sauvegarde l'index a la place
  Idx:=Owner.IndexOf(ParentDir);
  TheStream.Write(Idx,SizeOf(Integer));

  Len:=Length(SrcPath);
  TheStream.Write(Len,SizeOf(Integer));
  TheStream.Write(SrcPath[1],Len*SizeOf(WideChar));

  Len:=Length(Destpath);
  TheStream.Write(Len,SizeOf(Integer));
  TheStream.Write(Destpath[1],Len*SizeOf(WideChar));
end;

procedure TDirItem.LoadFromStream(TheStream:TStream;Version:integer;BaseDirListIndex:Integer);
var Len,Idx:Integer;
begin
  if Version>=001 then
  begin
    TheStream.Read(Idx,SizeOf(Integer));
    if Idx>=0 then
        // on récupère le DirItem en ajoutant à l'index sauvegardé
        // l'index du dernier DirItem avant le Chargement
      ParentDir:=Owner[BaseDirListIndex+Idx]
    else
      ParentDir:=nil;

    TheStream.Read(Len,SizeOf(Integer));
    SetLength(SrcPath,Len);
    TheStream.Read(SrcPath[1],Len*SizeOf(WideChar));

    TheStream.Read(Len,SizeOf(Integer));
    SetLength(Destpath,Len);
    TheStream.Read(Destpath[1],Len*SizeOf(WideChar));
  end;
end;

procedure TDirItem.DestCopyAge;
var SrcHnd,DstHnd:THandle;
		CT,AT,WT:TFileTime;
begin
	if Created and (Win32Platform=VER_PLATFORM_WIN32_NT) then
	begin
		SrcHnd:=CreateFileW(pwidechar(SrcPath),
												GENERIC_READ,
												FILE_SHARE_READ or FILE_SHARE_WRITE,
												nil,
												OPEN_ALWAYS,
												FILE_FLAG_BACKUP_SEMANTICS,
												0);
		DstHnd:=CreateFileW(pwidechar(DestPath),
												GENERIC_WRITE,
												FILE_SHARE_READ or FILE_SHARE_WRITE,
												nil,
												OPEN_ALWAYS,
												FILE_FLAG_BACKUP_SEMANTICS,
												0);
		if (SrcHnd<>INVALID_HANDLE_VALUE) and (DstHnd<>INVALID_HANDLE_VALUE) and
				 GetFileTime(SrcHnd,@CT,@AT,@WT) then
			SetFileTime(DstHnd,@CT,@AT,@WT);

		CloseHandle(SrcHnd);
		CloseHandle(DstHnd);
	end;
end;

function TDirItem.DestCopyAttributes: boolean;
var Attr:Cardinal;
    ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure DestCopyAttributes_;
  begin
    Attr:=SCWin32.GetFileAttributes(PWideChar(SrcPath));
    Result:=Attr<>$ffffffff;
    if Result then Result:=SCWin32.SetFileAttributes(PWideChar(Destpath),Attr);
    ErrCode:=GetLastError;
  end;

begin
  Result:=True;
  if not FAttributesCopied then
  begin
    DestCopyAttributes_;
    SetLastError(ErrCode);
    FAttributesCopied:=True;
  end;
end;

function TDirItem.DestCopySecurity:boolean;
var ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure DestCopySecurity_;
  begin
    Result:=CopySecurity(SrcPath,Destpath);
    ErrCode:=GetLastError;
  end;

begin
  Result:=True;
  if not FSecurityCopied then
  begin
    DestCopySecurity_;
    SetLastError(ErrCode);
    FSecurityCopied:=True;
  end;
end;

procedure TDirItem.VerifyOrCreate;
begin
	if Created then exit;

	if Assigned(ParentDir) then ParentDir.VerifyOrCreate;

	Created:=SCWin32.CreateDirectory(PWideChar(DestPath),nil) or (GetLastError=ERROR_ALREADY_EXISTS);

  // nouveau répertoire créé -> on recopie sa date de modif
  DestCopyAge;
end;

function TDirItem.SrcDelete:Boolean;
begin
  SCWin32.SetFileAttributes(PWideChar(SrcPath),FILE_ATTRIBUTE_NORMAL);
  Result:=SCWin32.RemoveDirectory(PWideChar(SrcPath));
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TDirList: liste de répertoires à copier
//******************************************************************************
//******************************************************************************
//******************************************************************************

procedure TDirList.SaveToStream(TheStream:TStream);
var i,Num,Version:integer;
begin
  Version:=DIRLIST_DATA_VERSION;
  TheStream.Write(Version,SizeOf(Integer));

  Num:=Count;
  TheStream.Write(Num,SizeOf(Integer));

  for i:=0 to Num-1 do
  begin
    Items[i].SaveToStream(TheStream);
  end;
end;

procedure TDirList.LoadFromStream(TheStream:TStream);
var i,Num,Version:integer;
    DirItem:TDirItem;
    BaseDirListIndex:Integer;
begin
  Version:=000;
  Num:=0;

  TheStream.Read(Version,SizeOf(Integer));
  if Version>DIRLIST_DATA_VERSION then raise Exception.Create('DirItems: data file is for a newer SuperCopier2 version');

  TheStream.Read(num,SizeOf(Integer));

  BaseDirListIndex:=Count;
  for i:=0 to Num-1 do
  begin
    DirItem:=TDirItem.Create;
    Add(DirItem);
    DirItem.LoadFromStream(TheStream,Version,BaseDirListIndex);
  end;
end;

function TDirList.Get(Index: Integer): TDirItem;
begin
	Result:=TDirItem(inherited Get(Index));
end;

procedure TDirList.Put(Index: Integer; Item: TDirItem);
begin
	inherited Put(Index,Item);
end;

function TDirList.Add(Item: TDirItem): Integer;
begin
  Item.Owner:=Self;

	Result:=inherited Add(Item);
end;

function TDirList.FindDirItem(SrcPath,DestPath:WideString):TDirItem;
var i:integer;
    Found:boolean;
    CleanSrcPath:WideString;
    CleanDestPath:WideString;
begin
  i:=0;
  Result:=nil;
  Found:=False;

  CleanSrcPath:=WideIncludeTrailingBackslash(SrcPath);
  CleanDestPath:=WideIncludeTrailingBackslash(DestPath);

  while (i<Count) and (not Found) do
  begin
    Found:=(Items[i].SrcPath=CleanSrcPath) and (Items[i].Destpath=CleanDestPath);
    Inc(i);
  end;

  if Found then Result:=Items[i-1];
end;

constructor TDirItem.Create;
begin
  inherited;
  Owner:=nil;
  FAttributesCopied:=False;
  FSecurityCopied:=False;
  BaseListId:=-1;
  SrcPath:='';
  Destpath:='';
  ParentDir:=nil;
  Created:=False;
end;

end.
