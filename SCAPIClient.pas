unit SCAPIClient;
{$message warn 'SCAPIClient n''est plus utilisé et n''est plus à jour, voir l''implémenation C++'}

interface

uses Windows,Classes,SysUtils,
     SCWin32,SCAPICommon;

type
  EAPIClientError=class(Exception);

  TAPIClient=class
  private
    FMutex:THandle;
    FFileMapping:THandle;
    FClientEvent:THandle;
    FAPIEvent:THandle;
    FFileMappingStream:TFileMappingStream;
  public
    constructor Create;
    destructor Destroy;override;

    procedure Lock;
    procedure UnLock;
    procedure SendAndWaitResult;

    property FileMappingStream:TFileMappingStream read FFileMappingStream;
  end;

var APIClient:TAPIClient=nil;

{
function TestI2S(Value:Integer):WideString;
function TestS2I(Value:WideString):Integer;
}

implementation

{ TAPIClient }

constructor TAPIClient.Create;
begin
  inherited;

  FMutex:=SCWin32.OpenMutex(MUTEX_ALL_ACCESS,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_MUTEX_ID)));
  if FMutex=0 then
    raise EAPIClientError.Create('Couldn''t open mutex');

  FFileMapping:=SCWin32.OpenFileMapping(FILE_MAP_ALL_ACCESS,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_FILEMAPPING_ID)));
  if FFileMapping=0 then
    raise EAPIClientError.Create('Couldn''t open file mapping');

  FClientEvent:=SCWin32.OpenEvent(EVENT_ALL_ACCESS,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_CLIENTEVENT_ID)));
  if FClientEvent=0 then
    raise EAPIClientError.Create('Couldn''t open client event');

  FAPIEvent:=SCWin32.OpenEvent(EVENT_ALL_ACCESS,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_APIEVENT_ID)));
  if FAPIEvent=0 then
    raise EAPIClientError.Create('Couldn''t open API event');

  FFileMappingStream:=TFileMappingStream.Create(FFileMapping,SC2_API_FILEMAPPING_SIZE);
end;

destructor TAPIClient.Destroy;
begin
  CloseHandle(FAPIEvent);
  CloseHandle(FClientEvent);
  FFileMappingStream.Free;
  CloseHandle(FFileMapping);
  CloseHandle(FMutex);
  inherited;
end;

procedure TAPIClient.Lock;
begin
  WaitForSingleObject(FMutex,INFINITE);

  // au passsage ...
  FileMappingStream.Seek(0,soFromBeginning);
end;

procedure TAPIClient.SendAndWaitResult;
begin
  SetEvent(FClientEvent);
  WaitForSingleObject(FAPIEvent,INFINITE);

  // au passsage ...
  FFileMappingStream.Seek(0,soFromBeginning);
end;

procedure TAPIClient.UnLock;
begin
  ReleaseMutex(FMutex);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// Fonctions de l'API
//******************************************************************************
//******************************************************************************
//******************************************************************************

{
function TestI2S(Value:Integer):WideString;
begin
  APIClient.Lock;
  try
    APIClient.FileMappingStream.WriteInteger(Integer(afTestI2S));
    APIClient.FileMappingStream.WriteInteger(Value);
    APIClient.SendAndWaitResult;
    Result:=APIClient.FileMappingStream.ReadWideString;
  finally
    APIClient.UnLock;
  end;
end;

function TestS2I(Value:WideString):Integer;
begin
  APIClient.Lock;
  try
    APIClient.FileMappingStream.WriteInteger(Integer(afTestS2I));
    APIClient.FileMappingStream.WriteWideString(Value);
    APIClient.SendAndWaitResult;
    Result:=APIClient.FileMappingStream.ReadInteger;
  finally
    APIClient.UnLock;
  end;
end;
}
end.
