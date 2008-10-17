=begin rdoc
  A Ruby interface to VoicePulse's SOAP interface.
=end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'soap/wsdlDriver'
  
class VoicePulse

  # When you create a VoicePulseApi.new class it creates a SOAP::WSDLDriverFactory class called @driver.  It also creates a variable @apikey to store the ApiKey from VoicePulse.
  #
  # Example:
  #    obj = VoicePulseApi.new
  def initialize()
    wsdl = 'http://connect.voicepulse.com/secure/services/Api0605.asmx?WSDL'
    @driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @apikey = API_KEY
  end

  # Requires a single hash in the format:
  #    (:ApiKey => String, :StartYear => Integer, :StartMonth => Integer, :StartDay => Integer, :EndYear => Integer, :EndMonth => Integer, :EndDay => Integer, :Filename => String)
  #
  # Example:
  #    datehash = {:ApiKey => @apikey, :StartYear => 2007, :StartMonth => 03, :StartDay => 01, :EndYear => 2007, :EndMonth => 04, :EndDay => 02, :Filename => "vpreport"}
  #    obj.generateReport(datehash) => "vpreport.zip"
  # Returns the name of the Filename created (will always be a .zip file because of the way VoicePulse processes the report).
  def generateReport(dates)
    result = @driver.GenerateReport(dates)
    if result.generateReport.errorCode == "0" then
      output = result.generateReport.filename
    else
      output = "Error Generating Report: #{result.generateReportResult.errorMessage}"
    end
    return output
  end

  # Requires a filename as a String (the one returned from generateReport).  Returns a https URL to download the file from.
  def getReport(filename)
    result = @driver.GetGeneratedReports(:ApiKey => @apikey)
    if result.getGeneratedReportsResult.errorCode == "0" then
      response = result.getGeneratedReportsResult.items.apiResponseItem
      @reportlist = Hash.new
      response.each do |res|
        @reportlist.update(res.filename => res.fullPath)
      end
      output = @reportlist[filename]
    else
      output = result.getGeneratedReportsResult.errorMessage
    end
    return output
  end

  # Gets the current balance of the account and returns it as a String
  def getBalance
    result = @driver.GetBalance(:ApiKey => @apikey)
    if result.getBalanceResult.errorCode == "0" then
      output = result.getBalanceResult.balance
    else
      output = result.getBalanceResult.errorMessage
    end
    return output
  end

  # Requires a phone number with no formatting as a String and returns a String for the rate per-minute.
  def getRate(phonenumber)
    result = @driver.GetFlexRate(:ApiKey => @apikey, :PhoneNumber => phonenumber)
    if result.getFlexRateResult.errorCode == "0" then
      output = result.getFlexRateResult.flexRate
    else
      output = "Error Getting FlexRate: #{result.getFlexRateResult.errorMessage}"
    end
    return output
  end

  # TODO: Need to test this when account balance gets low
  # Requires a CCV Code (3 digit number from back of Credit Card) and an amount as Strings. Returns success or failure message.
  def refill(ccvcode, amount)
    result = @driver.RefillNow(:ApiKey => @apikey, :CreditCardCode => ccvcode, :Amount => amount)
    return result.refillNowResult.refillNow
  end

  # TODO: activatePhoneNumbers = {:ApiKey => @apikey, :PhoneNumbers => Array, :AccountNumber1 => String, :AccountNumber2 => String}
  def activatePhoneNumbers

  end

  # TODO: deactivatePhoneNumbers = {:ApiKey => @apikey, :PhoneNumbers => Array, :AccountNumber1 => String, :AccountNumber2 => String}
  def deactivatePhoneNumbers

  end

  # TODO: getActivePhoneNumbers = {:ApiKey => @apikey} THE API FOR THIS IS CURRENTLY BROKEN
  # def getActivePhoneNumbers
  #   result = @driver.GetActivePhoneNumbers(:ApiKey => @apikey)
  #   if result.getActivePhoneNumbersResult.errorCode == "0" then
  #     output = result.getActivePhoneNumbersResult.phoneNumber
  #   else
  #     output = result.getActivePhoneNumbersResult.errorMessage
  #   end
  #   return output
  # end

  # Requires input of state as a string (two digit code).  Returns list of available area codes.
  def getAvailablePhoneNumberAreaCodes(state)
    result = @driver.GetAvailablePhoneNumberAreaCodes(:ApiKey => @apikey, :State => state)
    if result.getAvailablePhoneNumberAreaCodesResult.errorCode == "0" then
      response = result.getAvailablePhoneNumberAreaCodesResult.items.apiResponseItem
      @arealist = Array.new
      response.each do |res|
        @arealist += res.areaCode.to_a
      end
      output = @arealist
    else
      output = result.getAvailablePhoneNumberAreaCodesResult.errorMessage
    end
    return output
  end

  # Requires two strings for input ('state', 'areacode') and returns a hash of {'rate center' => 'city'}
  def getAvailablePhoneNumberRateCenters(state, areacode)
    result = @driver.GetAvailablePhoneNumberRateCenters(:ApiKey => @apikey, :State => state, :AreaCode => areacode)
    if result.getAvailablePhoneNumberRateCentersResult.errorCode == "0" then
      response = result.getAvailablePhoneNumberRateCentersResult.items.apiResponseItem
      @reportlist = Hash.new
      response.each do |res|
        @reportlist.update(res.rateCenter => res.city)
      end
      output = @reportlist
    else
      output = result.getAvailablePhoneNumberRateCentersResult.errorMessage
    end
    return output
  end

  # TODO: getAvailablePhoneNumberStates = {:ApiKey => @apikey}
  # Accepts no input and returns an array of available states (two digit codes)
  def getAvailablePhoneNumberStates
    result = @driver.GetAvailablePhoneNumberStates(:ApiKey => @apikey)
    if result.getAvailablePhoneNumberStatesResult.errorCode == "0" then
      response = result.getAvailablePhoneNumberStatesResult.items.apiResponseItem
      @statelist = Array.new
      response.each do |res|
        @statelist += res.state.to_a
      end
      output = @statelist
    else
      output = result.getAvailablePhoneNumberStatesResult.errorMessage
    end
    return output
  end

  # TODO: getAvailablePhoneNumbers = {:ApiKey => @apikey, :State => String, :AreaCode => String, :RateCenter => String}
  # Requires inputs of state, areacode, and ratecenter as strings.  Returns and array of available phone numbers.
  def getAvailablePhoneNumbers(state, areacode, ratecenter)
    result = @driver.GetAvailablePhoneNumbers(:ApiKey => @apikey, :State => state, :AreaCode => areacode, :RateCenter => ratecenter)
    if result.getAvailablePhoneNumbersResult.errorCode == "0" then
      response = result.getAvailablePhoneNumbersResult.items.apiResponseItem
      @numberlist = Array.new
      response.each do |res|
        @numberlist += res.phoneNumber.to_a
      end
      output = @numberlist
    else
      output = result.getAvailablePhoneNumbersResult.errorMessage
    end
    return output
  end

  # TODO: getCredentials = {:ApiKey => @apikey}
  # Accepts no inputs and returns an array of [login, password] for use in your sip.conf or iax2.conf
  def getCredentials
    result = @driver.GetCredentials(:ApiKey => @apikey)
    if result.getCredentialsResult.errorCode == "0" then
      output = [result.getCredentialsResult.items.apiResponseItem.login, result.getCredentialsResult.items.apiResponseItem.password]
    else
      output = "Error Getting FlexRate: #{result.getUserResult.errorMessage}"
    end
    return output
  end

  # Accepts no input and returns and array of [username, email]
  def getUser
    result = @driver.GetUser(:ApiKey => @apikey)
    if result.getUserResult.errorCode == "0" then
      output = [result.getUserResult.items.apiResponseItem.username, result.getUserResult.items.apiResponseItem.email]
    else
      output = "Error Getting FlexRate: #{result.getUserResult.errorMessage}"
    end
    return output
  end

end