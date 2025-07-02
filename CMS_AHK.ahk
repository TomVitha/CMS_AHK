#Requires AutoHotkey v2.0

;    # = WIN
;    ! = Alt
;    ^ = Ctrl
;    + = Shift
;    & = Combines two keys into hotkey
;    < = Use the left key of the pair. e.g. <!a is the same as !a except that only the left Alt will trigger it
;    > = Use the right key of the pair.
;    <^>! = AltGr
;    * = Wildcard
;    ~ = Prevents key's native function from being blocked
;    $ = Only necessary if the script uses the Send command to send the keys that comprise the hotkey itself, which might otherwise cause it to trigger itself.


#Warn                       ; Enables every type of warning and shows each warning in a message box.
SendMode "Input"
SetWorkingDir A_ScriptDir
;#Include A_ScriptDir       ; Changes the working directory for subsequent #Includes and FileInstalls.
#SingleInstance force
; InstallKeybdHook 

; INCLUDES
#Include include\ScriptIsRunningTrayTip_AHKv2.ahk             ; Displays a tray tip on script start
#Include "include\Alt_menu_acceleration_DISABLER_AHKv2.ahk"

; Custom tray icon
TraySetIcon "support_media/cms_ahk.ico"


; # DEFINITIONS
FindSaveButton()
{
    CoordMode "Mouse", "Screen"     ; Mouse set relative to screen
    MouseGetPos &startX, &StartY    ; Save mouse's starting position (rel to screen)

    ; Relative to client (window excl. title bar etc.)
    CoordMode "Mouse", "Client"
    CoordMode "Pixel", "Client"

    WinGetPos &X, &Y, &W, &H, "A"   ; Gets window's position and size

    ; Looks for 'Uložit' or 'Vytvořit nový obsah' buttons
    if not (ImageSearch(&OutputVarX, &OutputVarY, 0, 0, W, H, "support_media/CMS-Ulozit.png") or ImageSearch(&OutputVarX, &OutputVarY, 0, 0, W, H, "support_media/CMS-Vytvorit_novy_obsah.png")) {
        TrayTip "Tlačítko Uložit nenalezeno"
        Sleep 2000   ; Displays for 2000ms
        TrayTip
        return
    }
    
    MouseClick "Left", OutputVarX, OutputVarY
    CoordMode "Mouse", "Screen"
    MouseMove startX, startY
}

NewPaste() {
    clipboardLines := StrSplit(A_Clipboard, "`n", "`r").length
    newLines := clipboardLines-1

    if (newLines > 0) {
        SendInput "{" "Enter " newLines "}"
        SendInput "{" "Up " newLines "}"
        SendInput "{End}"
    }

    ; CTRL+V
    SendInput "{Ctrl down}"
    SendInput "v"
    SendInput "{Blind}{Ctrl Up}" ; {Blind} prevents CTRL from remaining "stuck"

    ; ! WMS is too slow to create new lines and paste text - Time to wait in ms per line
    Sleep (clipboardLines * 35)

    return
}

ParseAbbreviation(input) {
    result := {}
    result.tag  := "div"  ; defaults to 'div' if no tag is specified
    result.class := ""
    result.id := ""

    pattern := "((?:[.#])?[^.#]+)"
    while (RegExMatch(input, pattern, &match, (A_Index == 1 ? 1 : pos+StrLen(match[]))))
    {
        pos := InStr(input, match[])
        prefix := SubStr(match[], 1, 1)
        value := SubStr(match[], 2)  ; the actual value without prefix

        if (prefix == ".") {
            result.class .= (result.class ? " " : "") . value
        } else if (prefix == "#") {
            result.id .= (result.id ? " " : "") . value
        } else {
            result.tag := match[]  ; no prefix means it's the tag
        }
    }

    return result
}

WrapWithAbbreviation(input){
    ; Save the current clipboard contents
    clipboardBackup := ClipboardAll()
    selectedText := ""
    ; Clear the clipboard
    A_Clipboard := ""

    SendInput "^c"              ; Ctrl + C (copy)
    ClipWait 0.25               ; Waits until the clipboard contains data; Will wait no longer than 0.25 second

    ; * If clipboard not empty / If text was selected
    if (A_Clipboard) {
        selectedText := A_Clipboard
    }

    ; * Parses user's input *
    parsed := ParseAbbreviation(input)

    attributes := ""
    selfClosing := false

    ; * Element content (by default selected text)
    ; * some elements may not contain (only) the selected text
    ; content := selectedText


    ; ? Special Cases ?
    switch parsed.tag
    {
    case "a":
        attributes := 'href=""'
    case "br":
        selfClosing := true
    case "hr":
        selfClosing := true
    case "img":
        attributes := 'src="' . selectedText . '" alt=""'
        selfClosing := true
        selectedText := ""
    case "input":
        attributes := 'type="" id="" name="" value=""'
        selfClosing := true
    case "label":
        attributes := 'for=""'
    case "link":
        attributes := 'rel="stylesheet" href="' . selectedText . '"'
        selfClosing := true
    ; case "meta":
    ;     attributes := 'name="" content="' . selectedText . '"'
    ;     selfClosing := true
    case "option":
        attributes := 'value=""'
    ; case "picture":
    ;     if (!selectedText){
    ;         ; todo - picture with source and img inside
    ;     }
    case "source":
        attributes := 'type="" src="" srcset="" sizes="" media=""'
        selfClosing := true
    case "time":
        attributes := 'datetime=""'
    case "video":
        attributes := 'poster="" loop muted disablePictureInPicture'
        selfClosing := true
    default:
    }


    hasClassAttr := false
    hasIDAttr := false

    if RegExMatch(input, "\.") {
        hasClassAttr := true
    }
    if RegExMatch(input, "\#") {
        hasIDAttr := true
    }


    ; ? Opening Tag Construction ?
    ; Opens opening tag
    openingTag := '<' . parsed.tag . ' '
    
    ; * Inserts Class
    ; If user specified class with value
    if (parsed.class)
        openingTag .= 'class="' . parsed.class . '" '
    ; If user specified class without value (empty attribute)
    else if (hasClassAttr)
        openingTag .= 'class="" '

    ; * Inserts ID
    ; If user specified ID with value
    if (parsed.id) 
        openingTag .= 'id="' . parsed.id . '" '
    ; If user specified ID without value (empty attribute)
    else if (hasIDAttr)
        openingTag .= 'id="" '

    ; * Inserts Attributes
    if (attributes)
        openingTag .= attributes

    ; Removes trailing space
    openingTag := RegExReplace(openingTag, "\s+$") ; * Regex: matches one or more whitespace characters (including spaces, tabs, etc.) at the end of the string and removes them
    trailingSlash := false ; Whether to include trailing slash for self-closing (void) elements

    ; Closes opening tag
    if (trailingSlash and selfClosing)
        openingTag .= '/>'  
    else
        openingTag .= '>'
    ; ? Opening Tag Construction (end)


    ; ? Closing Tag Construction
    ; Construct closing tag if not self-closing
    closingTag := ""
    if (!selfClosing) {
        closingTag := '</' . parsed.tag . '>'
    }

    ; ? Output construction
    out := openingTag . selectedText . closingTag

    clipboardLines := StrSplit(A_Clipboard, "`n", "`r").length
    if (clipboardLines > 1) {
        SendText openingTag
        SendText closingTag
        SendInput "{" "Left " StrLen(closingTag) "}"    ; Moves caret in between tags
        SendInput "{Enter}{Enter}{Up}"
        SendInput "{Tab}"                               ; Indent
        ; SendText selectedText                         ; SendText is too slow for large texts, should use clipboard instead
        NewPaste()
    } else {
        SendText out
    }

    ; Move caret in between tags (if no text was selected)
    if (!selectedText) and (!selfClosing){
        SendInput "{" "Left " StrLen(closingTag) "}"
    }

    ; Restores clipboard
    A_Clipboard := clipboardBackup
    clipboardBackup := ""               ; Free the memory in case the clipboard was very large

    return
}
; * DEFINITIONS (end)



#HotIf WinActive("ahk_exe cmscg.exe") and WinActive("Editace obsahu prvku Text")

; # Ctrl+S
; * Clicks the Save button
^s::{
    FindSaveButton()
}

; TODO: CTRL+Shift+S => Uložit nový obsah (pokud najde tlačítka "Uložit" a "Vytvořit nový obsah")

; # Escape, Ctrl+W
; * Gives option to save/discard changes or cancel
Esc::
^w::
{

    Okno := MsgBox("Uložit změny?", "Zavřít a uložit", "YesNoCancel")
    if (Okno = "Yes") {
        FindSaveButton()
    }
    else if (Okno = "No") {
        SendInput "{Esc}"   ;Esc closes the windows
    }
    else {
        ;MsgBox ("cancel")  ; Does nothing
    }

}

; TODO: Add functionality to fix CMS behavior - After performing a CTRL hotkey and keep holding ctrl, then ctrl doesn't stay pressed; unable to perform subsequent ctrl actions without releasing and pressing ctrl again
; # Ctrl+V
; * Replaces default paste behavior - Creates new lines to prevent overwrite and pastes clipboard text
^v::{
    NewPaste()
}

; # Ctrl+Shift+V => Ctrl+V
; * Default paste ('overwrite' behavior)
^+v::^v

; # Ctrl+Shift+Z => Ctrl+Y
^+z::^y


CommentUncomment(commentType := "html") {
    clipboardBackup := ClipboardAll()       ; Save current clipboard contents
    A_Clipboard := ""                       ; Clear the clipboard
    
    ; Set comment tags based on type  
    if (commentType = "html") {
        openingCommentTag := "<!--"
        closingCommentTag := "-->"
        commentPattern := "^<!--(.*)-->$"
        hasClosingCommentTag := true
    } else if (commentType = "css") {
        openingCommentTag := "/*"
        closingCommentTag := "*/"
        commentPattern := "^/\*(.*)\*/$"
        hasClosingCommentTag := true
    } else if (commentType = "js") {
        openingCommentTag := "//"
        closingCommentTag := ""
        commentPattern := "^//(.*)$"
        hasClosingCommentTag := false
    }
        
    ; Select the whole line
    SendInput "{End}+{Home}"                ; Same as "{End}{LShift down}{Home}{LShift up}"
    
    SendInput "^c"                          ; Ctrl + C (copy)
    ClipWait(1)                             ; Wait up to 1 second for clipboard
    selectedText := A_Clipboard             ; Store clipboard contents

    ; Multiline (returns; not currently supported)
    clipboardLines := StrSplit(selectedText, "`n", "`r").length
    if (clipboardLines > 1) {
        Goto End                            ; Cheeky goto
    }
    
    ; If wrapped in comment tags, remove them
    if (selectedText ~= commentPattern) {
        unWrappedText := RegExReplace(selectedText, commentPattern, "$1")
        SendText unWrappedText
    } else {
        ; Not commented - add comment tags
        if (hasClosingCommentTag) {
            ; For HTML and CSS, wrap with opening and closing tags
            SendInput "{End}"
            SendText closingCommentTag
            SendInput "{Home}"
            SendText openingCommentTag
            SendInput "{End}"
        } else {
            ; For JavaScript, just prepend the comment marker
            SendInput "{End}"
            SendInput "{Home}"
            SendText openingCommentTag
        }
    }
    
    End:
    A_Clipboard := clipboardBackup          ; Restore clipboard
    clipboardBackup := ""                   ; Free memory
    
    return
}

; # Ctrl+/ (Numpad/)
; * HTML Comment
^NumpadDiv::{
    CommentUncomment("html")
}

; # Ctrl+* (Numpad*)
; * CSS Comment
^NumpadMult::{
    CommentUncomment("css")
}

; # Ctrl+Shift+/ (Numpad/)
; * JS Comment
^+NumpadDiv::{
    CommentUncomment("js")
}

; # Alt + W
; * Wrap with abbreviation (like Emmet Abbreviation in VSCode)
!w::{
    abbr := InputBox("", "Zadejte zkratku", "w370 h70", "div")
    ; Cancel if cancel
    if abbr.Result = "Cancel"{
        return
    }
    abbrIn := abbr.value
    WrapWithAbbreviation(abbrIn)
}

; # Ctrl+B -> <strong>
^b::WrapWithAbbreviation('strong')

; # Ctrl+I -> <strong>
^i::WrapWithAbbreviation('i')

; # Ctrl+P -> <p>
^p::WrapWithAbbreviation('p')

; # Ctrl+L -> <li>
^l::WrapWithAbbreviation('li')

; ** Check the next character after the caret
; ! Issue: Checking for next character doesn't work when caret is at the end of text (when no characters follow)
CheckNextChar(wantedChar) {
    SendInput "{LShift down}{Right}{Blind}{LShift up}^c"
    if (!ClipWait(1))
        return                  ; Return if clipboard isn't filled within 1 second
    sleep 10
    nextChar := A_Clipboard

    if (nextChar == wantedChar) {
        ; Next char is wanted char
        SendInput "{Left}"
        return true
    } else if (!nextChar) {
        ; No next char
        return false
    } else {
        ; Next char is different than wanted char
        SendInput "{Left}"
        return false
    }
    
}

; Wrap text in paired characters
; ! Bug: Sometimes pastes previous clipboard contents instead of opening and closing characters
WrapInPairedChars(openChar, closeChar := openChar) {

    if !openChar
        return

    ; Store and clear clipboard
    clipboardBackup := ClipboardAll()
    A_Clipboard := ""           ; Clear the clipboard

    SendInput "^x"              ; Ctrl + X (cut)
    if (!ClipWait(1))
        goto exit   ; Exit if clipboard isn't filled within 1s

    selectedText := A_Clipboard

    ; TODO: Implement multiline support
    ; TODO: Implement check for following closing character (CheckNextChar(closeChar))

    ; if(!selectedText and CheckNextChar(closeChar)){
    ;     SendInput "{Right}"
    ;     goto exit
    ; }

    clipboardLines := StrSplit(selectedText, "`n", "`r").length
    if (clipboardLines > 1) {
        SendText openChar
        SendText closeChar
        SendInput "{" "Left " StrLen(closeChar) "}"    ; Moves caret in between tags
        SendInput "{Enter}{Enter}{Up}"
        SendInput "{Tab}"                               ; Indent
        NewPaste()
    } else {
        A_Clipboard := openChar . selectedText . closeChar   ; Fill clipboard with wrapped text
        NewPaste()
        
    }

    exit:
    A_Clipboard := clipboardBackup      ; Restores clipboard
    clipboardBackup := ""               ; Free the memory in case the clipboard was very large
}

; ! Wrapping temp disabled - it's a bitch if you don't want wrapping/autocomplete

; ; # "
; ; * Wrap selected text in quotation marks
; "::{
;     WrapInPairedChars('"')
; }

; ; # '
; ; * Wrap selected text in single quotes
; '::{
;     WrapInPairedChars("'")
; }

; ; # (
; ; * Wrap selected text in parentheses
; (::{
;     WrapInPairedChars("(", ")")
; }

; # CTRL+T
; * Take copied row from Úložiště, parse, get tags, format, paste tags
^t::{
    input := InputBox("Vložte řádek obrázku z úložiště", "Automatické vypsání tagů", "w370 h95")

    if (input.Result = "Cancel")
        return

    if (!input.value)
        return

    ; Parse columns, get tags
    tagsString := StrSplit(input.value , [A_Tab])[6]
    ; Remove spaces (replace spaces with nothing)
    tagsString := StrReplace(tagsString, A_Space)

    if (!tagsString) {
        MsgBox('Neobsahuje žádné tagy')
        return
    }
    ; ! WRONG - JV cell from filename does not correspond to a tag -> JV still needs to be added manually as a tag
    /*
    tagJV := StrSplit(input.value , [A_Tab])[3]
    ; If JV specified (cell is not just whitespace and contains letters)
    if (RegExMatch(tagJV, "\S") && RegExMatch(tagJV, "[A-Za-z]")) {
        tagsString := tagsString . ';JV=' . tagJV           ; Append JV to the tags
    }
    */
   
    ; Parse tags array into individual tags
    ; tagsArray := StrSplit(tagsString , ";")
    ; for index, tag in tagsArray{
    ;     MsgBox(tag)
    ; }

    ; Replace separators ";" (semicolons) with " " (spaces)
    output := '{{' . 'documentUrl ' . StrReplace(tagsString , ";", A_Space) . '}}'
    SendText output
}

; # Ctrl+D and Shift+Alt+Down 
; * Duplicates line down
^d::
+!Down::{

    clipboardBackup := ClipboardAll()   ; Save the current clipboard contents
    A_Clipboard := ""                   ; Clear the clipboard
    selectedText := ""

    SendInput "^c"                      ; Ctrl + C (copy)
    ClipWait 0.5                        ; Waits until the clipboard contains data up to given number of seconds

    ; * If clipboard not empty / If text was selected
    if (A_Clipboard)
        selectedText := A_Clipboard

    clipboardLines := StrSplit(selectedText, "`n", "`r").length

    if (clipboardLines > 1) {
        ; TODO: Add multiline support
        /*
        SendInput "^x"                      ; Ctrl + X (cut)
        ClipWait 1                        ; Waits until the clipboard contains data up to given seconds
        NewPaste()
        SendInput "{Enter}"
        NewPaste()
        */
        ; MsgBox("Multiline support currently unavailable.")
    } else {
        SendInput "{End}{LShift down}{Home}{Home}{LShift up}"
        SendInput "^c"
        ClipWait 1                  ; Waits until the clipboard contains data; Will wait no longer than 1 second
        SendInput "{End}{Enter}"
        ; SendInput "^v"
        NewPaste()
        Sleep(15)                   ; ! TEMP
        SendInput "{End}"
    }  
    
    ; ! TEMP off
    /*
    A_Clipboard := clipboardBackup      ; Restores clipboard
    clipboardBackup := ""               ; Free the memory in case the clipboard was very large
    */

    return
}

; # Ctrl+Shift+D, Shift+Alt+Up 
; * Duplicates line up
^+d::
+!Up::{
    SendInput "{End}{Home}{Home}{LShift down}{End}{LShift up}"
    SendInput "^c"
    ClipWait 1
    SendInput "{Home}{Home}{Enter}{Up}"
    SendInput "^v"
    SendInput "{End}"    
}

; # Alt+Up
; * Moves line up 
!Up::{
    SendInput "{End}{LShift down}{Home}{Home}{LShift up}"
    SendInput "^x"
    ClipWait 1
    SendInput "{Backspace}{End}{Home}{Home}{Enter}{Up}"
    SendInput "^v"
}

; # Alt+Down
; * Moves line down
!Down::{
    SendInput "{End}{LShift down}{Home}{Home}{LShift up}"
    SendInput "^x"
    ClipWait 1
    SendInput "{Del}{End}{Enter}"
    SendInput "^v"
}

; # Ctrl+ú => Shift+Tab
; * Unindent line
^ú::+Tab

; # Ctrl+) => Tab
; * Indent line
^)::Tab

; # Ctrl+Shift+K, Ctrl+- (Ctrl + minus)
; * Deletes line
^+k::
^NumpadSub::{
    SendInput "{End}{Shift down}{Home}{Home}{Shift up}{Del}{Del}"
}

; # Ctrl+Tab, Ctrl+Shift+Tab
; * Prevents switching to Editace Textu
^Tab::
^+Tab::{
    ; Literally do nothing
}

; # Ctrl + PageUp => Arrow Up
^PgUp::Up

; # Ctrl + PageDown => Arrow Down
^PgDn::Down

; WIP
; # Ctrl + Enter
; * Create new line with indent
^Enter::{
    SendInput "{Enter 2}{Up 2}"
    SendInput "+{End}"                                          ; Select whole line
    
    SendInput "^c"                                              ; Ctrl + C (copy)
    ClipWait
    Sleep 30

    SendInput "{End}{Home 2}"                                   ; Move caret to the beginning of the line (consistent method)

    indent := ""
    if RegExMatch(A_Clipboard, "^(\s*)", &match) 
        indent := match[1]                                      ; Store captured whitespace

    if (StrLen(indent) = 0) {
        SendInput "{Down}{Tab}"
    } else {
        A_Clipboard := indent
        SendInput "{Down 2}"
        SendInput "^v" ; Ctrl + V (paste)
        Sleep 25
        SendInput "{Up}{Home}"
        SendInput "{Tab}"                                       ; Tab (indent)
        SendInput "^v" ; Ctrl + V (paste)
        Sleep 25
    }
}

; # Ctrl + Shift + R
; * Resize and center editor window
^+r::{
    windowWidth := 1800
    windowHeight := 1150
    ; WinMove [X, Y, Width, Height, WinTitle, WinText, ExcludeTitle, ExcludeText]
    WinMove((A_ScreenWidth/2)-(windowWidth/2), (A_ScreenHeight/2)-(windowHeight/2), windowWidth, windowHeight)
}

; # HOTSTRING

; ! Hotstrings_HTML1 must be above Hotstrings_HTML2 to avoid conflicts
; Todo: include attributes in selected elements (eg <a href="...">)
#Include "include\Hotstrings_HTML1.ahk"                         ; Writing opening <tag> autocompletes closing </tag>
#Include "include\Hotstrings_HTML2.ahk"                         ; Plain tag name + tab -> opening + closing tag

; Auto-complete comments
:*b0:<!--::-->{left 3}
:*b0:/*::*/{left 2}

#HotIf WinActive("ahk_exe cmscg.exe") and ( WinActive("Kolekce stránek") or WinActive("Detail WWW stránky") or WinActive("Název stránky") or WinActive("Find") or WinActive("HZ (Změna tagů)") or WinActive("Definice hodnot typu tagů pro filtr") or WinActive("Detail položky menu") )

; # Ctrl+Backspace
^Backspace::{
    SendInput "^+{Left}{Backspace}"
}

; NOTE: Version hard-coded, needs to be updated
; TODO: Make WinTitle dynamic
#HotIf WinActive("ahk_exe cmscg.exe") or WinActive("CMS CG v6.5.55.0 - [Správa obrázků]")

; # CTRL + ALT + 1
; * Imports all files in folder
^!Numpad1:: {
    CoordMode "Mouse", "Client"
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    ; Looking for yellow background behind list items
    if not (PixelSearch(&Px, &Py, 0, 0, WinW, WinH, 0xfafad2, 0)) {
        MsgBox "Color not found."
        return
    }
    
    Click Px, Py                                                ; Clicks on yellow background, setting focus
    SendInput "^a"                                              ; Ctrl + A (select all) 
    Sleep 500                                                   ; Waits for selection to be made
    SendInput "^i"                                              ; Ctrl + I (import)

    ;; Expects "overwrite existing files" dialog to appear
    if not (WinWaitActive("Zpráva", , 3)) {
        MsgBox "Import warning dialog not found."
        return
    }
    SendInput "{Enter}"

    ;; Expects "Import kolekcí" window to appear
    if not (WinWaitActive("Import kolekcí, soubory dané kolekce budou importovany s souladu definovaných pravidel.", , 10)) {
        MsgBox "Import options window not found."
        return
    }

    WinMaximize "Import kolekcí, soubory dané kolekce budou importovany s souladu definovaných pravidel."
    Sleep 300                                                   ; Waits for window to maximize
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"                   ; Gets window's position and size

    ;; Finds "Zobrazit" column heading
    if not (ImageSearch(&ZobX, &ZobY, 0, 0, WinW, WinH, "support_media/CMS-Zobrazit.png")) {
        MsgBox "Zobrazit column heading not found."
        return
    }

    ;; Find first checkbox (unchecked, on the first, already active, row) in rough expected area
    if not (ImageSearch(&ChckX, &ChckY, ZobX-7, ZobY, ZobX+90, ZobY+50, "support_media/CMS-checkbox-unchecked-on_active_row.png")) {
        MsgBox "Checkbox not found."
        return
    }
    MouseMove ChckX+7, ChckY+7                                  ; Move over checkbox (first row)
    MouseGetPos &CurX, &CurY                                    ; Save cursor position

    ; Loop over all other checkboxes and click them
    while (PixelGetColor(curX, curY) = "0xF3F3F3") or (PixelGetColor(curX, curY) = "0xEAEAEA") {
        Click
        MouseMove 0, 22, 0, "R"                                 ; Moves cursor down by 22px (by line height)
        MouseGetPos &CurX, &CurY                                ; Update cursor position
    }

    ;; NOTE: We can't simply loop over them, as the are not listed in alphabetical, or seemingly any other logical order, and the sorting cannot be changed, 'cause otherwise this all would have been too easy

    SendInput "^a"
    SendInput "^c"
    ClipWait 1
    Click ChckX+110, ChckY+10                                   ; First "zobrazit" cell
    Sleep 100
    
    rows := StrSplit(A_Clipboard, "`n", "`r")
    rows.RemoveAt(1)                                            ; Removes table header
    for (row in rows) {
        systomvyNazev := StrSplit(row, [A_Tab])[4]              ; Not my typo
        nazevParts := StrSplit(systomvyNazev, "-")
        n := nazevParts[nazevParts.length]
        SendText n
        SendInput "{Down}"
        Sleep 150
    }

    ControlClick "WindowsForms10.BUTTON.app.0.1f1128c_r8_ad11"  ; "Check In" button
}

; # CTRL + ALT + 2
; * Tags all files with "byt"
^!Numpad2:: {
    CoordMode "Mouse", "Client"
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    ; Looking for yellow background behind list items
    if not (PixelSearch(&Px, &Py, 0, 0, WinW, WinH, 0xfafad2, 0)) {
        MsgBox "Color not found."
        return
    }

    Click Px, Py                                                ; Clicks on yellow background, setting focus
    SendInput "^a"                                              ; Ctrl + A (select all) 
    Sleep 500                                                   ; Waits for selection to be made
    SendInput "^h"                                              ; Ctrl + A (select all) 

    if not (WinWaitActive("HZ (Změna tagů)", , 3)) {
        MsgBox "Změna tagů window not found."
        return
    }

    CoordMode "Mouse", "Client"
    CoordMode "Pixel", "Client"
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    ControlFocus "WindowsForms10.EDIT.app.0.1f1128c_r8_ad11"
    SendText "byt"
    Sleep 200
    Click 510, 114                                              ; "Přidat" checkbox
    Click "Left", 570, 114, 2                                   ; "Hodnoty k přidání" cell (double-click)

    if not (WinWaitActive("Definice hodnot typu tagů pro filtr", , 3)) {
        MsgBox "Window not found."
        return
    }
    Sleep 200                                                   ; Waits for window to open
    ControlFocus "WindowsForms10.EDIT.app.0.1f1128c_r8_ad14"    ; "Maska přejmenování" text input
    Sleep 100
    SendText "[N1-10]"
    Sleep 100
    ControlClick "WindowsForms10.BUTTON.app.0.1f1128c_r8_ad16"  ; "OK" Button

    WinWaitActive("HZ (Změna tagů)", , 3)
    ControlClick "WindowsForms10.BUTTON.app.0.1f1128c_r8_ad12"  ; "OK" button
}

; # CTRL + ALT + 3
; * Tags all files with "ukazka"
^!Numpad3:: {
    CoordMode "Mouse", "Client"
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    ; Looking for yellow background behind list items
    if not (PixelSearch(&Px, &Py, 0, 0, WinW, WinH, 0xfafad2, 0)) {
        MsgBox "Color not found."
        return
    }

    Click Px, Py                                                ; Clicks on yellow background, setting focus
    SendInput "^a"                                              ; Ctrl + A (select all) 
    Sleep 500                                                   ; Waits for selection to be made
    SendInput "^h"                                              ; Ctrl + H 

    if not (WinWaitActive("HZ (Změna tagů)", , 3)) {
        MsgBox "Změna tagů window not found."
        return
    }

    CoordMode "Mouse", "Client"
    CoordMode "Pixel", "Client"
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    ControlFocus "WindowsForms10.EDIT.app.0.1f1128c_r8_ad11"    ; "Název tagu" search input
    SendText "ukazka"
    Sleep 200
    Click 510, 114                                              ; "Přidat" checkbox
    Sleep 100
    ControlClick "WindowsForms10.BUTTON.app.0.1f1128c_r8_ad12"  ; "OK" button
}



#HotIf

; # Pauses the script
; * Win + PageUp
~#PgUp::Pause

; # Suspends hotkeys
; * Win + PageDown
; ~#PgDn::Suspend

; # Reloads the script
; * Win + End
~#End::Reload