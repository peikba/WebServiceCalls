pageextension 50100 "BAC Order Processor RC Ext" extends "Order Processor Role Center"
{

    actions
    {
        addfirst(Processing)
        {
            action("Test SOAP Web Service")
            {
                ApplicationArea = All;
                Image = ImportCodes;
                RunObject = codeunit "BAC Import Customers Soap";
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
            }
            action("Test REST Web Service")
            {
                ApplicationArea = All;
                Image = ImportDatabase;
                RunObject = codeunit "BAC Import Customers Rest";
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
            }
        }
    }

    var
        myInt: Integer;
}