unit SCHookShared;

interface

const
  IPC_NAME='SuperCopier2 IPC';
  DLL_NAME='SC2Hook.dll';

type
  TSCHookData=record
    Operation:Integer;
    ProcessId:Cardinal;
    SourceSize,DestinationSize:Integer;
  end;

implementation
end.
