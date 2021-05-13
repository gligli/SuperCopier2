unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SCProgessBar, ComCtrls, Menus, TntMenus, ScSystray,
  SCTitleBarBt, XPMan, ScPopupButton, StdCtrls,themes, Buttons, ColorGrd,
  ToolWin, ImgList;

type
  TForm1 = class(TForm)
    SCProgessBar1: TSCProgessBar;
    Timer1: TTimer;
    SCTitleBarBt1: TSCTitleBarBt;
    ScSystray1: TScSystray;
    XPManifest1: TXPManifest;
    SCProgessBar2: TSCProgessBar;
    ScPopupButton1: TScPopupButton;
    TntPopupMenu1: TTntPopupMenu;
    toto1: TTntMenuItem;
    toto21: TTntMenuItem;
    OTO31: TTntMenuItem;
    oto41: TTntMenuItem;
    TrackBar2: TTrackBar;
    ImageList1: TImageList;
    Button1: TButton;
    Timer2: TTimer;
    Button2: TButton;
    ScPopupButton3: TScPopupButton;
    ScPopupButton4: TScPopupButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SCTitleBarBt1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ScPopupButton1Click(Sender: TObject; ItemIndex: Integer);
    procedure TrackBar2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ScPopupButton2Click(Sender: TObject; ItemIndex: Integer);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

uses DateUtils;

{$R *.dfm}

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if SCProgessBar1.Position=SCProgessBar1.Max then SCProgessBar1.Position:=0;
  SCProgessBar1.SetAvancement(SCProgessBar1.Position+1,Format('Restant: %d s',[SCProgessBar1.Max-SCProgessBar1.Position]));

end;

procedure TForm1.FormCreate(Sender: TObject);
Var
  MenuItem:TTntMenuItem;
begin
  AllocConsole;
  ScSystray1.Icone:=Application.Icon;
   MenuItem:=TTntMenuItem.Create(ScPopupButton1.Popup);
   MenuItem.Caption:='toto';
end;

procedure TForm1.SCTitleBarBt1Click(Sender: TObject);
begin
  ShowMessage('toto');
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Details: TThemedElementDetails;
begin
Writeln('plop');
  if ThemeServices.ThemesEnabled then
  begin
    Details:=ThemeServices.GetElementDetails(ttbSplitButtonDropDownNormal);
    ThemeServices.DrawElement(Form1.Canvas.Handle,details,rect(0,0,100,20) );
  end;

end;

procedure TForm1.ScPopupButton1Click(Sender: TObject; ItemIndex: Integer);
begin
  write(format('%d a ete clique'+#10+#13,[ItemIndex]));
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  ScPopupButton1.ItemIndex:=TrackBar2.Position;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Canvas.DrawFocusRect(rect(5,5,50,50));
end;

procedure TForm1.ScPopupButton2Click(Sender: TObject; ItemIndex: Integer);
begin
  Writeln(itemindex);
end;

end.
