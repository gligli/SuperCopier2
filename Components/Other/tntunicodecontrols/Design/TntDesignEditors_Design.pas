
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://tnt.ccci.org/delphi_unicode_controls/                           }
{        Version: 2.1.9                                                       }
{                                                                             }
{    Copyright (c) 2002-2004, Troy Wolbrink (troy.wolbrink@ccci.org)          }
{                                                                             }
{*****************************************************************************}

unit TntDesignEditors_Design;

{$INCLUDE ..\TntCompilers.inc}

interface

uses
  Classes, Forms, TypInfo,
  {$IFDEF COMPILER_6_UP} DesignIntf, DesignEditors; {$ELSE} DsgnIntf; {$ENDIF}

type
  {$IFDEF COMPILER_6_UP}
  ITntDesigner = IDesigner;
  {$ELSE}
  ITntDesigner = IFormDesigner;
  {$ENDIF}

  TTntDesignerSelections = class(TInterfacedObject, IDesignerSelections)
  private
    FList: TList;
    {$IFNDEF COMPILER_6_UP}
    function IDesignerSelections.Add = Intf_Add;
    function Intf_Add(const Item: IPersistent): Integer;
    function IDesignerSelections.Get = Intf_Get;
    function Intf_Get(Index: Integer): IPersistent;
    {$ENDIF}
    {$IFDEF COMPILER_9_UP}
    function GetDesignObject(Index: Integer): IDesignObject;
    {$ENDIF}
  protected
    function Add(const Item: TPersistent): Integer;
    function Equals(const List: IDesignerSelections): Boolean;
    {$IFDEF COMPILER_6_UP}
    function Get(Index: Integer): TPersistent;
    {$ENDIF}
    function GetCount: Integer;
    property Count: Integer read GetCount;
    {$IFDEF COMPILER_6_UP}
    property Items[Index: Integer]: TPersistent read Get; default;
    {$ENDIF}
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure ReplaceSelection(const OldInst, NewInst: TPersistent);
  end;

function GetObjectInspectorForm: TCustomForm;
procedure EditPropertyWithDialog(Component: TPersistent; const PropName: AnsiString; const Designer: ITntDesigner);

implementation

uses
  SysUtils, TntSysUtils;

{ TTntDesignerSelections }

function TTntDesignerSelections.Add(const Item: TPersistent): Integer;
begin
  Result := FList.Add(Item);
end;

constructor TTntDesignerSelections.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TTntDesignerSelections.Destroy;
begin
  FList.Free;
  inherited;
end;

function TTntDesignerSelections.Equals(const List: IDesignerSelections): Boolean;
var
  I: Integer;
  {$IFNDEF COMPILER_6_UP}
  P1, P2: IPersistent;
  {$ENDIF}
begin
  Result := False;
  if List.Count <> Count then Exit;
  for I := 0 to Count - 1 do
  begin
    {$IFDEF COMPILER_6_UP}
    if Items[I] <> List[I] then Exit;
    {$ELSE}
    P1 := Intf_Get(I);
    P2 := List[I];
    if ((P1 = nil) and (P2 <> nil)) or
      (P2 = nil) or not P1.Equals(P2) then Exit;
    {$ENDIF}
  end;
  Result := True;
end;

{$IFDEF COMPILER_6_UP}
function TTntDesignerSelections.Get(Index: Integer): TPersistent;
begin
  Result := TPersistent(FList[Index]);
end;
{$ENDIF}

function TTntDesignerSelections.GetCount: Integer;
begin
  Result := FList.Count;
end;

{$IFNDEF COMPILER_6_UP}
function TTntDesignerSelections.Intf_Add(const Item: IPersistent): Integer;
begin
  Result := Add(ExtractPersistent(Item));
end;

function TTntDesignerSelections.Intf_Get(Index: Integer): IPersistent;
begin
  Result := MakeIPersistent(TPersistent(FList[Index]));
end;
{$ENDIF}

{$IFDEF COMPILER_9_UP}
function TTntDesignerSelections.GetDesignObject(Index: Integer): IDesignObject;
begin
  Result := nil; {TODO: Figure out what IDesignerSelections.GetDesignObject is all about.  Must wait for more documentation!}
end;
{$ENDIF}

procedure TTntDesignerSelections.ReplaceSelection(const OldInst, NewInst: TPersistent);
var
  Idx: Integer;
begin
  Idx := FList.IndexOf(OldInst);
  if Idx <> -1 then
    FList[Idx] := NewInst;
end;

{//------------------------------
//  Helpful discovery routines to explore the components and classes inside the IDE...
//
procedure EnumerateComponents(Comp: TComponent);
var
  i: integer;
begin
  for i := Comp.ComponentCount - 1 downto 0 do
    MessageBoxW(0, PWideChar(WideString(Comp.Components[i].Name + ': ' + Comp.Components[i].ClassName)),
      PWideChar(WideString(Comp.Name)), 0);
end;

procedure EnumerateClasses(Comp: TComponent);
var
  AClass: TClass;
begin
  AClass := Comp.ClassType;
  repeat
    MessageBoxW(0, PWideChar(WideString(AClass.ClassName)),
      PWideChar(WideString(Comp.Name)), 0);
    AClass := Aclass.ClassParent;
  until AClass = nil;
end;
//------------------------------}

//------------------------------
function GetIdeMainForm: TCustomForm;
var
  Comp: TComponent;
begin
  Result := nil;
  if Application <> nil then begin
    Comp := Application.FindComponent('AppBuilder');
    if Comp is TCustomForm then
      Result := TCustomForm(Comp);
  end;
end;

function GetObjectInspectorForm: TCustomForm;
var
  Comp: TComponent;
  IdeMainForm: TCustomForm;
begin
  Result := nil;
  IdeMainForm := GetIdeMainForm;
  if IdeMainForm <> nil then begin
    Comp := IdeMainForm.FindComponent('PropertyInspector');
    if Comp is TCustomForm then
      Result := TCustomForm(Comp);
  end;
end;

{ TPropertyEditorWithDialog }
type
  TPropertyEditorWithDialog = class
  private
    FPropName: AnsiString;
    {$IFDEF COMPILER_6_UP}
    procedure CheckEditProperty(const Prop: IProperty);
    {$ELSE}
    procedure CheckEditProperty(Prop: TPropertyEditor);
    {$ENDIF}
    procedure EditProperty(Component: TPersistent; const PropName: AnsiString; const Designer: ITntDesigner);
  end;

{$IFDEF COMPILER_6_UP}
procedure TPropertyEditorWithDialog.CheckEditProperty(const Prop: IProperty);
begin
  if Prop.GetName = FPropName then
    Prop.Edit;
end;

procedure TPropertyEditorWithDialog.EditProperty(Component: TPersistent; const PropName: AnsiString; const Designer: ITntDesigner);
var
  Components: IDesignerSelections;
begin
  FPropName := PropName;
  Components := TDesignerSelections.Create;
  Components.Add(Component);
  GetComponentProperties(Components, [tkClass], Designer, CheckEditProperty);
end;
{$ELSE}
procedure TPropertyEditorWithDialog.CheckEditProperty(Prop: TPropertyEditor);
begin
  if Prop.GetName = FPropName then
    Prop.Edit;
end;

procedure TPropertyEditorWithDialog.EditProperty(Component: TPersistent; const PropName: AnsiString; const Designer: ITntDesigner);
var
  Components: TDesignerSelectionList;
begin
  FPropName := PropName;
  Components := TDesignerSelectionList.Create;
  try
    Components.Add(Component);
    GetComponentProperties(Components, [tkClass], Designer, CheckEditProperty);
  finally
    Components.Free;
  end;
end;
{$ENDIF}

procedure EditPropertyWithDialog(Component: TPersistent; const PropName: AnsiString; const Designer: ITntDesigner);
begin
  with TPropertyEditorWithDialog.Create do
  try
    EditProperty(Component, PropName, Designer);
  finally
    Free;
  end;
end;

end.
