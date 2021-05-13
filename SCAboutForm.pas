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

unit SCAboutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,TntForms,
  Dialogs, ExtCtrls, StdCtrls, TntStdCtrls,ShellApi,SCLocEngine;

const
  COSTAB_LENGTH=2048;

type
  TAboutForm = class(TTntForm)
    imLogo: TImage;
    llName: TTntLabel;
    llStaffTitle: TTntLabel;
    llStaff1: TTntLabel;
    llURL: TTntLabel;
    btOk: TTntButton;
    llThanksTitle: TTntLabel;
    llThanks1: TTntLabel;
    llEmail: TTntLabel;
    llStaff2: TTntLabel;
    btReadme: TTntButton;
    llThanks2: TTntLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imLogoClick(Sender: TObject);
    procedure TntFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btOkClick(Sender: TObject);
    procedure llURLClick(Sender: TObject);
    procedure llEmailClick(Sender: TObject);
    procedure btReadmeClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
		LogoBmp:TBitmap;

		procedure DrawLogo(Sender:TObject;var Done:Boolean);
  end;

var
  AboutForm: TAboutForm;

	// données pour l'effet
	CosTab:array[0..COSTAB_LENGTH-1] of Byte;

implementation

{$R *.dfm}

procedure TAboutForm.FormCreate(Sender: TObject);
var i:integer;
begin
  LocEngine.TranslateForm(Self);

	imLogo.Picture.Bitmap.PixelFormat:=pf32bit;

  // copie de l'image dans une autre
	LogoBmp:=TBitmap.Create;
	LogoBmp.Width:=256;
	LogoBmp.Height:=256;
	LogoBmp.Canvas.Draw(0,0,imLogo.Picture.Bitmap);
	LogoBmp.PixelFormat:=pf32bit;

	// on précalcule une petite table de cosinus
	for i:=0 to COSTAB_LENGTH-1 do CosTab[i]:=Round((Cos(i*2*Pi/COSTAB_LENGTH)+1)*255/2);

end;

procedure TAboutForm.TntFormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Release;
  AboutForm:=nil;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
	Application.OnIdle:=nil;
	LogoBmp.Free;
end;

procedure TAboutForm.imLogoClick(Sender: TObject);
begin
  Application.OnIdle:=DrawLogo;
end;

procedure TAboutForm.DrawLogo(Sender:TObject;var Done:Boolean);
var pi,po:PColor;
		t,n,n2,tn,y,x1,x2,x3,x4:integer;

	//TexLine: Dessine une ligne de texture entre les coordonnées xs et xe
	// 				 (dessinée uniquement si xs<xe, pour faire du hsr pour pas cher :)
	procedure TexLine(xs,xe:byte);
	var k,oo,oi:integer;
	begin
		// calcul de l'offset où on va dessiner dans le buffer de sortie
		oo:=y shl 10 + xs shl 2;

    // on boucle pour chaque pixel à dessiner
		for k:=0 to xe-xs-1 do
		begin
			// on calcule l'offset dans le buffer d'entrée correspondant au pixel
			oi:=(oo and $3FC00) or ( ( (k shl 8) div (xe-xs) ) shl 2);

			// on copie le pixel
			PColor(integer(po)+oo)^:=PColor(integer(pi)+oi)^;

			// on passe au pixel suivant
			Inc(oo,SizeOf(TColor));
		end;
	end;

begin
	Done:=True;
  t:=GetTickCount;
  Sleep(25); // 40fps max

	// on récupère des pointeurs sur les zones mémoires des images
	pi:=LogoBmp.ScanLine[LogoBmp.Height-1];
	po:=imLogo.Picture.Bitmap.ScanLine[imLogo.Picture.Bitmap.Height-1];

	// on efface l'img de sortie
	imLogo.Canvas.Brush.Color:=Color;
	imLogo.Canvas.FillRect(Rect(0,0,256,256));

	// on calule les offsets pour la ligne du haut et du bas
	n :=(CosTab[t            shr 1 and (COSTAB_LENGTH-1)]-128);
	n2:=(CosTab[Round(t/1.1) shr 1 and (COSTAB_LENGTH-1)]-128);

	for y:=0 to 255 do
	begin
		// on calcule l'offset pour la ligne par interpolaton linéaire de celui du haut et du bas
		tn:=( n*y + n2*(255-y)) shr 5;

		// on calcule les coordonnés des 4 points pour la ligne
		x1:=CosTab[(tn)                          and (COSTAB_LENGTH-1)];
		x2:=CosTab[(tn+Round(COSTAB_LENGTH*1/4)) and (COSTAB_LENGTH-1)];
		x3:=CosTab[(tn+Round(COSTAB_LENGTH*2/4)) and (COSTAB_LENGTH-1)];
		x4:=CosTab[(tn+Round(COSTAB_LENGTH*3/4)) and (COSTAB_LENGTH-1)];

		// dessin des lignes de texture entre les 4 points
		TexLine(x1,x2);
		TexLine(x2,x3);
		TexLine(x3,x4);
		TexLine(x4,x1);
	end;
end;

procedure TAboutForm.btOkClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.llURLClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(String(llURL.Caption)),'','',SW_SHOW);
end;

procedure TAboutForm.llEmailClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(String('mailto:'+llEmail.Caption+'?subject='+llName.Caption)),'','',SW_SHOW);
end;

procedure TAboutForm.btReadmeClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(String(ExtractFilePath(Application.ExeName)+btReadme.Caption)),'','',SW_SHOW);
end;

end.
