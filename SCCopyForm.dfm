object CopyForm: TCopyForm
  Left = 550
  Top = 99
  Width = 408
  Height = 427
  BorderStyle = bsSizeToolWin
  Caption = 'CopyForm'
  Color = clBtnFace
  Constraints.MinHeight = 177
  Constraints.MinWidth = 408
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    400
    400)
  PixelsPerInch = 96
  TextHeight = 13
  object ggFile: TGauge
    Left = 8
    Top = 88
    Width = 385
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Progress = 50
  end
  object ggAll: TGauge
    Left = 8
    Top = 48
    Width = 385
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Progress = 50
  end
  object llFrom: TTntLabel
    Left = 40
    Top = 0
    Width = 353
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llFrom'
  end
  object llFile: TTntLabel
    Left = 8
    Top = 72
    Width = 385
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llFile'
  end
  object llAll: TTntLabel
    Left = 8
    Top = 32
    Width = 385
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llAll'
  end
  object llSpeed: TTntLabel
    Left = 8
    Top = 128
    Width = 145
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llSpeed'
  end
  object llTo: TTntLabel
    Left = 40
    Top = 16
    Width = 353
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llTo'
  end
  object llFromTitle: TTntLabel
    Left = 8
    Top = 0
    Width = 26
    Height = 13
    Caption = 'From:'
  end
  object llToTitle: TTntLabel
    Left = 8
    Top = 16
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object llAllRemaining: TTntLabel
    Left = 288
    Top = 50
    Width = 105
    Height = 13
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'llAllRemaining'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object llFileRemaining: TTntLabel
    Left = 289
    Top = 90
    Width = 104
    Height = 13
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'llFileRemaining'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object btCancel: TTntButton
    Left = 320
    Top = 120
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btCancel'
    TabOrder = 0
    OnClick = btCancelClick
  end
  object btSkip: TTntButton
    Left = 240
    Top = 120
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btSkip'
    TabOrder = 1
    OnClick = btSkipClick
  end
  object btPause: TTntButton
    Left = 160
    Top = 120
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btPause'
    TabOrder = 2
    OnClick = btPauseClick
  end
  object pcPages: TTntPageControl
    Left = 0
    Top = 150
    Width = 400
    Height = 250
    ActivePage = tsOptions
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 3
    object tsFileList: TTntTabSheet
      Caption = 'File list'
      object pnFileListButtons: TTntPanel
        Left = 0
        Top = 0
        Width = 25
        Height = 222
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object btFileUp: TTntButton
          Left = 0
          Top = 32
          Width = 25
          Height = 25
          Caption = 'U'
          TabOrder = 0
          TabStop = False
          OnClick = btFileUpClick
        end
        object btFileRemove: TTntButton
          Left = 0
          Top = 64
          Width = 25
          Height = 25
          Caption = 'R'
          TabOrder = 1
          TabStop = False
          OnClick = btFileRemoveClick
        end
        object btFileDown: TTntButton
          Left = 0
          Top = 96
          Width = 25
          Height = 25
          Caption = 'D'
          TabOrder = 2
          TabStop = False
          OnClick = btFileDownClick
        end
        object btFileBottom: TTntButton
          Left = 0
          Top = 128
          Width = 25
          Height = 25
          Caption = 'B'
          TabOrder = 3
          TabStop = False
          OnClick = btFileBottomClick
        end
        object btFileTop: TTntButton
          Left = 0
          Top = 0
          Width = 25
          Height = 25
          Caption = 'T'
          TabOrder = 4
          TabStop = False
          OnClick = btFileTopClick
        end
        object btFileSave: TTntButton
          Left = 0
          Top = 160
          Width = 25
          Height = 25
          Caption = 'S'
          TabOrder = 5
          TabStop = False
          OnClick = btFileSaveClick
        end
        object btFileLoad: TTntButton
          Left = 0
          Top = 192
          Width = 25
          Height = 25
          Caption = 'L'
          TabOrder = 6
          TabStop = False
          OnClick = btFileLoadClick
        end
      end
      object lvFileList: TTntListView
        Left = 25
        Top = 0
        Width = 367
        Height = 222
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        Columns = <
          item
            Caption = 'Source'
            Width = 250
          end
          item
            Alignment = taRightJustify
            Caption = 'Size'
            Width = 75
          end
          item
            Caption = 'Target'
            Width = 300
          end>
        ColumnClick = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        HideSelection = False
        MultiSelect = True
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        PopupMenu = pmFileContext
        TabOrder = 1
        ViewStyle = vsReport
        OnData = lvFileListData
      end
    end
    object tsErrors: TTntTabSheet
      Caption = 'Errors'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      object pnErrorListButtons: TTntPanel
        Left = 0
        Top = 0
        Width = 25
        Height = 222
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object btErrorClear: TTntButton
          Left = 0
          Top = 0
          Width = 25
          Height = 25
          Caption = 'C'
          TabOrder = 0
          TabStop = False
          OnClick = btErrorClearClick
        end
        object btErrorSaveLog: TTntButton
          Left = 0
          Top = 32
          Width = 25
          Height = 25
          Caption = 'S'
          TabOrder = 1
          TabStop = False
          OnClick = btErrorSaveLogClick
        end
      end
      object lvErrorList: TTntListView
        Left = 25
        Top = 0
        Width = 367
        Height = 222
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        Columns = <
          item
            Caption = 'Time'
            Width = 65
          end
          item
            Caption = 'Action'
          end
          item
            Caption = 'Target'
            Width = 200
          end
          item
            Caption = 'Error text'
            Width = 300
          end>
        ColumnClick = False
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        OnData = lvFileListData
      end
    end
    object tsOptions: TTntTabSheet
      Caption = 'Options'
      DesignSize = (
        392
        222)
      object gbSpeedLimit: TTntGroupBox
        Left = 8
        Top = 76
        Width = 377
        Height = 44
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Speed limit'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object llSpeedLimitKB: TTntLabel
          Left = 272
          Top = 17
          Width = 14
          Height = 13
          Caption = 'KB'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object chSpeedLimit: TTntCheckBox
          Left = 8
          Top = 16
          Width = 113
          Height = 17
          Caption = 'Limit copy speed to:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = chSpeedLimitClick
        end
        object cbSpeedLimit: TTntComboBox
          Left = 184
          Top = 14
          Width = 81
          Height = 21
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 1
          Text = '1024'
          OnChange = cbSpeedLimitChange
          OnKeyPress = cbSpeedLimitKeyPress
          Items.WideStrings = (
            '64'
            '128'
            '256'
            '512'
            '1024'
            '2048'
            '4096'
            '8192'
            '16384'
            '32768')
        end
      end
      object gbCollisions: TTntGroupBox
        Left = 8
        Top = 124
        Width = 377
        Height = 44
        Anchors = [akLeft, akTop, akRight]
        Caption = 'File collisions'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        DesignSize = (
          377
          44)
        object llCollisions: TTntLabel
          Left = 8
          Top = 18
          Width = 161
          Height = 13
          Caption = 'When a file already exists, always:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cbCollisions: TTntComboBox
          Left = 184
          Top = 14
          Width = 185
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ItemIndex = 0
          ParentFont = False
          TabOrder = 0
          Text = 'Ask what to do'
          OnChange = cbCollisionsChange
          Items.WideStrings = (
            'Ask what to do'
            'Cancel the whole copy'
            'Skip'
            'Resume transfert'
            'Overwrite'
            'Overwrite if different'
            'Rename new file'
            'Rename old file')
        end
      end
      object gbCopyErrors: TTntGroupBox
        Left = 8
        Top = 172
        Width = 377
        Height = 44
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Copy errors'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        DesignSize = (
          377
          44)
        object llCopyErrors: TTntLabel
          Left = 8
          Top = 18
          Width = 166
          Height = 13
          Caption = 'When there is a copy error, always:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cbCopyError: TTntComboBox
          Left = 184
          Top = 14
          Width = 185
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ItemIndex = 0
          ParentFont = False
          TabOrder = 0
          Text = 'Ask what to do'
          OnChange = cbCopyErrorChange
          Items.WideStrings = (
            'Ask what to do'
            'Cancel then whole copy'
            'Skip'
            'Retry'
            'Put the file at the copy list bottom')
        end
      end
      object gbGeneral: TTntGroupBox
        Left = 8
        Top = 3
        Width = 377
        Height = 70
        Anchors = [akLeft, akTop, akRight]
        Caption = 'General'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        DesignSize = (
          377
          70)
        object llCopyEnd: TTntLabel
          Left = 8
          Top = 18
          Width = 108
          Height = 13
          Caption = 'At the end of the copy:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cbCopyEnd: TTntComboBox
          Left = 184
          Top = 13
          Width = 185
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ItemIndex = 0
          ParentFont = False
          TabOrder = 0
          Text = 'Close the window'
          OnChange = cbCopyEndChange
          Items.WideStrings = (
            'Close the window'
            'Don'#39't close the window'
            'Don'#39't close if there was errors')
        end
      end
    end
  end
  object pmFileContext: TTntPopupMenu
    Left = 236
    Top = 6
    object miTop: TTntMenuItem
      Caption = 'Top'
      ShortCut = 16468
      OnClick = btFileTopClick
    end
    object miUp: TTntMenuItem
      Caption = 'Up'
      ShortCut = 16469
      OnClick = btFileUpClick
    end
    object miDown: TTntMenuItem
      Caption = 'Down'
      ShortCut = 16452
      OnClick = btFileDownClick
    end
    object miBottom: TTntMenuItem
      Caption = 'Bottom'
      ShortCut = 16450
      OnClick = btFileBottomClick
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object miRemove: TTntMenuItem
      Caption = 'Remove'
      ShortCut = 46
      OnClick = btFileRemoveClick
    end
    object N2: TTntMenuItem
      Caption = '-'
    end
    object miSelectAll: TTntMenuItem
      Caption = 'Select all'
      ShortCut = 16449
      OnClick = miSelectAllClick
    end
    object miInvert: TTntMenuItem
      Caption = 'Invert selection'
      ShortCut = 16457
      OnClick = miInvertClick
    end
  end
  object pmDropFiles: TTntPopupMenu
    Left = 268
    Top = 6
    object miDefaultDest: TTntMenuItem
      Caption = 'Use default destination folder ()'
      Default = True
      OnClick = miDefaultDestClick
    end
    object miChooseDest: TTntMenuItem
      Caption = 'Choose destination folder'
      OnClick = miChooseDestClick
    end
    object miChooseSetDefault: TTntMenuItem
      Caption = 'Choose destination folder and set it as default'
      OnClick = miChooseSetDefaultClick
    end
    object N3: TTntMenuItem
      Caption = '-'
    end
    object miCancel: TTntMenuItem
      Caption = 'Cancel'
      OnClick = miCancelClick
    end
  end
  object odCopyList: TTntOpenDialog
    DefaultExt = 'scl'
    Filter = 'SuperCopier2 Copy List (*.scl)|*.scl'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 300
    Top = 6
  end
  object sdCopyList: TTntSaveDialog
    DefaultExt = 'scl'
    Filter = 'SuperCopier2 Copy List (*.scl)|*.scl'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 332
    Top = 6
  end
  object sdErrorLog: TTntSaveDialog
    DefaultExt = 'txt'
    FileName = 'errorlog.txt'
    Filter = 'Text files (*.txt)|*.txt'
    Left = 364
    Top = 6
  end
end
