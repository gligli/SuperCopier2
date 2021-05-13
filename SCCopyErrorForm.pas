unit SCCopyErrorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls,SCCopier,SCCommon,
  SCFileNameLabel;

type
  TCopyErrorForm = class(TTntForm)
    imIcon: TTntImage;
    llCopyErrorText3: TTntLabel;
    llCopyErrorText1: TTntLabel;
    llCopyErrorText2: TTntLabel;
    mmErrorText: TTntMemo;
    btCancel: TTntButton;
    btSkip: TTntButton;
    btRetry: TTntButton;
    btEndOfList: TTntButton;
    chSameForNext: TTntCheckBox;
    llFileName: TSCFileNameLabel;
    procedure FormCreate(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btSkipClick(Sender: TObject);
    procedure btRetryClick(Sender: TObject);
    procedure btEndOfListClick(Sender: TObject);
    procedure TntFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chSameForNextClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure DisableButtons;
  public
    { Déclarations publiques }
    Action:TCopyErrorAction;
    SameForNext:Boolean;
  end;

var
  CopyErrorForm: TCopyErrorForm;

implementation

{$R *.dfm}

procedure TCopyErrorForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btSkip.Enabled:=False;
  btRetry.Enabled:=False;
  btEndOfList.Enabled:=False;
  chSameForNext.Enabled:=False;
end;

procedure TCopyErrorForm.FormCreate(Sender: TObject);
begin
  //HACK: ne pas mettre directement la fenêtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeable;

  // empécher le resize vertical
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;

  Action:=ceaNone;
  SameForNext:=False;
end;

procedure TCopyErrorForm.btCancelClick(Sender: TObject);
begin
  Action:=ceaCancel;
  DisableButtons;
end;

procedure TCopyErrorForm.btSkipClick(Sender: TObject);
begin
  Action:=ceaSkip;
  DisableButtons;
end;

procedure TCopyErrorForm.btRetryClick(Sender: TObject);
begin
  Action:=ceaRetry;
  DisableButtons;
end;

procedure TCopyErrorForm.btEndOfListClick(Sender: TObject);
begin
  Action:=ceaEndOfList;
  DisableButtons;
end;

procedure TCopyErrorForm.TntFormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=False;
  Action:=ceaCancel;
  DisableButtons;
end;

procedure TCopyErrorForm.chSameForNextClick(Sender: TObject);
begin
  SameForNext:=chSameForNext.Checked;
end;

end.
