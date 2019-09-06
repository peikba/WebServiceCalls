codeunit 50103 "BAC Import Customers Rest"
{
    trigger OnRun();
    begin
        Url := 'http://NAVTraining:7048/BC140/ODataV4/WS_Customers';
        HttpClient.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        HttpClient.UseWindowsAuthentication('Admin', '1<3VScode', 'NavTraining');
        //HttpClient.UseDefaultNetworkWindowsAuthentication();
        if not HttpClient.Get(Url, ResponseMessage) then
            Error('The call to the web service failed.');
        if not ResponseMessage.IsSuccessStatusCode then
            error('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
        //ResponseMessage.Headers.Add('content-type', 'Application/Json');
        ResponseMessage.Content.ReadAs(JsonText);
        error(JsonText);
        JsonText := '[' + JsonText + ']';
        if not JsonArray.ReadFrom(JsonText) then
            Error('Invalid response, expected an JSON array as root object');
        foreach jsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject;
            if Currency.findset then
                repeat
                    InsertCurrencyRate(Currency.Code);
                until Currency.Next = 0;
        end;
        page.run(0, CurrencyRate);
    end;


    local procedure InsertCurrencyRate(inCurrencyCode: Code[10]);
    var
        TokenName: Text[50];
        LowerCurrCode: Text[10];

    begin
        CurrencyRate.init;
        LowerCurrCode := LowerCase(inCurrencyCode);
        if not JsonObject.Get(LowerCurrCode, JsonToken) then
            exit;
        TokenName := '$.' + LowerCurrCode + '.code';
        CurrencyRate."Currency Code" := format(SelectJsonToken(JsonObject, TokenName));
        CurrencyRate."Exchange Rate Amount" := 100;
        TokenName := '$.' + LowerCurrCode + '.inverseRate';
        evaluate(InvExchRate, format(SelectJsonToken(JsonObject, TokenName)));
        CurrencyRate."Relational Exch. Rate Amount" := InvExchRate;
        TokenName := '$.' + LowerCurrCode + '.date';
        //CurrencyRate."Starting Date" := ConvertDate(format(SelectJsonToken(JsonObject, TokenName)));
        if CurrencyRate.Insert then;
    end;

    procedure SelectJsonToken(JsonObject: JsonObject; Path: text) JsonToken: JsonToken
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            Error('Could not find a token with path %1', Path);
    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;


    var
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonText: text;
        CurrencyRate: Record "Currency Exchange Rate" temporary;
        Currency: Record Currency;
        InvExchRate: Decimal;

        Url: Text;
}