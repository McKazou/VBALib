VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SuperTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Classe TableTool
Private pWorkbook As Workbook ' Classeur contenant le tableau
Private pWorksheet As Worksheet ' Feuille de calcul contenant le tableau
Private pRange() As Variant ' Emplacement du tableau
Private pHeaders As Collection ' Liste des en-t�tes
Private pmasterKeyColumn As Collection ' Valeurs de la premi�re colonne
Private coreRange() As Variant ' "C�ur" du tableau
Private masterKeyNames As Variant ' Noms possibles pour la MasterKeyColumn

' Initialisation de la classe
Private Sub Class_Initialize()
    Set pHeaders = New Collection
    Set masterKeyColumn = New Collection
    masterKeyNames = Array("iD", "Input_Name", "Name", "Path", "FolderPath", "Parameter Type")
End Sub


' Fonction pour rechercher une valeur dans le tableau
Public Function search(valueToSearch As Variant, inArray As String) As TableTool
    Dim i As Long
    Dim j As Long
    Dim searchTable As New TableTool
    Dim found As Boolean

    ' Rechercher inArray dans les en-t�tes
    For i = 1 To pHeaders.Count
        If pHeaders(i) = inArray Then
            ' Si inArray est trouv�, rechercher valueToSearch dans la colonne correspondante
            For j = 1 To masterKeyColumn.Count
                If pRange(j + 1, i).value = valueToSearch Then
                    ' Si valueToSearch est trouv�, ajouter la ligne enti�re � searchTable
                    'searchTable.Range = pRange(j + 1)
                    'searchTable.Headers (pHeaders)
                    'searchTable.masterKeyColumn.Add masterKeyColumn(j)
                    found = True
                    Exit For
                End If
            Next j
        End If
        If found Then Exit For
    Next i

    ' Si inArray n'est pas trouv� dans les en-t�tes, rechercher dans la MasterKeyColumn
    If Not found Then
        For i = 1 To masterKeyColumn.Count
            If masterKeyColumn(i) = inArray Then
                ' Si inArray est trouv�, rechercher valueToSearch dans la ligne correspondante
                For j = 1 To pHeaders.Count
                    If pRange(i + 1, j).value = valueToSearch Then
                        ' Si valueToSearch est trouv�, ajouter la colonne enti�re � searchTable
                        'searchTable.Range = pRange(j)
                        'searchTable.Headers.Add pHeaders(j)
                        'searchTable.masterKeyColumn = masterKeyColumn
                        found = True
                        Exit For
                    End If
                Next j
            End If
            If found Then Exit For
        Next i
    End If

    ' Si inArray n'est pas trouv� ni dans les en-t�tes ni dans la MasterKeyColumn, lever une erreur
    If Not found Then
        Err.Raise 1016, , "La valeur " & inArray & " n'a pas �t� trouv�e dans le tableau."
    End If

    ' Retourner le nouvel objet TableTool
    Set search = searchTable
End Function


' Fonction pour obtenir un tableau � partir de son nom
Public Function fromName(tableName As String, Optional Workbook As Workbook = Nothing, Optional sheet As Worksheet = Nothing)
    Dim ws As Worksheet
    Dim tbl As ListObject

    ' Si aucun classeur n'est sp�cifi�, utiliser le classeur actif
    If Workbook Is Nothing Then
        Set pWorkbook = ThisWorkbook
    Else
        Set pWorkbook = Workbook
    End If

    ' Si aucune feuille de calcul n'est sp�cifi�e, utiliser toutes les feuilles de calcul du classeur
    If sheet Is Nothing Then
        ' Parcourir tous les tableaux de toutes les feuilles de calcul
        For Each ws In pWorkbook.Worksheets
            For Each tbl In ws.ListObjects
                ' Si le nom du tableau correspond � tableName
                If tbl.Name = tableName Then
                    ' Mettre � jour les propri�t�s de l'objet
                    Set pWorksheet = ws
                    pRange = tbl.Range.value
                    updateTable tbl
                    Exit Function
                End If
            Next tbl
        Next ws
    Else
        ' Parcourir tous les tableaux de la feuille de calcul sp�cifi�e
        Set pWorksheet = sheet
        For Each tbl In pWorksheet.ListObjects
            ' Si le nom du tableau correspond � tableName
            If tbl.Name = tableName Then
                ' Mettre � jour les propri�t�s de l'objet
                pRange = tbl.Range.value
                updateTable tbl
                Exit Function
            End If
        Next tbl
    End If

    ' Si aucun tableau correspondant n'est trouv�, lever une erreur
    Err.Raise 1012, , "Table " & tableName & " not found in the workbook."
End Function


'' Fonction pour mettre � jour les propri�t�s de l'objet
Private Sub updateTable(tbl As ListObject)
    Dim i As Long
    Dim j As Long
    Dim hdr As Range
    Dim masterKeyIndex As Variant
    Dim masterKeyCount As Integer

    ' Mettre � jour les en-t�tes
    For Each hdr In tbl.HeaderRowRange
        pHeaders.Add hdr.value
    Next hdr

    ' Identifier la MasterKeyColumn
    masterKeyCount = 0
    For i = 1 To pHeaders.Count
        For j = LBound(masterKeyNames) To UBound(masterKeyNames)
            If pHeaders(i) = masterKeyNames(j) Then
                masterKeyIndex = i
                masterKeyCount = masterKeyCount + 1
            End If
        Next j
    Next i

    ' Si aucun nom de MasterKeyColumn n'est trouv�, utiliser la premi�re colonne par d�faut
    If masterKeyCount = 0 Then
        MsgBox "Aucun nom dans la liste des noms autoris�s n'a �t� trouv� pour le tableau " & tbl.Name & ". La premi�re colonne sera utilis�e par d�faut."
        Application.StatusBar = "[TableTool]{updateTable} Aucun nom dans la liste des noms autoris�s n'a �t� trouv� pour le tableau " & tbl.Name & ". La premi�re colonne sera utilis�e par d�faut."
        masterKeyIndex = 1
    ' Si plusieurs noms de MasterKeyColumn sont trouv�s, lever une erreur
    ElseIf masterKeyCount > 1 Then
        Err.Raise 1014, , "Plusieurs noms de MasterKeyColumn ont �t� trouv�s dans les en-t�tes."
    End If

    ' Mettre � jour les valeurs de la MasterKeyColumn
    For i = 1 To tbl.ListRows.Count
        masterKeyColumn.Add tbl.DataBodyRange(i, masterKeyIndex).value
    Next i

    ' Mettre � jour le "c�ur" du tableau
    coreRange = tbl.Range.Offset(1, masterKeyIndex).Resize(tbl.Range.Rows.Count - 1, tbl.Range.Columns.Count - masterKeyIndex).value
End Sub


' Fonction pour remplacer les valeurs dans certaines colonnes et/ou lignes du tableau
Public Sub replaceValues(newValues As Variant, columnNames As Variant, rowValues As Variant)
    Dim i As Long
    Dim j As Long
    Dim colIndex As Variant
    Dim rowIndex As Variant
    Dim replaceCount As Integer

    ' Initialiser le compteur de remplacements
    replaceCount = 0

    ' Compter le nombre de remplacements qui seraient effectu�s
    For i = 1 To pHeaders.Count
        If IsEmpty(columnNames) Or IsInArray(pHeaders(i), columnNames) Then
            For j = 1 To masterKeyColumn.Count
                If IsEmpty(rowValues) Or IsInArray(masterKeyColumn(j), rowValues) Then
                    replaceCount = replaceCount + 1
                End If
            Next j
        End If
    Next i

    ' V�rifier si la taille de newValues correspond au nombre de remplacements qui seraient effectu�s
    If replaceCount <> UBound(newValues) - LBound(newValues) + 1 Then
        Err.Raise 1015, , "La taille de newValues ne correspond pas � la taille de l'intersection sp�cifi�e."
    End If

    ' R�initialiser le compteur de remplacements
    replaceCount = 0

    ' Parcourir toutes les colonnes du tableau
    For i = 1 To pHeaders.Count
        ' Si aucune colonne n'est sp�cifi�e, ou si le nom de la colonne actuelle est dans columnNames
        If IsEmpty(columnNames) Or IsInArray(pHeaders(i), columnNames) Then
            colIndex = i
            ' Parcourir toutes les lignes du tableau
            For j = 1 To masterKeyColumn.Count
                ' Si aucune ligne n'est sp�cifi�e, ou si la valeur de la ligne actuelle est dans rowValues
                If IsEmpty(rowValues) Or IsInArray(masterKeyColumn(j), rowValues) Then
                    rowIndex = j
                    ' Remplacer la valeur � l'intersection de la colonne et de la ligne par newValues
                    pRange(rowIndex + 1, colIndex) = newValues(replaceCount + 1)
                    replaceCount = replaceCount + 1
                End If
            Next j
        End If
    Next i
End Sub



' Fonction pour extraire certaines lignes et/ou colonnes du tableau
Public Function extract(columnNames As Variant, Optional rowValues As Variant, Optional withHeader As Boolean = False, Optional includeMasterKey As Boolean = False) As TableTool
    Dim i As Long
    Dim j As Long
    Dim k As Long
    Dim colIndex As Variant
    Dim rowIndex As Variant
    Dim extractTable As New TableTool

    ' Parcourir toutes les colonnes du tableau
    For i = 1 To pHeaders.Count
        ' Si aucune colonne n'est sp�cifi�e, ou si le nom de la colonne actuelle est dans columnNames
        If IsEmpty(columnNames) Or IsInArray(pHeaders(i), columnNames) Then
            colIndex = i
            ' Parcourir toutes les lignes du tableau
            For j = 1 To masterKeyColumn.Count
                ' Si aucune ligne n'est sp�cifi�e, ou si la valeur de la ligne actuelle est dans rowValues
                If IsEmpty(rowValues) Or IsInArray(masterKeyColumn(j), rowValues) Then
                    rowIndex = j
                    ' Ajouter la valeur � l'intersection de la colonne et de la ligne au nouvel objet TableTool
                    extractTable.Range(rowIndex + 1, colIndex) = pRange(rowIndex + 1, colIndex)
                End If
            Next j
            ' Ajouter l'en-t�te de la colonne au nouvel objet TableTool, si withHeader est True
            If withHeader Then
                extractTable.Headers.Add pHeaders(i)
            End If
        End If
    Next i

    ' Ajouter les valeurs de la MasterKeyColumn au nouvel objet TableTool, si includeMasterKey est True
    If includeMasterKey Then
        For i = 1 To masterKeyColumn.Count
            extractTable.masterKeyColumn.Add masterKeyColumn(i)
        Next i
    End If

    ' Retourner le nouvel objet TableTool
    Set extract = extractTable
End Function

' Fonction pour v�rifier si une valeur est dans un tableau
Private Function IsInArray(value As Variant, arr As Variant) As Boolean
    Dim i As Long
    For i = LBound(arr) To UBound(arr)
        If arr(i) = value Then
            IsInArray = True
            Exit Function
        End If
    Next i
    IsInArray = False
End Function


' Propri�t� pour obtenir ou d�finir l'emplacement du tableau
Public Property Get Range() As Variant
    Range = pRange
End Property
Public Property Set Range(value As Range)
    pRange = value.value
End Property

' Propri�t� pour obtenir ou d�finir les en-t�tes
Public Property Get Headers() As Collection
    Set Headers = pHeaders
End Property
Public Property Set Headers(value As Collection)
    Set pHeaders = value
End Property

' Propri�t� pour obtenir ou d�finir les valeurs de la premi�re colonne
Public Property Get masterKeyColumn() As Collection
    Set masterKeyColumn = pmasterKeyColumn
End Property
Public Property Set masterKeyColumn(value As Collection)
    Set pmasterKeyColumn = value
End Property
