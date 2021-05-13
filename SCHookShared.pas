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

unit SCHookShared;

{$include 'SCBuildConfig.inc'}

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
