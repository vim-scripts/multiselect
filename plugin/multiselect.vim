" multiselect.vim
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 21-Oct-2004 @ 09:34
" Created: 21-Jan-2004
" Requires: Vim-6.2, multvals.vim(3.9), genutils.vim(1.12)
" Version: 1.2.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=953
" Acknowledgements:
"   - This plugin is based on the multipleRanges.vim script (vimscript#352)
"     version 1.7 by Salman Halim (salmanhalim at hotmail dot com). I first
"     started with the idea of adding additional features to this plugin, but
"     I quickly realized that implementing many of those ideas will be a lot
"     more work unless I use a full featured array functionality, which is why
"     I have rewritten it to use multvals.vim. Though most of the code has
"     been modified and a lot of new code has been added (so there is hardly
"     any code that you would see as same, except that it still has some
"     structural similarity), I give a lot of credit to Salman Halim for the
"     original ideas and to get me quickly started with this new plugin.
"
" Description:
"   - This plugin extends the Vim's visual mode functionality by allowing you
"     to define multiple selections before executing a command on them.
"   - Currently it is limited to the visual-by-line mode. There are other
"     limitations that exist, e.g., the selection is remembered by line
"     numbers, so insertions and deletions above the selections will not be
"     automatically taken care of.
"   - Here is a set of mappings (with applicable modes) and the equivalent
"     command that this plugin defines for each operation (for brevity, names
"     do not include the common prefix of <Plug>MS and defaults do not include
"     the common prefix of <Leader>):
"
"     Mapping Name               Default  Description~
"     AddSelection               msa  n,v Add current selection to the
"                                         selection list (MSAdd).
"                                <CR> v   if unused.
"                          Ctrl+LeftMouse Make multiple selections using mouse.
"     DeleteSelection            msd  n   Delete current selection (MSDelete).
"     ClearSelection             msc  n,v Clear selections in the given range or
"                                         the entire buffer (MSClear).
"     RestoreSelections          msr  n   Restore previous state of the
"                                         selections (MSRestore). After a
"                                         ClearSelection, this works like |gv|.
"     RefreshSelections          msf  n   Refresh/Redraw selections (MSRefresh).
"     HideSelections             msh  n   Hide the selections (MSHide). Use
"                                         MSRefresh to show the sections again.
"     InvertSelections           msi  n,v Invert the entire or selected
"                                         selection (MSInvert).
"     ExecCmdOnSelection         ms:  n   Execute a ex mode command on all the
"                                         selections (MSExecCmd).
"     ExecNormalCmdOnSelection   msn  n   Execute a normal mode command on all
"                                         the selections (MSExecNormalCmd).
"     ShowSelections             mss  n   Dump all the current selections on
"                                         the screen as "startline,endline"
"                                         pairs (MSShow).
"     NextSelection              ms]  n   Take cursor to the next selection
"                                         (MSNext).
"     PrevSelection              ms[  n   Take cursor to the previous selection
"                                         (MSPrev).
"     MatchAddSelection          msm  n,v Add matched lines to the selection
"                                         (MSMatchAdd).
"     VMatchAddSelection         msv  n,v Add unmatched lines to the selection
"                                         (MSVMatchAdd).
"
"     Note that the ex-mode commands that work on selections can also take
"     arbitrary ranges (see |:range|).
"
"   - To make it easier and quicker to add selections, the plugin unless
"     disabled by setting the g:no_multiselect_mousemaps, map the Ctrl+Mouse
"     combination to automatically add the current selection and start a new
"     one. Just keep the Ctrl key pressed and use left mouse to make
"     selections. If you are selecting single lines you don't even need to
"     drag mouse.
"
"     If you instead use keyboard to create visual selections, the plugin
"     automatically maps <Enter> (if it is not already mapped) such that you
"     can just press <Enter> to add the current selection. The cursor is
"     placed in the direction of the selection such that it is easier to
"     continue moving the cursor for making further selections. If you prefer,
"     you can also add the following mapping in your vimrc to use <Enter> key
"     to quickly make multiple single-line selections.
"
"       nnoremap <Enter> :MSAdd<CR>
"
"   - To allow other plugins access selections programmatically, the plugin
"     defines the following global functions (with prototypes):
"
"         boolean MSSelectionExists()
"         int     MSNumberOfSelections()
"         void    MSStartSelectionIter()
"         void    MSStopSelectionIter()
"         boolean MSHasNextSelection()
"         String  MSNextSelection()
"         " First line in the given selection.
"         int     MSFL(String sel)
"         " Last line in the given selection.
"         int     MSLL(String sel)
"         " If the plugin is current executing a command on the selection.
"         boolean MSIsExecuting()
"
"     However the operations are not limited to the above as the selections
"     themselves are stored as a multvals array in the buffer local variable
"     called b:multiselRanges (which may not exist if there are no selections
"     yet in the current buffer), with ":" as the separator and each element
"     as a "firstline,lastline" pair. You can use any multvals function to
"     manipulate this array. However it is recommended to stick with the
"     plugin API as far as possible, as the format of the array could be
"     changed in the future.
"
"     If your plugin depends on the existence of multiselect, it is
"     recommended to check the compatibility by comparing the value of
"     loaded_multiselect with what is expected. The format of this value is
"     exactly same as the |v:version|.
"
" Ex:
"   Delete all the lines in the current selections 
"     MSExecCmd d
"   Convert all the characters in the current selections to upper case.
"     MSExecNormalCmd gU
"
" Installation And Configuration:
"   - Drop the plugin in a plugin directory under your 'runtimepath'.
"   - Install the dependent multvals and genutils plugins.
"   - Configure any key bindings in the above table.
"   - Set g:multiselTmpMark if you don't like the default value 't'. This
"     specifies the mark name to be used internaly for keeping track of the
"     substitutions that split or join lines.
"   - Set g:multiselUseSynHi to 1 if you prefer using syntax highlighting over
"     :match highlight to highlight the selections. They both have advantages
"     and disadvantages, e.g., you can have multiple syntax highlighting rules
"     coexist, but only one :match highlighting can exist at any time in a
"     window (so if you have other plugins that depend on :match highlighting,
"     then you have a collision). However, highlighting selections by syntax
"     rules is not perfected yet, so in most cases, :match highlighting should
"     work better than syntax highlighting.
"   - Set g:multiselAbortOnErrors to 0 if you don't want the plugin to abort
"     on errors while executing commands on the selections. Alternatively, you
"     can pass in the appropriate flag/option to avoid generating an error
"     (such as 'e' flag to :substitute or :silent command in general)
"   - Customize MultiSelections highlighting group if you don't like the
"     default "reverse" video. E.g.:
"
"       hi MultiSelections guifg=grey90 guibg=black
"
"   - If you feel that the default mappings defined by the plugin are too
"     long, consider installing execmap.vim plugin from vim.org scripts
"     section.
"   - If you would like to change the modifiers that are used to add
"     selections through mouse (from the default Alt(or Meta)), use
"     g:multiselMouseSelAddMod variable. E.g. to use Alt+Shift (or Meta+Shift)
"     as the modifiers,
"
"       let g:multiselMouseSelAddMod = 'M-S-'
"
"     You can also change the mouse key that is to be used (Right instead of
"     Left, e.g.) by setting the g:multiselMouseSelAddKey variable. E.g. to
"     use Alt+RightMouse, you would set:
"
"       let g:multiselMouseSelAddMod = 'M-'
"       let g:multiselMouseSelAddKey = 'Right'
"
"     Of course, you could also remove the need to press modifiers by
"     setting g:multiselMouseSelAddMod to an empty string. You will then
"     essentially replace the normal Vim selection mechanism with that of the
"     plugin (not advisable if you use Vim's v and ^V modes very much).
" TODO:
"   - While executing commands on multiple ranges, there should be a way
"     to execute at least normal commands on each line in the range instead of
"     each range (useful for running on plugin windows).
"   - Implement yank and paste selections (\msy, \msp), but how should they
"     really work?
"   - Support different visual modes. The block mode could be quite
"     complicated to implement.

if exists('loaded_multiselect')
  finish
endif
if v:version < 602
  echomsg 'multiselect: You need at least Vim 6.2'
  finish
endif

" Dependency checks.
if !exists('loaded_multvals')
  runtime plugin/multvals.vim
endif
if !exists('loaded_multvals') || loaded_multvals < 309
  echomsg "multiselect: You need a newer version of multvals.vim plugin"
  finish
endif
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 112
  echomsg "multiselect: You need a newer version of genutils.vim plugin"
  finish
endif
let loaded_multiselect = 101

" Initializations {{{
if !exists('g:multiselTmpMark')
  let g:multiselTmpMark = 't'
endif

if !exists('g:multiselUseSynHi')
  let g:multiselUseSynHi = 0
endif

if !exists('g:multiselAbortOnErrors')
  let g:multiselAbortOnErrors = 1
endif

if !exists('g:multiselMouseSelAddMod')
  let g:multiselMouseSelAddMod = 'C-'
endif

if !exists('g:multiselMouseSelAddKey')
  let g:multiselMouseSelAddKey = 'Left'
endif

command! -range MSAdd :call <SID>AddSelection(<line1>, <line2>)
command! MSDelete :call <SID>DeleteSelection()
command! -range=% MSClear :call <SID>ClearSelection(<line1>, <line2>)
command! MSRestore :call <SID>RestoreSelections()
command! MSRefresh :call <SID>RefreshSelections()
command! -range MSInvert :call <SID>InvertSelections(<line1>, <line2>)
command! MSHide :call <SID>HideSelections()
command! -nargs=1 -complete=command MSExecCmd
      \ :call <SID>ExecCmdOnSelection(<q-args>, 0)
command! -nargs=1 -complete=command MSExecNormalCmd
      \ :call s:ExecCmdOnSelection(<q-args>, 1)
command! MSShow :call <SID>ShowSelections()
command! MSNext :call <SID>NextSelection(1)
command! MSPrev :call <SID>NextSelection(-1)
command! -range=% -nargs=1 MSMatchAdd :call <SID>AddSelectionsByMatch(<line1>,
      \ <line2>, <q-args>, 0)
command! -range=% -nargs=1 MSVMatchAdd :call <SID>AddSelectionsByMatch(<line1>,
      \ <line2>, <q-args>, 1)

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_multiselect_maps") || ! no_multiselect_maps) " [-2f]

if (! exists("no_multiselect_mousemaps") || ! no_multiselect_mousemaps)
  exec 'noremap <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Mouse> '.
        \ '<'.g:multiselMouseSelAddKey.'Mouse><Esc>V'
  exec 'noremap <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Drag> <'.g:multiselMouseSelAddKey.'Drag>'
  exec 'noremap <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Release> '.
        \ ':MSInvert<CR><'.g:multiselMouseSelAddKey.'Release>'
endif

if maparg('<Enter>', 'v') == ''
  vnoremap <Enter> m`:MSAdd<Enter>``
endif

function! s:AddMap(name, map, cmd, mode, silent)
  if (!hasmapto('<Plug>MS'.a:name, a:mode))
    exec a:mode.'map <unique> <Leader>'.a:map.' <Plug>MS'.a:name
  endif
  exec a:mode.'map '.(a:silent?'<silent> ':'').'<script> <Plug>MS'.a:name.
        \ ' '.a:cmd
endfunction

call s:AddMap('AddSelection', 'msa', 'm`:MSAdd<CR>``', 'v', 1)
call s:AddMap('AddSelection', 'msa', ':MSAdd<CR>', 'n', 1)
call s:AddMap('DeleteSelection', 'msd', ':MSDelete<CR>', 'n', 1)
call s:AddMap('ClearSelection', 'msc', ':MSClear<CR>', 'v', 1)
call s:AddMap('ClearSelection', 'msc', ':MSClear<CR>', 'n', 1)
call s:AddMap('RestoreSelections', 'msr', ':MSRestore<CR>', 'n', 1)
call s:AddMap('RefreshSelections', 'msf', ':MSRefresh<CR>', 'n', 1)
call s:AddMap('HideSelections', 'msh', ':MSHide<CR>', 'n', 1)
call s:AddMap('InvertSelections', 'msi', ':MSInvert<CR>', 'n', 1)
call s:AddMap('InvertSelections', 'msi', ':MSInvert<CR>', 'v', 1)
call s:AddMap('ShowSelections', 'mss', ':MSShow<CR>', 'n', 1)
call s:AddMap('NextSelection', 'ms]', ':MSNext<CR>', 'n', 1)
call s:AddMap('PrevSelection', 'ms[', ':MSPrev<CR>', 'n', 1)
call s:AddMap('ExecCmdOnSelection', 'ms:', ':MSExecCmd<Space>', 'n', 0)
call s:AddMap('ExecNormalCmdOnSelection', 'msn', ':MSExecNormalCmd<Space>', 'n',
      \ 0)
call s:AddMap('MatchAddSelection', 'msm', ':MSMatchAdd<Space>', 'v', 0)
call s:AddMap('MatchAddSelection', 'msm', ':MSMatchAdd<Space>', 'n', 0)
call s:AddMap('VMatchAddSelection', 'msv', ':MSVMatchAdd<Space>', 'v', 0)
call s:AddMap('VMatchAddSelection', 'msv', ':MSVMatchAdd<Space>', 'n', 0)

delf s:AddMap
endif

aug MultiSelect
  au!
  au BufLeave * :call <SID>_hideSelections()
  au BufEnter * :call <SID>DrawSelections()
  " WORKAROUND: The WinLeave event might have preceded by a BufLeave event
  "   that could have _hidden the selection, so as long as there is selection
  "   in the current buffer, just draw it again.
  au WinLeave * :call <SID>DrawSelections()
  au WinEnter * :call <SID>DrawSelections()
aug END

let s:inExecution = 0
" Initializations }}}

function! s:AddSelection(fline, lline) " {{{
  if !exists('b:multiselRanges')
    let b:multiselRanges = ''
  endif

  call s:SetSelRanges(MvAddElement(b:multiselRanges, ':',
        \ a:fline.','.a:lline))
  let b:multiselNeedsConsol = 1

  if g:multiselUseSynHi
    call s:HighlightRange(a:fline, a:lline)
  else
    call s:MatchRanges()
  endif
endfunction " }}}

function! s:ClearSelection(fline, lline) " {{{
  if !MSSelectionExists()
    return
  endif

  " When the range refers to the entire file or when MSClear is executed with
  " '%' as range.
  if a:fline == 1 && a:lline == line('$')
    call s:_hideSelections()
    call s:SetSelRanges('')
  else
    call s:ConsolidateSelections()

    let curSel = ''
    let newSel = ''
    call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
    while MvIterHasNext('MultiSelect')
      let curSel = MvIterNext('MultiSelect')
      let fl = MSFL(curSel)
      let ll = MSLL(curSel)
      " Check if this selection intersects with what needs to be deleted.
      if      (fl >= a:fline) && (fl <= a:lline) ||
            \ (a:fline >= fl) && (a:fline <= ll)
        let pt1 = s:Min(fl, a:fline)
        let pt2 = s:Max(fl, a:fline)
        let pt3 = s:Min(ll, a:lline)
        let pt4 = s:Max(ll, a:lline)
        if pt1 != pt2 && fl == pt1
          let newSel = MvAddElement(newSel, ':', pt1.','.(pt2 - 1))
        endif
        if pt3 != pt4 && ll == pt4
          let fl = pt3 + 1
          let ll = pt4
        else
          continue
        endif
      endif
      let newSel = MvAddElement(newSel, ':', fl.','.ll)
    endwhile
    call MvIterDestroy('MultiSelect')
    if newSel == ''
      MSClear
    else
      call s:SetSelRanges(newSel)
      MSRefresh
    endif
  endif
endfunction " }}}

function! s:ShowSelections() " {{{
  if MSSelectionExists()
    call s:ConsolidateSelections()

    let curSel = ''
    call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
    while MvIterHasNext('MultiSelect')
      let curSel = MvIterNext('MultiSelect')
      exec 'let nLines = (-1 * ('.substitute(curSel, ',', '-', '').' - 1))'
      echo curSel . ' (' . nLines . ' lines)'
    endwhile
    call MvIterDestroy('MultiSelect')
  endif
endfunction " }}}

function! s:DeleteSelection() " {{{
  if !MSSelectionExists()
    return
  endif

  call s:ConsolidateSelections()
  let curSelSt = MvNumSearchNext(substitute(b:multiselRanges, ',\d\+', '',
        \ 'g'), ':', line('.'), -1)
  if curSelSt != ''
    let sel = MvElementLike(b:multiselRanges, ':', curSelSt.',\d\+')
    " Remove only if the cursor is in the selection.
    if sel != '' && !(MSFL(sel) <= line('.') && MSLL(sel) >= line('.'))
      " Check if the next selection is in the range.
      let index = MvIndexOfElement(b:multiselRanges, ':', sel)
      let sel = MvElementAt(b:multiselRanges, ':', index+1)
      if sel != '' && !(MSFL(sel) <= line('.') && MSLL(sel) >= line('.'))
        let sel = '' " No matching selection.
      endif
    endif
    if sel != ''
      let newSel = MvRemoveElement(b:multiselRanges, ':', sel)
      if newSel == ''
        MSClear
      else
        call s:SetSelRanges(newSel)
        MSRefresh
      endif
    endif
  endif
endfunction " }}}

function! s:RestoreSelections()"{{{
  if exists('b:_multiselRanges')
    let b:multiselRanges = b:_multiselRanges
    MSRefresh
  endif
endfunction"}}}

function! s:IsSelectionHidden() " {{{
  if exists('b:multiselHidden') && b:multiselHidden
    return 1
  else
    return 0
  endif
endfunction " }}}

function! s:HideSelections() " {{{
  if !MSSelectionExists() || s:IsSelectionHidden()
    return
  endif

  call s:_hideSelections()
  let b:multiselHidden = 1
endfunction " }}}

" I need a better name for this function.
function! s:_hideSelections() " {{{
  if s:IsSelectionHidden()
    return
  endif

  if g:multiselUseSynHi
    " Actually, should not be required.
    syn clear MultiSelections
  else
    match NONE
  endif
endfunction " }}}

function! s:RefreshSelections() " {{{
  MSHide

  let b:multiselHidden = 0
  if !MSSelectionExists()
    return
  endif

  call s:DrawSelections()
endfunction }}}

function! s:DrawSelections() " {{{
  if !MSSelectionExists() || s:IsSelectionHidden()
    return
  endif

  call SaveHardPosition('RefreshSelections')

  if g:multiselUseSynHi
    call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
    while MvIterHasNext('MultiSelect')
      let curSel = MvIterNext('MultiSelect')
      exec 'call s:HighlightRange('.curSel.')'
    endwhile
    call MvIterDestroy('MultiSelect')
  else
    call s:MatchRanges()
  endif

  call RestoreHardPosition('RefreshSelections')
  call ResetHardPosition('RefreshSelections')
endfunction " }}}

function! s:InvertSelections(fline, lline) " {{{
  call s:ConsolidateSelections()

  let curSel = ''
  let nexSel = ''
  let invSel = ''
  let intersectedAny = 0
  " To track ranges that are across multiple selections, we need a dynamic
  " range.
  let fline = a:fline
  let lline = a:lline
  let nextfl = fline
  let nextll = lline
  call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
  while MvIterHasNext('MultiSelect')
    let curSel = MvIterNext('MultiSelect')
    let selfl = MSFL(curSel)
    let selll = MSLL(curSel)
    if selll < fline || selfl > lline
      " No intersection.
      let invSel = MvAddElement(invSel, ':', curSel)
      continue
    endif
    " FIXME: Check if the selections went beyond the range and skip this
    " (optimization).
    let intersectedAny = 1

    let nexSel = MvIterPeek('MultiSelect')
    " If the range spawns across multiple selections, we need to handle it.
    if nexSel != '' && lline >= MSFL(nexSel)
      let nextfl = MSFL(nexSel)
      let nextll = lline
      let lline = MSFL(nexSel) - 1
    endif

    let pt1 = s:Min(selfl, fline)
    let pt2 = s:Max(selfl, fline)
    let pt3 = s:Min(selll, lline)
    let pt4 = s:Max(selll, lline)
    if pt1 != pt2
      let invSel = MvAddElement(invSel, ':', pt1.','.(pt2 - 1))
    endif
    if pt3 != pt4
      let invSel = MvAddElement(invSel, ':', (pt3 + 1).','.pt4)
    endif

    let fline = nextfl
    let lline = nextll
  endwhile
  call MvIterDestroy('MultiSelect')
  if !intersectedAny
    let invSel = MvAddElement(invSel, ':', fline.','.lline)
  endif

  if invSel == ''
    MSClear
  else
    call s:SetSelRanges(invSel)
    MSRefresh
  endif
endfunction " }}}

" Add selection ranges for the matched pattern.
function! s:AddSelectionsByMatch(fline, lline, pat, negate) " {{{
  if ! MSSelectionExists()
    let b:multiselRanges = ''
  endif

  let i = a:fline
  let cnt = 0
  let newSel = b:multiselRanges
  let fl = -1
  while 1
    let result = match(getline(i), a:pat)
    if (!a:negate && result > -1) || (a:negate && result == -1) &&
          \ (i <= a:lline)
      if fl == -1
        let fl = i
      endif
    else
      if fl != -1
        let ll = i - 1
        let newSel = MvAddElement(newSel, ':', fl.','.ll)
        let fl = -1
        let cnt = cnt + 1
      endif
    endif
    if i > a:lline
      break
    endif
    let i = i + 1
  endwhile
  if cnt > 0
    call s:SetSelRanges(newSel)
    MSRefresh
  endif
  echo 'Total selections added: '.cnt
endfunction " }}}

function! s:ExecCmdOnSelection(theCommand, normalMode) " {{{
  if !MSSelectionExists()
    return
  endif

  call s:ConsolidateSelections()

  let curSel = ''
  let offset = 0
  let bufNr = bufnr('%') + 0 
  call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
  try
    while MvIterHasNext('MultiSelect')
      let curSel = MvIterNext('MultiSelect')
      let fl = MSFL(curSel) + offset
      let ll = MSLL(curSel) + offset
      if ll != line('$')
        exec (ll+1).'mark '.((g:multiselTmpMark != '') ? g:multiselTmpMark : 't')
      endif
      let v:errmsg = ''
      let s:inExecution = 1
      if a:normalMode
        execute 'normal! '.fl.'GV'.ll.'G'
        execute 'normal ' . a:theCommand
      else
        execute fl.','.ll.' '.a:theCommand
      endif
      if g:multiselAbortOnErrors && v:errmsg != ''
        echohl ERROR | echo "ABORTED due to errors" | echohl NONE
      endif

      " Make sure we are still in the right window. If not, we can still find
      " and move cursor to the right window. Not having the buffer open in any
      " window is considered an error condition.
      if bufnr('%') != bufNr
        let winNr = bufwinnr(bufNr)
        if winNr == -1
          echohl ERROR | echo 'Execution ABORTED because the original buffer'.
                \ ' is no longer visible' | echohl NONE
          return
        endif
        exec winNr'wincmd w'
      endif

      " Strictly speaking, this should be done only if ll was not the last line
      "   in the file, but there is no harm if done unconditionally.
      let offset = offset + line("'t") - (ll + 1)
    endwhile
  finally
    call MvIterDestroy('MultiSelect')
    let s:inExecution = 0
  endtry
  " FIXME: Clear the g:multiselTmpMark (feature coming up in new Vim release).
endfunction " }}}

" Utilities {{{
function! s:SetSelRanges(newSel)
  if exists('b:multiselRanges')
    let b:_multiselRanges = b:multiselRanges
  endif
  let b:multiselRanges = a:newSel
endfunction

function! s:ConsolidateSelections() " {{{
  if ! exists('b:multiselNeedsConsol') || ! b:multiselNeedsConsol
    return
  endif

  call s:SortSelections()

  let numConsolidations = 0
  let prevSel = ''
  let curSel = ''
  let consoldSel = ''
  call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
  while MvIterHasNext('MultiSelect')
    let curSel = MvIterNext('MultiSelect')
    if prevSel == ''
      let prevSel = curSel
      continue
    endif

    if MSLL(prevSel) >= (MSFL(curSel) - 1)
      " Next selection is with in the current selection range, ignore.
      if MSLL(curSel) <= MSLL(prevSel)
        continue
      endif
      " echo "Consolidating " . prevSel . " and " . curSel
      let prevSel = MSFL(prevSel).','.MSLL(curSel)
      let numConsolidations = numConsolidations + 1
    else
      let consoldSel = MvAddElement(consoldSel, ':', prevSel)
      let prevSel = curSel
    endif
  endwhile
  call MvIterDestroy('MultiSelect')
  let b:multiselRanges = MvAddElement(consoldSel, ':', prevSel)
  let b:multiselNeedsConsol = 0
endfunction " }}}

function! s:HighlightRange(ffline, lline) " {{{
  if s:IsSelectionHidden()
    return
  endif

  execute "syn match MultiSelections '\\%" . a:fline .
        \ "l\\_.*\\%" . a:lline . "l' containedin=ALL"
  execute "syn match MultiSelections '\\%" . a:fline .
        \ "l\\_.*\\%" . a:lline . "l' contains=ALL"
endfunction " }}}

function! s:MatchRanges() " {{{
  if s:IsSelectionHidden()
    return
  endif

  " CUATION: This should typically be done only once, as part of the plugin
  "   startup, but some plugins like SpellChecker.vim when turned off, remove
  "   all highlighting groups, so it is better that we do this everytime.  The
  "   highlight scheme to show the selection.
  hi default MultiSelections gui=reverse term=reverse cterm=reverse

  let matchPat = substitute(substitute(b:multiselRanges, ':$', '', ''),
        \ '\(^\|:\)\(\d\+\),\(\d\+\)',
        \ '\=(submatch(1)==#":"?"\\|":"")."\\%>".'.
        \   '(submatch(2)-1)."l\\%<".(submatch(3)+1)."l"', 'g')
  execute "match MultiSelections '".matchPat."'"
endfunction " }}}

function! s:SortSelections()
  let b:multiselRanges = MvQSortElements(b:multiselRanges, ':',
        \ 'CmpByNumber', 1)
endfunction

function! s:NextSelection(dir) " {{{
  if !MSSelectionExists()
    return
  endif

  call s:ConsolidateSelections()
  let nextSel = MvNumSearchNext(substitute(b:multiselRanges, ',\d\+', '', 'g'),
        \ ':', line('.'), a:dir)
  if nextSel != ''
    exec nextSel
  endif
endfunction " }}}

function! s:Min(num1, num2)
  return (a:num1 < a:num2) ? a:num1 : a:num2
endfunction

function! s:Max(num1, num2)
  return (a:num1 > a:num2) ? a:num1 : a:num2
endfunction

" Function to heuristically determine if the user meant the range as the whole
"   file, when the default range for the command is only the current line
"   (workaround to avoid the cursor getting reset to firstline).
function! s:MayBeRangeIsWholeFile(fline, lline)
  if (a:fline == a:lline && a:fline == line('.') &&
        \  !(line("'<") == line("'>") && a:fline == line("'<")))
    return 1
  else
    return 0
  endif
endfunction
" Utilities }}}

" Public interface {{{
function! MSSelectionExists()
  return exists('b:multiselRanges') && b:multiselRanges != ''
endfunction

function! MSNumberOfSelections()
  return MvNumberOfElements(b:multiselRanges, ':')
endfunction

function! MSStartSelectionIter()
  call MvIterCreate(b:multiselRanges, ':', 'MultiSelect')
endfunction

function! MSStopSelectionIter()
  call MvIterDestroy('MultiSelect')
endfunction

function! MSHasNextSelection()
  return MvIterHasNext('MultiSelect')
endfunction

function! MSNextSelection()
  return MvIterNext('MultiSelect')
endfunction

function! MSFL(sel)
  return substitute(a:sel, ',.*$', '', '')+0
endfunction

function! MSLL(sel)
  return substitute(a:sel, '^.*,', '', '')+0
endfunction

function! MSIsExecuting()
  return s:inExecution
endfunction
" Public interface }}}

" vim6:fdm=marker et sw=2
