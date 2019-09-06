codeunit 50109 "BAC License Handling"
//BAC1.00 PBA 01-01-2019 Check Linense 
{
    trigger OnRun()
    var
        IdentityMgt: Codeunit "Identity Management";
        ExpiryDate: Date;
        AppVersion: Text;
    begin
        HttpRequestLicenseCheck('64610644B4734EAB90B75047C0A997', 'peik@b-a.dk', ExpiryDate, AppVersion);
        Error('Test %1\%2', ExpiryDate, AppVersion);
    end;

    Procedure ValidateLicenseNo(inLicenseNo: Text[100]; inLicenseEmail: text[100]; VAR outExpiryDate: Date; VAR outVersion: Text[100])
    begin
        HttpRequestLicenseCheck(inLicenseNo, inLicenseEmail, outExpiryDate, outVersion);
    end;

    local procedure HttpRequestLicenseCheck(inLicenseNo: Text[100]; inLicenseMail: Text[100]; var outExpiryDate: date; var outVersion: Text[100])
    var
        TempBlob: Record TempBlob temporary;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        XMLoptions: XmlReadOptions;
        XMLDoc: XmlDocument;
        XML_text: text;
        URL: Text;
        UserName: Text;
        Password: Text;
        AuthTxt: Text;
        ErrorMessage: Text;

    begin
        URL := 'http://ba-consult.dk:7047/Privat_NavUser/WS/Bech-Andersen%20Consult%20ApS/Codeunit/WSFunc';
        Username := 'Webservice';
        Password := 'Webservice123';
        XML_text := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> ' +
                    '  <soap:Body> ' +
                    '    <ValidateAppLicense xmlns="urn:microsoft-dynamics-schemas/codeunit/WSFunc"> ' +
                    '      <inLicenseNo>' + inLicenseNo + '</inLicenseNo> ' +
                    '      <inLicenseMail>' + inLicenseMail + '</inLicenseMail> ' +
                    '      <inAppName>ManPlus</inAppName> ' +
                    '      <outExpiryDate>2016-01-01</outExpiryDate> ' +
                    '      <outVMVersion /> ' +
                    '      <outErrorMessage /> ' +
                    '    </ValidateAppLicense> ' +
                    '  </soap:Body> ' +
                    '</soap:Envelope> ';

        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(XML_text);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/xml;charset=utf-8');
        RequestMessage.Content := Content;
        RequestMessage.GetHeaders(Headers);
        if UserName <> '' then begin
            AuthTxt := strsubstno('%1:%2', UserName, Password);
            TempBlob.WriteAsText(AuthTxt, TextEncoding::Windows);
            Headers.Add('Authorization', StrSubstNo('Basic %1', TempBlob.ToBase64String()));
        end;
        Headers.Add('SoapAction', 'ValidateAppLicense');
        Client.send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode() then
            error(format(ResponseMessage.HttpStatusCode()) + ' , ' + ResponseMessage.ReasonPhrase())
        else begin
            clear(XML_text);
            ResponseMessage.Content().ReadAs(XML_text);
            XMLoptions.PreserveWhitespace := true;
            XmlDocument.ReadFrom(XML_text, XMLoptions, XMLDoc);
            Evaluate(outExpiryDate, format(FindTagValue(Xml_Text, 'outExpiryDate')), 9);
            outVersion := copystr(FindTagValue(XML_text, 'outVMVersion'), 1, MaxStrLen(outVersion));
            ErrorMessage := FindTagValue(XML_text, 'outErrorMessage');
            if ErrorMessage <> '' then
                error(ErrorMessage);
        end;
    end;


    local procedure FindTagValue(inXMLBody: Text; inTagName: Text): Text
    var
        endTagName: Text;
        FoundPos: Integer;
        ValueLen: Integer;

    begin
        inTagName := DELCHR(inTagName, '<', '<');
        inTagName := DELCHR(inTagName, '>', '>');
        endTagName := '</' + inTagName + '>';
        inTagName := '<' + inTagName + '>';
        FoundPos := STRPOS(inXMLBody, inTagName) + STRLEN(inTagName);
        ValueLen := STRPOS(COPYSTR(inXMLBody, FoundPos + 1), endTagName);
        if ValueLen = 0 then
            exit('')
        else
            exit(COPYSTR(inXMLBody, FoundPos, ValueLen));
    end;
}
