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

unit SCCopyThread;

interface

uses
  Windows,Commctrl,Classes,Messages,SCObjectThreadList,SCWorkThread,SCWorkThreadList,
  SCCopier,SCAnsiBufferedCopier,SCWideUnbufferedCopier,SCCommon,SCConfig,SCBaseList,
  SCDirList,SCSystray,SCCopyForm,SCDiskSpaceForm,SCCollisionForm,SCCopyErrorForm,
  SCBaseListQueue,Forms,TntForms,ShlObj,ShellApi;

type
  TCopyThread=class(TWorkThread)
  private
    Copier:TCopier;

    BaseListQueue:TBaseListQueue;

    FDefaultDir,SrcDir:WideString;
    FIsMove:Boolean;

    FIsThreadAlive:Boolean;

    // variables pour la copie
    LastCopyWindowUpdate:Integer;

    LastCopiedSize:Int64;
    NumSamples,CurrentSample:Integer;
    SpeedSamples:array of integer;
    SpeedSamplesFirstPass:Boolean;
    CopySpeed:Integer;

    ThrottleLastTime:Integer;
    ThrottleLastCopiedSize:Int64;

    Sync:record
      Copy:record
        Form:TCopyForm;
        Paused,SkipPending,CancelPending:Boolean;
        State:TCopyWindowState;
        ConfigData:TCopyWindowConfigData;
        ConfigDataModifiedByThread:Boolean; // mettre a true si la config doit être copiée de la thread vers la fenêtre
        lvErrorListEmpty:Boolean;

        FormCaption,
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
      Notification:record
        TargetForm:TTntForm;
        UseMainIcon:Boolean;
        IconType:TIcoBalloon;
        Title,Text:WideString;
      end;
    end;

    function CheckWaitingBaseList:Boolean;
    procedure HandlePause;

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
    procedure SyncShowNotificationBalloon;

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
    function LockCopier:TCopier;
    procedure UnlockCopier;
    procedure UpdateCopyWindow;
    procedure Cancel;override;
  end;


implementation

uses SysUtils,SCMainForm,TntSysUtils,FileCtrl,SCLocStrings, TntComCtrls,
  SCFileList, StrUtils,SCWin32,Math;

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
  FIsThreadAlive:=True;

  // on choisis le copier en fonction de la config et de l'OS
  if Config.Values.FailSafeCopier or (Win32Platform<>VER_PLATFORM_WIN32_NT) then
    Copier:=TAnsiBufferedCopier.Create
  else
    Copier:=TWideUnbufferedCopier.Create;

  Copier.BufferSize:=Config.Values.CopyBufferSize;

  BaseListQueue:=TBaseListQueue.Create;

  FDefaultDir:='?';
  SrcDir:='?';
  FIsMove:=PIsMove;

  Copier.CopyAttributes:=(Config.Values.SaveAttributesOnCopy and not IsMove) or
                         (Config.Values.SaveAttributesOnMove and IsMove);

  Copier.CopySecurity:=(Config.Values.SaveSecurityOnCopy and not IsMove) or
                       (Config.Values.SaveSecurityOnMove and IsMove);

  // init calcul vitesse
  NumSamples:=0;
  if Config.Values.CopyWindowUpdateInterval<>0 then
    NumSamples:=Config.Values.CopySpeedAveragingInterval div Config.Values.CopyWindowUpdateInterval;
  if NumSamples=0 then NumSamples:=1;
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
  if FIsThreadAlive then
  begin
    // annuler la copie
    FreeOnTerminate:=False; // pour éviter que le Cancel fasse que le Destroy soit rappelé
    Cancel;
    WaitFor;
  end;

  // sauvegarde automatique du log des erreurs
  if Config.Values.ErrorLogAutoSave then Synchronize(SyncSaveErrorLog);

  // destruction de la fenêtre
  Synchronize(SyncEndCopy);

  BaseListQueue.Free;
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
    Result:=WideFormat(lsMoveDisplayName,[SrcDir,FDefaultDir])
  else
    Result:=WideFormat(lsCopyDisplayName,[SrcDir,FDefaultDir]);
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

  if Result and Config.Values.CopyListHandlingConfirm then
  begin
    Result:=MessageBoxW(Sync.Copy.Form.Handle,
                        PWideChar(lsConfirmCopylistAdd),
                        PWideChar(DisplayName),
                        MB_YESNO or MB_ICONQUESTION or MB_APPLMODAL or MB_SETFOREGROUND)=IDYES;
  end;
end;

//******************************************************************************
// AddBaseList: ajoute une baselist de fichiers à copier
//******************************************************************************
procedure TCopyThread.AddBaseList(BaseList:TBaseList;AddMode:TBaselistAddMode=amDefaultDir;Dir:WideString='');
var DestDir:WideString;
    AddOk:Boolean;
    BLQueueItem:TBaseListQueueItem;
begin
  AddOk:=True;
  case AddMode of
    amDefaultDir:
    begin
      Assert(FDefaultDir<>'?','No DefaultDir');
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
      AddOk:=BrowseForFolder(lsChooseDestDir,DestDir,Sync.Copy.Form.Handle);

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

    // on ajoute la baselist à la queue
    BaseListQueue.Lock;
    try
      BLQueueItem:=TBaseListQueueItem.Create;
      BLQueueItem.BaseList:=BaseList;
      BLQueueItem.DestDir:=DestDir;
      BaseListQueue.Push(BLQueueItem);
    finally
      BaseListQueue.Unlock;
    end;
  end
  else
  begin
    // libérer la baselist
    BaseList.Free;
  end;
end;

//******************************************************************************
// CheckWaitingBaseList: teste des BaseList sont en attente, si oui elles sont
//                       traitées et la fonction renvoie true;
//******************************************************************************
function TCopyThread.CheckWaitingBaseList:Boolean;
var BLQueueItem:TBaseListQueueItem;
begin
  Result:=False;

  BaseListQueue.Lock;
  try
    // on boucle tant que la queue n'est pas vidée
    while BaseListQueue.Count>0 do
    begin
      Result:=True;

      BLQueueItem:=BaseListQueue.Pop;

      // on ajoute les fichiers au copier
      Copier.AddBaseList(BLQueueItem.BaseList,BLQueueItem.DestDir);

      // on vérifie si il y a assez de place
      Copier.VerifyFreeSpace;

      // on a ajouté des fichiers, màj de lvFileList
      Synchronize(SyncSetFileListviewCount);

      BLQueueItem.Free;
    end;
  finally
    BaseListQueue.Unlock;
  end;
end;

//******************************************************************************
// HandlePause:
//******************************************************************************
procedure TCopyThread.HandlePause;
var OldState:TCopyWindowState;
begin
  with Sync.Copy do
  begin
    if Paused then
    begin
      OldState:=State;
      State:=cwsPaused;

      while Paused and not CancelPending do
      begin
        CheckWaitingBaseList;
        UpdateCopyWindow;
        Sleep(DEFAULT_WAIT);
      end;
      State:=OldState;
      UpdateCopyWindow;
    end;
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
var CopyError,UnfinishedCopy:Boolean;
begin
  try
    try
      // état de départ
      Sync.Copy.State:=cwsWaiting;

      repeat
        UpdateCopyWindow;
        // attendre les données
        while (not CheckWaitingBaseList) and (not Sync.Copy.CancelPending) and (Copier.FileList.Count=0) do
        begin
          UpdateCopyWindow;
          Sleep(DEFAULT_WAIT);
        end;

        // init des veriables servant a calculer la vitesse
        LastCopyWindowUpdate:=GetTickCount;
        LastCopiedSize:=Copier.CopiedSize;
        CurrentSample:=-1;
        CopySpeed:=0;
        SpeedSamplesFirstPass:=True;

        ThrottleLastTime:=GetTickCount;
        ThrottleLastCopiedSize:=Copier.CopiedSize;

        if Copier.FirstCopy then
        begin
          dbgln('Copy Start');

          // boucle principale
          repeat
            // gérer la pause
            HandlePause;

            // vérifier si il y a une baselist en attente
            CheckWaitingBaseList;

            // màj de lvFileItems
            Synchronize(SyncUpdateFileListview);

            // màj de la fenêtre
            Sync.Copy.State:=cwsCopying;
            UpdateCopyWindow;

            if Copier.ManageFileAction(Config.Values.CopyResumeNoAgeVerification) then
            begin
    //          dbgln('Copying: '+Copier.CurrentCopy.FileItem.SrcFullName);
    //          dbgln('      -> '+Copier.CurrentCopy.FileItem.DestFullName);

              Copier.VerifyOrCreateDir;

              CopyError:=not Copier.DoCopy;
              UnfinishedCopy:=(Copier.CurrentCopy.CopiedSize+Copier.CurrentCopy.SkippedSize)<Copier.CurrentCopy.FileItem.SrcSize;
              if not CopyError then
              begin
                Copier.CopyAttributesAndSecurity;

                // déplacement et le fichier à été copié en entier -> on peut supprimer le source
                if FIsMove and not UnfinishedCopy then
                  Copier.DeleteSrcFile;
              end;

              // gestion suppression copies non terminées
              if UnfinishedCopy and Config.Values.DeleteUnfinishedCopies and
                 not (CopyError and Config.Values.DontDeleteOnCopyError) then
              begin
                Copier.DeleteDestFile;
              end;
            end;

            if Sync.Copy.CancelPending then Copier.CurrentCopy.NextAction:=cpaCancel;
          until not Copier.NextCopy;

          dbgln('Copy End');
        end;

        Sync.Copy.State:=cwsCopyEnd;

        // tout afficher a 100% si la fenêtre reste ouverte alors que la copie est finie
        Sync.Copy.ggFileProgress:=Sync.Copy.ggFileMax;
        Sync.Copy.ggAllProgress:=Sync.Copy.ggAllMax;
        Synchronize(SyncUpdateFileListview); // lvFileList n'est pas à jour après la copie du dernier item

        if (Copier.CurrentCopy.NextAction<>cpaCancel) and (not Sync.Copy.CancelPending) then
        begin
          // notifier de la fin de la copie
          with Sync.Notification do
          begin
            TargetForm:=nil;
            UseMainIcon:=True;
            IconType:=IBInfo;
            Title:=lsCopyEndNotifyTitle;
            Text:=WideFormat(lsCopyEndNotifyText,[DisplayName,Sync.Copy.llSpeedCaption]);
          end;
          Synchronize(SyncShowNotificationBalloon);

          // créer les reps vide et supprimer les reps source
          Copier.CreateEmptyDirs;

          if FIsMove then Copier.DeleteSrcDirs;
        end;

      // on boucle tant que la fenêtre de copie doit rester ouverte
      until Sync.Copy.CancelPending or (Copier.CurrentCopy.NextAction=cpaCancel) or
            (Sync.Copy.ConfigData.CopyEndAction=cweClose) or
            ((Sync.Copy.ConfigData.CopyEndAction=cweDontCloseIfErrors) and Sync.Copy.lvErrorListEmpty);
    except
      // afficher les exception qui n'ont pas étées trappées (et qui sont de toute façon des bugs)
      on E:Exception do SCWin32.MessageBox(Sync.Copy.Form.Handle,E.Message,'SuperCopier2 - Critical error!',MB_ICONERROR);
    end;
  finally
    // dé-rescencer la thread
    WorkThreadList.Remove(Self);
    FIsThreadAlive:=False;
  end;
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

      // notification pour le systray
      with Sync.Notification do
      begin
        TargetForm:=Form;
        UseMainIcon:=False;
        Title:=lsCollisionNotifyTitle;
        Text:=WideFormat(lsCollisionNotifyText,[DisplayName,Copier.CurrentCopy.FileItem.DestFullName]);
        IconType:=IBWarning;
      end;
      Synchronize(SyncShowNotificationBalloon);

      while (Action=claNone) and (not Sync.Copy.CancelPending) do
      begin
        Synchronize(SyncCheckCollision);
        Sleep(DEFAULT_WAIT);
      end;
      if Sync.Copy.CancelPending then Action:=claCancel;

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


  // notification pour le systray
  with Sync.Notification do
  begin
    TargetForm:=Sync.DiskSpace.Form;
    UseMainIcon:=False;
    Title:=lsDiskSpaceNotifyTitle;
    Text:=DisplayName;
    IconType:=IBWarning;
  end;
  Synchronize(SyncShowNotificationBalloon);

  while (Sync.DiskSpace.Action=dsaNone) and (not Sync.Copy.CancelPending) do
  begin
    Synchronize(SyncCheckDiskSpace);
    Sleep(DEFAULT_WAIT);
  end;
  if Sync.Copy.CancelPending then Sync.DiskSpace.Action:=dsaCancel;

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

      // notification pour le systray
      with Sync.Notification do
      begin
        TargetForm:=Form;
        UseMainIcon:=False;
        Title:=lsCopyErrorNotifyTitle;
        Text:=WideFormat(lsCopyErrorNotifyText,[DisplayName,Copier.CurrentCopy.FileItem.DestFullName,ErrorText]);
        IconType:=IBError;
      end;
      Synchronize(SyncShowNotificationBalloon);

      while (Action=ceaNone) and (not Sync.Copy.CancelPending) do
      begin
        Synchronize(SyncCheckCopyError);
        Sleep(DEFAULT_WAIT);
      end;
      if Sync.Copy.CancelPending then Action:=ceaCancel;

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
      if Copier.CurrentCopy.FileItem.CopyTryCount>1 then
      begin
        Sleep(Config.Values.CopyErrorRetryInterval);
      end;

      Result:=Sync.Copy.ConfigData.CopyErrorAction;
    end;
  end;
end;

//******************************************************************************
// CopierGenericError: evenement du copier
//******************************************************************************
procedure TCopyThread.CopierGenericError(Action,Target,ErrorText:WideString);
begin
  dbgln('CopierGenericError: '+Action+' '+ErrorText+' '+Target);

  // notification pour le systray
  with Sync.Notification do
  begin
    TargetForm:=nil;
    UseMainIcon:=False;
    Title:=lsGenericErrorNotifyTitle;
    Text:=WideFormat(lsGenericErrorNotifyText,[DisplayName,Action,Target,ErrorText]);
    IconType:=IBError;
  end;
  Synchronize(SyncShowNotificationBalloon);

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
      i,UsedSamples:Integer;
  begin
    // calcul de la vitesse instantanée
    TempCopyTime:=CurTime-LastCopyWindowUpdate;

    if TempCopyTime<>0 then
      TempCopySpeed:=Round((Copier.CopiedSize-LastCopiedSize) * MSecsPerSec / TempCopyTime)
    else
      TempCopySpeed:=0;

    LastCopiedSize:=Copier.CopiedSize;

    // ajout à la liste des précédentes vitesses
    CurrentSample:=(CurrentSample+1) mod NumSamples;
    SpeedSamples[CurrentSample]:=TempCopySpeed;
    if CurrentSample=NumSamples-1 then SpeedSamplesFirstPass:=False;

    // on fait la moyenne pour avoir la vitesse à afficher
    Total:=0;
    if SpeedSamplesFirstPass then
      UsedSamples:=CurrentSample+1
    else
      UsedSamples:=NumSamples;

    for i:=0 to UsedSamples-1 do
      Total:=Total+SpeedSamples[i];
    CopySpeed:=Total div UsedSamples;
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
  with Sync.Copy do
  begin
    // vérifier si il y a une baselist en attente
    CheckWaitingBaseList;

    CurTime:=GetTickCount;

    State:=cwsCopying;

    if not ConfigData.ThrottleEnabled then
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
      DataSizeForThrottleTime:=Int64(ConfigData.ThrottleSpeedLimit)*1024*Config.Values.CopyThrottleInterval div MSecsPerSec;

      if Copier.CopiedSize>=(ThrottleLastCopiedSize+DataSizeForThrottleTime) then
      begin
        ThrottleTime:=Config.Values.CopyThrottleInterval-(CurTime-ThrottleLastTime);

        if ThrottleTime>0 then Sleep(ThrottleTime);

        CurTime:=GetTickCount;

        ComputeThrottleCopySpeed;

        UpdateCopyWindow;

        ThrottleLastTime:=CurTime;
        ThrottleLastCopiedSize:=Copier.CopiedSize;
      end
      else
      begin
        Synchronize(SyncUpdateCopy);
      end;
    end;

    // gestion de la pause
    HandlePause;

    // gestion Skip/Cancel
    Result:=not (CancelPending or SkipPending);
  end;
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

  // gérer la pause
  HandlePause;

  Result:=not Sync.Copy.CancelPending;
end;

//******************************************************************************
// UpdateCopyWindow: màj des infos de la fenêtre de copie
//******************************************************************************
procedure TCopyThread.UpdateCopyWindow;
var TmpStr:String;
    AllRemaining,FileRemaining:TDateTime;
    Percent:Integer;
    StateUpdated:Boolean;

  //ComputeRemainingTime: calcul du temps restant
  procedure ComputeRemainingTime;
  begin
    AllRemaining:=0;
    FileRemaining:=0;
    if CopySpeed<>0 then
      with Copier do
      begin
        AllRemaining:=(FileList.TotalSize-CopiedSize-SkippedSize)/CopySpeed/SecsPerDay;
        FileRemaining:=(CurrentCopy.FileItem.SrcSize-CurrentCopy.CopiedSize-CurrentCopy.SkippedSize)/CopySpeed/SecsPerDay;
      end;
  end;

begin
  StateUpdated:=False;
  repeat
    with Sync.Copy,Copier do
    begin
      // calcul du caption
      Case State of
        cwsWaiting,
        cwsRecursing:
          FormCaption:=WideFormat(lsCopyWindowWaitingCaption,[GetDisplayName]);
        cwsPaused:
          FormCaption:=WideFormat(lsCopyWindowPausedCaption,[GetDisplayName]);
        cwsCancelling:
          FormCaption:=WideFormat(lsCopyWindowCancellingCaption,[GetDisplayName]);
        cwsCopyEnd:
          if lvErrorListEmpty then
            FormCaption:=WideFormat(lsCopyWindowCopyEndCaption,[GetDisplayName])
          else
            FormCaption:=WideFormat(lsCopyWindowCopyEndErrorsCaption,[GetDisplayName]);
        else
        begin
          if ggAllMax>0 then Percent:=Round(ggAllProgress*100/ggAllMax) else Percent:=0;
          FormCaption:=WideFormat('%d%% - %s',[Percent,GetDisplayName]);
        end;
      end;

      // infos sur la copie
      if Assigned(Copier.CurrentCopy.FileItem) and (Copier.FileList.Count>0) then
      begin
        ComputeRemainingTime;

        llFromCaption:=CurrentCopy.DirItem.SrcPath;
        llToCaption:=CurrentCopy.DirItem.Destpath;

        llAllCaption:=WideFormat(lsAll,[CopiedCount+1,FileList.TotalCount,SizeToString(FileList.TotalSize,Config.Values.SizeUnit)]);
        llFileCaption:=WideFormat(lsFile,[CurrentCopy.FileItem.SrcName,SizeToString(CurrentCopy.FileItem.SrcSize,Config.Values.SizeUnit)]);

        ggFileProgress:=CurrentCopy.CopiedSize+CurrentCopy.SkippedSize;
        ggFileMax:=CurrentCopy.FileItem.SrcSize;
        ggAllProgress:=CopiedSize+SkippedSize;
        ggAllMax:=FileList.TotalSize;

        llSpeedCaption:=WideFormat(lsSpeed,[CopySpeed / 1024]);

        DateTimeToString(TmpStr,'hh:nn:ss',AllRemaining);
        ggAllRemaining:=WideFormat(lsRemaining,[TmpStr]);

        DateTimeToString(TmpStr,'hh:nn:ss',FileRemaining);
        ggFileRemaining:=WideFormat(lsRemaining,[TmpStr]);
      end;

      Synchronize(SyncUpdateCopy);

      // gestion de l'état annulation
      if CancelPending then
      begin
        Sync.Copy.State:=cwsCancelling;
        StateUpdated:=not StateUpdated; // état changé -> on refait la màj
      end;
    end;
  until not StateUpdated;
end;

//******************************************************************************
// Cancel: annule la copie en cours
//******************************************************************************
procedure TCopyThread.Cancel;
begin
  try
    LockCopier;

    Sync.Copy.CancelPending:=True;
    Copier.CurrentCopy.NextAction:=cpaCancel;
  finally
    UnlockCopier;
  end;
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
    Form:=TCopyForm.Create(nil);

    Form.CopyThread:=Self;

    ggFileProgress:=0;
    ggFileMax:=0;
    ggAllProgress:=0;
    ggAllMax:=0;

    State:=cwsWaiting;

    SyncUpdateCopy;

    if not Form.Minimized then
    begin
      Form.Show;
      Application.BringToFront;
      Form.BringToFront;
    end;
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

    Caption:=FormCaption;

    llFrom.Caption:=llFromCaption;
    llTo.Caption:=llToCaption;
    llFile.Caption:=llFileCaption;
    llAll.Caption:=llAllCaption;
    llSpeed.Caption:=llSpeedCaption;

    ggFile.Max:=ggFileMax;
    ggFile.SetAvancement(ggFileProgress,ggFileRemaining);
    ggAll.Max:=ggAllMax;
    ggAll.SetAvancement(ggAllProgress,ggAllRemaining);

    Sync.Copy.Form.State:=Sync.Copy.State;

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

    Sync.Copy.Paused:=Sync.Copy.Form.Paused;

    Sync.Copy.SkipPending:=Sync.Copy.Form.SkipPending;
    Sync.Copy.Form.SkipPending:=False;

    Sync.Copy.CancelPending:= Sync.Copy.CancelPending or Sync.Copy.Form.CancelPending;
  end;
end;

//******************************************************************************
// SyncSetFileListviewCount: màj du nb d'éléments de lvFileItems
//******************************************************************************
procedure TCopyThread.SyncSetFileListviewCount;
begin
  with Sync.Copy.Form do
  begin
    lvFileList.Items.Count:=Copier.FileList.Count-1;
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
    if lvFileList.Items.Count<>Copier.FileList.Count-1 then
    begin
      while lvFileList.Items.Count>Max(0,Copier.FileList.Count-1) do // on réduit le nombre d'items de lvFileList jusqu'à en avoir le bon nombre
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

  with Sync.Copy.Form do
  begin
    // notifier de la présence d'une nouvelle erreur
    if pcPages.ActivePage<>tsErrors then tsErrors.Highlighted:=True;
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
// SyncShowNotificationBalloon: afiche une bulle de notification dans le systray
//                              en fonction de la config et de l'état de CopyForm
//******************************************************************************
procedure TCopyThread.SyncShowNotificationBalloon;
var TheSystray:TScSystray;
begin
  with Sync.Copy.Form,Sync.Notification do
  begin
    if Minimized then
    begin
      TheSystray:=Systray;

      // on force l'utilisation de l'icône principale si la fenêtre est réduite dans la taskbar
      if (UseMainIcon or (not MinimizedToTray)){ and Config.Values.TrayIcon} then
      begin
        TheSystray:=MainForm.Systray;
        MainForm.NotificationSourceThread:=Self;
        MainForm.NotificationSourceForm:=Sync.Copy.Form;
      end;

      if Config.Values.MinimizedEventHandling=mehShowBalloon then
        TheSystray.ShowBalloon(Title,Text,IconType);

      if Config.Values.MinimizedEventHandling<>mehPopupWindow then
        NotificationTargetForm:=TargetForm;
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
    Form:=TDiskSpaceForm.Create(Sync.Copy.Form);

    Form.Caption:=DisplayName+Form.Caption;

    //on remplit la liste des volumes
    for i:=0 to Length(Volumes)-1 do
      with Form.lvDiskSpace.Items.Add,Volumes[i] do
      begin
        Caption:=GetVolumeReadableName(Volume);
        SubItems.Add(SizeToString(VolumeSize,Config.Values.SizeUnit));
        SubItems.Add(SizeToString(FreeSize,Config.Values.SizeUnit));
        SubItems.Add(SizeToString(LackSize,Config.Values.SizeUnit));
      end;

    SyncCheckDiskSpace;

    if (not Sync.Copy.Form.Minimized) or (Config.Values.MinimizedEventHandling=mehPopupWindow) then Form.Show;
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
    Form:=TCollisionForm.Create(Sync.Copy.Form);

    Form.Caption:=DisplayName+Form.Caption;

    Form.llFileName.Caption:=DestFullName;

    Form.llSourceData.Caption:=lsUnknown;
    if SrcExists then
      Form.llSourceData.Caption:=Format(lsCollisionFileData,[SizeToString(SrcSize,Config.Values.SizeUnit),DateTimeToStr(FileDateToDateTime(SrcAge))]);

    Form.llDestinationData.Caption:=lsUnknown;
    if DestExists then
      Form.llDestinationData.Caption:=Format(lsCollisionFileData,[SizeToString(DestSize,Config.Values.SizeUnit),DateTimeToStr(FileDateToDateTime(DestAge))]);

    Form.FileName:=FileName;

    SyncCheckCollision;

    if (not Sync.Copy.Form.Minimized) or (Config.Values.MinimizedEventHandling=mehPopupWindow) then Form.Show;
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
    Form:=TCopyErrorForm.Create(Sync.Copy.Form);

    Form.Caption:=DisplayName+Form.Caption;

    Form.llFileName.Caption:=Copier.CurrentCopy.FileItem.DestFullName;
    Form.mmErrorText.Text:=ErrorText;

    SyncCheckCopyError;

    if (not Sync.Copy.Form.Minimized) or (Config.Values.MinimizedEventHandling=mehPopupWindow) then Form.Show;
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

