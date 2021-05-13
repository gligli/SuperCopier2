// DDShellExt.cpp : Implementation of CDDShellExt

#include "stdafx.h"
#include "DDShellExt.h"
#include "SCApiClient.h"

bool isWinNT4(){
	OSVERSIONINFO version;

	version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);

	GetVersionEx(&version);

	return ((version.dwPlatformId==VER_PLATFORM_WIN32_NT) && (version.dwMajorVersion==4));
};


// CDDShellExt

#ifndef _M_X64
const CLSID CLSID_DDShellExt = {0x68D44A27,0xFFB6,0x4B89,{0xA3,0xE5,0x7B,0x0E,0x50,0xA7,0xAB,0x33}};
#else
const CLSID CLSID_DDShellExt = {0x68ff37c4,0x51bc,0x4c2a,{0xa9,0x92,0x7e,0x39,0xbc,0xe,0x70,0x6f}};
#endif

int CDDShellExt::fBaselistHandle=SC2_API_INVALID_HANDLE;

STDMETHODIMP CDDShellExt::Initialize(LPCITEMIDLIST pidlFolder,LPDATAOBJECT pDO,HKEY hProgID){

	APIClient->connect();
	if (!APIClient->getConnected())
		return	E_FAIL;

	if(!APIClient->isAPIAlive()){
		APIClient->disconnect();
		return	E_FAIL;
	}
	
	if(fBaselistHandle!=SC2_API_INVALID_HANDLE){
		SCObjectFree(fBaselistHandle);
		fBaselistHandle=SC2_API_INVALID_HANDLE;
	}

	FORMATETC fmt={CF_HDROP,NULL,DVASPECT_CONTENT,-1,TYMED_HGLOBAL};
	STGMEDIUM stg={TYMED_HGLOBAL};
	HDROP hDrop;
 
	fDestDir[0]=0;
	if (!SHGetPathFromIDList(pidlFolder,fDestDir))
		return E_FAIL;

	// Detect if it's explorer that started the operation by enumerating available
	// clipboard formats and searching for one that only explorer uses
	IEnumFORMATETC *en;
	FORMATETC fmt2;
	WCHAR fmtName[256]=L"\0";
	fFromExplorer=false;
	pDO->EnumFormatEtc(DATADIR_GET,&en);
	while(en->Next(1,&fmt2,NULL)==S_OK){
		GetClipboardFormatName(fmt2.cfFormat,fmtName,256);
		if (!wcscmp(fmtName,CFSTR_SHELLIDLIST)) fFromExplorer=true;
	}
	en->Release();

	// Look for CF_HDROP data in the data object. If there
	// is no such data, return an error back to Explorer.
	if (FAILED(pDO->GetData(&fmt,&stg)))
		return E_INVALIDARG;

	// Get a pointer to the actual data.
	hDrop=(HDROP)GlobalLock(stg.hGlobal);

	// Make sure it worked.
	if (hDrop==NULL)
		return E_INVALIDARG;

	UINT numFiles,i;
	WCHAR fn[MAX_PATH]=L"";

	numFiles=DragQueryFile(hDrop,0xFFFFFFFF,NULL,0);

	if(numFiles){
		fBaselistHandle=SCNewBaseList();

		for(i=0;i<numFiles;++i){
			if(DragQueryFile(hDrop,i,fn,MAX_PATH)){
				SCBaselistAddItem(fBaselistHandle,fn);
			}
		}
	}

	GlobalUnlock(stg.hGlobal);
	ReleaseStgMedium(&stg);

	return S_OK;
}

STDMETHODIMP CDDShellExt::QueryContextMenu(HMENU hmenu,UINT uMenuIndex,UINT uidFirstCmd,UINT uidLastCmd,UINT uFlags){
    // If the flags include CMF_DEFAULTONLY then we shouldn't do anything.
    if (uFlags&CMF_DEFAULTONLY)
        return MAKE_HRESULT(SEVERITY_SUCCESS,FACILITY_NULL,0);

	int cmd=uidFirstCmd;
	WCHAR ls[256];

	SCGetLocString(51,ls,sizeof(ls));
	InsertMenu(hmenu,uMenuIndex++,MF_STRING|MF_BYPOSITION,cmd++,ls);
	SCGetLocString(52,ls,sizeof(ls));
    InsertMenu(hmenu,uMenuIndex++,MF_STRING|MF_BYPOSITION,cmd++,ls);

	if (SCIsEnabled()){
		
		int defItem=GetMenuDefaultItem(hmenu,false,0);

		if (isWinNT4()){
			DeleteMenu(hmenu,1,MF_BYCOMMAND); // 1: Copy
			defItem=1;
		}
					  
		if (defItem==1){ // 1: Copy
			if (fFromExplorer) SetMenuDefaultItem(hmenu,uidFirstCmd+defItem-1,false); // don't handle external copies, fixes 7-Zip
		}else{
			if (defItem==2 && !SCIsSameVolumeMove(fBaselistHandle,fDestDir)) // 2: Move
				SetMenuDefaultItem(hmenu,uidFirstCmd+defItem-1,false);
		}
	}																	

	// Return 2 to tell the shell that we added 2 top-level menu items.
    return MAKE_HRESULT(SEVERITY_SUCCESS,FACILITY_NULL,2);
}

STDMETHODIMP CDDShellExt::InvokeCommand ( LPCMINVOKECOMMANDINFO pInfo ){

	if(HIWORD(pInfo->lpVerb))
		return E_INVALIDARG;
	
	switch(LOWORD(pInfo->lpVerb)){
		case 0:
			SCProcessBaseList(fBaselistHandle,FO_COPY,fDestDir);			
			fBaselistHandle=SC2_API_INVALID_HANDLE; // handle will be freed by SC2
			break;
		case 1:
			SCProcessBaseList(fBaselistHandle,FO_MOVE,fDestDir);			
			fBaselistHandle=SC2_API_INVALID_HANDLE; // handle will be freed by SC2
			break;
	}

	return S_OK;
}
