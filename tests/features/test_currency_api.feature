@FixerAPIIntegrationTests
Feature: Test Currency Conversion API
  In order to verify currency API works fine
  We want to input *toCurrency*, *fromCurrency* and *amount* to be converted

  @VerifyThatGivenCurrencyBelongsToGivenCountry
  Scenario Outline: To Verify that the valid currency belongs to given country
    When I execute get currency call with "<currency>"
    Then I verify status code as "200"
    And I validate the country with "<currency>" currency as "<country>"

    Examples:
      | currency | country       |
      | INR      | India         |
      | USD      | United States |
      | EUR      | Austria       |

  @VerifyThatGivenInvalidCurrencyReturnsNotFoundResponse
  Scenario: To Verify that the invalid currency should return not found response
    When I execute get currency call with "DUMMY"
    Then I verify status code as "404"
    And I verify response message as "Not Found"

  @VerifyThatGivenCapitalCityBelongsToCountry
  Scenario Outline: To Verify that capital city name belongs to country
    When I execute get capitalcity call with "<capital>"
    Then I verify status code as "200"
    And I validate the country with "<capital>" capital as "<country>"

    Examples:
      | capital   | country |
      | New Delhi | India   |
      | Paris     | France  |
      | Tokyo     | Japan   |

  @VerifyThatGivenTwoCurrenciesAreConvertedAsPerGivenAmountGETRequest
  Scenario Outline: To Verify that given two currencies and amount converts successfully with data from fixer
    Given I have Initialized API Service call for fixer Currency Conversion API
    When I want to convert <amount> <fromCurrency> to <toCurrency>
    Then Verify that the response after conversion is "OK"
    And The response body contain "from" as <fromCurrency>
    And The response body contain "success" as "true"
    And The response body contain "rate" as "Non Null"
    And The response body contain "convertResult" as "Non Null"
    Examples:
      | amount | fromCurrency | toCurrency |
      | 1587   | "USD"        | "PKR"      |
      | 222.56 | "NOK"        | "EUR"      |
      | 100.09 | "DKK"        | "SEK"      |

  @VerifyThatGivenTwoCurrenciesAreConvertedAsPerGivenAmountPOSTRequest
  Scenario Outline: To Verify Given two currencies and amount converts successfully
    Given I have Initialized API Service call for fixer Currency Conversion API
    When I want to convert <amount> <fromCurrency> to <toCurrency>
    Then Verify that the response after conversion is <responseStatus>
    Examples:
      | fromCurrency | toCurrency | amount | responseStatus |
      | "NOK"        | "PKR"      | 10.5   | "OK"           |
      | "DKK"        | "SEK"      | 44.5   | "OK"           |
      | "CCCZ"       | "SEK"      | 20.0   | "BadRequest"   |
      | "NOK"        | "BBCC"     | 22.7   | "BadRequest"   |
      | "NOK"        | "INR"      | 0.0    | "BadRequest"   |

  @VerifyThatCallingCurrencyConversionAPIWithoutAPIKeyThrowsUNAUTHORIZEDErrorCode
  Scenario Outline: To Verify that any request with invalid API key in header will throw 401 UnAuthorized Error respose from server
    Given I have Initialized API Service call for fixer Currency Conversion API Without api key
    When I want to convert <amount> <fromCurrency> to <toCurrency>
    Then Verify that the response after conversion is <responseStatus>

    Examples:
      | fromCurrency | toCurrency | amount | responseStatus |
      | "NOK"        | "INR"      | 2880.0 | "Unauthorized" |