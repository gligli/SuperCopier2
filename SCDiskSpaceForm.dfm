object DiskSpaceForm: TDiskSpaceForm
  Left = 193
  Top = 100
  BorderStyle = bsDialog
  Caption = ' - Not enough free space'
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object llDiskSpaceText1: TTntLabel
    Left = 48
    Top = 8
    Width = 270
    Height = 13
    Caption = 'There is not enough free space on the following volumes:'
  end
  object llDiskSpaceText2: TTntLabel
    Left = 48
    Top = 104
    Width = 126
    Height = 13
    Caption = 'What would you like to to?'
  end
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
  object lvDiskSpace: TTntListView
    Left = 48
    Top = 23
    Width = 345
    Height = 79
    Columns = <
      item
        Caption = 'Volume'
        Width = 131
      end
      item
        Alignment = taRightJustify
        Caption = 'Size'
        Width = 70
      end
      item
        Alignment = taRightJustify
        Caption = 'Free'
        Width = 70
      end
      item
        Alignment = taRightJustify
        Caption = 'Lacking'
        Width = 70
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object btCancel: TTntButton
    Left = 320
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'btCancel'
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btForce: TTntButton
    Left = 240
    Top = 120
    Width = 75
    Height = 25
    Caption = 'btForce'
    Default = True
    TabOrder = 2
    OnClick = btForceClick
  end
end
