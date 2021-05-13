unit SCFileList;

interface
uses SCDirList,Classes,SCObjectThreadList;

const
  FILELIST_DATA_VERSION=001;

type
	TFileList=class;

	TFileItem=class
	private
    Owner:TFileList;
	public
    BaseListId:Integer;

		SrcName,
		DestName:WideString;
		SrcSize:Int64;
		Directory:TDirItem;

    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream;Version:integer;BaseDirListIndex:Integer);
		function SrcFullName:WideString;
		function DestFullName:WideString;
		function DestSize:Int64;
		function SrcAge:Integer;
		function DestAge:Integer;
		function DestExists:Boolean;
		function DestIsSameFile:Boolean;
    function SrcDelete:Boolean;
    function DestDelete:Boolean;
    function DestCopyAttributes:boolean;
    function DestClearAttributes:boolean;
	end;

	TFileList = class (TObjectThreadList)
  private
    FDirList:TDirList;
	protected
		function Get(Index: Integer): TFileItem;
		procedure Put(Index: Integer; Item: TFileItem);
	public
		TotalCount:cardinal;
		TotalSize,Size:Int64;

		constructor Create(PDirList:TDirList);
		destructor Destroy; override;

    procedure SaveToStream(TheStream:TStream);
    procedure LoadFromStream(TheStream:TStream);
		function Add(Item: TFileItem): Integer;
		procedure Delete(Index: Integer;UpdateTotalCount:Boolean=False);

		property Items[Index: Integer]: TFileItem read Get write Put; default;
	end;

implementation

uses SCCommon,SCWin32,SysUtils,TntSysUtils,Windows, Contnrs;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TFileItem: fichier � copier
//******************************************************************************
//******************************************************************************
//******************************************************************************

procedure TFileItem.SaveToStream(TheStream:TStream);
var Len,Idx:Integer;
begin
  // version 1
    // On ne peut pas sauvegarder un pointeur, on sauvegarde l'index a la place
    // L'index commence de la fin de la liste pour pouvoir retrouver le DirItem
    // au chargement alors que la DirList est d�j� charg�e
  Idx:=Owner.FDirList.Count-1-Owner.FDirList.IndexOf(Directory);
  TheStream.Write(Idx,SizeOf(Integer));

  Len:=Length(SrcName);
  TheStream.Write(Len,SizeOf(Integer));
  TheStream.Write(SrcName[1],Len*SizeOf(WideChar));

  Len:=Length(DestName);
  TheStream.Write(Len,SizeOf(Integer));
  TheStream.Write(DestName[1],Len*SizeOf(WideChar));

  TheStream.Write(SrcSize,SizeOf(Int64));
end;

procedure TFileItem.LoadFromStream(TheStream:TStream;Version:integer;BaseDirListIndex:Integer);
var Len,Idx:Integer;
begin
  if Version>=001 then
  begin
    TheStream.Read(Idx,SizeOf(Integer));
      // on r�cup�re le DirItem en retranchant � l'index du dernier item de DirList
      // l'index sauvegard�
    Directory:=Owner.FDirList[BaseDirListIndex-Idx];



    TheStream.Read(Len,SizeOf(Integer));
    SetLength(SrcName,Len);
    TheStream.Read(SrcName[1],Len*SizeOf(WideChar));

    TheStream.Read(Len,SizeOf(Integer));
    SetLength(DestName,Len);
    TheStream.Read(DestName[1],Len*SizeOf(WideChar));

    TheStream.Read(SrcSize,SizeOf(Int64));
  end;
end;

function TFileItem.SrcFullName:WideString;
begin
  Result:=Concat(Directory.SrcPath,SrcName);
end;

function TFileItem.DestFullName:WideString;
begin
  Result:=Concat(Directory.DestPath,DestName);
end;

function TFileItem.DestSize:Int64;
begin
  Result:=SCCommon.GetFileSizeByName(DestFullName);
end;

function TFileItem.SrcAge:Integer;
begin
	Result:=WideFileAge(SrcFullName);
end;

function TFileItem.DestAge:Integer;
begin
	Result:=WideFileAge(DestFullName);
end;

function TFileItem.DestExists:Boolean;
begin
	Result:=WideFileAge(DestFullName)<>-1;
end;

function TFileItem.DestIsSameFile:Boolean;
begin
	// Deux fichiers sont consid�r�s identiques lorsque ils ont la m�me taille et la m�me date de derni�re modif
	Result:=(SrcSize=DestSize) and (SrcAge=DestAge);
end;

function TFileItem.SrcDelete:Boolean;
var ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure SrcDelete_;
  begin
    Result:=SCWin32.DeleteFile(PWideChar(SrcFullName));
    ErrCode:=GetLastError;
  end;

begin
  SrcDelete_;
  SetLastError(ErrCode);
end;

function TFileItem.DestDelete:Boolean;
var ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure DestDelete_;
  begin
    Result:=SCWin32.DeleteFile(PWideChar(DestFullName));
    ErrCode:=GetLastError;
  end;

begin
  DestDelete_;
  SetLastError(ErrCode);
end;

function TFileItem.DestCopyAttributes:Boolean;
var Attr:Cardinal;
    ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure DestCopyAttributes_;
  begin
    Attr:=SCWin32.GetFileAttributes(PWideChar(SrcFullName));
    Result:=Attr<>$ffffffff;
    if Result then Result:=SCWin32.SetFileAttributes(PWideChar(DestFullName),Attr);
    ErrCode:=GetLastError;
  end;

begin
  DestCopyAttributes_;
  SetLastError(ErrCode);
end;

function TFileItem.DestClearAttributes:boolean;
var ErrCode:Integer;

  //HACK: la gestion interne de l'unicode de delphi pourrit le code d'erreur win32
  //      lors du retour d'une fonction, ceci permets de le conserver
  procedure DestClearAttributes_;
  begin
    Result:=SCWin32.SetFileAttributes(PWideChar(DestFullName),FILE_ATTRIBUTE_NORMAL);
    ErrCode:=GetLastError;
  end;

begin
  DestClearAttributes_;
  SetLastError(ErrCode);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TFileList: liste de fichiers � copier
//******************************************************************************
//******************************************************************************
//******************************************************************************

procedure TFileList.SaveToStream(TheStream:TStream);
var i,Num,Version:integer;
begin
  Version:=FILELIST_DATA_VERSION;
  TheStream.Write(Version,SizeOf(Integer));

  Num:=Count;
  TheStream.Write(Num,SizeOf(Integer));

  for i:=0 to Num-1 do
  begin
    Items[i].SaveToStream(TheStream);
  end;
end;

procedure TFileList.LoadFromStream(TheStream:TStream);
var i,Num,Version:integer;
    FileItem:TFileItem;
    BaseDirListIndex:Integer;
begin
  Version:=000;
  Num:=0;

  TheStream.Read(Version,SizeOf(Integer));
  if Version>FILELIST_DATA_VERSION then raise Exception.Create('FileItems: data file is for a newer SuperCopier2 version');

  TheStream.Read(num,SizeOf(Integer));

  BaseDirListIndex:=FDirList.Count-1;
  for i:=0 to Num-1 do
  begin
    FileItem:=TFileItem.Create;
    FileItem.Owner:=Self;
    FileItem.LoadFromStream(TheStream,Version,BaseDirListIndex);
    Add(FileItem);
  end;
end;

function TFileList.Add(Item: TFileItem): Integer;
begin
	// maj des compteurs
	Inc(Size,Item.SrcSize);
	Inc(TotalSize,Item.SrcSize);
	Inc(TotalCount,1);

  Item.Owner:=Self;

	Result:=inherited Add(Item);
end;

procedure TFileList.Delete(Index: Integer;UpdateTotalCount:Boolean=False);
begin
	// maj des compteurs
  if Items[Index]<>nil then
  begin
    Dec(Size,Items[Index].SrcSize);

    if UpdateTotalCount then
    begin
      Dec(TotalSize,Items[Index].SrcSize);
      Dec(TotalCount,1);
    end;
  end;

	inherited Delete(Index);
end;

function TFileList.Get(Index: Integer): TFileItem;
begin
	Result:=TFileItem(inherited Get(Index));
end;

procedure TFileList.Put(Index: Integer; Item: TFileItem);
begin
	inherited Put(Index,Item);
end;

constructor TFileList.Create(PDirList:TDirList);
begin
	inherited Create;

  // init des variables
	TotalCount:=0;
	TotalSize:=0;
  Size:=0;

  FDirList:=PDirList;
end;

destructor TFileList.Destroy;
begin
	inherited Destroy;
end;

end.
