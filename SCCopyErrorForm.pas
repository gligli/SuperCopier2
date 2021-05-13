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

unit SCCopyErrorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls,SCCopier,SCCommon,
  SCFileNameLabel, ScPopupButton, Menus, TntMenus,SCLocEngine;

type
  TCopyErrorForm = class(TTntForm)
    imIcon: TTntImage;
    llCopyErrorText3: TTntLabel;
    llCopyErrorText1: TTntLabel;
    llCopyErrorText2: TTntLabel;
    mmErrorText: TTntMemo;
    llFileName: TSCFileNameLabel;
    pmRetry: TTntPopupMenu;
    Retry1: TTntMenuItem;
    Alwaysretry1: TTntMenuItem;
    btRetry: TScPopupButton;
    btEndOfList: TScPopupButton;
    pmEndOfList: TTntPopupMenu;
    pmSkip: TTntPopupMenu;
    Skip1: TTntMenuItem;
    Alwaysskip1: TTntMenuItem;
    btSkip: TScPopupButton;
    btCancel: TScPopupButton;
    Endoflist1: TTntMenuItem;
    Alwaysputtoendoflist1: TTntMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btSkipClick(Sender: TObject; ItemIndex: Integer);
    procedure btEndOfListClick(Sender: TObject; ItemIndex: Integer);
    procedure btRetryClick(Sender: TObject; ItemIndex: Integer);
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
end;

procedure TCopyErrorForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);

  //HACK: ne pas mettre directement la fenêtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeToolWin;

  // empécher le resize vertical
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;

  Action:=ceaNone;
  SameForNext:=False;
end;

procedure TCopyErrorForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=ceaCancel;
  DisableButtons;
end;

procedure TCopyErrorForm.btSkipClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=ceaSkip;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCopyErrorForm.btEndOfListClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=ceaEndOfList;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCopyErrorForm.btRetryClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=ceaRetry;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

end.
