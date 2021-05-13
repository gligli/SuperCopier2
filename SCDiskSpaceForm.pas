unit SCDiskSpaceForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ComCtrls, TntComCtrls, ExtCtrls,
  TntExtCtrls,SCCommon, ScPopupButton,SCLocEngine;

type
  TDiskSpaceForm = class(TTntForm)
    llDiskSpaceText1: TTntLabel;
    lvDiskSpace: TTntListView;
    llDiskSpaceText2: TTntLabel;
    imIcon: TTntImage;
    btCancel: TScPopupButton;
    btForce: TScPopupButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btForceClick(Sender: TObject; ItemIndex: Integer);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
  private
    { Déclarations privées }
    procedure DisableButtons;
  public
    { Déclarations publiques }
    Action:TDiskSpaceAction;
  end;

var
  DiskSpaceForm: TDiskSpaceForm;

implementation

{$R *.dfm}

procedure TDiskSpaceForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btForce.Enabled:=False;
end;

procedure TDiskSpaceForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);

  Action:=dsaNone;
end;

procedure TDiskSpaceForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=False;

  Action:=dsaCancel;
  DisableButtons;
end;

procedure TDiskSpaceForm.btForceClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=dsaForce;
  DisableButtons;
end;

procedure TDiskSpaceForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=dsaCancel;
  DisableButtons;
end;

end.
