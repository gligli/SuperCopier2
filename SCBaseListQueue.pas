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

unit SCBaseListQueue;

interface
uses
  windows,messages,classes,contnrs,SCCommon,SCBaseList;

type

  TBaseListQueueItem=class
  public
    BaseList:TBaseList;
    DestDir:WideString;
  end;

  TBaseListQueue=class(TObjectQueue)
  private
    FLock:TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy;Override;

    procedure Lock;
    procedure Unlock;

    function Pop: TBaseListQueueItem;
    function Peek: TBaseListQueueItem;
  end;

implementation

{ TBaseListQueue }

constructor TBaseListQueue.Create;
begin
  inherited;

  InitializeCriticalSection(FLock);
end;

destructor TBaseListQueue.Destroy;
begin
  DeleteCriticalSection(FLock);

  inherited;
end;

procedure TBaseListQueue.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TBaseListQueue.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

function TBaseListQueue.Pop: TBaseListQueueItem;
begin
  Result:=(inherited Pop) as TBaseListQueueItem;
end;

function TBaseListQueue.Peek: TBaseListQueueItem;
begin
  Result:=(inherited Peek) as TBaseListQueueItem;
end;

end.
