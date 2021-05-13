unit SCCollisionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls,SCCopier,SCCommon;

type
  TCollisionForm = class(TTntForm)
    imIcon: TTntImage;
    llCollisionText1: TTntLabel;
    llFileName: TTntLabel;
    llSourceTitle: TTntLabel;
    llDestiationTitle: TTntLabel;
    llCollisionText2: TTntLabel;
    llSourceData: TTntLabel;
    llDestinationData: TTntLabel;
    btCancel: TTntButton;
    btOverwrite: TTntButton;
    btResume: TTntButton;
    btSkip: TTntButton;
    btOverwriteIfDifferent: TTntButton;
    btRenameNew: TTntButton;
    btRenameOld: TTntButton;
    chSameForNext: TTntCheckBox;
    btCustomRename: TTntButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btCancelClick(Sender: TObject);
    procedure btSkipClick(Sender: TObject);
    procedure btResumeClick(Sender: TObject);
    procedure btOverwriteClick(Sender: TObject);
    procedure btOverwriteIfDifferentClick(Sender: TObject);
    procedure btRenameNewClick(Sender: TObject);
    procedure btRenameOldClick(Sender: TObject);
    procedure chSameForNextClick(Sender: TObject);
    procedure btCustomRenameClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure DisableButtons;
  public
    { Déclarations publiques }
    Action:TCollisionAction;
    SameForNext:Boolean;
    FileName:WideString;
    CustomRename:Boolean;
  end;

var
  CollisionForm: TCollisionForm;

implementation

{$R *.dfm}

uses SCCollisionRenameForm, DateUtils;

procedure TCollisionForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btOverwrite.Enabled:=False;
  btResume.Enabled:=False;
  btSkip.Enabled:=False;
  btOverwriteIfDifferent.Enabled:=False;
  btRenameNew.Enabled:=False;
  btRenameOld.Enabled:=False;
  chSameForNext.Enabled:=False;
end;

procedure TCollisionForm.FormCreate(Sender: TObject);
begin
  Action:=claNone;
  SameForNext:=False;
  FileName:='';
  CustomRename:=False;
end;

procedure TCollisionForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=False;
  Action:=claCancel;
  DisableButtons;
end;

procedure TCollisionForm.btCancelClick(Sender: TObject);
begin
  Action:=claCancel;
  DisableButtons;
end;

procedure TCollisionForm.btSkipClick(Sender: TObject);
begin
  Action:=claSkip;
  DisableButtons;
end;

procedure TCollisionForm.btResumeClick(Sender: TObject);
begin
  Action:=claResume;
  DisableButtons;
end;

procedure TCollisionForm.btOverwriteClick(Sender: TObject);
begin
  Action:=claOverwrite;
  DisableButtons;
end;

procedure TCollisionForm.btOverwriteIfDifferentClick(Sender: TObject);
begin
  Action:=claOverwriteIfDifferent;
  DisableButtons;
end;

procedure TCollisionForm.btRenameNewClick(Sender: TObject);
begin
  Action:=claRenameNew;
  DisableButtons;
end;

procedure TCollisionForm.btRenameOldClick(Sender: TObject);
begin
  Action:=claRenameOld;
  DisableButtons;
end;

procedure TCollisionForm.chSameForNextClick(Sender: TObject);
begin
  SameForNext:=chSameForNext.Checked;
end;

procedure TCollisionForm.btCustomRenameClick(Sender: TObject);
begin
  try
    Application.CreateForm(TCollisionRenameForm,CollisionRenameForm);

    with CollisionRenameForm do
    begin
      llOriginalName.Caption:=FileName;
      edNewName.Text:=FileName;

      CollisionRenameForm.ShowModal;
      if CollisionRenameForm.ModalResult=mrOk then
      begin
        CustomRename:=True;

        FileName:=edNewName.Text;

        if rbRenameNew.Checked then
          Self.Action:=claRenameNew
        else
          Self.Action:=claRenameOld;

      end;
    end;
  finally
    CollisionRenameForm.Free;
  end;
end;

end.
