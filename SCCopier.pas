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

    function RecurseSubs(DirItem:TDirItem):Boolean;
  protected
    FBufferSize:integer;

    procedure RaiseCopyErrorIfNot(Test:Boolean);
    procedure CopyFileAge(HSrc,HDest:THandle);

    procedure GenericError(Action,Target:WideString;ErrorText:WideString='');
    procedure CopyError;
    procedure SetBufferSize(Value:Integer);virtual;abstract;
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

    property BufferSize:integer read FBufferSize write SetBufferSize;

		constructor Create;
		destructor Destroy;override;

    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream);
    procedure AddBaseList(BaseList:TBaseList;DestDir:WideString);
    procedure RemoveLastBaseList;
    function VerifyFreeSpace(FastMode:Boolean=true):Boolean;
    function FirstCopy:Boolean;
    function NextCopy:Boolean;
    function ManageFileAction:Boolean;
    procedure CreateEmptyDirs;
    procedure DeleteSrcDirs;
    procedure DeleteSrcFile;
    procedure CopyAttributes;

    function DoCopy:Boolean;virtual;abstract;
	end;

  TAnsiBufferedCopier=class(TCopier)
  private
    Buffer:array of byte;
  protected
    procedure SetBufferSize(Value:Integer);override;
  public
    function DoCopy:Boolean;override;
  end;

implementation
uses Windows,SCWin32,SCLocStrings, Math;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TCopier: classe de base de copie de fichiers, les erreurs et collisions sont
//          g�r�es par �v�nements
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// Create
//******************************************************************************
constructor TCopier.Create;
begin
  // cr�ation des listes
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
  // lib�ration des listes
  FileList.Free;
  DirList.Free;

  inherited Destroy;
end;

//******************************************************************************
// SaveToStream : sauvegarde des donn�es
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
// LoadFromStream : chargement des donn�es
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
// RaiseCopyErrorIfNot : d�clenche un exception ECopyError si Test vaut false
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
// GenericError : d�clenche un �v�nement d'erreur g�n�rique
//******************************************************************************
procedure TCopier.GenericError(Action,Target:WideString;ErrorText:WideString='');
begin
  if Assigned(OnGenericError) then
  begin
    OnGenericError(Action,Target,ErrorText);
  end;
end;

//******************************************************************************
// CopyError : d�clenche un �v�nement d'erreur de copie et gere la valeur de retour
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

      // on ajoute � la filelist un nouvel item contenant les m�mes donn�es que celui en cours
      with CurrentCopy.FileItem do
      begin
        FileItem:=TFileItem.Create;
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
// AddBaseList : Ajoute une liste de fichiers au Copier, Copi�s dans DestDir
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
      Result.Created:=False; // le r�pertoire de destination n'existe pas forc�ment
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
				Result:=Format(lsCopyOf2,[NewInc,OldName])
			else
				Result:=Format(lsCopyOf1,[OldName]);

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

      //copie d'un �l�ment sur lui m�me=renommage automatique
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
        FileItem.BaseListId:=LastBaseListId;
        FileItem.SrcName:=ShortSourceName;
        FileItem.DestName:=ShortDestName;
        FileItem.SrcSize:=GetFileSizeByName(SrcName);
        FileItem.Directory:=FindOrCreateParent(SrcName,DestDir);
        FileList.Add(FileItem);
      end;
    end;

  // lib�ration de la liste
  BaseList.Free;
end;

//******************************************************************************
// RemoveLastBaseList : Enl�ve de la liste de copie les derniers fichiers ajout�s
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
      FileList.Delete(i);
      Dec(i);
    end;

  finally
    FileList.Unlock;
  end;

end;

//******************************************************************************
// RecurseSubs : Ajout par r�cursion des fichiers d'un r�pertoire
//               Renvoie false si la r�cursion a �t� annul�e
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
          NewFileItem.BaseListId:=LastBaseListId;
          NewFileItem.SrcName:=WideString(cFileName);
          NewFileItem.DestName:=WideString(cFileName);
          NewFileItem.Directory:=DirItem;
          NewFileItem.SrcSize:=nFileSizeLow;
          inc(NewFileItem.SrcSize,nFileSizeHigh * $FFFFFFFF);
          FileList.Add(NewFileItem);
        end;
      end;
    until (not SCWin32.FindNextFile(FindHandle,FindData)) or (not Result);

    Windows.FindClose(FindHandle);
  end;
end;

//******************************************************************************
// VerifyFreeSpace : V�rifie qu'il y a assez d'espace disque pour copier les
//                   fichiers et d�clenche un ev�nement sinon
//                   renvoie true si la copie des fichiers n'est pas annul�e
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

    if i>=Length(Volumes) then // le volume est-il r�pertori�?
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

    if i>=Length(Volumes) then // le volume est-il r�pertori�?
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

        // ne pas compter la partie copi�e du fichier en cours
        if CurrentCopy.CopiedSize>0 then AddToVolumeByPath(CurrentCopy.DirItem.Destpath,-CurrentCopy.CopiedSize);
      end
      else
      begin
        // recup de la taille des fichiers pour chaque volume
        for i:=0 to FileList.Count-1 do
          AddToVolume(GetVolumeNameString(FileList[i].Directory.Destpath),FileList[i].SrcSize);

        // ne pas compter la partie copi�e du fichier en cours
        if CurrentCopy.CopiedSize>0 then AddToVolume(GetVolumeNameString(CurrentCopy.DirItem.Destpath),-CurrentCopy.CopiedSize);
      end;

    finally
      FileList.Unlock;
    end;

  // �liminer les volumes contenant assez de place
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

  // d�clencher un �v�nement si au moins 1 volume n'a pas assez de place
  if (Length(Volumes)>0) and Assigned(OnDiskSpaceWarning) then
  begin
    ForceCopy:=OnDiskSpaceWarning(Volumes);

    if not ForceCopy then RemoveLastBaseList;
    Result:=ForceCopy;
  end;
end;

//******************************************************************************
// FirstCopy : Pr�pare le Copier pour la premi�re copie
//             Renvoie false si rien � copier
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
// NextCopy : Pr�pare le Copier pour la prochaine copie
//            Renvoie false si plus rien � copier
//******************************************************************************
function TCopier.NextCopy:Boolean;
var NonCopiedSize:Int64;
begin
  if CurrentCopy.NextAction<>cpaRetry then
  begin
    Inc(CopiedCount);

    // Ajouter aux SkippedSize tout ce qui n'a pas �t� copi�
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

        // on enleve le FileItem qui vient d'etre copi�
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
      // rien � faire
  end;
end;


//******************************************************************************
// ManageFileAction : G�re les collisions de fichiers et effectue les actions demand�es
//                    Renvoie false si la copie du fichier en cours est annul�e
//******************************************************************************
function TCopier.ManageFileAction;
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

    // rien � faire si pas de collision ou fichier deja trait�
    if (not CurrentCopy.FileItem.DestExists) or (CurrentCopy.NextAction<>cpaNextFile) then exit;

    // on lance l'�v�nement pour savoir quoi faire
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
          if (SrcAge=DestAge) and (SrcSize<DestSize) then
          begin
            Result:=true;
            CurrentCopy.NextAction:=cpaRetry;
          end
          else
          begin
            // la reprise ne peut pas etre effectu�e -> passer au fichier suivant
            Result:=False;
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

        MustRedo:=True; // le nom du fichier � chang�, il peut aussi exister d�j�
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
          MustRedo:=True; // le renommage a �chou� -> la collision n'a pas �t� r�solue
        end;
      end;
    end;
  until not MustRedo;
end;

//******************************************************************************
// CreateEmptyDirs : cr�ation des r�pertoires vides
//******************************************************************************
procedure TCopier.CreateEmptyDirs;
var i:integer;
begin
  for i:=0 to DirList.Count-1  do
    DirList[i].VerifyOrCreate;
end;

//******************************************************************************
// DeleteSrcDirs : supprime les r�pertoires contenant les fichiers source
//******************************************************************************
procedure TCopier.DeleteSrcDirs;
var i:integer;
begin
  for i:=DirList.Count-1 downto 0  do
    if DirList[i].ParentDir<>nil then // un DirItem n'a pas de parent seulement
    begin                             // si c'est le r�pertoire de base des �l�ments � d�placer
      if not DirList[i].SrcDelete then
      begin
        // gestion de l'erreur
        GenericError(lsDeleteAction,DirList[i].SrcPath,GetLastErrorText);
      end;
    end;
end;

//******************************************************************************
// DeleteSrcFile : supprime le fichier source en cours (pour les d�placements)
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
// CopyAttributes : Copie les attributs du fichier en cours
//******************************************************************************
procedure TCopier.CopyAttributes;
begin
  if not CurrentCopy.FileItem.DestCopyAttributes then
  begin
    // gestion de l'erreur
    GenericError(lsUpdateAttributesAction,CurrentCopy.FileItem.DestFullName,GetLastErrorText);
  end;
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TAnsiBufferedCopier: descendant de TCopier, copie bufferis�e simple en mode
//                      ansi (Pour Win9x)
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// SetBufferSize: fixe la taille du buffer de copie
//******************************************************************************
procedure TAnsiBufferedCopier.SetBufferSize(Value:Integer);
begin
  if Value<>FBufferSize then
  begin
    SetLength(Buffer,Value);
    FBufferSize:=Value;
  end;
end;

//******************************************************************************
// DoCopy: renvoie false si la copie �choue
//******************************************************************************
function TAnsiBufferedCopier.DoCopy:boolean;
var HSrc,HDest:THandle;
    SourceFile,DestFile:String;
    BytesRead,BytesWritten:Cardinal;
    ContinueCopy:Boolean;
begin
  Assert(Assigned(OnCopyProgress),'OnCopyProgress not assigned');

  Result:=True;
  with CurrentCopy do
  begin
    NextAction:=cpaNextFile;
    CopiedSize:=0;
    SkippedSize:=0;
    SourceFile:=FileItem.SrcFullName;
    DestFile:=FileItem.DestFullName;

    try
      HSrc:=INVALID_HANDLE_VALUE;
      HDest:=INVALID_HANDLE_VALUE;
      try
        // on ouvre le fichier source
        HSrc:=CreateFile(pchar(SourceFile),
                            GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE,
                            nil,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,
                            0);
        RaiseCopyErrorIfNot(HSrc<>INVALID_HANDLE_VALUE);

        // effacer les attributs du fichier de destination pour pouvoir l'ouvrir en �criture
        FileItem.DestClearAttributes;

        // on ouvre le fichier de destination
        if NextAction<>cpaRetry then // doit-on reprendre le transfert?
        begin
          HDest:=CreateFile(pchar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ,
                              nil,
                              CREATE_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL,
                              0);
        end
        else
        begin
          HDest:=CreateFile(pchar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ,
                              nil,
                              OPEN_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL,
                              0);

          // on se positionne a la fin du fichier de destination
          SetFilePointer(HDest,0,FILE_END);

          SkippedSize:=FileItem.DestSize;
          Self.SkippedSize:=Self.SkippedSize+SkippedSize;
          // et on se mets a la position correspondante dans le fichier source
          SetFilePointer(HSrc,SkippedSize,FILE_BEGIN);
        end;
        RaiseCopyErrorIfNot(HDest<>INVALID_HANDLE_VALUE);

        // on donne sa taille finale au fichier de destination (pour �viter la fragmentation)
        RaiseCopyErrorIfNot(SetFileSize(HDest,FileItem.SrcSize));

        // boucle principale de copie
        repeat
          RaiseCopyErrorIfNot(ReadFile(HSrc,Buffer[0],BufferSize,BytesRead,nil));
          RaiseCopyErrorIfNot(WriteFile(HDest,Buffer[0],BytesRead,BytesWritten,nil));
          CopiedSize:=CopiedSize+BytesWritten;
          Self.CopiedSize:=Self.CopiedSize+BytesWritten;

          ContinueCopy:=OnCopyProgress;
        until ((CopiedSize+SkippedSize)>=FileItem.SrcSize) or (not ContinueCopy);

        // copie de la date de modif
        CopyFileAge(HSrc,HDest);
      finally
        // on d�clare la position courrante dans le fichier destination comme fin de fichier
        if HDest<>INVALID_HANDLE_VALUE then SetEndOfFile(HDest);

        // fermeture des handles si ouverts
        if HSrc<>INVALID_HANDLE_VALUE then CloseHandle(HSrc);
        if HDest<>INVALID_HANDLE_VALUE then CloseHandle(HDest);
      end;
    except
      on E:ECopyError do
      begin
        Result:=False;

        CopyError;
      end;
    end;
  end;
end;

end.
