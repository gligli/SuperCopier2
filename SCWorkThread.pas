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

unit SCWorkThread;

interface

uses Classes;

type
  TWorkThreadType=(wttNone,wttCopy,wttMove,wttDelete); //wttCopy est utilisé aussi pour les déplacements entre volumes

  TWorkThread=class(TThread)
  protected
    FThreadType:TWorkThreadType;
    function GetDisplayName:WideString;virtual;abstract;
  public
    property ThreadType:TWorkThreadType read FThreadType;
    property DisplayName:WideString read GetDisplayName;

    constructor Create;
    destructor Destroy;override;

    procedure Cancel;virtual;abstract;
  end;

implementation

uses SCAPI;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TWorkThread: classe de base des thread de copie/supression/...
//******************************************************************************
//******************************************************************************
//******************************************************************************

constructor TWorkThread.Create;
begin
  inherited Create(True);

  FThreadType:=wttNone;
end;

destructor TWorkThread.Destroy;
begin
  API.RemoveHandle(Self);
  inherited;
end;

end.
