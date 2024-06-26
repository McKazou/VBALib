VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "TableTools"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'Cette Class permet de manipuler facilement les tableaux


' Fonction pour obtenir la plage de cellules d'un tableau
Public Function GetContent(tableName As String, Optional ws As Worksheet) As Range
    Dim lo As ListObject
    
    ' Si ws n'est pas d�fini, utiliser toutes les feuilles de calcul du classeur
    If ws Is Nothing Then
        Dim w As Worksheet
        For Each w In ThisWorkbook.Worksheets
            For Each lo In w.ListObjects
                If lo.Name = tableName Then
                    Set GetContent = lo.Range
                    Exit Function
                End If
            Next lo
        Next w
    Else
        ' Sinon, utiliser uniquement la feuille de calcul sp�cifi�e
        For Each lo In ws.ListObjects
            If lo.Name = tableName Then
                Set GetContent = lo.Range
                Exit Function
            End If
        Next lo
    End If
    
    ' Si aucun tableau n'a �t� trouv�, retourner Nothing
    Set GetContent = Nothing
End Function


' Fonction pour v�rifier si un tableau existe
Public Function TableExists(tableName As String, Optional ws As Worksheet) As Boolean
    Dim lo As ListObject
    
    ' Si ws n'est pas d�fini, utiliser toutes les feuilles de calcul du classeur
    If ws Is Nothing Then
        Dim w As Worksheet
        For Each w In ThisWorkbook.Worksheets
            For Each lo In w.ListObjects
                If lo.Name = tableName Then
                    TableExists = True
                    Exit Function
                End If
            Next lo
        Next w
    Else
        ' Sinon, utiliser uniquement la feuille de calcul sp�cifi�e
        For Each lo In ws.ListObjects
            If lo.Name = tableName Then
                TableExists = True
                Exit Function
            End If
        Next lo
    End If
    
    ' Si le tableau n'est pas trouv�, retourner False
    TableExists = False
End Function

' Fonction pour supprimer un tableau
Public Sub DeleteTable(tableName As String)
    On Error Resume Next
    ThisWorkbook.Worksheets(tableName).ListObjects(1).Delete
End Sub

' Fonction pour cr�er un tableau
Public Sub CreateTable(wsheet As Worksheet, tableName As String, RangeString As String, IncludeHeaders As Boolean)
    Dim rng As Range
    Dim tbl As ListObject

    ' D�finir la plage sur laquelle le tableau sera cr��
    Set rng = wsheet.Range(RangeString)

    ' Cr�er le tableau
    Set tbl = wsheet.ListObjects.Add(xlSrcRange, rng, , IncludeHeaders)

    ' D�finir le nom du tableau
    tbl.Name = tableName
End Sub

Public Function AreTablesIdentical(table1 As Range, table2 As Range) As Boolean
    ' V�rifier si les deux tableaux ont le m�me nombre de lignes et de colonnes
    If table1.Rows.Count <> table2.Rows.Count Or table1.Columns.Count <> table2.Columns.Count Then
        AreTablesIdentical = False
        Exit Function
    End If
    
    ' Calculer le nombre total de cellules � parcourir
    Dim totalCells As Long
    totalCells = table1.Rows.Count * table1.Columns.Count
    
    ' Comparer chaque cellule dans les deux tableaux
    Dim r As Long, c As Long
    Dim currentCell As Long
    For r = 1 To table1.Rows.Count
        For c = 1 To table1.Columns.Count
            ' Mettre � jour le num�ro de cellule actuel
            currentCell = ((r - 1) * table1.Columns.Count) + c
            
            ' Afficher la progression dans la barre d'�tat d'Excel
            Application.StatusBar = "Comparaison des cellules : " & currentCell & " sur " & totalCells
            
            If table1.Cells(r, c).value <> table2.Cells(r, c).value Then
                AreTablesIdentical = False
                ' R�initialiser la barre d'�tat avant de quitter
                Application.StatusBar = False
                Exit Function
            End If
            DoEvents ' Permettre � Excel de traiter d'autres �v�nements
        Next c
    Next r
    
    ' Si toutes les cellules sont identiques, les tableaux sont identiques
    AreTablesIdentical = True
    ' R�initialiser la barre d'�tat � la fin
    Application.StatusBar = False
End Function



' Function to get the name of tha table that intersect with the position of the range
Public Function getTableNameFromRange(rangeToSearch As Range) As String
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim intersectRange As Range
    Set ws = rangeToSearch.Worksheet
        For Each tbl In ws.ListObjects
            ' V�rifier si la plage sp�cifi�e est sur la m�me feuille de calcul que le tableau
            If rangeToSearch.Worksheet.Name = ws.Name Then
                ' V�rifier si la plage sp�cifi�e intersecte enti�rement avec le tableau
                Set intersectRange = Application.Intersect(tbl.Range, rangeToSearch)
                If Not intersectRange Is Nothing Then
                        ' Retourner le nom du tableau
                        getTableNameFromRange = tbl.Name
                        Exit Function
                End If
            End If
        Next tbl

    ' Si aucun tableau n'a �t� trouv�, retourner une cha�ne vide
    getTableNameFromRange = ""
End Function

' Fonction pour renommer un tableau
Public Sub renameTable(oldName As String, newName As String, Optional ws As Worksheet)
    Dim tbl As ListObject

    ' Si ws n'est pas d�fini, utiliser toutes les feuilles de calcul du classeur
    If ws Is Nothing Then
        Dim w As Worksheet
        For Each w In ThisWorkbook.Worksheets
            For Each tbl In w.ListObjects
                If tbl.Name = oldName Then
                    ' Renommer le tableau
                    tbl.Name = newName
                    Exit Sub
                End If
            Next tbl
        Next w
    Else
        ' Sinon, utiliser uniquement la feuille de calcul sp�cifi�e
        For Each tbl In ws.ListObjects
            If tbl.Name = oldName Then
                ' Renommer le tableau
                tbl.Name = newName
                Exit Sub
            End If
        Next tbl
    End If
End Sub



'Get the list of table pr�sent in the workbook
Function getTablesNamesList() As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim TableNames() As String
    Dim i As Integer

    i = 0

    ' Parcourir chaque feuille de calcul et chaque tableau
    For Each ws In ThisWorkbook.Worksheets
        For Each tbl In ws.ListObjects
            ' Ajouter le nom du tableau au tableau
            ReDim Preserve TableNames(i)
            TableNames(i) = tbl.Name
            i = i + 1
        Next tbl
    Next ws

    ' Retourner le tableau de noms de tableaux
    getTablesNamesList = TableNames
End Function

Function getTableNameListIn(sheetName As String) As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim TableNames() As String
    Dim i As Integer

    i = 0

    ' Parcourir chaque feuille de calcul et chaque tableau
    For Each ws In ThisWorkbook.Worksheets
        ' V�rifier si le nom de la feuille de calcul correspond au param�tre
        If ws.Name = sheetName Then
            For Each tbl In ws.ListObjects
                ' Ajouter le nom du tableau au tableau
                ReDim Preserve TableNames(i)
                TableNames(i) = tbl.Name
                i = i + 1
            Next tbl
        End If
    Next ws

    ' Retourner le tableau de noms de tableaux
    getTableNameListIn = TableNames
End Function


' Fonction pour ajouter des donn�es � la fin d'un tableau
Public Sub addAtEnd(tableName As String, rangeToPaste As Range, Optional ws As Worksheet)
    Dim tbl As ListObject
    Dim rng As Range

    ' Si aucune feuille de calcul n'est sp�cifi�e, utilisez la feuille de calcul active
    If ws Is Nothing Then Set ws = ActiveSheet

    ' V�rifiez si le tableau existe
    If Not TableExists(tableName, ws) Then
        MsgBox "Table " & tableName & " does not exist."
        Exit Sub
    End If

    ' Obtenez le tableau et la plage de cellules
    Set tbl = ws.ListObjects(tableName)
    Set rng = tbl.Range
    
    If (rangeToPaste.Columns.Count > rng.Columns.Count) Then
        'Insert as much Column at the right of the table as the difference between the two
        For i = rng.Columns.Count + 1 To rangeToPaste.Columns.Count
            'Insert column at the end of the table
            rng.Cells(1, rng.Columns.Count + 1).EntireColumn.Insert
        Next
    End If
    
    ' Ajoutez les donn�es � la fin du tableau
    Dim rowValues() As Variant
    Dim oneDValues() As Variant
    Dim j As Integer
    For i = 1 To rangeToPaste.Rows.Count
        rowValues = rangeToPaste.Rows(i).value
        ReDim oneDValues(1 To UBound(rowValues, 2))
        For j = 1 To UBound(rowValues, 2)
            oneDValues(j) = rowValues(1, j)
        Next j
        Call addRow(tableName, oneDValues, ws)
    Next i

    ' Check if the header is at its default value
    If tbl.HeaderRowRange.Cells(1, 1).value = "Column1" Then
        ' Replace the headers with the values of the first row
        tbl.HeaderRowRange.value = tbl.ListRows(1).Range.value
        ' Delete the first row
        tbl.ListRows(1).Delete
    End If
End Sub



' Fonction pour ajouter une ligne � un tableau
Public Function addRow(tableName As String, rowValues As Variant, Optional ws As Worksheet)
    ' Si aucune feuille de calcul n'est sp�cifi�e, utilisez la feuille de calcul active
    If ws Is Nothing Then Set ws = ActiveSheet

    ' V�rifiez si le tableau existe
    If Not TableExists(tableName, ws) Then
        Err.Raise "1006", "TableTools", "Table " & tableName & " does not exist."
        Exit Function
    End If

    ' V�rifiez si rowValues est vide ou Nothing
    If IsEmpty(rowValues) Then
        Err.Raise "1008", "TableTools", "No Data to add"
        Exit Function
    End If

    ' Obtenez le tableau
    Dim tbl As ListObject
    Set tbl = ws.ListObjects(tableName)

    ' Ajoutez une nouvelle ligne au tableau avec les valeurs fournies
    Dim newRow As ListRow
    Set newRow = tbl.ListRows.Add
    newRow.Range(1, 1).Resize(, UBound(rowValues) - LBound(rowValues) + 1).value = rowValues
End Function

' Fonction pour ajouter une colonne � un tableau
Public Function addColumn(tableName As String, columnValues As Variant, Optional ws As Worksheet)
    ' Si aucune feuille de calcul n'est sp�cifi�e, utilisez la feuille de calcul active
    If ws Is Nothing Then Set ws = ActiveSheet

    ' V�rifiez si le tableau existe
    If Not TableExists(tableName, ws) Then
        Err.Raise "1006", "TableTools", "Table " & tableName & " does not exist."
        Exit Function
    End If

    ' V�rifiez si columnValues est vide ou Nothing
    If IsEmpty(columnValues) Then
        Err.Raise "1008", "TableTools", "No Data to add"
        Exit Function
    End If

    ' Obtenez le tableau
    Dim tbl As ListObject
    Set tbl = ws.ListObjects(tableName)

    ' Ajoutez une nouvelle colonne au tableau avec les valeurs fournies
    tbl.Range.Resize(, tbl.Range.Columns.Count + 1).value = Application.Transpose(columnValues)
End Function

' Fonction pour v�rifier si une colonne existe dans un tableau
Public Function ColumnExists(tableName As String, columnName As String, Optional ws As Worksheet) As Boolean
    ' Si aucune feuille de calcul n'est sp�cifi�e, utilisez la feuille de calcul active
    If ws Is Nothing Then Set ws = ActiveSheet

    ' V�rifiez si le tableau existe
    If Not TableExists(tableName, ws) Then
        Err.Raise "1006", "TableTools", "Table " & tableName & " does not exist."
        Exit Function
    End If

    ' Obtenez le tableau
    Dim tbl As ListObject
    Set tbl = ws.ListObjects(tableName)

    ' Parcourez chaque colonne du tableau pour v�rifier si la colonne existe
    Dim col As ListColumn
    For Each col In tbl.ListColumns
        If col.Name = columnName Then
            ColumnExists = True
            Exit Function
        End If
    Next col

    ' Si la colonne n'a pas �t� trouv�e, retournez False
    ColumnExists = False
End Function



Public Sub TestTableTools()
    Dim tableName As String
    Dim RangeString As String
    Dim IncludeHeaders As Boolean
    Dim rng As Range
    Dim TableNames() As String
    
    ' D�finir les valeurs de test
    tableName = "MonTableau"
    RangeString = "A1:C10"
    IncludeHeaders = True
    
    ' Tester la fonction CreateTable
    CreateTable tableName, RangeString, IncludeHeaders
    Debug.Assert TableExists(tableName)
    
    ' Tester la fonction GetContent
    Set rng = GetContent(tableName)
    Debug.Assert Not rng Is Nothing
    Debug.Print "Le tableau est dans la plage : " & rng.Address
    
    ' Tester la fonction getTableNameFromRange
    Debug.Assert getTableNameFromRange(rng) = tableName
    
    ' Tester la fonction getTablesNamesList
    TableNames = getTablesNamesList()
    Debug.Assert UBound(TableNames) >= 0
    Debug.Assert IsInArray(tableName, TableNames)
    
    ' Tester la fonction DeleteTable
    DeleteTable tableName
    Debug.Assert Not TableExists(tableName)
End Sub

' Fonction auxiliaire pour v�rifier si une valeur est dans un tableau
Private Function IsInArray(valToBeFound As Variant, arr As Variant) As Boolean
    Dim element As Variant
    On Error GoTo ErrorHandler
    For Each element In arr
        If element = valToBeFound Then
            IsInArray = True
            Exit Function
        End If
    Next element
ErrorHandler:
    On Error GoTo 0
End Function

