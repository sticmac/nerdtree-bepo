" ============================================================================
" File:        NERD_tree.vim
" Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
"
" SECTION: Script init stuff {{{1
"============================================================
if exists("loaded_nerd_tree")
    finish
endif
if v:version < 703
    echoerr "NERDTree: this plugin requires vim >= 7.3. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerd_tree = 1

"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim

"Function: s:initVariable() function {{{2
"This function is used to initialise a given variable to a given value. The
"variable is only initialised if it does not exist prior
"
"Args:
"var: the name of the var to be initialised
"value: the value to initialise var to
"
"Returns:
"1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

"SECTION: Init variable calls and other random constants {{{2
call s:initVariable("g:NERDTreeAutoCenter", 1)
call s:initVariable("g:NERDTreeAutoCenterThreshold", 3)
call s:initVariable("g:NERDTreeCaseSensitiveSort", 0)
call s:initVariable("g:NERDTreeNaturalSort", 0)
call s:initVariable("g:NERDTreeSortHiddenFirst", 1)
call s:initVariable("g:NERDTreeUseTCD", 0)
call s:initVariable("g:NERDTreeChDirMode", 0)
call s:initVariable("g:NERDTreeCreatePrefix", "silent")
call s:initVariable("g:NERDTreeMinimalUI", 0)
call s:initVariable("g:NERDTreeMinimalMenu", 0)
if !exists("g:NERDTreeIgnore")
    let g:NERDTreeIgnore = ['\~$']
endif
call s:initVariable("g:NERDTreeBookmarksFile", expand('$HOME') . '/.NERDTreeBookmarks')
call s:initVariable("g:NERDTreeBookmarksSort", 1)
call s:initVariable("g:NERDTreeHighlightCursorline", 1)
call s:initVariable("g:NERDTreeHijackNetrw", 1)
call s:initVariable('g:NERDTreeMarkBookmarks', 1)
call s:initVariable("g:NERDTreeMouseMode", 1)
call s:initVariable("g:NERDTreeNotificationThreshold", 100)
call s:initVariable("g:NERDTreeQuitOnOpen", 0)
call s:initVariable("g:NERDTreeRespectWildIgnore", 0)
call s:initVariable("g:NERDTreeShowBookmarks", 0)
call s:initVariable("g:NERDTreeShowFiles", 1)
call s:initVariable("g:NERDTreeShowHidden", 0)
call s:initVariable("g:NERDTreeShowLineNumbers", 0)
call s:initVariable("g:NERDTreeSortDirs", 1)

if !nerdtree#runningWindows() && !nerdtree#runningCygwin()
    call s:initVariable("g:NERDTreeDirArrowExpandable", "▸")
    call s:initVariable("g:NERDTreeDirArrowCollapsible", "▾")
else
    call s:initVariable("g:NERDTreeDirArrowExpandable", "+")
    call s:initVariable("g:NERDTreeDirArrowCollapsible", "~")
endif

call s:initVariable("g:NERDTreeCascadeOpenSingleChildDir", 1)
call s:initVariable("g:NERDTreeCascadeSingleChildDir", 1)

if !exists("g:NERDTreeSortOrder")
    let g:NERDTreeSortOrder = ['\/$', '*', '\.swp$',  '\.bak$', '\~$']
endif
let g:NERDTreeOldSortOrder = []

call s:initVariable("g:NERDTreeGlyphReadOnly", "RO")

if has("conceal")
    call s:initVariable("g:NERDTreeNodeDelimiter", "\x07")
elseif (g:NERDTreeDirArrowExpandable == "\u00a0" || g:NERDTreeDirArrowCollapsible == "\u00a0")
    call s:initVariable("g:NERDTreeNodeDelimiter", "\u00b7")
else
    call s:initVariable("g:NERDTreeNodeDelimiter", "\u00a0")
endif

if !exists('g:NERDTreeStatusline')

    "the exists() crap here is a hack to stop vim spazzing out when
    "loading a session that was created with an open nerd tree. It spazzes
    "because it doesnt store b:NERDTree(its a b: var, and its a hash)
    let g:NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}"

endif
call s:initVariable("g:NERDTreeWinPos", "left")
call s:initVariable("g:NERDTreeWinSize", 31)

"init the shell commands that will be used to copy nodes, and remove dir trees
"
"Note: the space after the command is important
if nerdtree#runningWindows()
    call s:initVariable("g:NERDTreeRemoveDirCmd", 'rmdir /s /q ')
    call s:initVariable("g:NERDTreeCopyDirCmd", 'xcopy /s /e /i /y /q ')
    call s:initVariable("g:NERDTreeCopyFileCmd", 'copy /y ')
else
    call s:initVariable("g:NERDTreeRemoveDirCmd", 'rm -rf ')
    call s:initVariable("g:NERDTreeCopyCmd", 'cp -r ')
endif


"SECTION: Init variable calls for key mappings {{{2
call s:initVariable("g:NERDTreeMapCustomOpen", "<CR>")
call s:initVariable("g:NERDTreeMapActivateNode", "o")
call s:initVariable("g:NERDTreeMapChangeRoot", "C")
call s:initVariable("g:NERDTreeMapChdir", "cd")
call s:initVariable("g:NERDTreeMapCloseChildren", "X")
call s:initVariable("g:NERDTreeMapCloseDir", "x")
call s:initVariable("g:NERDTreeMapDeleteBookmark", "D")
call s:initVariable("g:NERDTreeMapMenu", "m")
call s:initVariable("g:NERDTreeMapHelp", "?")
call s:initVariable("g:NERDTreeMapJumpFirstChild", "K")
call s:initVariable("g:NERDTreeMapJumpLastChild", "T")
call s:initVariable("g:NERDTreeMapJumpNextSibling", "<C-t>")
call s:initVariable("g:NERDTreeMapJumpParent", "p")
call s:initVariable("g:NERDTreeMapJumpPrevSibling", "<C-k>")
call s:initVariable("g:NERDTreeMapJumpRoot", "P")
call s:initVariable("g:NERDTreeMapOpenExpl", "e")
call s:initVariable("g:NERDTreeMapOpenInTab", "j")
call s:initVariable("g:NERDTreeMapOpenInTabSilent", "J")
call s:initVariable("g:NERDTreeMapOpenRecursively", "O")
call s:initVariable("g:NERDTreeMapOpenSplit", "i")
call s:initVariable("g:NERDTreeMapOpenVSplit", "u")
call s:initVariable("g:NERDTreeMapPreview", "g" . NERDTreeMapActivateNode)
call s:initVariable("g:NERDTreeMapPreviewSplit", "g" . NERDTreeMapOpenSplit)
call s:initVariable("g:NERDTreeMapPreviewVSplit", "g" . NERDTreeMapOpenVSplit)
call s:initVariable("g:NERDTreeMapQuit", "q")
call s:initVariable("g:NERDTreeMapRefresh", "r")
call s:initVariable("g:NERDTreeMapRefreshRoot", "R")
call s:initVariable("g:NERDTreeMapToggleBookmarks", "B")
call s:initVariable("g:NERDTreeMapToggleFiles", "F")
call s:initVariable("g:NERDTreeMapToggleFilters", "f")
call s:initVariable("g:NERDTreeMapToggleHidden", "I")
call s:initVariable("g:NERDTreeMapToggleZoom", "A")
call s:initVariable("g:NERDTreeMapUpdir", "v")
call s:initVariable("g:NERDTreeMapUpdirKeepOpen", "V")
call s:initVariable("g:NERDTreeMapCWD", "CD")
call s:initVariable("g:NERDTreeMenuDown", "t")
call s:initVariable("g:NERDTreeMenuUp", "s")

"SECTION: Load class files{{{2
call nerdtree#loadClassFiles()

" SECTION: Commands {{{1
"============================================================
call nerdtree#ui_glue#setupCommands()

" SECTION: Auto commands {{{1
"============================================================
augroup NERDTree
    "Save the cursor position whenever we close the nerd tree
    exec "autocmd BufLeave,WinLeave ". g:NERDTreeCreator.BufNamePrefix() ."* if g:NERDTree.IsOpen() | call b:NERDTree.ui.saveScreenState() | endif"

    "disallow insert mode in the NERDTree
    exec "autocmd BufEnter,WinEnter ". g:NERDTreeCreator.BufNamePrefix() ."* stopinsert"
augroup END

if g:NERDTreeHijackNetrw
    augroup NERDTreeHijackNetrw
        autocmd VimEnter * silent! autocmd! FileExplorer
        au BufEnter,VimEnter * call nerdtree#checkForBrowse(expand("<amatch>"))
    augroup END
endif

if g:NERDTreeChDirMode == 3
    augroup NERDTreeChDirOnTabSwitch
        autocmd TabEnter * if g:NERDTree.ExistsForTab()|call g:NERDTree.ForCurrentTab().getRoot().path.changeToDir()|endif
    augroup END
endif

" SECTION: Public API {{{1
"============================================================
function! NERDTreeAddMenuItem(options)
    call g:NERDTreeMenuItem.Create(a:options)
endfunction

function! NERDTreeAddMenuSeparator(...)
    let opts = a:0 ? a:1 : {}
    call g:NERDTreeMenuItem.CreateSeparator(opts)
endfunction

function! NERDTreeAddSubmenu(options)
    return g:NERDTreeMenuItem.Create(a:options)
endfunction

function! NERDTreeAddKeyMap(options)
    call g:NERDTreeKeyMap.Create(a:options)
endfunction

function! NERDTreeRender()
    call nerdtree#renderView()
endfunction

function! NERDTreeFocus()
    if g:NERDTree.IsOpen()
        call g:NERDTree.CursorToTreeWin()
    else
        call g:NERDTreeCreator.ToggleTabTree("")
    endif
endfunction

function! NERDTreeCWD()

    if empty(getcwd())
        call nerdtree#echoWarning('current directory does not exist')
        return
    endif

    try
        let l:cwdPath = g:NERDTreePath.New(getcwd())
    catch /^NERDTree.InvalidArgumentsError/
        call nerdtree#echoWarning('current directory does not exist')
        return
    endtry

    call NERDTreeFocus()

    if b:NERDTree.root.path.equals(l:cwdPath)
        return
    endif

    let l:newRoot = g:NERDTreeFileNode.New(l:cwdPath, b:NERDTree)
    call b:NERDTree.changeRoot(l:newRoot)
    normal! ^
endfunction

function! NERDTreeAddPathFilter(callback)
    call g:NERDTree.AddPathFilter(a:callback)
endfunction

" SECTION: Post Source Actions {{{1
call nerdtree#postSourceActions()

"reset &cpo back to users setting
let &cpo = s:old_cpo

" vim: set sw=4 sts=4 et fdm=marker:
