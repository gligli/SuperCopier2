object CollisionForm: TCollisionForm
  Left = 251
  Top = 102
  Width = 408
  Height = 177
  BorderIcons = [biSystemMenu]
  Caption = ' - File already exists'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    400
    150)
  PixelsPerInch = 96
  TextHeight = 13
  object imIcon: TTntImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    Picture.Data = {
      07544269746D617076020000424D760200000000000076000000280000002000
      0000200000000100040000000000000200000000000000000000100000001000
      000000000000000080000080000000808000800000008000800080800000C0C0
      C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF00777778888888888888888888888888777777888888888888888888888888
      88877730000000000000000000000008888873BBBBBBBBBBBBBBBBBBBBBBBB70
      88883BBBBBBBBBBBBBBBBBBBBBBBBBB708883BBBBBBBBBBBBBBBBBBBBBBBBBBB
      08883BBBBBBBBBBBB7007BBBBBBBBBBB08873BBBBBBBBBBBB0000BBBBBBBBBB7
      088773BBBBBBBBBBB0000BBBBBBBBBB0887773BBBBBBBBBBB7007BBBBBBBBB70
      8877773BBBBBBBBBBBBBBBBBBBBBBB088777773BBBBBBBBBBB0BBBBBBBBBB708
      87777773BBBBBBBBB707BBBBBBBBB08877777773BBBBBBBBB303BBBBBBBB7088
      777777773BBBBBBBB000BBBBBBBB0887777777773BBBBBBB70007BBBBBB70887
      7777777773BBBBBB30000BBBBBB088777777777773BBBBBB00000BBBBB708877
      77777777773BBBBB00000BBBBB08877777777777773BBBBB00000BBBB7088777
      777777777773BBBB00000BBBB0887777777777777773BBBB00000BBB70887777
      7777777777773BBB70007BBB088777777777777777773BBBBBBBBBB708877777
      77777777777773BBBBBBBBB08877777777777777777773BBBBBBBB7088777777
      777777777777773BBBBBBB0887777777777777777777773BBBBBB70887777777
      7777777777777773BBBBB088777777777777777777777773BBBB708777777777
      77777777777777773BB707777777777777777777777777777333777777777777
      7777}
    Transparent = True
  end
  object llCollisionText1: TTntLabel
    Left = 48
    Top = 8
    Width = 148
    Height = 13
    Caption = 'The following file already exists:'
  end
  object llFileName: TTntLabel
    Left = 48
    Top = 24
    Width = 345
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llFileName'
  end
  object llSourceTitle: TTntLabel
    Left = 48
    Top = 40
    Width = 37
    Height = 13
    Caption = 'Source:'
  end
  object llDestiationTitle: TTntLabel
    Left = 48
    Top = 56
    Width = 56
    Height = 13
    Caption = 'Destination:'
  end
  object llCollisionText2: TTntLabel
    Left = 48
    Top = 80
    Width = 126
    Height = 13
    Caption = 'What would you like to to?'
  end
  object llSourceData: TTntLabel
    Left = 112
    Top = 40
    Width = 281
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llSourceData'
  end
  object llDestinationData: TTntLabel
    Left = 112
    Top = 56
    Width = 281
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llDestinationData'
  end
  object btCancel: TTntButton
    Left = 8
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = btCancelClick
  end
  object btOverwrite: TTntButton
    Left = 176
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Overwrite'
    TabOrder = 1
    OnClick = btOverwriteClick
  end
  object btResume: TTntButton
    Left = 120
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Resume'
    TabOrder = 2
    OnClick = btResumeClick
  end
  object btSkip: TTntButton
    Left = 64
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Skip'
    TabOrder = 3
    OnClick = btSkipClick
  end
  object btOverwriteIfDifferent: TTntButton
    Left = 232
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Over <>'
    TabOrder = 4
    OnClick = btOverwriteIfDifferentClick
  end
  object btRenameNew: TTntButton
    Left = 288
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Ren new'
    TabOrder = 5
    OnClick = btRenameNewClick
  end
  object btRenameOld: TTntButton
    Left = 344
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Ren old'
    TabOrder = 6
    OnClick = btRenameOldClick
  end
  object chSameForNext: TTntCheckBox
    Left = 8
    Top = 128
    Width = 97
    Height = 17
    Caption = 'chSameForNext'
    TabOrder = 7
    OnClick = chSameForNextClick
  end
  object btCustomRename: TTntButton
    Left = 288
    Top = 72
    Width = 105
    Height = 25
    Caption = 'Custom Rename'
    TabOrder = 8
    OnClick = btCustomRenameClick
  end
end
