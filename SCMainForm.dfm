object MainForm: TMainForm
  Left = 637
  Top = 101
  Width = 200
  Height = 111
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TntButton1: TTntButton
    Left = 24
    Top = 48
    Width = 75
    Height = 25
    Caption = 'TntButton1'
    TabOrder = 0
  end
  object XPManifest: TXPManifest
    Left = 72
    Top = 8
  end
  object Systray: TScSystray
    Popup = pmSystray
    Visible = True
    Left = 40
    Top = 8
  end
  object pmSystray: TTntPopupMenu
    Left = 8
    Top = 8
    object miActivate: TTntMenuItem
      Caption = 'Activate'
      OnClick = miActivateClick
    end
    object miDeactivate: TTntMenuItem
      Caption = 'Deactivate'
      Visible = False
      OnClick = miActivateClick
    end
    object N2: TTntMenuItem
      Caption = '-'
    end
    object miNewThread: TTntMenuItem
      Caption = 'New thread'
      object miNewCopyThread: TTntMenuItem
        Caption = 'Copy...'
        OnClick = miNewCopyThreadClick
      end
      object miNewMoveThread: TTntMenuItem
        Caption = 'Move...'
        OnClick = miNewMoveThreadClick
      end
    end
    object miThreadList: TTntMenuItem
      Caption = 'Thread list'
      OnClick = miThreadListClick
      object miNoThreadList: TTntMenuItem
        Caption = 'empty'
        Visible = False
      end
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object miConfig: TTntMenuItem
      Caption = 'Configuration...'
      OnClick = miConfigClick
    end
    object miAbout: TTntMenuItem
      Caption = 'About...'
      OnClick = miAboutClick
    end
    object miExit: TTntMenuItem
      Caption = 'Exit'
      OnClick = miExitClick
    end
  end
  object ilGlobal: TImageList
    Left = 104
    Top = 8
  end
end
