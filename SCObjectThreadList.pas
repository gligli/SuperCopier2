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

unit SCObjectThreadList;

interface
uses
  Contnrs,Windows,SCCommon;

type
  TObjectThreadList=class(TObjectList)
  private
    FLock:TRTLCriticalSection;
  public
    function Remove(AObject: TObject): Integer;
    procedure Delete(Index: Integer);
    procedure Lock;
    procedure Unlock;

    constructor Create;
    destructor Destroy;Override;
  end;


implementation

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TObjectThreadList: conteneur à objets adapté aux threads
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor TObjectThreadList.Create;
begin
  inherited Create;

  InitializeCriticalSection(FLock);
end;

destructor TObjectThreadList.Destroy;
begin
  DeleteCriticalSection(FLock);

  inherited Destroy;
end;

function TObjectThreadList.Remove(AObject: TObject): Integer;
begin
  try
    Lock;
    Result:=inherited Remove(AObject);
  finally
    Unlock;
  end;
end;

procedure TObjectThreadList.Delete(Index: Integer);
begin
  try
    Lock;
    inherited Delete(Index);
  finally
    Unlock;
  end;
end;

procedure TObjectThreadList.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TObjectThreadList.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

end.
