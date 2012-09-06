public class HttpUtils{

    @future(callout=true)
    public static void doPost(String bodyContent){
    
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        
        //req.setEndpoint('http://disqount.herokuapp.com/qrCode');
       req.setEndpoint('http://greenapples.herokuapp.com/qrCode');
       
        req.setBody(bodyContent);
        req.setMethod('POST');
   
           System.debug('>>>>>>>>> POST BODY:'+bodyContent+'<<<<<<<<<<<<');

        HttpResponse res = h.send(req);
        System.debug('>>>>>>>>> RESPONSE:'+res.getBody()+'<<<<<<<<<<<<');
    }

}