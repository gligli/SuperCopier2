object ConfigForm: TConfigForm
  Left = 244
  Top = 105
  BorderStyle = bsDialog
  Caption = 'Configuration'
  ClientHeight = 394
  ClientWidth = 607
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = TntFormShow
  DesignSize = (
    607
    394)
  PixelsPerInch = 96
  TextHeight = 13
  object lvSections: TTntListView
    Left = 0
    Top = 0
    Width = 161
    Height = 367
    BevelInner = bvNone
    BevelOuter = bvNone
    Columns = <
      item
        AutoSize = True
      end>
    HideSelection = False
    Items.Data = {
      1D0100000800000000000000FFFFFFFFFFFFFFFF0000000000000000084C616E
      677561676500000000FFFFFFFFFFFFFFFF000000000000000007537461727475
      7000000000FFFFFFFFFFFFFFFF00000000000000000E5573657220696E746572
      6661636500000000FFFFFFFFFFFFFFFF000000000000000017436F7069657320
      26206D6F7665732064656661756C747300000000FFFFFFFFFFFFFFFF00000000
      0000000017436F706965732026206D6F766573206265686176696F7200000000
      FFFFFFFFFFFFFFFF0000000000000000094572726F72206C6F6700000000FFFF
      FFFFFFFFFFFF00000000000000001148616E646C65642070726F636573736573
      00000000FFFFFFFFFFFFFFFF000000000000000008416476616E636564}
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvSectionsChange
  end
  object pcSections: TTntPageControl
    Left = 160
    Top = 0
    Width = 447
    Height = 369
    ActivePage = tsProcesses
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabHeight = 10
    TabOrder = 1
    TabPosition = tpBottom
    object tsLanguage: TTntTabSheet
      Caption = 'tsLanguage'
      TabVisible = False
      object gbLanguage: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 62
        Caption = 'Language'
        TabOrder = 0
        object llLanguage: TTntLabel
          Left = 8
          Top = 18
          Width = 92
          Height = 13
          Caption = 'Interface language:'
        end
        object llLanguageInfo: TTntLabel
          Left = 8
          Top = 40
          Width = 299
          Height = 13
          Caption = 
            '(English (default) won'#39't be applied until you restart SuperCopie' +
            'r.)'
        end
        object cbLanguage: TTntComboBox
          Left = 216
          Top = 13
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
        end
      end
    end
    object tsStartup: TTntTabSheet
      Caption = 'tsStartup'
      TabVisible = False
      object gbStartup: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 67
        Caption = 'Startup'
        TabOrder = 0
        object chStartWithWindows: TTntCheckBox
          Left = 8
          Top = 17
          Width = 393
          Height = 17
          Caption = 'Start when windows starts'
          TabOrder = 0
        end
        object chActivateOnStart: TTntCheckBox
          Left = 8
          Top = 41
          Width = 393
          Height = 17
          Caption = 'Activate SuperCopier when it starts'
          TabOrder = 1
        end
      end
    end
    object tsUI: TTntTabSheet
      Caption = 'tsUI'
      TabVisible = False
      object gbTaskbar: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 112
        Caption = 'Taskbar && system tray'
        TabOrder = 0
        object llMinimizedEventHandling: TTntLabel
          Left = 9
          Top = 63
          Width = 250
          Height = 13
          Caption = 'When there is an event and the window is minimized:'
        end
        object chTrayIcon: TTntCheckBox
          Left = 8
          Top = 17
          Width = 363
          Height = 17
          Caption = 'Show SuperCopier icon in system tray'
          TabOrder = 0
        end
        object cbMinimize: TTntComboBox
          Left = 8
          Top = 38
          Width = 409
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnClick = cbMinimizeClick
          Items.Strings = (
            'Minimize windows to system tray and set them as always on top'
            'Minimize windows to taskbar')
        end
        object cbMinimizedEventHandling: TTntComboBox
          Left = 8
          Top = 82
          Width = 409
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'Do nothing (wait for the window to be restored)'
            
              'Display a balloon notification (will not work on Windows 98,95 &' +
              ' NT4)'
            'Popup the event window')
        end
      end
      object gbCWAppearance: TTntGroupBox
        Left = 8
        Top = 119
        Width = 425
        Height = 90
        Caption = 'Copy window appearance'
        TabOrder = 1
        object chCWSavePosition: TTntCheckBox
          Left = 8
          Top = 40
          Width = 401
          Height = 17
          Caption = 'Save copy window position'
          TabOrder = 1
        end
        object chCWSaveSize: TTntCheckBox
          Left = 8
          Top = 64
          Width = 401
          Height = 17
          Caption = 'Save copy window size'
          TabOrder = 2
        end
        object chCWStartMinimized: TTntCheckBox
          Left = 8
          Top = 16
          Width = 401
          Height = 17
          Caption = 'Start copies with copy window minimized'
          TabOrder = 0
        end
      end
      object gbSizeUnit: TTntGroupBox
        Left = 8
        Top = 213
        Width = 425
        Height = 45
        Caption = 'Size unit'
        TabOrder = 2
        object llSizeUnit: TTntLabel
          Left = 8
          Top = 18
          Width = 145
          Height = 13
          Caption = 'Use this unit to display file size:'
        end
        object cbSizeUnit: TTntComboBox
          Left = 216
          Top = 14
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Auto'
            'Bytes'
            'KB (Kilobytes)'
            'MB (Megabytes)'
            'GB (Gigabytes)')
        end
      end
      object gbProgressrar: TTntGroupBox
        Left = 8
        Top = 262
        Width = 426
        Height = 96
        Caption = 'Progress bars'
        TabOrder = 3
        object llProgressFG: TTntLabel
          Left = 6
          Top = 16
          Width = 88
          Height = 13
          Caption = 'Foreground colors:'
        end
        object llProgressBG: TTntLabel
          Left = 116
          Top = 16
          Width = 92
          Height = 13
          Caption = 'Background colors:'
        end
        object llProgressBorder: TTntLabel
          Left = 338
          Top = 16
          Width = 60
          Height = 13
          Caption = 'Border color:'
        end
        object ggProgress: TSCProgessBar
          Left = 6
          Top = 72
          Width = 411
          Height = 17
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
          Position = 50
          TimeRemaining = '00:00:00 Remaining'
        end
        object llProgressText: TTntLabel
          Left = 227
          Top = 16
          Width = 55
          Height = 13
          Caption = 'Text colors:'
        end
        object btProgressFG1: TTntButton
          Left = 6
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Edges'
          TabOrder = 0
          OnClick = btProgressFG1Click
        end
        object bgProgressFG2: TTntButton
          Left = 54
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Middle'
          TabOrder = 1
          OnClick = bgProgressFG2Click
        end
        object btProgressBG1: TTntButton
          Left = 116
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Edges'
          TabOrder = 2
          OnClick = btProgressBG1Click
        end
        object btProgressBG2: TTntButton
          Left = 164
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Middle'
          TabOrder = 3
          OnClick = btProgressBG2Click
        end
        object btProgressBorder: TTntButton
          Left = 338
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Border'
          TabOrder = 6
          OnClick = btProgressBorderClick
        end
        object btProgressOutline: TTntButton
          Left = 275
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Outline'
          TabOrder = 5
          OnClick = btProgressOutlineClick
        end
        object btProgressText: TTntButton
          Left = 227
          Top = 34
          Width = 48
          Height = 25
          Caption = 'Text'
          TabOrder = 4
          OnClick = btProgressTextClick
        end
      end
    end
    object tsCWDefaults: TTntTabSheet
      Caption = 'tsCWDefaults'
      TabVisible = False
      object gbCopyEnd: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 44
        Caption = 'Copy end'
        TabOrder = 0
        object llCopyEnd: TTntLabel
          Left = 8
          Top = 18
          Width = 108
          Height = 13
          Caption = 'At the end of the copy:'
        end
        object cbCopyEnd: TTntComboBox
          Left = 216
          Top = 13
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Close the window'
          Items.Strings = (
            'Close the window'
            'Don'#39't close the window'
            'Don'#39't close if there was errors')
        end
      end
      object gbSpeedLimit: TTntGroupBox
        Left = 8
        Top = 51
        Width = 425
        Height = 44
        Caption = 'Speed limit'
        TabOrder = 1
        object llCustomSpeedLimit: TTntLabel
          Left = 397
          Top = 17
          Width = 14
          Height = 13
          Caption = 'KB'
          Enabled = False
        end
        object llSpeedLimit: TTntLabel
          Left = 338
          Top = 17
          Width = 73
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'llSpeedLimit'
          Enabled = False
          Visible = False
        end
        object chSpeedLimit: TTntCheckBox
          Left = 8
          Top = 16
          Width = 73
          Height = 17
          Caption = 'Enabled'
          TabOrder = 0
          OnClick = chSpeedLimitClick
        end
        object tbSpeedLimit: TScTrackBar
          Left = 80
          Top = 13
          Width = 249
          Height = 23
          Enabled = False
          Max = 52
          TabOrder = 1
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = tbSpeedLimitChange
        end
        object edCustomSpeedLimit: TTntEdit
          Left = 336
          Top = 14
          Width = 57
          Height = 21
          Enabled = False
          TabOrder = 2
          Text = 'edCustomSpeedLimit'
          OnKeyPress = NumbersOnly
        end
      end
      object gbCollisions: TTntGroupBox
        Left = 8
        Top = 99
        Width = 425
        Height = 44
        Caption = 'File collisions'
        TabOrder = 2
        object llCollisions: TTntLabel
          Left = 8
          Top = 18
          Width = 161
          Height = 13
          Caption = 'When a file already exists, always:'
        end
        object cbCollisions: TTntComboBox
          Left = 216
          Top = 14
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Ask what to do'
          Items.Strings = (
            'Ask what to do'
            'Cancel the whole copy'
            'Skip'
            'Resume transfer'
            'Overwrite'
            'Overwrite if different'
            'Rename new file'
            'Rename old file')
        end
      end
      object gbCopyErrors: TTntGroupBox
        Left = 8
        Top = 147
        Width = 425
        Height = 72
        Caption = 'Copy errors'
        TabOrder = 3
        object llCopyErrors: TTntLabel
          Left = 8
          Top = 18
          Width = 166
          Height = 13
          Caption = 'When there is a copy error, always:'
        end
        object llRetryInterval: TTntLabel
          Left = 8
          Top = 46
          Width = 155
          Height = 13
          Caption = 'Time to wait between two retries:'
        end
        object llRetryIntervalUnit: TTntLabel
          Left = 304
          Top = 46
          Width = 57
          Height = 13
          Caption = 'Milliseconds'
        end
        object cbCopyError: TTntComboBox
          Left = 216
          Top = 14
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Ask what to do'
          Items.Strings = (
            'Ask what to do'
            'Cancel then whole copy'
            'Skip'
            'Retry'
            'Put the file at the copy list bottom')
        end
        object edCopyErrorRetry: TTntEdit
          Left = 216
          Top = 42
          Width = 81
          Height = 21
          TabOrder = 1
        end
      end
    end
    object tsCopy: TTntTabSheet
      Caption = 'tsCopy'
      TabVisible = False
      object gbCLHandling: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 106
        Caption = 'New copy list handling'
        TabOrder = 0
        object llCLHandling: TTntLabel
          Left = 8
          Top = 18
          Width = 237
          Height = 13
          Caption = 'Add new copy lists to allready copying ones when:'
        end
        object llCLHandlingInfo: TTntLabel
          Left = 8
          Top = 64
          Width = 258
          Height = 13
          Caption = '(same source means, for example, same physical drive)'
        end
        object cbCLHandling: TTntComboBox
          Left = 8
          Top = 37
          Width = 409
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Never'
            'Always'
            'The source is the same'
            'The destination is the same'
            'The source and the destination are the same'
            'The source or the destination are the same')
        end
        object chCLHandlingConfirm: TTntCheckBox
          Left = 8
          Top = 81
          Width = 363
          Height = 17
          Caption = 'Ask for confirmation before adding'
          TabOrder = 1
        end
      end
      object gbAttributes: TTntGroupBox
        Left = 8
        Top = 113
        Width = 425
        Height = 67
        Caption = 'Attributes && security'
        TabOrder = 1
        object llAttributesAndSecurityForCopies: TTntLabel
          Left = 8
          Top = 18
          Width = 172
          Height = 13
          Caption = 'When a file or folder is copied, copy:'
        end
        object llAttributesAndSecurityForMoves: TTntLabel
          Left = 8
          Top = 42
          Width = 172
          Height = 13
          Caption = 'When a file or folder is moved, copy:'
        end
        object chSaveAttributesOnCopy: TTntCheckBox
          Left = 200
          Top = 17
          Width = 105
          Height = 17
          Caption = 'Attributes'
          TabOrder = 0
        end
        object chSaveAttributesOnMove: TTntCheckBox
          Left = 200
          Top = 41
          Width = 105
          Height = 17
          Caption = 'Attributes'
          TabOrder = 2
        end
        object chSaveSecurityOnCopy: TTntCheckBox
          Left = 312
          Top = 17
          Width = 105
          Height = 17
          Caption = 'Security'
          TabOrder = 1
        end
        object chSaveSecurityOnMove: TTntCheckBox
          Left = 312
          Top = 41
          Width = 105
          Height = 17
          Caption = 'Security'
          TabOrder = 3
        end
      end
      object gbDeleting: TTntGroupBox
        Left = 8
        Top = 184
        Width = 425
        Height = 67
        Caption = 'Deleting'
        TabOrder = 2
        object chDeleteUnfinishedCopies: TTntCheckBox
          Left = 8
          Top = 17
          Width = 363
          Height = 17
          Caption = 'Delete files when they are not entirely copied'
          TabOrder = 0
          OnClick = chDeleteUnfinishedCopiesClick
        end
        object chDontDeleteOnCopyError: TTntCheckBox
          Left = 32
          Top = 41
          Width = 340
          Height = 17
          Caption = 'Don'#39't delete them if it was caused by a copy error'
          TabOrder = 1
        end
      end
      object gbRenaming: TTntGroupBox
        Left = 8
        Top = 255
        Width = 425
        Height = 82
        Caption = 'Renaming'
        TabOrder = 4
        object llRenameOld: TTntLabel
          Left = 8
          Top = 26
          Width = 117
          Height = 13
          Caption = 'Old file renaming pattern:'
        end
        object llRenameNew: TTntLabel
          Left = 8
          Top = 54
          Width = 123
          Height = 13
          Caption = 'New file renaming pattern:'
        end
        object edRenameOldPattern: TTntEdit
          Left = 216
          Top = 22
          Width = 201
          Height = 21
          TabOrder = 0
        end
        object edRenameNewPattern: TTntEdit
          Left = 216
          Top = 50
          Width = 201
          Height = 21
          TabOrder = 1
        end
      end
      object btRenamingHelp: TTntButton
        Left = 357
        Top = 254
        Width = 75
        Height = 16
        Caption = 'Help'
        TabOrder = 3
        OnClick = btRenamingHelpClick
      end
    end
    object tsLog: TTntTabSheet
      Caption = 'tsLog'
      TabVisible = False
      object gbErrorLog: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 94
        Caption = 'Error log'
        TabOrder = 0
        object llErrorLogAutoSaveMode: TTntLabel
          Left = 32
          Top = 42
          Width = 48
          Height = 13
          Caption = 'Save it to:'
        end
        object llErrorLogFileName: TTntLabel
          Left = 32
          Top = 68
          Width = 135
          Height = 13
          Caption = 'Filename (and maybe folder):'
        end
        object cbErrorLogAutoSaveMode: TTntComboBox
          Left = 216
          Top = 37
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbErrorLogAutoSaveModeChange
          Items.Strings = (
            'The destination folder'
            'The source folder'
            'A custom folder')
        end
        object chErrorLogAutoSave: TTntCheckBox
          Left = 8
          Top = 17
          Width = 363
          Height = 17
          Caption = 'Automatically save the error log'
          TabOrder = 1
          OnClick = chErrorLogAutoSaveClick
        end
        object edErrorLogFileName: TTntEdit
          Left = 216
          Top = 64
          Width = 169
          Height = 21
          TabOrder = 2
          OnKeyPress = FileNameOnly
        end
        object btELFNBrowse: TTntButton
          Left = 392
          Top = 64
          Width = 26
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btELFNBrowseClick
        end
      end
    end
    object tsProcesses: TTntTabSheet
      Caption = 'tsProcesses'
      TabVisible = False
      DesignSize = (
        439
        361)
      object gbHandledProcesses: TTntGroupBox
        Left = 8
        Top = 3
        Width = 423
        Height = 214
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Handled processes'
        TabOrder = 0
        Visible = False
        object llHandledProcessses: TTntLabel
          Left = 8
          Top = 18
          Width = 298
          Height = 13
          Caption = 
            'List of processes (shells or other) that SuperCopier must handle' +
            ':'
        end
        object lvHandledProcesses: TTntListView
          Left = 8
          Top = 40
          Width = 329
          Height = 165
          BevelInner = bvNone
          BevelOuter = bvNone
          Columns = <
            item
              AutoSize = True
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          ShowColumnHeaders = False
          TabOrder = 0
          ViewStyle = vsReport
        end
        object btAddProcess: TTntButton
          Left = 346
          Top = 40
          Width = 71
          Height = 25
          Caption = 'Add'
          TabOrder = 1
          OnClick = btAddProcessClick
        end
        object btRemoveProcess: TTntButton
          Left = 346
          Top = 72
          Width = 71
          Height = 25
          Caption = 'Remove'
          TabOrder = 2
          OnClick = btRemoveProcessClick
        end
      end
    end
    object tsAdvanced: TTntTabSheet
      Caption = 'tsAdvanced'
      TabVisible = False
      object gbPriority: TTntGroupBox
        Left = 8
        Top = 3
        Width = 425
        Height = 44
        Caption = 'Priority'
        TabOrder = 0
        object llPriority: TTntLabel
          Left = 8
          Top = 18
          Width = 134
          Height = 13
          Caption = 'SuperCopier process priority:'
        end
        object cbPriority: TTntComboBox
          Left = 216
          Top = 13
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Idle'
            'Normal'
            'High')
        end
      end
      object gbAdvanced: TTntGroupBox
        Left = 8
        Top = 99
        Width = 425
        Height = 198
        Caption = 'Advanced parameters'
        TabOrder = 3
        object llCopyBufferSize: TTntLabel
          Left = 8
          Top = 18
          Width = 78
          Height = 13
          Caption = 'Copy buffer size:'
        end
        object llCopyBufferSizeUnit: TTntLabel
          Left = 304
          Top = 18
          Width = 26
          Height = 13
          Caption = 'Bytes'
        end
        object llCopyWindowUpdateInterval: TTntLabel
          Left = 8
          Top = 47
          Width = 139
          Height = 13
          Caption = 'Copy window update interval:'
        end
        object llCopyWindowUpdateIntervalUnit: TTntLabel
          Left = 304
          Top = 47
          Width = 57
          Height = 13
          Caption = 'Milliseconds'
        end
        object llCopySpeedAveragingInterval: TTntLabel
          Left = 8
          Top = 76
          Width = 146
          Height = 13
          Caption = 'Copy speed averaging interval:'
        end
        object llCopySpeedAveragingIntervalUnit: TTntLabel
          Left = 304
          Top = 76
          Width = 57
          Height = 13
          Caption = 'Milliseconds'
        end
        object llCopyThrottleInterval: TTntLabel
          Left = 8
          Top = 105
          Width = 99
          Height = 13
          Caption = 'Copy throttle interval:'
        end
        object llCopyThrottleIntervalUnit: TTntLabel
          Left = 304
          Top = 105
          Width = 57
          Height = 13
          Caption = 'Milliseconds'
        end
        object edCopyBufferSize: TTntEdit
          Left = 216
          Top = 14
          Width = 81
          Height = 21
          TabOrder = 0
          OnKeyPress = NumbersOnly
        end
        object edCopyWindowUpdateInterval: TTntEdit
          Left = 216
          Top = 43
          Width = 81
          Height = 21
          TabOrder = 1
          OnKeyPress = NumbersOnly
        end
        object edCopySpeedAveragingInterval: TTntEdit
          Left = 216
          Top = 72
          Width = 81
          Height = 21
          TabOrder = 2
          OnKeyPress = NumbersOnly
        end
        object edCopyThrottleInterval: TTntEdit
          Left = 216
          Top = 101
          Width = 81
          Height = 21
          TabOrder = 3
          OnKeyPress = NumbersOnly
        end
        object chFastFreeSpaceCheck: TTntCheckBox
          Left = 8
          Top = 132
          Width = 415
          Height = 17
          Caption = 'Fast free space check (can have problems with NTFS mount points)'
          TabOrder = 4
        end
        object chFailSafeCopier: TTntCheckBox
          Left = 8
          Top = 152
          Width = 409
          Height = 17
          Caption = 'Use a failsafe copier (buffered copy and no unicode support)'
          TabOrder = 5
        end
        object chCopyResumeNoAgeVerification: TTntCheckBox
          Left = 8
          Top = 172
          Width = 413
          Height = 17
          Caption = 'Do not check for same file age before resuming file transfer'
          TabOrder = 6
        end
      end
      object gbConfigLocation: TTntGroupBox
        Left = 8
        Top = 51
        Width = 425
        Height = 44
        Caption = 'Settings location'
        TabOrder = 1
        object llConfigLocation: TTntLabel
          Left = 8
          Top = 18
          Width = 79
          Height = 13
          Caption = 'Store settings to:'
        end
        object cbConfigLocation: TTntComboBox
          Left = 216
          Top = 13
          Width = 201
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'The registry'
            '.ini file')
        end
      end
      object btAdvancedHelp: TTntButton
        Left = 357
        Top = 97
        Width = 75
        Height = 16
        Caption = 'Help'
        TabOrder = 2
        OnClick = btAdvancedHelpClick
      end
    end
  end
  object btCancel: TTntButton
    Left = 446
    Top = 368
    Width = 76
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btOk: TTntButton
    Left = 362
    Top = 368
    Width = 76
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = btOkClick
  end
  object btApply: TTntButton
    Left = 530
    Top = 368
    Width = 76
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 4
    OnClick = btApplyClick
  end
  object odLog: TTntOpenDialog
    DefaultExt = 'txt'
    Filter = 'Any file (*.*)'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Top = 368
  end
  object odProcesses: TTntOpenDialog
    DefaultExt = 'exe'
    Filter = 'Process (*.exe)|*.exe'
    Left = 32
    Top = 368
  end
  object cdProgress: TColorDialog
    Options = [cdFullOpen, cdAnyColor]
    Left = 64
    Top = 368
  end
end
