codeunit 50100 "BAC Install Web Service"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        WS_Mgt : Codeunit "Web Service Management";
        ObjectType : Option TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber;
    begin
        WS_Mgt.CreateWebService(ObjectType::Page,page::"BAC WS Customers",'WS Customers',true);
    end;
}