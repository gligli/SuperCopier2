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
  public
    function Pop: TBaseListQueueItem;
    function Peek: TBaseListQueueItem;
  end;

implementation

function TBaseListQueue.Pop: TBaseListQueueItem;
begin
  Result:=(inherited Pop) as TBaseListQueueItem;
end;

function TBaseListQueue.Peek: TBaseListQueueItem;
begin
  Result:=(inherited Peek) as TBaseListQueueItem;
end;

end.
