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

lsDummy:WideString='Dummy!';

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
lsDiskSpaceNotifyTitle:WideString='Not enough free space';

lsAPINoSemaphore:WideString='Failed to initialize the API: semaphore creation failed';
lsAPINoMutex:WideString='Failed to initialize the API: mutex creation failed';
lsAPINoFileMapping:WideString='Failed to initialize the API: file mapping creation failed';
lsAPINoEvent:WideString='Failed to initialize the API: event creation failed';
lsAPIAlreadyRunning:WideString='API is already running for the current session';

lsShellExtCopyHere:WideString='SuperCopier copy here';
lsShellExtMoveHere:WideString='SuperCopier move here';

lsAlreadyRunningText:WideString='%s'+#13#10+'You can''t run SuperCopier 2 more than once per session';
lsAlreadyRunningCaption:WideString='SuperCopier 2 is already running';

lsUnknown:WideString='Unknown';

procedure TranslateAllStrings;

// /!\ Toujours ajouter les chaines à la fin et remplacer celles enlevées par des lsDummy !!!!
const LOC_STRINGS_ARRAY:array[1..57] of PWideString=(
  @lsCopyDisplayName,
  @lsMoveDisplayName,
  @lsCopyOf1,
  @lsCopyOf2,
  @lsConfirmCopylistAdd,
  @lsCreatingCopyList,
  @lsChooseDestDir,
  @lsAll,
  @lsFile,
  @lsSpeed,
  @lsRemaining,
  @lsCopyWindowCancellingCaption,
  @lsCopyWindowPausedCaption,
  @lsCopyWindowWaitingCaption,
  @lsCollisionFileData,
  @lsRenameAction,
  @lsDeleteAction,
  @lsListAction,
  @lsCopyAction,
  @lsUpdateTimeAction,
  @lsUpdateAttributesAction,
  @lsUpdateSecurityAction,
  @lsBytes,
  @lsKBytes,
  @lsMBytes,
  @lsGBytes,
  @lsChooseFolderToAdd,
  @lsRenamingHelpCaption,
  @lsRenamingHelpText,
  @lsAdvancedHelpCaption,
  @lsAdvancedHelpText,
  @lsCollisionNotifyTitle,
  @lsCollisionNotifyText,
  @lsCopyErrorNotifyTitle,
  @lsCopyErrorNotifyText,
  @lsGenericErrorNotifyTitle,
  @lsGenericErrorNotifyText,
  @lsCopyEndNotifyTitle,
  @lsCopyEndNotifyText,
  @lsDummy,
  @lsDummy,
  @lsDiskSpaceNotifyTitle,
  @lsCopyWindowCopyEndCaption,
  @lsCopyWindowCopyEndErrorsCaption,
  @lsDummy,
  @lsDummy,
  @lsDummy,
  @lsAPINoMutex,
  @lsAPINoFileMapping,
  @lsAPINoEvent,
  @lsShellExtCopyHere,
  @lsShellExtMoveHere,
  @lsAPIAlreadyRunning,
  @lsAlreadyRunningText,
  @lsAlreadyRunningCaption,
  @lsAPINoSemaphore,
  @lsUnknown
);

implementation

procedure TranslateAllStrings;
var i:Integer;
begin
  for i:=Low(LOC_STRINGS_ARRAY) to High(LOC_STRINGS_ARRAY) do
    LocEngine.TranslateString(i,LOC_STRINGS_ARRAY[i]^);
end;

end.
