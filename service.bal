import ballerina/http;
import ballerina/log;

type ApiConfigurations record {|
    string baseUrl;
    string scope;
    string accessTokenUrl;
    string clientId;
    string clientSecret;
|};

configurable ApiConfigurations apiConfigurations = ?;

http:Client httpClient = check new (apiConfigurations.baseUrl, 
    auth = {
        tokenUrl: apiConfigurations.accessTokenUrl,
        clientId: apiConfigurations.clientId,
        clientSecret: apiConfigurations.clientSecret,
        scopes: [apiConfigurations.scope]
    }
);

public listener http:Listener listenerPolice = new (9090);

service /app on listenerPolice {
    resource function get sayHello() returns json|error {
        json|error result = httpClient->get("/services/product-api/1.0.0/products");
        if (result is error) {
            log:printError("============================================Received an error=========================================");

            log:printError(result.message());
             log:printError("============================================Error message ends here=========================================");

            return result;
        }
         log:printInfo("*************************************** success response*********************************************************");
        log:printInfo(result.toString());
         log:printInfo("*************************************** success response ends here*********************************************************");

        return result;

    }
}
