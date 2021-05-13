#pragma once
#include <windows.h>

const WCHAR SC2_API_ID[]=L"SuperCopier2 API";
const WCHAR SC2_API_MUTEX_ID[]=L"Mutex";
const WCHAR SC2_API_FILEMAPPING_ID[]=L"FileMapping";
const WCHAR SC2_API_CLIENTEVENT_ID[]=L"ClientEvent";
const WCHAR SC2_API_APIEVENT_ID[]=L"APIEvent";

const int SC2_API_FILEMAPPING_SIZE=128*1024;

const int SC2_API_TIMEOUT=500; //ms

const int SC2_API_INVALID_HANDLE=-1;

typedef enum ApiErrorEnum {aeNone=0,aeBadHandle=1,aeWrongHandleType=2,aeEmptyBaseList=3,aeBadLocStringId=4} TApiError;

typedef enum ApiFunctionEnum {afNone=0,afObjectFree=1,afGetLastError=2,afErrorMessage=3,afObjectExists=4,afGetLocString=5,
  						      afNewBaseList=10,afBaselistAddItem=11,
							  afIsEnabled=20,afProcessBaseList=21,afIsSameVolumeMove=22,
							  afNewCopy=30,afCopyAddBaseList=31} TApiFunction;

typedef enum SeekOriginEnum {soFromBeginning=0,soFromCurrent=1,soFromEnd=2} TSeekOrigin;

typedef enum BaselistAddModeEnum {amDefaultDir=0,amSpecifyDest=1,amPromptForDest=2,amPromptForDestAndSetDefault=3} TBaselistAddMode;

class TFileMappingStream {
private:
    void * fFileMapping;
    int fSize;
	int fPosition;
public:
	TFileMappingStream(HANDLE aHandle,int aSize);
	virtual ~TFileMappingStream();

	void read(void * aBuffer,int aCount);
	void write(const void * aBuffer,int aCount);
	void seek(int aOffset,TSeekOrigin aOrigin);

    void writeInteger(int aValue);
    void writeWideString(const WCHAR * aValue);
	int readInteger();
    void readWideString(WCHAR * aValue,int aCount);
};

class TAPIClient {
private:
	HANDLE fMutex;
	HANDLE fFileMapping;
	HANDLE fClientEvent;
	HANDLE fAPIEvent;
	TFileMappingStream * fFileMappingStream;
	bool fConnected;
	TApiError fLastError;

	void retrieveLastError();

public:
	TAPIClient();
	virtual ~TAPIClient();

	void connect();
	void disconnect();
	bool isAPIAlive();

	void begin(TApiFunction aFuntion);
	void end();
	void sendAndWaitResult();

	TFileMappingStream * getFileMappingStream(){return fFileMappingStream;};
	bool getConnected(){return fConnected;};
	TApiError getLastError(){return fLastError;};
};

extern TAPIClient * APIClient;

void sessionUniqueAPIIdentifier(const WCHAR * aObject,WCHAR * aOutput,int aOutputCount);

//******************************************************************************
// Fonctions de l'API
//******************************************************************************

void SCObjectFree(int aHandle);
int SCGetLastError();
void SCErrorMessage(int aError,WCHAR * aOutput,int aOutputCount);
bool SCObjectExists(int aHandle);
void SCGetLocString(int aLocStringId,WCHAR * aOutput,int aOutputCount);

int SCNewBaseList();
void SCBaselistAddItem(int aBaseListHandle,WCHAR * aItemName);

bool SCIsEnabled();
int SCProcessBaseList(int aBaseListHandle,int aOperation,WCHAR * aDestDir);
bool SCIsSameVolumeMove(int aBaseListHandle,WCHAR * aDestDir);

int SCNewCopy(bool aIsMove);
void SCCopyAddBaseList(int aCopyHandle,int aBaseListHandle,int aMode,WCHAR * aDestDir);
