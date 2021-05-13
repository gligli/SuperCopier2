//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("TntLibD.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("..\Design\TntComCtrls_Design.pas");
USEUNIT("..\Design\TntDesignEditors_Design.pas");
USEUNIT("..\Design\TntForms_Design.pas");
USEUNIT("..\Design\TntMenus_Design.pas");
USEFORMNS("..\Design\TntStrEdit_Design.pas", Tntstredit_design, TntStrEditDlg);
USEUNIT("..\Design\TntDBGrids_Design.pas");
USEUNIT("..\Design\TntUnicodeVcl_Register.pas");
USERES("..\Design\TntActnlist.dcr");
USERES("..\Design\TntButtons.dcr");
USERES("..\Design\TntComCtrls.dcr");
USERES("..\Design\TntDBCtrls.dcr");
USERES("..\Design\TntExtCtrls.dcr");
USERES("..\Design\TntGrids.dcr");
USERES("..\Design\TntMenus.dcr");
USERES("..\Design\TntForms.dcr");
USERES("..\Design\TntStdCtrls.dcr");
USERES("..\Design\TntDialogs.dcr");
USERES("..\Design\TntExtDlgs.dcr");
USEPACKAGE("TntLibR.bpi");
USEPACKAGE("dsnide50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("dcldb50.bpi");
USEPACKAGE("dclstd50.bpi");
USEPACKAGE("vclx50.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
    return 1;
}
//---------------------------------------------------------------------------
