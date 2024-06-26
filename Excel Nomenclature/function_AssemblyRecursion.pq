let
    // Définition de la fonction récursive AssemblyRecursion
    AssemblyRecursion = (inputTable as table, source as table) as table =>
    let
        // Mise en mémoire tampon du tableau d'entrée pour éviter les modifications pendant l'exécution
        result = Table.Buffer(inputTable),
        
        // Définition de la fonction processRow qui traite une ligne du tableau
        processRow = (row as record) as table =>
            let
                // Récupération des valeurs de la ligne actuelle
                depth = row[Depth],
                name = row[Name],
                qty = row[Qty],
                // Vérification de l'existence de la colonne 'BranchQty' et création si nécessaire
                branchQty = row[BranchQty],
                
                // Récupération du tableau correspondant au nom dans le tableau "Backend_AllTableMerge"
                currentTable = try function_FilterMergeTable(name) otherwise null,
                
                // Création d'un tableau avec la ligne actuelle
                currentRowTable = #table({"id", "Name", "Qty", "Depth", "BranchQty", "Status"}, {{row[id], row[Name], row[Qty], row[Depth], row[BranchQty], try row[Status] otherwise "" }}),
                
                // Si le tableau actuel existe et que la profondeur est supérieure à 0, on continue la récursion
                newTable = if currentTable <> null and depth > 0 then
                    let
                        // Ajout de la colonne "Depth" avec la profondeur diminuée de 1
                        addedDepth = Table.AddColumn(currentTable, "Depth", each depth - 1),
                        
                        // Ajout de la colonne "BranchQty" avec la quantité multipliée par la quantité de la ligne actuelle
                        addedQty = Table.AddColumn(addedDepth, "BranchQty", each if Type.Is(Value.Type([Qty]), Text.Type) then try Number.FromText([Qty]) otherwise "#Text" else if [Qty] is number then branchQty*[Qty] else branchQty),
                        
                        // Appel récursif de la fonction avec le nouveau tableau
                        recursionResult = function_AssemblyRecursion(addedQty,source)
                    in
                        // Combinaison du tableau de la ligne actuelle et du résultat de la récursion
                        Table.Combine({currentRowTable, recursionResult})
                else
                    // Si le tableau actuel n'existe pas ou que la profondeur est égale à 0, on retourne le tableau de la ligne actuelle
                    currentRowTable
            in
                // Si le nouveau tableau n'est pas null, on le retourne, sinon on retourne un tableau vide
                if newTable <> null then newTable else #table(type table [id=text, Name=text, Qty=number, Depth=number, BranchQty=number], {})
    in
        // Accumulation des résultats de processRow pour chaque enregistrement du tableau résultat dans un tableau d'état
        List.Accumulate(Table.ToRecords(result), #table(type table [id=text, Name=text, Qty=number, Depth=number, BranchQty=number], {}), (state, current) => Table.Combine({state, processRow(current)}))
in
    // Retour de la fonction AssemblyRecursion
    AssemblyRecursion