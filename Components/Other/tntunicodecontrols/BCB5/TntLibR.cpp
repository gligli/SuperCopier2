//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("TntLibR.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("..\TntClasses.pas");
USEUNIT("..\TntComCtrls.pas");
USEUNIT("..\TntControls.pas");
USEUNIT("..\TntForms.pas");
USEUNIT("..\TntGraphics.pas");
USEUNIT("..\TntMenus.pas");
USEUNIT("..\TntStdCtrls.pas");
USEUNIT("..\ActiveIMM_TLB.pas");
USEPACKAGE("Vclx50.bpi");
USEPACKAGE("VCLDB50.bpi");
USEUNIT("..\TntDBGrids.pas");
USEUNIT("..\TntDBCtrls.pas");
USEUNIT("..\TntDB.pas");
USEUNIT("..\TntActnList.pas");
USEUNIT("..\TntDBActns.pas");
USEUNIT("..\TntButtons.pas");
USEUNIT("..\TntAxCtrls.pas");
USEUNIT("..\TntClipBrd.pas");
USEUNIT("..\TntSysUtils.pas");
USEUNIT("..\TntTypInfo.pas");
USEUNIT("..\TntWindows.pas");
USEUNIT("..\TntRegistry.pas");
USEUNIT("..\TntDBLogDlg.pas");
USEUNIT("..\TntSystem.pas");
USEUNIT("..\TntCheckLst.pas");
USEUNIT("..\TntDialogs.pas");
USEUNIT("..\TntExtCtrls.pas");
USEUNIT("..\TntExtDlgs.pas");
USEUNIT("..\TntGrids.pas");
USEUNIT("..\TntStdActns.pas");
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
