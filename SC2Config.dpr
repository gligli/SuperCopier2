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

program SCConfig;

uses
  messages,windows,
  SCConfigShared in 'SCConfigShared.pas';

{$R SC2Config.res}

var param:string;
    handle:THandle;
begin
  param:=ParamStr(1);
  handle:=FindWindow(nil,SC2_MAINFORM_CAPTION);

  if handle=0 then
  begin
    MessageBox(0,'SuperCopier must be running to use this','SuperCopier is not running',MB_ICONWARNING);
    Halt;
  end;

  if param='config' then
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_CONFIG,0);
  end
  else if param='about' then
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_ABOUT,0);
  end
  else if param='quit' then
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_QUIT,0);
  end
  else if param='onoff' then
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_ONOFF,0);
  end
  else if param='menu' then
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_SHOWMENU,0);
  end
  else // action par défaut
  begin
    PostMessage(handle,WM_OPENDIALOG,OD_SHOWMENU,0);
  end;

end.
