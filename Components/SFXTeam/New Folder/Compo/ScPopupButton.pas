unit ScPopupButton;

interface

uses
  SysUtils, Classes, Controls,TNTMenus;

type
  TClickPopupButton = Procedure (Sender:TObject;ItemIndex:Integer) of object;

  TScPopupButton = class(TWinControl)
  private
    { D�clarations priv�es }
    FItemIndex:integer;
    FPopup:TTntPopupMenu;
    procedure SetItemIndex(const Value:Integer);
  protected
    { D�clarations prot�g�es }
   // procedure OnClickPopup:;
  public
    { D�clarations publiques }
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
  published
    { D�clarations publi�es }
    property Anchors;
    property ItemIndex : Integer read FItemIndex write SetItemIndex;
    property Popup : TTntPopupMenu read FPopup;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SFX Team', [TScPopupButton]);
end;

{ TScPopupButton }

constructor TScPopupButton.Create(AOwner: TComponent);
begin
  inherited;
  FPopup:=TTntPopupMenu.Create(self);
  FPopup.PopupComponent:=self;
end;

destructor TScPopupButton.Destroy;
begin
  FPopup.Free;
  inherited;
end;

procedure TScPopupButton.SetItemIndex(const Value: Integer);
begin
  if value<>FItemIndex then
  begin
    FItemIndex:=Value;
    If Popup.Items[FItemIndex]<>nil then // on cache l'item du popup
      Popup.Items[FItemIndex].Visible:=false;
  end;
end;


end.
