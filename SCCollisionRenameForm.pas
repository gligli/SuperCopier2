unit SCCollisionRenameForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ScPopupButton;

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
