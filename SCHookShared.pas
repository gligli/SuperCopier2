unit SCHookShared;

interface

const
  IPC_NAME='SuperCopier2 IPC';
  FILE_MAPING_NAME='SuperCopier2 file mapping';
  DLL_NAME='SC2Hook.dll';

type
  TSCH2ADataType=(hdtSHFileOperation,hdtShellExecute);

  TSCHook2AppData=record
    ProcessId:Cardinal;
    case DataType:TSCH2ADataType of
      hdtSHFileOperation:(
        Operation:Integer;
        SourceSize,DestinationSize:Integer;
      );
      hdtShellExecute:(
        ProcessHandle:THandle;
      );
  end;

  TSCApp2HookData=record
    IsUserHook:Boolean;
    HandledProcesses:string[255];
  end;

  PSCApp2HookData=^TSCApp2HookData;
implementation
end.
