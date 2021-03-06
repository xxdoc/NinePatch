VERSION 5.00
Begin VB.UserControl ctxTouchButton 
   BackStyle       =   0  'Transparent
   CanGetFocus     =   0   'False
   ClientHeight    =   1260
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4044
   ClipBehavior    =   0  'None
   ClipControls    =   0   'False
   DefaultCancel   =   -1  'True
   HitBehavior     =   0  'None
   KeyPreview      =   -1  'True
   ScaleHeight     =   105
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   337
   Windowless      =   -1  'True
End
Attribute VB_Name = "ctxTouchButton"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
DefObj A-Z
Private Const STR_MODULE_NAME As String = "ctxTouchButton"

#Const ImplUseShared = NPPNG_USE_SHARED <> 0
#Const ImplNoIdeProtection = (MST_NO_IDE_PROTECTION <> 0)
#Const ImplSelfContained = True

'=========================================================================
' Public events
'=========================================================================

Event Click()
Attribute Click.VB_UserMemId = -600
Event DblClick()
Attribute DblClick.VB_UserMemId = -601
Event ContextMenu()
Event OwnerDraw(ByVal hGraphics As Long, ByVal hFont As Long, ByVal ButtonState As UcsNineButtonStateEnum, ClientLeft As Long, ClientTop As Long, ClientWidth As Long, ClientHeight As Long, Caption As String, ByVal hPicture As Long)
Event RegisterCancelMode(oCtl As Object, Handled As Boolean)
Event KeyDown(KeyCode As Integer, Shift As Integer)
Attribute KeyDown.VB_UserMemId = -602
Event AccessKeyPress(KeyAscii As Integer)
Event KeyPress(KeyAscii As Integer)
Attribute KeyPress.VB_UserMemId = -604
Event KeyUp(KeyCode As Integer, Shift As Integer)
Event MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute MouseDown.VB_UserMemId = -605
Event MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute MouseMove.VB_UserMemId = -606
Event MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute MouseUp.VB_UserMemId = -607

'=========================================================================
' Public enums
'=========================================================================

#If Not ImplUseShared Then
Public Enum UcsNineButtonStateEnum
    ucsBstNormal = 0
    ucsBstHover = 1
    ucsBstPressed = 2
    ucsBstHoverPressed = 3
    ucsBstDisabled = 4
    ucsBstFocused = 8
End Enum

Public Enum UcsNineButtonStyleEnum
    ucsBtyNone
End Enum
#End If
Private Const ucsBstLast = ucsBstFocused

'=========================================================================
' API
'=========================================================================

'--- for GdipCreateBitmapFromScan0
Private Const PixelFormat32bppARGB          As Long = &H26200A
Private Const PixelFormat32bppPARGB         As Long = &HE200B
'--- for GdipDrawImageXxx
Private Const UnitPixel                     As Long = 2
'--- for GdipSetTextRenderingHint
Private Const TextRenderingHintAntiAlias    As Long = 4
Private Const TextRenderingHintClearTypeGridFit As Long = 5
'--- DIB Section constants
Private Const DIB_RGB_COLORS                As Long = 0 '  color table in RGBs
'--- for GdipBitmapLockBits
Private Const ImageLockModeRead             As Long = &H1
Private Const ImageLockModeWrite            As Long = &H2
'--- for thunks
Private Const MEM_COMMIT                    As Long = &H1000
Private Const PAGE_EXECUTE_READWRITE        As Long = &H40
Private Const CRYPT_STRING_BASE64           As Long = 1

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (lpDst As Any, lpSrc As Any, ByVal ByteLength As Long)
Private Declare Function ArrPtr Lib "msvbvm60" Alias "VarPtr" (Ptr() As Any) As Long
Private Declare Function OleTranslateColor Lib "oleaut32" (ByVal lOleColor As Long, ByVal lHPalette As Long, ByVal lColorRef As Long) As Long
Private Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hDC As Long) As Long
Private Declare Function DeleteDC Lib "gdi32" (ByVal hDC As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hDC As Long, ByVal hObject As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Private Declare Function GetModuleHandle Lib "kernel32" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As Long
Private Declare Function GetIconInfo Lib "user32" (ByVal hIcon As Long, pIconInfo As ICONINFO) As Long
Private Declare Function GetDIBits Lib "gdi32" (ByVal hDC As Long, ByVal hBitmap As Long, ByVal nStartScan As Long, ByVal nNumScans As Long, lpBits As Any, lpBI As BITMAPINFOHEADER, ByVal wUsage As Long) As Long
Private Declare Function CreateDIBSection Lib "gdi32" (ByVal hDC As Long, lpBitsInfo As BITMAPINFOHEADER, ByVal wUsage As Long, lpBits As Long, ByVal Handle As Long, ByVal dw As Long) As Long
Private Declare Function ApiUpdateWindow Lib "user32" Alias "UpdateWindow" (ByVal hWnd As Long) As Long
Private Declare Function GetEnvironmentVariable Lib "kernel32" Alias "GetEnvironmentVariableA" (ByVal lpName As String, ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare Function SetEnvironmentVariable Lib "kernel32" Alias "SetEnvironmentVariableA" (ByVal lpName As String, ByVal lpValue As String) As Long
Private Declare Function AlphaBlend Lib "msimg32" (ByVal hDestDC As Long, ByVal lX As Long, ByVal lY As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal widthSrc As Long, ByVal heightSrc As Long, ByVal blendFunct As Long) As Boolean
'--- gdi+
Private Declare Function GdiplusStartup Lib "gdiplus" (hToken As Long, pInputBuf As Any, Optional ByVal pOutputBuf As Long = 0) As Long
Private Declare Function GdipCreateBitmapFromScan0 Lib "gdiplus" (ByVal lWidth As Long, ByVal lHeight As Long, ByVal lStride As Long, ByVal lPixelFormat As Long, ByVal Scan0 As Long, hBitmap As Long) As Long
Private Declare Function GdipDisposeImage Lib "gdiplus" (ByVal hImage As Long) As Long
Private Declare Function GdipGetImageGraphicsContext Lib "gdiplus" (ByVal hImage As Long, hGraphics As Long) As Long
Private Declare Function GdipDeleteGraphics Lib "gdiplus" (ByVal hGraphics As Long) As Long
Private Declare Function GdipDrawImageRectRect Lib "gdiplus" (ByVal hGraphics As Long, ByVal hImage As Long, ByVal dstX As Single, ByVal dstY As Single, ByVal dstWidth As Single, ByVal dstHeight As Single, ByVal srcX As Single, ByVal srcY As Single, ByVal srcWidth As Single, ByVal srcHeight As Single, Optional ByVal srcUnit As Long = UnitPixel, Optional ByVal hImageAttributes As Long, Optional ByVal pfnCallback As Long, Optional ByVal lCallbackData As Long) As Long
Private Declare Function GdipCreateFromHDC Lib "gdiplus" (ByVal hDC As Long, hGraphics As Long) As Long
Private Declare Function GdipCreateImageAttributes Lib "gdiplus" (hImgAttr As Long) As Long
Private Declare Function GdipSetImageAttributesColorMatrix Lib "gdiplus" (ByVal hImgAttr As Long, ByVal lAdjustType As Long, ByVal fAdjustEnabled As Long, clrMatrix As Any, grayMatrix As Any, ByVal lFlags As Long) As Long
Private Declare Function GdipSetImageAttributesColorKeys Lib "gdiplus" (ByVal hImgAttr As Long, ByVal lAdjustType As Long, ByVal fAdjustEnabled As Long, ByVal clrLow As Long, ByVal clrHigh As Long) As Long
Private Declare Function GdipDisposeImageAttributes Lib "gdiplus" (ByVal hImgAttr As Long) As Long
Private Declare Function GdipBitmapGetPixel Lib "gdiplus" (ByVal hBitmap As Long, ByVal lX As Long, ByVal lY As Long, clrCurrent As Any) As Long
Private Declare Function GdipCreateSolidFill Lib "gdiplus" (ByVal argb As Long, hBrush As Long) As Long
Private Declare Function GdipDeleteBrush Lib "gdiplus" (ByVal hBrush As Long) As Long
Private Declare Function GdipDrawString Lib "gdiplus" (ByVal hGraphics As Long, ByVal lStrPtr As Long, ByVal lLength As Long, ByVal hFont As Long, uRect As RECTF, ByVal hStringFormat As Long, ByVal hBrush As Long) As Long
Private Declare Function GdipSetTextRenderingHint Lib "gdiplus" (ByVal hGraphics As Long, ByVal lMode As Long) As Long
Private Declare Function GdipCloneBitmapAreaI Lib "gdiplus" (ByVal lX As Long, ByVal lY As Long, ByVal lWidth As Long, ByVal lHeight As Long, ByVal lPixelFormat As Long, ByVal srcBitmap As Long, dstBitmap As Long) As Long
Private Declare Function GdipCreateBitmapFromHBITMAP Lib "gdiplus" (ByVal hBmp As Long, ByVal hPal As Long, hBtmap As Long) As Long
Private Declare Function GdipCreateBitmapFromHICON Lib "gdiplus" (ByVal hIcon As Long, hBitmap As Long) As Long
Private Declare Function GdipGetImageDimension Lib "gdiplus" (ByVal Image As Long, ByRef nWidth As Single, ByRef nHeight As Single) As Long '
Private Declare Function GdipCloneImage Lib "gdiplus" (ByVal hImage As Long, hCloneImage As Long) As Long
Private Declare Function GdipBitmapLockBits Lib "gdiplus" (ByVal hBitmap As Long, lpRect As Any, ByVal lFlags As Long, ByVal lPixelFormat As Long, uLockedBitmapData As BitmapData) As Long
Private Declare Function GdipBitmapUnlockBits Lib "gdiplus" (ByVal hBitmap As Long, uLockedBitmapData As BitmapData) As Long
#If Not ImplNoIdeProtection Then
    Private Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" (ByVal hWndParent As Long, ByVal hWndChildAfter As Long, ByVal lpszClass As String, ByVal lpszWindow As String) As Long
    Private Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hWnd As Long, lpdwProcessId As Long) As Long
    Private Declare Function GetCurrentProcessId Lib "kernel32" () As Long
#End If
#If Not ImplUseShared Then
    Private Declare Function QueryPerformanceCounter Lib "kernel32" (lpPerformanceCount As Currency) As Long
    Private Declare Function QueryPerformanceFrequency Lib "kernel32" (lpFrequency As Currency) As Long
    '--- for thunks
    Private Declare Function VirtualAlloc Lib "kernel32" (ByVal lpAddress As Long, ByVal dwSize As Long, ByVal flAllocationType As Long, ByVal flProtect As Long) As Long
    Private Declare Function CryptStringToBinary Lib "crypt32" Alias "CryptStringToBinaryA" (ByVal pszString As String, ByVal cchString As Long, ByVal dwFlags As Long, ByVal pbBinary As Long, pcbBinary As Long, Optional ByVal pdwSkip As Long, Optional ByVal pdwFlags As Long) As Long
    Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
'    Private Declare Function GetModuleHandle Lib "kernel32" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As Long
    Private Declare Function GetProcAddress Lib "kernel32" (ByVal hModule As Long, ByVal lpProcName As String) As Long
#End If

Private Type RECTF
   Left                 As Single
   Top                  As Single
   Right                As Single
   Bottom               As Single
End Type

Private Type BITMAPINFOHEADER
    biSize              As Long
    biWidth             As Long
    biHeight            As Long
    biPlanes            As Integer
    biBitCount          As Integer
    biCompression       As Long
    biSizeImage         As Long
    biXPelsPerMeter     As Long
    biYPelsPerMeter     As Long
    biClrUsed           As Long
    biClrImportant      As Long
End Type

Private Type UcsRgbQuad
    R                   As Byte
    G                   As Byte
    B                   As Byte
    A                   As Byte
End Type

Private Type ICONINFO
    fIcon               As Long
    xHotspot            As Long
    yHotspot            As Long
    hbmMask             As Long
    hbmColor            As Long
End Type

Private Type BitmapData
    Width               As Long
    Height              As Long
    Stride              As Long
    PixelFormat         As Long
    Scan0               As Long
    Reserved            As Long
End Type

Private Type SAFEARRAY1D
    cDims               As Integer
    fFeatures           As Integer
    cbElements          As Long
    cLocks              As Long
    pvData              As Long
    cElements           As Long
    lLbound             As Long
End Type

'=========================================================================
' Constants and variables
'=========================================================================

Private Const DBL_EPLISON           As Double = 0.000001
Private Const DEF_STYLE             As Long = ucsBtyNone
Private Const DEF_ENABLED           As Boolean = True
Private Const DEF_OPACITY           As Single = 1
Private Const DEF_ANIMATIONDURATION As Single = 0
Private Const DEF_FORECOLOR         As Long = vbButtonText
Private Const DEF_MANUALFOCUS       As Boolean = False
Private Const DEF_MASKCOLOR         As Long = vbMagenta
Private Const DEF_AUTOREDRAW        As Boolean = False
Private Const DEF_TEXTOPACITY       As Single = 1
Private Const DEF_TEXTCOLOR         As Long = -1  '--- none
Private Const DEF_TEXTFLAGS         As Long = ucsBflCenter
Private Const DEF_IMAGEOPACITY      As Single = 1
Private Const DEF_SHADOWOPACITY     As Single = 0.5
Private Const DEF_SHADOWCOLOR       As Long = vbButtonShadow

'--- design-time
Private m_eStyle                As UcsNineButtonStyleEnum
Private m_sngOpacity            As Single
Private m_sngAnimationDuration  As Single
Private m_uButton(0 To ucsBstLast) As UcsNineButtonStateType
Private m_sCaption              As String
Private WithEvents m_oFont      As StdFont
Attribute m_oFont.VB_VarHelpID = -1
Private m_clrFore               As Long
Private m_bManualFocus          As Boolean
Private m_oPicture              As StdPicture
Private m_clrMask               As OLE_COLOR
Private m_bAutoRedraw           As Boolean
'--- run-time
Private m_eState                As UcsNineButtonStateEnum
Private m_hPrevBitmap           As Long
Private m_hBitmap               As Long
Private m_hAttributes           As Long
Private m_sngBitmapAlpha        As Single
Private m_hFocusBitmap          As Long
Private m_hFocusAttributes      As Long
Private m_nDownButton           As Integer
Private m_nDownShift            As Integer
Private m_sngDownX              As Single
Private m_sngDownY              As Single
Private m_dblAnimationStart     As Double
Private m_dblAnimationEnd       As Double
Private m_sngAnimationOpacity1  As Single
Private m_sngAnimationOpacity2  As Single
Private m_hFont                 As Long
Private m_bShown                As Boolean
Private m_hPictureBitmap        As Long
Private m_hPictureAttributes    As Long
Private m_eContainerScaleMode   As ScaleModeConstants
Private m_pTimer                As IUnknown
Private m_hRedrawDib            As Long
'--- debug
Private m_sInstanceName         As String
#If DebugMode Then
    Private m_sDebugID          As String
#End If

Private Type UcsNineButtonStateType
    ImageArray()        As Byte
    ImagePatch          As cNinePatch
    ImageOpacity        As Single
    TextFont            As StdFont
    TextFlags           As UcsNineButtonTextFlagsEnum
    TextColor           As OLE_COLOR
    TextOpacity         As Single
    TextOffsetX         As Single
    TextOffsetY         As Single
    ShadowColor         As OLE_COLOR
    ShadowOpacity       As Single
    ShadowOffsetX       As Single
    ShadowOffsetY       As Single
End Type

'=========================================================================
' Error handling
'=========================================================================

Friend Function frInstanceName() As String
    frInstanceName = m_sInstanceName
End Function

Private Property Get MODULE_NAME() As String
#If ImplUseShared Then
    #If DebugMode Then
        MODULE_NAME = GetModuleInstance(STR_MODULE_NAME, frInstanceName, m_sDebugID)
    #Else
        MODULE_NAME = GetModuleInstance(STR_MODULE_NAME, frInstanceName)
    #End If
#Else
    MODULE_NAME = STR_MODULE_NAME
#End If
End Property

Private Function PrintError(sFunction As String) As VbMsgBoxResult
#If ImplUseShared Then
    PopPrintError sFunction, MODULE_NAME, PushError
#Else
    Debug.Print "Critical error: " & Err.Description & " [" & STR_MODULE_NAME & "." & sFunction & "]", Timer
#End If
End Function

'Private Function RaiseError(sFunction As String) As VbMsgBoxResult
'    Err.Raise Err.Number, STR_MODULE_NAME & "." & sFunction & vbCrLf & Err.Source, Err.Description
'End Function

'=========================================================================
' Properties
'=========================================================================

'== design-time ==========================================================

Property Get Style() As UcsNineButtonStyleEnum
    Style = m_eStyle
End Property

Property Let Style(ByVal eValue As UcsNineButtonStyleEnum)
    If m_eStyle <> eValue Then
        m_eStyle = eValue
        pvSetStyle eValue
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get Enabled() As Boolean
Attribute Enabled.VB_UserMemId = -514
    Enabled = UserControl.Enabled
End Property

Property Let Enabled(ByVal bValue As Boolean)
    If UserControl.Enabled <> bValue Then
        UserControl.Enabled = bValue
        pvState(ucsBstDisabled) = Not bValue
    End If
    PropertyChanged
End Property

Property Get Opacity() As Single
    Opacity = m_sngOpacity
End Property

Property Let Opacity(ByVal sngValue As Single)
    If m_sngOpacity <> sngValue Then
        m_sngOpacity = sngValue
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get AnimationDuration() As Single
    AnimationDuration = m_sngAnimationDuration
End Property

Property Let AnimationDuration(sngValue As Single)
    m_sngAnimationDuration = sngValue
    PropertyChanged
End Property

Property Get Caption() As String
Attribute Caption.VB_UserMemId = -518
    Caption = m_sCaption
End Property

Property Let Caption(sValue As String)
    If m_sCaption <> sValue Then
        m_sCaption = sValue
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get Font() As StdFont
Attribute Font.VB_UserMemId = -512
    Set Font = m_oFont
End Property

Property Set Font(oValue As StdFont)
    If Not m_oFont Is oValue Then
        Set m_oFont = oValue
        pvPrepareFont m_oFont, m_hFont
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get ForeColor() As OLE_COLOR
Attribute ForeColor.VB_UserMemId = -513
    ForeColor = m_clrFore
End Property

Property Let ForeColor(ByVal clrValue As OLE_COLOR)
    If m_clrFore <> clrValue Then
        m_clrFore = clrValue
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get ManualFocus() As Boolean
    ManualFocus = m_bManualFocus
End Property

Property Let ManualFocus(ByVal bValue As Boolean)
    m_bManualFocus = bValue
    PropertyChanged
End Property

Property Get Picture() As StdPicture
    Set Picture = m_oPicture
End Property

Property Set Picture(oValue As StdPicture)
    If Not m_oPicture Is oValue Then
        Set m_oPicture = oValue
        pvPreparePicture m_oPicture, m_clrMask, m_hPictureBitmap, m_hPictureAttributes
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get MaskColor() As OLE_COLOR
    MaskColor = m_clrMask
End Property

Property Let MaskColor(ByVal clrValue As OLE_COLOR)
    If m_clrMask <> clrValue Then
        m_clrMask = clrValue
        pvPreparePicture m_oPicture, m_clrMask, m_hPictureBitmap, m_hPictureAttributes
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get AutoRedraw() As Boolean
    AutoRedraw = m_bAutoRedraw
End Property

Property Let AutoRedraw(ByVal bValue As Boolean)
    If m_bAutoRedraw <> bValue Then
        m_bAutoRedraw = bValue
        pvRefresh
        PropertyChanged
    End If
End Property

Property Get ButtonState() As UcsNineButtonStateEnum
    ButtonState = m_eState
End Property

Property Let ButtonState(ByVal eState As UcsNineButtonStateEnum)
    pvState(m_eState And Not eState) = False
    pvState(eState And Not m_eState) = True
    PropertyChanged
End Property

'== run-time =============================================================

Property Get Value() As Boolean
Attribute Value.VB_UserMemId = 0
Attribute Value.VB_MemberFlags = "400"
    '--- do nothing
End Property

Property Let Value(ByVal bValue As Boolean)
    If bValue Then
        pvHandleClick
    End If
End Property

Property Get ButtonImageArray(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Byte()
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonImageArray = m_uButton(eState).ImageArray
End Property

Property Let ButtonImageArray(Optional ByVal eState As UcsNineButtonStateEnum = -1, baValue() As Byte)
    Dim oPatch          As cNinePatch
    
    If eState < 0 Then
        eState = m_eState
    End If
    m_uButton(eState).ImageArray = baValue
    Set oPatch = New cNinePatch
    If oPatch.LoadFromByteArray(baValue) Then
        Set m_uButton(eState).ImagePatch = oPatch
    Else
        Set m_uButton(eState).ImagePatch = Nothing
    End If
    pvRefresh
End Property

Property Get ButtonImageBitmap(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Long
    If eState < 0 Then
        eState = m_eState
    End If
    If Not m_uButton(eState).ImagePatch Is Nothing Then
        ButtonImageBitmap = m_uButton(eState).ImagePatch.Bitmap
    End If
End Property

Property Let ButtonImageBitmap(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal hBitmap As Long)
    Dim oPatch          As cNinePatch
    Dim hNewBitmap      As Long
    
    If eState < 0 Then
        eState = m_eState
    End If
    Set oPatch = New cNinePatch
    Call GdipCloneImage(hBitmap, hNewBitmap)
    If hNewBitmap = 0 Then
        Set m_uButton(eState).ImagePatch = Nothing
    ElseIf oPatch.LoadFromBitmap(hNewBitmap) Then
        Set m_uButton(eState).ImagePatch = oPatch
    Else
        Set m_uButton(eState).ImagePatch = Nothing
    End If
    pvRefresh
End Property

Property Get ButtonImageOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonImageOpacity = m_uButton(eState).ImageOpacity
End Property

Property Let ButtonImageOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).ImageOpacity <> sngValue Then
        m_uButton(eState).ImageOpacity = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonTextFont(Optional ByVal eState As UcsNineButtonStateEnum = -1) As StdFont
    If eState < 0 Then
        eState = m_eState
    End If
    Set ButtonTextFont = m_uButton(eState).TextFont
End Property

Property Set ButtonTextFont(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal oValue As StdFont)
    If eState < 0 Then
        eState = m_eState
    End If
    If Not m_uButton(eState).TextFont Is oValue Then
        Set m_uButton(eState).TextFont = oValue
        pvRefresh
    End If
End Property

Property Get ButtonTextFlags(Optional ByVal eState As UcsNineButtonStateEnum = -1) As UcsNineButtonTextFlagsEnum
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonTextFlags = m_uButton(eState).TextFlags
End Property

Property Let ButtonTextFlags(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal eValue As UcsNineButtonTextFlagsEnum)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).TextFlags <> eValue Then
        m_uButton(eState).TextFlags = eValue
        pvRefresh
    End If
End Property

Property Get ButtonTextColor(Optional ByVal eState As UcsNineButtonStateEnum = -1) As OLE_COLOR
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonTextColor = m_uButton(eState).TextColor
End Property

Property Let ButtonTextColor(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal clrValue As OLE_COLOR)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).TextColor <> clrValue Then
        m_uButton(eState).TextColor = clrValue
        pvRefresh
    End If
End Property

Property Get ButtonTextOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonTextOpacity = m_uButton(eState).TextOpacity
End Property

Property Let ButtonTextOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).TextOpacity <> sngValue Then
        m_uButton(eState).TextOpacity = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonTextOffsetX(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonTextOffsetX = m_uButton(eState).TextOffsetX
End Property

Property Let ButtonTextOffsetX(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).TextOffsetX <> sngValue Then
        m_uButton(eState).TextOffsetX = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonTextOffsetY(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonTextOffsetY = m_uButton(eState).TextOffsetY
End Property

Property Let ButtonTextOffsetY(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).TextOffsetY <> sngValue Then
        m_uButton(eState).TextOffsetY = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonShadowColor(Optional ByVal eState As UcsNineButtonStateEnum = -1) As OLE_COLOR
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonShadowColor = m_uButton(eState).ShadowColor
End Property

Property Let ButtonShadowColor(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal clrValue As OLE_COLOR)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).ShadowColor <> clrValue Then
        m_uButton(eState).ShadowColor = clrValue
        pvRefresh
    End If
End Property

Property Get ButtonShadowOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonShadowOpacity = m_uButton(eState).ShadowOpacity
End Property

Property Let ButtonShadowOpacity(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).ShadowOpacity <> sngValue Then
        m_uButton(eState).ShadowOpacity = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonShadowOffsetX(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonShadowOffsetX = m_uButton(eState).ShadowOffsetX
End Property

Property Let ButtonShadowOffsetX(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).ShadowOffsetX <> sngValue Then
        m_uButton(eState).ShadowOffsetX = sngValue
        pvRefresh
    End If
End Property

Property Get ButtonShadowOffsetY(Optional ByVal eState As UcsNineButtonStateEnum = -1) As Single
    If eState < 0 Then
        eState = m_eState
    End If
    ButtonShadowOffsetY = m_uButton(eState).ShadowOffsetY
End Property

Property Let ButtonShadowOffsetY(Optional ByVal eState As UcsNineButtonStateEnum = -1, ByVal sngValue As Single)
    If eState < 0 Then
        eState = m_eState
    End If
    If m_uButton(eState).ShadowOffsetY <> sngValue Then
        m_uButton(eState).ShadowOffsetY = sngValue
        pvRefresh
    End If
End Property

Property Get DownButton() As Integer
Attribute DownButton.VB_MemberFlags = "400"
    DownButton = m_nDownButton
End Property

'== private ==============================================================

Private Property Get pvState(ByVal eState As UcsNineButtonStateEnum) As Boolean
    pvState = (m_eState And eState) <> 0
End Property

Private Property Let pvState(ByVal eState As UcsNineButtonStateEnum, ByVal bValue As Boolean)
    Dim ePrevState      As UcsNineButtonStateEnum
    
    ePrevState = m_eState
    If bValue Then
        If (m_eState And eState) <> eState Then
            m_eState = m_eState Or eState
        End If
    Else
        If (m_eState And eState) <> 0 Then
            m_eState = m_eState And Not eState
        End If
    End If
    If ePrevState <> m_eState And m_bShown Then
        pvStartAnimation m_sngAnimationDuration, _
            m_sngOpacity * m_uButton(pvGetEffectiveState(ePrevState)).ImageOpacity, _
            m_sngOpacity * m_uButton(pvGetEffectiveState(m_eState)).ImageOpacity
    End If
End Property

Private Property Get pvAddressOfTimerProc() As ctxTouchButton
    Set pvAddressOfTimerProc = InitAddressOfMethod(Me, 0)
End Property

'=========================================================================
' Methods
'=========================================================================

Public Sub Refresh()
    Const FUNC_NAME     As String = "Refresh"
    Dim hMemDC          As Long
    Dim hPrevDib        As Long
    
    On Error GoTo EH
    If m_hRedrawDib <> 0 Then
        Call DeleteObject(m_hRedrawDib)
        m_hRedrawDib = 0
    End If
    If AutoRedraw Then
        hMemDC = CreateCompatibleDC(0)
        If hMemDC = 0 Then
            GoTo QH
        End If
        If Not pvCreateDib(hMemDC, ScaleWidth, ScaleHeight, m_hRedrawDib) Then
            GoTo QH
        End If
        hPrevDib = SelectObject(hMemDC, m_hRedrawDib)
        pvPaintControl hMemDC
    End If
    UserControl.Refresh
QH:
    On Error Resume Next
    If hMemDC <> 0 Then
        Call SelectObject(hMemDC, hPrevDib)
        Call DeleteDC(hMemDC)
        hMemDC = 0
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume QH
End Sub

Public Sub Repaint()
    Const FUNC_NAME     As String = "Repaint"
    
    On Error GoTo EH
    If m_bShown Then
        pvPrepareBitmap m_eState, m_hFocusBitmap, m_hBitmap
        pvPrepareAttribs m_sngOpacity * m_uButton(pvGetEffectiveState(m_eState)).ImageOpacity, m_hAttributes
        Refresh
'        Call ApiUpdateWindow(ContainerHwnd) '--- pump WM_PAINT
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Public Sub CancelMode()
    Const FUNC_NAME     As String = "CancelMode"
    
    On Error GoTo EH
    pvState(ucsBstHoverPressed) = False
    m_nDownButton = 0
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Public Function TimerProc() As Long
Attribute TimerProc.VB_MemberFlags = "40"
    Const FUNC_NAME     As String = "TimerProc"
    
    On Error GoTo EH
    pvAnimateState TimerEx - m_dblAnimationStart, m_sngAnimationOpacity1, m_sngAnimationOpacity2
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume Next
End Function

'== private ==============================================================

Private Function pvGetEffectiveState(ByVal eState As UcsNineButtonStateEnum) As UcsNineButtonStateEnum
    If (eState And ucsBstDisabled) <> 0 Then
        If Not m_uButton(ucsBstDisabled).ImagePatch Is Nothing Then
            pvGetEffectiveState = ucsBstDisabled
            Exit Function
        End If
    End If
    eState = eState And Not ucsBstFocused
    If m_uButton(eState).ImagePatch Is Nothing Then
        eState = eState And Not ucsBstHover
    End If
    If m_uButton(eState).ImagePatch Is Nothing Then
        eState = eState And Not ucsBstPressed
    End If
    If m_uButton(eState).ImagePatch Is Nothing Then
        eState = ucsBstNormal
    End If
    pvGetEffectiveState = eState
End Function

Private Function pvPrepareBitmap(ByVal eState As UcsNineButtonStateEnum, hFocusBitmap As Long, hBitmap As Long) As Boolean
    Const FUNC_NAME     As String = "pvPrepareBitmap"
    Dim hGraphics       As Long
    Dim hNewFocusBitmap As Long
    Dim hNewBitmap      As Long
    Dim lLeft           As Long
    Dim lTop            As Long
    Dim lWidth          As Long
    Dim lHeight         As Long
    Dim hBrush          As Long
    Dim hShadowBrush    As Long
    Dim lOffset         As Long
    Dim uRect           As RECTF
    Dim hStringFormat   As Long
    Dim hFont           As Long
    Dim sngPicWidth     As Single
    Dim sngPicHeight    As Single
    Dim sCaption        As String
    
    On Error GoTo EH
    If (eState And ucsBstFocused) <> 0 And (eState And ucsBstHoverPressed) <> ucsBstHoverPressed Then
        If hFocusBitmap = 0 Then
            With m_uButton(ucsBstFocused)
                If Not .ImagePatch Is Nothing Then
                    If GdipCreateBitmapFromScan0(ScaleWidth, ScaleHeight, ScaleWidth * 4, PixelFormat32bppARGB, 0, hNewFocusBitmap) <> 0 Then
                        GoTo QH
                    End If
                    If GdipGetImageGraphicsContext(hNewFocusBitmap, hGraphics) <> 0 Then
                        GoTo QH
                    End If
                    If Not .ImagePatch.DrawToGraphics(hGraphics, 0, 0, ScaleWidth, ScaleHeight) Then
                        GoTo QH
                    End If
                    Call GdipDeleteGraphics(hGraphics)
                    hGraphics = 0
                End If
            End With
        Else
            hNewFocusBitmap = hFocusBitmap
        End If
    End If
    With m_uButton(pvGetEffectiveState(eState))
        If Not .TextFont Is Nothing Then
            If Not pvPrepareFont(.TextFont, hFont) Then
                GoTo QH
            End If
        Else
            hFont = m_hFont
        End If
        If GdipCreateBitmapFromScan0(ScaleWidth, ScaleHeight, ScaleWidth * 4, PixelFormat32bppARGB, 0, hNewBitmap) <> 0 Then
            GoTo QH
        End If
        If GdipGetImageGraphicsContext(hNewBitmap, hGraphics) <> 0 Then
            GoTo QH
        End If
        If GdipSetTextRenderingHint(hGraphics, TextRenderingHintClearTypeGridFit) <> 0 Then
            GoTo QH
        End If
        If Not .ImagePatch Is Nothing Then
            If Not .ImagePatch.DrawToGraphics(hGraphics, 0, 0, ScaleWidth, ScaleHeight) Then
                GoTo QH
            End If
            .ImagePatch.CalcClientRect ScaleWidth, ScaleHeight, lLeft, lTop, lWidth, lHeight
        Else
            lWidth = ScaleWidth
            lHeight = ScaleHeight
        End If
        sCaption = m_sCaption
        RaiseEvent OwnerDraw(hGraphics, hFont, eState, lLeft, lTop, lWidth, lHeight, sCaption, m_hPictureBitmap)
        If lWidth > 0 And lHeight > 0 Then
            If m_hPictureBitmap <> 0 Then
                If GdipGetImageDimension(m_hPictureBitmap, sngPicWidth, sngPicHeight) <> 0 Then
                    GoTo QH
                End If
                If GdipDrawImageRectRect(hGraphics, m_hPictureBitmap, lLeft + (lWidth - sngPicWidth) / 2, lTop + (lHeight - sngPicHeight) / 2, sngPicWidth, sngPicHeight, 0, 0, sngPicWidth, sngPicHeight, , m_hPictureAttributes) <> 0 Then
                    GoTo QH
                End If
            ElseIf hFont <> 0 And LenB(sCaption) <> 0 Then
                If GdipCreateSolidFill(pvTranslateColor(IIf(.TextColor = DEF_TEXTCOLOR, m_clrFore, .TextColor), .TextOpacity), hBrush) <> 0 Then
                    GoTo QH
                End If
                If Not pvPrepareStringFormat(.TextFlags, hStringFormat) Then
                    GoTo QH
                End If
                lOffset = .TextOffsetX * -((eState And ucsBstHoverPressed) = ucsBstHoverPressed)
                uRect.Left = lLeft + lOffset
                lOffset = .TextOffsetY * -((eState And ucsBstHoverPressed) = ucsBstHoverPressed)
                uRect.Top = lTop + lOffset
                uRect.Right = lWidth
                uRect.Bottom = lHeight
                If .ShadowOffsetX <> 0 Or .ShadowOffsetY <> 0 Or .ImagePatch Is Nothing Then
                    If GdipCreateSolidFill(pvTranslateColor(.ShadowColor, .ShadowOpacity), hShadowBrush) <> 0 Then
                        GoTo QH
                    End If
                    If GdipSetTextRenderingHint(hGraphics, TextRenderingHintAntiAlias) <> 0 Then
                        GoTo QH
                    End If
                    uRect.Left = uRect.Left + .ShadowOffsetX
                    uRect.Top = uRect.Top + .ShadowOffsetY
                    If GdipDrawString(hGraphics, StrPtr(sCaption), -1, hFont, uRect, hStringFormat, hShadowBrush) <> 0 Then
                        GoTo QH
                    End If
                    uRect.Left = uRect.Left - .ShadowOffsetX
                    uRect.Top = uRect.Top - .ShadowOffsetY
                End If
                If GdipDrawString(hGraphics, StrPtr(sCaption), -1, hFont, uRect, hStringFormat, hBrush) <> 0 Then
                    GoTo QH
                End If
            End If
        End If
    End With
    '--- commit
    If hNewFocusBitmap <> hFocusBitmap Then
        If hFocusBitmap <> 0 Then
            Call GdipDisposeImage(hFocusBitmap)
            hFocusBitmap = 0
        End If
        hFocusBitmap = hNewFocusBitmap
    End If
    hNewFocusBitmap = 0
    If hNewBitmap <> hBitmap Then
        If hBitmap <> 0 Then
            Call GdipDisposeImage(hBitmap)
            hBitmap = 0
        End If
        hBitmap = hNewBitmap
    End If
    hNewBitmap = 0
    '-- success
    pvPrepareBitmap = True
QH:
    On Error Resume Next
    If hFont <> 0 And hFont <> m_hFont Then
        Call GdipDeleteFont(hFont)
        hFont = 0
    End If
    If hStringFormat <> 0 Then
        Call GdipDeleteStringFormat(hStringFormat)
        hStringFormat = 0
    End If
    If hShadowBrush <> 0 Then
        Call GdipDeleteBrush(hShadowBrush)
        hShadowBrush = 0
    End If
    If hBrush <> 0 Then
        Call GdipDeleteBrush(hBrush)
        hBrush = 0
    End If
    If hNewFocusBitmap <> 0 Then
        Call GdipDisposeImage(hNewFocusBitmap)
        hNewFocusBitmap = 0
    End If
    If hNewBitmap <> 0 Then
        Call GdipDisposeImage(hNewBitmap)
        hNewBitmap = 0
    End If
    If hGraphics <> 0 Then
        Call GdipDeleteGraphics(hGraphics)
        hGraphics = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Function pvPrepareAttribs(ByVal sngAlpha As Single, hAttributes As Long) As Boolean
    Const FUNC_NAME     As String = "pvPrepareAttribs"
    Dim clrMatrix(0 To 4, 0 To 4) As Single
    Dim hNewAttributes  As Long
    
    On Error GoTo EH
    If GdipCreateImageAttributes(hNewAttributes) <> 0 Then
        GoTo QH
    End If
    clrMatrix(0, 0) = 1
    clrMatrix(1, 1) = 1
    clrMatrix(2, 2) = 1
    clrMatrix(3, 3) = sngAlpha
    clrMatrix(4, 4) = 1
    If GdipSetImageAttributesColorMatrix(hNewAttributes, 0, 1, clrMatrix(0, 0), clrMatrix(0, 0), 0) <> 0 Then
        GoTo QH
    End If
    '--- commit
    If hAttributes <> 0 Then
        Call GdipDisposeImageAttributes(hAttributes)
        hAttributes = 0
    End If
    hAttributes = hNewAttributes
    hNewAttributes = 0
    '--- success
    pvPrepareAttribs = True
QH:
    On Error Resume Next
    If hNewAttributes <> 0 Then
        Call GdipDisposeImageAttributes(hNewAttributes)
        hNewAttributes = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Function pvPrepareFont(oFont As StdFont, hFont As Long) As Boolean
    pvPrepareFont = GdipPrepareFont(oFont, hFont)
End Function

Private Function pvPrepareStringFormat(ByVal lFlags As UcsNineButtonTextFlagsEnum, hStringFormat As Long) As Boolean
    pvPrepareStringFormat = GdipPrepareStringFormat(lFlags, hStringFormat)
End Function

Private Function pvPreparePicture(oPicture As StdPicture, ByVal clrMask As OLE_COLOR, hPictureBitmap As Long, hPictureAttributes As Long) As Boolean
    Const FUNC_NAME     As String = "pvPreparePicture"
    Dim hTempBitmap     As Long
    Dim hNewBitmap      As Long
    Dim hNewAttributes  As Long
    Dim lWidth          As Long
    Dim lHeight         As Long
    Dim uHdr            As BITMAPINFOHEADER
    Dim hMemDC          As Long
    Dim uInfo           As ICONINFO
    Dim baColorBits()   As Byte
    Dim bHasAlpha       As Boolean
    Dim hDib            As Long
    Dim lpBits          As Long
    Dim hPrevDib        As Long
    Dim lIdx            As Long
    
    On Error GoTo EH
    If Not oPicture Is Nothing Then
        If oPicture.Handle <> 0 Then
            Select Case oPicture.Type
            Case vbPicTypeBitmap
                If GdipCreateBitmapFromHBITMAP(oPicture.Handle, 0, hNewBitmap) <> 0 Then
                    GoTo QH
                End If
                If clrMask <> -1 Then
                    If GdipCreateImageAttributes(hNewAttributes) <> 0 Then
                        GoTo QH
                    End If
                    If GdipSetImageAttributesColorKeys(hNewAttributes, 0, 1, pvTranslateColor(clrMask), pvTranslateColor(clrMask)) <> 0 Then
                        GoTo QH
                    End If
                End If
            Case Else
                lWidth = HM2Pix(oPicture.Width)
                lHeight = HM2Pix(oPicture.Height)
                hMemDC = CreateCompatibleDC(0)
                If hMemDC = 0 Then
                    GoTo QH
                End If
                With uHdr
                    .biSize = Len(uHdr)
                    .biPlanes = 1
                    .biBitCount = 32
                    .biWidth = lWidth
                    .biHeight = -lHeight
                    .biSizeImage = (4 * lWidth) * lHeight
                End With
                If oPicture.Type = vbPicTypeIcon Then
                    If GetIconInfo(oPicture.Handle, uInfo) = 0 Then
                        GoTo QH
                    End If
                    ReDim baColorBits(0 To uHdr.biSizeImage - 1) As Byte
                    If GetDIBits(hMemDC, uInfo.hbmColor, 0, lHeight, baColorBits(0), uHdr, DIB_RGB_COLORS) = 0 Then
                        GoTo QH
                    End If
                    For lIdx = 3 To UBound(baColorBits) Step 4
                        If baColorBits(lIdx) <> 0 Then
                            bHasAlpha = True
                            Exit For
                        End If
                    Next
                    If Not bHasAlpha Then
                        '--- note: GdipCreateBitmapFromHICON working ok for old-style (single-bit) transparent icons only
                        If GdipCreateBitmapFromHICON(oPicture.Handle, hNewBitmap) <> 0 Then
                            GoTo QH
                        End If
                    Else
                        If GdipCreateBitmapFromScan0(lWidth, lHeight, 4 * lWidth, PixelFormat32bppARGB, VarPtr(baColorBits(0)), hTempBitmap) <> 0 Then
                            GoTo QH
                        End If
                        '--- note: pixel format (or size) *must* differ from hTempBitmap's one for actual
                        '---   memcpy to happen (PixelFormat32bppARGB -> PixelFormat32bppPARGB)
                        If GdipCloneBitmapAreaI(0, 0, lWidth, lHeight, PixelFormat32bppPARGB, hTempBitmap, hNewBitmap) <> 0 Then
                            GoTo QH
                        End If
                    End If
                Else
                    hDib = CreateDIBSection(hMemDC, uHdr, DIB_RGB_COLORS, lpBits, 0, 0)
                    If hDib = 0 Then
                        GoTo QH
                    End If
                    hPrevDib = SelectObject(hMemDC, hDib)
                    pvRenderPicture oPicture, hMemDC, 0, 0, lWidth, lHeight, 0, oPicture.Height, oPicture.Width, -oPicture.Height
                    If GdipCreateBitmapFromScan0(lWidth, lHeight, 4 * lWidth, PixelFormat32bppARGB, lpBits, hTempBitmap) <> 0 Then
                        GoTo QH
                    End If
                    If GdipCloneBitmapAreaI(0, 0, lWidth, lHeight, PixelFormat32bppPARGB, hTempBitmap, hNewBitmap) <> 0 Then
                        GoTo QH
                    End If
                End If
            End Select
        End If
    End If
    '--- commit
    If hPictureBitmap <> 0 Then
        Call GdipDisposeImage(hPictureBitmap)
        hPictureBitmap = 0
    End If
    hPictureBitmap = hNewBitmap
    hNewBitmap = 0
    If hPictureAttributes <> 0 Then
        Call GdipDisposeImageAttributes(hPictureAttributes)
        hPictureAttributes = 0
    End If
    hPictureAttributes = hNewAttributes
    hNewAttributes = 0
    '--- success
    pvPreparePicture = True
QH:
    On Error Resume Next
    If hNewBitmap <> 0 Then
        Call GdipDisposeImage(hNewBitmap)
        hNewBitmap = 0
    End If
    If hNewAttributes <> 0 Then
        Call GdipDisposeImageAttributes(hNewAttributes)
        hNewAttributes = 0
    End If
    If hTempBitmap <> 0 Then
        Call GdipDisposeImage(hTempBitmap)
        hTempBitmap = 0
    End If
    If hPrevDib <> 0 Then
        Call SelectObject(hMemDC, hPrevDib)
        hPrevDib = 0
    End If
    If hDib <> 0 Then
        Call DeleteObject(hDib)
        hDib = 0
    End If
    If uInfo.hbmColor <> 0 Then
        Call DeleteObject(uInfo.hbmColor)
        uInfo.hbmColor = 0
    End If
    If uInfo.hbmMask <> 0 Then
        Call DeleteObject(uInfo.hbmMask)
        uInfo.hbmMask = 0
    End If
    If hMemDC <> 0 Then
        Call DeleteDC(hMemDC)
        hMemDC = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Function pvTranslateColor(ByVal clrValue As OLE_COLOR, Optional ByVal Alpha As Single = 1) As Long
    Dim uQuad           As UcsRgbQuad
    Dim lTemp           As Long
    
    Call OleTranslateColor(clrValue, 0, VarPtr(uQuad))
    lTemp = uQuad.R
    uQuad.R = uQuad.B
    uQuad.B = lTemp
    lTemp = Alpha * &HFF
    If lTemp > 255 Then
        uQuad.A = 255
    ElseIf lTemp < 0 Then
        uQuad.A = 0
    Else
        uQuad.A = lTemp
    End If
    Call CopyMemory(pvTranslateColor, uQuad, 4)
End Function

Private Function pvParentRegisterCancelMode(oCtl As Object) As Boolean
    Dim bHandled        As Boolean
    
    RaiseEvent RegisterCancelMode(oCtl, bHandled)
    If Not bHandled Then
        On Error GoTo QH
        Parent.RegisterCancelMode oCtl
        On Error GoTo 0
    End If
    '--- success
    pvParentRegisterCancelMode = True
QH:
End Function

Private Function pvHitTest(ByVal X As Single, ByVal Y As Single) As HitResultConstants
    Const FUNC_NAME     As String = "pvHitTest"
    Dim uQuad           As UcsRgbQuad
    
    On Error GoTo EH
    pvHitTest = vbHitResultHit
    If GdipBitmapGetPixel(m_hBitmap, X, Y, uQuad) <> 0 Then
        GoTo QH
    End If
    If uQuad.A < 255 Then
        If uQuad.A > 0 Then
            pvHitTest = vbHitResultTransparent
        Else
            pvHitTest = vbHitResultOutside
        End If
    End If
QH:
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Function pvStartAnimation(ByVal sngDuration As Single, ByVal sngOpacity1 As Single, ByVal sngOpacity2 As Single) As Boolean
    Const FUNC_NAME     As String = "pvStartAnimation"
    Dim hNewBitmap      As Long
    
    On Error GoTo EH
    If Not pvPrepareBitmap(m_eState, m_hFocusBitmap, hNewBitmap) Then
        GoTo QH
    End If
    If m_hPrevBitmap <> 0 Then
        Call GdipDisposeImage(m_hPrevBitmap)
        m_hPrevBitmap = 0
    End If
    m_hPrevBitmap = m_hBitmap
    m_hBitmap = hNewBitmap
    hNewBitmap = 0
    m_dblAnimationStart = TimerEx
    m_dblAnimationEnd = m_dblAnimationStart + sngDuration
    m_sngAnimationOpacity1 = sngOpacity1
    m_sngAnimationOpacity2 = sngOpacity2
    pvAnimateState 0, m_sngAnimationOpacity1, m_sngAnimationOpacity2
QH:
    If hNewBitmap <> 0 Then
        Call GdipDisposeImage(hNewBitmap)
        hNewBitmap = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume Next
End Function

Private Function pvAnimateState(ByVal dblElapsed As Double, ByVal sngOpacity1 As Single, ByVal sngOpacity2 As Single) As Boolean
    Const FUNC_NAME     As String = "pvAnimateState"
    Dim sngOpacity      As Single
    Dim dblFull         As Double

    On Error GoTo EH
    sngOpacity = sngOpacity2
    m_sngBitmapAlpha = 1
    dblFull = (m_dblAnimationEnd - m_dblAnimationStart)
    If dblFull > DBL_EPLISON And dblElapsed <= dblFull Then
        sngOpacity = sngOpacity1 + (sngOpacity2 - sngOpacity1) * dblElapsed / dblFull
        m_sngBitmapAlpha = dblElapsed / dblFull
    End If
    If Not pvPrepareAttribs(sngOpacity, m_hAttributes) Then
        GoTo QH
    End If
    Refresh
    If m_sngBitmapAlpha < 1 Then
        Set m_pTimer = InitFireOnceTimerThunk(Me, pvAddressOfTimerProc.TimerProc)
    End If
    '--- success
    pvAnimateState = True
    Exit Function
QH:
    On Error Resume Next
    If m_hPrevBitmap <> 0 Then
        Call GdipDisposeImage(m_hPrevBitmap)
        m_hPrevBitmap = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Sub pvSetStyle(ByVal eStyle As UcsNineButtonStyleEnum)
    #If eStyle Then '--- touch arg
    #End If
    pvSetEmptyStyle
End Sub

Private Sub pvSetEmptyStyle()
    Dim lIdx            As Long
    Dim uEmpty          As UcsNineButtonStateType

    With uEmpty
        .ImageOpacity = DEF_IMAGEOPACITY
        .TextOpacity = DEF_TEXTOPACITY
        .TextColor = DEF_TEXTCOLOR
        .TextFlags = DEF_TEXTFLAGS
        .ShadowOpacity = DEF_SHADOWOPACITY
        .ShadowColor = DEF_SHADOWCOLOR
    End With
    For lIdx = 0 To UBound(m_uButton)
        m_uButton(lIdx) = uEmpty
    Next
End Sub

Private Sub pvHandleMouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Const FUNC_NAME     As String = "pvHandleMouseDown"
    
    On Error GoTo EH
    m_nDownButton = Button
    m_nDownShift = Shift
    m_sngDownX = X
    m_sngDownY = Y
    If (Button And vbLeftButton) <> 0 Then
        If pvHitTest(X, Y) <> vbHitResultOutside Then
            pvParentRegisterCancelMode Me
            pvState(ucsBstPressed Or ucsBstFocused * (1 + m_bManualFocus)) = True
        End If
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub pvHandleClick()
    Const FUNC_NAME     As String = "pvHandleClick"
    
    On Error GoTo EH
    pvState(ucsBstPressed) = True
    pvState(ucsBstPressed) = False
    Call ApiUpdateWindow(ContainerHwnd) '--- pump WM_PAINT
    RaiseEvent Click
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub pvRenderPicture(pPicture As IPicture, ByVal hDC As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal xSrc As OLE_XPOS_HIMETRIC, ByVal ySrc As OLE_YPOS_HIMETRIC, ByVal cxSrc As OLE_XSIZE_HIMETRIC, ByVal cySrc As OLE_YSIZE_HIMETRIC)
    If Not pPicture Is Nothing Then
        If pPicture.Handle <> 0 Then
            pPicture.Render hDC, X, Y, cx, cy, xSrc, ySrc, cxSrc, cySrc, ByVal 0
        End If
    End If
End Sub

Private Function pvMergeBitmap(ByVal hDstBitmap As Long, ByVal hSrcBitmap As Long, ByVal lDstAlpha As Long, ByVal lSrcAlpha As Long) As Boolean
    Const FUNC_NAME     As String = "pvMergeBitmap"
    Dim uDstData        As BitmapData
    Dim uSrcData        As BitmapData
    Dim uDstArray       As SAFEARRAY1D
    Dim uSrcArray       As SAFEARRAY1D
    Dim baDst()         As Byte
    Dim baSrc()         As Byte
    Dim lIdx            As Long
    Dim lY              As Long
    Dim lX              As Long
    Dim lG              As Long

    On Error GoTo EH
    If GdipBitmapLockBits(hDstBitmap, ByVal 0, ImageLockModeRead Or ImageLockModeWrite, PixelFormat32bppARGB, uDstData) <> 0 Then
        GoTo QH
    End If
    If GdipBitmapLockBits(hSrcBitmap, ByVal 0, ImageLockModeRead, PixelFormat32bppARGB, uSrcData) <> 0 Then
        GoTo QH
    End If
    With uDstArray
        .cDims = 1
        .fFeatures = 1 ' FADF_AUTO
        .cbElements = 1
        .cLocks = 1
        .pvData = uDstData.Scan0
        .cElements = uDstData.Stride * uDstData.Height
    End With
    Call CopyMemory(ByVal ArrPtr(baDst), VarPtr(uDstArray), 4)
    With uSrcArray
        .cDims = 1
        .fFeatures = 1 ' FADF_AUTO
        .cbElements = 1
        .cLocks = 1
        .pvData = uSrcData.Scan0
        .cElements = uSrcData.Stride * uSrcData.Height
    End With
    Call CopyMemory(ByVal ArrPtr(baSrc), VarPtr(uSrcArray), 4)
    For lIdx = 0 To UBound(baDst)
        lY = lIdx \ uDstData.Stride
        If lY < uSrcData.Height Then
            lX = lIdx - (lY * uDstData.Stride)
            If lX < uSrcData.Stride Then
                lG = (baDst(lIdx) * lDstAlpha + baSrc(lY * uSrcData.Stride + lX) * lSrcAlpha) \ 255
                If lG > 255 Then
                    lG = 255
                ElseIf lG < 0 Then
                    lG = 0
                End If
                baDst(lIdx) = lG
            End If
        End If
    Next
    '--- success
    pvMergeBitmap = True
QH:
    On Error Resume Next
    If uDstData.Scan0 <> 0 Then
        Call GdipBitmapUnlockBits(hDstBitmap, uDstData)
    End If
    If uSrcData.Scan0 <> 0 Then
        Call GdipBitmapUnlockBits(hSrcBitmap, uSrcData)
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Public Sub pvRefresh()
    m_bShown = False
    If m_hRedrawDib <> 0 Then
        Call DeleteObject(m_hRedrawDib)
        m_hRedrawDib = 0
    End If
    UserControl.Refresh
End Sub

Private Function pvPaintControl(ByVal hDC As Long) As Boolean
    Const FUNC_NAME     As String = "pvPaintControl"
    Dim hGraphics       As Long
    Dim hMergeBitmap    As Long
    Dim lSrcAlpha       As Long
    
    On Error GoTo EH
    If Not m_bShown Then
        m_bShown = True
        pvPrepareBitmap m_eState, m_hFocusBitmap, m_hBitmap
        pvPrepareAttribs m_sngOpacity * m_uButton(pvGetEffectiveState(m_eState)).ImageOpacity, m_hAttributes
    End If
    If m_hBitmap <> 0 Then
        If m_hPrevBitmap <> 0 Then
            lSrcAlpha = Int(m_sngBitmapAlpha * 255 + 0.5!)
            If lSrcAlpha < 255 Then
                If GdipCloneImage(m_hPrevBitmap, hMergeBitmap) <> 0 Then
                    GoTo QH
                End If
                If lSrcAlpha > 0 Then
                    If Not pvMergeBitmap(hMergeBitmap, m_hBitmap, 255 - lSrcAlpha, lSrcAlpha) Then
                        GoTo QH
                    End If
                End If
            End If
        End If
        If GdipCreateFromHDC(hDC, hGraphics) <> 0 Then
            GoTo QH
        End If
        If m_hFocusBitmap <> 0 Then
            If GdipDrawImageRectRect(hGraphics, m_hFocusBitmap, 0, 0, ScaleWidth, ScaleHeight, 0, 0, ScaleWidth, ScaleHeight, , m_hFocusAttributes) <> 0 Then
                GoTo QH
            End If
        End If
        If GdipDrawImageRectRect(hGraphics, IIf(hMergeBitmap <> 0, hMergeBitmap, m_hBitmap), 0, 0, ScaleWidth, ScaleHeight, 0, 0, ScaleWidth, ScaleHeight, , m_hAttributes) <> 0 Then
            GoTo QH
        End If
    Else
        Line (0, 0)-(ScaleWidth - 1, ScaleHeight - 1), &HE0FFFF, BF
    End If
    '--- success
    pvPaintControl = True
QH:
    On Error Resume Next
    If hGraphics <> 0 Then
        Call GdipDeleteGraphics(hGraphics)
        hGraphics = 0
    End If
    If hMergeBitmap <> 0 Then
        Call GdipDisposeImage(hMergeBitmap)
        hMergeBitmap = 0
    End If
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

Private Function pvCreateDib(ByVal hMemDC As Long, ByVal lWidth As Long, ByVal lHeight As Long, hDib As Long) As Boolean
    Const FUNC_NAME     As String = "pvCreateDib"
    Dim uHdr            As BITMAPINFOHEADER
    Dim lpBits          As Long
    
    On Error GoTo EH
    With uHdr
        .biSize = Len(uHdr)
        .biPlanes = 1
        .biBitCount = 32
        .biWidth = lWidth
        .biHeight = -lHeight
        .biSizeImage = 4 * lWidth * lHeight
    End With
    hDib = CreateDIBSection(hMemDC, uHdr, DIB_RGB_COLORS, lpBits, 0, 0)
    If hDib = 0 Then
        GoTo QH
    End If
    '--- success
    pvCreateDib = True
QH:
    Exit Function
EH:
    PrintError FUNC_NAME
    Resume QH
End Function

#If Not ImplUseShared Then
Private Property Get TimerEx() As Double
    Dim cFreq           As Currency
    Dim cValue          As Currency
    
    Call QueryPerformanceFrequency(cFreq)
    Call QueryPerformanceCounter(cValue)
    TimerEx = cValue / cFreq
End Property

Private Function HM2Pix(ByVal Value As Single) As Long
   HM2Pix = Int(Value * 1440 / 2540 / Screen.TwipsPerPixelX + 0.5!)
End Function

Private Function ToScaleMode(sScaleUnits As String) As ScaleModeConstants
    Select Case sScaleUnits
    Case "Twip"
        ToScaleMode = vbTwips
    Case "Point"
        ToScaleMode = vbPoints
    Case "Pixel"
        ToScaleMode = vbPixels
    Case "Character"
        ToScaleMode = vbCharacters
    Case "Centimeter"
        ToScaleMode = vbCentimeters
    Case "Millimeter"
        ToScaleMode = vbMillimeters
    Case "Inch"
        ToScaleMode = vbInches
    Case Else
        ToScaleMode = vbTwips
    End Select
End Function

Private Function InitAddressOfMethod(pObj As Object, ByVal MethodParamCount As Long) As Object
    Const STR_THUNK     As String = "6AAAAABag+oFV4v6ge9QEMEAgcekEcEAuP9EJAS5+QcAAPOri8LB4AgFuQAAAKuLwsHoGAUAjYEAq7gIAAArq7hEJASLq7hJCIsEq7iBi1Qkq4tEJAzB4AIFCIkCM6uLRCQMweASBcDCCACriTrHQgQBAAAAi0QkCIsAiUIIi0QkEIlCDIHqUBDBAIvCBTwRwQCri8IFUBHBAKuLwgVgEcEAq4vCBYQRwQCri8IFjBHBAKuLwgWUEcEAq4vCBZwRwQCri8IFpBHBALn5BwAAq4PABOL6i8dfgcJQEMEAi0wkEIkRK8LCEAAPHwCLVCQE/0IEi0QkDIkQM8DCDABmkItUJAT/QgSLQgTCBAAPHwCLVCQE/0oEi0IEg/gAfgPCBABZWotCDGgAgAAAagBSUf/gZpC4AUAAgMIIALgBQACAwhAAuAFAAIDCGAC4AUAAgMIkAA==" ' 25.3.2019 14:01:08
    Const THUNK_SIZE    As Long = 16728
    Dim hThunk          As Long
    Dim lSize           As Long
    
    hThunk = VirtualAlloc(0, THUNK_SIZE, MEM_COMMIT, PAGE_EXECUTE_READWRITE)
    If hThunk = 0 Then
        Exit Function
    End If
    Call CryptStringToBinary(STR_THUNK, Len(STR_THUNK), CRYPT_STRING_BASE64, hThunk, THUNK_SIZE)
    lSize = CallWindowProc(hThunk, ObjPtr(pObj), MethodParamCount, GetProcAddress(GetModuleHandle("kernel32"), "VirtualFree"), VarPtr(InitAddressOfMethod))
    Debug.Assert lSize = THUNK_SIZE
End Function

Private Function InitFireOnceTimerThunk(pObj As Object, ByVal pfnCallback As Long, Optional Delay As Long) As IUnknown
    Const STR_THUNK     As String = "6AAAAABag+oFgeogERkAV1aLdCQUg8YIgz4AdCqL+oHHBBMZAIvCBSgSGQCri8IFZBIZAKuLwgV0EhkAqzPAq7kIAAAA86WBwgQTGQBSahj/UhBai/iLwqu4AQAAAKszwKuri3QkFKWlg+8Yi0IMSCX/AAAAUItKDDsMJHULWIsPV/9RFDP/62P/QgyBYgz/AAAAjQTKjQTIjUyIMIB5EwB101jHAf80JLiJeQTHQQiJRCQEi8ItBBMZAAWgEhkAUMHgCAW4AAAAiUEMWMHoGAUA/+CQiUEQiU8MUf90JBRqAGoAiw//URiJRwiLRCQYiTheX7g0ExkALSARGQAFABQAAMIQAGaQi0QkCIM4AHUqg3gEAHUkgXgIwAAAAHUbgXgMAAAARnUSi1QkBP9CBItEJAyJEDPAwgwAuAJAAIDCDACQi1QkBP9CBItCBMIEAA8fAItUJAT/SgSLQgR1HYtCDMZAEwCLCv9yCGoA/1Eci1QkBIsKUv9RFDPAwgQAi1QkBIsKi0EohcB0J1L/0FqD+AF3SYsKUv9RLFqFwHU+iwpSavD/cSD/USRaqQAAAAh1K4sKUv9yCGoA/1EcWv9CBDPAUFT/chD/UhSLVCQIx0IIAAAAAFLodv///1jCFABmkA==" ' 27.3.2019 9:14:57
    Const THUNK_SIZE    As Long = 5652
    Static hThunk       As Long
    Dim aParams(0 To 9) As Long
    Dim lSize           As Long
    
    aParams(0) = ObjPtr(pObj)
    aParams(1) = pfnCallback
    #If ImplSelfContained Then
        If hThunk = 0 Then
            hThunk = pvThunkGlobalData("InitFireOnceTimerThunk")
        End If
    #End If
    If hThunk = 0 Then
        hThunk = VirtualAlloc(0, THUNK_SIZE, MEM_COMMIT, PAGE_EXECUTE_READWRITE)
        If hThunk = 0 Then
            Exit Function
        End If
        Call CryptStringToBinary(STR_THUNK, Len(STR_THUNK), CRYPT_STRING_BASE64, hThunk, THUNK_SIZE)
        aParams(2) = GetProcAddress(GetModuleHandle("ole32"), "CoTaskMemAlloc")
        aParams(3) = GetProcAddress(GetModuleHandle("ole32"), "CoTaskMemFree")
        aParams(4) = GetProcAddress(GetModuleHandle("user32"), "SetTimer")
        aParams(5) = GetProcAddress(GetModuleHandle("user32"), "KillTimer")
        '--- for IDE protection
        Debug.Assert pvGetIdeOwner(aParams(6))
        If aParams(6) <> 0 Then
            aParams(7) = GetProcAddress(GetModuleHandle("user32"), "GetWindowLongA")
            aParams(8) = GetProcAddress(GetModuleHandle("vba6"), "EbMode")
            aParams(9) = GetProcAddress(GetModuleHandle("vba6"), "EbIsResetting")
        End If
        #If ImplSelfContained Then
            pvThunkGlobalData("InitFireOnceTimerThunk") = hThunk
        #End If
    End If
    lSize = CallWindowProc(hThunk, 0, Delay, VarPtr(aParams(0)), VarPtr(InitFireOnceTimerThunk))
    Debug.Assert lSize = THUNK_SIZE
End Function

Private Function pvGetIdeOwner(hIdeOwner As Long) As Boolean
    #If Not ImplNoIdeProtection Then
        Dim lProcessId      As Long
        
        Do
            hIdeOwner = FindWindowEx(0, hIdeOwner, "IDEOwner", vbNullString)
            Call GetWindowThreadProcessId(hIdeOwner, lProcessId)
        Loop While hIdeOwner <> 0 And lProcessId <> GetCurrentProcessId()
    #End If
    pvGetIdeOwner = True
End Function

Private Property Get pvThunkGlobalData(sKey As String) As Long
    Dim sBuffer     As String
    
    sBuffer = String$(50, 0)
    Call GetEnvironmentVariable("_MST_GLOBAL" & App.hInstance & "_" & sKey, sBuffer, Len(sBuffer) - 1)
    pvThunkGlobalData = Val(Left$(sBuffer, InStr(sBuffer, vbNullChar) - 1))
End Property

Private Property Let pvThunkGlobalData(sKey As String, ByVal lValue As Long)
    Call SetEnvironmentVariable("_MST_GLOBAL" & App.hInstance & "_" & sKey, lValue)
End Property
#End If

'=========================================================================
' Event handlers
'=========================================================================

Private Sub m_oFont_FontChanged(ByVal PropertyName As String)
    pvPrepareFont m_oFont, m_hFont
    pvRefresh
    PropertyChanged
End Sub

Private Sub UserControl_AmbientChanged(PropertyName As String)
    If PropertyName = "ScaleUnits" Then
        m_eContainerScaleMode = ToScaleMode(Ambient.ScaleUnits)
    End If
End Sub

Private Sub UserControl_HitTest(X As Single, Y As Single, HitResult As Integer)
    If Ambient.UserMode Then
        HitResult = pvHitTest(X, Y)
    Else
        HitResult = vbHitResultHit
    End If
End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
    RaiseEvent KeyDown(KeyCode, Shift)
End Sub

Private Sub UserControl_KeyPress(KeyAscii As Integer)
    RaiseEvent KeyPress(KeyAscii)
    If KeyAscii = 32 Or KeyAscii = 13 Then
        pvHandleClick
        KeyAscii = 0
    End If
End Sub

Private Sub UserControl_AccessKeyPress(KeyAscii As Integer)
    RaiseEvent AccessKeyPress(KeyAscii)
    If KeyAscii <> 0 Then
        pvHandleClick
        KeyAscii = 0
    End If
End Sub

Private Sub UserControl_KeyUp(KeyCode As Integer, Shift As Integer)
    RaiseEvent KeyUp(KeyCode, Shift)
End Sub

Private Sub UserControl_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    RaiseEvent MouseDown(Button, Shift, ScaleX(X, ScaleMode, m_eContainerScaleMode), ScaleY(Y, ScaleMode, m_eContainerScaleMode))
    pvHandleMouseDown Button, Shift, X, Y
End Sub

Private Sub UserControl_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Const FUNC_NAME     As String = "UserControl_MouseMove"
    
    On Error GoTo EH
    RaiseEvent MouseMove(Button, Shift, ScaleX(X, ScaleMode, m_eContainerScaleMode), ScaleY(Y, ScaleMode, m_eContainerScaleMode))
    If Button = -1 Then
        GoTo QH
    End If
    If X >= 0 And X < ScaleWidth And Y >= 0 And Y < ScaleHeight Then
        If Not pvState(ucsBstHover) Then
            If pvParentRegisterCancelMode(Me) Then
                pvState(ucsBstHover) = True
            End If
        End If
        pvState(ucsBstPressed) = (Button And vbLeftButton) <> 0
    Else
        pvState(ucsBstPressed) = False
    End If
QH:
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Const FUNC_NAME     As String = "UserControl_MouseUp"
    
    On Error GoTo EH
    RaiseEvent MouseUp(Button, Shift, ScaleX(X, ScaleMode, m_eContainerScaleMode), ScaleY(Y, ScaleMode, m_eContainerScaleMode))
    If Button = -1 Then
        GoTo QH
    End If
    If (Button And vbLeftButton) <> 0 Then
        pvState(ucsBstPressed) = False
    End If
    If Button <> 0 And X >= 0 And X < ScaleWidth And Y >= 0 And Y < ScaleHeight Then
        If (m_nDownButton And Button And vbLeftButton) <> 0 Then
            Call ApiUpdateWindow(ContainerHwnd) '--- pump WM_PAINT
            RaiseEvent Click
        ElseIf (m_nDownButton And Button And vbRightButton) <> 0 Then
            RaiseEvent ContextMenu
        End If
    Else
        pvState(ucsBstHover) = False
    End If
    m_nDownButton = 0
QH:
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_DblClick()
    pvHandleMouseDown vbLeftButton, m_nDownShift, m_sngDownX, m_sngDownY
    RaiseEvent DblClick
End Sub

Private Sub UserControl_Paint()
    Const FUNC_NAME     As String = "UserControl_Paint"
    Const AC_SRC_ALPHA  As Long = 1
    Const Opacity       As Long = &HFF
    Dim hMemDC          As Long
    Dim hPrevDib        As Long
    
    On Error GoTo EH
    If AutoRedraw Then
        hMemDC = CreateCompatibleDC(hDC)
        If hMemDC = 0 Then
            GoTo QH
        End If
        If m_hRedrawDib = 0 Then
            If Not pvCreateDib(hMemDC, ScaleWidth, ScaleHeight, m_hRedrawDib) Then
                GoTo QH
            End If
            hPrevDib = SelectObject(hMemDC, m_hRedrawDib)
            If Not pvPaintControl(hMemDC) Then
                GoTo QH
            End If
        Else
            hPrevDib = SelectObject(hMemDC, m_hRedrawDib)
        End If
        Call AlphaBlend(hDC, 0, 0, ScaleWidth, ScaleHeight, hMemDC, 0, 0, ScaleWidth, ScaleHeight, AC_SRC_ALPHA * &H1000000 + Opacity * &H10000)
    Else
        pvPaintControl hDC
    End If
QH:
    On Error Resume Next
    If hMemDC <> 0 Then
        Call SelectObject(hMemDC, hPrevDib)
        Call DeleteDC(hMemDC)
        hMemDC = 0
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume QH
End Sub

Private Sub UserControl_EnterFocus()
    Const FUNC_NAME     As String = "UserControl_EnterFocus"
    
    On Error GoTo EH
    If Not m_bManualFocus Then
        pvState(ucsBstFocused) = True
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_ExitFocus()
    Const FUNC_NAME     As String = "UserControl_ExitFocus"
    
    On Error GoTo EH
    If Not m_bManualFocus Then
        pvState(ucsBstFocused) = False
    End If
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_InitProperties()
    Const FUNC_NAME     As String = "UserControl_InitProperties"
    
    On Error GoTo EH
    m_eContainerScaleMode = ToScaleMode(Ambient.ScaleUnits)
    Style = DEF_STYLE
    Enabled = DEF_ENABLED
    Opacity = DEF_OPACITY
    AnimationDuration = DEF_ANIMATIONDURATION
    Caption = Ambient.DisplayName
    Set Font = Ambient.Font
    ForeColor = DEF_FORECOLOR
    ManualFocus = DEF_MANUALFOCUS
    MaskColor = DEF_MASKCOLOR
    AutoRedraw = DEF_AUTOREDRAW
    On Error GoTo QH
    m_sInstanceName = TypeName(Extender.Parent) & "." & Extender.Name
    #If DebugMode Then
        DebugInstanceName m_sInstanceName, m_sDebugID
    #End If
QH:
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)
    Const FUNC_NAME     As String = "UserControl_ReadProperties"
    
    On Error GoTo EH
    m_eContainerScaleMode = ToScaleMode(Ambient.ScaleUnits)
    With PropBag
        Style = .ReadProperty("Style", DEF_STYLE)
        Enabled = .ReadProperty("Enabled", DEF_ENABLED)
        Opacity = .ReadProperty("Opacity", DEF_OPACITY)
        AnimationDuration = .ReadProperty("AnimationDuration", DEF_ANIMATIONDURATION)
        Caption = .ReadProperty("Caption", vbNullString)
        Set Font = .ReadProperty("Font", Ambient.Font)
        ForeColor = .ReadProperty("ForeColor", DEF_FORECOLOR)
        ManualFocus = .ReadProperty("ManualFocus", DEF_MANUALFOCUS)
        MaskColor = .ReadProperty("MaskColor", DEF_MASKCOLOR)
        AutoRedraw = .ReadProperty("AutoRedraw", DEF_AUTOREDRAW)
    End With
    On Error GoTo QH
    m_sInstanceName = TypeName(Extender.Parent) & "." & Extender.Name
    #If DebugMode Then
        DebugInstanceName m_sInstanceName, m_sDebugID
    #End If
QH:
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_WriteProperties(PropBag As PropertyBag)
    Const FUNC_NAME     As String = "UserControl_WriteProperties"
    
    On Error GoTo EH
    With PropBag
        .WriteProperty "Style", Style, DEF_STYLE
        .WriteProperty "Enabled", Enabled, DEF_ENABLED
        .WriteProperty "Opacity", Opacity, DEF_OPACITY
        .WriteProperty "AnimationDuration", AnimationDuration, DEF_ANIMATIONDURATION
        .WriteProperty "Caption", Caption, vbNullString
        .WriteProperty "Font", Font, Ambient.Font
        .WriteProperty "ForeColor", ForeColor, DEF_FORECOLOR
        .WriteProperty "ManualFocus", ManualFocus, DEF_MANUALFOCUS
        .WriteProperty "MaskColor", MaskColor, DEF_MASKCOLOR
        .WriteProperty "AutoRedraw", AutoRedraw, DEF_AUTOREDRAW
    End With
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_Resize()
    Const FUNC_NAME     As String = "UserControl_Resize"
    
    On Error GoTo EH
    If m_hFocusBitmap <> 0 Then
        Call GdipDisposeImage(m_hFocusBitmap)
        m_hFocusBitmap = 0
    End If
    pvRefresh
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

Private Sub UserControl_Hide()
    Const FUNC_NAME     As String = "UserControl_Hide"
    
    On Error GoTo EH
    m_bShown = False
    If m_hPrevBitmap <> 0 Then
        Call GdipDisposeImage(m_hPrevBitmap)
        m_hPrevBitmap = 0
    End If
    CancelMode
    Set m_pTimer = Nothing
    Exit Sub
EH:
    PrintError FUNC_NAME
    Resume Next
End Sub

'=========================================================================
' Base class events
'=========================================================================

Private Sub UserControl_Initialize()
    Dim aInput(0 To 3)  As Long
    
    #If DebugMode Then
        DebugInstanceInit MODULE_NAME, m_sDebugID, Me
    #End If
    If GetModuleHandle("gdiplus") = 0 Then
        aInput(0) = 1
        Call GdiplusStartup(0, aInput(0))
    End If
    m_eContainerScaleMode = vbTwips
    pvSetEmptyStyle
End Sub

Private Sub UserControl_Terminate()
    If m_hAttributes <> 0 Then
        Call GdipDisposeImageAttributes(m_hAttributes)
        m_hAttributes = 0
    End If
    If m_hBitmap <> 0 Then
        Call GdipDisposeImage(m_hBitmap)
        m_hBitmap = 0
    End If
    If m_hPrevBitmap <> 0 Then
        Call GdipDisposeImage(m_hPrevBitmap)
        m_hPrevBitmap = 0
    End If
    If m_hFocusBitmap <> 0 Then
        Call GdipDisposeImage(m_hFocusBitmap)
        m_hFocusBitmap = 0
    End If
    If m_hFocusAttributes <> 0 Then
        Call GdipDisposeImageAttributes(m_hFocusAttributes)
        m_hFocusAttributes = 0
    End If
    If m_hFont <> 0 Then
        Call GdipDeleteFont(m_hFont)
        m_hFont = 0
    End If
    If m_hPictureBitmap <> 0 Then
        Call GdipDisposeImage(m_hPictureBitmap)
        m_hPictureBitmap = 0
    End If
    If m_hPictureAttributes <> 0 Then
        Call GdipDisposeImageAttributes(m_hPictureAttributes)
        m_hPictureAttributes = 0
    End If
    If m_hRedrawDib <> 0 Then
        Call DeleteObject(m_hRedrawDib)
        m_hRedrawDib = 0
    End If
    Set m_pTimer = Nothing
    #If DebugMode Then
        DebugInstanceTerm MODULE_NAME, m_sDebugID
    #End If
End Sub
