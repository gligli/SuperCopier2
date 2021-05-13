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

unit SCWorkThreadList;
//TODO: quand on enleve une workthread de la liste, l'enlever aussi de la liste des handles de l'API

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

    function ProcessBaseList(BaseList:TBaseList;Operation:Cardinal;DestDir:WideString=''):TWorkThread;
    procedure CreateEmptyCopyThread(IsMove:Boolean);
    procedure CancelAllAndWaitTermination(Timeout:Cardinal);

    constructor Create;
  end;

var
  WorkThreadList:TWorkThreadList;

implementation

uses ShellApi,TntSysUtils, Contnrs,SCCopyThread, DateUtils,Windows,Forms;

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
//                  renvoie la WorkThread qui a pris en charge la BL ou nil si pas de prise en charge
//******************************************************************************
function TWorkThreadList.ProcessBaseList(BaseList:TBaseList;Operation:Cardinal;DestDir:WideString=''):TWorkThread;
var i:Integer;
    GuessedSrcDir:WideString;
    SameVolumeMove:Boolean;
    CopyThread:TCopyThread;
begin
  Result:=nil;

  if BaseList.Count=0 then Exit;

  dbgln('ProcessBaseList: B[0]='+BaseList[0].SrcName);
  dbgln('                   DD='+DestDir);
  try
    Lock;

    case Operation of
      FO_RENAME:
        Result:=nil;
      FO_DELETE:
        Result:=nil; // non supporté pour le moment
      FO_MOVE,
      FO_COPY:
      begin
        GuessedSrcDir:=WideExtractFilePath(BaseList[0].SrcName);
        SameVolumeMove:=(Operation=FO_MOVE) and SameVolume(GuessedSrcDir,DestDir);

        if SameVolumeMove then
        begin
          Result:=nil; // non supporté pour le moment
        end
        else
        begin
          Result:=nil;
          CopyThread:=nil;
          i:=0;
          while (i<Count) and (Result=nil) do
          begin
            if Items[i].ThreadType=wttCopy then
            begin
              CopyThread:=Items[i] as TCopyThread;

              if (CopyThread.IsMove=(Operation=FO_MOVE)) and CopyThread.CanHandle(GuessedSrcDir,DestDir) then
                Result:=CopyThread;
            end;

            Inc(i);
          end;

          if Result=nil then // aucune CopyThread ne peut prendre en charge l'opération -> on en crée une nouvelle
          begin
            CopyThread:=TCopyThread.Create(Operation=FO_MOVE);
            Add(CopyThread); // rescencer la thread
            Result:=CopyThread;
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

//******************************************************************************
// CancelAllAndWaitTermination: annule tout les traitements et attends la fin des threads
//******************************************************************************
procedure TWorkThreadList.CancelAllAndWaitTermination(Timeout:Cardinal);
var i:Integer;
    t:Cardinal;
    Ok:Boolean;
begin
  // annulation
  for i:=Count-1 downto 0 do Items[i].Cancel;

  // attente
  t:=GetTickCount;
  repeat
    try
      Lock;
      Ok:=Count=0;
    finally
      Unlock
    end;
    Sleep(DEFAULT_WAIT);
    Application.ProcessMessages;
  until Ok or (GetTickCount>=t+Timeout);
end;

end.
