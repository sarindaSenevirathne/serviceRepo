import ballerina/log;
import ballerinax/exchangerates;
import ramith/countryprofile;
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
@display {
    label: "rateconvert",
    id: "rateconvert-311bc702-c4cb-4836-abde-a377e04bfe2d"
}
service / on new http:Listener(9090) {
    @display {
        label: "Exchange Rates",
        id: "exchangerates-e54d8d17-1549-4177-9dfd-7b368b4a8896"
    }
    exchangerates:Client exchangeratesEp;

    @display {
        label: "CountryProfile",
        id: "countryprofile-c456774b-e9a3-4f09-968c-ba524293029c"
    }
    countryprofile:Client countryprofileEp;

    function init() returns error? {
        self.exchangeratesEp = check new ();
        self.countryprofileEp = check new (config = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        });
    }

    resource function get convert(decimal amount = 1.0, string target = "AUD", string base = "USD") returns PricingInfo|error {

        log:printInfo("new request:", base = base, target = target, amount = amount);
        countryprofile:Currency getCurrencyCodeResponse = check self.countryprofileEp->getCurrencyCode(code = target);
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check self.exchangeratesEp->getExchangeRateFor(apikey = exchangeRateAPIKey, baseCurrency = base);

        decimal exchangeRate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        decimal convertedAmount = amount * exchangeRate;

        PricingInfo pricingInfo = {
            currencyCode: target,
            displayName: getCurrencyCodeResponse.displayName,
            amount: convertedAmount
        };

        return pricingInfo;
    }
}

type PricingInfo record {
    string currencyCode;
    string displayName;
    decimal amount;
};

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string exchangeRateAPIKey = ?;
