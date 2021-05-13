
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntComCtrls_Design;

{$INCLUDE ..\TntCompilers.inc}

interface

uses
  {$IFDEF COMPILER_6_UP} DesignIntf, DesignMenus, DesignEditors, {$ELSE} DsgnIntf, Menus, {$ENDIF}
  Classes, ComCtrls;

type
{$IFDEF COMPILER_6_UP}
  IPrepareMenuItem = IMenuItem;
{$ELSE}
  IPrepareMenuItem = TMenuItem{TNT-ALLOW TMenuItem};
{$ENDIF}

  TTntListViewEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string{TNT-ALLOW string}; override;
    function GetVerbCount: Integer; override;
  end;

  TTntPageControlEditor = class(TDefaultEditor)
  private
    function PageControl: TPageControl{TNT-ALLOW TPageControl};
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string{TNT-ALLOW string}; override;
    function GetVerbCount: Integer; override;
    procedure PrepareItem(Index: Integer; const AItem: IPrepareMenuItem); override;
  end;

  TTntStatusBarEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string{TNT-ALLOW string}; override;
    function GetVerbCount: Integer; override;
  end;


procedure Register;

implementation

uses
  {$IFDEF COMPILER_6_UP} DsnConst, {$ENDIF} TntComCtrls, TntDesignEditors_Design;

procedure Register;
begin
  RegisterComponentEditor(TTntListView, TTntListViewEditor);
  RegisterComponentEditor(TTntPageControl, TTntPageControlEditor);
  RegisterComponentEditor(TTntTabSheet, TTntPageControlEditor);
  RegisterComponentEditor(TTntStatusBar, TTntStatusBarEditor);
end;

{$IFNDEF COMPILER_6_UP} // Delphi 5 compatibility
resourcestring
  SListColumnsEditor = 'Columns Editor...';
  SListItemsEditor = 'Items Editor...';
  SNewPage = 'New Page';
  SNextPage = 'Next Page';
  SPrevPage = 'Previous Page';
  SDeletePage = 'Delete Page';
  SStatusBarPanelEdit = 'Panels Editor...';
{$ENDIF}

{ TTntListViewEditor }

function TTntListViewEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

function TTntListViewEditor.GetVerb(Index: Integer): string{TNT-ALLOW string};
begin
  case Index of
    0: Result := SListColumnsEditor;
    1: Result := SListItemsEditor;
  end;
end;

procedure TTntListViewEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: EditPropertyWithDialog(Component, 'Columns', Designer);
    1: EditPropertyWithDialog(Component, 'Items', Designer);
  end;
end;

{ TTntPageControlEditor }

function TTntPageControlEditor.PageControl: TPageControl{TNT-ALLOW TPageControl};
begin
  if Component is TTabSheet{TNT-ALLOW TTabSheet} then
    Result := TTabSheet{TNT-ALLOW TTabSheet}(Component).PageControl
  else
    Result := Component as TPageControl{TNT-ALLOW TPageControl};
end;

function TTntPageControlEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;

function TTntPageControlEditor.GetVerb(Index: Integer): string{TNT-ALLOW string};
begin
  case Index of
    0: Result := SNewPage;
    1: Result := SNextPage;
    2: Result := SPrevPage;
    3: Result := SDeletePage;
  end;
end;

procedure TTntPageControlEditor.PrepareItem(Index: Integer; const AItem: IPrepareMenuItem);
begin
  AItem.Enabled := (Index <> 3) or (PageControl.PageCount > 0);
end;

type TAccessPageControl = class(TPageControl{TNT-ALLOW TPageControl});

procedure TTntPageControlEditor.ExecuteVerb(Index: Integer);

  procedure CreateNewTabSheet;
  var
    NewTabsheet: TTntTabSheet;
  begin
    NewTabSheet := TTntTabSheet.Create(PageControl.Owner);
      NewTabSheet.PageControl := Self.PageControl;
    with NewTabSheet do begin
      Name := Designer.UniqueName(ClassName);
      Caption := Name;
      Visible := True;
    end;
    PageControl.ActivePage := NewTabSheet;
  end;

  procedure SelectNextPage(GoForward: Boolean);
  {$IFDEF COMPILER_6_UP}
  begin
    PageControl.SelectNextPage(GoForward, False);
  {$ELSE}
  var
    Page: TTabSheet{TNT-ALLOW TTabSheet};
  begin
    with TAccessPageControl(PageControl) do begin
      Page := FindNextPage(ActivePage, GoForward, False);
      if (Page <> nil) and (Page <> ActivePage) and CanChange then
      begin
        ActivePage := Page;
        Change;
      end;
    end;
  {$ENDIF}
  end;

begin
  case Index of
    0: CreateNewTabSheet;
    1: SelectNextPage(True);
    2: SelectNextPage(False);
    3: if PageControl.ActivePage <> nil then
         PageControl.ActivePage.Free;
  end;
end;

{ TTntStatusBarEditor }

function TTntStatusBarEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TTntStatusBarEditor.GetVerb(Index: Integer): string{TNT-ALLOW string};
begin
  case Index of
    0: Result := SStatusBarPanelEdit;
  end;
end;

procedure TTntStatusBarEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: EditPropertyWithDialog(Component, 'Panels', Designer);
  end;
end;

end.
