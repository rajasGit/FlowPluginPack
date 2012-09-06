/*
 * Tests
 */
 

/*
 * This is the basic test
 */
 
 public with sharing class testSendEmailFlowPlugin { 
 
 
     public static final String SUBJECT = 'Subject of Test Email';
     public static final String SUBJECT1 = 'Subject of Test Email with Only Email Address';
     public static final String BODY = 'BODY of Test Email';
     public static final String EMAIL_ADDRESS = 'blah@blah.org';
     public static final String TEXT_ATTACHMENT_NAME = 'My Text Attachment';
     public static final String TEXT_ATTACHMENT_BODY = 'My Text Attachment BODY';
     public static final String PDF_ATTACHMENT_NAME = 'My PDF Attachment.pdf';
     public static final String PDF_ATTACHMENT_BODY = 'My PDF Attachment BODY';
     public static final String INVALIDID = '000000000000000';    
     
    static testMethod void basicTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', Email='tuser15@salesforce.com');
        insert testLead;
    
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);
        
        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');
        
        Task aTask = [select Subject from Task where WhoID = :testLead.ID];
        System.AssertEquals(aTask.Subject, 'Email: Subject of Test Email');
        
        Lead aLead = [select name, (SELECT Subject, ActivityDate, Description from ActivityHistories) FROM Lead where id=:testLead.ID];
  //      System.assert(aLead.ActivityHistories.size()==1);
  //      System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);
        
    }
    
    
    static testMethod void basicTestwithTextAttachment() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', Email='tuser15@salesforce.com');
        insert testLead;
    
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);
        inputParams.put('textAttachmentName',TEXT_ATTACHMENT_NAME);
        inputParams.put('textAttachmentContent',TEXT_ATTACHMENT_BODY);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);

        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');
        Lead aLead = [select name, (SELECT Subject, ActivityDate, Description from ActivityHistories) FROM Lead where id=:testLead.ID];
//        System.assert(aLead.ActivityHistories.size()==1);
//        System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);        
        
        Attachment anAttach = [select id, name from Attachment where parentID = :testLead.ID];
        System.AssertEquals(anAttach.name, TEXT_ATTACHMENT_NAME);
        
    }


    static testMethod void basicTestwithpdfAttachment() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', Email='tuser15@salesforce.com');
        insert testLead;
    
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);
        inputParams.put('pdfAttachmentName',PDF_ATTACHMENT_NAME);
        inputParams.put('pdfAttachmentContent',PDF_ATTACHMENT_BODY);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);

        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');
        Lead aLead = [select name, (SELECT Subject, ActivityDate, Description from ActivityHistories) FROM Lead where id=:testLead.ID];
//        System.assert(aLead.ActivityHistories.size()==1);
//        System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);        
        
        Attachment anAttach = [select id, name from Attachment where parentID = :testLead.ID];
        System.AssertEquals(anAttach.name, PDF_ATTACHMENT_NAME);
        
    }
    
 /*
  * This test is to test the convert Lead with the Account ID specified
  */
       static testMethod void basicTestwithCCEmail() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', Email='tuser15@salesforce.com');
        insert testLead;
    
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);
        inputParams.put('emailAddress',EMAIL_ADDRESS);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);

        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');
                        
        Lead aLead = [select name, (SELECT Subject, ActivityDate, Description from ActivityHistories) FROM Lead where id=:testLead.ID];
 //       System.assert(aLead.ActivityHistories.size()==1);
 //       System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);
 //       System.assertEquals(aLead.ActivityHistories[0].Description.contains(EMAIL_ADDRESS), True);

                
    }

    static testMethod void basicTestwithTextAttachmentandCCEmail() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', Email='tuser15@salesforce.com');
        insert testLead;
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);
        inputParams.put('emailAddress',EMAIL_ADDRESS);
        inputParams.put('textAttachmentName',TEXT_ATTACHMENT_NAME);
        inputParams.put('textAttachmentContent',TEXT_ATTACHMENT_BODY);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);

        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');        
    
        Lead aLead = [select name, (SELECT Subject, ActivityDate, Description from ActivityHistories) FROM Lead where id=:testLead.ID];
 //       System.assert(aLead.ActivityHistories.size()==1);
 //       System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);
 //       System.assertEquals(aLead.ActivityHistories[0].Description.contains(EMAIL_ADDRESS), True);
        Attachment anAttach = [select id, name from Attachment where parentID = :testLead.ID];
        System.AssertEquals(anAttach.name, TEXT_ATTACHMENT_NAME);
        
    }

static testMethod void attachmentTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe', email='vrajaram@salesforce.com');
        insert testLead;
            
        // Create dummy conversion
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body','testing body');
        inputParams.put('textAttachmentName','textattach');
        inputParams.put('textAttachmentContent','testing text content');
        inputParams.put('pdfAttachmentName','pdfattach');
        inputParams.put('pdfAttachmentContent','testing pdf content');
        


        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);

        System.assertEquals(result.outputparameters.get('Status'),'SUCCESS');
                
        Lead aLead = [select name, (SELECT Subject from ActivityHistories), (select name from Attachments) FROM Lead where id=:testLead.ID];
     //   System.assert(aLead.ActivityHistories.size()==1);
     //   System.assertEquals(aLead.ActivityHistories[0].subject, 'Email: '+SUBJECT);
        
        System.assert(aLead.Attachments.size()==2);
        String attach1Name = aLead.Attachments[0].name;
        String attach2Name = aLead.Attachments[1].name;
        
        System.assert(attach1Name == 'textattach' || attach2Name == 'textattach');
        System.assert(attach1Name == 'pdfattach.pdf' || attach2Name == 'pdfattach.pdf');
        

        

    } 

 

 /*
  * -ve Test
  */  
  static testMethod void negativeTest() {

        // Create dummy lead
    
       
        // Test Sending Email against a record
        SendEmail aSendEmailPlugin = new SendEmail();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',INVALIDID);
        inputParams.put('subject',SUBJECT);
        inputParams.put('body',BODY);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aSendEmailPlugin.invoke(request);
        
        System.assertEquals(result.outputparameters.get('Status'),'ERROR');
        
    }  
  
    
 /*
  * This test is to test the describe() method
  */ 
        static testMethod void describeTest() {

                SendEmail aSendEmailPlugin = new SendEmail();
                Process.PluginDescribeResult result = aSendEmailPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 8);
                System.AssertEquals(result.OutputParameters.size(), 2);
        
        }

    
}