let
    Source = Folder.Files("C:\Users\alain\Dev\personal\data-projects\dp-projects\static\ks-mpq\data\interim\Order Data"),
    #"Filtered Hidden Files1" = Table.SelectRows(Source, each [Attributes]?[Hidden]? <> true),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File", each #"Transform File"([Content])),
    #"Removed Other Columns1" = Table.SelectColumns(#"Invoke Custom Function1", {"Name", "Transform File"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File", Table.ColumnNames(#"Transform File"(#"Sample File"))),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Table Column1",{{"Name", type text}, {"Order ID", type any}, {"Customer ID", type text}, {"Cookies Shipped", Int64.Type}, {"Revenue", Int64.Type}, {"Cost", type number}, {"Order Date", type date}, {"Ship Date", type date}, {"Order Status", type text}})
in
    #"Changed Type"