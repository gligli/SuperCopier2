unit SCLocStrings;

interface

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
lsSpeed:WideString='%d KB/Sec';
lsRemaining:WideString='%s Remaining';

lsCollisionFileData:WideString='%s, Modified: %s';

lsRenameAction:WideString='Renaming';
lsDeleteAction:WideString='Deleting';
lsListAction:WideString='Listing';
lsCopyAction:WideString='Copying';
lsUpdateTimeAction:WideString='Updating time';
lsUpdateAttributesAction:WideString='Updating attributes';

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

implementation
end.
