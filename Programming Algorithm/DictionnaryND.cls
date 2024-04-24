VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DictionnaryND"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private nKeys As Collection ' Collection pour stocker les collections de cl�s
Private values As Collection ' Collection pour stocker les valeurs
Private pDimension  As Integer ' Le nombre de dimensions du dictionnaire

' Initialise les collections lors de la cr�ation de l'objet DictionaryND
Private Sub Class_Initialize()
    Set nKeys = New Collection
    Set values = New Collection
End Sub

' D�finit la valeur de la propri�t� Dimension
Public Property Let dimension(n As Integer)
    Dim i As Integer
    ' Si la dimension a d�j� �t� d�finie, l�ve une erreur
    If pDimension <> 0 Then
        Err.Raise 1010, , "Impossible de redimensionner le dictionnaire."
    Else
        If pDimension < 0 Then
            Err.Raise 1011, , "Impossible de cr�er un dictionaire avec une dimension n�gative."
        Else
            pDimension = n
            ' Cr�e une nouvelle collection de cl�s pour chaque dimension
            For i = 1 To pDimension
                nKeys.Add New Collection
            Next i
        End If
    End If
End Property


' Obtient la valeur de la propri�t� Dimension
Public Property Get dimension() As Integer
    dimension = pDimension
End Property

' Ajoute une nouvelle paire cl�-valeur au dictionnaire
' value : La valeur � ajouter
' keys : Un tableau de cl�s � ajouter
' Comportement : Dans le cas ou la cl� est d�j� pr�sente dans le dictionnaire, pour le moment une erreur est lev�, il est possible de "remplacer" la valeur � la place
Public Sub Add(value As Variant, keys() As Variant)
    Dim i As Integer
    Dim j As Integer
    Dim found As Boolean
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        ' Initialise le dictionnaire avec les dimensions de cette premi�re s�
        Me.dimension = UBound(keys) - LBound(keys) + 1
    End If
    ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
    If UBound(keys) - LBound(keys) + 1 <> dimension Then
        Err.Raise 1013, , "Number of keys does not match the number of dimensions."
    Else
        ' V�rifie si les cl�s existent d�j�
        For i = 1 To nKeys(1).count
            found = True
            For j = LBound(keys) To UBound(keys)
                If nKeys(j + 1)(i) <> keys(j) Then
                    found = False
                    Exit For
                End If
            Next j
            If found Then
                Err.Raise 1014, , "Keys " & Join(keys, ", ") & " already exist in the dictionary."
                Exit Sub
            End If
        Next i
        ' Ajoute les cl�s et la valeur si les cl�s n'existent pas d�j�
        For i = LBound(keys) To UBound(keys)
            nKeys(i).Add keys(i)
        Next i
        values.Add value
    End If
End Sub



' V�rifie si une cl� existe dans le dictionnaire
' keys : Un tableau de cl�s � v�rifier
' Retourne : True si la cl� existe, False sinon
Public Function Exists(keys() As Variant) As Boolean
    Dim i As Integer
    Dim j As Integer
    Dim found As Boolean
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        Err.Raise 1012, , "Dimension of the dictionary has not been specified."
    Else
        ' Parcourt les collections de cl�s pour v�rifier l'existence de la cl�
        For i = 1 To nKeys(1).count
            found = True
            For j = LBound(keys) To UBound(keys)
                If nKeys(j)(i) <> keys(j) Then
                    found = False
                    Exit For
                End If
            Next j
            If found Then
                Exists = True
                Exit Function
            End If
        Next i
    End If
    ' Si la cl� n'est pas trouv�e, retourne False
    Exists = False
End Function

' V�rifie si une cl� est dans une collection
' col : La collection � v�rifier
' key : La cl� � v�rifier
' Retourne : True si la cl� est dans la collection, False sinon
Private Function IsInCollection(col As Collection, key As Variant) As Boolean
    Dim obj As Variant
    On Error Resume Next
    Set obj = col(key)
    If Err.Number = 0 Then
        IsInCollection = True
    Else
        IsInCollection = False
    End If
    On Error GoTo 0
End Function


Public Function Remove(keys() As Variant)
    Dim dimension As Collection
    Dim keyInCollection As Variant
    Dim i As Integer
    Dim found As Boolean
    On Error Resume Next
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If Me.dimension = 0 Then
        Err.Raise 1012, , "Dimension of the dictionary has not been specified."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(keys) - LBound(keys) + 1 <> Me.dimension Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else
            ' Parcourt les collections de cl�s pour trouver et supprimer la paire cl�-valeur
            i = 1
            For Each dimension In nKeys
                found = True
                For j = LBound(keys) To UBound(keys)
                    If dimension(j) <> keys(j) Then
                        found = False
                        Exit For
                    End If
                Next j
                If found Then
                    ' Supprime la paire cl�-valeur
                    dimension.Remove i
                    values.Remove i
                    Exit Function
                End If
                i = i + 1
            Next dimension
        End If
        ' Si les cl�s ne sont pas trouv�es, l�ve une erreur
        If Not found Then
            Err.Raise 1012, , "Keys " & Join(keys, ", ") & " not found in the dictionary."
        End If
    End If
    On Error GoTo 0
End Function




' Obtient la valeur associ�e � une paire de cl�s
' keys : Un tableau de cl�s dont la valeur doit �tre obtenue
' Retourne : La valeur associ�e aux cl�s
Public Function item(keys() As Variant) As Variant
    Dim dimension As Collection
    Dim keyInCollection As Variant
    Dim key As Variant
    Dim i As Integer
    Dim j As Integer
    Dim found As Boolean
    On Error Resume Next
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If Me.dimension = 0 Then
        Err.Raise 1012, , "Dimension of the dictionary has not been specified."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(keys) - LBound(keys) + 1 <> Me.dimension Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else
            ' Parcourt les collections de cl�s pour trouver la valeur
            For i = 1 To nKeys(1).count
                found = True
                j = 1
                For Each dimension In nKeys
                    For Each keyInCollection In dimension
                        If keyInCollection = keys(j) Then
                            Exit For
                        End If
                    Next keyInCollection
                    j = j + 1
                Next dimension
                If found Then
                    ' Retourne la valeur
                    item = values(i)
                    Exit Function
                End If
            Next i
        End If
        ' Si les cl�s ne sont pas trouv�es, l�ve une erreur
        If Not found Then
            Err.Raise 1013, , "Keys " & Join(keys, ", ") & " not found in the dictionary."
        End If
    End If
    On Error GoTo 0
End Function




' Obtient toutes les valeurs associ�es � une cl� donn�e
' keys : Un tableau de cl�s dont les valeurs doivent �tre obtenues
' Retourne : Un objet DictionnaryND contenant les valeurs associ�es aux cl�s
Public Function items(keys() As Variant) As DictionnaryND
    Dim i As Integer
    Dim j As Integer
    Dim found As Boolean
    Dim results As New DictionnaryND
    On Error Resume Next
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        Err.Raise 1012, , "Dimension of the dictionary has not been specified."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(keys) - LBound(keys) + 1 <> n Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else
            ' Parcourt les collections de cl�s pour trouver les valeurs
            For i = 1 To nKeys(1).count
                found = True
                For j = LBound(keys) To UBound(keys) - 1
                    If nKeys(j + 1)(i) <> keys(j) Then
                        found = False
                        Exit For
                    End If
                Next j
                If found And nKeys(UBound(keys))(i) = keys(UBound(keys)) Then
                    ' Ajoute la valeur � l'objet DictionnaryND de r�sultats
                    results.Add values(i)
                End If
            Next i
        End If
        ' Si les cl�s ne sont pas trouv�es, l�ve une erreur
        If Not found Then
            Err.Raise 1014, , "Keys " & Join(keys, ", ") & " not found in the dictionary."
        Else
            Set items = results
        End If
    End If
    On Error GoTo 0
End Function

' Cr�e un tableau 2D � partir du dictionnaire
' Retourne : Un tableau 2D o� chaque ligne est une paire cl�-valeur du dictionnaire
Public Function toArray() As Variant
    Dim i As Integer
    Dim j As Integer
    Dim arr() As Variant
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        Err.Raise 1011, , "Dimension of the dictionary has not been specified."
    Else
        ' Redimensionne le tableau pour contenir toutes les paires cl�-valeur
        ReDim arr(1 To nKeys(1).count, 1 To dimension + 1)
        ' Remplit le tableau avec les cl�s et les valeurs
        For i = 1 To nKeys(1).count
            For j = 1 To dimension
                arr(i, j) = nKeys(j)(i)
            Next j
            arr(i, dimension + 1) = values(i)
        Next i
    End If
    ' Retourne le tableau
    toArray = arr
End Function



Sub Test()
    Dim dict As New DictionnaryND
    Dim keys(1 To 2) As Variant
    Dim value As Variant
    Dim i As Integer
    
    ' Initialise le dictionnaire avec 2 dimensions
    dict.dimension = 2
    
    ' Ajoute des paires cl�-valeur au dictionnaire
    For i = 1 To 10
        keys(1) = "Key1_" & i
        keys(2) = "Key2_" & i
        value = "Value_" & i
        dict.Add value, keys
    Next i
    Dim arr() As Variant
    arr = dict.toArray
    
    ' V�rifie l'existence des cl�s et obtient les valeurs
    For i = 1 To 10
        keys(1) = "Key1_" & i
        keys(2) = "Key2_" & i
        If dict.Exists(keys) Then
            Debug.Print "Keys: " & Join(keys, ", ") & ", Value: " & dict.item(keys)
        Else
            Debug.Print "Keys: " & Join(keys, ", ") & " not found in the dictionary."
        End If
    Next i
    
    ' Supprime des paires cl�-valeur du dictionnaire
    For i = 1 To 5
        keys(1) = "Key1_" & i
        keys(2) = "Key2_" & i
        dict.Remove keys
    Next i
    
    ' V�rifie � nouveau l'existence des cl�s et obtient les valeurs
    For i = 1 To 10
        keys(1) = "Key1_" & i
        keys(2) = "Key2_" & i
        If dict.Exists(keys) Then
            Debug.Print "Keys: " & Join(keys, ", ") & ", Value: " & dict.item(keys)
        Else
            Debug.Print "Keys: " & Join(keys, ", ") & " not found in the dictionary."
        End If
    Next i
End Sub
