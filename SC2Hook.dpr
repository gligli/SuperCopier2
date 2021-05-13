library SC2Hook;

uses
  Windows,
  ShellApi,
  madCodeHook,
  SCHookShared in 'SCHookShared.pas';

var
	NextSHFileOperationA : function(const lpFileOp : TSHFileOpStructA):integer;stdcall;
	NextSHFileOperationW : function(const lpFileOp : TSHFileOpStructW):integer;stdcall;

{$R *.res}

//******************************************************************************
// MultiNullStrLen: r�cup�re la taille d'une chaine termin�e par NumNull z�ros
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
// NewSHFileOperationA
//******************************************************************************
function NewSHFileOperationA(const lpFileOp : TSHFileOpStructA):integer;stdcall;
var HookData:TSCHookData;
    Buffer:array of byte;
    BufferSize:Integer;
    Handled:Boolean;
begin
  with HookData,lpFileOp do
  begin
    Operation:=wFunc;
    ProcessId:=GetCurrentProcessId;
    SourceSize:=2*MultiNullStrLen(pFrom,2); // 2 #0 car ce sont des chaines a double 0 terminal
                                            // les donn�es vont �tre stock�es sour forme unicode, donc 2 bytes/char au lieu d'1

    if wFunc in [FO_COPY,FO_MOVE] then // pTo n'est valide que si copie ou d�placement
      DestinationSize:=2*MultiNullStrLen(pTo,2)
    else
      DestinationSize:=0;

    // le buffer va contenir les 3 �l�ments plac�s les uns derri�re les autres
    BufferSize:=SizeOf(TSCHookData)+SourceSize+DestinationSize;
    SetLength(Buffer,BufferSize);

    // on �crit dans le buffer HookData suivi de la destination suivi de la source
    // tout est converti en unicode
    Move(HookData,Buffer[0],SizeOf(TSCHookData));
    MultiByteToWideChar(CP_ACP,0,pTo,DestinationSize div 2,@Buffer[SizeOf(TSCHookData)],DestinationSize);
    MultiByteToWideChar(CP_ACP,0,pFrom,SourceSize div 2,@Buffer[SizeOf(TSCHookData)+DestinationSize],SourceSize);

    // envoi des donn�es par IPC
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
var HookData:TSCHookData;
    Buffer:array of byte;
    BufferSize:Integer;
    Handled:Boolean;
begin
  with HookData,lpFileOp do
  begin
    Operation:=wFunc;
    ProcessId:=GetCurrentProcessId;
    SourceSize:=MultiNullStrLen(pFrom,4); // 4 #0 car ce sont des chaines unicode a double 0 terminal

    if wFunc in [FO_COPY,FO_MOVE] then // pTo n'est valide que si copie ou d�placement
      DestinationSize:=MultiNullStrLen(pTo,4)
    else
      DestinationSize:=0;

    // le buffer va contenir les 3 �l�ments plac�s les uns derri�re les autres
    BufferSize:=SizeOf(TSCHookData)+SourceSize+DestinationSize;
    SetLength(Buffer,BufferSize);

    // on �crit dans le buffer HookData suivi de la destination suivi de la source
    Move(HookData,Buffer[0],SizeOf(TSCHookData));
    Move(pTo^,Buffer[SizeOf(TSCHookData)],DestinationSize);
    Move(pFrom^,Buffer[SizeOf(TSCHookData)+DestinationSize],SourceSize);

    // envoi des donn�es par IPC
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

begin
  HookAPI('shell32.dll','SHFileOperationA',@NewSHFileOperationA,@NextSHFileOperationA);

  if GetVersion and $80000000 = 0 then // Windows NT ?
    HookAPI('shell32.dll','SHFileOperationW',@NewSHFileOperationW,@NextSHFileOperationW);
end.
