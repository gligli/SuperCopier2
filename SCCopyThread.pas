unit SCCopyThread;

interface

uses
  Windows,Commctrl,Classes,SCObjectThreadList,SCWorkThread,SCWorkThreadList,SCCopier,SCCommon,
  SCConfig,SCBaseList,SCDirList,SCCopyForm,SCDiskSpaceForm,SCCollisionForm,SCCopyErrorForm,Forms;

type
  TCopyThread=class(TWorkThread)
  private
    Copier:TCopier;

    WaitingBaseList:TBaseList;
    WaitingBaseListDestDir:WideString;

    FDefaultDir,SrcDir:WideString;
    FIsMove:Boolean;

    // variables pour la copie
    LastCopyWindowUpdate:Integer;

    LastCopiedSize:Int64;
    NumSamples,CurrentSample:Integer;
    SpeedSamples:array of integer;
    CopySpeed:Integer;

    ThrottleLastTime:Integer;
    ThrottleLastCopiedSize:Int64;

    LastCopyErrorFile:WideString;

    Sync:record
      Copy:record
        Form:TCopyForm;
        Action:TCopyWindowAction;
        State:TCopyWindowState;
        ConfigData:TCopyWindowConfigData;
        ConfigDataModifiedByThread:Boolean; // mettre a true si la config doit être copiée de la thread vers la fenêtre
        lvErrorListEmpty:Boolean;


        llFromCaption,
        llToCaption,
        llFileCaption,
        llAllCaption,
        llSpeedCaption:WideString;
        ggFileProgress,ggFileMax,
        ggAllProgress,ggAllMax:Int64;
        ggAllRemaining,ggFileRemaining:WideString;
        Error:record
          Time:TDateTime;
          Action,Target,ErrorText:WideString;
        end;
      end;
      DiskSpace:record
        Form:TDiskSpaceForm;
        Volumes:TDiskSpaceWarningVolumeArray;
        Action:TDiskSpaceAction;
      end;
      Collision:record
        Form:TCollisionForm;
        Action:TCollisionAction;
        SameForNext:Boolean;
        FileName:WideString;
        CustomRename:Boolean;
      end;
      CopyError:record
        Form:TCopyErrorForm;
        ErrorText:WideString;
        Action:TCopyErrorAction;
        SameForNext:Boolean;
      end;
    end;

    function CopierFileCollision(var NewName:WideString):TCollisionAction;
    function CopierDiskSpaceWarning(Volumes:TDiskSpaceWarningVolumeArray):Boolean;
    function CopierCopyError(ErrorText:WideString):TCopyErrorAction;
    procedure CopierGenericError(Action,Target,ErrorText:WideString);
    function CopierCopyProgress:Boolean;
    function CopierRecurseProgress(CurrentItem:TDirItem):Boolean;

    //Copy
    procedure SyncInitCopy;
    procedure SyncEndCopy;
    procedure SyncUpdateCopy;
    procedure SyncSetFileListviewCount;
    procedure SyncUpdateFileListview;
    procedure SyncAddToErrorLog;
    procedure SyncSaveErrorLog;

    //DiskSpace
    procedure SyncInitDiskSpace;
    procedure SyncEndDiskSpace;
    procedure SyncCheckDiskSpace;

    //Collision
    procedure SyncInitCollision;
    procedure SyncEndCollision;
    procedure SyncCheckCollision;

    //CopyError
    procedure SyncInitCopyError;
    procedure SyncEndCopyError;
    procedure SyncCheckCopyError;

  protected
    function GetDisplayName:WideString;override;
    procedure Execute;override;
  public
    property IsMove:boolean read FIsMove;
    property DefaultDir:WideString read FDefaultDir;

    constructor Create(PIsMove:Boolean);
    destructor Destroy;override;

    function CanHandle(pSrcDir,pDestDir:WideString):boolean;
    procedure AddBaseList(BaseList:TBaseList;AddMode:TBaselistAddMode=amDefaultDir;Dir:WideString='');
    function CheckWaitingBaseList:Boolean;
    function LockCopier:TCopier;
    procedure UnlockCopier;
    procedure UpdateCopyWindow;
  published
    property Handle;
  end;


implementation

uses SysUtils,TntSysUtils,FileCtrl,SCLocStrings, TntComCtrls,
  SCFileList, StrUtils, MaskUtils;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TCopyThread: thread de copie de fichiers, gère la fenètre de copie,
//              les synchros, délègue la copie au Copier et gère ses évènements
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// Create
//******************************************************************************
constructor TCopyThread.Create(PIsMove:Boolean);
begin
  inherited Create;
  FreeOnTerminate:=True;
  FThreadType:=wttCopy;

  Copier:=TAnsiBufferedCopier.Create; //TODO: choisir le copier en fonction de l'os et de la config
  Copier.BufferSize:=Config.Values.CopyBufferSize;

  WaitingBaseList:=nil;
  FDefaultDir:='?';
  SrcDir:='?';
  FIsMove:=PIsMove;
  LastCopyErrorFile:='';

  NumSamples:=Config.Values.CopySpeedAveragingInterval div Config.Values.CopyWindowUpdateInterval;
  SetLength(SpeedSamples,NumSamples);

  // évènements du copier
  Copier.OnFileCollision:=CopierFileCollision;
  Copier.OnDiskSpaceWarning:=CopierDiskSpaceWarning;
  Copier.OnCopyError:=CopierCopyError;
  Copier.OnGenericError:=CopierGenericError;
  Copier.OnCopyProgress:=CopierCopyProgress;
  Copier.OnRecurseProgress:=CopierRecurseProgress;

  // création de la fenêtre
  Synchronize(SyncInitCopy);

  // tout est initialisé, on peut lancer la thread
  Resume;
end;

//******************************************************************************
// Destroy
//******************************************************************************
destructor TCopyThread.Destroy;
begin
  // sauvegarde automatique du log des erreurs
  if Config.Values.ErrorLogAutoSave then Synchronize(SyncSaveErrorLog);

  // destruction de la fenêtre
  Synchronize(SyncEndCopy);

  Copier.Free;

  SetLength(SpeedSamples,0);

  inherited Destroy;
end;

//******************************************************************************
// GetDisplayName: implémentation de TWorkThread.GetDisplayName
//******************************************************************************
function TCopyThread.GetDisplayName:WideString;
begin
  if FIsMove then
    Result:=Format(lsMoveDisplayName,[SrcDir,FDefaultDir])
  else
    Result:=Format(lsCopyDisplayName,[SrcDir,FDefaultDir]);
end;

//******************************************************************************
// CanHandle: retourne true si le mode de playlist permets a la thread de
//            prendre en charge la copie
//******************************************************************************
function TCopyThread.CanHandle(pSrcDir,pDestDir:WideString):boolean;
var SameSource,SameDest:Boolean;
begin
  Result:=False;
  SameSource:=SamePhysicalDrive(pSrcDir,SrcDir);
  SameDest:=SamePhysicalDrive(pDestDir,DefaultDir);

  case Config.Values.CopyListHandlingMode of
    chmAlways:
      Result:=True;
    chmSameSource:
      Result:=SameSource;
    chmSameDestination:
      Result:=SameDest;
    chmSameSourceAndDestination:
      Result:=SameSource and SameDest;
    chmSameSourceorDestination:
      Result:=SameSource or SameDest;
  end;

  if Config.Values.CopyListHandlingConfirm then
  begin
    Result:=MessageBoxW(Application.Handle,PWideChar(lsConfirmCopylistAdd),PWideChar(DisplayName),MB_YESNO)=IDYES;
  end;
end;

//******************************************************************************
// AddBaseList: ajoute une baselist de fichiers à copier
//******************************************************************************
procedure TCopyThread.AddBaseList(BaseList:TBaseList;AddMode:TBaselistAddMode=amDefaultDir;Dir:WideString='');
var DestDir:WideString;
    AddOk:Boolean;
begin
  AddOk:=True;
  case AddMode of
    amDefaultDir:
    begin
      Assert(FDefaultDir<>'','No DefaultDir');
      DestDir:=FDefaultDir;
    end;
    amSpecifyDest:
    begin
      Assert(Dir<>'','No DestDir given');
      DestDir:=Dir;
    end;
    amPromptForDest,
    amPromptForDestAndSetDefault:
    begin
      DestDir:=FDefaultDir;
      AddOk:=BrowseForFolder(lsChooseDestDir,DestDir);

      if (AddMode=amPromptForDestAndSetDefault) and AddOk then FDefaultDir:=DestDir;
    end;
  end;

  if AddOk then
  begin
    dbgln('AddBaseList DestDir='+DestDir);

    // le premier appel a AddBaseList déterminera le répertoire par défaut
    if FDefaultDir='?' then
    begin
      FDefaultDir:=WideIncludeTrailingBackslash(DestDir);
      SrcDir:=WideExtractFilePath(BaseList[0].SrcName);
    end;

    // on attends si la précédente baselist n'a pas encore été traitée
    // (ca va freezer la thread principale, mais le cas ne devrait de présenter que très rarement)
    while WaitingBaseList<>nil do
    begin
      Application.ProcessMessages;
      Sleep(DEFAULT_WAIT);
    end;

    WaitingBaseList:=BaseList;
    WaitingBaseListDestDir:=DestDir;
  end
  else
  begin
    // libérer la baselist
    BaseList.Free;
  end;
end;

//******************************************************************************
// CheckWaitingBaseList: teste si une BaseList est en attente, si oui la BL est
//                       traitée et la fonction renvoie true;
//******************************************************************************
function TCopyThread.CheckWaitingBaseList:Boolean;
begin
  Result:=False;

  if Assigned(WaitingBaseList) and (WaitingBaseList.Count>0) then
  begin
    Result:=True;

    // on ajoute les fichiers au copier
    Copier.AddBaseList(WaitingBaseList,WaitingBaseListDestDir);

    // on vérifie si il y a assez de place
    Copier.VerifyFreeSpace;

    // on a ajouté des fichiers, màj de lvFileList
    Synchronize(SyncSetFileListviewCount);

    WaitingBaseList:=nil;
  end;
end;

//******************************************************************************
// LockCopier: bloque les données du copier et renvoie sa référence
//******************************************************************************
function TCopyThread.LockCopier:TCopier;
begin
  Copier.FileList.Lock;
  Copier.DirList.Lock;

  Result:=Copier;
end;

//******************************************************************************
// UnlockCopier: débloque les données du copier
//******************************************************************************
procedure TCopyThread.UnlockCopier;
begin
  Copier.FileList.Unlock;
  Copier.DirList.Unlock;
end;

//******************************************************************************
// Execute: corps de la thread, sers de chef d'orchestre pour le copier
//******************************************************************************
procedure TCopyThread.Execute;
begin
  repeat
    // attendre les données
    while (not CheckWaitingBaseList) and (Copier.FileList.Count=0) and (Sync.Copy.Action<>cwaCancel) do
    begin
      Synchronize(SyncUpdateCopy);
      Sleep(DEFAULT_WAIT);
    end;

    // init des veriables servant a calculer la vitesse
    LastCopyWindowUpdate:=GetTickCount;
    LastCopiedSize:=Copier.CopiedSize;
    CurrentSample:=-1;
    CopySpeed:=0;

    ThrottleLastTime:=GetTickCount;
    ThrottleLastCopiedSize:=Copier.CopiedSize;

    if Copier.FirstCopy then
    begin
      dbgln('Copy Start');

      // boucle principale
      repeat
        // vérifier si il y a une baselist en attente
        CheckWaitingBaseList;

        // màj de lvFileItems
        Synchronize(SyncUpdateFileListview);

        // màj de la fenêtre
        Sync.Copy.State:=cwsCopying;
        UpdateCopyWindow;

        if Copier.ManageFileAction then
        begin
//          dbgln('Copying: '+Copier.CurrentCopy.FileItem.SrcFullName);
//          dbgln('      -> '+Copier.CurrentCopy.FileItem.DestFullName);

          Copier.CurrentCopy.DirItem.VerifyOrCreate;

          if Copier.DoCopy then
          begin
            Copier.CopyAttributes; //TODO: a gérer en fonction de ismove et de la config

            if FIsMove then Copier.DeleteSrcFile;
          end;
        end;

      until not Copier.NextCopy;

      dbgln('Copy End');
    end;

    if Copier.CurrentCopy.NextAction<>cpaCancel then
    begin
      Copier.CreateEmptyDirs;

      if FIsMove then Copier.DeleteSrcDirs;
    end;

  // on boucle tant que la fenêtre de copie doit rester ouverte
  until (Sync.Copy.Action=cwaCancel) or (Copier.CurrentCopy.NextAction=cpaCancel) or
        (Sync.Copy.ConfigData.CopyEndAction=cweClose) or
        ((Sync.Copy.ConfigData.CopyEndAction=cweDontCloseIfErrors) and Sync.Copy.lvErrorListEmpty);

  WorkThreadList.Remove(Self); // dé-rescencer la thread
end;

//******************************************************************************
//******************************************************************************
// Evenèments du copier
//******************************************************************************
//******************************************************************************

//******************************************************************************
// CopierFileCollision: evenement du copier
//******************************************************************************
function TCopyThread.CopierFileCollision(var NewName:WideString):TCollisionAction;
begin
  dbgln('CopierFileCollision');

  with Sync.Collision do
  begin
    if Sync.Copy.ConfigData.CollisionAction=claNone then // aucune action automatique choisie?
    begin
      FileName:=Copier.CurrentCopy.FileItem.DestName;

      Synchronize(SyncInitCollision);

      while Action=claNone do
      begin
        Synchronize(SyncCheckCollision);
        Sleep(DEFAULT_WAIT);
      end;

      Synchronize(SyncEndCollision);

      Result:=Action;

      if SameForNext then
      begin
        Sync.Copy.ConfigDataModifiedByThread:=True;
        Sync.Copy.ConfigData.CollisionAction:=Action;
      end;
    end
    else
    begin
      Result:=Sync.Copy.ConfigData.CollisionAction;
    end;

    // récupérer le nouveau nom pour le fichier si renommage
    if Result in [claRenameNew,claRenameOld] then
    begin
      if CustomRename then
      begin
        NewName:=FileName;
      end
      else
      begin
        // on renomme en fonction du pattern choisi dans la config
        if Result=claRenameNew then
          NewName:=PatternRename(Copier.CurrentCopy.FileItem.DestName,Copier.CurrentCopy.DirItem.Destpath,Config.Values.RenameNewPattern)
        else
          NewName:=PatternRename(Copier.CurrentCopy.FileItem.DestName,Copier.CurrentCopy.DirItem.Destpath,Config.Values.RenameOldPattern);
      end;
    end;
  end;
end;

//******************************************************************************
// CopierDiskSpaceWarning: evenement du copier
//******************************************************************************
function TCopyThread.CopierDiskSpaceWarning(Volumes:TDiskSpaceWarningVolumeArray):Boolean;
begin
  dbgln('CopierDiskSpaceWarning');

  Sync.DiskSpace.Volumes:=Volumes;
  Synchronize(SyncInitDiskSpace);

  while Sync.DiskSpace.Action=dsaNone do
  begin
    Synchronize(SyncCheckDiskSpace);
    Sleep(DEFAULT_WAIT);
  end;

  Synchronize(SyncEndDiskSpace);

  Result:=Sync.DiskSpace.Action=dsaForce;
end;

//******************************************************************************
// CopierCopyError: evenement du copier
//******************************************************************************
function TCopyThread.CopierCopyError(ErrorText:WideString):TCopyErrorAction;
begin
  dbgln('CopierCopyError: '+ErrorText);

  // ajout de l'erreur à la liste des erreurs
  with Sync.Copy do
  begin
    Error.Time:=Now;
    Error.Action:=lsCopyAction;
    Error.Target:=Copier.CurrentCopy.FileItem.SrcFullName;
    Error.ErrorText:=ErrorText;
  end;

  Synchronize(SyncAddToErrorLog);

  //gestion de l'erreur
  Sync.CopyError.ErrorText:=ErrorText;
  with Sync.CopyError do
  begin
    if Sync.Copy.ConfigData.CopyErrorAction=ceaNone then // aucune action automatique choisie?
    begin
      Synchronize(SyncInitCopyError);

      while Action=ceaNone do
      begin
        Synchronize(SyncCheckCopyError);
        Sleep(DEFAULT_WAIT);
      end;

      Synchronize(SyncEndCopyError);

      Result:=Action;

      if SameForNext then
      begin
        Sync.Copy.ConfigDataModifiedByThread:=True;
        Sync.Copy.ConfigData.CopyErrorAction:=Action;
      end;
    end
    else
    begin
      // attendre un certain temps entre 2 erreurs de copie sur un même fichier
      if Copier.CurrentCopy.FileItem.DestFullName=LastCopyErrorFile then
      begin
        Sleep(Config.Values.CopyErrorRetryInterval);
      end;

      Result:=Sync.Copy.ConfigData.CopyErrorAction;
    end;
  end;

  LastCopyErrorFile:=Copier.CurrentCopy.FileItem.DestFullName;
end;

//******************************************************************************
// CopierGenericError: evenement du copier
//******************************************************************************
procedure TCopyThread.CopierGenericError(Action,Target,ErrorText:WideString);
begin
  dbgln('CopierGenericError: '+Action+' '+ErrorText+' '+Target);

  Sync.Copy.Error.Time:=Now;
  Sync.Copy.Error.Action:=Action;
  Sync.Copy.Error.Target:=Target;
  Sync.Copy.Error.ErrorText:=ErrorText;

  Synchronize(SyncAddToErrorLog);
end;

//******************************************************************************
// CopierCopyProgress: evenement du copier
//                     renvoyer false pour annuler la copie en cours
//******************************************************************************
function TCopyThread.CopierCopyProgress:Boolean;
var CurTime:Integer;
    ThrottleTime:Integer;
    DataSizeForThrottleTime:Int64;

  //ComputeCopySpeed: calcul de la vitesse de copie
  procedure ComputeCopySpeed;
  var TempCopySpeed,TempCopyTime:integer;
      Total:Int64;
      i:Integer;
  begin
    // calcul de la vitesse instantanée
    TempCopyTime:=CurTime-LastCopyWindowUpdate;

    if TempCopyTime<>0 then
      TempCopySpeed:=Round((Copier.CopiedSize-LastCopiedSize) * MSecsPerSec / TempCopyTime)
    else
      TempCopySpeed:=0;

    LastCopiedSize:=Copier.CopiedSize;

    if CurrentSample=-1 then // premier calcul de vitesse?
    begin
      // on remplit la liste des samples avec la valeur instantanée
      for i:=0 to NumSamples-1 do
        SpeedSamples[i]:=TempCopySpeed;

      CurrentSample:=0;
    end
    else
    begin
      // ajout à la liste des précédentes vitesses
      CurrentSample:=(CurrentSample+1) mod NumSamples;
      SpeedSamples[CurrentSample]:=TempCopySpeed;
    end;


    // on fait la moyenne pour avoir la vitesse à afficher
    Total:=0;
    for i:=0 to NumSamples-1 do
      Total:=Total+SpeedSamples[i];
    CopySpeed:=Total div NumSamples;
  end;

  //ComputeThrottleCopySpeed: calcul de la vitesse de copie lorsque la limitation de vitesse est activée
  //                          (vitesse instantanée sur l'intervale de throttle)
  procedure ComputeThrottleCopySpeed;
  var TempCopyTime:Integer;
  begin
    TempCopyTime:=CurTime-ThrottleLastTime;

    if TempCopyTime<>0 then
      CopySpeed:=Round((Copier.CopiedSize-ThrottleLastCopiedSize) * MSecsPerSec / TempCopyTime)
    else
      CopySpeed:=0;
  end;

begin
  // vérifier si il y a une baselist en attente
  CheckWaitingBaseList;

  CurTime:=GetTickCount;

  Sync.Copy.State:=cwsCopying;

  if not Sync.Copy.ConfigData.ThrottleEnabled then
  begin
    // màj de la fenêtre si nécesaire
    if CurTime>=(LastCopyWindowUpdate+Config.Values.CopyWindowUpdateInterval) then
    begin
      ComputeCopySpeed;

      UpdateCopyWindow;

      LastCopyWindowUpdate:=CurTime;
    end;
  end
  else
  begin
    // gestion limitation de vitesse
    DataSizeForThrottleTime:=Int64(Sync.Copy.ConfigData.ThrottleSpeedLimit)*1024*Config.Values.CopyThrottleInterval div MSecsPerSec;

    if Copier.CopiedSize>=(ThrottleLastCopiedSize+DataSizeForThrottleTime) then
    begin
      ThrottleTime:=Config.Values.CopyThrottleInterval-(CurTime-ThrottleLastTime);

      if ThrottleTime>0 then Sleep(ThrottleTime);

      CurTime:=GetTickCount;

      ComputeThrottleCopySpeed;

      UpdateCopyWindow;

      ThrottleLastTime:=CurTime;
      ThrottleLastCopiedSize:=Copier.CopiedSize;
    end;
  end;

  // gestion de la pause
  if Sync.Copy.Action=cwaPause then
  begin
    Sync.Copy.State:=cwsPaused;

    while Sync.Copy.State=cwsPaused do
    begin
      CheckWaitingBaseList;
      UpdateCopyWindow;

      if Sync.Copy.Action<>cwaNone then
        Sync.Copy.State:=cwsCopying
      else
        Sync.Copy.State:=cwsPaused;

      Sleep(DEFAULT_WAIT);
    end;
  end;

  // gestion Skip/Cancel
  Result:=not (Sync.Copy.Action in [cwaSkip,cwaCancel]);
end;

//******************************************************************************
// CopierRecurseProgress: evenement du copier
//                        renvoyer false pour annuler la récursion
//******************************************************************************
function TCopyThread.CopierRecurseProgress(CurrentItem:TDirItem):Boolean;
begin
  Sync.Copy.llAllCaption:=lsCreatingCopyList;
  Sync.Copy.llFileCaption:=CurrentItem.SrcPath;
  Sync.Copy.State:=cwsRecursing;

  Synchronize(SyncUpdateCopy);

  Result:=Sync.Copy.Action<>cwaCancel;
end;

//******************************************************************************
// UpdateCopyWindow: màj des infos de la fenêtre de copie
//******************************************************************************
procedure TCopyThread.UpdateCopyWindow;
var TmpStr:String;
    AllRemaining,FileRemaining:TDateTime;

  //ComputeRemainingTime: calcul du temps restant
  procedure ComputeRemainingTime;
  begin
    if CopySpeed<>0 then
      with Copier do
      begin
        AllRemaining:=(FileList.TotalSize-CopiedSize-SkippedSize)/CopySpeed/SecsPerDay;
        FileRemaining:=(CurrentCopy.FileItem.SrcSize-CurrentCopy.CopiedSize-CurrentCopy.SkippedSize)/CopySpeed/SecsPerDay;
      end;
  end;

begin
  if Assigned(Copier.CurrentCopy.FileItem) then
  begin
    ComputeRemainingTime;

    with Sync.Copy,Copier do
    begin
      llFromCaption:=CurrentCopy.DirItem.SrcPath;
      llToCaption:=CurrentCopy.DirItem.Destpath;

      llAllCaption:=WideFormat(lsAll,[CopiedCount+1,FileList.TotalCount,SizeToString(FileList.TotalSize)]);
      llFileCaption:=WideFormat(lsFile,[CurrentCopy.FileItem.SrcName,SizeToString(CurrentCopy.FileItem.SrcSize)]);

      ggFileProgress:=CurrentCopy.CopiedSize+CurrentCopy.SkippedSize;
      ggFileMax:=CurrentCopy.FileItem.SrcSize;
      ggAllProgress:=CopiedSize+SkippedSize;
      ggAllMax:=FileList.TotalSize;

      llSpeedCaption:=WideFormat(lsSpeed,[CopySpeed div 1024]);

      DateTimeToString(TmpStr,'hh:nn:ss',AllRemaining);
      ggAllRemaining:=WideFormat(lsRemaining,[TmpStr]);

      DateTimeToString(TmpStr,'hh:nn:ss',FileRemaining);
      ggFileRemaining:=WideFormat(lsRemaining,[TmpStr]);
    end;
  end;

  Synchronize(SyncUpdateCopy);

  if Sync.Copy.Action=cwaCancel then Copier.CurrentCopy.NextAction:=cpaCancel; // gestion de l'annulation
end;

//******************************************************************************
//******************************************************************************
// Méthodes de synchro
//******************************************************************************
//******************************************************************************

//******************************************************************************
// SyncInitCopy: création et initialisation de la fenêtre de copie
//******************************************************************************
procedure TCopyThread.SyncInitCopy;
begin
  with Sync.Copy do
  begin
    Application.CreateForm(TCopyForm,Form);

    Form.CopyThread:=Self;

    ggFileProgress:=0;
    ggFileMax:=0;
    ggAllProgress:=0;
    ggAllMax:=0;

    State:=cwsWaiting;

    SyncUpdateCopy;

    Form.Show;
  end;
end;

//******************************************************************************
// SyncEndCopy: destruction de la fenêtre de copie
//******************************************************************************
procedure TCopyThread.SyncEndCopy;
begin
  with Sync.Copy.Form do
  begin
    Hide;
    Free;
  end;
end;

//******************************************************************************
// SyncUpdatecopy: màj de la fenêtre de copie
//******************************************************************************
procedure TCopyThread.SyncUpdatecopy;
begin
  with Sync.Copy,Sync.Copy.Form do
  begin
    // thread -> form

    Caption:=GetDisplayName;

    llFrom.Caption:=llFromCaption;
    llTo.Caption:=llToCaption;
    llFile.Caption:=llFileCaption;
    llAll.Caption:=llAllCaption;
    llSpeed.Caption:=llSpeedCaption;

    //TODO: temporaire
    ggFile.Progress:=ggFileProgress div 1024;
    ggFile.MaxValue:=ggFileMax div 1024;
    ggAll.Progress:=ggAllProgress div 1024;
    ggAll.MaxValue:=ggAllMax div 1024;
    {
    ggFile.Progress:=ggFileProgress;
    ggFile.MaxValue:=ggFileMax;
    ggAll.Progress:=ggAllProgress;
    ggAll.MaxValue:=ggAllMax;
    }

    llAllRemaining.Caption:=ggAllRemaining;
    llFileRemaining.Caption:=ggFileRemaining;

    // form -> thread

    lvErrorListEmpty:=lvErrorList.Items.Count=0;

    if ConfigDataModifiedByThread then
    begin
      ConfigDataModifiedByThread:=False;
      Sync.Copy.Form.ConfigData:=Sync.Copy.ConfigData;
    end
    else
    begin
      Sync.Copy.ConfigData:=Sync.Copy.Form.ConfigData;
    end;

    Sync.Copy.Action:=Sync.Copy.Form.Action;
    Sync.Copy.Form.Action:=cwaNone;

    Sync.Copy.Form.State:=Sync.Copy.State;
  end;
end;

//******************************************************************************
// SyncSetFileListviewCount: màj du nb d'éléments de lvFileItems
//******************************************************************************
procedure TCopyThread.SyncSetFileListviewCount;
begin
  with Sync.Copy.Form do
  begin
    lvFileList.Items.Count:=Copier.FileList.Count;
  end;
end;

//******************************************************************************
// SyncUpdateFileListview: màj de lvFileItems
//******************************************************************************
procedure TCopyThread.SyncUpdateFileListview;
var TIndex:integer;
begin
  with Sync.Copy.Form do
  begin
    if lvFileList.Items.Count<>Copier.FileList.Count then
    begin
      while lvFileList.Items.Count>Copier.FileList.Count do // on réduit le nombre d'items de lvFileList jusqu'à en avoir le bon nombre
      begin
        lvFileList.Scroll(0,-16);
        lvFileList.Update;
        ListView_DeleteItem(lvFileList.Handle,0);
      end;
    end
    else
    begin
      TIndex:=lvFileList.TopItem.Index;
      lvFileList.UpdateItems(TIndex,TIndex+lvFileList.VisibleRowCount);
    end;
  end;
end;

//******************************************************************************
// SyncAddToErrorLog: ajout d'une erreur à lvErrorList
//******************************************************************************
procedure TCopyThread.SyncAddToErrorLog;
begin
  with Sync.Copy.Error,Sync.Copy.Form.lvErrorList.Items.Add do
  begin
    Caption:=TimeToStr(Time);
    SubItems.Add(Action);
    SubItems.Add(Target);
    SubItems.Add(ErrorText);

    Sync.Copy.lvErrorListEmpty:=False;
  end;
end;

//******************************************************************************
// SyncSaveErrorLog: enregistrement automatique du log des erreurs
//******************************************************************************
procedure TCopyThread.SyncSaveErrorLog;
var FileName:WideString;
begin
  with Sync.Copy.Form do
  begin
    if lvErrorList.Items.Count>0 then
    begin
      case Config.Values.ErrorLogAutoSaveMode of
        eamToDestDir:
          FileName:=DefaultDir+WideExtractFileName(Config.Values.ErrorLogFileName);
        eamToSrcDir:
          FileName:=SrcDir+WideExtractFileName(Config.Values.ErrorLogFileName);
        eamCustomDir:
          FileName:=Config.Values.ErrorLogFileName;
      end;

      SaveCopyErrorLog(FileName);
    end;
  end;
end;

//******************************************************************************
// SyncInitDiskSpace:
//******************************************************************************
procedure TCopyThread.SyncInitDiskSpace;
var i:Integer;
begin
  with Sync.DiskSpace do
  begin
    Application.CreateForm(TDiskSpaceForm,Form);
    Form.Caption:=DisplayName+Form.Caption;

    //on remplit la liste des volumes
    for i:=0 to Length(Volumes)-1 do
      with Form.lvDiskSpace.Items.Add,Volumes[i] do
      begin
        Caption:=GetVolumeReadableName(Volume);
        SubItems.Add(SizeToString(VolumeSize));
        SubItems.Add(SizeToString(FreeSize));
        SubItems.Add(SizeToString(LackSize));
      end;

    SyncCheckDiskSpace;

    Form.Show;
  end;
end;

//******************************************************************************
// SyncEndDiskSpace:
//******************************************************************************
procedure TCopyThread.SyncEndDiskSpace;
begin
  with Sync.DiskSpace.Form do
  begin
    Hide;
    Free;
  end;
end;

//******************************************************************************
// SyncCheckDiskSpace:
//******************************************************************************
procedure TCopyThread.SyncCheckDiskSpace;
begin
  Sync.DiskSpace.Action:=Sync.DiskSpace.Form.Action;
end;

//******************************************************************************
// SyncInitCollisions:
//******************************************************************************
procedure TCopyThread.SyncInitCollision;
begin
  with Sync.Collision,Copier.CurrentCopy.FileItem do
  begin
    Application.CreateForm(TCollisionForm,Form);
    Form.Caption:=DisplayName+Form.Caption;

    Form.llFileName.Caption:=DestFullName;
    Form.llSourceData.Caption:=Format(lsCollisionFileData,[SizeToString(SrcSize),DateTimeToStr(FileDateToDateTime(SrcAge))]);
    Form.llDestinationData.Caption:=Format(lsCollisionFileData,[SizeToString(DestSize),DateTimeToStr(FileDateToDateTime(DestAge))]);

    Form.FileName:=FileName;

    SyncCheckCollision;

    Form.Show;
  end;
end;

//******************************************************************************
// SyncEndCollisions:
//******************************************************************************
procedure TCopyThread.SyncEndCollision;
begin
  with Sync.Collision.Form do
  begin
    Hide;
    Free;
  end;
end;

//******************************************************************************
// SyncCheckCollisions:
//******************************************************************************
procedure TCopyThread.SyncCheckCollision;
begin
  with Sync.Collision do
  begin
    Action:=Form.Action;
    SameForNext:=Form.SameForNext;
    FileName:=Form.FileName;
    CustomRename:=Form.CustomRename;
  end;
end;

//******************************************************************************
// SyncInitCopyError:
//******************************************************************************
procedure TCopyThread.SyncInitCopyError;
begin
  with Sync.CopyError do
  begin
    Application.CreateForm(TCopyErrorForm,Form);
    Form.Caption:=DisplayName+Form.Caption;

    Form.llFileName.Caption:=Copier.CurrentCopy.FileItem.DestFullName;
    Form.mmErrorText.Text:=ErrorText;

    SyncCheckCopyError;

    Form.Show;
  end;
end;

//******************************************************************************
// SyncEndCopyError:
//******************************************************************************
procedure TCopyThread.SyncEndCopyError;
begin
  with Sync.CopyError.Form do
  begin
    Hide;
    Free;
  end;
end;

//******************************************************************************
// SyncCheckCopyError:
//******************************************************************************
procedure TCopyThread.SyncCheckCopyError;
begin
  with Sync.CopyError do
  begin
    Action:=Form.Action;
    SameForNext:=Form.SameForNext;
  end;
end;

end.
