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
    destructor Destroy;override;

		property Items[Index: Integer]: TBaseItem read Get write Put; default;
	end;

implementation
uses SysUtils,SCCommon,SCAPI;

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

destructor TBaseList.Destroy;
begin
  API.RemoveHandle(Self);
  inherited;
end;

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
