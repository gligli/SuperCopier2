
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntActions_Design;

{$INCLUDE ..\TntCompilers.inc}

interface

procedure Register;

implementation

uses
  Classes, ActnList, TntActnList, StdActns, TntStdActns,
  {$IFDEF COMPILER_6_UP}
    ExtActns, TntExtActns, ListActns, TntListActns, BandActn, TntBandActn,
  {$ENDIF}
  DBActns, TntDBActns, TntDesignEditors_Design;

procedure Register;
begin
  RegisterClass(TTntAction);
  // StdActns
  RegisterClass(TTntEditAction);
  RegisterClass(TTntEditCut);
  RegisterClass(TTntEditCopy);
  RegisterClass(TTntEditPaste);
  RegisterClass(TTntEditSelectAll);
  RegisterClass(TTntEditUndo);
  RegisterClass(TTntEditDelete);
  RegisterClass(TTntWindowAction);
  RegisterClass(TTntWindowClose);
  RegisterClass(TTntWindowCascade);
  RegisterClass(TTntWindowTileHorizontal);
  RegisterClass(TTntWindowTileVertical);
  RegisterClass(TTntWindowMinimizeAll);
  RegisterClass(TTntWindowArrange);
  RegisterClass(TTntHelpAction);
  RegisterClass(TTntHelpContents);
  RegisterClass(TTntHelpTopicSearch);
  RegisterClass(TTntHelpOnHelp);
  {$IFDEF COMPILER_6_UP}
  RegisterClass(TTntHelpContextAction);
  RegisterClass(TTntFileOpen);
  RegisterClass(TTntFileOpenWith);
  RegisterClass(TTntFileSaveAs);
  RegisterClass(TTntFilePrintSetup);
  RegisterClass(TTntFileExit);
  RegisterClass(TTntSearchFind);
  RegisterClass(TTntSearchReplace);
  RegisterClass(TTntSearchFindFirst);
  RegisterClass(TTntSearchFindNext);
  RegisterClass(TTntFontEdit);
  RegisterClass(TTntColorSelect);
  RegisterClass(TTntPrintDlg);
  // ExtActns
  RegisterClass(TTntFileRun);
  RegisterClass(TTntRichEditAction);
  RegisterClass(TTntRichEditBold);
  RegisterClass(TTntRichEditItalic);
  RegisterClass(TTntRichEditUnderline);
  RegisterClass(TTntRichEditStrikeOut);
  RegisterClass(TTntRichEditBullets);
  RegisterClass(TTntRichEditAlignLeft);
  RegisterClass(TTntRichEditAlignRight);
  RegisterClass(TTntRichEditAlignCenter);
  RegisterClass(TTntPreviousTab);
  RegisterClass(TTntNextTab);
  RegisterClass(TTntOpenPicture);
  RegisterClass(TTntSavePicture);
  RegisterClass(TTntURLAction);
  RegisterClass(TTntBrowseURL);
  RegisterClass(TTntDownLoadURL);
  RegisterClass(TTntSendMail);
  RegisterClass(TTntListControlCopySelection);
  RegisterClass(TTntListControlDeleteSelection);
  RegisterClass(TTntListControlSelectAll);
  RegisterClass(TTntListControlClearSelection);
  RegisterClass(TTntListControlMoveSelection);
  // ListActns
  RegisterClass(TTntStaticListAction);
  RegisterClass(TTntVirtualListAction);
  {$ENDIF}
  {$IFDEF COMPILER_7_UP}
  RegisterClass(TTntFilePageSetup);
  {$ENDIF}
  // DBActns
  RegisterClass(TTntDataSetAction);
  RegisterClass(TTntDataSetFirst);
  RegisterClass(TTntDataSetPrior);
  RegisterClass(TTntDataSetNext);
  RegisterClass(TTntDataSetLast);
  RegisterClass(TTntDataSetInsert);
  RegisterClass(TTntDataSetDelete);
  RegisterClass(TTntDataSetEdit);
  RegisterClass(TTntDataSetPost);
  RegisterClass(TTntDataSetCancel);
  RegisterClass(TTntDataSetRefresh);
  {$IFDEF COMPILER_6_UP}
  // BandActn
  RegisterClass(TTntCustomizeActionBars);
  {$ENDIF}
end;

//------------------------

function GetTntActionClass(OldActionClass: TContainedActionClass): TContainedActionClass;
begin
  Result := TContainedActionClass(GetClass('TTnt' + Copy(OldActionClass.ClassName, 2, Length(OldActionClass.ClassName))));
end;

type
  TAccessContainedAction = class(TContainedAction);

function UpgradeAction(ActionList: TTntActionList; OldAction: TContainedAction): TContainedAction;
var
  Name: TComponentName;
  i: integer;
  NewActionClass: TContainedActionClass;
begin
  Result := nil;
  if (OldAction = nil) or (OldAction.Owner = nil) or (OldAction.Name = '') then
    Exit;

  NewActionClass := GetTntActionClass(TContainedActionClass(OldAction.ClassType));
  if NewActionClass <> nil then begin
    // create new action
    Result := NewActionClass.Create(OldAction.Owner) as TContainedAction;
    {$IFDEF COMPILER_6_UP}
    Include(TAccessContainedAction(Result).FComponentStyle, csTransient);
    {$ENDIF}
    // copy base class info
    {$IFDEF COMPILER_6_UP}
    Result.ActionComponent := OldAction.ActionComponent;
    {$ENDIF}
    Result.Category := OldAction.Category; { Assign Category before ActionList/Index to avoid flicker. }
    Result.ActionList := ActionList;
    Result.Index := OldAction.Index;
    // assign props
    Result.Assign(OldAction);
    // point all links to this new action
    for i := TAccessContainedAction(OldAction).FClients.Count - 1 downto 0 do
      TBasicActionLink(TAccessContainedAction(OldAction).FClients[i]).Action := Result;
    // free old object, preserve name...
    Name := OldAction.Name;
    OldAction.Free;
    Result.Name := Name; { link up to old name }
    {$IFDEF COMPILER_6_UP}
    Exclude(TAccessContainedAction(Result).FComponentStyle, csTransient);
    {$ENDIF}
  end;
end;

procedure TntActionList_UpgradeActionListItems(ActionList: TTntActionList);
var
  DesignerNotify: IDesignerNotify;
  Designer: ITntDesigner;
  TntSelections: TTntDesignerSelections;
  i: integer;
  OldAction, NewAction: TContainedAction;
begin
  DesignerNotify := FindRootDesigner(ActionList);
  if (DesignerNotify <> nil) then begin
    DesignerNotify.QueryInterface(ITntDesigner, Designer);
    if (Designer <> nil) then begin
      TntSelections := TTntDesignerSelections.Create;
      try
        Designer.GetSelections(TntSelections);
        for i := ActionList.ActionCount - 1 downto 0 do begin
          OldAction := ActionList.Actions[i];
          NewAction := UpgradeAction(ActionList, OldAction);
          if (NewAction <> nil) then
            TntSelections.ReplaceSelection(OldAction, NewAction);
        end;
        Designer.SetSelections(TntSelections);
      finally
        TntSelections.Free;
      end;
    end;
  end;
end;

initialization
  UpgradeActionListItemsProc := TntActionList_UpgradeActionListItems;

end.
