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
'This whole class is to have a multi dimensionnal Dictionnary
'It could have been done using recursive dictionnary
'It also could have been done by "merging" keys together to get one key
'Bilan => could have avoided all this ...

Private nKeys As Collection ' Collection pour stocker les collections de cl�s
Private pValues As Collection ' Collection pour stocker les valeurs
Private pDimension  As Integer ' Le nombre de dimensions du dictionnaire
Private pCount As Integer

' Initialise les collections lors de la cr�ation de l'objet DictionaryND
Private Sub Class_Initialize()
    Set nKeys = New Collection
    Set pValues = New Collection
End Sub

'Obtient la valeur � l'indice i
'indice :           Indice o� se situe la valeur � retourner
'Retourne :         La valeur � l'indice donn�
Public Property Get values(i As Integer)
    values = pValues(i)
End Property

'Obtient la valeur � l'indice i
'indice :           Indice o� se situe les cl�s � r�cup�r�
'Retourne :         Les cl�s � l'indice donn�
Public Property Get Keys(i As Integer) As Collection
    Dim keysCollection As Collection
    For Each dimension In nKeys
        keysCollection.Add dimension(i)
    Next
    values = keysCollection
End Property

'Obtient le nombre de valeur stock� dans le dictionnaire
'Retourne :         Le nombre de valeurs dans le Dictionnaire � n Dimension
Public Property Get Count() As Integer
    Count = pValues.Count
End Property

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

' Trouve l'indice du premier ensemble de cl�s qui correspond aux cl�s fournies
' keys :            Un tableau de cl�s � rechercher
' Retourne :        L'indice du premier ensemble de cl�s qui correspond aux cl�s fournies. Si aucune cl� n'est trouv�e, retourne -1.
Private Function FindKeys(Keys() As Variant) As Variant
    Dim i As Integer
    Dim j As Integer
    Dim hasAllKey As Boolean
    'Parcours toutes les cl�s
    For i = 1 To nKeys(1).Count
        hasAllKey = True
        'Parcours toutes les dimensions
        For j = 1 To Me.dimension
            'Test si la cl� fourni est vide ou Nothing
            If Keys(j) <> "" Then
                'On calcul si la cl� match parmis les nKeys on obtiens "1" sinon "0".
                'Le produit de ces valeurs permets de faire un "ET" logique et de savoir si toutes les cl�s match
                hasAllKey = (IIf(nKeys(j)(i) = Keys(j), 1, 0)) * hasAllKey
                If hasAllKey = False Then
                    Exit For
                End If
            End If
        Next j
        'Si on a trouv� toutes les cl�s alors on renvoie l'indice
        If hasAllKey Then
            FindKeys = i
            Exit Function
        End If
    Next i
    'Si aucune cl� n'a �t� trouv�e, on renvoie Nothing
    'Err.Raise 1013, , "No Key-Pairs have been found"
    FindKeys = -1
End Function

' Trouve tous les indices des ensembles de cl�s qui correspondent aux cl�s fournies
' keys :            Un tableau de cl�s � rechercher
' Retourne :        Une collection contenant tous les indices des ensembles de cl�s qui correspondent aux cl�s fournies.
'                   Si aucune cl� n'est trouv�e, retourne une collection vide.
Private Function FindAllKeys(Keys() As Variant) As Collection
    Dim i As Integer
    Dim j As Integer
    Dim hasKey As Boolean
    Dim indices As New Collection
    'Parcours toutes les cl�s
    For i = 1 To nKeys(1).Count
        hasKey = True
        'Parcours toutes les dimensions
        For j = 1 To Me.dimension
            'Test si la cl� fourni est vide ou Nothing
            If Keys(j) <> "" Then
                'On calcul si la cl� match parmis les nKeys on obtiens "1" sinon "0".
                'Le produit de ces valeurs permets de faire un "ET" logique et de savoir si toutes les cl�s match
                hasKey = (IIf(nKeys(j)(i) = Keys(j), 1, 0)) * hasKey
                If hasKey = False Then
                    Exit For
                End If
            End If
        Next j
        'Si on a trouv� toutes les cl�s alors on ajoute l'indice � la collection
        If hasKey Then
            indices.Add i
        End If
    Next i
    'Retourne la collection d'indices
    Set FindAllKeys = indices
End Function



' Ajoute une nouvelle paire cl�-valeur au dictionnaire
' value :           La valeur � ajouter
' keys :            Un tableau de cl�s � ajouter
' Comportement :    Dans le cas ou la cl� est d�j� pr�sente dans le dictionnaire, pour le moment une erreur est lev�, il est possible de "remplacer" la valeur � la place
Public Sub Add(value As Variant, Keys() As Variant)
    Dim i, j, k As Integer
    Dim hasAllKey As Boolean
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        ' Initialise le dictionnaire avec les dimensions de cette premi�re s�
        Me.dimension = UBound(Keys) - LBound(Keys) + 1
    End If
    ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
    If UBound(Keys) - LBound(Keys) + 1 <> dimension Then
        Err.Raise 1013, , "Number of keys does not match the number of dimensions."
    Else
        ' V�rifie si les cl�s existent d�j�
        i = FindKeys(Keys)
        
        'Si on a trouv� toutes les cl�s alors on lance une erreur
        If i <> -1 Then
            ' Si les cl�s existent d�j�, on remplace la valeur associ�e
            Err.Raise 1014, , "Keys " & Join(Keys, ", ") & " already exist in the dictionary."
            Exit Sub
        Else
            ' Ajoute les cl�s et la valeur si les cl�s n'existent pas d�j�
            For k = 1 To Me.dimension
                nKeys(k).Add Keys(k)
            Next k
            pValues.Add value
        End If
    End If
End Sub


Public Function Exists(Keys() As Variant) As Boolean
    Dim i As Variant
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        Err.Raise 1012, , "Dictionary has not been initialize."
    Else
        ' Utilise la fonction FindKeys pour v�rifier l'existence de la cl�
        i = FindKeys(Keys)
        If i <> -1 Then
            ' Si les cl�s existent d�j�, retourne True
            Exists = True
            Exit Function
        End If
    End If
    ' Si la cl� n'est pas trouv�e, retourne False
    Exists = False
End Function


' V�rifie si une cl� est dans une collection
' col :             La collection � v�rifier
' key :             La cl� � v�rifier
' Retourne :        True si la cl� est dans la collection, False sinon
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

' Compare deux dictionnaires pour v�rifier s'ils sont identiques
' dict1, dict2 : Les deux dictionnaires � comparer
' Retourne : True si les dictionnaires sont identiques, False sinon
Public Function equal(dict2 As DictionnaryND) As Boolean
    Dim i As Integer
    Dim Keys() As Variant

    ' V�rifie si les deux dictionnaires ont la m�me dimension
    If Me.dimension <> dict2.dimension Then
        equal = False
        Exit Function
    End If

    ' V�rifie si les deux dictionnaires ont le m�me nombre de cl�s
    If Me.Count <> dict2.Count Then
        equal = False
        Exit Function
    End If

    ' Parcourt toutes les cl�s du premier dictionnaire
    For i = 1 To Me.Count
        If Not Me.values(i) = dict2.values(i) Then
            equal = False
            Exit Function
        End If
    Next i

    ' Si toutes les cl�s et valeurs sont les m�mes, les dictionnaires sont identiques
    equal = True
End Function


' Supprime une paire cl?-valeur du dictionnaire
' keys :            Un tableau de cl?s de la paire ? supprimer
Public Function Remove(Keys() As Variant)
    Dim i As Variant
    Dim Dimen As Collection
    On Error Resume Next
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If Me.dimension = 0 Then
        Err.Raise 1012, , "Dictionary has not been initialize."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(Keys) - LBound(Keys) + 1 <> Me.dimension Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else
            ' Utilise la fonction FindKeys pour trouver l'indice des cl�s
            i = FindKeys(Keys)
            If i <> -1 Then
                ' Si les cl�s existent d�j�, on les supprime
                pValues.Remove (i)
                For Each Dimen In nKeys
                    Dimen.Remove (i)
                Next
                Exit Function
            End If
        End If
        ' Si les cl�s ne sont pas trouv�es, l�ve une erreur
        Err.Raise 1013, , "Keys " & Join(Keys, ", ") & " not found in the dictionary."
    End If
    On Error GoTo 0
End Function




' Obtient la valeur associ�e � une paire de cl�s
' keys :            Un tableau de cl�s dont la valeur doit �tre obtenue
' Retourne :        La valeur associ�e aux cl�s
Public Function item(Keys() As Variant) As Variant
    Dim i As Variant
    On Error Resume Next
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If Me.dimension = 0 Then
        Err.Raise 1012, , "Dictionary has not been initialize."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(Keys) - LBound(Keys) + 1 <> Me.dimension Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else
            ' Utilise la fonction FindKeys pour trouver l'indice des cl�s
            i = FindKeys(Keys)
            If i <> -1 Then
                ' Si les cl�s existent d�j�, on retourne la valeur
                item = pValues(i)
                Exit Function
            End If
        End If
        ' Si les cl�s ne sont pas trouv�es, l�ve une erreur
        Err.Raise 1013, , "Keys " & Join(Keys, ", ") & " not found in the dictionary."
    End If
    On Error GoTo 0
End Function


' Obtient toutes les valeurs associ�es � une cl� donn�e
' keys :            Un tableau de cl�s dont les valeurs doivent �tre obtenues
' keepKey :         Un param�tre optionnel pour d�terminer si la cl� doit �tre conserv�e dans le nouveau dictionnaire
' Retourne :        Un objet DictionnaryND contenant les valeurs associ�es aux cl�s
Public Function items(Keys() As Variant, Optional keepKey As Boolean = False) As DictionnaryND
    Dim i As Variant
    Dim j, k As Integer
    Dim newKeys() As Variant
    Dim newDict As New DictionnaryND
    Dim indices As Collection
    
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If Me.dimension = 0 Then
        Err.Raise 1012, , "Dictionary has not been initialize."
    Else
        ' V�rifie si le nombre de cl�s correspond au nombre de dimensions
        If UBound(Keys) - LBound(Keys) + 1 <> Me.dimension Then
            Err.Raise 1013, , "Number of keys does not match the number of dimensions."
        Else

            ' Utilise la fonction FindAllKeys pour trouver tous les indices des cl�s
            Set indices = FindAllKeys(Keys)
            ' Parcourt tous les indices trouv�s
            For Each i In indices
                k = 1
                ' Cr�e un nouveau tableau de cl�s pour le nouveau dictionnaire
                If keepKey Then
                     ReDim newKeys(1 To Me.dimension)
                Else
                    ReDim newKeys(1 To Me.dimension - 1)
                End If
                
                For j = 1 To Me.dimension
                    If Keys(j) = "" Then
                        newKeys(k) = nKeys(j)(i)
                        k = k + 1
                    Else
                        If keepKey Then
                            newKeys(k) = nKeys(j)(i)
                            k = k + 1
                        Else
                            'skip this one
                        End If
                    End If
                Next j
                ' Ajoute la valeur au nouveau dictionnaire
                newDict.Add pValues(i), newKeys
            Next i
        End If
    End If
    ' Retourne le nouveau dictionnaire
    Set items = newDict
End Function






' Cr�e un tableau 2D � partir du dictionnaire
' Retourne :        Un tableau 2D o� chaque ligne est une paire cl�-valeur du dictionnaire
Public Function toArray() As Variant
    Dim i As Integer
    Dim j As Integer
    Dim arr() As Variant
    ' V�rifie si la dimension du dictionnaire a �t� sp�cifi�e
    If dimension = 0 Then
        Err.Raise 1011, , "Dimension of the dictionary has not been specified."
    Else
        ' Redimensionne le tableau pour contenir toutes les paires cl�-valeur
        ReDim arr(1 To nKeys(1).Count, 1 To dimension + 1)
        ' Remplit le tableau avec les cl�s et les valeurs
        For i = 1 To nKeys(1).Count
            For j = 1 To dimension
                arr(i, j) = nKeys(j)(i)
            Next j
            arr(i, dimension + 1) = pValues(i)
        Next i
    End If
    ' Retourne le tableau
    toArray = arr
End Function

' Initialise le dictionnaire � partir d'un tableau 2D
' arr :         Un tableau 2D o� chaque ligne est une paire cl�-valeur
Public Function FromArray(arr() As Variant)
    Dim i As Integer
    Dim j As Integer
    Dim newKeys As Collection
    ' V�rifie si la dimension du tableau a �t� sp�cifi�e
    If UBound(arr, 2) = 0 Then
        Err.Raise 1011, , "Dimension of the array has not been specified."
    Else
        ' Redimensionne le dictionnaire pour contenir toutes les paires cl�-valeur
        Me.dimension = UBound(arr, 2) - 1

        Set pValues = New Collection
        ' Remplit le dictionnaire avec les cl�s et les valeurs
        For i = LBound(arr, 1) To UBound(arr, 1)
            For j = LBound(arr, 2) To UBound(arr, 2) - 1
                nKeys(j).Add arr(i, j)
            Next j
            pValues.Add arr(i, UBound(arr, 2))
        Next i
    End If
End Function


Sub Test()
    Dim dict As New DictionnaryND
    Dim dictFromArray As New DictionnaryND
    Dim Keys(1 To 2) As Variant
    Dim value As Variant
    Dim i, j As Integer
    
    ' Initialise le dictionnaire avec 2 dimensions
    dict.dimension = 2
    
    ' Ajoute des paires cl�-valeur au dictionnaire
    For i = 1 To 3
        For j = 1 To 3
            Keys(1) = "Key1_" & i
            Keys(2) = "Key2_" & j
            value = "Value_" & i & j
            dict.Add value, Keys
        Next j
    Next i
    
    
    
    '-------------------------------------------
    'V�rification getting a specific value : Valid function 'item'
    '-------------------------------------------
    Dim result As String
    result = dict.item(Keys)
    If Not result = value Then
        Debug.Print "ERROR - Got the item :" & result & " for the keys {" & Keys(1) & "," & Keys(2) & "} should have gotten " & value
    Else
        Debug.Print "VALID - Got the item :" & result & " for the keys {Key1_10, Key2_10} - VALID"
    End If
    
    
    
    '-------------------------------------------
    'V�rification a value has been removed : Valid function 'Exists' & 'Remove'
    '-------------------------------------------
    
    ' Supprime des paires cl�-valeur du dictionnaire
    Keys(1) = "Key1_" & 1
    Keys(2) = "Key2_" & 1
    dict.Remove Keys
    
    If dict.Exists(Keys) Then
        Debug.Print "ERROR - The item has not been removed correctly from the dictionnary - ERROR"
    Else
        Debug.Print "VALID - The item has been removed correctly from the dictionnary - VALID"
    End If
    
    
    
    
    '-------------------------------------------
    'V�rification que dict et dictFromArray sont identiques : Valid function 'equal', 'toArray' & 'FromArray'
    '-------------------------------------------
    'Initialisation des tableaux de sorti
    Dim arr() As Variant
    Dim arr2() As Variant
    Dim arr3() As Variant
    
    arr = dict.toArray 'Convert to array
    
    dictFromArray.FromArray arr 'Create from Array

    arr2 = dictFromArray.toArray
    
    If Not dict.equal(dictFromArray) Then
        Debug.Print "ERROR - Array are not identical - ERROR"
    Else
        Debug.Print "VALID - Array are identical - VALID"
    End If
    
    

    
    
    '-------------------------------------------
    'Verification we did get a slice of the dictionnary : Valid function 'items'
    '-------------------------------------------
    Dim slice As DictionnaryND
    Keys(1) = "Key1_1"
    Keys(2) = ""
    Set slice = dictFromArray.items(Keys) ' doesn't return the dict
    arr3 = slice.toArray
    
    MsgBox "End of test"
    
End Sub

