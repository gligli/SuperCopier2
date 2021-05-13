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

unit SCAnsiBufferedCopier;

interface
uses
  Windows,Messages,SCCopier;
  
type
  TAnsiBufferedCopier=class(TCopier)
  private
    Buffer:array of byte;
  protected
    procedure SetBufferSize(Value:cardinal);override;
  public
    function DoCopy:Boolean;override;
  end;

implementation

uses SCCommon,SCLocStrings,SCWin32;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TAnsiBufferedCopier: descendant de TCopier, copie bufferisée simple en mode
//                      ansi (Pour Win9x)
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// SetBufferSize: fixe la taille du buffer de copie
//******************************************************************************
procedure TAnsiBufferedCopier.SetBufferSize(Value:cardinal);
begin
  if Value<>FBufferSize then
  begin
    SetLength(Buffer,Value);
    FBufferSize:=Value;
  end;
end;

//******************************************************************************
// DoCopy: renvoie false si la copie échoue
//******************************************************************************
function TAnsiBufferedCopier.DoCopy:boolean;
var HSrc,HDest:THandle;
    SourceFile,DestFile:String;
    BytesRead,BytesWritten:Cardinal;
    ContinueCopy:Boolean;
    LastError:Cardinal;
begin
  Assert(Assigned(OnCopyProgress),'OnCopyProgress not assigned');

  Result:=True;
  with CurrentCopy do
  begin
    CopiedSize:=0;
    SkippedSize:=0;
    SourceFile:=FileItem.SrcFullName;
    DestFile:=FileItem.DestFullName;

    Inc(FileItem.CopyTryCount);

    try
      HSrc:=INVALID_HANDLE_VALUE;
      HDest:=INVALID_HANDLE_VALUE;
      try
        // on ouvre le fichier source
        HSrc:=CreateFile(pchar(SourceFile),
                            GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE,
                            nil,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,
                            0);
        RaiseCopyErrorIfNot(HSrc<>INVALID_HANDLE_VALUE);

        // effacer les attributs du fichier de destination pour pouvoir l'ouvrir en écriture
        FileItem.DestClearAttributes;

        // on ouvre le fichier de destination
        if NextAction<>cpaRetry then // doit-on reprendre le transfert?
        begin
          HDest:=CreateFile(pchar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ,
                              nil,
                              CREATE_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL,
                              0);
        end
        else
        begin
          HDest:=CreateFile(pchar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ,
                              nil,
                              OPEN_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL,
                              0);

          // on se positionne a la fin du fichier de destination
          SetFilePointer(HDest,0,FILE_END);

          SkippedSize:=FileItem.DestSize;
          Self.SkippedSize:=Self.SkippedSize+SkippedSize;
          // et on se mets a la position correspondante dans le fichier source
          SetFilePointer(HSrc,SkippedSize,FILE_BEGIN);
        end;
        RaiseCopyErrorIfNot(HDest<>INVALID_HANDLE_VALUE);

        // on donne sa taille finale au fichier de destination (pour éviter la fragmentation)
        RaiseCopyErrorIfNot(SetFileSize(HDest,FileItem.SrcSize));

        // boucle principale de copie
        repeat
          RaiseCopyErrorIfNot(ReadFile(HSrc,Buffer[0],BufferSize,BytesRead,nil));
          RaiseCopyErrorIfNot(WriteFile(HDest,Buffer[0],BytesRead,BytesWritten,nil));
          CopiedSize:=CopiedSize+BytesWritten;
          Self.CopiedSize:=Self.CopiedSize+BytesWritten;

          ContinueCopy:=OnCopyProgress;
        until ((CopiedSize+SkippedSize)>=FileItem.SrcSize) or (not ContinueCopy);

        // copie de la date de modif
        CopyFileAge(HSrc,HDest);
      finally
        LastError:=GetLastError;

        // on déclare la position courrante dans le fichier destination comme fin de fichier
        SetEndOfFile(HDest);

        // fermeture des handles si ouverts
        CloseHandle(HSrc);
        CloseHandle(HDest);

        SetLastError(LastError); // ne pas polluer le code d'erreur

        NextAction:=cpaNextFile;
      end;
    except
      on E:ECopyError do
      begin
        Result:=False;

        CopyError;
      end;
    end;
  end;
end;

end.
