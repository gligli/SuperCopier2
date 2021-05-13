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

unit SCLocStrings;

interface

uses SCLocEngine;

var

lsCopyDisplayName:WideString='Copy from %s to %s';
lsMoveDisplayName:WideString='Move from %s to %s';
lsCopyOf1:WideString='Copy of %s';
lsCopyOf2:WideString='Copy (%d) of %s';

lsConfirmCopylistAdd:WideString='Do you want to add the copy list to this copy?';
lsCreatingCopyList:WideString='Creating copy list, current folder:';
lsChooseDestDir:WideString='Choose destination folder';
lsAll:WideString='File %d/%d, Total: %s';
lsFile:WideString='%s, %s';
lsSpeed:WideString='%n KB/Sec';
lsRemaining:WideString='%s Remaining';
lsCopyWindowCancellingCaption:WideString='Cancelling - %s';
lsCopyWindowPausedCaption:WideString='Paused - %s';
lsCopyWindowWaitingCaption:WideString='Waiting - %s';
lsCopyWindowCopyEndCaption:WideString='Copy end - %s';
lsCopyWindowCopyEndErrorsCaption:WideString='Copy end (errors occured) - %s';

lsCollisionFileData:WideString='%s, Modified: %s';

lsRenameAction:WideString='Renaming';
lsDeleteAction:WideString='Deleting';
lsListAction:WideString='Listing';
lsCopyAction:WideString='Copying';
lsUpdateTimeAction:WideString='Updating time';
lsUpdateAttributesAction:WideString='Updating attributes';
lsUpdateSecurityAction:WideString='Updating security';

lsBytes:WideString='Bytes';
lsKBytes:WideString='KB';
lsMBytes:WideString='MB';
lsGBytes:WideString='GB';

lsChooseFolderToAdd:WideString='Choose the folder to add';

lsRenamingHelpCaption:WideString='Renaming help';
lsRenamingHelpText:WideString='Available tags:'+#13#10+#13#10+
                              '<full> : full file name with extension'+#13#10+
                              '<name> : file name without extension'+#13#10+
                              '<ext> : extension only without dot'+#13#10+
                              '<#>,<##>,<#...#> : incremental number, for example: # will give 1, ## will give 01, ...';

lsAdvancedHelpCaption:WideString='Advanced parameters help';
lsAdvancedHelpText:WideString='Copy buffer size:'+#13#10+
                              '     Size of each chunk of data that is red and written, you should not modify this.'+#13#10+
                              'Copy window update interval:'+#13#10+
                              '     Time between two refreshes of the copy window, the lower, the more CPU used.'+#13#10+
                              'Copy speed averaging interval:'+#13#10+
                              '     The copy speed displayed is the average on this time.'+#13#10+
                              'Copy throttle interval:'+#13#10+
                              '     Resolution of the speed limit, higher value gives preciser limit, lower value gives smoother speed control.'+#13#10;

lsCollisionNotifyTitle:WideString='A file already exists';
lsCollisionNotifyText:WideString='%s'+#13#10+'Filename: %s';
lsCopyErrorNotifyTitle:WideString='There was a copy error';
lsCopyErrorNotifyText:WideString='%s'+#13#10+'Filename: %s'+#13#10+'Error: %s';
lsGenericErrorNotifyTitle:WideString='There was a non blocking error';
lsGenericErrorNotifyText:WideString='%s'+#13#10+'Action: %s'+#13#10+'Target: %s'+#13#10+'Error: %s';
lsCopyEndNotifyTitle:WideString='Copy end';
lsCopyEndNotifyText:WideString='%s'+#13#10+'End speed: %s';

lsHookErrorCaption:WideString='SuperCopier2 can''t run';
lsHookErrorText:WideString='SuperCopier2 couldn''t attach to processes, this is normal if you ran it twice.'+#13#10+'Error text: ';
lsDiskSpaceNotifyTitle:WideString='Not enough free space';

lsHookEngineNoIPC:WideString='Failed to initialize the hooking engine: IPC creation failed';
lsHookEngineNoFileMapping:WideString='Failed to initialize the hooking engine: file mapping creation failed';
lsGlobalHookingFailed:WideString='Failed to hook processes: global hooking only works with administrator rights.';

procedure TranslateAllStrings;

implementation

procedure TranslateAllStrings;
begin
  with LocEngine do
  begin
    TranslateString(01,lsCopyDisplayName);
    TranslateString(02,lsMoveDisplayName);
    TranslateString(03,lsCopyOf1);
    TranslateString(04,lsCopyOf2);
    TranslateString(05,lsConfirmCopylistAdd);
    TranslateString(06,lsCreatingCopyList);
    TranslateString(07,lsChooseDestDir);
    TranslateString(08,lsAll);
    TranslateString(09,lsFile);
    TranslateString(10,lsSpeed);
    TranslateString(11,lsRemaining);
    TranslateString(12,lsCopyWindowCancellingCaption);
    TranslateString(13,lsCopyWindowPausedCaption);
    TranslateString(14,lsCopyWindowWaitingCaption);
    TranslateString(15,lsCollisionFileData);
    TranslateString(16,lsRenameAction);
    TranslateString(17,lsDeleteAction);
    TranslateString(18,lsListAction);
    TranslateString(19,lsCopyAction);
    TranslateString(20,lsUpdateTimeAction);
    TranslateString(21,lsUpdateAttributesAction);
    TranslateString(22,lsUpdateSecurityAction);
    TranslateString(23,lsBytes);
    TranslateString(24,lsKBytes);
    TranslateString(25,lsMBytes);
    TranslateString(26,lsGBytes);
    TranslateString(27,lsChooseFolderToAdd);
    TranslateString(28,lsRenamingHelpCaption);
    TranslateString(29,lsRenamingHelpText);
    TranslateString(30,lsAdvancedHelpCaption);
    TranslateString(31,lsAdvancedHelpText);
    TranslateString(32,lsCollisionNotifyTitle);
    TranslateString(33,lsCollisionNotifyText);
    TranslateString(34,lsCopyErrorNotifyTitle);
    TranslateString(35,lsCopyErrorNotifyText);
    TranslateString(36,lsGenericErrorNotifyTitle);
    TranslateString(37,lsGenericErrorNotifyText);
    TranslateString(38,lsCopyEndNotifyTitle);
    TranslateString(39,lsCopyEndNotifyText);
    TranslateString(40,lsHookErrorCaption);
    TranslateString(41,lsHookErrorText);
    TranslateString(42,lsDiskSpaceNotifyTitle);
    TranslateString(43,lsCopyWindowCopyEndCaption);
    TranslateString(44,lsCopyWindowCopyEndErrorsCaption);
  end;
end;

end.
