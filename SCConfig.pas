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

unit SCConfig;

interface
uses Registry,IniFiles,SCCommon,Graphics,Windows;

type
  // /!\ a chaque modification de cette structure, modifier en concéquence
  //     CONFIG_DEFAULT_VALUES, TConfig.SaveConfig et TConfig.LoadConfig
  TSCConfigValues=record
    CopyBufferSize:Integer;
    CopyWindowUpdateInterval:Integer;
    CopySpeedAveragingInterval:Integer;
    CopyThrottleInterval:Integer;
    CopyErrorRetryInterval:Integer;
    HandledProcesses:String;
    RenameNewPattern:String;
    RenameOldPattern:String;
    DefaultCopyWindowConfig:TCopyWindowConfigData;
    ErrorLogAutoSave:Boolean;
    ErrorLogAutoSaveMode:TErrorLogAutoSaveMode;
    ErrorLogFileName:String;
    FastFreeSpaceCheck:Boolean;
    CopyListHandlingMode:TCopyListHandlingMode;
    CopyListHandlingConfirm:Boolean;
    SaveAttributesOnCopy:Boolean;
    SaveAttributesOnMove:Boolean;
    SizeUnit:TSizeUnit;
    DeleteUnfinishedCopies:Boolean;
    DontDeleteOnCopyError:Boolean;
    CopyWindowSavePosition:Boolean;
    CopyWindowSaveSize:Boolean;
    CopyWindowTop:Integer;
    CopyWindowLeft:Integer;
    CopyWindowWidth:Integer;
    CopyWindowHeight:Integer;
    CopyWindowUnfolded:Boolean;
    StartWithWindows:Boolean;
    ActivateOnStart:Boolean;
    TrayIcon:Boolean;
    MinimizeToTray:Boolean;
    CopyWindowStartMinimized:Boolean;
    Priority:Integer;
    ProgressForegroundColor1:TColor;
    ProgressForegroundColor2:TColor;
    ProgressBackgroundColor1:TColor;
    ProgressBackgroundColor2:TColor;
    ProgressBorderColor:TColor;
    ProgressTextColor:TColor;
    ProgressOutlineColor:TColor;
    MinimizedEventHandling:TMinimizedEventHandling;
    FailSafeCopier:Boolean;
    Language:WideString;
    CopyResumeNoAgeVerification:Boolean;
    SaveSecurityOnCopy:Boolean;
    SaveSecurityOnMove:Boolean;
  end;

  TConfig=class
  protected
    function ReadInteger(Name:string):Integer;virtual;abstract;
    function ReadBoolean(Name:string):Boolean;virtual;abstract;
    function ReadFloat(Name:string):Double;virtual;abstract;
    function ReadString(Name:string):String;virtual;abstract;

    procedure WriteInteger(Name:String;Value:Integer);virtual;abstract;
    procedure WriteBoolean(Name:String;Value:Boolean);virtual;abstract;
    procedure WriteFloat(Name:String;Value:Double);virtual;abstract;
    procedure WriteString(Name:String;Value:String);virtual;abstract;
  public
    Values:TSCConfigValues;

    procedure LoadDefaultConfig;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure DeleteData;virtual;abstract;

    constructor Create;
  end;

  TRegistryConfig=class(TConfig)
  private
    Reg:TRegistry;
    FKey:String;
  protected
    function ReadInteger(Name:string):Integer;override;
    function ReadBoolean(Name:string):Boolean;override;
    function ReadFloat(Name:string):Double;override;
    function ReadString(Name:string):String;override;

    procedure WriteInteger(Name:String;Value:Integer);override;
    procedure WriteBoolean(Name:String;Value:Boolean);override;
    procedure WriteFloat(Name:String;Value:Double);override;
    procedure WriteString(Name:String;Value:String);override;
  public
    constructor Create(Key:String);
    destructor Destroy;override;

    procedure DeleteData;override;
  end;

  TIniConfig=class(TConfig)
  private
    Ini:TMemIniFile;
    Section:String;
    FFilename:WideString;

    procedure VerifyValueExists(Name:String);
  protected
    function ReadInteger(Name:string):Integer;override;
    function ReadBoolean(Name:string):Boolean;override;
    function ReadFloat(Name:string):Double;override;
    function ReadString(Name:string):String;override;

    procedure WriteInteger(Name:String;Value:Integer);override;
    procedure WriteBoolean(Name:String;Value:Boolean);override;
    procedure WriteFloat(Name:String;Value:Double);override;
    procedure WriteString(Name:String;Value:String);override;
  public
    constructor Create(FileName:WideString);
    destructor Destroy;override;

    procedure DeleteData;override;
  end;

const
  // valeurs de config par défaut
  CONFIG_DEFAULT_VALUES:TSCConfigValues=(
    CopyBufferSize:65536;
    CopyWindowUpdateInterval:100;
    CopySpeedAveragingInterval:5000;
    CopyThrottleInterval:1000;
    CopyErrorRetryInterval:2000;
    HandledProcesses:'explorer.exe';
    RenameNewPattern:'<name>_New<#>.<ext>';
    RenameOldPattern:'<name>_Old<#>.<ext>';
    DefaultCopyWindowConfig:(
      CopyEndAction:cweDontCloseIfErrors;
      ThrottleEnabled:False;
      ThrottleSpeedLimit:1024;
      CollisionAction:claNone;
      CopyErrorAction:ceaNone;
    );
    ErrorLogAutoSave:False;
    ErrorLogAutoSaveMode:eamToDestDir;
    ErrorLogFileName:'errorlog.txt';
    FastFreeSpaceCheck:True;
    CopyListHandlingMode:chmNever;
    CopyListHandlingConfirm:True;
    SaveAttributesOnCopy:False;
    SaveAttributesOnMove:True;
    SizeUnit:suAuto;
    DeleteUnfinishedCopies:True;
    DontDeleteOnCopyError:True;
    CopyWindowSavePosition:False;
    CopyWindowSaveSize:False;
    CopyWindowTop:0;
    CopyWindowLeft:0;
    CopyWindowWidth:408;
    CopyWindowHeight:177;
    CopyWindowUnfolded:False;
    StartWithWindows:True;
    ActivateOnStart:True;
    TrayIcon:True;
    MinimizeToTray:True;
    CopyWindowStartMinimized:False;
    Priority:NORMAL_PRIORITY_CLASS;
    ProgressForegroundColor1:clNavy;
    ProgressForegroundColor2:clCream;
    ProgressBackgroundColor1:clGray;
    ProgressBackgroundColor2:clWhite;
    ProgressBorderColor:clBlack;
    ProgressTextColor:clWhite;
    ProgressOutlineColor:clBlack;
    MinimizedEventHandling:mehShowBalloon;
    FailSafeCopier:False;
    Language:'';
    CopyResumeNoAgeVerification:False;
    SaveSecurityOnCopy:False;
    SaveSecurityOnMove:False;
  );

  CONFIG_REGISTRY_KEY='Software\SFX TEAM\SuperCopier2';
  AUTORUN_REGISTRY_KEY='\Software\Microsoft\Windows\CurrentVersion\Run';
var
  Config:TConfig;
  ConfigLocation:TConfigLocation;

procedure OpenConfig;
procedure CloseConfig;
procedure ApplyConfig;

implementation
uses SysUtils, StrUtils,TntForms,TntSysutils,SCWin32,SCMainForm,SCLocEngine,SCLocStrings,SCConfigForm,SCAboutForm;

//******************************************************************************
// OpenConfig: crée l'objet de configuration et charge la config
//******************************************************************************
procedure OpenConfig;
var IniFileName:WideString;
    Reg:TRegistry;
begin
  IniFileName:=ChangeFileExt(TntApplication.ExeName,'.ini');

  if WideFileExists(IniFileName) then
  begin
    ConfigLocation:=clIniFile;
    Config:=TIniConfig.Create(IniFileName);
  end
  else
  begin
    ConfigLocation:=clRegistry;
    Config:=TRegistryConfig.Create(CONFIG_REGISTRY_KEY);
  end;

  Config.LoadConfig;

	//lecture de l'état de l'autorun
  Reg:=TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(AUTORUN_REGISTRY_KEY, True) then
      Config.Values.StartWithWindows:=Reg.ValueExists(WideExtractFileName(TntApplication.ExeName));
  finally
    Reg.CloseKey;
    Reg.Free;
  end;

  // langage
  if Config.Values.Language='' then Config.Values.Language:=GetOSLanguageName;
  if Config.Values.Language<>DEFAULT_LANGUAGE then
  begin
    LocEngine.LoadLanguageFile(WideExtractFilePath(TntApplication.ExeName)+LANG_SUBDIR+Config.Values.Language+LANG_EXT);
    TranslateAllStrings;
  end;
end;

//******************************************************************************
// CloseConfig sauvegarde la config et détruit l'objet de configuration
//******************************************************************************
procedure CloseConfig;
var IniFileName:WideString;
    NewConfig:TConfig;
    Reg:TRegistry;
begin
  //mise en place de l'autorun
  Reg:=TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(AUTORUN_REGISTRY_KEY, True) then
    begin
      if Config.Values.StartWithWindows then
        Reg.WriteString(WideExtractFileName(TntApplication.ExeName),TntApplication.ExeName)
      else
        Reg.DeleteValue(WideExtractFileName(TntApplication.ExeName));
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;

  if (ConfigLocation=clRegistry) and (Config is TIniConfig) then
  begin
    Config.DeleteData;

    NewConfig:=TRegistryConfig.Create(CONFIG_REGISTRY_KEY);
    try
      NewConfig.Values:=Config.Values;
      NewConfig.SaveConfig;
    finally
      NewConfig.Free;
    end;
  end
  else if (ConfigLocation=clIniFile) and (Config is TRegistryConfig) then
  begin
    Config.DeleteData;

    IniFileName:=ChangeFileExt(TntApplication.ExeName,'.ini');
    NewConfig:=TIniConfig.Create(IniFileName);
    try
      NewConfig.Values:=Config.Values;
      NewConfig.SaveConfig;
    finally
      NewConfig.Free;
    end;
  end
  else
  begin
    Config.SaveConfig;
  end;

  Config.Free;
end;

//******************************************************************************
// ApplyConfig: applique la configuration 'instantannée' 
//******************************************************************************
procedure ApplyConfig;
begin
  SetProcessPriority(Config.Values.Priority);
  MainForm.Systray.Visible:=Config.Values.TrayIcon;

  LocEngine.TranslateForm(MainForm);
  if Assigned(ConfigForm) then LocEngine.TranslateForm(ConfigForm);
  if Assigned(AboutForm) then LocEngine.TranslateForm(AboutForm);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TConfig: classe abstraite de base gérant la configuration
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor TConfig.Create;
begin
  LoadDefaultConfig;
end;

procedure TConfig.LoadDefaultConfig;
begin
  Values:=CONFIG_DEFAULT_VALUES;
end;

procedure TConfig.LoadConfig;
begin
  LoadDefaultConfig;

  with Values do
  begin
    try
      CopyBufferSize:=ReadInteger('CopyBufferSize');
      CopyWindowUpdateInterval:=ReadInteger('CopyWindowUpdateInterval');
      CopySpeedAveragingInterval:=ReadInteger('CopySpeedAveragingInterval');
      CopyThrottleInterval:=ReadInteger('CopyThrottleInterval');
      CopyErrorRetryInterval:=ReadInteger('CopyErrorRetryInterval');
      HandledProcesses:=ReadString('HandledProcesses');
      RenameNewPattern:=ReadString('RenameNewPattern');
      RenameOldPattern:=ReadString('RenameOldPattern');
      with DefaultCopyWindowConfig do
      begin
        CopyEndAction:=TCopyWindowCopyEndAction(ReadInteger('CopyEndAction'));
        ThrottleEnabled:=ReadBoolean('ThrottleEnabled');
        ThrottleSpeedLimit:=ReadInteger('ThrottleSpeedLimit');
        CollisionAction:=TCollisionAction(ReadInteger('CollisionAction'));
        CopyErrorAction:=TcopyErrorAction(ReadInteger('CopyErrorAction'));
      end;
      ErrorLogAutoSave:=ReadBoolean('ErrorLogAutoSave');
      ErrorLogAutoSaveMode:=TErrorLogAutoSaveMode(ReadInteger('ErrorLogAutoSaveMode'));
      ErrorLogFileName:=ReadString('ErrorLogFileName');
      FastFreeSpaceCheck:=ReadBoolean('FastFreeSpaceCheck');
      CopyListHandlingMode:=TCopyListHandlingMode(ReadInteger('CopyListHandlingMode'));
      CopyListHandlingConfirm:=ReadBoolean('CopyListHandlingConfirm');
      SaveAttributesOnCopy:=ReadBoolean('SaveAttributesOnCopy');
      SaveAttributesOnMove:=ReadBoolean('SaveAttributesOnMove');
      SizeUnit:=TSizeUnit(ReadInteger('SizeUnit'));
      DeleteUnfinishedCopies:=ReadBoolean('DeleteUnfinishedCopies');
      DontDeleteOnCopyError:=ReadBoolean('DontDeleteOnCopyError');
      CopyWindowSavePosition:=ReadBoolean('CopyWindowSavePosition');
      CopyWindowSaveSize:=ReadBoolean('CopyWindowSaveSize');
      CopyWindowTop:=ReadInteger('CopyWindowTop');
      CopyWindowLeft:=ReadInteger('CopyWindowLeft');
      CopyWindowWidth:=ReadInteger('CopyWindowWidth');
      CopyWindowHeight:=ReadInteger('CopyWindowHeight');
      CopyWindowUnfolded:=ReadBoolean('CopyWindowUnfolded');

      ActivateOnStart:=ReadBoolean('ActivateOnStart');
      TrayIcon:=ReadBoolean('TrayIcon');
      MinimizeToTray:=ReadBoolean('MinimizeToTray');
      CopyWindowStartMinimized:=ReadBoolean('CopyWindowStartMinimized');
      Priority:=ReadInteger('Priority');
      ProgressForegroundColor1:=StringToColor(ReadString('ProgressForegroundColor1'));
      ProgressForegroundColor2:=StringToColor(ReadString('ProgressForegroundColor2'));
      ProgressBackgroundColor1:=StringToColor(ReadString('ProgressBackgroundColor1'));
      ProgressBackgroundColor2:=StringToColor(ReadString('ProgressBackgroundColor2'));
      ProgressBorderColor:=StringToColor(ReadString('ProgressBorderColor'));
      ProgressTextColor:=StringToColor(ReadString('ProgressTextColor'));
      ProgressOutlineColor:=StringToColor(ReadString('ProgressOutlineColor'));
      MinimizedEventHandling:=TMinimizedEventHandling(ReadInteger('MinimizedEventHandling'));
      FailSafeCopier:=ReadBoolean('FailSafeCopier');
      Language:=UTF8Decode(ReadString('Language'));
      CopyResumeNoAgeVerification:=ReadBoolean('CopyResumeNoAgeVerification');
      SaveSecurityOnCopy:=ReadBoolean('SaveSecurityOnCopy');
      SaveSecurityOnMove:=ReadBoolean('SaveSecurityOnMove');
    except
      // ne rien faire si une valeur n'existe pas
    end;
  end;
end;

procedure TConfig.SaveConfig;
begin
  with Values do
  begin
    WriteInteger('CopyBufferSize',CopyBufferSize);
    WriteInteger('CopyWindowUpdateInterval',CopyWindowUpdateInterval);
    WriteInteger('CopySpeedAveragingInterval',CopySpeedAveragingInterval);
    WriteInteger('CopyThrottleInterval',CopyThrottleInterval);
    WriteInteger('CopyErrorRetryInterval',CopyErrorRetryInterval);
    WriteString('HandledProcesses',HandledProcesses);
    WriteString('RenameNewPattern',RenameNewPattern);
    WriteString('RenameOldPattern',RenameOldPattern);
    with DefaultCopyWindowConfig do
    begin
      WriteInteger('CopyEndAction',Integer(CopyEndAction));
      WriteBoolean('ThrottleEnabled',ThrottleEnabled);
      WriteInteger('ThrottleSpeedLimit',ThrottleSpeedLimit);
      WriteInteger('CollisionAction',Integer(CollisionAction));
      WriteInteger('CopyErrorAction',Integer(CopyErrorAction));
    end;
    WriteBoolean('ErrorLogAutoSave',ErrorLogAutoSave);
    WriteInteger('ErrorLogAutoSaveMode',Integer(ErrorLogAutoSaveMode));
    WriteString('ErrorLogFileName',ErrorLogFileName);
    WriteBoolean('FastFreeSpaceCheck',FastFreeSpaceCheck);
    WriteInteger('CopyListHandlingMode',Integer(CopyListHandlingMode));
    WriteBoolean('CopyListHandlingConfirm',CopyListHandlingConfirm);
    WriteBoolean('SaveAttributesOnCopy',SaveAttributesOnCopy);
    WriteBoolean('SaveAttributesOnMove',SaveAttributesOnMove);
    WriteInteger('SizeUnit',Integer(SizeUnit));
    WriteBoolean('DeleteUnfinishedCopies',DeleteUnfinishedCopies);
    WriteBoolean('DontDeleteOnCopyError',DontDeleteOnCopyError);
    WriteBoolean('CopyWindowSavePosition',CopyWindowSavePosition);
    WriteBoolean('CopyWindowSaveSize',CopyWindowSaveSize);
    WriteInteger('CopyWindowTop',CopyWindowTop);
    WriteInteger('CopyWindowLeft',CopyWindowLeft);
    WriteInteger('CopyWindowWidth',CopyWindowWidth);
    WriteInteger('CopyWindowHeight',CopyWindowHeight);
    WriteBoolean('CopyWindowUnfolded',CopyWindowUnfolded);

    WriteBoolean('ActivateOnStart',ActivateOnStart);
    WriteBoolean('TrayIcon',TrayIcon);
    WriteBoolean('MinimizeToTray',MinimizeToTray);
    WriteBoolean('CopyWindowStartMinimized',CopyWindowStartMinimized);
    WriteInteger('Priority',Priority);
    WriteString('ProgressForegroundColor1',ColorToString(ProgressForegroundColor1));
    WriteString('ProgressForegroundColor2',ColorToString(ProgressForegroundColor2));
    WriteString('ProgressBackgroundColor1',ColorToString(ProgressBackgroundColor1));
    WriteString('ProgressBackgroundColor2',ColorToString(ProgressBackgroundColor2));
    WriteString('ProgressBorderColor',ColorToString(ProgressBorderColor));
    WriteString('ProgressTextColor',ColorToString(ProgressTextColor));
    WriteString('ProgressOutlineColor',ColorToString(ProgressOutlineColor));
    WriteInteger('MinimizedEventHandling',Integer(MinimizedEventHandling));
    WriteBoolean('FailSafeCopier',FailSafeCopier);
    WriteString('Language',UTF8Encode(Language));
    WriteBoolean('CopyResumeNoAgeVerification',CopyResumeNoAgeVerification);
    WriteBoolean('SaveSecurityOnCopy',SaveSecurityOnCopy);
    WriteBoolean('SaveSecurityOnMove',SaveSecurityOnMove);
  end;
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TRegistryConfig: descendant de TConfig stockant la configuration dans la bdr
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor TRegistryConfig.Create(Key:String);
begin
  inherited Create;

  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  Reg.OpenKey(Key,True);

  FKey:=Key;
end;

destructor TRegistryConfig.Destroy;
begin
  if Assigned(Reg) then
  begin
    Reg.CloseKey;
    Reg.Free;
  end;

  inherited Destroy;
end;

procedure TRegistryConfig.DeleteData;
begin
  Reg.CloseKey;
  Reg.DeleteKey(FKey);
  Reg.Free;
  Reg:=nil;
end;

function TRegistryConfig.ReadInteger(Name:string):Integer;
begin
  Result:=Reg.ReadInteger(Name);
end;

function TRegistryConfig.ReadBoolean(Name:string):Boolean;
begin
  Result:=Reg.ReadBool(Name);
end;

function TRegistryConfig.ReadFloat(Name:string):Double;
begin
  Result:=Reg.ReadFloat(Name);
end;

function TRegistryConfig.ReadString(Name:string):String;
begin
  Result:=Reg.ReadString(Name);
end;

procedure TRegistryConfig.WriteInteger(Name:String;Value:Integer);
begin
  Reg.WriteInteger(Name,Value);
end;

procedure TRegistryConfig.WriteBoolean(Name:String;Value:Boolean);
begin
  Reg.WriteBool(Name,Value);
end;

procedure TRegistryConfig.WriteFloat(Name:String;Value:Double);
begin
  Reg.WriteFloat(Name,Value);
end;

procedure TRegistryConfig.WriteString(Name:String;Value:String);
begin
  Reg.WriteString(Name,Value);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TIniConfig: descendant de TConfig stockant la configuration dans un .ini
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor TIniConfig.Create(FileName:WideString);
begin
  inherited Create;

  Ini:=TMemIniFile.Create(FileName);

  Section:=ExtractFileName(FileName);
  Section:=LeftStr(Section,Pos('.',Section)-1);

  FFilename:=FileName;
end;

destructor TIniConfig.Destroy;
begin
  if Assigned(Ini) then
  begin
    Ini.UpdateFile;
    Ini.Free;
  end;

  inherited Destroy;
end;

procedure TIniConfig.DeleteData;
begin
  Ini.Free;
  Ini:=nil;
  SCWin32.DeleteFile(PWidechar(FFileName));
end;

procedure TIniConfig.VerifyValueExists(Name:String);
begin
  if not Ini.ValueExists(Section,Name) then Raise Exception.Create(''''+Name+''' doesn''t exists');
end;

function TIniConfig.ReadInteger(Name:string):Integer;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadInteger(Section,Name,0);
end;

function TIniConfig.ReadBoolean(Name:string):Boolean;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadBool(Section,Name,False);
end;

function TIniConfig.ReadFloat(Name:string):Double;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadFloat(Section,Name,0.0);
end;

function TIniConfig.ReadString(Name:string):String;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadString(Section,Name,'');
end;

procedure TIniConfig.WriteInteger(Name:String;Value:Integer);
begin
  Ini.WriteInteger(Section,Name,Value);
end;

procedure TIniConfig.WriteBoolean(Name:String;Value:Boolean);
begin
  Ini.WriteBool(Section,Name,Value);
end;

procedure TIniConfig.WriteFloat(Name:String;Value:Double);
begin
  Ini.WriteFloat(Section,Name,Value);
end;

procedure TIniConfig.WriteString(Name:String;Value:String);
begin
  Ini.WriteString(Section,Name,Value);
end;

end.
