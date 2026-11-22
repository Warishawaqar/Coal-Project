; =====================================================================
;  SUDOKU  -  WINDOWS API (GUI) VERSION (EXTENDED FOOTER CARD EDITION)
;  EL-2003 COAL Lab | MASM32 (no Irvine32 needed)
;
;  BUILD (MASM32 SDK installed in C:\masm32):
;     \masm32\bin\ml /c /coff sudoku_gui.asm
;     \masm32\bin\link /subsystem:windows sudoku_gui.obj
; =====================================================================
.386
.model flat, stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib

; ---------------------------------------------------------------------
;  Prototypes
; ---------------------------------------------------------------------
WinMain            PROTO :DWORD
WndProc            PROTO :DWORD,:DWORD,:DWORD,:DWORD
LoadPuzzleIndex    PROTO :DWORD
LoadPuzzle         PROTO
PlaceDigit         PROTO :DWORD,:DWORD,:DWORD
IsGameOver         PROTO
IsBoardComplete    PROTO
GetBoxIndex        PROTO :DWORD,:DWORD
CheckRules         PROTO :DWORD,:DWORD,:DWORD
CountDigitPlaced   PROTO :DWORD
LoadPlayers        PROTO
SavePlayers        PROTO
FindOrCreatePlayer PROTO
FinishGame         PROTO :DWORD
BuildLeaderboard   PROTO
Redraw             PROTO
MakeFont           PROTO :DWORD,:DWORD
FillRectColor      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FillRoundRectColor PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawCard           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawTxt            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawTxtR           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawButton         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawPadBtn         PROTO :DWORD,:DWORD,:DWORD
HitTest            PROTO :DWORD,:DWORD
DrawHeader         PROTO :DWORD,:DWORD,:DWORD
DrawStatLine       PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawGridLines      PROTO :DWORD
DrawBoardGfx       PROTO :DWORD
DrawNameScr        PROTO :DWORD
DrawMenuScr        PROTO :DWORD
DrawGameScr        PROTO :DWORD
DrawEndScr         PROTO :DWORD
DrawDashScr        PROTO :DWORD
DrawInstrScr       PROTO :DWORD
PaintAll           PROTO :DWORD
NameChar           PROTO :DWORD
OnKey              PROTO :DWORD
OnClick            PROTO :DWORD,:DWORD
MenuAction         PROTO :DWORD
StartGame          PROTO
AbandonGame        PROTO
ChangePlayer       PROTO
TryPlace           PROTO :DWORD
EndGame            PROTO :DWORD
MoveCursor         PROTO :DWORD,:DWORD

; ---------------------------------------------------------------------
;  Game constants
; ---------------------------------------------------------------------
GRID_SIZE       = 9
CELL_COUNT      = 81
NUM_PUZZLES     = 4
MAX_MISTAKES    = 3
POINTS_CORRECT  = 10
PENALTY_MISTAKE = 5
WIN_BONUS       = 500
BONUS_PER_LIFE  = 100
MAX_PLAYERS     = 20
NAME_LEN        = 16
REC_SIZE        = 40
OFF_PLAYED      = 16
OFF_WINS        = 20
OFF_LOSSES      = 24
OFF_TOTAL       = 28
OFF_BEST        = 32
OFF_LAST        = 36
RESULT_MISTAKE  = 0
RESULT_OK       = 1
RESULT_IGNORED  = 2

; ---------------------------------------------------------------------
;  Window / layout constants
; ---------------------------------------------------------------------
CLIENT_W        = 760
CLIENT_H        = 620
BOARD_X         = 35
BOARD_Y         = 74
CELL            = 54
BOARD_PX        = 9 * CELL            ; 486
PAD_X           = 570                 ; safely inside the right-hand panel
PAD_Y           = 225
PAD_S           = 42                  ; square button size
PAD_STEP        = 48                  ; step gap between buttons
QUIT_Y          = PAD_Y + 3 * PAD_STEP + 12
MENU_X1         = 210
MENU_X2         = 550
MENU_Y0         = 170
MENU_STEP       = 68
MENU_H          = 52

BACK_X1         = 18
BACK_Y1         = 12
BACK_X2         = 114
BACK_Y2         = 44

START_X1        = 300
START_Y1        = 322
START_X2        = 460
START_Y2        = 368

ST_NAME         = 0
ST_MENU         = 1
ST_GAME         = 2
ST_END          = 3
ST_DASH         = 4
ST_INSTR        = 5

K_ENTER         = 0Dh
K_ESC           = 1Bh
K_SPACE         = 20h
K_LEFT          = 25h
K_UP            = 26h
K_RIGHT         = 27h
K_DOWN          = 28h
TIMER_CARET     = 1

DTFLAGS         = DT_CENTER or DT_VCENTER or DT_SINGLELINE

; ---------------------------------------------------------------------
;  MODERNIZED COLOUR PALETTE
; ---------------------------------------------------------------------
CLR_BG          = 001C1917h
CLR_CARD        = 00292524h
CLR_CARD_BORDER = 0044403Ch
CLR_WHITE       = 00FFFFFFh
CLR_BLACK       = 00000000h
CLR_TEXT        = 00E7E5E4h
CLR_TITLE       = 00F8BD38h
CLR_PLAYER      = 00FCD37Dh
CLR_CLUE        = 00F5F5F4h
CLR_ERR         = 007171F8h
CLR_WRONGBG     = 00331D2Ch
CLR_SEL         = 00785B40h
CLR_PEER        = 00342E2Ah
CLR_GRID        = 0044403Ch
CLR_THICK       = 00A8A29Eh
CLR_OK          = 0080DE4Ah
CLR_WARN        = 0024BF71h
CLR_BTN         = 0037302Bh
CLR_BTNH        = 00524841h
CLR_BTNP        = 0026211Eh
CLR_BTNDIM      = 00221F1Dh
CLR_BTNQ        = 003C2B2Bh
CLR_BTNQH       = 00543A3Ah
CLR_ACCENT_BTN  = 00D99B26h
CLR_ACCENT_BTNH = 00F8BD38h
CLR_MSG         = 00D6D3D1h
CLR_HINT        = 00A8A29Eh
CLR_DIM_TXT     = 0057534Eh
CLR_SAME        = 00594436h
CLR_SHADOW      = 00110F0Eh
CURSOR_HAND     = 32649
MSG_MOUSELEAVE  = 02A3h

.data
puzzle          BYTE 81 DUP(0)
solution        BYTE 81 DUP(0)
playerGrid      BYTE 81 DUP(0)
cursorRow       BYTE 0
cursorCol       BYTE 0
mistakes        BYTE 0
currentPuzzle   BYTE 0
showCursor      BYTE 1
wrongRow        BYTE 0FFh
wrongCol        BYTE 0FFh
wrongDigit      BYTE 0
score           DWORD 0

fileName        BYTE "sudoku_players.dat",0
players         BYTE MAX_PLAYERS * REC_SIZE DUP(0)
playerCount     DWORD 0
currentPlayer   DWORD -1
nameBuf         BYTE NAME_LEN DUP(0)
nameLen         DWORD 0
shown           BYTE MAX_PLAYERS DUP(0)
topIdx          DWORD 5 DUP(0)
topCount        DWORD 0
lastSaveOk      DWORD 0
userRow         DWORD 0
userCol         DWORD 0
userDigit       DWORD 0

hWnd            DWORD 0
hoverId         DWORD 0
pressedId       DWORD 0
menuFocus       DWORD 0
caretVisible    DWORD 1
tmeBuf          DWORD 4 DUP(0)
vpX             DWORD 0
vpY             DWORD 0
vpW             DWORD CLIENT_W
vpH             DWORD CLIENT_H
state           DWORD ST_NAME
endWin          DWORD 0
msgPtr          DWORD 0
menuMsg         DWORD 0
hfTitle         DWORD 0
hfBig           DWORD 0
hfBoard         DWORD 0
hfBoardB        DWORD 0
hfMed           DWORD 0
hfBold          DWORD 0
hfSmall         DWORD 0
txtBuf          BYTE 128 DUP(0)
tmpBuf          BYTE 32 DUP(0)

ClassName       BYTE "SudokuGuiWnd",0
AppName         BYTE "Sudoku",0
fontName        BYTE "Segoe UI",0

puzzleBank LABEL BYTE
    BYTE 0, 1, 0, 9, 0, 0, 4, 5, 8
    BYTE 8, 0, 5, 0, 0, 7, 0, 0, 0
    BYTE 0, 2, 0, 0, 0, 0, 0, 0, 0
    BYTE 2, 0, 0, 4, 0, 9, 7, 0, 0
    BYTE 4, 0, 0, 1, 0, 0, 6, 0, 0
    BYTE 1, 7, 8, 0, 6, 3, 5, 0, 4
    BYTE 7, 0, 0, 0, 3, 1, 0, 0, 5
    BYTE 6, 3, 1, 5, 9, 0, 8, 4, 0
    BYTE 5, 9, 2, 7, 0, 0, 3, 1, 0

    BYTE 5, 1, 0, 6, 2, 0, 7, 3, 0
    BYTE 4, 6, 0, 3, 0, 0, 0, 1, 5
    BYTE 0, 3, 7, 0, 9, 0, 2, 0, 0
    BYTE 0, 7, 5, 9, 4, 1, 8, 0, 0
    BYTE 0, 2, 0, 7, 5, 3, 0, 9, 0
    BYTE 0, 0, 4, 0, 0, 6, 5, 7, 3
    BYTE 0, 0, 3, 0, 0, 0, 6, 4, 9
    BYTE 0, 4, 0, 8, 0, 0, 1, 0, 0
    BYTE 0, 5, 1, 4, 6, 9, 0, 0, 2

    BYTE 1, 0, 0, 3, 2, 0, 6, 0, 0
    BYTE 0, 4, 6, 1, 0, 9, 0, 3, 2
    BYTE 3, 0, 8, 0, 4, 0, 0, 0, 7
    BYTE 4, 0, 0, 0, 0, 1, 3, 2, 6
    BYTE 0, 8, 1, 2, 6, 3, 5, 4, 0
    BYTE 2, 6, 0, 4, 9, 0, 1, 0, 8
    BYTE 0, 5, 2, 0, 0, 0, 0, 8, 3
    BYTE 0, 0, 0, 6, 5, 2, 4, 0, 1
    BYTE 0, 1, 4, 0, 0, 7, 0, 6, 5

    BYTE 7, 0, 3, 4, 0, 6, 9, 0, 0
    BYTE 1, 0, 2, 0, 8, 3, 5, 6, 4
    BYTE 4, 0, 6, 1, 0, 2, 0, 3, 0
    BYTE 0, 0, 8, 6, 0, 5, 7, 0, 2
    BYTE 0, 1, 5, 0, 7, 9, 4, 0, 0
    BYTE 2, 0, 9, 0, 4, 8, 0, 5, 6
    BYTE 0, 0, 0, 0, 3, 0, 6, 4, 0
    BYTE 0, 6, 4, 5, 2, 1, 3, 7, 9
    BYTE 0, 3, 0, 0, 6, 4, 2, 1, 5

solutionBank LABEL BYTE
    BYTE 3, 1, 7, 9, 2, 6, 4, 5, 8
    BYTE 8, 4, 5, 3, 1, 7, 2, 6, 9
    BYTE 9, 2, 6, 8, 4, 5, 1, 7, 3
    BYTE 2, 6, 3, 4, 5, 9, 7, 8, 1
    BYTE 4, 5, 9, 1, 7, 8, 6, 3, 2
    BYTE 1, 7, 8, 2, 6, 3, 5, 9, 4
    BYTE 7, 8, 4, 6, 3, 1, 9, 2, 5
    BYTE 6, 3, 1, 5, 9, 2, 8, 4, 7
    BYTE 5, 9, 2, 7, 8, 4, 3, 1, 6

    BYTE 5, 1, 9, 6, 2, 4, 7, 3, 8
    BYTE 4, 6, 2, 3, 7, 8, 9, 1, 5
    BYTE 8, 3, 7, 1, 9, 5, 2, 6, 4
    BYTE 3, 7, 5, 9, 4, 1, 8, 2, 6
    BYTE 6, 2, 8, 7, 5, 3, 4, 9, 1
    BYTE 1, 9, 4, 2, 8, 6, 5, 7, 3
    BYTE 2, 8, 3, 5, 1, 7, 6, 4, 9
    BYTE 9, 4, 6, 8, 3, 2, 1, 5, 7
    BYTE 7, 5, 1, 4, 6, 9, 3, 8, 2

    BYTE 1, 7, 9, 3, 2, 8, 6, 5, 4
    BYTE 5, 4, 6, 1, 7, 9, 8, 3, 2
    BYTE 3, 2, 8, 5, 4, 6, 9, 1, 7
    BYTE 4, 9, 5, 7, 8, 1, 3, 2, 6
    BYTE 7, 8, 1, 2, 6, 3, 5, 4, 9
    BYTE 2, 6, 3, 4, 9, 5, 1, 7, 8
    BYTE 6, 5, 2, 9, 1, 4, 7, 8, 3
    BYTE 8, 3, 7, 6, 5, 2, 4, 9, 1
    BYTE 9, 1, 4, 8, 3, 7, 2, 6, 5

    BYTE 7, 8, 3, 4, 5, 6, 9, 2, 1
    BYTE 1, 9, 2, 7, 8, 3, 5, 6, 4
    BYTE 4, 5, 6, 1, 9, 2, 8, 3, 7
    BYTE 3, 4, 8, 6, 1, 5, 7, 9, 2
    BYTE 6, 1, 5, 2, 7, 9, 4, 8, 3
    BYTE 2, 7, 9, 3, 4, 8, 1, 5, 6
    BYTE 5, 2, 1, 9, 3, 7, 6, 4, 8
    BYTE 8, 6, 4, 5, 2, 1, 3, 7, 9
    BYTE 9, 3, 7, 8, 6, 4, 2, 1, 5

sTitle      BYTE "S U D O K U",0
sWelcome    BYTE "Welcome, challenger!  Who is playing today?",0
sYourName   BYTE "PLAYER NAME",0
sNameHint1  BYTE "Type up to 15 characters, then press ENTER or click Continue",0
sNameHint2  BYTE "Your stats and high scores are saved automatically.",0
sStartBtn   BYTE "Continue  ->",0
sBackBtn    BYTE "<-  Menu",0
sCaret      BYTE "_",0

sMenu1      BYTE "1.  Play Game",0
sMenu2      BYTE "2.  How to Play",0
sMenu3      BYTE "3.  Dashboard && Leaderboard",0
sMenu4      BYTE "4.  Switch Player",0
sMenu5      BYTE "5.  Exit",0
menuItems   DWORD OFFSET sMenu1, OFFSET sMenu2, OFFSET sMenu3, OFFSET sMenu4, OFFSET sMenu5
sMenuHint   BYTE "Use Mouse, Up/Down Arrows + Enter, or keys 1 - 5",0
fmtPlayerIs BYTE "Active Player: %s",0
sGuestNote  BYTE "Guest Mode: Scores will not be saved.",0
sAbandon    BYTE "Game paused/abandoned - not counted in statistics.",0

sHelp       BYTE "Click a cell or use Arrow Keys, then press 1-9.  Esc returns to menu.",0
sOk         BYTE "Great move!  +10 points",0
sDup        BYTE "Conflict: Digit already exists in this row, column, or 3x3 box (-5)",0
sNoFit      BYTE "Incorrect: Fits Sudoku rules, but not the solution (-5)",0
sFixed      BYTE "Locked cell: Clues and solved digits cannot be modified.",0
sPlayerLbl  BYTE "PLAYER",0
fmtMist     BYTE "Mistakes: %d / 3",0
fmtScore    BYTE "Score: %d",0
fmtNum      BYTE "%d",0
fmtMist2    BYTE "%d / 3",0
sPadLbl     BYTE "NUMBER PAD",0
sQuit       BYTE "Menu  (Esc)",0

sWinTxt     BYTE "VICTORY!",0
sLoseTxt    BYTE "GAME OVER",0
sFinalLbl   BYTE "FINAL SCORE",0
sUsedLbl    BYTE "MISTAKES USED",0
sSaved      BYTE "Progress saved.",0
sSaveFail   BYTE "Warning: Save failed!",0
sEndHint    BYTE "Click or press Enter for Dashboard",0
sSolShown   BYTE "Solution revealed.",0

sDashTitle  BYTE "PLAYER DASHBOARD",0
sNoRecord   BYTE "Guest mode: no statistics recorded.",0
fmtName     BYTE "Player        : %s",0
fmtPlayed   BYTE "Games played  : %d",0
fmtWins     BYTE "Wins          : %d",0
fmtLosses   BYTE "Losses        : %d",0
fmtRate     BYTE "Win rate (%%)  : %d",0
fmtTotal    BYTE "Total score   : %d",0
fmtBest     BYTE "Best score    : %d",0
fmtLast     BYTE "Last score    : %d",0
sBoardTitle BYTE "LEADERBOARD (TOP 5)",0
sBoardNone  BYTE "No records found.",0
fmtBoard    BYTE "%d.  %s   -   %d",0
sRules0     BYTE "SCORING SYSTEM",0
sRules1     BYTE "+10 points for every accurate digit placed",0
sRules2     BYTE "-5 points for every mistake (minimum score is 0)",0
sRules3     BYTE "+500 bonus points for completing the puzzle",0
sRules4     BYTE "+100 bonus points for each remaining life",0
sBackHint   BYTE "Click '<- Menu', click anywhere, or press Esc / Enter",0

sInstrTitle BYTE "HOW TO PLAY SUDOKU",0
sI1         BYTE "Fill the 9x9 grid so every ROW, COLUMN, and 3x3 BOX",0
sI2         BYTE "contains the digits 1 to 9 without repetition.",0
sI3         BYTE "CONTROLS",0
sI4         BYTE "  Mouse / Arrow Keys   Select any cell on the board",0
sI5         BYTE "  1 - 9 / Number Pad   Input a digit into the active cell",0
sI6         BYTE "  (Completed digits automatically dim on the number pad)",0
sI7         BYTE "  Esc / <- Menu        Return to the main menu",0
sI8         BYTE "RULES & SCORING",0
sI9         BYTE "  Three mistakes end the game immediately.",0
sI10        BYTE "  +10 per correct digit, -5 per mistake, +500 for winning,",0
sI11        BYTE "  plus +100 for each unused mistake.",0
sI12        BYTE "COLOR GUIDE",0
sI13        BYTE "  White digit  = Fixed puzzle clue",0
sI14        BYTE "  Cyan digit   = Your confirmed entry",0
sI15        BYTE "  Red digit    = Temporary error feedback",0
sI16        BYTE "  Shaded guide = Active row, column, 3x3 box & matching digits",0
sEmpty      BYTE 0

instrTable  DWORD OFFSET sI1,  CLR_TEXT
            DWORD OFFSET sI2,  CLR_TEXT
            DWORD OFFSET sEmpty, CLR_TEXT
            DWORD OFFSET sI3,  CLR_TITLE
            DWORD OFFSET sI4,  CLR_TEXT
            DWORD OFFSET sI5,  CLR_TEXT
            DWORD OFFSET sI6,  CLR_TEXT
            DWORD OFFSET sI7,  CLR_TEXT
            DWORD OFFSET sEmpty, CLR_TEXT
            DWORD OFFSET sI8,  CLR_TITLE
            DWORD OFFSET sI9,  CLR_TEXT
            DWORD OFFSET sI10, CLR_TEXT
            DWORD OFFSET sI11, CLR_TEXT
            DWORD OFFSET sEmpty, CLR_TEXT
            DWORD OFFSET sI12, CLR_TITLE
            DWORD OFFSET sI13, CLR_CLUE
            DWORD OFFSET sI14, CLR_PLAYER
            DWORD OFFSET sI15, CLR_ERR
            DWORD OFFSET sI16, CLR_TEXT
            DWORD 0, 0

.code
start:
    INVOKE GetModuleHandle, NULL
    INVOKE WinMain, eax
    INVOKE ExitProcess, eax

WinMain PROC hInst:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL rc:RECT

    mov  wc.cbSize, SIZEOF WNDCLASSEX
    mov  wc.style, CS_HREDRAW or CS_VREDRAW
    mov  wc.lpfnWndProc, OFFSET WndProc
    mov  wc.cbClsExtra, 0
    mov  wc.cbWndExtra, 0
    mov  eax, hInst
    mov  wc.hInstance, eax
    mov  wc.hbrBackground, COLOR_WINDOW + 1
    mov  wc.lpszMenuName, NULL
    mov  wc.lpszClassName, OFFSET ClassName
    INVOKE LoadIcon, NULL, IDI_APPLICATION
    mov  wc.hIcon, eax
    mov  wc.hIconSm, eax
    INVOKE LoadCursor, NULL, IDC_ARROW
    mov  wc.hCursor, eax
    INVOKE RegisterClassEx, ADDR wc

    mov  rc.left, 0
    mov  rc.top, 0
    mov  rc.right, CLIENT_W
    mov  rc.bottom, CLIENT_H
    INVOKE AdjustWindowRect, ADDR rc, WS_OVERLAPPEDWINDOW, FALSE
    mov  eax, rc.right
    sub  eax, rc.left
    mov  ecx, rc.bottom
    sub  ecx, rc.top

    INVOKE CreateWindowEx, 0, ADDR ClassName, ADDR AppName, \
           WS_OVERLAPPEDWINDOW, \
           CW_USEDEFAULT, CW_USEDEFAULT, eax, ecx, NULL, NULL, hInst, NULL
    INVOKE ShowWindow, hWnd, SW_SHOWMAXIMIZED
    INVOKE UpdateWindow, hWnd

msgLoop:
    INVOKE GetMessage, ADDR msg, NULL, 0, 0
    cmp  eax, 0
    je   msgDone
    INVOKE TranslateMessage, ADDR msg
    INVOKE DispatchMessage, ADDR msg
    jmp  msgLoop
msgDone:
    mov  eax, msg.wParam
    ret
WinMain ENDP

WndProc PROC USES ebx esi edi, hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        mov  eax, hWin
        mov  hWnd, eax
        INVOKE MakeFont, -52, FW_BOLD
        mov  hfTitle, eax
        INVOKE MakeFont, -28, FW_BOLD
        mov  hfBig, eax
        INVOKE MakeFont, -28, FW_NORMAL
        mov  hfBoard, eax
        INVOKE MakeFont, -28, FW_BOLD
        mov  hfBoardB, eax
        INVOKE MakeFont, -18, FW_NORMAL
        mov  hfMed, eax
        INVOKE MakeFont, -18, FW_BOLD
        mov  hfBold, eax
        INVOKE MakeFont, -14, FW_NORMAL
        mov  hfSmall, eax
        INVOKE LoadPlayers
        INVOKE SetTimer, hWin, TIMER_CARET, 500, NULL
        mov  state, ST_NAME
        xor  eax, eax
        ret

    .elseif uMsg == WM_TIMER
        .if wParam == TIMER_CARET && state == ST_NAME
            xor  caretVisible, 1
            call Redraw
        .endif
        xor  eax, eax
        ret

    .elseif uMsg == WM_DESTROY
        INVOKE KillTimer, hWin, TIMER_CARET
        INVOKE DeleteObject, hfTitle
        INVOKE DeleteObject, hfBig
        INVOKE DeleteObject, hfBoard
        INVOKE DeleteObject, hfBoardB
        INVOKE DeleteObject, hfMed
        INVOKE DeleteObject, hfBold
        INVOKE DeleteObject, hfSmall
        INVOKE PostQuitMessage, 0
        xor  eax, eax
        ret

    .elseif uMsg == WM_ERASEBKGND
        mov  eax, 1
        ret

    .elseif uMsg == WM_PAINT
        INVOKE PaintAll, hWin
        xor  eax, eax
        ret

    .elseif uMsg == WM_CHAR
        .if state == ST_NAME
            INVOKE NameChar, wParam
        .endif
        xor  eax, eax
        ret

    .elseif uMsg == WM_KEYDOWN
        INVOKE OnKey, wParam
        xor  eax, eax
        ret

    .elseif uMsg == WM_MOUSEMOVE
        mov  tmeBuf[0], 16
        mov  tmeBuf[4], 2
        mov  eax, hWin
        mov  tmeBuf[8], eax
        mov  tmeBuf[12], 0
        INVOKE TrackMouseEvent, ADDR tmeBuf
        mov  eax, lParam
        movzx ecx, ax
        shr  eax, 16
        sub  ecx, vpX
        jb   mmNone
        sub  eax, vpY
        jb   mmNone
        imul ecx, ecx, CLIENT_W
        imul eax, eax, CLIENT_H
        mov  esi, eax
        mov  eax, ecx
        xor  edx, edx
        div  vpW
        mov  ebx, eax
        mov  eax, esi
        xor  edx, edx
        div  vpH
        INVOKE HitTest, ebx, eax
        jmp  mmGot
mmNone:
        xor  eax, eax
mmGot:
        .if eax != hoverId
            mov  hoverId, eax
            .if state == ST_MENU && eax >= 1 && eax <= 5
                dec  eax
                mov  menuFocus, eax
            .endif
            call Redraw
        .endif
        xor  eax, eax
        ret

    .elseif uMsg == MSG_MOUSELEAVE
        .if hoverId != 0 || pressedId != 0
            mov  hoverId, 0
            mov  pressedId, 0
            call Redraw
        .endif
        xor  eax, eax
        ret

    .elseif uMsg == WM_SETCURSOR
        mov  eax, lParam
        and  eax, 0FFFFh
        .if eax == 1 && hoverId != 0
            INVOKE LoadCursor, NULL, CURSOR_HAND
            INVOKE SetCursor, eax
            mov  eax, 1
            ret
        .endif

    .elseif uMsg == WM_LBUTTONDOWN
        mov  eax, hoverId
        mov  pressedId, eax
        .if eax != 0
            call Redraw
        .endif
        mov  eax, lParam
        movzx ecx, ax
        shr  eax, 16
        sub  ecx, vpX
        jb   wmSkipClick
        sub  eax, vpY
        jb   wmSkipClick
        imul ecx, ecx, CLIENT_W
        imul eax, eax, CLIENT_H
        mov  esi, eax
        mov  eax, ecx
        xor  edx, edx
        div  vpW
        mov  ebx, eax
        mov  eax, esi
        xor  edx, edx
        div  vpH
        INVOKE OnClick, ebx, eax
wmSkipClick:
        xor  eax, eax
        ret

    .elseif uMsg == WM_LBUTTONUP
        .if pressedId != 0
            mov  pressedId, 0
            call Redraw
        .endif
        xor  eax, eax
        ret
    .endif

    INVOKE DefWindowProc, hWin, uMsg, wParam, lParam
    ret
WndProc ENDP

Redraw PROC
    INVOKE InvalidateRect, hWnd, NULL, FALSE
    ret
Redraw ENDP

MakeFont PROC h:DWORD, w:DWORD
    INVOKE CreateFont, h, 0, 0, 0, w, 0, 0, 0, DEFAULT_CHARSET, \
           OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, \
           DEFAULT_PITCH, ADDR fontName
    ret
MakeFont ENDP

LoadPuzzleIndex PROC USES eax ebx ecx esi edi, idx:DWORD
    mov  eax, idx
    mov  currentPuzzle, al
    imul ebx, idx, CELL_COUNT
    cld

    mov  esi, OFFSET puzzleBank
    add  esi, ebx
    mov  edi, OFFSET puzzle
    mov  ecx, CELL_COUNT
    rep  movsb

    mov  esi, OFFSET puzzleBank
    add  esi, ebx
    mov  edi, OFFSET playerGrid
    mov  ecx, CELL_COUNT
    rep  movsb

    mov  esi, OFFSET solutionBank
    add  esi, ebx
    mov  edi, OFFSET solution
    mov  ecx, CELL_COUNT
    rep  movsb

    mov  mistakes, 0
    mov  score, 0
    mov  cursorRow, 0
    mov  cursorCol, 0
    ret
LoadPuzzleIndex ENDP

LoadPuzzle PROC USES eax ecx edx
    INVOKE GetTickCount
    xor  edx, edx
    mov  ecx, NUM_PUZZLES
    div  ecx
    INVOKE LoadPuzzleIndex, edx
    ret
LoadPuzzle ENDP

PlaceDigit PROC USES ebx ecx esi, row:DWORD, col:DWORD, digit:DWORD
    cmp  row, GRID_SIZE - 1
    ja   pdIgnored
    cmp  col, GRID_SIZE - 1
    ja   pdIgnored
    cmp  digit, 1
    jb   pdIgnored
    cmp  digit, 9
    ja   pdIgnored

    mov  ebx, row
    imul ebx, ebx, GRID_SIZE
    add  ebx, col

    mov  esi, OFFSET puzzle
    cmp  BYTE PTR [esi + ebx], 0
    jne  pdIgnored

    mov  esi, OFFSET playerGrid
    cmp  BYTE PTR [esi + ebx], 0
    jne  pdIgnored

    mov  ecx, digit
    mov  esi, OFFSET solution
    mov  al, [esi + ebx]
    cmp  al, cl
    jne  pdWrong

    mov  esi, OFFSET playerGrid
    mov  [esi + ebx], cl
    add  score, POINTS_CORRECT
    mov  eax, RESULT_OK
    ret

pdWrong:
    inc  mistakes
    cmp  score, PENALTY_MISTAKE
    jae  pdTakePenalty
    mov  score, 0
    jmp  pdPenaltyDone
pdTakePenalty:
    sub  score, PENALTY_MISTAKE
pdPenaltyDone:
    mov  eax, RESULT_MISTAKE
    ret

pdIgnored:
    mov  eax, RESULT_IGNORED
    ret
PlaceDigit ENDP

IsGameOver PROC
    mov  eax, 0
    cmp  mistakes, MAX_MISTAKES
    jb   igNotOver
    mov  eax, 1
igNotOver:
    ret
IsGameOver ENDP

IsBoardComplete PROC USES ecx esi edi
    mov  esi, OFFSET playerGrid
    mov  edi, OFFSET solution
    mov  ecx, CELL_COUNT
ibcNext:
    mov  al, [esi]
    cmp  al, [edi]
    jne  ibcNo
    inc  esi
    inc  edi
    loop ibcNext
    mov  eax, 1
    ret
ibcNo:
    mov  eax, 0
    ret
IsBoardComplete ENDP

CountDigitPlaced PROC USES ecx esi, digit:DWORD
    xor  eax, eax
    mov  edx, digit
    mov  esi, OFFSET playerGrid
    mov  ecx, CELL_COUNT
cdpLoop:
    cmp  BYTE PTR [esi], dl
    jne  cdpNext
    inc  eax
cdpNext:
    inc  esi
    loop cdpLoop
    ret
CountDigitPlaced ENDP

GetBoxIndex PROC USES ebx ecx edx, row:DWORD, col:DWORD
    mov  ebx, 3
    mov  eax, row
    xor  edx, edx
    div  ebx
    imul ecx, eax, 3
    mov  eax, col
    xor  edx, edx
    div  ebx
    add  eax, ecx
    ret
GetBoxIndex ENDP

CheckRules PROC USES ebx edx esi, row:DWORD, col:DWORD, digit:DWORD
    LOCAL targetBox:DWORD, curRow:DWORD, curCol:DWORD

    INVOKE GetBoxIndex, row, col
    mov  targetBox, eax
    mov  edx, digit
    mov  esi, OFFSET playerGrid

    mov  curRow, 0
crRowLoop:
    mov  curCol, 0
crColLoop:
    mov  eax, curRow
    cmp  eax, row
    jne  crNotSelf
    mov  eax, curCol
    cmp  eax, col
    je   crNextCell
crNotSelf:
    mov  ebx, curRow
    imul ebx, ebx, GRID_SIZE
    add  ebx, curCol
    mov  al, [esi + ebx]
    cmp  al, dl
    jne  crNextCell

    mov  eax, curRow
    cmp  eax, row
    je   crConflict
    mov  eax, curCol
    cmp  eax, col
    je   crConflict
    INVOKE GetBoxIndex, curRow, curCol
    cmp  eax, targetBox
    je   crConflict

crNextCell:
    inc  curCol
    cmp  curCol, GRID_SIZE
    jb   crColLoop
    inc  curRow
    cmp  curRow, GRID_SIZE
    jb   crRowLoop

    mov  eax, 1
    ret
crConflict:
    mov  eax, 0
    ret
CheckRules ENDP

LoadPlayers PROC USES ebx ecx edx
    LOCAL nRead:DWORD
    mov  playerCount, 0
    mov  nRead, 0
    INVOKE CreateFile, ADDR fileName, GENERIC_READ, 0, NULL, \
           OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp  eax, INVALID_HANDLE_VALUE
    je   lpNoFile
    mov  ebx, eax
    INVOKE ReadFile, ebx, ADDR players, MAX_PLAYERS * REC_SIZE, ADDR nRead, NULL
    test eax, eax
    jz   lpClose
    mov  eax, nRead
    xor  edx, edx
    mov  ecx, REC_SIZE
    div  ecx
    mov  playerCount, eax
lpClose:
    INVOKE CloseHandle, ebx
lpNoFile:
    ret
LoadPlayers ENDP

SavePlayers PROC USES ebx ecx edx
    LOCAL nWritten:DWORD, okFlag:DWORD
    mov  okFlag, 0
    INVOKE CreateFile, ADDR fileName, GENERIC_WRITE, 0, NULL, \
           CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    cmp  eax, INVALID_HANDLE_VALUE
    je   spFail
    mov  ebx, eax
    mov  ecx, playerCount
    imul ecx, ecx, REC_SIZE
    INVOKE WriteFile, ebx, ADDR players, ecx, ADDR nWritten, NULL
    mov  okFlag, eax
    INVOKE CloseHandle, ebx
spFail:
    mov  eax, okFlag
    ret
SavePlayers ENDP

FindOrCreatePlayer PROC USES eax ebx ecx edx esi edi
    mov  ebx, 0
fcSearch:
    cmp  ebx, playerCount
    jae  fcNotFound
    mov  esi, ebx
    imul esi, esi, REC_SIZE
    add  esi, OFFSET players
    mov  edi, OFFSET nameBuf
    mov  ecx, NAME_LEN
    cld
    repe cmpsb
    je   fcFound
    inc  ebx
    jmp  fcSearch
fcFound:
    mov  currentPlayer, ebx
    ret

fcNotFound:
    cmp  playerCount, MAX_PLAYERS
    jb   fcCreate
    mov  currentPlayer, -1
    ret
fcCreate:
    mov  edi, playerCount
    imul edi, edi, REC_SIZE
    add  edi, OFFSET players
    push edi
    mov  ecx, REC_SIZE
    xor  eax, eax
    cld
    rep  stosb
    pop  edi
    mov  esi, OFFSET nameBuf
    mov  ecx, NAME_LEN
    rep  movsb
    mov  eax, playerCount
    mov  currentPlayer, eax
    inc  playerCount
    ret
FindOrCreatePlayer ENDP

FinishGame PROC USES eax ebx esi, isWin:DWORD
    cmp  isWin, 1
    jne  fgTally
    mov  eax, MAX_MISTAKES
    movzx ebx, mistakes
    sub  eax, ebx
    imul eax, eax, BONUS_PER_LIFE
    add  eax, WIN_BONUS
    add  score, eax

fgTally:
    mov  lastSaveOk, 0
    cmp  currentPlayer, -1
    je   fgDone

    mov  esi, currentPlayer
    imul esi, esi, REC_SIZE
    add  esi, OFFSET players

    inc  DWORD PTR [esi + OFF_PLAYED]
    cmp  isWin, 1
    jne  fgLoss
    inc  DWORD PTR [esi + OFF_WINS]
    jmp  fgScore
fgLoss:
    inc  DWORD PTR [esi + OFF_LOSSES]
fgScore:
    mov  eax, score
    add  [esi + OFF_TOTAL], eax
    mov  [esi + OFF_LAST], eax
    cmp  eax, [esi + OFF_BEST]
    jbe  fgSave
    mov  [esi + OFF_BEST], eax
fgSave:
    call SavePlayers
    mov  lastSaveOk, eax
fgDone:
    ret
FinishGame ENDP

BuildLeaderboard PROC USES eax ebx ecx edx esi edi
    LOCAL rank:DWORD, bestIdx:DWORD, bestVal:DWORD

    mov  topCount, 0
    mov  edi, OFFSET shown
    mov  ecx, MAX_PLAYERS
    xor  eax, eax
    cld
    rep  stosb

    mov  rank, 0
blRank:
    cmp  rank, 5
    jae  blDone
    mov  eax, rank
    cmp  eax, playerCount
    jae  blDone

    mov  bestIdx, -1
    mov  bestVal, 0
    xor  ebx, ebx
blFind:
    cmp  ebx, playerCount
    jae  blFound
    cmp  BYTE PTR shown[ebx], 0
    jne  blNext
    mov  esi, ebx
    imul esi, esi, REC_SIZE
    mov  eax, DWORD PTR players[esi + OFF_BEST]
    cmp  bestIdx, -1
    je   blTake
    cmp  eax, bestVal
    jbe  blNext
blTake:
    mov  bestVal, eax
    mov  bestIdx, ebx
blNext:
    inc  ebx
    jmp  blFind

blFound:
    mov  ebx, bestIdx
    mov  BYTE PTR shown[ebx], 1
    mov  eax, rank
    mov  topIdx[eax * 4], ebx
    inc  topCount
    inc  rank
    jmp  blRank
blDone:
    ret
BuildLeaderboard ENDP

StartGame PROC
    INVOKE LoadPuzzle
    mov  state, ST_GAME
    mov  hoverId, 0
    mov  pressedId, 0
    mov  showCursor, 1
    mov  wrongRow, 0FFh
    mov  wrongCol, 0FFh
    mov  wrongDigit, 0
    mov  msgPtr, OFFSET sHelp
    mov  menuMsg, 0
    ret
StartGame ENDP

AbandonGame PROC
    mov  state, ST_MENU
    mov  hoverId, 0
    mov  pressedId, 0
    mov  menuMsg, OFFSET sAbandon
    call Redraw
    ret
AbandonGame ENDP

ChangePlayer PROC USES eax ecx edi
    mov  edi, OFFSET nameBuf
    mov  ecx, NAME_LEN
    xor  eax, eax
    cld
    rep  stosb
    mov  nameLen, 0
    mov  currentPlayer, -1
    mov  menuMsg, 0
    mov  hoverId, 0
    mov  pressedId, 0
    mov  state, ST_NAME
    ret
ChangePlayer ENDP

EndGame PROC USES eax ecx esi edi, win:DWORD
    INVOKE FinishGame, win
    mov  eax, win
    mov  endWin, eax
    cmp  win, 1
    je   egKeep
    mov  esi, OFFSET solution
    mov  edi, OFFSET playerGrid
    mov  ecx, CELL_COUNT
    cld
    rep  movsb
egKeep:
    mov  wrongRow, 0FFh
    mov  wrongCol, 0FFh
    mov  showCursor, 0
    mov  hoverId, 0
    mov  pressedId, 0
    mov  state, ST_END
    ret
EndGame ENDP

TryPlace PROC digit:DWORD
    mov  wrongRow, 0FFh
    mov  wrongCol, 0FFh
    mov  wrongDigit, 0
    movzx eax, cursorRow
    mov  userRow, eax
    movzx eax, cursorCol
    mov  userCol, eax
    mov  eax, digit
    mov  userDigit, eax

    INVOKE PlaceDigit, userRow, userCol, userDigit
    cmp  eax, RESULT_OK
    je   tpOk
    cmp  eax, RESULT_MISTAKE
    je   tpMist
    mov  msgPtr, OFFSET sFixed
    jmp  tpDone

tpOk:
    mov  msgPtr, OFFSET sOk
    call IsBoardComplete
    cmp  eax, 1
    jne  tpDone
    INVOKE EndGame, 1
    jmp  tpDone

tpMist:
    mov  eax, userRow
    mov  wrongRow, al
    mov  eax, userCol
    mov  wrongCol, al
    mov  eax, userDigit
    mov  wrongDigit, al
    INVOKE CheckRules, userRow, userCol, userDigit
    cmp  eax, 0
    je   tpBreaks
    mov  msgPtr, OFFSET sNoFit
    jmp  tpAfter
tpBreaks:
    mov  msgPtr, OFFSET sDup
tpAfter:
    call IsGameOver
    cmp  eax, 1
    jne  tpDone
    INVOKE EndGame, 0

tpDone:
    call Redraw
    ret
TryPlace ENDP

MoveCursor PROC dr:DWORD, dc:DWORD
    movzx eax, cursorRow
    add  eax, dr
    cmp  eax, 8
    ja   mcSkip
    movzx ecx, cursorCol
    add  ecx, dc
    cmp  ecx, 8
    ja   mcSkip
    mov  cursorRow, al
    mov  cursorCol, cl
    mov  wrongRow, 0FFh
    mov  wrongCol, 0FFh
    call Redraw
mcSkip:
    ret
MoveCursor ENDP

MenuAction PROC n:DWORD
    mov  hoverId, 0
    mov  pressedId, 0
    mov  eax, n
    .if eax == 1
        INVOKE StartGame
    .elseif eax == 2
        mov  state, ST_INSTR
    .elseif eax == 3
        mov  state, ST_DASH
    .elseif eax == 4
        INVOKE ChangePlayer
    .elseif eax == 5
        INVOKE DestroyWindow, hWnd
        ret
    .endif
    call Redraw
    ret
MenuAction ENDP

NameChar PROC USES ecx, inChar:DWORD
    mov  eax, inChar
    cmp  eax, 13
    je   ncEnter
    cmp  eax, 8
    je   ncBack
    cmp  eax, 32
    jb   ncIgnore
    cmp  eax, 126
    ja   ncIgnore
    cmp  nameLen, NAME_LEN - 1
    jae  ncIgnore
    mov  ecx, nameLen
    mov  BYTE PTR nameBuf[ecx], al
    inc  nameLen
    mov  caretVisible, 1
    call Redraw
    ret
ncBack:
    cmp  nameLen, 0
    je   ncIgnore
    dec  nameLen
    mov  ecx, nameLen
    mov  BYTE PTR nameBuf[ecx], 0
    mov  caretVisible, 1
    call Redraw
    ret
ncEnter:
    cmp  nameLen, 0
    je   ncIgnore
    call FindOrCreatePlayer
    mov  menuFocus, 0
    mov  hoverId, 0
    mov  pressedId, 0
    mov  state, ST_MENU
    call Redraw
ncIgnore:
    ret
NameChar ENDP

OnKey PROC USES ebx, vk:DWORD
    mov  eax, vk
    .if eax >= 60h && eax <= 69h
        sub  eax, 30h
        mov  vk, eax
    .endif

    mov  ebx, state
    .if ebx == ST_MENU
        mov  eax, vk
        .if eax >= '1' && eax <= '5'
            sub  eax, '0'
            INVOKE MenuAction, eax
        .elseif eax == K_UP
            .if menuFocus == 0
                mov  menuFocus, 4
            .else
                dec  menuFocus
            .endif
            call Redraw
        .elseif eax == K_DOWN
            inc  menuFocus
            .if menuFocus >= 5
                mov  menuFocus, 0
            .endif
            call Redraw
        .elseif eax == K_ENTER || eax == K_SPACE
            mov  eax, menuFocus
            inc  eax
            INVOKE MenuAction, eax
        .endif

    .elseif ebx == ST_GAME
        mov  eax, vk
        .if eax == K_ESC
            INVOKE AbandonGame
        .elseif eax == K_LEFT
            INVOKE MoveCursor, 0, -1
        .elseif eax == K_RIGHT
            INVOKE MoveCursor, 0, 1
        .elseif eax == K_UP
            INVOKE MoveCursor, -1, 0
        .elseif eax == K_DOWN
            INVOKE MoveCursor, 1, 0
        .elseif eax >= '1' && eax <= '9'
            sub  eax, '0'
            INVOKE TryPlace, eax
        .endif

    .elseif ebx == ST_INSTR || ebx == ST_DASH
        mov  eax, vk
        .if eax == K_ENTER || eax == K_ESC || eax == K_SPACE
            mov  hoverId, 0
            mov  pressedId, 0
            mov  state, ST_MENU
            call Redraw
        .endif

    .elseif ebx == ST_END
        mov  eax, vk
        .if eax == K_ENTER || eax == K_ESC || eax == K_SPACE
            mov  hoverId, 0
            mov  pressedId, 0
            mov  state, ST_DASH
            call Redraw
        .endif
    .endif
    ret
OnKey ENDP

HitTest PROC USES ebx esi, mx:DWORD, my:DWORD
    LOCAL remX:DWORD, remY:DWORD, px1:DWORD, py1:DWORD, px2:DWORD, py2:DWORD, prow:DWORD, pcol:DWORD

    mov  eax, state
    .if eax == ST_NAME
        .if nameLen > 0 && mx >= START_X1 && mx < START_X2 && my >= START_Y1 && my < START_Y2
            mov  eax, 22
            ret
        .endif

    .elseif eax == ST_MENU
        .if mx >= MENU_X1 && mx < MENU_X2 && my >= MENU_Y0
            mov  eax, my
            sub  eax, MENU_Y0
            xor  edx, edx
            mov  ecx, MENU_STEP
            div  ecx
            .if eax < 5 && edx < MENU_H
                inc  eax
                ret
            .endif
        .endif

    .elseif eax == ST_GAME
        .if mx >= BACK_X1 && mx < BACK_X2 && my >= BACK_Y1 && my < BACK_Y2
            mov  eax, 21
            ret
        .endif

        mov  prow, 0
htRowLoop:
        cmp  prow, 3
        jae  htPadDone
        mov  pcol, 0
htColLoop:
        cmp  pcol, 3
        jae  htNextRow

        mov  eax, pcol
        imul eax, eax, PAD_STEP
        add  eax, PAD_X
        mov  px1, eax
        add  eax, PAD_S
        mov  px2, eax

        mov  eax, prow
        imul eax, eax, PAD_STEP
        add  eax, PAD_Y
        mov  py1, eax
        add  eax, PAD_S
        mov  py2, eax

        mov  eax, mx
        cmp  eax, px1
        jl   htNextCol
        cmp  eax, px2
        jge  htNextCol
        mov  eax, my
        cmp  eax, py1
        jl   htNextCol
        cmp  eax, py2
        jge  htNextCol

        imul eax, prow, 3
        add  eax, pcol
        add  eax, 11
        ret

htNextCol:
        inc  pcol
        jmp  htColLoop
htNextRow:
        inc  prow
        jmp  htRowLoop
htPadDone:

        .if mx >= PAD_X && mx < PAD_X + 130 && my >= QUIT_Y && my < QUIT_Y + 42
            mov  eax, 20
            ret
        .endif

    .elseif eax == ST_INSTR || eax == ST_DASH || eax == ST_END
        .if mx >= BACK_X1 && mx < BACK_X2 && my >= BACK_Y1 && my < BACK_Y2
            mov  eax, 21
            ret
        .endif
    .endif
    xor  eax, eax
    ret
HitTest ENDP

OnClick PROC USES ebx esi edi, mx:DWORD, my:DWORD
    LOCAL remX:DWORD, remY:DWORD, px1:DWORD, py1:DWORD, px2:DWORD, py2:DWORD, prow:DWORD, pcol:DWORD

    mov  eax, state
    .if eax == ST_NAME
        .if nameLen > 0 && mx >= START_X1 && mx < START_X2 && my >= START_Y1 && my < START_Y2
            call FindOrCreatePlayer
            mov  menuFocus, 0
            mov  hoverId, 0
            mov  pressedId, 0
            mov  state, ST_MENU
            call Redraw
        .endif

    .elseif eax == ST_MENU
        .if mx >= MENU_X1 && mx < MENU_X2 && my >= MENU_Y0
            mov  eax, my
            sub  eax, MENU_Y0
            xor  edx, edx
            mov  ecx, MENU_STEP
            div  ecx
            .if eax < 5 && edx < MENU_H
                inc  eax
                INVOKE MenuAction, eax
            .endif
        .endif

    .elseif eax == ST_GAME
        .if mx >= BACK_X1 && mx < BACK_X2 && my >= BACK_Y1 && my < BACK_Y2
            INVOKE AbandonGame
            ret
        .endif

        .if mx >= BOARD_X && my >= BOARD_Y
            mov  eax, mx
            sub  eax, BOARD_X
            xor  edx, edx
            mov  ecx, CELL
            div  ecx
            mov  ebx, eax
            mov  eax, my
            sub  eax, BOARD_Y
            xor  edx, edx
            div  ecx
            mov  esi, eax
            .if ebx < 9 && esi < 9
                mov  eax, esi
                mov  cursorRow, al
                mov  eax, ebx
                mov  cursorCol, al
                mov  wrongRow, 0FFh
                mov  wrongCol, 0FFh
                call Redraw
                ret
            .endif
        .endif

        mov  prow, 0
clRowLoop:
        cmp  prow, 3
        jae  clPadDone
        mov  pcol, 0
clColLoop:
        cmp  pcol, 3
        jae  clNextRow

        mov  eax, pcol
        imul eax, eax, PAD_STEP
        add  eax, PAD_X
        mov  px1, eax
        add  eax, PAD_S
        mov  px2, eax

        mov  eax, prow
        imul eax, eax, PAD_STEP
        add  eax, PAD_Y
        mov  py1, eax
        add  eax, PAD_S
        mov  py2, eax

        mov  eax, mx
        cmp  eax, px1
        jl   clNextCol
        cmp  eax, px2
        jge  clNextCol
        mov  eax, my
        cmp  eax, py1
        jl   clNextCol
        cmp  eax, py2
        jge  clNextCol

        imul eax, prow, 3
        add  eax, pcol
        inc  eax
        INVOKE TryPlace, eax
        ret

clNextCol:
        inc  pcol
        jmp  clColLoop
clNextRow:
        inc  prow
        jmp  clRowLoop
clPadDone:

        .if mx >= PAD_X && mx < PAD_X + 130 && my >= QUIT_Y && my < QUIT_Y + 42
            INVOKE AbandonGame
        .endif

    .elseif eax == ST_INSTR || eax == ST_DASH
        mov  hoverId, 0
        mov  pressedId, 0
        mov  state, ST_MENU
        call Redraw

    .elseif eax == ST_END
        mov  hoverId, 0
        mov  pressedId, 0
        mov  state, ST_DASH
        call Redraw
    .endif
    ret
OnClick ENDP

FillRectColor PROC hdc:DWORD, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, clr:DWORD
    LOCAL rc:RECT, hbr:DWORD
    mov  eax, x1
    mov  rc.left, eax
    mov  eax, y1
    mov  rc.top, eax
    mov  eax, x2
    mov  rc.right, eax
    mov  eax, y2
    mov  rc.bottom, eax
    INVOKE CreateSolidBrush, clr
    mov  hbr, eax
    INVOKE FillRect, hdc, ADDR rc, hbr
    INVOKE DeleteObject, hbr
    ret
FillRectColor ENDP

FillRoundRectColor PROC USES ebx esi, hdc:DWORD, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, rad:DWORD, fillClr:DWORD, borderClr:DWORD
    LOCAL hbr:DWORD, hpen:DWORD, oldBr:DWORD, oldPen:DWORD
    INVOKE CreateSolidBrush, fillClr
    mov  hbr, eax
    INVOKE CreatePen, PS_SOLID, 1, borderClr
    mov  hpen, eax
    INVOKE SelectObject, hdc, hbr
    mov  oldBr, eax
    INVOKE SelectObject, hdc, hpen
    mov  oldPen, eax
    INVOKE RoundRect, hdc, x1, y1, x2, y2, rad, rad
    INVOKE SelectObject, hdc, oldBr
    INVOKE SelectObject, hdc, oldPen
    INVOKE DeleteObject, hbr
    INVOKE DeleteObject, hpen
    ret
FillRoundRectColor ENDP

DrawCard PROC hdc:DWORD, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
    LOCAL sx1:DWORD, sy1:DWORD, sx2:DWORD, sy2:DWORD
    mov  eax, x1
    add  eax, 3
    mov  sx1, eax
    mov  eax, y1
    add  eax, 4
    mov  sy1, eax
    mov  eax, x2
    add  eax, 3
    mov  sx2, eax
    mov  eax, y2
    add  eax, 4
    mov  sy2, eax
    INVOKE FillRoundRectColor, hdc, sx1, sy1, sx2, sy2, 14, CLR_SHADOW, CLR_SHADOW
    INVOKE FillRoundRectColor, hdc, x1, y1, x2, y2, 14, CLR_CARD, CLR_CARD_BORDER
    ret
DrawCard ENDP

DrawTxt PROC hdc:DWORD, x:DWORD, y:DWORD, pText:DWORD, clr:DWORD, hf:DWORD
    INVOKE SelectObject, hdc, hf
    INVOKE SetTextColor, hdc, clr
    INVOKE SetBkMode, hdc, TRANSPARENT
    INVOKE lstrlen, pText
    INVOKE TextOut, hdc, x, y, pText, eax
    ret
DrawTxt ENDP

DrawTxtR PROC hdc:DWORD, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, pText:DWORD, clr:DWORD, hf:DWORD, flg:DWORD
    LOCAL rc:RECT
    mov  eax, x1
    mov  rc.left, eax
    mov  eax, y1
    mov  rc.top, eax
    mov  eax, x2
    mov  rc.right, eax
    mov  eax, y2
    mov  rc.bottom, eax
    INVOKE SelectObject, hdc, hf
    INVOKE SetTextColor, hdc, clr
    INVOKE SetBkMode, hdc, TRANSPARENT
    INVOKE DrawText, hdc, pText, -1, ADDR rc, flg
    ret
DrawTxtR ENDP

DrawButton PROC hdc:DWORD, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, pText:DWORD, clr:DWORD, hclr:DWORD, txtClr:DWORD, id:DWORD
    LOCAL sx1:DWORD, sy1:DWORD, sx2:DWORD, sy2:DWORD, by1:DWORD, by2:DWORD, fillc:DWORD, bdr:DWORD

    mov  eax, y1
    mov  by1, eax
    mov  eax, y2
    mov  by2, eax
    mov  eax, clr
    mov  fillc, eax
    mov  bdr, CLR_CARD_BORDER

    mov  eax, id
    .if eax == pressedId && eax == hoverId
        add  by1, 2
        add  by2, 2
        mov  fillc, CLR_BTNP
        mov  bdr, CLR_TITLE
        jmp  dbtDrawBody
    .endif

    .if eax == hoverId
        sub  by1, 2
        sub  by2, 2
        mov  eax, hclr
        mov  fillc, eax
        mov  bdr, CLR_TITLE

        mov  eax, x1
        add  eax, 2
        mov  sx1, eax
        mov  eax, y1
        add  eax, 5
        mov  sy1, eax
        mov  eax, x2
        add  eax, 2
        mov  sx2, eax
        mov  eax, y2
        add  eax, 5
        mov  sy2, eax
        INVOKE FillRoundRectColor, hdc, sx1, sy1, sx2, sy2, 12, CLR_SHADOW, CLR_SHADOW
        jmp  dbtDrawBody
    .endif

    mov  eax, x1
    add  eax, 2
    mov  sx1, eax
    mov  eax, y1
    add  eax, 3
    mov  sy1, eax
    mov  eax, x2
    add  eax, 2
    mov  sx2, eax
    mov  eax, y2
    add  eax, 3
    mov  sy2, eax
    INVOKE FillRoundRectColor, hdc, sx1, sy1, sx2, sy2, 12, CLR_SHADOW, CLR_SHADOW

dbtDrawBody:
    INVOKE FillRoundRectColor, hdc, x1, by1, x2, by2, 12, fillc, bdr
    INVOKE DrawTxtR, hdc, x1, by1, x2, by2, pText, txtClr, hfBold, DTFLAGS
    ret
DrawButton ENDP

DrawHeader PROC hdc:DWORD, pText:DWORD, showBack:DWORD
    INVOKE FillRectColor, hdc, 0, 0, CLIENT_W, 56, CLR_CARD
    INVOKE FillRectColor, hdc, 0, 55, CLIENT_W, 57, CLR_CARD_BORDER
    INVOKE DrawTxtR, hdc, 0, 0, CLIENT_W, 56, pText, CLR_TITLE, hfBig, DTFLAGS
    .if showBack != 0
        INVOKE DrawButton, hdc, BACK_X1, BACK_Y1, BACK_X2, BACK_Y2, ADDR sBackBtn, CLR_BTN, CLR_BTNH, CLR_TEXT, 21
    .endif
    ret
DrawHeader ENDP

DrawStatLine PROC hdc:DWORD, y:DWORD, pFmt:DWORD, val:DWORD
    INVOKE wsprintf, ADDR txtBuf, pFmt, val
    INVOKE DrawTxt, hdc, 50, y, ADDR txtBuf, CLR_TEXT, hfMed
    ret
DrawStatLine ENDP

DrawGridLines PROC USES ebx esi edi, hdc:DWORD
    LOCAL pos:DWORD, t1:DWORD, t2:DWORD, lineClr:DWORD

    xor  esi, esi
glPass:
    .if esi == 0
        mov  t1, 0
        mov  t2, 1
        mov  lineClr, CLR_GRID
    .else
        mov  t1, 1
        mov  t2, 2
        mov  lineClr, CLR_THICK
    .endif

    xor  ebx, ebx
glLine:
    mov  eax, ebx
    xor  edx, edx
    mov  ecx, 3
    div  ecx
    xor  edi, edi
    test edx, edx
    jnz  glCheck
    mov  edi, 1
glCheck:
    cmp  edi, esi
    jne  glNext

    imul eax, ebx, CELL
    mov  pos, eax

    mov  eax, BOARD_X
    add  eax, pos
    mov  ecx, eax
    sub  ecx, t1
    add  eax, t2
    INVOKE FillRectColor, hdc, ecx, BOARD_Y - 1, eax, BOARD_Y + BOARD_PX + 1, lineClr

    mov  eax, BOARD_Y
    add  eax, pos
    mov  ecx, eax
    sub  ecx, t1
    add  eax, t2
    INVOKE FillRectColor, hdc, BOARD_X - 1, ecx, BOARD_X + BOARD_PX + 1, eax, lineClr

glNext:
    inc  ebx
    cmp  ebx, 10
    jb   glLine

    inc  esi
    cmp  esi, 2
    jb   glPass
    ret
DrawGridLines ENDP

DrawBoardGfx PROC USES ebx esi edi, hdc:DWORD
    LOCAL x1:DWORD, y1:DWORD, bgc:DWORD, fgc:DWORD, dg:DWORD, fnt:DWORD, tb[4]:BYTE, selDigit:DWORD, curBox:DWORD

    INVOKE FillRectColor, hdc, BOARD_X + 5, BOARD_Y + 5, BOARD_X + BOARD_PX + 7, BOARD_Y + BOARD_PX + 7, CLR_SHADOW

    movzx eax, cursorRow
    imul eax, eax, 9
    movzx ecx, cursorCol
    add  eax, ecx
    movzx eax, BYTE PTR playerGrid[eax]
    mov  selDigit, eax

    movzx eax, cursorRow
    movzx ecx, cursorCol
    INVOKE GetBoxIndex, eax, ecx
    mov  curBox, eax

    xor  esi, esi
dbRow:
    xor  edi, edi
dbCol:
    imul ebx, esi, 9
    add  ebx, edi
    imul eax, edi, CELL
    add  eax, BOARD_X
    mov  x1, eax
    imul eax, esi, CELL
    add  eax, BOARD_Y
    mov  y1, eax

    mov  bgc, CLR_CARD
    cmp  showCursor, 0
    je   dbNoHl
    movzx eax, cursorRow
    cmp  eax, esi
    jne  dbCheckCol
    movzx eax, cursorCol
    cmp  eax, edi
    jne  dbPeer
    mov  bgc, CLR_SEL
    jmp  dbNoHl
dbCheckCol:
    movzx eax, cursorCol
    cmp  eax, edi
    je   dbPeer
    INVOKE GetBoxIndex, esi, edi
    cmp  eax, curBox
    jne  dbNoHl
dbPeer:
    mov  bgc, CLR_PEER
dbNoHl:
    cmp  showCursor, 0
    je   dbSameDone
    movzx eax, BYTE PTR playerGrid[ebx]
    cmp  eax, 0
    je   dbSameDone
    cmp  eax, selDigit
    jne  dbSameDone
    cmp  bgc, CLR_SEL
    je   dbSameDone
    mov  bgc, CLR_SAME
dbSameDone:

    movzx eax, BYTE PTR playerGrid[ebx]
    mov  dg, eax
    mov  fgc, CLR_PLAYER
    mov  eax, hfBoard
    mov  fnt, eax
    cmp  BYTE PTR puzzle[ebx], 0
    je   dbNotClue
    mov  fgc, CLR_CLUE
    mov  eax, hfBoardB
    mov  fnt, eax
    jmp  dbDraw
dbNotClue:
    cmp  dg, 0
    jne  dbDraw
    movzx eax, wrongRow
    cmp  eax, esi
    jne  dbDraw
    movzx eax, wrongCol
    cmp  eax, edi
    jne  dbDraw
    movzx eax, wrongDigit
    mov  dg, eax
    mov  bgc, CLR_WRONGBG
    mov  fgc, CLR_ERR

dbDraw:
    mov  edx, x1
    add  edx, CELL
    mov  ecx, y1
    add  ecx, CELL
    INVOKE FillRectColor, hdc, x1, y1, edx, ecx, bgc

    cmp  dg, 0
    je   dbNext
    mov  eax, dg
    add  eax, '0'
    mov  BYTE PTR tb[0], al
    mov  BYTE PTR tb[1], 0
    mov  edx, x1
    add  edx, CELL
    mov  ecx, y1
    add  ecx, CELL
    INVOKE DrawTxtR, hdc, x1, y1, edx, ecx, ADDR tb, fgc, fnt, DTFLAGS

dbNext:
    inc  edi
    cmp  edi, 9
    jb   dbCol
    inc  esi
    cmp  esi, 9
    jb   dbRow

    INVOKE DrawGridLines, hdc
    ret
DrawBoardGfx ENDP

DrawNameScr PROC hdc:DWORD
    INVOKE DrawCard, hdc, 130, 55, 630, 485
    INVOKE DrawTxtR, hdc, 0, 80, CLIENT_W, 148, ADDR sTitle, CLR_TITLE, hfTitle, DTFLAGS
    INVOKE DrawTxtR, hdc, 0, 158, CLIENT_W, 192, ADDR sWelcome, CLR_TEXT, hfBold, DTFLAGS
    INVOKE DrawTxt, hdc, 200, 214, ADDR sYourName, CLR_HINT, hfSmall

    INVOKE FillRoundRectColor, hdc, 198, 240, 562, 296, 12, CLR_BG, CLR_TITLE
    INVOKE lstrcpy, ADDR tmpBuf, ADDR nameBuf
    .if caretVisible != 0
        INVOKE lstrcat, ADDR tmpBuf, ADDR sCaret
    .endif
    INVOKE DrawTxtR, hdc, 214, 240, 558, 296, ADDR tmpBuf, CLR_CLUE, hfBold, DT_VCENTER or DT_SINGLELINE

    .if nameLen > 0
        INVOKE DrawButton, hdc, START_X1, START_Y1, START_X2, START_Y2, ADDR sStartBtn, CLR_ACCENT_BTN, CLR_ACCENT_BTNH, CLR_BG, 22
    .else
        INVOKE FillRoundRectColor, hdc, START_X1, START_Y1, START_X2, START_Y2, 12, CLR_BTNDIM, CLR_CARD_BORDER
        INVOKE DrawTxtR, hdc, START_X1, START_Y1, START_X2, START_Y2, ADDR sStartBtn, CLR_DIM_TXT, hfBold, DTFLAGS
    .endif

    INVOKE DrawTxtR, hdc, 0, 392, CLIENT_W, 420, ADDR sNameHint1, CLR_TEXT, hfMed, DTFLAGS
    INVOKE DrawTxtR, hdc, 0, 422, CLIENT_W, 448, ADDR sNameHint2, CLR_HINT, hfSmall, DTFLAGS
    ret
DrawNameScr ENDP

DrawMenuScr PROC USES ebx esi, hdc:DWORD
    LOCAL fillClr:DWORD, hvrClr:DWORD

    INVOKE DrawTxtR, hdc, 0, 30, CLIENT_W, 105, ADDR sTitle, CLR_TITLE, hfTitle, DTFLAGS
    INVOKE wsprintf, ADDR txtBuf, ADDR fmtPlayerIs, ADDR nameBuf
    INVOKE DrawTxtR, hdc, 0, 110, CLIENT_W, 138, ADDR txtBuf, CLR_TEXT, hfMed, DTFLAGS
    .if currentPlayer == -1
        INVOKE DrawTxtR, hdc, 0, 136, CLIENT_W, 158, ADDR sGuestNote, CLR_ERR, hfSmall, DTFLAGS
    .endif

    xor  ebx, ebx
mnLoop:
    imul esi, ebx, MENU_STEP
    add  esi, MENU_Y0
    mov  ecx, esi
    add  ecx, MENU_H
    mov  eax, menuItems[ebx * 4]
    lea  edx, [ebx + 1]

    .if ebx == menuFocus
        mov  fillClr, CLR_BTNH
        mov  hvrClr, CLR_BTNH
    .else
        mov  fillClr, CLR_BTN
        mov  hvrClr, CLR_BTNH
    .endif

    INVOKE DrawButton, hdc, MENU_X1, esi, MENU_X2, ecx, eax, fillClr, hvrClr, CLR_TEXT, edx
    inc  ebx
    cmp  ebx, 5
    jb   mnLoop

    INVOKE DrawTxtR, hdc, 0, 515, CLIENT_W, 540, ADDR sMenuHint, CLR_HINT, hfSmall, DTFLAGS
    .if menuMsg != 0
        INVOKE DrawTxtR, hdc, 0, 548, CLIENT_W, 578, menuMsg, CLR_WARN, hfMed, DTFLAGS
    .endif
    ret
DrawMenuScr ENDP

DrawPadBtn PROC USES ebx esi, hdc:DWORD, prow:DWORD, pcol:DWORD
    LOCAL px1:DWORD, py1:DWORD, px2:DWORD, py2:DWORD, tb[4]:BYTE, digitVal:DWORD, btnId:DWORD

    mov  eax, pcol
    imul eax, eax, PAD_STEP
    add  eax, PAD_X
    mov  px1, eax
    add  eax, PAD_S
    mov  px2, eax

    mov  eax, prow
    imul eax, eax, PAD_STEP
    add  eax, PAD_Y
    mov  py1, eax
    add  eax, PAD_S
    mov  py2, eax

    imul eax, prow, 3
    add  eax, pcol
    mov  ebx, eax
    inc  eax
    mov  digitVal, eax
    add  eax, '0'
    mov  BYTE PTR tb[0], al
    mov  BYTE PTR tb[1], 0
    add  ebx, 11
    mov  btnId, ebx

    INVOKE CountDigitPlaced, digitVal
    .if eax >= 9
        INVOKE FillRoundRectColor, hdc, px1, py1, px2, py2, 8, CLR_BTNDIM, CLR_CARD_BORDER
        INVOKE DrawTxtR, hdc, px1, py1, px2, py2, ADDR tb, CLR_DIM_TXT, hfBold, DTFLAGS
    .else
        INVOKE DrawButton, hdc, px1, py1, px2, py2, ADDR tb, CLR_BTN, CLR_BTNH, CLR_TEXT, btnId
    .endif
    ret
DrawPadBtn ENDP

DrawGameScr PROC USES ebx esi, hdc:DWORD
    INVOKE DrawHeader, hdc, ADDR sTitle, 1
    INVOKE DrawCard, hdc, PAD_X - 15, BOARD_Y, PAD_X + 130 + 15, BOARD_Y + BOARD_PX
    INVOKE DrawBoardGfx, hdc

    INVOKE DrawTxt, hdc, PAD_X, 84, ADDR sPlayerLbl, CLR_HINT, hfSmall
    INVOKE DrawTxt, hdc, PAD_X, 102, ADDR nameBuf, CLR_TITLE, hfBold
    .if currentPlayer == -1
        INVOKE DrawTxt, hdc, PAD_X, 126, ADDR sGuestNote, CLR_ERR, hfSmall
    .endif

    movzx ebx, mistakes
    INVOKE wsprintf, ADDR txtBuf, ADDR fmtMist, ebx
    mov  eax, CLR_OK
    .if ebx == 1
        mov  eax, CLR_WARN
    .elseif ebx >= 2
        mov  eax, CLR_ERR
    .endif
    INVOKE DrawTxt, hdc, PAD_X, 152, ADDR txtBuf, eax, hfBold

    INVOKE wsprintf, ADDR txtBuf, ADDR fmtScore, score
    INVOKE DrawTxt, hdc, PAD_X, 178, ADDR txtBuf, CLR_TEXT, hfBold
    INVOKE DrawTxt, hdc, PAD_X, 200, ADDR sPadLbl, CLR_HINT, hfSmall

    xor  esi, esi
gpRow:
    xor  ebx, ebx
gpCol:
    INVOKE DrawPadBtn, hdc, esi, ebx
    inc  ebx
    cmp  ebx, 3
    jb   gpCol
    inc  esi
    cmp  esi, 3
    jb   gpRow

    mov  eax, hoverId
    .if eax >= 11 && eax <= 19
        sub  eax, 11
        xor  edx, edx
        mov  ecx, 3
        div  ecx
        INVOKE DrawPadBtn, hdc, eax, edx
    .endif

    INVOKE DrawButton, hdc, PAD_X, QUIT_Y, PAD_X + 130, QUIT_Y + 42, ADDR sQuit, CLR_BTNQ, CLR_BTNQH, CLR_TEXT, 20

    .if msgPtr != 0
        ; Extended width & padding to match BOARD_PX (486 width) so the text has comfortable side margins
        INVOKE DrawCard, hdc, BOARD_X, BOARD_Y + BOARD_PX + 12, BOARD_X + BOARD_PX, BOARD_Y + BOARD_PX + 46
        INVOKE DrawTxtR, hdc, BOARD_X + 16, BOARD_Y + BOARD_PX + 12, BOARD_X + BOARD_PX - 16, BOARD_Y + BOARD_PX + 46, msgPtr, CLR_MSG, hfMed, DTFLAGS
    .endif
    ret
DrawGameScr ENDP

DrawEndScr PROC USES ebx esi, hdc:DWORD
    INVOKE DrawHeader, hdc, ADDR sTitle, 1
    INVOKE DrawCard, hdc, PAD_X - 15, BOARD_Y, PAD_X + 130 + 15, BOARD_Y + BOARD_PX
    INVOKE DrawBoardGfx, hdc

    mov  ebx, CLR_OK
    mov  esi, OFFSET sWinTxt
    .if endWin == 0
        mov  ebx, CLR_ERR
        mov  esi, OFFSET sLoseTxt
    .endif
    INVOKE FillRoundRectColor, hdc, PAD_X, 90, PAD_X + 130, 144, 12, ebx, ebx
    INVOKE DrawTxtR, hdc, PAD_X, 90, PAD_X + 130, 144, esi, CLR_BG, hfBold, DTFLAGS

    INVOKE DrawTxt, hdc, PAD_X, 174, ADDR sFinalLbl, CLR_HINT, hfSmall
    INVOKE wsprintf, ADDR txtBuf, ADDR fmtNum, score
    INVOKE DrawTxt, hdc, PAD_X, 194, ADDR txtBuf, CLR_TITLE, hfBig

    INVOKE DrawTxt, hdc, PAD_X, 248, ADDR sUsedLbl, CLR_HINT, hfSmall
    movzx eax, mistakes
    INVOKE wsprintf, ADDR txtBuf, ADDR fmtMist2, eax
    INVOKE DrawTxt, hdc, PAD_X, 268, ADDR txtBuf, CLR_TEXT, hfBold

    .if currentPlayer == -1
        INVOKE DrawTxt, hdc, PAD_X, 318, ADDR sGuestNote, CLR_HINT, hfSmall
    .elseif lastSaveOk != 0
        INVOKE DrawTxt, hdc, PAD_X, 318, ADDR sSaved, CLR_OK, hfSmall
    .else
        INVOKE DrawTxt, hdc, PAD_X, 318, ADDR sSaveFail, CLR_ERR, hfSmall
    .endif
    .if endWin == 0
        INVOKE DrawTxt, hdc, PAD_X, 342, ADDR sSolShown, CLR_HINT, hfSmall
    .endif
    INVOKE DrawTxt, hdc, PAD_X, 410, ADDR sEndHint, CLR_HINT, hfSmall
    ret
DrawEndScr ENDP

DrawDashScr PROC USES ebx esi edi, hdc:DWORD
    INVOKE DrawHeader, hdc, ADDR sDashTitle, 1
    INVOKE DrawCard, hdc, 30, 74, 350, 344
    INVOKE DrawCard, hdc, 370, 74, 730, 344
    INVOKE DrawCard, hdc, 30, 364, 730, 536

    .if currentPlayer == -1
        INVOKE DrawTxt, hdc, 50, 96, ADDR sNoRecord, CLR_TEXT, hfMed
    .else
        mov  esi, currentPlayer
        imul esi, esi, REC_SIZE
        add  esi, OFFSET players

        INVOKE wsprintf, ADDR txtBuf, ADDR fmtName, ADDR nameBuf
        INVOKE DrawTxt, hdc, 50, 92, ADDR txtBuf, CLR_TITLE, hfBold

        mov  eax, [esi + OFF_PLAYED]
        INVOKE DrawStatLine, hdc, 126, ADDR fmtPlayed, eax
        mov  eax, [esi + OFF_WINS]
        INVOKE DrawStatLine, hdc, 156, ADDR fmtWins, eax
        mov  eax, [esi + OFF_LOSSES]
        INVOKE DrawStatLine, hdc, 186, ADDR fmtLosses, eax

        mov  eax, [esi + OFF_WINS]
        imul eax, eax, 100
        mov  ecx, [esi + OFF_PLAYED]
        cmp  ecx, 0
        je   dsNoGames
        xor  edx, edx
        div  ecx
        jmp  dsShowRate
dsNoGames:
        mov  eax, 0
dsShowRate:
        INVOKE DrawStatLine, hdc, 216, ADDR fmtRate, eax
        mov  eax, [esi + OFF_TOTAL]
        INVOKE DrawStatLine, hdc, 246, ADDR fmtTotal, eax
        mov  eax, [esi + OFF_BEST]
        INVOKE DrawStatLine, hdc, 276, ADDR fmtBest, eax
        mov  eax, [esi + OFF_LAST]
        INVOKE DrawStatLine, hdc, 306, ADDR fmtLast, eax
    .endif

    INVOKE BuildLeaderboard
    INVOKE DrawTxt, hdc, 390, 92, ADDR sBoardTitle, CLR_TITLE, hfBold
    .if topCount == 0
        INVOKE DrawTxt, hdc, 390, 126, ADDR sBoardNone, CLR_TEXT, hfMed
    .else
        xor  ebx, ebx
dsBoardLoop:
        mov  eax, topIdx[ebx * 4]
        imul esi, eax, REC_SIZE
        add  esi, OFFSET players
        mov  edx, [esi + OFF_BEST]
        lea  ecx, [ebx + 1]
        INVOKE wsprintf, ADDR txtBuf, ADDR fmtBoard, ecx, esi, edx
        imul edi, ebx, 30
        add  edi, 126
        INVOKE DrawTxt, hdc, 390, edi, ADDR txtBuf, CLR_TEXT, hfMed
        inc  ebx
        cmp  ebx, topCount
        jb   dsBoardLoop
    .endif

    INVOKE DrawTxt, hdc, 50, 380, ADDR sRules0, CLR_TITLE, hfBold
    INVOKE DrawTxt, hdc, 50, 412, ADDR sRules1, CLR_TEXT, hfMed
    INVOKE DrawTxt, hdc, 50, 437, ADDR sRules2, CLR_TEXT, hfMed
    INVOKE DrawTxt, hdc, 50, 462, ADDR sRules3, CLR_TEXT, hfMed
    INVOKE DrawTxt, hdc, 50, 487, ADDR sRules4, CLR_TEXT, hfMed
    INVOKE DrawTxtR, hdc, 0, 558, CLIENT_W, 590, ADDR sBackHint, CLR_HINT, hfSmall, DTFLAGS
    ret
DrawDashScr ENDP

DrawInstrScr PROC USES ebx esi, hdc:DWORD
    INVOKE DrawHeader, hdc, ADDR sInstrTitle, 1
    INVOKE DrawCard, hdc, 40, 74, 720, 576
    mov  ebx, 92
    mov  esi, OFFSET instrTable
inLoop:
    mov  eax, [esi]
    cmp  eax, 0
    je   inDone
    mov  ecx, [esi + 4]
    INVOKE DrawTxt, hdc, 65, ebx, eax, ecx, hfMed
    add  esi, 8
    add  ebx, 25
    jmp  inLoop
inDone:
    INVOKE DrawTxtR, hdc, 0, 584, CLIENT_W, 612, ADDR sBackHint, CLR_HINT, hfSmall, DTFLAGS
    ret
DrawInstrScr ENDP

PaintAll PROC hWin:DWORD
    LOCAL ps:PAINTSTRUCT, hdc:DWORD, mdc:DWORD, hbm:DWORD, hold:DWORD
    LOCAL crc:RECT, winW:DWORD, winH:DWORD, sclW:DWORD, sclH:DWORD

    INVOKE BeginPaint, hWin, ADDR ps
    mov  hdc, eax
    INVOKE GetClientRect, hWin, ADDR crc
    mov  eax, crc.right
    mov  winW, eax
    mov  eax, crc.bottom
    mov  winH, eax
    .if winW == 0 || winH == 0
        INVOKE EndPaint, hWin, ADDR ps
        xor  eax, eax
        ret
    .endif

    INVOKE CreateCompatibleDC, hdc
    mov  mdc, eax
    INVOKE CreateCompatibleBitmap, hdc, winW, winH
    mov  hbm, eax
    INVOKE SelectObject, mdc, hbm
    mov  hold, eax
    INVOKE FillRectColor, mdc, 0, 0, winW, winH, CLR_BG

    mov  eax, winW
    imul eax, eax, CLIENT_H
    mov  ecx, winH
    imul ecx, ecx, CLIENT_W
    cmp  eax, ecx
    ja   ptHeightBound
    mov  eax, winW
    mov  sclW, eax
    imul eax, eax, CLIENT_H
    xor  edx, edx
    mov  ecx, CLIENT_W
    div  ecx
    mov  sclH, eax
    jmp  ptScaled
ptHeightBound:
    mov  eax, winH
    mov  sclH, eax
    imul eax, eax, CLIENT_W
    xor  edx, edx
    mov  ecx, CLIENT_H
    div  ecx
    mov  sclW, eax
ptScaled:
    .if sclW == 0
        mov  sclW, 1
    .endif
    .if sclH == 0
        mov  sclH, 1
    .endif
    mov  eax, winW
    sub  eax, sclW
    shr  eax, 1
    mov  vpX, eax
    mov  eax, winH
    sub  eax, sclH
    shr  eax, 1
    mov  vpY, eax
    mov  eax, sclW
    mov  vpW, eax
    mov  eax, sclH
    mov  vpH, eax

    INVOKE SetMapMode, mdc, MM_ANISOTROPIC
    INVOKE SetWindowExtEx, mdc, CLIENT_W, CLIENT_H, NULL
    INVOKE SetViewportExtEx, mdc, sclW, sclH, NULL
    INVOKE SetViewportOrgEx, mdc, vpX, vpY, NULL

    INVOKE FillRectColor, mdc, 0, 0, CLIENT_W, CLIENT_H, CLR_BG

    .if state == ST_NAME
        INVOKE DrawNameScr, mdc
    .elseif state == ST_MENU
        INVOKE DrawMenuScr, mdc
    .elseif state == ST_GAME
        INVOKE DrawGameScr, mdc
    .elseif state == ST_END
        INVOKE DrawEndScr, mdc
    .elseif state == ST_DASH
        INVOKE DrawDashScr, mdc
    .elseif state == ST_INSTR
        INVOKE DrawInstrScr, mdc
    .endif

    INVOKE SetMapMode, mdc, MM_TEXT
    INVOKE SetViewportOrgEx, mdc, 0, 0, NULL
    INVOKE BitBlt, hdc, 0, 0, winW, winH, mdc, 0, 0, SRCCOPY
    INVOKE SelectObject, mdc, hold
    INVOKE DeleteObject, hbm
    INVOKE DeleteDC, mdc
    INVOKE EndPaint, hWin, ADDR ps
    ret
PaintAll ENDP

END start
