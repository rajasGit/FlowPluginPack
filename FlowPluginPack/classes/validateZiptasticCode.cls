global class validateZiptasticCode implements Process.Plugin
{

        // Inputs and Outputs
        String ZipCode;
        String City;
        String State;
        String Country;

        
    global Process.PluginResult invoke(Process.PluginRequest request)
    {
        zipCode = (String)request.inputParameters.get('ZipCode');
 

    // Call ZipCheck Service
        checkZipCodeZiptastic aZipCheck = new checkZipCodeZiptastic();        
        aZipCheck.validateAndGetZiptasticInfo(zipCode);        
        String callStatus = aZipCheck.Status;
   
   // Get Status and set return data     
        Map<String, Object> result = new Map<String, Object>();
        result.put('Status', callStatus);

        if (callStatus=='OK') {
            result.put('City', aZipCheck.theCity);
            result.put('State', aZipCheck.theState);
            result.put('Country', aZipCheck.theCountry);
        }
        else 
            result.put('ErrorMessage', aZipCheck.ErrorMessage);
        
        return new Process.PluginResult(result); 
    }

    global Process.PluginDescribeResult describe()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.description='This plug-in Validates the Zipcode from Ziptastic Web Service';
        result.tag='ZipCode Utils';
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
            new Process.PluginDescribeResult.InputParameter('ZipCode', Process.PluginDescribeResult.ParameterType.STRING, true)
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('City', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('State', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Country', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Status', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ErrorMessage', Process.PluginDescribeResult.ParameterType.STRING)
        };

        return result;
    }
    
    }