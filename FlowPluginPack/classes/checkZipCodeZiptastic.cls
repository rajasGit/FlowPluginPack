global class checkZipCodeZiptastic {

    public static final String ZURL = 'http://ziptasticapi.com/';
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String COUNTRY = 'country';


    public String theCity {get; private set;}
    public String theState {get; private set;}
    public String theCountry {get; private set;}

    
    public String Status {get; private set;}
    public String ErrorMessage {get; private set;}
    
    public boolean validZip;
    
    global void validateAndGetZiptasticInfo(String zipCode)
    {       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getZURL(zipCode)); 
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if (res.getStatus()=='OK') {
            String JsonResp = res.getBody();
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonResp);
            ErrorMessage = (String) m.get('error');
            if (ErrorMessage==null) {
                Status = 'OK';
                theCountry = (String) m.get(COUNTRY);
                theState = (String) m.get(STATE);
                theCity = (String)m.get(CITY);
            }
            else Status = 'INVALID ZIP';
            
        }
        else {
            Status = 'ERROR';
            ErrorMessage = res.getBody();
        }
            
    }

    public String getZURL(String zipCode) {
        return (ZURL+zipCode);    
    }
        
  
   
}