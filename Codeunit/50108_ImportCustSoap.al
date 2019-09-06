codeunit 50108 "BAC Import Customers Soap"
{
    trigger OnRun();
    begin
        XMLText := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        XMLText += '  <soap:Body>';
        XMLText += '   <ReadMultiple xmlns="urn:microsoft-dynamics-schemas/page/ws_customers">';
        XMLText += '     <filter>';
        XMLText += '         <Field>No</Field>';
        XMLText += '         <Criteria />';
        XMLText += '     </filter>';
        XMLText += '     <bookmarkKey />';
        XMLText += '     <setSize>0</setSize>';
        XMLText += '   </ReadMultiple>';
        XMLText += '  </soap:Body>';
        XMLText += '</soap:Envelope>';
        Url := 'http://navtraining:7047/BC140/WS/CRONUS%20International%20Ltd./Page/WS_Customers';

        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.Method('POST');
        HttpContent.WriteFrom(XMLtext);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml;charset=utf-8');
        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/page/ws_customers');
        HttpClient.UseWindowsAuthentication('Admin', '1<3VScode', 'NavTraining');
        HttpClient.send(HttpRequestMessage, HttpResponse);
        if not HttpResponse.IsSuccessStatusCode() then
            error(format(HttpResponse.HttpStatusCode()) + ' , ' + HttpResponse.ReasonPhrase())
        else begin
            clear(XMLtext);
            HttpResponse.Content().ReadAs(XMLtext);
            XMLoptions.PreserveWhitespace := true;
            XmlDocument.ReadFrom(xmlText, XMLoptions, XMLDoc);
            //error('%1', XMLDoc);
            if XmlDoc.SelectNodes('//WS_Customers', XmlNodeList) then begin
                foreach XmlNode in XmlNodeList do begin
                    if XmlNode.SelectSingleNode('./No', XmlNode) then
                        TempCust."No." := XmlNode.AsXmlElement.InnerText;

                    if XmlNode.SelectSingleNode('Name', XmlNode) then
                        TempCust.Name := XmlNode.AsXmlElement.InnerText;

                    if XmlNode.SelectSingleNode('City', XmlNode) then
                        TempCust.City := XmlNode.AsXmlElement.InnerText;

                    if XmlNode.SelectSingleNode('Balance_LCY', XmlNode) then begin
                        evaluate(BalanceLCY, XmlNode.AsXmlElement.InnerText);
                        TempCust."Budgeted Amount" := BalanceLCY;
                    end;

                    if (TempCust."No." <> '') and
                    (TempCust.Name <> '') and
                    (TempCust.City <> '') and
                    (TempCust."Budgeted Amount" <> 0) then begin
                        TempCust.Insert;
                        TempCust.init;
                    end;
                end;
            end;
            page.run(0, TempCust);

        end;
    end;

    var
        XMLText: Text;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        Url: Text;
        HttpResponse: HttpResponseMessage;
        XMLoptions: XmlReadOptions;
        XMLDoc: XmlDocument;
        XmlNodeList: XmlNodeList;
        XmlNode: XmlNode;
        TempCust: Record Customer temporary;
        BalanceLCY: Decimal;

}