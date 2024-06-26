VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "FileTool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'test
' Classe FileHandler
Private pPath As String
Private pReadOnly As Boolean
Private pHidden As Boolean
Private pFullPath As String

' Propri�t� Path
Public Property Let path(ByVal Value As String)
    pPath = Value
End Property

Public Property Get path() As String
    path = pPath
End Property

' Propri�t� ReadOnly
Public Property Let readOnly(ByVal Value As Boolean)
    pReadOnly = Value
End Property

Public Property Get readOnly() As Boolean
    readOnly = pReadOnly
End Property

' Propri�t� Hidden
Public Property Let hidden(ByVal Value As Boolean)
    pHidden = Value
End Property

Public Property Get hidden() As Boolean
    hidden = pHidden
End Property

' Propri�t� FullPath
Public Property Let FullPath(ByVal Value As String)
    pFullPath = Value
End Property

Public Property Get FullPath() As String
    FullPath = pFullPath
End Property

' M�thode pour d�finir le classeur actuel
Public Sub setThisWorkbook()
    ' D�finir le chemin du classeur actuel
    pPath = ThisWorkbook.path
    
    ' D�finir si le classeur est en lecture seule
    pReadOnly = ThisWorkbook.readOnly
    
    ' V�rifier si le classeur est ouvert dans une fen�tre
    If ThisWorkbook.Windows.Count > 0 Then
        ' D�finir si le classeur est cach�
        pHidden = Not ThisWorkbook.Windows(1).Visible
    Else
        ' Si le classeur n'est pas ouvert dans une fen�tre, d�finir pHidden comme False
        pHidden = False
    End If
    
    ' D�finir le chemin complet du classeur
    pFullPath = ThisWorkbook.path & "\" & ThisWorkbook.Name
End Sub



' M�thode pour ouvrir un fichier
Public Sub openFile(applicationName As String, filePath As String)
    Dim cmd As String
    cmd = "cmd /c start """" """ & applicationName & """ """ & filePath & """"
    Call Shell(cmd, vbNormalFocus)
End Sub

' Dans la classe FileManager
Public Function isFileOpen(filePath As String) As Boolean
    Dim fileNum As Integer
    Dim isOpen As Boolean
    
    On Error Resume Next
    fileNum = FreeFile()
    Open filePath For Binary Lock Read Write As #fileNum
    If Err.Number <> 0 Then
        ' Si une erreur se produit, cela signifie que le fichier est d�j� ouvert
        isOpen = True
    Else
        ' Si aucune erreur ne se produit, cela signifie que le fichier n'est pas ouvert
        Close #fileNum
        isOpen = False
    End If
    On Error GoTo 0
    
    isFileOpen = isOpen
End Function



' M�thode pour fermer un fichier
Public Sub closeFile()
    ' Code pour fermer un fichier
End Sub

' M�thode pour v�rifier si un fichier existe
Public Function fileExists() As Boolean
    ' Code pour v�rifier si un fichier existe
End Function

' M�thode pour obtenir la date de derni�re sauvegarde d'un fichier
Public Function lastSaved() As Date
    ' V�rifiez si le fichier existe
    If pPath <> "" Then
        ' Obtenez la date de derni�re modification du fichier
        lastSaved = FileDateTime(pPath)
    Else
        ' Si le fichier n'existe pas, renvoyez une date vide
        lastSaved = 0
    End If
End Function

' M�thode pour obtenir un fichier � partir d'un chemin
Public Function getFileFromPath(path As String) As String
    ' Code pour obtenir un fichier � partir d'un chemin
End Function

' M�thode pour obtenir un dossier � partir d'un chemin
Public Function getFolderFromPath(path As String) As String
    ' Code pour obtenir un dossier � partir d'un chemin
End Function

' M�thode pour obtenir le dossier o� le script est ex�cut�
Public Function getFolderWhereScriptIsRun() As String
    ' Code pour obtenir le dossier o� le script est ex�cut�
End Function

' M�thode pour obtenir le chemin o� le script est ex�cut�
Public Function getPathWhereScriptIsRun() As String
    ' Code pour obtenir le chemin o� le script est ex�cut�
End Function

Public Sub FileFinder(FileName As String, selectedFolder As String, isRecursif As Boolean, recursifLimit As Integer, Optional ignoreHidden As Boolean = True)
    Dim fso As Object
    Dim Folder As Object
    Dim Subfolder As Object
    Dim File As Object

    If recursifLimit = 0 Then Exit Sub

    ' V�rifiez si selectedFolder se termine par un backslash
    If Right(selectedFolder, 1) <> "\" Then
        selectedFolder = selectedFolder & "\"
    End If

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set Folder = fso.GetFolder(selectedFolder)

    ' Parcourir tous les fichiers dans le dossier
    For Each File In Folder.Files
        If File.Name = FileName Then
            pFullPath = File.path
            pPath = selectedFolder
            Exit Sub
        End If
    Next File

    ' Parcourir les sous-dossiers si isRecursif est True
    If isRecursif Then
        For Each Subfolder In Folder.Subfolders
            ' Ignore les dossiers cach�s si ignoreHidden est True
            If ignoreHidden And Subfolder.Attributes And 2 Then
                ' Ce dossier est cach�, donc on l'ignore
            Else
                FileFinder FileName, Subfolder.path, isRecursif, recursifLimit - 1, ignoreHidden
            End If
        Next Subfolder
    End If

    Set File = Nothing
    Set Folder = Nothing
    Set fso = Nothing
End Sub


' M�thode pour renommer un fichier
Public Sub renameFileTo()
    ' Code pour renommer un fichier
End Sub

' M�thode pour obtenir le dossier de l'utilisateur
Public Function getUserFolder() As String
    ' Code pour obtenir le dossier de l'utilisateur
End Function

' M�thode pour d�placer un fichier
Public Sub moveFileTo()
    ' Code pour d�placer un fichier
End Sub

Function GetAbsolutePath(RelativePath As String) As String
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Obtenez le chemin du r�pertoire de travail actuel
    Dim CurrentDirectory As String
    CurrentDirectory = CurDir
    
    ' Combinez le chemin du r�pertoire de travail actuel avec le chemin relatif
    Dim CombinedPath As String
    CombinedPath = CurrentDirectory & RelativePath
    
    ' V�rifiez si le dossier combin� existe
    If fso.FolderExists(CombinedPath) Then
        ' Si le dossier existe, retournez le chemin combin�
        GetAbsolutePath = CombinedPath
    Else
        ' Si le dossier n'existe pas, remontez d'un niveau et r�essayez
        GetAbsolutePath = GetAbsolutePath("..\" & RelativePath)
    End If
    
    Set fso = Nothing
End Function


