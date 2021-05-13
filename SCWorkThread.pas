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

    procedure Cancel;virtual;abstract;
  end;

implementation

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

end.
