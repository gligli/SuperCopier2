// DDShellExt.h : Declaration of the CDDShellExt

#pragma once
#include "resource.h"       // main symbols
#include "shlobj.h"

// CDDShellExt

extern const CLSID CLSID_DDShellExt;

class ATL_NO_VTABLE CDDShellExt :
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CDDShellExt, &CLSID_DDShellExt>,
	public IShellExtInit,
    public IContextMenu
{
private:
	static int fBaselistHandle;
	bool fFromExplorer;
	WCHAR fDestDir[MAX_PATH]; 
public:
	BEGIN_COM_MAP(CDDShellExt)
		COM_INTERFACE_ENTRY(IShellExtInit)
        COM_INTERFACE_ENTRY(IContextMenu)
	END_COM_MAP()
 
    DECLARE_REGISTRY_RESOURCEID(IDR_SC2SHELLEXT)

	// IShellExtInit
	STDMETHODIMP Initialize(LPCITEMIDLIST, LPDATAOBJECT, HKEY);
  
	// IContextMenu
    STDMETHODIMP GetCommandString(UINT_PTR idCmd,UINT uFlags,UINT* pwReserved,LPSTR pszName,UINT cchMax){return E_NOTIMPL;};
    STDMETHODIMP InvokeCommand(LPCMINVOKECOMMANDINFO);
    STDMETHODIMP QueryContextMenu(HMENU,UINT,UINT,UINT,UINT);
};