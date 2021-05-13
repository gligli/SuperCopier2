
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://www.tntware.com/delphicontrols/unicode/                         }
{        Version: 2.2.3                                                       }
{                                                                             }
{    Copyright (c) 2002-2006, Troy Wolbrink (troy.wolbrink@tntware.com)       }
{                                                                             }
{*****************************************************************************}

unit TntForms_Design;

{$INCLUDE ..\TntCompilers.inc}

interface

uses
  Classes, Windows, DesignIntf, ToolsApi, Forms;

type HICON = LongWord;

type
  TTntNewFormWizard = class(TNotifierObject, IOTAWizard, IOTARepositoryWizard, IOTAFormWizard)
  protected
    function ThisFormName: WideString;
    function ThisFormClass: TComponentClass; virtual; abstract;
  public
    // IOTAWizard
    function GetIDString: AnsiString;
    function GetName: AnsiString; virtual;
    function GetState: TWizardState;
    procedure Execute;
    // IOTARepositoryWizard
    function GetAuthor: AnsiString;
    function GetComment: AnsiString; virtual; abstract;
    function GetPage: AnsiString;
    function GetGlyph: HICON;
  end;

procedure Register;

implementation

uses
  TntForms, DesignEditors, WCtlForm, TypInfo, SysUtils;

type
  TTntNewTntFormWizard = class(TTntNewFormWizard)
  protected
    function ThisFormClass: TComponentClass; override;
  public
    function GetName: AnsiString; override;
    function GetComment: AnsiString; override;
  end;

  TTntNewTntFrameWizard = class(TTntNewFormWizard)
  protected
    function ThisFormClass: TComponentClass; override;
  public
    function GetName: AnsiString; override;
    function GetComment: AnsiString; override;
  end;

  TTntFrameCustomModule = class(TWinControlCustomModule)
  public
    function Nestable: Boolean; override;
  end;

  TTntFormCustomModule = class(TCustomModule)
  public
    class function DesignClass: TComponentClass; override;
  end;

procedure Register;
begin
  RegisterCustomModule(TTntFrame, TTntFrameCustomModule);
  RegisterPackageWizard(TTntNewTntFrameWizard.Create);
  //--
  RegisterCustomModule(TTntForm, TTntFormCustomModule);
  //--
  RegisterPackageWizard(TTntNewTntFormWizard.Create);
end;

function GetFirstModuleSupporting(const IID: TGUID): IOTAModule;
var
  ModuleServices: IOTAModuleServices;
  i: integer;
begin
  Result := nil;
  if Assigned(BorlandIDEServices) then
  begin
    // look for the first project
    ModuleServices := BorlandIDEServices as IOTAModuleServices;
    for i := 0 to ModuleServices.ModuleCount - 1 do
      if Supports(ModuleServices.Modules[i], IID, Result) then
        Break;
  end;
end;

function MyGetActiveProject: IOTAProject;
{$IFDEF COMPILER_7_UP}
begin
  Result := ToolsAPI.GetActiveProject;
{$ELSE}
var
  ProjectGroup: IOTAProjectGroup;
begin
  ProjectGroup := GetFirstModuleSupporting(IOTAProjectGroup) as IOTAProjectGroup;
  if ProjectGroup = nil then
    Result := nil
  else
    Result := ProjectGroup.ActiveProject;
{$ENDIF}
  if (Result = nil) then
    Result := GetFirstModuleSupporting(IOTAProject) as IOTAProject;
end;

{ TTntNewFormCreator }
type
  TTntNewFormCreator = class(TInterfacedObject, IOTACreator, IOTAModuleCreator)
  private
    FAncestorName: WideString;
  public
    // IOTACreator
    function GetCreatorType: AnsiString;
    function GetExisting: Boolean;
    function GetFileSystem: AnsiString;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    // IOTAModuleCreator
    function GetAncestorName: AnsiString;
    function GetImplFileName: AnsiString;
    function GetIntfFileName: AnsiString;
    function GetFormName: AnsiString;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: AnsiString): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: AnsiString): IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: AnsiString): IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  public
    constructor Create(const FormName, AncestorName: WideString);
  end;

constructor TTntNewFormCreator.Create(const FormName, AncestorName: WideString);
begin
  inherited Create;
  FAncestorName := AncestorName;
end;

procedure TTntNewFormCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin
end;

function TTntNewFormCreator.GetAncestorName: AnsiString;
begin
  Result := FAncestorName;
end;

function TTntNewFormCreator.GetCreatorType: AnsiString;
begin
  Result := sForm;
end;

function TTntNewFormCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TTntNewFormCreator.GetFileSystem: AnsiString;
begin
  Result := '';
end;

function TTntNewFormCreator.GetFormName: AnsiString;
begin
  Result := '';
end;

function TTntNewFormCreator.GetImplFileName: AnsiString;
begin
  Result := '';
end;

function TTntNewFormCreator.GetIntfFileName: AnsiString;
begin
  Result := '';
end;

function TTntNewFormCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TTntNewFormCreator.GetOwner: IOTAModule;
begin
  Result := MyGetActiveProject;
end;

function TTntNewFormCreator.GetShowForm: Boolean;
begin
  Result := True;
end;

function TTntNewFormCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TTntNewFormCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

function TTntNewFormCreator.NewFormFile(const FormIdent, AncestorIdent: AnsiString): IOTAFile;
begin
  Result := nil;
end;

function TTntNewFormCreator.NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: AnsiString): IOTAFile;
begin
  Result := nil;
end;

function TTntNewFormCreator.NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: AnsiString): IOTAFile;
begin
  Result := nil;
end;

{ TTntNewFormWizard }

function TTntNewFormWizard.ThisFormName: WideString;
begin
  Result := ThisFormClass.ClassName;
  Delete(Result, 1, 1); // drop the 'T'
end;

function TTntNewFormWizard.GetName: AnsiString;
begin
  Result := ThisFormName;
end;

function TTntNewFormWizard.GetAuthor: AnsiString;
begin
  Result := 'Troy Wolbrink';
end;

function TTntNewFormWizard.GetPage: AnsiString;
begin
  Result := 'New';
end;

function TTntNewFormWizard.GetGlyph: HICON;
begin
  Result := 0;
end;

function TTntNewFormWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

function TTntNewFormWizard.GetIDString: AnsiString;
begin
  Result := 'Tnt.Create_'+ThisFormName+'.Wizard';
end;

procedure AddUnitToUses(Module: IOTAModule; UnitName: WideString);
const
  UnitFileSize = 8192; // 8k ought to be enough for everybody! (we're dealing with a new default unit)
var
  Editor: IOTASourceEditor;
  Reader: IOTAEditReader;
  Writer: IOTAEditWriter;
  Buffer, P: PAnsiChar;
  StartPos: Integer;
begin
  (* Warning: add the necessary routines for C++Builder *)
  Buffer := StrAlloc{TNT-ALLOW StrAlloc}(UnitFileSize);
  Editor := (Module.GetModuleFileEditor(0)) as IOTASourceEditor;
  try
    Reader := Editor.CreateReader;
    try
      StartPos := Reader.GetText(0, Buffer, UnitFileSize);
      P := StrPos{TNT-ALLOW StrPos}(Buffer, 'uses'); // Locate uses
      P := StrPos{TNT-ALLOW StrPos}(P, ';'); // Locate the semi-colon afterwards
      if Assigned(P) then
        StartPos := Integer(P - Buffer)
      else
        StartPos := -1;
    finally
      Reader := nil; { get rid of reader before we use writer }
    end;
    if StartPos <> -1 then
    begin
      Writer := Editor.CreateWriter;
      try
        Writer.CopyTo(StartPos);
        Writer.Insert(PAnsiChar(AnsiString(', ' + UnitName)));
      finally
        Writer := nil;
      end;
    end;
  finally
    Editor := nil;
    StrDispose{TNT-ALLOW StrDispose}(Buffer);
  end;
end;

procedure TTntNewFormWizard.Execute;
var
  Module: IOTAModule;
begin
  Module := (BorlandIDEServices as IOTAModuleServices).CreateModule(TTntNewFormCreator.Create('', ThisFormName));
  {$IFNDEF COMPILER_9_UP}
  {TODO: Get AddUnitToUses() working with D9.}
  AddUnitToUses(Module, GetTypeData(PTypeInfo(ThisFormClass.ClassInfo)).UnitName);
  {$ENDIF}
end;

{ TTntNewTntFormWizard }

function TTntNewTntFormWizard.ThisFormClass: TComponentClass;
begin
  Result := TTntForm;
end;

function TTntNewTntFormWizard.GetName: AnsiString;
begin
  Result := ThisFormName + ' (Unicode)'
end;

function TTntNewTntFormWizard.GetComment: AnsiString;
begin
  Result := 'Creates a new Unicode enabled TntForm';
end;

{ TTntNewTntFrameWizard }

function TTntNewTntFrameWizard.ThisFormClass: TComponentClass;
begin
  Result := TTntFrame;
end;

function TTntNewTntFrameWizard.GetName: AnsiString;
begin
  Result := ThisFormName + ' (Unicode)'
end;

function TTntNewTntFrameWizard.GetComment: AnsiString;
begin
  Result := 'Creates a new Unicode enabled TntFrame';
end;

{ TTntFrameCustomModule }

function TTntFrameCustomModule.Nestable: Boolean;
begin
  Result := True;
end;

{ TTntFormCustomModule }

class function TTntFormCustomModule.DesignClass: TComponentClass;
begin
  Result := TTntForm;
end;

end.
