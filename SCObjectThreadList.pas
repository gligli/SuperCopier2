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
