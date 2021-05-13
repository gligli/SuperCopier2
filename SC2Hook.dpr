library SC2Hook;

uses
  Windows,
  ShellApi,
  madCodeHook,
  SCHookShared in 'SCHookShared.pas';

var
	NextSHFileOperationA : function(const lpFileOp : TSHFileOpStructA):integer;stdcall;
	NextSHFileOperationW : function(const lpFileOp : TSHFileOpStructW):integer;stdcall;
	NextShellExecuteExA : function(var lpExecInfo : TShellExecuteInfoA):LongBool;stdcall;
	NextShellExecuteExW : function(var lpExecInfo : TShellExecuteInfoW):LongBool;stdcall;

  App2HookData:PSCApp2HookData=nil;
  App2HookMapping:THandle=0;
{$R *.res}

//******************************************************************************
//******************************************************************************
//                           Fonctions Helper
//******************************************************************************
//******************************************************************************

//******************************************************************************
// MultiNullStrLen: récupère la taille d'une chaine terminée par NumNull zéros
//******************************************************************************
function MultiNullStrLen(S:Pointer;NumNull:Integer):Integer;
var PS:PChar;
    FoundNull:Integer;
begin
  Result:=0;
  FoundNull:=0;
  PS:=S;

  while FoundNull<=NumNull do
  begin
    if PS^=#0 then
      Inc(FoundNull)
    else
      FoundNull:=0;

    Inc(PS);
    Inc(Result);
  end;
end;

//******************************************************************************
// ExtractFileName: fonction standard de Delphi
//******************************************************************************
function ExtractFileName(FN:String):string;
var P:PChar;
begin
  P:=PChar(FN);
  inc(P,Length(FN));

  while (P>=PChar(FN)) and (P^<>'\') do
  begin
		if (P^>='A') and (P^<='Z') then Inc(P^,32); // uppercase -> lowercase
    dec(P);
  end;
  Result:=P+1;
end;

//******************************************************************************
//******************************************************************************
//                           Fonctions de hook
//******************************************************************************
//******************************************************************************

//******************************************************************************
// NewSHFileOperationA
//******************************************************************************
function NewSHFileOperationA(const lpFileOp : TSHFileOpStructA):integer;stdcall;
var HookData:TSCHook2AppData;
    Buffer:array of byte;
    BufferSize:Integer;
    Handled:Boolean;
begin
  with HookData,lpFileOp do
  begin
    Operation:=wFunc;
    ProcessId:=GetCurrentProcessId;
    SourceSize:=2*MultiNullStrLen(pFrom,2); // 2 #0 car ce sont des chaines a double 0 terminal
                                            // les données vont être stockées sour forme unicode, donc 2 bytes/char au lieu d'1

    if wFunc in [FO_COPY,FO_MOVE] then // pTo n'est valide que si copie ou déplacement
      DestinationSize:=2*MultiNullStrLen(pTo,2)
    else
      DestinationSize:=0;

    // le buffer va contenir les 3 éléments placés les uns derrière les autres
    BufferSize:=SizeOf(TSCHook2AppData)+SourceSize+DestinationSize;
    SetLength(Buffer,BufferSize);

    // on écrit dans le buffer HookData suivi de la destination suivi de la source
    // tout est converti en unicode
    Move(HookData,Buffer[0],SizeOf(TSCHook2AppData));
    MultiByteToWideChar(CP_ACP,0,pTo,DestinationSize div 2,@Buffer[SizeOf(TSCHook2AppData)],DestinationSize);
    MultiByteToWideChar(CP_ACP,0,pFrom,SourceSize div 2,@Buffer[SizeOf(TSCHook2AppData)+DestinationSize],SourceSize);

    // envoi des données par IPC
    if not SendIpcMessage(IPC_NAME,Buffer,BufferSize,@Handled,SizeOf(Boolean)) then
    begin
      Handled:=False;
    end;

    // si action pas prise en charge, on renvoie le tout a windows
    if Handled then
    begin
      Result:=NO_ERROR;
    end
    else
    begin
      Result:=NextSHFileOperationA(lpFileOp);
    end;

    SetLength(Buffer,0);
  end;
end;

//******************************************************************************
// NewSHFileOperationW
//******************************************************************************
function NewSHFileOperationW(const lpFileOp : TSHFileOpStructW):integer;stdcall;
var HookData:TSCHook2AppData;
    Buffer:array of byte;
    BufferSize:Integer;
    Handled:Boolean;
begin
  with HookData,lpFileOp do
  begin
    ProcessId:=GetCurrentProcessId;
    DataType:=hdtSHFileOperation;
    Operation:=wFunc;
    SourceSize:=MultiNullStrLen(pFrom,4); // 4 #0 car ce sont des chaines unicode a double 0 terminal

    if wFunc in [FO_COPY,FO_MOVE] then // pTo n'est valide que si copie ou déplacement
      DestinationSize:=MultiNullStrLen(pTo,4)
    else
      DestinationSize:=0;

    // le buffer va contenir les 3 éléments placés les uns derrière les autres
    BufferSize:=SizeOf(TSCHook2AppData)+SourceSize+DestinationSize;
    SetLength(Buffer,BufferSize);

    // on écrit dans le buffer HookData suivi de la destination suivi de la source
    Move(HookData,Buffer[0],SizeOf(TSCHook2AppData));
    Move(pTo^,Buffer[SizeOf(TSCHook2AppData)],DestinationSize);
    Move(pFrom^,Buffer[SizeOf(TSCHook2AppData)+DestinationSize],SourceSize);

    // envoi des données par IPC
    if not SendIpcMessage(IPC_NAME,Buffer,BufferSize,@Handled,SizeOf(Boolean)) then
    begin
      Handled:=False;
    end;

    // si action pas prise en charge, on renvoie le tout a windows
    if Handled then
    begin
      Result:=NO_ERROR;
    end
    else
    begin
      Result:=NextSHFileOperationW(lpFileOp);
    end;

    SetLength(Buffer,0);
  end;
end;

//******************************************************************************
// NewShellExecuteExW
//******************************************************************************
function NewShellExecuteExW(var lpExecInfo : TShellExecuteInfoW):LongBool;
var HookData:TSCHook2AppData;
var FN,ExplorersList:string;
begin
  with HookData,lpExecInfo do
	begin
    ProcessId:=GetCurrentProcessId;
    DataType:=hdtShellExecute;

    MessageBoxW(0,lpFile,pwidechar(widestring(string(App2HookData.HandledProcesses))),0);

		FN:=ExtractFileName(lpFile);
		if Pos(FN,ExplorersList)<>0 then // doit-on hooker le processus qui va être créé?
		begin
			fMask:=fMask or SEE_MASK_NOCLOSEPROCESS; // on veut récupérer un handle su processus créé

			Result:=NextShellExecuteExW(lpExecInfo);
			if Result and (hProcess<>0) then
			begin
				//SendMessage(HandleDest,WM_HOOKEXPLORER,hProcess,GetCurrentProcessId);
				CloseHandle(hProcess);
			end;
		end
		else
		begin
			Result:=NextShellExecuteExW(lpExecInfo);
		end;
	end;
end;

//******************************************************************************
// LibraryProc
//******************************************************************************
procedure LibraryProc(AReason:Integer);
begin
  case AReason of
    DLL_PROCESS_ATTACH:
    begin
      // accès aux données provenant de l'appli
      App2HookMapping:=OpenFileMapping(FILE_MAP_READ,True,FILE_MAPING_NAME);
      App2HookData:=MapViewOfFile(App2HookMapping,FILE_MAP_READ,0,0,0);

      // hook des fonctions
      HookAPI('shell32.dll','SHFileOperationA',@NewSHFileOperationA,@NextSHFileOperationA);

      if GetVersion and $80000000 = 0 then // Windows NT ?
      begin
        HookAPI('shell32.dll','SHFileOperationW',@NewSHFileOperationW,@NextSHFileOperationW);
        HookAPI('shell32.dll','ShellExecuteExW',@NewShellExecuteExW,@NextShellExecuteExW);
      end;
    end;
    DLL_PROCESS_DETACH:
    begin
      UnMapViewOfFile(App2HookData);
      CloseHandle(App2HookMapping);
    end;
    DLL_THREAD_ATTACH:;
    DLL_THREAD_DETACH:;
  end;
end;

begin
  DllProc:=@LibraryProc;
  LibraryProc(DLL_PROCESS_ATTACH);
end.



