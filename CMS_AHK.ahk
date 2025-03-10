﻿#Requires AutoHotkey v2.0

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


#Warn                       ;; Enables every type of warning and shows each warning in a message box.
SendMode "Input"
SetWorkingDir A_ScriptDir
;#Include A_ScriptDir       ;; Changes the working directory for subsequent #Includes and FileInstalls.
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
    if (ImageSearch(&OutputVarX, &OutputVarY, 0, 0, W, H, "support_media/CMS_Ulozit.png") or ImageSearch(&OutputVarX, &OutputVarY, 0, 0, W, H, "support_media/CMS_Vytvorit-novy-obsah.png")) {
        MouseClick "Left", OutputVarX, OutputVarY
        CoordMode "Mouse", "Screen"
        MouseMove startX, startY
    }
    else
    {
        TrayTip "Tlačítko Uložit nenalezeno"
        Sleep 2000   ; Displays for 2000ms
        TrayTip
    }
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
    ;; Save the current clipboard contents
    clipboardBackup := ClipboardAll()

    selectedText := ""

    ;; Clear the clipboard
    A_Clipboard := ""

    SendInput "^c"              ;; Ctrl + C (copy)
    ClipWait 0.25               ;; Waits until the clipboard contains data; Will wait no longer than 0.25 second

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
        attributes := 'srcset="" media=""'
        selfClosing := true
    case "time":
        attributes := 'datetime=""'
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
    ;; Construct closing tag if not self-closing
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
    A_Clipboard := clipboardBackup      ; Buggy: Feels iffy
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
        SendInput "{Esc}"   ;;Esc closes the windows
    }
    else {
        ;MsgBox ("cancel")  ;; Does nothing
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
        return                  ;; Return if clipboard isn't filled within 1 second
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

; # CTRL+G
; * Copy row in Uložiště, parse, get tags, format, paste tags
^g::{

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

    ; Parse Array into individual tags
    ; tagsArray := StrSplit(tagsString , ";")
    ; for index, tag in tagsArray{
    ;     MsgBox(tag)
    ; }

    ; Replace ";" with spaces
    output := '{{' . 'documentUrl ' . StrReplace(tagsString , ";", A_Space) . '}}'
    SendText output
}

; # Ctrl+D and Shift+Alt+Down 
; * Duplicates line down
^d::
+!Down::{

    clipboardBackup := ClipboardAll()   ;; Save the current clipboard contents
    A_Clipboard := ""                   ;; Clear the clipboard
    selectedText := ""

    SendInput "^c"                      ;; Ctrl + C (copy)
    ClipWait 0.5                        ;; Waits until the clipboard contains data up to given number of seconds

    ; * If clipboard not empty AKA If text was selected
    if (A_Clipboard)
        selectedText := A_Clipboard

    clipboardLines := StrSplit(selectedText, "`n", "`r").length

    if (clipboardLines > 1) {
        ; TODO: Add multiline support
        /*
        SendInput "^x"                      ;; Ctrl + X (cut)
        ClipWait 1                        ;; Waits until the clipboard contains data up to given seconds
        NewPaste()
        SendInput "{Enter}"
        NewPaste()
        */
        ; MsgBox("Multiline support currently unavailable.")
    } else {
        SendInput "{End}{LShift down}{Home}{Home}{LShift up}"
        SendInput "^c"
        ClipWait 1                  ;; Waits until the clipboard contains data; Will wait no longer than 1 second
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
    SendInput "{End}{Shift down}{Home}{Home}{Shift up}{Backspace}{Backspace}"
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


; # HOTSTRING

; ! Hotstrings_HTML1 must be above 2 to avoid conflicts
; Todo: include attributes in selected elements (eg <a href="...">)
#Include "include\Hotstrings_HTML1.ahk"          ; Writing opening <tag> autocompletes closing </tag>
#Include "include\Hotstrings_HTML2.ahk"         ; Plain tag name + tab -> opening + closing tag

; Auto-complete comments
:*b0:<!--::-->{left 3}
:*b0:/*::*/{left 2}

#HotIf WinActive("ahk_exe cmscg.exe") and ( WinActive("Kolekce stránek") or WinActive("Detail WWW stránky") or WinActive("Název stránky") or WinActive("Find") or WinActive("HZ (Změna tagů)") or WinActive("Definice hodnot typu tagů pro filtr") )
; # Ctrl+Backspace
^Backspace::{
    SendInput "^+{Left}{Backspace}"
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