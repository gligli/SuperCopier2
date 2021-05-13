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

unit SCCollisionRenameForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ScPopupButton,SCLocEngine;

type
  TCollisionRenameForm = class(TTntForm)
    rbRenameNew: TTntRadioButton;
    rbRenameOld: TTntRadioButton;
    llOriginalNameTitle: TTntLabel;
    llOriginalName: TTntLabel;
    llNewNameTitle: TTntLabel;
    edNewName: TTntEdit;
    btCancel: TScPopupButton;
    btRename: TScPopupButton;
    procedure edNewNameKeyPress(Sender: TObject; var Key: Char);
    procedure edNewNameChange(Sender: TObject);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btRenameClick(Sender: TObject; ItemIndex: Integer);
    procedure TntFormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  CollisionRenameForm: TCollisionRenameForm;

implementation

{$R *.dfm}

uses SCCommon,SCLocStrings,SCWin32,TntSysutils;

procedure TCollisionRenameForm.TntFormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);
end;

procedure TCollisionRenameForm.edNewNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in ['\','/',':','?','*','"','<','>','|'] then Key:=#0; //caractères interdits dans un nom de fichier
end;

procedure TCollisionRenameForm.edNewNameChange(Sender: TObject);
begin
  btRename.Enabled:=TrimRight(edNewName.Text)<>llOriginalName.Caption;
end;

procedure TCollisionRenameForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  ModalResult:=mrCancel;
end;

procedure TCollisionRenameForm.btRenameClick(Sender: TObject;
  ItemIndex: Integer);
begin
  ModalResult:=mrOk;
end;

end.
