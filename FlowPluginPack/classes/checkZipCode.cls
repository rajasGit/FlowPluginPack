global class checkZipCode {

    public static final String ZURL = 'http://www.webservicex.net/uszip.asmx/GetInfoByZIP?USZip=';
    public static final String CITY = 'CITY';
    public static final String STATE = 'STATE';
    public static final String AREA_CODE = 'AREA_CODE';
    public static final String TIME_ZONE = 'TIME_ZONE';

    public String theCity;
    public String theState;
    public String theTimeZone;
    public String theAreaCode;
    
    public String Status;
    public String ErrorMessage;
    
    public boolean validZip;
    
    
    global void validateAndGetZipInfo(String zipCode)
    {       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getZURL(zipCode)); 
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if (res.getStatus()=='OK') {
               XmlStreamReader reader = res.getXmlStreamReader();
               theCity = getCity(reader);
               if (theCity!=null) {
                   theState = getState(reader);
                   theAreaCode = getAreaCode(reader);
                   theTimeZone = getTimeZone(reader);
                   Status = 'OK';
                   ErrorMessage = '';
               }
               else {
                STATUS = 'INVALID ZIP';
                ErrorMessage = zipCode + ' seems to be an invalid zip code. Please check the zip code and try again';
                }
            }
        else {
            Status = 'ERROR';
            ErrorMessage = res.toString();
        }
            
        
    }

    public String getZURL(String zipCode) {
        return (ZURL+zipCode);    
    }
        
    public String getCity(XmlStreamReader reader) {
        String parsedValue;
        while(reader.hasNext()) {
            if ((reader.getEventType() == XmlTag.START_ELEMENT)) {
                if (reader.getLocalName() == CITY) {
                    parsedValue = parseResponse(reader);
                    break;
                }
            }
            reader.next();
        }
        return (parsedValue);
    }

    public String getState(XmlStreamReader reader) {
        String parsedValue;
        while(reader.hasNext()) {
            if ((reader.getEventType() == XmlTag.START_ELEMENT)) {
                if (reader.getLocalName() == STATE) {
                    parsedValue = parseResponse(reader);
                    break;
                }
            }
            reader.next();
        }
        return (parsedValue);
    }
    
    public String getTimeZone(XmlStreamReader reader) {
        String parsedValue;
        while(reader.hasNext()) {
            if ((reader.getEventType() == XmlTag.START_ELEMENT)) {
                if (reader.getLocalName() == TIME_ZONE) {
                    parsedValue = parseResponse(reader);
                    break;
                }
            }
            reader.next();
        }
        return (parsedValue);
    }
    
    public String getAreaCode(XmlStreamReader reader) {
        String parsedValue;
        while(reader.hasNext()) {
            if ((reader.getEventType() == XmlTag.START_ELEMENT)) {
                if (reader.getLocalName() == AREA_CODE) {
                    parsedValue = parseResponse(reader);
                    break;
                }
            }
            reader.next();
        }
        return (parsedValue);
    }
                
    public String getTheCity() {
        return theCity;
    }

    public String getTheState() {
        return theState;
    }
    
        public String getTheTimeZone() {
        return theTimeZone;
    }
    
        public String getTheAreaCode() {
        return theAreaCode;
    }  
    
        public String getStatus() {
        return Status;
    }  
    
        public String getErrorMessage() {
        return ErrorMessage;
    }  
    
      
    public String parseResponse(XmlStreamReader reader) {
        String parsedValue;
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) { 
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) { 
                parsedValue = reader.getText();
            } 
            reader.next();
            
        }
            return parsedValue;
    }
    
    
   /*
    public static testmethod void testAll() {
      
        checkZipCode aZipCheck = new checkZipCode();
        String city;
        
        aZipCheck.validateAndGetZipInfo('94131');
        System.debug('Got City: ' + aZipCheck.getTheCity());
        
        
    } 
    
    */
   
   
   
   
}