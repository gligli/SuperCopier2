unit SCWorkThreadList;

interface

uses
  Classes,SCObjectThreadList,SCBaseList,SCWorkThread,SCCommon;

type
  TWorkThreadList=class(TObjectThreadList)
  private
		function Get(Index: Integer): TWorkThread;
		procedure Put(Index: Integer; Item: TWorkThread);
  public
	  property Items[Index: Integer]: TWorkThread read Get write Put; default;

    function ProcessBaseList(BaseList:TBaseList;Operation:Cardinal;DestDir:WideString=''):Boolean;
    procedure CreateEmptyCopyThread(IsMove:Boolean);

    constructor Create;
  end;

var
  WorkThreadList:TWorkThreadList;

implementation

uses ShellApi,TntSysUtils, Contnrs,SCCopyThread;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TWorkThreadList
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// Create
//******************************************************************************
constructor TWorkThreadList.Create;
begin
  inherited Create;

  OwnsObjects:=False;
end;

//******************************************************************************
// Get
//******************************************************************************
function TWorkThreadList.Get(Index: Integer): TWorkThread;
begin
  Result:=TWorkThread(inherited Get(Index));
end;

//******************************************************************************
// Put
//******************************************************************************
procedure TWorkThreadList.Put(Index: Integer; Item: TWorkThread);
begin
  inherited Put(Index,Item);
end;

//******************************************************************************
// ProcessBaseList: prends en charge une opération sur une BaseList,
//                  renvoie False si pas pris en charge
//******************************************************************************
function TWorkThreadList.ProcessBaseList(BaseList:TBaseList;Operation:Cardinal;DestDir:WideString=''):Boolean;
var i:Integer;
    GuessedSrcDir:WideString;
    SameVolumeMove:Boolean;
    CopyThread:TCopyThread;
begin
  try
    Lock;

    Result:=False;

    case Operation of
      FO_RENAME:
        Result:=False;
      FO_DELETE:
        Result:=False; // non supporté pour le moment
      FO_MOVE,
      FO_COPY:
      begin
        GuessedSrcDir:=WideExtractFilePath(BaseList[0].SrcName);
        dbgln(GuessedSrcDir);
        dbgln(DestDir);
        SameVolumeMove:=(Operation=FO_MOVE) and SameVolume(GuessedSrcDir,DestDir);

        if SameVolumeMove then
        begin
          Result:=False; // non supporté pour le moment
        end
        else
        begin
          Result:=False;
          CopyThread:=nil;
          i:=0;
          while (i<Count) and not Result do
          begin
            if Items[i].ThreadType=wttCopy then
            begin
              CopyThread:=Items[i] as TCopyThread;

              Result:=(CopyThread.IsMove=(Operation=FO_MOVE)) and CopyThread.CanHandle(GuessedSrcDir,DestDir);
            end;

            Inc(i);
          end;

          if not Result then // aucune CopyThread ne peut prendre en charge l'opération -> on en crée une nouvelle
          begin
            CopyThread:=TCopyThread.Create(Operation=FO_MOVE);
            Add(CopyThread); // rescencer la thread
            Result:=True;
          end;

          CopyThread.AddBaseList(BaseList,amSpecifyDest,DestDir);
        end;
      end;
    end;

  finally
    Unlock;
  end;
end;

//******************************************************************************
// CreateEmptyCopyThread: crée une fenêtre de copie vide
//******************************************************************************
procedure TWorkThreadList.CreateEmptyCopyThread(IsMove:Boolean);
var CopyThread:TCopyThread;
begin
  CopyThread:=TCopyThread.Create(IsMove);
  Add(CopyThread);
end;

end.
