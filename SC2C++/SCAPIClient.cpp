#include "stdafx.h"
#include "SCAPIClient.h"


//******************************************************************************
// TFileMappingStream
//******************************************************************************

TFileMappingStream::TFileMappingStream(HANDLE aHandle,int aSize){
	fFileMapping=NULL;
	if (aHandle)
		fFileMapping=MapViewOfFile(aHandle,FILE_MAP_ALL_ACCESS,0,0,aSize);
	
	_ASSERT(fFileMapping);

	fPosition=0;
	fSize=aSize;
};

TFileMappingStream::~TFileMappingStream(){
	UnmapViewOfFile(fFileMapping);
};

void TFileMappingStream::read(void * aBuffer,int aCount){
	int endPos=fPosition+aCount;
	_ASSERT((aCount>=0) && (endPos<=fSize));
	memcpy(aBuffer,(unsigned char *)fFileMapping+fPosition,aCount);
	fPosition=endPos;
};

void TFileMappingStream::write(const void * aBuffer,int aCount){
	int endPos=fPosition+aCount;
	_ASSERT((aCount>=0) && (endPos<=fSize));
	memcpy((unsigned char *)fFileMapping+fPosition,aBuffer,aCount);
	fPosition=endPos;
};

void TFileMappingStream::seek(int aOffset,TSeekOrigin aOrigin){
	switch(aOrigin){
		case soFromBeginning:
			fPosition=aOffset;
			break;
		case soFromCurrent:
			fPosition+=aOffset;
			break;
		case soFromEnd:
			fPosition=fSize+aOffset;
			break;
	}
	_ASSERT((fPosition>=0) && (fPosition<=fSize));
};

void TFileMappingStream::writeInteger(int aValue){
	write(&aValue,sizeof(aValue));
};

void TFileMappingStream::writeWideString(const WCHAR * aValue){
	int len=(int)wcslen(aValue);
	writeInteger(len);
	write(aValue,len*sizeof(WCHAR));
};

int TFileMappingStream::readInteger(){
	int result;
	read(&result,sizeof(result));
	return result;
};

void TFileMappingStream::readWideString(WCHAR * aValue,int aCount){
	int len=readInteger();
	_ASSERT(len<aCount);
	read(aValue,len*sizeof(WCHAR));
	aValue[len]=0;
};

//******************************************************************************
// TAPIClient
//******************************************************************************

TAPIClient * APIClient=NULL;

TAPIClient::TAPIClient(){
	fMutex=0;
	fFileMapping=0;
	fClientEvent=0;
	fAPIEvent=0;
	fFileMappingStream=NULL;
	fConnected=false;
	fLastError=aeNone;
};

TAPIClient::~TAPIClient(){
	disconnect();
};

void TAPIClient::connect(){
	if (fConnected)
		return;

	WCHAR name[MAX_PATH];

	sessionUniqueAPIIdentifier(SC2_API_MUTEX_ID,name,MAX_PATH);
	fMutex=OpenMutex(MUTEX_ALL_ACCESS,false,name);
	if (!fMutex) 
		return;

	sessionUniqueAPIIdentifier(SC2_API_FILEMAPPING_ID,name,MAX_PATH);
	fFileMapping=OpenFileMapping(FILE_MAP_ALL_ACCESS,false,name);
	if (!fFileMapping){
		CloseHandle(fMutex);	
		return;
	}

	sessionUniqueAPIIdentifier(SC2_API_CLIENTEVENT_ID,name,MAX_PATH);
	fClientEvent=OpenEvent(EVENT_ALL_ACCESS,false,name);
	if (!fClientEvent){
		CloseHandle(fMutex);	
		CloseHandle(fFileMapping);	
		return;
	}

	sessionUniqueAPIIdentifier(SC2_API_APIEVENT_ID,name,MAX_PATH);
	fAPIEvent=OpenEvent(EVENT_ALL_ACCESS,false,name);
	if (!fAPIEvent){
		CloseHandle(fMutex);	
		CloseHandle(fFileMapping);	
		CloseHandle(fClientEvent);	
		return;
	}

	fFileMappingStream=new TFileMappingStream(fFileMapping,SC2_API_FILEMAPPING_SIZE);

	fLastError=aeNone;

	fConnected=true;
};

void TAPIClient::disconnect(){
	if (!fConnected) return;
	
	if (fFileMappingStream) delete fFileMappingStream;
	if (fMutex) CloseHandle(fMutex);
	if (fFileMapping) CloseHandle(fFileMapping);
	if (fClientEvent) CloseHandle(fClientEvent);
	if (fAPIEvent) CloseHandle(fAPIEvent);
	
	fMutex=0;
	fFileMapping=0;
	fClientEvent=0;
	fAPIEvent=0;
	fFileMappingStream=NULL;

	fConnected=false;
};

bool TAPIClient::isAPIAlive(){
	bool result=true;
	
	begin(afNone);
	 SetEvent(fClientEvent);
	if (WaitForSingleObject(fAPIEvent,SC2_API_TIMEOUT)==WAIT_TIMEOUT){
		ResetEvent(fClientEvent);
		result=false;
	}
	ReleaseMutex(fMutex);

	return result;
};

void TAPIClient::begin(TApiFunction aFuntion){
	WaitForSingleObject(fMutex,INFINITE);

	fFileMappingStream->seek(0,soFromBeginning);
	fFileMappingStream->writeInteger(aFuntion);
};

void TAPIClient::end(){
  	retrieveLastError();
	ReleaseMutex(fMutex);
};

void TAPIClient::sendAndWaitResult(){
	SetEvent(fClientEvent);
	WaitForSingleObject(fAPIEvent,INFINITE);

	fFileMappingStream->seek(0,soFromBeginning);
};

void TAPIClient::retrieveLastError(){
	fFileMappingStream->seek(0,soFromBeginning);
	fFileMappingStream->writeInteger(afGetLastError);
	sendAndWaitResult();
	fLastError=(TApiError)fFileMappingStream->readInteger();
};

//******************************************************************************

void sessionUniqueAPIIdentifier(const WCHAR * aObject,WCHAR * aOutput,int aOutputCount){
	WCHAR * userName;
    DWORD size;

	_ASSERT(aOutputCount>0);
	aOutput[0]=0;
	userName=NULL;
	size=0;

	if (GetUserName(NULL,&size) || (GetLastError()!=ERROR_INSUFFICIENT_BUFFER))
		return;

	userName=new WCHAR[size];

	if (GetUserName(userName,&size)){
		wcscat_s(aOutput,aOutputCount,SC2_API_ID);
		wcscat_s(aOutput,aOutputCount,L" ");
		wcscat_s(aOutput,aOutputCount,aObject);
		wcscat_s(aOutput,aOutputCount,L" ");
		wcscat_s(aOutput,aOutputCount,userName);
	}
	
	delete[] userName;
};

//******************************************************************************
// Fonctions de l'API
//******************************************************************************

void SCObjectFree(int aHandle){
	APIClient->begin(afObjectFree);
	APIClient->getFileMappingStream()->writeInteger(aHandle);
	APIClient->sendAndWaitResult();
	APIClient->end();
}

int SCGetLastError(){
	// je n'appelle pas directement le afGetLastError car le code d'erreur est partagé entre tous les clients connectés côté SC
	// le problême est contourné en appelant afGetLastError pendant le end() et en stockant le code d'erreur
	return APIClient->getLastError();
}

void SCErrorMessage(int aError,WCHAR * aOutput,int aOutputCount){
	APIClient->begin(afErrorMessage);
	APIClient->getFileMappingStream()->writeInteger(aError);
	APIClient->sendAndWaitResult();
	APIClient->getFileMappingStream()->readWideString(aOutput,aOutputCount);
	APIClient->end();
};

bool SCObjectExists(int aHandle){
	bool result;
	
	APIClient->begin(afObjectExists);
	APIClient->getFileMappingStream()->writeInteger(aHandle);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger()!=0;
	APIClient->end();

	return result;
};

void SCGetLocString(int aLocStringId,WCHAR * aOutput,int aOutputCount){
	APIClient->begin(afGetLocString);
	APIClient->getFileMappingStream()->writeInteger(aLocStringId);
	APIClient->sendAndWaitResult();
	APIClient->getFileMappingStream()->readWideString(aOutput,aOutputCount);
	APIClient->end();
};

int SCNewBaseList(){
	int result;
	
	APIClient->begin(afNewBaseList);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger();
	APIClient->end();

	return result;
};

void SCBaselistAddItem(int aBaseListHandle,WCHAR * aItemName){
	APIClient->begin(afBaselistAddItem);
	APIClient->getFileMappingStream()->writeInteger(aBaseListHandle);
	APIClient->getFileMappingStream()->writeWideString(aItemName);
	APIClient->sendAndWaitResult();
	APIClient->end();
};

bool SCIsEnabled(){
	bool result;
	
	APIClient->begin(afIsEnabled);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger()!=0;
	APIClient->end();

	return result;
};

int SCProcessBaseList(int aBaseListHandle,int aOperation,WCHAR * aDestDir){
	int result;
	
	APIClient->begin(afProcessBaseList);
	APIClient->getFileMappingStream()->writeInteger(aBaseListHandle);
	APIClient->getFileMappingStream()->writeInteger(aOperation);
	APIClient->getFileMappingStream()->writeWideString(aDestDir);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger();
	APIClient->end();

	return result;
};

bool SCIsSameVolumeMove(int aBaseListHandle,WCHAR * aDestDir){
	bool result;
	
	APIClient->begin(afIsSameVolumeMove);
	APIClient->getFileMappingStream()->writeInteger(aBaseListHandle);
	APIClient->getFileMappingStream()->writeWideString(aDestDir);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger()!=0;
	APIClient->end();

	return result;
};

int SCNewCopy(bool aIsMove){
	int result;
	
	APIClient->begin(afNewCopy);
	APIClient->getFileMappingStream()->writeInteger(aIsMove?-1:0);
	APIClient->sendAndWaitResult();
	result=APIClient->getFileMappingStream()->readInteger();
	APIClient->end();

	return result;
};

void SCCopyAddBaseList(int aCopyHandle,int aBaseListHandle,int aMode,WCHAR * aDestDir){
	APIClient->begin(afCopyAddBaseList);
	APIClient->getFileMappingStream()->writeInteger(aCopyHandle);
	APIClient->getFileMappingStream()->writeInteger(aBaseListHandle);
	APIClient->getFileMappingStream()->writeInteger(aMode);
	APIClient->getFileMappingStream()->writeWideString(aDestDir);
	APIClient->sendAndWaitResult();
	APIClient->end();
};
