object MainForm: TMainForm
  Left = 567
  Top = 99
  Width = 252
  Height = 216
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TntButton1: TTntButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'TntButton1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object TntButton2: TTntButton
    Left = 16
    Top = 160
    Width = 75
    Height = 25
    Caption = 'TntButton2'
    TabOrder = 1
    OnClick = TntButton2Click
  end
  object TntCheckBox1: TTntCheckBox
    Left = 144
    Top = 168
    Width = 97
    Height = 17
    Caption = 'TntCheckBox1'
    TabOrder = 2
  end
  object TntListBox1: TTntListBox
    Left = 16
    Top = 40
    Width = 201
    Height = 97
    ItemHeight = 13
    TabOrder = 3
  end
  object TntButton3: TTntButton
    Left = 128
    Top = 8
    Width = 75
    Height = 25
    Caption = 'TntButton3'
    TabOrder = 4
    OnClick = TntButton3Click
  end
  object TntEdit1: TTntEdit
    Left = 112
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'TntEdit1'
  end
end
