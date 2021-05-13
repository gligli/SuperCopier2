unit SCMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,  TntForms,
  Dialogs, StdCtrls,filectrl,tntsysutils,TntStdCtrls,ShellApi, Controls;

type
  TMainForm = class(TTntForm)
    TntButton1: TTntButton;
    TntButton2: TTntButton;
    TntCheckBox1: TTntCheckBox;
    TntListBox1: TTntListBox;
    TntButton3: TTntButton;
    TntEdit1: TTntEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure TntButton2Click(Sender: TObject);
    procedure TntButton3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;

implementation
uses SCConfig,SCCommon,SCWin32,SCCopyThread,SCBaseList,SCFileList,SCDirList,SCHookShared,SCWorkThreadList,madCodeHook,
  Forms;
{$R *.dfm}

//******************************************************************************
// HookCallback
//******************************************************************************
procedure HookCallback(name:pchar;messageBuf:pointer;messageLen:dword;
                       answerBuf:pointer;answerLen:dword);stdcall;
var Handled:Boolean;
    HookData:TSCHookData;
    RawProcessName:array[0..MAX_PATH] of char;
    ProcessName:String;
    Source,Destination:PWideChar;
    FileName:WideString;
    BaseList:TBaseList;
    Item:TBaseItem;
begin
  Handled:=False;

  // on récup les données qui étaient collées les unes apres les autres
  Move(messageBuf^,HookData,SizeOf(TSCHookData));
  Destination:=Pointer(Cardinal(messageBuf)+SizeOf(TSCHookData));
  Source:=Pointer(Integer(messageBuf)+SizeOf(TSCHookData)+HookData.DestinationSize);

  // le processus ayant lancé la copie doit-it être pris en charge?
  ProcessIdToFileName(HookData.ProcessId,RawProcessName);
  ProcessName:=LowerCase(ExtractFileName(RawProcessName));
  if Pos(ProcessName,Config.Values.HandledProcesses)<>0 then
    with HookData do
    begin
      BaseList:=TBaseList.Create;

      // on parcours la liste des Sources et on ajoute les éléments à la BaseList
      while Source^<>#0 do //Source est terminée par un double #0, je me serts du deuxième #0 pour tester la fin de la liste
      begin
        FileName:=Source;
        
        // windows rajoute parfois *.* a la fin d'un nom de répertoire
        if WideExtractFileName(FileName)='*.*' then
        begin
          FileName:=WideExcludeTrailingBackslash(WideExtractFilePath(FileName));
        end;

        Item:=TBaseItem.Create;
        Item.SrcName:=FileName;
        Item.IsDirectory:=WideDirectoryExists(FileName);

        BaseList.Add(Item);

        Inc(Source,StrLenW(Source)+1);
      end;

      Handled:=WorkThreadList.ProcessBaseList(BaseList,Operation,Destination);
    end;

  Boolean(answerBuf^):=Handled;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  Config:=TIniConfig.Create(ChangeFileExt(TntApplication.ExeName,'.ini'));
  Config.LoadConfig;

  WorkThreadList:=TWorkThreadList.Create;

  if not InjectLibrary(ALL_SESSIONS and not CURRENT_PROCESS,DLL_NAME) or
     not CreateIpcQueue(IPC_NAME,HookCallback) then
  begin
    ShowMessage('hook foiré');
    Application.Terminate;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;

  DestroyIpcQueue(IPC_NAME);
  UninjectLibrary(ALL_SESSIONS,DLL_NAME);

  WorkThreadList.Free;

  Config.SaveConfig;
  Config.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var i:Integer;
begin
  TntListBox1.Clear;
  for i:=0 to WorkThreadList.Count-1 do
    TntListBox1.AddItem(WorkThreadList[i].DisplayName,nil);
end;

procedure TMainForm.TntButton2Click(Sender: TObject);
begin
  WorkThreadList.CreateEmptyCopyThread(TntCheckBox1.Checked);  
end;

procedure TMainForm.TntButton3Click(Sender: TObject);
var sdn:TStorageDeviceNumber;
begin
  if GetStorageDeviceNumber(TntEdit1.Text,sdn) then
  begin
    dbgln(sdn.DeviceType);
    dbgln(sdn.DeviceNumber);
  end;
end;

end.








































