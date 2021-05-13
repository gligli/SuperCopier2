SuperCopier 2.2 beta
====================

SuperCopier2 is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

SuperCopier2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Website:
  http://supercopier.sfxteam.org

E-Mail:
  supercopier@sfxteam.org (preferably put the 'SuperCopier' word  in the e-mail
  subject)

Staff:
  GliGli: Main code,
  Yogi: Original NT Copier,
  ZeuS: Graphical components.

Special thanks to:
  TntWare http://www.tntware.com/ (unicode components),
  Tal Sella http://www.virtualplastic.net/scrow/ (icons).

Description:
============

SuperCopier replaces Windows explorer file copy and adds many features:
    - Transfer resuming
    - Copy speed control
    - No bugs if You copy more than 2GB at once
    - Copy speed computation
    - Better copy progress display
    - A little faster
    - Copy list editable while copying
    - Error log
    - Copy list saving/loading
    - ...
    
Compatibility: Windows NT4/2000/XP/Vista/Seven and 64 bit / Server flavors.

History:
========

- v2 beta 1:
    Complete rewrite.
    ... So many new things but it's too long to enumerate :)

- v2 beta 1.9:
    - Better handling of transfer resume (overwrite if resume is not possible
      and new option to force resume without file age verification).
    - Pause can now be used during waiting state or during copy list creation.
    - Better handling of temporization on retry after copy errors
    - Added a notification balloon for insufficient disk space windows.
    - Corrected speed issues with networked copies (especially on upload).
    - Fixed bug with handled processes name case.
    - Fixed bug with language files loading.
    - Fixed one bug with files larger than 4GB (one more :).
    - Fixed bug while cancelling the insufficient disk space window.
    - Fixed bug with renaming on file names containing dots.
    - Fixed bug with 'Always overwrite if different' option for file collisions.
    - GUI bug fixes and enhancements:
	- Lowered CPU usage.
        - Fixed blinking problem with themes.
        - Fixed problem with copy window minimize button click.
        - Better handling of copy window buttons focus.
        - Hopefully fixed the problem with systray progress bars for copy
          windows.

- v2.2 beta:
    - Complete rewrite of the copy interception system, adds support for
      Windows Vista, Seven and all 64 bit Windows. For now, compatibility with 
      Windows 95, 98 and Millenium has been dropped and 'handled processes' is 
      deactivated.
    - Added options to sort the copy list. You can either click on the column headers
      or use the 'Sort' context menu item.
    - Separated attributes copy from security copy.
    - User interface improvements, including: 
        - Reintroduced Supercopier 1.35 like cursor for copy speed limitation.
        - Popup menus from file collision and file error windows now automatically
          popup when the button is hovered.
	- Copy window is no more a tool window, so now it has standard buttons like
          minimize, maximize and system menu. This should also fix problems with
          non standard themes.
    - Many bugfixes (about 100 bugs were treated).

About the author:
=================
  Tanks for all the replies I got from my job search, I now have a good delphi job.
  
  