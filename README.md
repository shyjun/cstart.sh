# cstart.sh
Simple script to manage/navigate C project using cscope, ctags, and vim in bash



Command line options:

-a <path/file> : add files/folder to consider 

-ex <path/file>: exclude files or folders from project list

-c             : Continue script even if file/folder specified in "-a" is not present

-k             : Dont delete the extra files created (tags, cscope.files, cscope.out, tree)

-fl <file>     : Use this file as list of files.

-d             : Dont consider files in current directory

-s             : silent. Create DB and exit



This script creates file list: cscope.files


Then runs cscope, and ctags on cscope.files. cscope creates cscope.out, and ctags creates tags


This script also creates a tree view of source files named: tree


As an entry point, in cscope, select the option "Find this file"  and select the file tags


If you opened vim on a file, and want to run cstart on top of it, add these below in vimrc, and execute :CSTART command in vim

==============================================

function Saveall()

:wa!

endfunction

function CleanUpCstartDB()

call Saveall()

:autocmd! VimLeave * !delete_tag_list.sh

endfunction

function CscopeLink()

call Saveall()

!cstart.sh -s

:cs add cscope.out

call CleanUpCstartDB()

endfunction

command! CSTART :call CscopeLink()

==============================================


Copy these files to /sbin, or /usr/sbin  or any folder which belongs to PATH list. and use it at any location.
