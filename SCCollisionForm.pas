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

unit SCCollisionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls,SCCopier,SCCommon,
  SCFileNameLabel, Menus, TntMenus, ScPopupButton,SCLocEngine;

type
  TCollisionForm = class(TTntForm)
    imIcon: TTntImage;
    llCollisionText1: TTntLabel;
    llSourceTitle: TTntLabel;
    llDestiationTitle: TTntLabel;
    llCollisionText2: TTntLabel;
    llSourceData: TTntLabel;
    llDestinationData: TTntLabel;
    llFileName: TSCFileNameLabel;
    btCancel: TScPopupButton;
    btSkip: TScPopupButton;
    btOverwrite: TScPopupButton;
    btResume: TScPopupButton;
    btRename: TScPopupButton;
    pmSkip: TTntPopupMenu;
    pmResume: TTntPopupMenu;
    pmOverwrite: TTntPopupMenu;
    pmRename: TTntPopupMenu;
    Skip1: TTntMenuItem;
    Alwaysskip1: TTntMenuItem;
    Resume1: TTntMenuItem;
    Alwaysresume1: TTntMenuItem;
    Overwrite1: TTntMenuItem;
    Overwtiteisdifferent1: TTntMenuItem;
    Alwaysoverwrite1: TTntMenuItem;
    Alwaysoverwriteifdifferent1: TTntMenuItem;
    Rename1: TTntMenuItem;
    Renameoldfile1: TTntMenuItem;
    Customrename1: TTntMenuItem;
    Alwaysrename1: TTntMenuItem;
    Alwaysrenameoldfile1: TTntMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btSkipClick(Sender: TObject; ItemIndex: Integer);
    procedure btResumeClick(Sender: TObject; ItemIndex: Integer);
    procedure btOverwriteClick(Sender: TObject; ItemIndex: Integer);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btRenameClick(Sender: TObject; ItemIndex: Integer);
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

uses SCCollisionRenameForm, DateUtils,SCMainForm;

procedure TCollisionForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btOverwrite.Enabled:=False;
  btResume.Enabled:=False;
  btSkip.Enabled:=False;
  btRename.Enabled:=False;
end;

procedure TCollisionForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);

  //HACK: ne pas mettre directement la fenêtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeToolWin;

  // empécher le resize vertical
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;

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

procedure TCollisionForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=claCancel;
  DisableButtons;
end;

procedure TCollisionForm.btSkipClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=claSkip;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCollisionForm.btResumeClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=claResume;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCollisionForm.btOverwriteClick(Sender: TObject;
  ItemIndex: Integer);
begin
  case ItemIndex of
    0:
    begin
      Action:=claOverwrite;
      SameForNext:=False;
    end;
    1:
    begin
      Action:=claOverwriteIfDifferent;
      SameForNext:=False;
    end;
    2:
    begin
      Action:=claOverwrite;
      SameForNext:=True;
    end;
    3:
    begin
      Action:=claOverwriteIfDifferent;
      SameForNext:=True;
    end;
  end;
  DisableButtons;
end;

procedure TCollisionForm.btRenameClick(Sender: TObject;
  ItemIndex: Integer);
  procedure DoCustomRename;
  begin
    try
      CollisionRenameForm:=TCollisionRenameForm.Create(Self);

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
begin
  case ItemIndex of
    0:
    begin
      Action:=claRenameNew;
      SameForNext:=False;
    end;
    1:
    begin
      Action:=claRenameOld;
      SameForNext:=False;
    end;
    2:
    begin
      DoCustomRename;
    end;
    3:
    begin
      Action:=claRenameNew;
      SameForNext:=True;
    end;
    4:
    begin
      Action:=claRenameOld;
      SameForNext:=True;
    end;
  end;
  if ItemIndex<>2 then DisableButtons;
end;

end.
