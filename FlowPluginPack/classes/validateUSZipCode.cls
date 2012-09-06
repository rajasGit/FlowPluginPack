global class validateUSZipCode implements Process.Plugin
{

        String ZipCode;
        String City;
        String State;
        String TimeZone;
        String AreaCode;
        
    global Process.PluginResult invoke(Process.PluginRequest request)
    {
        zipCode = (String)request.inputParameters.get('ZipCode');
 

    // Magic here
        checkZipCode aZipCheck = new checkZipCode();        
        aZipCheck.validateAndGetZipInfo(zipCode);        
        String callStatus = aZipCheck.getStatus();
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('Status', callStatus);

        if (callStatus=='OK') {
            result.put('City', aZipCheck.getTheCity());
            result.put('State', aZipCheck.getTheState());
            result.put('TimeZone', aZipCheck.getTheTimeZone());
            result.put('AreaCode', aZipCheck.getTheAreaCode());
          
        }
        else 
            result.put('ErrorMessage', aZipCheck.getErrorMessage());

        
        return new Process.PluginResult(result); 
    }

    global Process.PluginDescribeResult describe()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.description='This plug-in Validates the Zipcode from USZip Web Service';
        result.tag='ZipCode Utils';
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
            new Process.PluginDescribeResult.InputParameter('ZipCode', Process.PluginDescribeResult.ParameterType.STRING, true)
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('City', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('State', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('TimeZone', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('AreaCode', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Status', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ErrorMessage', Process.PluginDescribeResult.ParameterType.STRING)
        };

        return result;
    }
    
    }