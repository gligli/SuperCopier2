program SCConfig;

uses
  messages,windows,
  SCConfigShared;

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
