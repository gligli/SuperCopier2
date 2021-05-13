unit SCBaseList;

interface
uses Classes,SCObjectThreadList;

type
	TBaseItem=class
    public
		SrcName:WideString;
		IsDirectory:boolean;
    function FileSize:Int64;
	end;

	TBaseList = class (TObjectThreadList)
	protected
		function Get(Index: Integer): TBaseItem;
		procedure Put(Index: Integer; Item: TBaseItem);
	public
    procedure SortByFileName;

		property Items[Index: Integer]: TBaseItem read Get write Put; default;
	end;

implementation
uses SysUtils,SCCommon;

function BLSortCompare(Item1,Item2:Pointer):Integer;forward;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TBaseItem: élément de base (fichier ou répertoire)
//******************************************************************************
//******************************************************************************
//******************************************************************************

function TBaseItem.FileSize:Int64;
begin
  Result:=GetFileSizeByName(SrcName);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TBaseList: liste d'éléments de base
//******************************************************************************
//******************************************************************************
//******************************************************************************

function TBaseList.Get(Index: Integer): TBaseItem;
begin
	Result:=inherited Get(Index);
end;

procedure TBaseList.Put(Index: Integer; Item: TBaseItem);
begin
	inherited Put(Index,Item);
end;

procedure TBaseList.SortByFileName;
begin
  Self.Sort(BLSortCompare);
end;

//******************************************************************************
// BLSortCompare: fonction de tri par nom de fichier pour la baselist
//******************************************************************************

function BLSortCompare(Item1,Item2:Pointer):Integer;
begin
  Result:=CompareText(TBaseItem(Item1).SrcName,TBaseItem(Item2).SrcName);
end;

end.
