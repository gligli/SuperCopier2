object CopyForm: TCopyForm
  Left = 236
  Top = 106
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'CopyForm'
  ClientHeight = 405
  ClientWidth = 400
  Color = clBtnFace
  Constraints.MinHeight = 169
  Constraints.MinWidth = 408
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    400
    405)
  PixelsPerInch = 96
  TextHeight = 13
  object ggAll: TSCProgessBar
    Left = 8
    Top = 48
    Width = 385
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BorderColor = clBlack
    FrontColor1 = clRed
    FrontColor2 = clBlue
    BackColor1 = clGray
    BackColor2 = clWhite
    Max = 100
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
    Top = 120
    Width = 97
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llSpeed'
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
  object ggFile: TSCProgessBar
    Left = 8
    Top = 88
    Width = 385
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BorderColor = clBlack
    FrontColor1 = clRed
    FrontColor2 = clBlue
    BackColor1 = clGray
    BackColor2 = clWhite
    Max = 100
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
  object llTo: TSCFileNameLabel
    Left = 40
    Top = 16
    Width = 353
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llTo'
  end
  object llFrom: TSCFileNameLabel
    Left = 40
    Top = 0
    Width = 353
    Height = 13
    AutoSize = False
    Caption = 'llFrom'
  end
  object btCancel: TTntButton
    Left = 330
    Top = 116
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btCancel'
    TabOrder = 0
    OnClick = btCancelClick
  end
  object btSkip: TTntButton
    Left = 258
    Top = 116
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btSkip'
    TabOrder = 1
    OnClick = btSkipClick
  end
  object btPause: TTntButton
    Left = 186
    Top = 116
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btPause'
    TabOrder = 2
    OnClick = btPauseClick
  end
  object pcPages: TTntPageControl
    Left = -1
    Top = 150
    Width = 404
    Height = 259
    ActivePage = tsCopyList
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 3
    OnChange = pcPagesChange
    object tsCopyList: TTntTabSheet
      Caption = 'Copy list'
      DesignSize = (
        396
        231)
      object lvFileList: TTntListView
        Left = 25
        Top = 0
        Width = 371
        Height = 230
        Anchors = [akLeft, akTop, akRight, akBottom]
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
        TabOrder = 0
        ViewStyle = vsReport
        OnData = lvFileListData
      end
      object btFileTop: TTntButton
        Left = 0
        Top = 0
        Width = 25
        Height = 25
        Caption = 'T'
        TabOrder = 1
        TabStop = False
        OnClick = btFileTopClick
      end
      object btFileUp: TTntButton
        Left = 0
        Top = 28
        Width = 25
        Height = 25
        Caption = 'U'
        TabOrder = 2
        TabStop = False
        OnClick = btFileUpClick
      end
      object btFileBottom: TTntButton
        Left = 0
        Top = 84
        Width = 25
        Height = 25
        Caption = 'B'
        TabOrder = 3
        TabStop = False
        OnClick = btFileBottomClick
      end
      object btFileDown: TTntButton
        Left = 0
        Top = 56
        Width = 25
        Height = 25
        Caption = 'D'
        TabOrder = 4
        TabStop = False
        OnClick = btFileDownClick
      end
      object btFileAdd: TTntButton
        Left = 0
        Top = 116
        Width = 25
        Height = 24
        Caption = 'A'
        TabOrder = 5
        TabStop = False
        OnClick = btFileAddClick
      end
      object btFileRemove: TTntButton
        Left = 0
        Top = 144
        Width = 25
        Height = 25
        Caption = 'R'
        TabOrder = 6
        TabStop = False
        OnClick = btFileRemoveClick
      end
      object btFileSave: TTntButton
        Left = 0
        Top = 177
        Width = 25
        Height = 25
        Caption = 'S'
        TabOrder = 7
        TabStop = False
        OnClick = btFileSaveClick
      end
      object btFileLoad: TTntButton
        Left = 0
        Top = 206
        Width = 25
        Height = 25
        Caption = 'L'
        TabOrder = 8
        TabStop = False
        OnClick = btFileLoadClick
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
      DesignSize = (
        396
        231)
      object lvErrorList: TTntListView
        Left = 25
        Top = 0
        Width = 371
        Height = 230
        Anchors = [akLeft, akTop, akRight, akBottom]
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
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        TabOrder = 0
        ViewStyle = vsReport
        OnData = lvFileListData
      end
      object btErrorClear: TTntButton
        Left = 0
        Top = 0
        Width = 25
        Height = 25
        Caption = 'C'
        TabOrder = 1
        TabStop = False
        OnClick = btErrorClearClick
      end
      object btErrorSaveLog: TTntButton
        Left = 0
        Top = 28
        Width = 25
        Height = 25
        Caption = 'S'
        TabOrder = 2
        TabStop = False
        OnClick = btErrorSaveLogClick
      end
    end
    object tsOptions: TTntTabSheet
      Caption = 'Options'
      DesignSize = (
        396
        231)
      object gbSpeedLimit: TTntGroupBox
        Left = 8
        Top = 51
        Width = 381
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
          DropDownCount = 20
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
        Top = 99
        Width = 381
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
          381
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
          Width = 189
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
        Top = 147
        Width = 381
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
          381
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
          Width = 189
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
      object gbCopyEnd: TTntGroupBox
        Left = 8
        Top = 3
        Width = 381
        Height = 44
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Copy end'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        DesignSize = (
          381
          44)
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
          Width = 189
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
      object btSaveDefaultCfg: TTntButton
        Left = 272
        Top = 199
        Width = 116
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'btSaveDefaultCfg'
        TabOrder = 4
        OnClick = btSaveDefaultCfgClick
      end
    end
  end
  object btUnfold: TTntButton
    Left = 114
    Top = 116
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'btUnfold'
    TabOrder = 4
    OnClick = btUnfoldClick
  end
  object TntButton1: TTntButton
    Left = 88
    Top = 112
    Width = 17
    Height = 25
    Caption = 'TntButton1'
    TabOrder = 5
    OnClick = btTitleBarClick
  end
  object pmFileContext: TTntPopupMenu
    Left = 204
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
  object pmNewFiles: TTntPopupMenu
    Left = 236
    Top = 6
    object miDefaultDest: TTntMenuItem
      Caption = 'Use default destination folder ()'
      Default = True
      OnClick = miDefaultDestClick
    end
    object miChooseDest: TTntMenuItem
      Caption = 'Choose destination folder...'
      OnClick = miChooseDestClick
    end
    object miChooseSetDefault: TTntMenuItem
      Caption = 'Choose destination folder and set it as default...'
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
  object odFileAdd: TTntOpenDialog
    Filter = 'Any file (*.*)'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofShareAware, ofEnableSizing]
    Left = 268
    Top = 6
  end
  object pmFileAdd: TTntPopupMenu
    Left = 172
    Top = 6
    object miAddFiles: TTntMenuItem
      Caption = 'Add files...'
      OnClick = miAddFilesClick
    end
    object miAddFolder: TTntMenuItem
      Caption = 'Add folder...'
      OnClick = miAddFolderClick
    end
  end
  object btTitleBar: TSCTitleBarBt
    OnClick = btTitleBarClick
    Left = 139
    Top = 6
  end
  object Systray: TScSystray
    Visible = False
    OnMouseDown = SystrayMouseDown
    Left = 107
    Top = 6
  end
  object tiSystray: TTimer
    Interval = 500
    OnTimer = tiSystrayTimer
    Left = 75
    Top = 6
  end
end
