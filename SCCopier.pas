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

unit SCCopier;

interface
uses Classes,SCFileList,SCDirList,SCBaseList,Sysutils,TntSysUtils,SCCommon;

const
  COPIER_DATA_VERSION=001;

type

  TFileCollisionEvent=function(var NewName:WideString):TCollisionAction of object;
  TDiskSpaceWarningEvent=function(Drives:TDiskSpaceWarningVolumeArray):Boolean of object;
  TCopyErrorEvent=function(ErrorText:WideString):TCopyErrorAction of object;
  TGenericErrorEvent=procedure(Action,Target,ErrorText:WideString) of object;
  TCopyProgressEvent=function:Boolean of object;
  TRecurseProgressEvent=function(CurrentItem:TDirItem):Boolean of object;

  ECopyError=class(Exception);

	TCopier=class
	private
		LastBaseListId:Integer;
    FCopyAttributes:Boolean;
    FCopySecurity:Boolean;

    function RecurseSubs(DirItem:TDirItem):Boolean;
  protected
    FBufferSize:cardinal;

    procedure RaiseCopyErrorIfNot(Test:Boolean);
    procedure CopyFileAge(HSrc,HDest:THandle);

    procedure GenericError(Action,Target:WideString;ErrorText:WideString='');
    procedure CopyError;
    procedure SetBufferSize(Value:cardinal);virtual;abstract;
	public
		FileList:TFileList;
		DirList:TDirList;

		CopiedCount:Cardinal;
		CopiedSize,SkippedSize:Int64;

		CurrentCopy:record
			FileItem:TFileItem;
			DirItem:TDirItem;
			CopiedSize,SkippedSize:Int64;
			NextAction:TCopyAction;
		end;

    OnFileCollision:TFileCollisionEvent;
    OnDiskSpaceWarning:TDiskSpaceWarningEvent;
    OnCopyError:TCopyErrorEvent;
    OnGenericError:TGenericErrorEvent;
    OnCopyProgress:TCopyProgressEvent;
    OnRecurseProgress:TRecurseProgressEvent;

		constructor Create;
		destructor Destroy;override;

    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream);
    procedure AddBaseList(BaseList:TBaseList;DestDir:WideString);
    procedure RemoveLastBaseList;
    function VerifyFreeSpace(FastMode:Boolean=true):Boolean;
    function FirstCopy:Boolean;
    function NextCopy:Boolean;
    function ManageFileAction(ResumeNoAgeVerification:Boolean=False):Boolean;
    procedure CreateEmptyDirs;
    procedure DeleteSrcDirs;
    procedure DeleteSrcFile;
    procedure DeleteDestFile;
    procedure CopyAttributesAndSecurity;
    procedure VerifyOrCreateDir(ADirItem:TDirItem=nil);

    function DoCopy:Boolean;virtual;abstract;

    property BufferSize:cardinal read FBufferSize write SetBufferSize;
    property CopyAttributes:Boolean read FCopyAttributes write FCopyAttributes;
    property CopySecurity:Boolean read FCopySecurity write FCopySecurity;
	end;

implementation
uses Windows,SCWin32,SCLocStrings, Math;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TCopier: classe de base de copie de fichiers, les erreurs et collisions sont
//          gérées par évènements
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// Create
//******************************************************************************
constructor TCopier.Create;
begin
  // création des listes
  DirList:=TDirList.Create;
  FileList:=TFileList.Create(DirList);

  // init des variables
  CopiedCount:=0;
  CopiedSize:=0;
  SkippedSize:=0;
  LastBaseListId:=-1;
  OnFileCollision:=nil;
  OnDiskSpaceWarning:=nil;
  OnCopyError:=nil;
  OnGenericError:=nil;
  OnCopyProgress:=nil;
  FBufferSize:=0;

  with CurrentCopy do
  begin
    FileItem:=nil;
    DirItem:=nil;
    CopiedSize:=0;
    SkippedSize:=0;
    NextAction:=cpaNextFile;
  end;

end;

//******************************************************************************
// Destroy
//******************************************************************************
destructor TCopier.Destroy;
begin
  // libération des listes
  FileList.Free;
  DirList.Free;

  inherited Destroy;
end;

//******************************************************************************
// SaveToStream : sauvegarde des données
//******************************************************************************
procedure TCopier.SaveToStream(TheStream:TStream);
var Sig:String;
    Version:integer;
begin
  Sig:=SCL_SIGNATURE;
  TheStream.Write(Sig[1],Length(Sig));

  Version:=COPIER_DATA_VERSION;
  TheStream.Write(Version,SizeOf(Integer));

  //version 1
  DirList.SaveToStream(TheStream);
  FileList.SaveToStream(TheStream);
end;

//******************************************************************************
// LoadFromStream : chargement des données
//******************************************************************************
procedure TCopier.LoadFromStream(TheStream:TStream);
var Sig:String;
    Version:integer;
begin
  SetLength(Sig,SCL_SIGNATURE_LENGTH);
  TheStream.Read(Sig[1],SCL_SIGNATURE_LENGTH);
  if Sig<>SCL_SIGNATURE then raise Exception.Create('Data file is not a SuperCopier2 CopyList');

  Version:=000;

  TheStream.Read(Version,SizeOf(Integer));
  if Version>COPIER_DATA_VERSION then raise Exception.Create('Copier: data file is for a newer SuperCopier2 version');

  DirList.LoadFromStream(TheStream);
  FileList.LoadFromStream(TheStream);
end;

//******************************************************************************
// RaiseCopyErrorIfNot : déclenche un exception ECopyError si Test vaut false
//******************************************************************************
procedure TCopier.RaiseCopyErrorIfNot(Test:Boolean);
begin
  if not Test then raise ECopyError.Create('Copy Error');
end;

//******************************************************************************
// CopyFileAge : copie la date de modif d'un fichier ouvert vers un autre
//******************************************************************************
procedure TCopier.CopyFileAge(HSrc,HDest:THandle);
var FileTime:TFileTime;
begin
  if (not GetFileTime(HSrc,nil,nil,@FileTime)) or
     (not SetFileTime(HDest,nil,nil,@FileTime)) then
  begin
    GenericError(lsUpdateTimeAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
  end;
end;

//******************************************************************************
// GenericError : déclenche un évènement d'erreur générique
//******************************************************************************
procedure TCopier.GenericError(Action,Target:WideString;ErrorText:WideString='');
begin
  if Assigned(OnGenericError) then
  begin
    OnGenericError(Action,Target,ErrorText);
  end;
end;

//******************************************************************************
// CopyError : déclenche un évènement d'erreur de copie et gere la valeur de retour
//******************************************************************************
procedure TCopier.CopyError;
var ErrorResult:TCopyErrorAction;
    FileItem:TFileItem;
begin
  Assert(Assigned(OnCopyError),'OnCopyError not assigned');

  ErrorResult:=OnCopyError(SysErrorMessage(GetLastError));

  case ErrorResult of
    ceaNone:
      Assert(False,'ErrorAction=claNone');
    ceaSkip:
      CurrentCopy.NextAction:=cpaNextFile;
    ceaCancel:
      CurrentCopy.NextAction:=cpaCancel;
    ceaRetry:
      CurrentCopy.NextAction:=cpaRetry;
    ceaEndOfList:
    begin
      CurrentCopy.NextAction:=cpaNextFile;

      // on ajoute à la filelist un nouvel item contenant les mêmes données que celui en cours
      with CurrentCopy.FileItem do
      begin
        FileItem:=TFileItem.Create;
        FileItem.CopyTryCount:=CopyTryCount;
        FileItem.BaseListId:=BaseListId;
        FileItem.SrcName:=SrcName;
        FileItem.DestName:=DestName;
        FileItem.SrcSize:=SrcSize;
        FileItem.Directory:=Directory;

        FileList.Add(FileItem);
      end;
    end;
  end;
end;

//******************************************************************************
// AddBaseList : Ajoute une liste de fichiers au Copier, Copiés dans DestDir
//******************************************************************************
procedure TCopier.AddBaseList(BaseList:TBaseList;DestDir:WideString);

	// FindOrCreateParent
	function FindOrCreateParent(SrcPath,DestPath:WideString):TDirItem;
  var SrcParent:WideString;
  begin
    SrcParent:=WideExtractFilePath(SrcPath);

    Result:=DirList.FindDirItem(SrcParent,DestPath);
    if Result=nil then
    begin
      Result:=TDirItem.Create;
      Result.SrcPath:=SrcParent;
      Result.DestPath:=DestPath;
      Result.ParentDir:=nil;
      Result.Created:=WideDirectoryExists(DestPath);
      DirList.Add(Result);
    end;
  end;

	// FindNewName
	function FindNewName(OldName,Dir:WideString):WideString;
	var NewInc:integer;
			NotFound:boolean;
	begin
		NewInc:=1;
		repeat
			if NewInc>1 then
				Result:=WideFormat(lsCopyOf2,[NewInc,OldName])
			else
				Result:=WideFormat(lsCopyOf1,[OldName]);

			NotFound:=True;

			if WideFileExists(Dir+Result) or WideDirectoryExists(Dir+Result) then
				NotFound:=False;

			Inc(NewInc);
		until NotFound;
	end;

var i:integer;
		FileItem:TFileItem;
		DirItem:TDirItem;
		ShortSourceName,ShortDestName:WideString;

begin
  Inc(LastBaseListId);

  // tri de la liste
  BaseList.SortByFileName;

  // forcer le \ terminal
  DestDir:=WideIncludeTrailingBackslash(DestDir);

  for i:=0 to BaseList.Count-1 do
    with BaseList[i] do
    begin
      ShortSourceName:=WideExtractFileName(SrcName);
      ShortDestName:=ShortSourceName;

      //copie d'un élément sur lui même=renommage automatique
      if WideExtractFilePath(SrcName)=DestDir then
      begin
        ShortDestName:=FindNewName(ShortDestName,DestDir);
      end;

      // transfert des BaseItems dans leurs listes respectives
      if IsDirectory then
      begin
        DirItem:=TDiritem.Create;
        DirItem.BaseListId:=LastBaseListId;
        DirItem.SrcPath:=WideIncludeTrailingBackslash(SrcName);
        DirItem.DestPath:=WideIncludeTrailingBackslash(DestDir+ShortDestName);
        DirItem.ParentDir:=FindOrCreateParent(SrcName,DestDir);
        DirItem.Created:=False;
        DirList.Add(DirItem);

        if not RecurseSubs(DirItem) then
        begin
          RemoveLastBaseList;
          Break;
        end;
      end
      else
      begin
        FileItem:=TFileItem.Create;
        FileItem.CopyTryCount:=0;
        FileItem.BaseListId:=LastBaseListId;
        FileItem.SrcName:=ShortSourceName;
        FileItem.DestName:=ShortDestName;
        FileItem.SrcSize:=GetFileSizeByName(SrcName);
        FileItem.Directory:=FindOrCreateParent(SrcName,DestDir);
        FileList.Add(FileItem);
      end;
    end;

  // libération de la liste
  BaseList.Free;
end;

//******************************************************************************
// RemoveLastBaseList : Enlève de la liste de copie les derniers fichiers ajoutés
//******************************************************************************
procedure TCopier.RemoveLastBaseList;
var i:integer;
begin
  // suppression des DirItems
  try
    DirList.Lock;

    i:=DirList.Count-1;
    while (i>=0) and (DirList[i].BaseListId=LastBaseListId) do
    begin
      DirList.Delete(i);
      Dec(i);
    end;

  finally
    DirList.Unlock;
  end;

  // suppression des FileItems
  try
    FileList.Lock;

    i:=FileList.Count-1;
    while (i>=0) and (FileList[i].BaseListId=LastBaseListId) do
    begin
      FileList.Delete(i,True);
      Dec(i);
    end;

  finally
    FileList.Unlock;
  end;

end;

//******************************************************************************
// RecurseSubs : Ajout par récursion des fichiers d'un répertoire
//               Renvoie false si la récursion a été annulée
//******************************************************************************
function TCopier.RecurseSubs(DirItem:TDirItem):Boolean;
var FindData:TWin32FindDataW;
    FindHandle:THandle;
    NewFileItem:TFileItem;
    NewDirItem:TDirItem;
begin
  Assert(Assigned(OnRecurseProgress),'OnRecurseProgress not assigned');
  Result:=OnRecurseProgress(DirItem);

  with DirItem do
  begin
    FindHandle:=SCWin32.FindFirstFile(PWideChar(SrcPath+'\*.*'),FindData);
    if FindHandle=INVALID_HANDLE_VALUE then
    begin
      GenericError(lsListAction,SrcPath,GetLastErrorText);
      exit;
    end;

    repeat
      with FindData do
      begin
        if (WideString(cFileName)='.') or (WideString(cFileName)='..') then continue; //ne pas prendre en compte les reps '.' et '..'

        if (dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)<>0 then //IsDir
        begin
          NewDirItem:=TDirItem.Create;
          NewDirItem.BaseListId:=LastBaseListId;
          NewDirItem.SrcPath:=SrcPath+WideString(cFileName)+'\';
          NewDirItem.DestPath:=DestPath+WideString(cFileName)+'\';
          NewDirItem.ParentDir:=DirItem;
          NewDirItem.Created:=False;
          DirList.Add(NewDirItem);

          Result:=Result and RecurseSubs(NewDirItem);
        end
        else
        begin
          NewFileItem:=TFileItem.Create;
          NewFileItem.CopyTryCount:=0;
          NewFileItem.BaseListId:=LastBaseListId;
          NewFileItem.SrcName:=WideString(cFileName);
          NewFileItem.DestName:=WideString(cFileName);
          NewFileItem.Directory:=DirItem;
          NewFileItem.SrcSize:=nFileSizeLow;
          Inc(NewFileItem.SrcSize,nFileSizeHigh * $100000000);
          FileList.Add(NewFileItem);
        end;
      end;
    until (not SCWin32.FindNextFile(FindHandle,FindData)) or (not Result);

    Windows.FindClose(FindHandle);
  end;
end;

//******************************************************************************
// VerifyFreeSpace : Vérifie qu'il y a assez d'espace disque pour copier les
//                   fichiers et déclenche un evènement sinon
//                   renvoie true si la copie des fichiers n'est pas annulée
//                   FastMode=false pour corriger qq pb avec les points de montage NTFS 
//******************************************************************************
function TCopier.VerifyFreeSpace(FastMode:Boolean=true):Boolean;
var Volumes:TDiskSpaceWarningVolumeArray;
    i:Integer;
    ForceCopy:Boolean;
    DiskSpaceOk:Boolean;

  //AddToVolume
  procedure AddToVolume(Volume:WideString;Size:Int64);
  var i:integer;
  begin
    i:=0;
    while (i<Length(Volumes)) and (Volumes[i].Volume<>Volume) do
      Inc(i);

    if i>=Length(Volumes) then // le volume est-il répertorié?
    begin
      SetLength(Volumes,Length(Volumes)+1);
      Volumes[i].Volume:=Volume;
      Volumes[i].LackSize:=Size;
    end
    else
    begin
      Volumes[i].LackSize:=Volumes[i].LackSize+Size;
    end;
  end;

  //AddToVolumeByPath
  procedure AddToVolumeByPath(Path:WideString;Size:Int64);
  var i:integer;
  begin
    i:=0;
    while (i<Length(Volumes)) and (Pos(Volumes[i].Volume,Path)=0) do
      Inc(i);

    if i>=Length(Volumes) then // le volume est-il répertorié?
    begin
      SetLength(Volumes,Length(Volumes)+1);
      Volumes[i].Volume:=GetVolumeNameString(Path);
      Volumes[i].LackSize:=Size;
    end
    else
    begin
      Volumes[i].LackSize:=Volumes[i].LackSize+Size;
    end;
  end;

  //RemoveVolume
  procedure RemoveVolume(VolNum:integer);
  var i:integer;
  begin
    for i:=VolNum to Length(Volumes)-2 do
      Volumes[i]:=Volumes[i+1];

    SetLength(Volumes,Length(Volumes)-1);
  end;

begin
  Result:=True;

    try
      FileList.Lock;

      if FastMode then
      begin
        // recup de la taille des fichiers pour chaque volume
        for i:=0 to FileList.Count-1 do
          AddToVolumeByPath(FileList[i].Directory.Destpath,FileList[i].SrcSize);

        // ne pas compter la taille du fichier en cours (allouée par avance)
        if CurrentCopy.CopiedSize>0 then AddToVolumeByPath(CurrentCopy.DirItem.Destpath,-CurrentCopy.FileItem.SrcSize);
      end
      else
      begin
        // recup de la taille des fichiers pour chaque volume
        for i:=0 to FileList.Count-1 do
          AddToVolume(GetVolumeNameString(FileList[i].Directory.Destpath),FileList[i].SrcSize);

        // ne pas compter la taille du fichier en cours (allouée par avance)
        if CurrentCopy.CopiedSize>0 then AddToVolume(GetVolumeNameString(CurrentCopy.DirItem.Destpath),-CurrentCopy.FileItem.SrcSize);
      end;

    finally
      FileList.Unlock;
    end;

  // éliminer les volumes contenant assez de place
  for i:=Length(Volumes)-1 downto 0 do
    with Volumes[i] do
    begin
      DiskSpaceOk:=SCWin32.GetDiskFreeSpaceEx(PWideChar(Volume),FreeSize,VolumeSize,nil);
      if DiskSpaceOk then
      begin
        LackSize:=LackSize-FreeSize;
        if LackSize<0 then RemoveVolume(i);
      end
      else
      begin
        RemoveVolume(i);
      end;
    end;

  // déclencher un évènement si au moins 1 volume n'a pas assez de place
  if (Length(Volumes)>0) and Assigned(OnDiskSpaceWarning) then
  begin
    ForceCopy:=OnDiskSpaceWarning(Volumes);

    if not ForceCopy then RemoveLastBaseList;
    Result:=ForceCopy;
  end;
end;

//******************************************************************************
// FirstCopy : Prépare le Copier pour la première copie
//             Renvoie false si rien à copier
//******************************************************************************
function TCopier.FirstCopy:Boolean;
begin
  if FileList.Count>0 then
  begin
    Result:=True;

    with CurrentCopy do
    begin
      FileItem:=FileList[0];
      DirItem:=FileItem.Directory;
      CopiedSize:=0;
      SkippedSize:=0;
      NextAction:=cpaNextFile;
    end;
  end
  else
  begin
    Result:=False;
  end;
end;

//******************************************************************************
// NextCopy : Prépare le Copier pour la prochaine copie
//            Renvoie false si plus rien à copier
//******************************************************************************
function TCopier.NextCopy:Boolean;
var NonCopiedSize:Int64;
begin
  if CurrentCopy.NextAction<>cpaRetry then
  begin
    Inc(CopiedCount);

    // Ajouter aux SkippedSize tout ce qui n'a pas été copié
    with CurrentCopy do
    begin
      NonCopiedSize:=FileItem.SrcSize-(CopiedSize+SkippedSize);
      SkippedSize:=SkippedSize+NonCopiedSize;
      Self.SkippedSize:=Self.SkippedSize+NonCopiedSize;
    end;
  end;

  Result:=true;

  case CurrentCopy.NextAction of
    cpaNextFile:
    begin
      try
        FileList.Lock;

        // on enleve le FileItem qui vient d'etre copié
        FileList.Delete(0);

        if FileList.Count>0 then
        begin
          // maj de CurrentCopy
          with CurrentCopy do
          begin
            FileItem:=FileList[0];
            DirItem:=FileItem.Directory;
            CopiedSize:=0;
            SkippedSize:=0;
          end;
        end
        else
        begin
          // plus d'items -> renvoyer false
          Result:=false;
        end;

      finally
        FileList.Unlock;
      end;
    end;
    cpaCancel:
    begin
      Result:=False;
    end;
    cpaRetry:
    begin
      // on recommence la meme copie -> faire comme si l'on avait rien copié
      SkippedSize:=SkippedSize-CurrentCopy.SkippedSize;
      CopiedSize:=CopiedSize-CurrentCopy.CopiedSize;
    end;
  end;
end;


//******************************************************************************
// ManageFileAction : Gère les collisions de fichiers et effectue les actions demandées
//                    Renvoie false si la copie du fichier en cours est annulée
//******************************************************************************
function TCopier.ManageFileAction(ResumeNoAgeVerification:Boolean):Boolean;
var Action:TCollisionAction;
    FullNewName,NewName:WideString;
    MustRedo:Boolean;
begin
  Result:=true;

  // gestion annulation
  if CurrentCopy.NextAction=cpaCancel then
  begin
    Result:=False;
    Exit;
  end;

  repeat
    MustRedo:=False;

    // rien à faire si pas de collision ou fichier deja traité
    if (not CurrentCopy.FileItem.DestExists) or (CurrentCopy.NextAction<>cpaNextFile) then exit;

    // on lance l'évènement pour savoir quoi faire
    Assert(Assigned(OnFileCollision),'OnFileCollision not assigned');
    Action:=OnFileCollision(NewName);

    case Action of
      claNone:
      begin
        Assert(False,'CollisionAction=claNone');
      end;
      claCancel:
      begin
        Result:=false;
        CurrentCopy.NextAction:=cpaCancel;
      end;
      claSkip:
      begin
        Result:=false;
        CurrentCopy.NextAction:=cpaNextFile;
      end;
      claResume:
      begin
        with CurrentCopy.FileItem do
        begin
          if (ResumeNoAgeVerification or (SrcAge=DestAge)) and (SrcSize>DestSize) then
          begin
            Result:=true;
            CurrentCopy.NextAction:=cpaRetry;
          end
          else
          begin
            // la reprise ne peut pas etre effectuée -> écraser
            Result:=True;
            CurrentCopy.NextAction:=cpaNextFile;
          end;
        end;
      end;
      claOverwrite:
      begin
        Result:=true;
        CurrentCopy.NextAction:=cpaNextFile;
      end;
      claOverwriteIfDifferent:
      begin
        Result:=not CurrentCopy.FileItem.DestIsSameFile;
        CurrentCopy.NextAction:=cpaNextFile;
      end;
      claRenameNew:
      begin
        Result:=true;
        CurrentCopy.NextAction:=cpaNextFile;

        CurrentCopy.FileItem.DestName:=NewName;

        MustRedo:=True; // le nom du fichier à changé, il peut aussi exister déjà
      end;
      claRenameOld:
      begin
        Result:=true;
        CurrentCopy.NextAction:=cpaNextFile;

        FullNewName:=IncludeTrailingBackslash(CurrentCopy.DirItem.Destpath)+NewName;

        if not SCWin32.MoveFile(PWideChar(CurrentCopy.FileItem.DestFullName),PWideChar(FullNewName)) then
        begin
          // gestion de l'erreur
          GenericError(lsRenameAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
          MustRedo:=True; // le renommage a échoué -> la collision n'a pas été résolue
        end;
      end;
    end;
  until not MustRedo;
end;

//******************************************************************************
// CreateEmptyDirs : création des répertoires vides
//******************************************************************************
procedure TCopier.CreateEmptyDirs;
var i:integer;
begin
  for i:=0 to DirList.Count-1  do
    VerifyOrCreateDir(DirList[i]);
end;

//******************************************************************************
// DeleteSrcDirs : supprime les répertoires contenant les fichiers source
//******************************************************************************
procedure TCopier.DeleteSrcDirs;
var i:integer;
begin
  for i:=DirList.Count-1 downto 0  do
    if DirList[i].ParentDir<>nil then // un DirItem n'a pas de parent seulement
    begin                             // si c'est le répertoire de base des éléments à déplacer
      if not DirList[i].SrcDelete then
      begin
        // gestion de l'erreur
        GenericError(lsDeleteAction,DirList[i].SrcPath,GetLastErrorText);
      end;
    end;
end;

//******************************************************************************
// DeleteSrcFile : supprime le fichier source en cours (pour les déplacements)
//******************************************************************************
procedure TCopier.DeleteSrcFile;
begin
  if not CurrentCopy.FileItem.SrcDelete then
  begin
    // gestion de l'erreur
    GenericError(lsDeleteAction,CurrentCopy.FileItem.SrcFullName,GetLastErrorText);
  end;
end;

//******************************************************************************
// DeleteDestFile : supprime le fichier destination en cours (copie non terminée ou erreur)
//******************************************************************************
procedure TCopier.DeleteDestFile;
begin
  if not CurrentCopy.FileItem.DestDelete then
  begin
    // gestion de l'erreur
    GenericError(lsDeleteAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
  end;
end;

//******************************************************************************
// CopyAttributesAndSecurity : Copie les attributs et la sécurité du fichier en cours
//******************************************************************************
procedure TCopier.CopyAttributesAndSecurity;
begin
  if CopyAttributes and not CurrentCopy.FileItem.DestCopyAttributes then
  begin
    // gestion de l'erreur
    GenericError(lsUpdateAttributesAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
  end;

  if CopySecurity and (Win32Platform=VER_PLATFORM_WIN32_NT) and not CurrentCopy.FileItem.DestCopySecurity then
  begin
    // gestion de l'erreur
    GenericError(lsUpdateSecurityAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
  end;
end;

//******************************************************************************
// VerifyOrCreateDir : Appelle VerifyOrCreate pour un DirItem et gère attributs et sécurité
//******************************************************************************
procedure TCopier.VerifyOrCreateDir(ADirItem: TDirItem);
var DirItem:TDirItem;
begin
  DirItem:=ADirItem;
  if DirItem=nil then DirItem:=CurrentCopy.DirItem;

  if DirItem.Created then Exit;

  DirItem.VerifyOrCreate;

  if CopyAttributes and not DirItem.DestCopyAttributes then
  begin
    // gestion de l'erreur
    GenericError(lsUpdateAttributesAction,DirItem.Destpath,GetLastErrorText);
  end;

  if CopySecurity and (Win32Platform=VER_PLATFORM_WIN32_NT) and not DirItem.DestCopySecurity then
  begin
    // gestion de l'erreur
    GenericError(lsUpdateSecurityAction,DirItem.Destpath,GetLastErrorText);
  end;
end;

end.
