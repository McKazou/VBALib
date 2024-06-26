VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Dictionnary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private keys As Collection ' Collection pour stocker les cl�s
Private values As Collection ' Collection pour stocker les valeurs

' Initialise les collections lors de la cr�ation de l'objet Dictionary
Private Sub Class_Initialize()
    Set keys = New Collection
    Set values = New Collection
End Sub

' Ajoute une nouvelle paire cl�-valeur au dictionnaire
' key : La cl� � ajouter
' value : La valeur � ajouter
Public Sub Add(key As Variant, value As Variant)
    On Error Resume Next
    ' V�rifie si la cl� existe d�j�
    If IsInCollection(keys, key) Then
        Err.Raise 1010, , "Key " & key & " already exists in the dictionary."
    Else
        keys.Add key
        values.Add value
    End If
    On Error GoTo 0
End Sub

' V�rifie si une cl� existe dans le dictionnaire
' key : La cl� � v�rifier
' Retourne : True si la cl� existe, False sinon
Public Function Exists(key As Variant) As Boolean
    On Error Resume Next
    Exists = Not IsEmpty(keys(key))
    On Error GoTo 0
End Function

' Supprime une paire cl�-valeur du dictionnaire
' key : La cl� de la paire � supprimer
Public Function Remove(key As Variant)
    Dim i As Long
    Dim found As Boolean
    found = False
    For i = 1 To keys.count
        If keys(i) = key Then
            keys.Remove i
            values.Remove i
            found = True
            Exit Function
        End If
    Next i
    ' Si la cl� n'est pas trouv�e, l�ve une erreur
    If Not found Then
        Err.Raise 1011, , "Key " & key & " not found in the dictionary."
    End If
End Function


' Obtient la valeur associ�e � une cl�
' key : La cl� dont la valeur doit �tre obtenue
' Retourne : La valeur associ�e � la cl�
Public Function item(key As Variant) As Variant
    Dim i As Long
    Dim found As Boolean
    found = False
    For i = 1 To keys.count
        If keys(i) = key Then
            item = values(i)
            found = True
            Exit Function
        End If
    Next i
    ' Si la cl� n'est pas trouv�e, l�ve une erreur
    If Not found Then
        Err.Raise 1012, , "Key " & key & " not found in the dictionary."
    End If
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

