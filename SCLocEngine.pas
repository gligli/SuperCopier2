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

unit SCLocEngine;

interface
uses
  Windows,Messages,Classes,Forms,Controls,TntForms,TntStdCtrls,TntComCtrls,Graphics,
  TntClasses,TntMenus,TntDialogs,TntButtons,SCCommon,SCPopupButton,SCWin32,IniFiles;

type
  TLocEngine=class
  private
    LangIni:TMemIniFile;
    Strings:TTntStringList;

    procedure ReadHeader;
    procedure WriteHeader;
    procedure ReadStrings;
    function GetComponentText(Component:TComponent):WideString;
    procedure SetComponentText(Component:TComponent;Text:WideString);
  public
    IsUTF8:Boolean;
    UIFont:String;

    constructor Create;
    destructor Destroy;override;

    procedure LoadLanguageFile(LangFile:WideString);
    procedure TranslateForm(Form:TTntForm);
    procedure TranslateString(Id:Integer;var S:WideString);
    procedure AddForm(Form:TTntForm);
    procedure UpdateFile;
  end;

const
  LANG_SUBDIR:WideString='.\Languages\';
  LANG_EXT:WideString='.lng';
  HEADER_SECTION='-Header-'; // le '-' est interdit dans les noms de form
  STRINGS_SECTION='-Strings-';
  CAPTION_VALUE='-Caption-';
  DEFAULT_LANGUAGE='English (default)';
  TMP_LANGFILE_NAME='SC2Lang.lng';
  DEFAULT_UI_FONT='MS Sans Serif';

var
  LocEngine:TLocEngine=nil;
  
implementation

uses ComCtrls,SysUtils,TntSysUtils, TypInfo;

constructor TLocEngine.Create;
begin
  LangIni:=nil;
  Strings:=TTntStringList.Create;
end;

destructor TLocEngine.Destroy;
begin
  Strings.Free;
  LangIni.Free;
end;

procedure TLocEngine.LoadLanguageFile(LangFile:WideString);
var TmpLangFile:String;
begin
  if Assigned(LangIni) then LangIni.Free;

  TmpLangFile:=LangFile;
  if WideString(TmpLangFile)<>LangFile then // le nom de fichier est-il passé 'sans pertes' en ansi?
  begin
    //HACK: TMemIniFile ne supporte pas unicode, je crée donc une version temporaire
    //      du fichier de langues ne contenant que des caractères ansi dans le nom
    TmpLangFile:=SCWin32.GetTempPath+TMP_LANGFILE_NAME;
    SCWin32.CopyFile(PWideChar(LangFile),PWideChar(WideString(TmpLangFile)),False);
  end;

  LangIni:=TMemIniFile.Create(TmpLangFile);
  ReadHeader;
  ReadStrings;
end;

procedure TLocEngine.ReadHeader;
begin
  if not Assigned(LangIni) then exit;

  IsUTF8:=LangIni.ReadBool(HEADER_SECTION,'IsUTF8',False);
  UIFont:=LangIni.ReadString(HEADER_SECTION,'UIFont',DEFAULT_UI_FONT);
  dbgln(UIFont);
end;

procedure TLocEngine.WriteHeader;
begin
  if not Assigned(LangIni) then exit;

  LangIni.WriteBool(HEADER_SECTION,'IsUTF8',IsUTF8);
end;

procedure TLocEngine.ReadStrings;
var i:Integer;
    S:String;
begin
  if not Assigned(LangIni) then exit;

  Strings.Clear;
  i:=1;
  while LangIni.ValueExists(STRINGS_SECTION,IntToStr(I)) do
  begin
    S:=LangIni.ReadString(STRINGS_SECTION,IntToStr(I),'');
    S:=StringReplace(S,'|',#13#10,[rfReplaceAll]);
    if IsUTF8 then
      Strings.Add(UTF8Decode(S))
    else
      Strings.Add(S);

    Inc(i);
  end;
end;

procedure TLocEngine.TranslateForm(Form:TTntForm);
var i:Integer;
    Name,Text:WideString;
    FormName:WideString;
begin
  if not Assigned(LangIni) then exit;

  FormName:=Form.ClassName;
  // rétrocompat anciens fichiers de langage
  if not LangIni.SectionExists(FormName) and (Length(FormName)>0) and (FormName[1]='T') then
    FormName:=Copy(FormName,2,Maxint);

  if IsUTF8 then
    Form.Caption:=UTF8Decode(LangIni.ReadString(FormName,CAPTION_VALUE,Form.Caption))
  else
    Form.Caption:=LangIni.ReadString(FormName,CAPTION_VALUE,Form.Caption);

  Form.Font.Name:=UIFont;

  for i:=0 to Form.ComponentCount-1 do
  begin
    Name:=Form.Components[i].Name;
    Text:=LangIni.ReadString(FormName,Form.Components[i].Name,'');
    if Text<>'' then
    begin
      if IsUTF8 then
        SetComponentText(Form.Components[i],UTF8Decode(Text))
      else
        SetComponentText(Form.Components[i],Text);
    end;
  end;
end;

procedure TLocEngine.AddForm(Form:TTntForm);
var i:Integer;
    Name,Text:WideString;
    StrText:String;
begin
  if not Assigned(LangIni) then exit;

  if IsUTF8 then
    LangIni.WriteString(Form.ClassName,CAPTION_VALUE,UTF8Encode(Form.Caption))
  else
    LangIni.WriteString(Form.ClassName,CAPTION_VALUE,Form.Caption);

  for i:=0 to Form.ComponentCount-1 do
  begin
    Name:=Form.Components[i].Name;
    Text:=GetComponentText(Form.Components[i]);
    if Text<>'' then
    begin
      if IsUTF8 then
        StrText:=UTF8Encode(Text)
      else
        StrText:=Text;                                 

      LangIni.WriteString(Form.ClassName,Name,StrText);
    end;
  end;
end;

procedure TLocEngine.UpdateFile;
begin
  if not Assigned(LangIni) then exit;

  WriteHeader;
  LangIni.UpdateFile;
end;

procedure TLocEngine.TranslateString(Id:Integer;var S:WideString);
begin
  if Id<=Strings.Count then S:=Strings[Id-1];
end;

function TLocEngine.GetComponentText(Component:TComponent):WideString;
  function Get_TntButton:WideString;
  begin
    Result:=(Component as TTntButton).Caption;
  end;

  function Get_TntLabel:WideString;
  begin
    Result:=(Component as TTntLabel).Caption;
  end;

  function Get_TntEdit:WideString;
  begin
    Result:=(Component as TTntEdit).Text;
  end;

  function Get_TntComboBox:WideString;
  begin
    Result:=(Component as TTntComboBox).Items.CommaText;
  end;

  function Get_TntCheckBox:WideString;
  begin
    Result:=(Component as TTntCheckBox).Caption;
  end;

  function Get_TntListView:WideString;
  var i:Integer;
      SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      with (Component as TTntListView) do
      begin
        SL.Clear;

        // colonnes
        for i:=0 to Columns.Count-1 do
          SL.Add(Columns[i].Caption);

        // items
        for i:=0 to Items.Count-1 do
          SL.Add(Items[i].Caption);

        Result:=SL.CommaText;
      end;
    finally
      SL.Free;
    end;
  end;

  function Get_TntGroupBox:WideString;
  begin
    Result:=(Component as TTntGroupBox).Caption;
  end;

  function Get_TntTabSheet:WideString;
  begin
    Result:=(Component as TTntTabSheet).Caption;
  end;

  function Get_TntMenuItem:WideString;
  begin
    Result:=(Component as TTntMenuItem).Caption;
  end;

  function Get_TntOpenDialog:WideString;
  begin
    Result:=(Component as TTntOpenDialog).Filter;
  end;

  function Get_TntSpeedButton:WideString;
  var SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      SL.Add((Component as TTntSpeedButton).Caption);
      SL.Add((Component as TTntSpeedButton).Hint);
      Result:=SL.CommaText;
    finally
      SL.Free;
    end;
  end;

  function Get_SCPopupButton:WideString;
  var SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      SL.Add((Component as TScPopupButton).Caption);
      SL.Add((Component as TScPopupButton).Hint);
      Result:=SL.CommaText;
    finally
      SL.Free;
    end;
  end;

  function Get_TntRadioButton:WideString;
  begin
    Result:=(Component as TTntRadioButton).Caption;
  end;

begin
  Result:='';
  if Component is TTntButton then
    Result:=Get_TntButton
  else if Component is TTntLabel then
    Result:=Get_TntLabel
  else if Component is TTntEdit then
    Result:=Get_TntEdit
  else if Component is TTntComboBox then
    Result:=Get_TntComboBox
  else if Component is TTntCheckBox then
    Result:=Get_TntCheckBox
  else if Component is TTntListView then
    Result:=Get_TntListView
  else if Component is TTntGroupBox then
    Result:=Get_TntGroupBox
  else if Component is TTntTabSheet then
    Result:=Get_TntTabSheet
  else if Component is TTntMenuItem then
    Result:=Get_TntMenuItem
  else if Component is TTntOpenDialog then
    Result:=Get_TntOpenDialog
  else if Component is TTntSpeedButton then
    Result:=Get_TntSpeedButton
  else if Component is TScPopupButton then
    Result:=Get_SCPopupButton
  else if Component is TTntRadioButton then
    Result:=Get_TntRadioButton;
end;

procedure TLocEngine.SetComponentText(Component:TComponent;Text:WideString);
  procedure Set_TntButton;
  begin
    (Component as TTntButton).Caption:=Text;
  end;

  procedure Set_TntLabel;
  begin
    (Component as TTntLabel).Caption:=Text;
  end;

  procedure Set_TntEdit;
  begin
    (Component as TTntEdit).Text:=Text;
  end;

  procedure Set_TntComboBox;
  var Idx:Integer;
  begin
    Idx:=(Component as TTntComboBox).ItemIndex;
    (Component as TTntComboBox).Items.CommaText:=Text;
    if Idx<(Component as TTntComboBox).Items.Count then
      (Component as TTntComboBox).ItemIndex:=Idx;
  end;

  procedure Set_TntCheckBox;
  begin
    (Component as TTntCheckBox).Caption:=Text;
  end;

  procedure Set_TntListView;
  var i:Integer;
      SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      with (Component as TTntListView) do
      begin
        SL.CommaText:=Text;

        Items.BeginUpdate;

        // colonnes
        for i:=0 to Columns.Count-1 do
          Columns[i].Caption:=SL[i];

        // items
        for i:=0 to Items.Count-1 do
          Items[i].Caption:=SL[i+Columns.Count];

        Items.EndUpdate;
      end;
    finally
      SL.Free;
    end;
  end;

  procedure Set_TntGroupBox;
  begin
    (Component as TTntGroupBox).Caption:=Text;
  end;

  procedure Set_TntTabSheet;
  begin
    (Component as TTntTabSheet).Caption:=Text;
  end;

  procedure Set_TntMenuItem;
  begin
    (Component as TTntMenuItem).Caption:=Text;
  end;

  procedure Set_TntOpenDialog;
  begin
    (Component as TTntOpenDialog).Filter:=Text;
  end;

  procedure Set_TntSpeedButton;
  var SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      SL.CommaText:=Text;
      (Component as TTntSpeedButton).Caption:=SL[0];
      (Component as TTntSpeedButton).Hint:=SL[1];
    finally
      SL.Free;
    end;
  end;

  procedure Set_SCPopupButton;
  var SL:TTntStringList;
  begin
    SL:=TTntStringList.Create;
    try
      SL.CommaText:=Text;
      (Component as TScPopupButton).Caption:=SL[0];
      (Component as TScPopupButton).Hint:=SL[1];
    finally
      SL.Free;
    end;
  end;

  procedure Set_TntRadioButton;
  begin
    (Component as TTntRadioButton).Caption:=Text;
  end;

begin
  if Component is TTntButton then
    Set_TntButton
  else if Component is TTntLabel then
    Set_TntLabel
  else if Component is TTntEdit then
    Set_TntEdit
  else if Component is TTntComboBox then
    Set_TntComboBox
  else if Component is TTntCheckBox then
    Set_TntCheckBox
  else if Component is TTntListView then
    Set_TntListView
  else if Component is TTntGroupBox then
    Set_TntGroupBox
  else if Component is TTntTabSheet then
    Set_TntTabSheet
  else if Component is TTntMenuItem then
    Set_TntMenuItem
  else if Component is TTntOpenDialog then
    Set_TntOpenDialog
  else if Component is TTntSpeedButton then
    Set_TntSpeedButton
  else if Component is TScPopupButton then
    Set_SCPopupButton
  else if Component is TTntRadioButton then
    Set_TntRadioButton;
end;

end.
