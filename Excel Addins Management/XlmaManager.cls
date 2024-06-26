VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "XlmaManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Type VBIDE
    VBProject As VBIDE.VBProject
End Type

Private this As VBIDE

' Ajoutez cette constante en haut de votre classe
Private Const DEFAULT_LOADING_FOLDER As String = "\\STCCWP0015\pierre.leroy$\07_Code\Excel\"

' M�thode pour charger une liste de modules
Public Sub include(nomsDesModules() As Variant, Optional targetProject As VBIDE.VBProject)
    Dim nomDuModule As Variant
    Dim cheminDuModule As String
    Dim managedFile As New FileTool

    For Each nomDuModule In nomsDesModules
        ' Utilisez FileFinder pour obtenir le chemin du module
        ' Essayez d'abord avec l'extension .bas
        managedFile.FileFinder nomDuModule & ".bas", DEFAULT_LOADING_FOLDER, True, 10
        cheminDuModule = managedFile.FullPath

        ' Si aucun fichier n'a �t� trouv�, essayez avec l'extension .cls
        If cheminDuModule = "" Then
            managedFile.FileFinder nomDuModule & ".cls", DEFAULT_LOADING_FOLDER, True, 10
            cheminDuModule = managedFile.FullPath
        End If

        ' Si aucun fichier n'a �t� trouv�, affichez un message d'erreur
        If cheminDuModule = "" Then
            MsgBox "Impossible de trouver le module " & nomDuModule & " dans le dossier : " & DEFAULT_LOADING_FOLDER, vbCritical, "Module non trouv�"
        Else
            ' Appelle la m�thode addModule pour charger le module
            Me.refreshModule cheminDuModule, targetProject
        End If
    Next nomDuModule
End Sub



' Constructeur de la classe
Public Sub Class_Initialize()
    On Error GoTo 0
    ' Initialise le projet VBA pour ce classeur
    Set this.VBProject = ThisWorkbook.VBProject
    Me.refreshModule "\\STCCWP0015\pierre.leroy$\07_Code\Excel\File Management\FileTool.cls"
End Sub

Public Sub refreshModule(cheminDuModule As String, Optional targetProject As VBIDE.VBProject)
    Dim nomDuModule As String
    Dim modulesCharges As Collection
    Dim moduleEstCharge As Boolean
    Dim i As Integer
    Dim lastSavedModule As Date
    Dim lastSavedExcel As Date

    ' Obtenez le nom du module � partir du chemin du module
    nomDuModule = Mid(cheminDuModule, InStrRev(cheminDuModule, "\") + 1)
    nomDuModule = Left(nomDuModule, InStrRev(nomDuModule, ".") - 1)
    
    'Obtenir le VBA Project
    If targetProject Is Nothing Then
        Set targetProject = this.VBProject
    End If

    ' Obtenez la liste des modules charg�s
    Set modulesCharges = Me.modulesLoaded(targetProject)

    ' V�rifiez si le module est d�j� charg�
    moduleEstCharge = False
    For i = 1 To modulesCharges.Count
        If modulesCharges.Item(i) = nomDuModule Then
            moduleEstCharge = True
            Exit For
        End If
    Next i

    ' Si le module n'est pas charg�, ajoutez-le et terminez la fonction
    If Not moduleEstCharge Then
        ' Si targetProject n'est pas fourni, utilisez this.VBProject
        Me.addModule cheminDuModule, targetProject
        Exit Sub
    End If

    ' Obtenez la date de derni�re modification du module
    lastSavedModule = FileDateTime(cheminDuModule)
    ' Obtenez la date de derni�re sauvegarde du classeur
    lastSavedExcel = ThisWorkbook.BuiltinDocumentProperties("Last Save Time")

    ' Si la date de derni�re modification du module est plus r�cente que la date de derni�re sauvegarde du classeur, rechargez le module
    If lastSavedModule > lastSavedExcel Then
        ' Fermez le module s'il existe d�j�
        Me.CloseModule nomDuModule, targetProject

    ' Si la date de derni�re sauvegarde du classeur est plus r�cente que la date de derni�re modification du module, exportez le module vers le fichier
    ElseIf lastSavedModule < lastSavedExcel Then
        ' Exportez le module vers le fichier
        targetProject.VBComponents.Item(nomDuModule).Export cheminDuModule
    End If
End Sub

' M�thode pour ajouter un module � partir de son chemin
Public Sub addModule(cheminDuModule As String, Optional targetProject As VBIDE.VBProject)
    ' Si targetProject n'est pas fourni, utilisez this.VBProject
    If targetProject Is Nothing Then
        Set targetProject = this.VBProject
    End If
    
    ' Essayez d'importer un module � partir d'un fichier
    On Error GoTo ErrorHandler
    targetProject.VBComponents.Import cheminDuModule
    Exit Sub
ErrorHandler:
    ' Affiche un message si le module ne peut pas �tre charg�
    MsgBox "[XlmaManager]{addModule} Impossible de charger le module � partir du chemin : " & cheminDuModule, vbCritical, "Erreur de chargement du module"
End Sub

' M�thode pour fermer un module sp�cifique
Public Sub CloseModule(nomDuModule As String, Optional targetProject As VBIDE.VBProject)
    Dim vbComp As VBIDE.VBComponent
    
    If targetProject Is Nothing Then
        Set targetProject = this.VBProject
    End If
    
    ' Parcourez tous les composants du projet VBA
    For Each vbComp In targetProject.VBComponents
        ' Si le nom du composant correspond au nom du module, supprimez le module
        If vbComp.Name = nomDuModule Then
            targetProject.VBComponents.Remove vbComp
            Exit Sub
        End If
    Next vbComp
    
    ' Si le module n'existe pas, affichez un message d'erreur
    MsgBox "[XlmaManager]{removeModule} Le module " & nomDuModule & " n'existe pas dans ce projet.", vbExclamation
End Sub


' M�thode pour fermer tous les modules sauf le module actif
Public Sub CloseAllExceptActiveModules()
    Dim vbComp As VBIDE.VBComponent
    Dim moduleActif As String
    Dim modulesASupprimer As Collection
    Set modulesASupprimer = New Collection

    ' Obtenez le nom du module actif
    moduleActif = Application.VBE.ActiveCodePane.CodeModule.Name

    ' Parcourez tous les composants du projet VBA
    For Each vbComp In this.VBProject.VBComponents
        ' Si le composant n'est pas le module actif et est un module standard ou un module de classe, ajoutez-le � la liste des modules � supprimer
        If vbComp.Name <> moduleActif And (vbComp.Type = vbext_ct_StdModule Or vbComp.Type = vbext_ct_ClassModule) Then
            modulesASupprimer.Add vbComp.Name
        End If
    Next vbComp

    ' Parcourez la liste des modules � supprimer et supprimez chaque module
    Dim nomDuModule As Variant
    For Each nomDuModule In modulesASupprimer
        Me.CloseModule (nomDuModule)
    Next nomDuModule
End Sub


' Propri�t� pour obtenir la liste des modules charg�s
Public Property Get modulesLoaded(Optional targetProject As VBIDE.VBProject) As Collection
    Dim vbComp As VBIDE.VBComponent
    Dim modulesCharges As New Collection

    ' Parcourez tous les composants du projet VBA
    For Each vbComp In targetProject.VBComponents
        ' Ajoutez le nom du module � la collection
        modulesCharges.Add vbComp.Name
    Next vbComp

    ' Retournez la collection des modules charg�s
    Set modulesLoaded = modulesCharges
End Property

'Method pour savoir si un module avec un nom sp�cific existe
Private Function ModuleExists(moduleName As String) As Boolean
    Dim modulesCharges As Collection
    Dim i As Integer

    ' Obtenez la liste des modules charg�s
    Set modulesCharges = Me.modulesLoaded

    ' V�rifiez si le module est d�j� charg�
    ModuleExists = False
    For i = 1 To modulesCharges.Count
        If modulesCharges.Item(i) = moduleName Then
            ModuleExists = True
            Exit Function
        End If
    Next i
End Function


Public Sub ScheduleCheckReloadModules()
    Dim wb As Workbook
    Dim vbComp As VBIDE.VBComponent
    Dim nomsDesModules() As Variant
    Dim i As Integer

    ' Parcourez tous les classeurs ouverts
    For Each wb In Application.Workbooks
        i = 0
        ' Parcourez tous les modules du projet VBA du classeur
        For Each vbComp In wb.VBProject.VBComponents
            ' Ignorez certains composants en fonction de leur nom ou de leur type
            If Not (vbComp.Name = "ThisWorkbook" _
                    Or vbComp.Name = "XlmaManager" _
                    Or vbComp.Type = vbext_ct_MSForm _
                    Or vbComp.Type = vbext_ct_Document _
                    Or vbComp.Type = vbext_ct_StdModule) Then
                
                ' Ajoutez le nom du module � la liste
                ReDim Preserve nomsDesModules(i)
                nomsDesModules(i) = vbComp.Name
                i = i + 1
            End If
        Next vbComp

        ' Utilisez la fonction include pour charger tous les modules
        Me.include nomsDesModules, wb.VBProject
    Next wb
End Sub




Public Sub renameAllExceptActiveModules()
    ' R�le :
    ' Cette fonction a pour but de renommer tous les modules dans le projet VBA,
    ' � l'exception de ceux qui sont actuellement actifs (c'est-�-dire en cours d'utilisation).
    '
    ' Probl�me qu'elle tente de r�soudre :
    ' Lors de l'importation d'un module dans un projet VBA, si un module du m�me nom existe d�j�,
    ' Excel renomme automatiquement le module import� en ajoutant un chiffre � la fin du nom.
    ' Cela peut poser probl�me si vous comptez sur le nom du module pour certaines fonctionnalit�s de votre code. Par example instancier Dim a as new FileTool
    '
    ' Solution envisag�e :
    ' Pour �viter ce probl�me, cette fonction renomme tous les modules qui ne sont pas actuellement actifs.
    ' Cela lib�re le nom du module pour �tre utilis� par le module que vous souhaitez importer.
    '
    ' Comment l'appeler :
    ' Dim xlma as XlmaManager
    ' xlma.renameAllExceptActiveModules
    '
    ' O� l'appeler :
    ' Vous devriez appeler cette fonction � un endroit de votre code o� vous �tes s�r qu'aucun des modules que vous ne voulez pas renommer n'est actif.
    ' Cela pourrait �tre au d�but de votre code, ou juste avant une op�ration d'importation de module.
    ' Dans :
    '   Private Sub Workbook_afterSave(ByVal SaveAsUI As Boolean, Cancel As Boolean)
    '       Dim xlma As New XlmaManager
    '       xlma.renameAllExceptActiveModules
    '   End Sub
    '
    ' NOTE : Cette fonction n'a pas encore �t� impl�ment�e. Le code r�el pour renommer les modules doit encore �tre �crit.

End Sub












Public Sub test()
    ' Cette m�thode est actuellement vide
End Sub

