unit SCCollisionRenameForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls;

type
  TCollisionRenameForm = class(TTntForm)
    rbRenameNew: TTntRadioButton;
    rbRenameOld: TTntRadioButton;
    llOriginalNameTitle: TTntLabel;
    llOriginalName: TTntLabel;
    llNewNameTitle: TTntLabel;
    edNewName: TTntEdit;
    btRename: TTntButton;
    btCancel: TTntButton;
    procedure edNewNameKeyPress(Sender: TObject; var Key: Char);
    procedure edNewNameChange(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  CollisionRenameForm: TCollisionRenameForm;

implementation

{$R *.dfm}

uses SCCommon,SCLocStrings,SCWin32,TntSysutils;

procedure TCollisionRenameForm.edNewNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in ['\','/',':','?','*','"','<','>','|'] then Key:=#0; //caract�res interdits dans un nom de fichier
end;

procedure TCollisionRenameForm.edNewNameChange(Sender: TObject);
begin
  btRename.Enabled:=TrimRight(edNewName.Text)<>llOriginalName.Caption;
end;

end.
