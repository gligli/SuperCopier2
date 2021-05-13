unit SCConfig;

interface
uses Registry,IniFiles,SCCommon;

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

    constructor Create;
  end;

  TRegistryConfig=class(TConfig)
  private
    Reg:TRegistry;
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
  end;

  TIniConfig=class(TConfig)
  private
    Ini:TMemIniFile;

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
    constructor Create(FileName:String);
    destructor Destroy;override;
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
  );

  INI_SECTION='SuperCopier2';

var
  Config:TConfig;

implementation
uses Windows,SysUtils;

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
      CopyListHandlingConfirm:=ReadBoolean('CopyListHandlingConfirm')
    except
      LoadDefaultConfig;
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
end;

destructor TRegistryConfig.Destroy;
begin
  Reg.CloseKey;
  Reg.Free;

  inherited Destroy;
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

constructor TIniConfig.Create(FileName:String);
begin
  inherited Create;

  Ini:=TMemIniFile.Create(FileName);
end;

destructor TIniConfig.Destroy;
begin
  Ini.UpdateFile;
  Ini.Free;

  inherited Destroy;
end;

procedure TIniConfig.VerifyValueExists(Name:String);
begin
  if not Ini.ValueExists(INI_SECTION,Name) then Raise Exception.Create(''''+Name+''' doesn''t exists');
end;

function TIniConfig.ReadInteger(Name:string):Integer;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadInteger(INI_SECTION,Name,0);
end;

function TIniConfig.ReadBoolean(Name:string):Boolean;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadBool(INI_SECTION,Name,False);
end;

function TIniConfig.ReadFloat(Name:string):Double;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadFloat(INI_SECTION,Name,0.0);
end;

function TIniConfig.ReadString(Name:string):String;
begin
  VerifyValueExists(Name);
  Result:=Ini.ReadString(INI_SECTION,Name,'');
end;

procedure TIniConfig.WriteInteger(Name:String;Value:Integer);
begin
  Ini.WriteInteger(INI_SECTION,Name,Value);
end;

procedure TIniConfig.WriteBoolean(Name:String;Value:Boolean);
begin
  Ini.WriteBool(INI_SECTION,Name,Value);
end;

procedure TIniConfig.WriteFloat(Name:String;Value:Double);
begin
  Ini.WriteFloat(INI_SECTION,Name,Value);
end;

procedure TIniConfig.WriteString(Name:String;Value:String);
begin
  Ini.WriteString(INI_SECTION,Name,Value);
end;

end.
