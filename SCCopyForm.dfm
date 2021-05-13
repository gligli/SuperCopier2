object CopyForm: TCopyForm
  Left = 288
  Top = 99
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'CopyForm'
  ClientHeight = 395
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
    395)
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
    FontProgress.Charset = DEFAULT_CHARSET
    FontProgress.Color = clWhite
    FontProgress.Height = -11
    FontProgress.Name = 'MS Sans Serif'
    FontProgress.Style = [fsBold]
    FontProgressColor = clBlack
    FontTxt.Charset = DEFAULT_CHARSET
    FontTxt.Color = clWhite
    FontTxt.Height = -11
    FontTxt.Name = 'MS Sans Serif'
    FontTxt.Style = []
    FontTxtColor = clBlack
    Max = 100
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
    FontProgress.Charset = DEFAULT_CHARSET
    FontProgress.Color = clWhite
    FontProgress.Height = -11
    FontProgress.Name = 'MS Sans Serif'
    FontProgress.Style = [fsBold]
    FontProgressColor = clBlack
    FontTxt.Charset = DEFAULT_CHARSET
    FontTxt.Color = clWhite
    FontTxt.Height = -11
    FontTxt.Name = 'MS Sans Serif'
    FontTxt.Style = []
    FontTxtColor = clBlack
    Max = 100
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
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llFrom'
  end
  object llFile: TSCFileNameLabel
    Left = 8
    Top = 72
    Width = 385
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'llFile'
  end
  object pcPages: TTntPageControl
    Left = -1
    Top = 150
    Width = 404
    Height = 249
    ActivePage = tsCopyList
    Anchors = [akLeft, akTop, akRight, akBottom]
    Images = MainForm.ilGlobal
    MultiLine = True
    TabOrder = 6
    OnChange = pcPagesChange
    object tsCopyList: TTntTabSheet
      Caption = 'Copy list'
      ImageIndex = 8
      DesignSize = (
        396
        221)
      object btFileTop: TTntSpeedButton
        Left = 0
        Top = 0
        Width = 25
        Height = 25
        Hint = 'Move files to top'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileTopClick
      end
      object btFileUp: TTntSpeedButton
        Left = 0
        Top = 28
        Width = 25
        Height = 25
        Hint = 'Move files up'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileUpClick
      end
      object btFileDown: TTntSpeedButton
        Left = 0
        Top = 56
        Width = 25
        Height = 25
        Hint = 'Move files down'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileDownClick
      end
      object btFileBottom: TTntSpeedButton
        Left = 0
        Top = 84
        Width = 25
        Height = 25
        Hint = 'Move files to bottom'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileBottomClick
      end
      object btFileAdd: TTntSpeedButton
        Left = 0
        Top = 117
        Width = 25
        Height = 25
        Hint = 'Add files'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileAddClick
      end
      object btFileRemove: TTntSpeedButton
        Left = 0
        Top = 145
        Width = 25
        Height = 25
        Hint = 'Remove files'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileRemoveClick
      end
      object btFileSave: TTntSpeedButton
        Left = 0
        Top = 178
        Width = 25
        Height = 25
        Hint = 'Save copy list'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileSaveClick
      end
      object btFileLoad: TTntSpeedButton
        Left = 0
        Top = 206
        Width = 25
        Height = 25
        Hint = 'Load copy list'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btFileLoadClick
      end
      object lvFileList: TTntListView
        Left = 25
        Top = 0
        Width = 371
        Height = 218
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
    end
    object tsErrors: TTntTabSheet
      Caption = 'Error log'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ImageIndex = 9
      ParentFont = False
      DesignSize = (
        396
        220)
      object btErrorClear: TTntSpeedButton
        Left = 0
        Top = 0
        Width = 25
        Height = 25
        Hint = 'Clear log'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btErrorClearClick
      end
      object btErrorSaveLog: TTntSpeedButton
        Left = 0
        Top = 28
        Width = 25
        Height = 25
        Hint = 'Save log'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = btErrorSaveLogClick
      end
      object lvErrorList: TTntListView
        Left = 25
        Top = 0
        Width = 371
        Height = 216
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
            Width = 75
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
    end
    object tsOptions: TTntTabSheet
      Caption = 'Options'
      ImageIndex = 4
      DesignSize = (
        396
        220)
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
          Width = 177
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
        Left = 192
        Top = 199
        Width = 196
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Set as default options'
        TabOrder = 4
        OnClick = btSaveDefaultCfgClick
      end
    end
  end
  object btCancel: TScPopupButton
    Left = 329
    Top = 116
    Width = 65
    Height = 25
    TabOrder = 5
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Cancel'
    ImageIndex = 6
    ImageList = MainForm.ilGlobal
    OnClick = btCancelClick
  end
  object btSkip: TScPopupButton
    Left = 257
    Top = 116
    Width = 65
    Height = 25
    TabOrder = 4
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Skip'
    ImageIndex = 19
    ImageList = MainForm.ilGlobal
    OnClick = btSkipClick
  end
  object btPause: TScPopupButton
    Left = 185
    Top = 116
    Width = 65
    Height = 25
    TabOrder = 2
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Pause'
    ImageIndex = 25
    ImageList = MainForm.ilGlobal
    OnClick = btPauseClick
  end
  object btResume: TScPopupButton
    Left = 185
    Top = 116
    Width = 65
    Height = 25
    Visible = False
    TabOrder = 3
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Resume'
    ImageIndex = 26
    ImageList = MainForm.ilGlobal
    OnClick = btPauseClick
  end
  object btUnfold: TScPopupButton
    Left = 113
    Top = 116
    Width = 65
    Height = 25
    TabOrder = 1
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Unfold'
    ImageIndex = 24
    ImageList = MainForm.ilGlobal
    OnClick = btUnfoldClick
  end
  object btFold: TScPopupButton
    Left = 113
    Top = 116
    Width = 65
    Height = 25
    TabOrder = 0
    TabStop = True
    Anchors = [akTop, akRight]
    ItemIndex = 0
    Caption = 'Fold up'
    ImageIndex = 23
    ImageList = MainForm.ilGlobal
    OnClick = btUnfoldClick
  end
  object pmFileContext: TTntPopupMenu
    AutoHotkeys = maManual
    Images = MainForm.ilGlobal
    TrackButton = tbLeftButton
    Left = 204
    Top = 366
    object miTop: TTntMenuItem
      Caption = 'Top'
      ImageIndex = 12
      ShortCut = 16468
      OnClick = btFileTopClick
    end
    object miUp: TTntMenuItem
      Caption = 'Up'
      ImageIndex = 10
      ShortCut = 16469
      OnClick = btFileUpClick
    end
    object miDown: TTntMenuItem
      Caption = 'Down'
      ImageIndex = 11
      ShortCut = 16452
      OnClick = btFileDownClick
    end
    object miBottom: TTntMenuItem
      Caption = 'Bottom'
      ImageIndex = 13
      ShortCut = 16450
      OnClick = btFileBottomClick
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object miRemove: TTntMenuItem
      Caption = 'Remove'
      ImageIndex = 15
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
    AutoHotkeys = maManual
    TrackButton = tbLeftButton
    Left = 236
    Top = 366
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
    Top = 366
  end
  object sdCopyList: TTntSaveDialog
    DefaultExt = 'scl'
    Filter = 'SuperCopier2 Copy List (*.scl)|*.scl'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 332
    Top = 366
  end
  object sdErrorLog: TTntSaveDialog
    DefaultExt = 'txt'
    FileName = 'errorlog.txt'
    Filter = 'Text files (*.txt)|*.txt'
    Left = 364
    Top = 366
  end
  object odFileAdd: TTntOpenDialog
    Filter = 'Any file (*.*)'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofShareAware, ofEnableSizing]
    Left = 268
    Top = 366
  end
  object pmFileAdd: TTntPopupMenu
    AutoHotkeys = maManual
    TrackButton = tbLeftButton
    Left = 172
    Top = 366
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
    Left = 107
    Top = 366
  end
  object Systray: TScSystray
    Popup = pmSystray
    Visible = False
    OnMouseDown = SystrayMouseDown
    OnBallonClick = SystrayMouseDown
    Left = 75
    Top = 366
  end
  object tiSystray: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tiSystrayTimer
    Left = 43
    Top = 366
  end
  object pmSystray: TTntPopupMenu
    AutoHotkeys = maManual
    Images = MainForm.ilGlobal
    TrackButton = tbLeftButton
    Left = 140
    Top = 366
    object miStResume: TTntMenuItem
      Caption = 'Resume'
      ImageIndex = 26
      Visible = False
      OnClick = miStPauseClick
    end
    object miStPause: TTntMenuItem
      Caption = 'Pause'
      ImageIndex = 25
      OnClick = miStPauseClick
    end
    object miStCancel: TTntMenuItem
      Caption = 'Cancel'
      ImageIndex = 6
      OnClick = miStCancelClick
    end
  end
end
