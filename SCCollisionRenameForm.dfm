object CollisionRenameForm: TCollisionRenameForm
  Left = 385
  Top = 102
  BorderStyle = bsDialog
  Caption = 'Custom rename'
  ClientHeight = 150
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object llOriginalNameTitle: TTntLabel
    Left = 8
    Top = 48
    Width = 66
    Height = 13
    Caption = 'Rename from:'
  end
  object llOriginalName: TTntLabel
    Left = 80
    Top = 48
    Width = 313
    Height = 13
    AutoSize = False
    Caption = 'llOriginalName'
  end
  object llNewNameTitle: TTntLabel
    Left = 8
    Top = 80
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object rbRenameNew: TTntRadioButton
    Left = 8
    Top = 8
    Width = 113
    Height = 17
    Caption = 'Rename new file'
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object rbRenameOld: TTntRadioButton
    Left = 208
    Top = 8
    Width = 113
    Height = 17
    Caption = 'Rename old file'
    TabOrder = 1
  end
  object edNewName: TTntEdit
    Left = 80
    Top = 76
    Width = 313
    Height = 21
    TabOrder = 2
    Text = 'edNewName'
    OnChange = edNewNameChange
    OnKeyPress = edNewNameKeyPress
  end
  object btRename: TTntButton
    Left = 240
    Top = 120
    Width = 75
    Height = 25
    Caption = 'btRename'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 3
  end
  object btCancel: TTntButton
    Left = 320
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'btCancel'
    ModalResult = 2
    TabOrder = 4
  end
end
