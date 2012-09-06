/*

Copyright (c) 2012, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.


 * Salesforce version written for: Winter '12 onwards
 * This Apex plug-in for Visual Workflow does the lead conversion of any given lead.
 * Inputs: 
 *    lead ID (Required)
 *    Contact ID (Optional)
 *    Account ID (Optional)
 *    Converted Status (Optional)
 *    OverwriteLeadSource (Optional)
 *    Converted Status (Optional)
 *    Opportunity Name (Optional)
 *    SendEmailtoOwner (Optional)
 *
 * Outputs:
 *    Account ID: ID of the account after the conversion
 *    Contact ID: ID of the contact after the conversion
 *    Opportunity ID: ID of the Opportunity after the conversion
 */


// The Apex Plug-in for a flow must implement the Apex Process.Plugin Interface
global with sharing class  ConvertLead implements Process.Plugin {

    // This is the main method the Flow engine calls at run-time.
    global Process.PluginResult invoke(Process.PluginRequest request) {    

        // Get all the inputs from the Flow
        String leadID = (String) request.inputParameters.get('LeadID');
        String contactID = (String) request.inputParameters.get('ContactID');
        String accountID = (String) request.inputParameters.get('AccountID');
        String convertedStatus = (String) request.inputParameters.get('ConvertedStatus');
        Boolean overWriteLeadSource = (Boolean) request.inputParameters.get('OverwriteLeadSource');
        Boolean createOpportunity = (Boolean) request.inputParameters.get('CreateOpportunity');
        String opportunityName = (String) request.inputParameters.get('OpportunityName');
        Boolean sendEmailToOwner = (Boolean) request.inputParameters.get('SendEmailToOwner');   
        
        // Set the default handling for booleans 
        if (overWriteLeadSource == null) overWriteLeadSource = false;
        if (createOpportunity == null) createOpportunity = true;
        if (sendEmailToOwner == null) sendEmailToOwner = false;
        
        Map<String,Object> result = new Map<String,Object>();
    
        //Convert the lead
        result = convertLead(leadID, contactID, accountID, convertedStatus, overWriteLeadSource, createOpportunity, opportunityName, sendEmailToOwner);
        return new Process.PluginResult(result); 
    }
 
 
    /* This is the method the Cloud Flow Designer calls to show the Apex Plug-ins to the flow author
     * The implemnetation of this method drives how author of the flow interacts in the the Cloud Flow Designer 
     */   
    global Process.PluginDescribeResult describe() {
    
    Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        //Shows the description visible in the Palette tab of the Cloud Flow Designer.
        result.description = 'The LeadConvert Flow Plug-in converts a lead into an account and contact, as well as (optionally) an opportunity.';
        
        //Setting the 'tag' give the Apex Plug-in as its own section on the Cloud Flow Designer Palette tab.
        // Use this attribute to group related Apex Plug-ins together in the Cloud Flow Designer.
        result.tag = 'Lead Management';
        
        //All the Inputs needed, their data type and the requiredness
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('LeadID', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('AccountID', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('ContactID', 
                Process.PluginDescribeResult.ParameterType.STRING, false),            
            new Process.PluginDescribeResult.InputParameter('ConvertedStatus', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('OpportunityName', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('OverwriteLeadSource', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN, false),
            new Process.PluginDescribeResult.InputParameter('CreateOpportunity', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN, false),
            new Process.PluginDescribeResult.InputParameter('SendEmailToOwner', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN, false)                                                   
                };
        //All the Outputs and their data type
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('AccountID', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ContactID', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('OpportunityID', 
                Process.PluginDescribeResult.ParameterType.STRING)                
                };
   
        
        return result;
    }
    
    
        
    /**
     * The Implementation of the Lead conversion using the standard Apex LeadConvert API
     */
    public Map<String,String> convertLead (
                               String leadID,
                               String contactID,
                               String accountID,
                               String convertedStatus,
                               Boolean overWriteLeadSource,
                               Boolean createOpportunity,
                               String opportunityName,
                               Boolean sendEmailToOwner
        ) {
        Map<String,String> result = new Map<String,String>();
        LeadStatus convertStatus;
        if (leadId == null) throw new ConvertLeadPluginException('Lead Id cannot be null');
        if (convertedStatus == null) {
            convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1]; 
        }
    
        
        Lead[] leads = [Select Id, FirstName, LastName, Company From Lead where Id = :leadID];
        if (leads.size() > 0) {
            Lead l = leads[0];
            // CheckAccount = true, checkContact = false
            if (accountID == null && l.Company != null) {
                Account[] accounts = [Select Id, Name FROM Account where Name = :l.Company LIMIT 1];
                if (accounts.size() > 0) {
                    accountId = accounts[0].id;
                }
            }
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadID);
            lc.setOverwriteLeadSource(overWriteLeadSource);
            lc.setDoNotCreateOpportunity(!createOpportunity);
            lc.setConvertedStatus(convertedStatus!=null ? convertedStatus : convertStatus.MasterLabel );
            if (sendEmailToOwner != null) lc.setSendNotificationEmail(sendEmailToOwner);
            if (accountId != null && accountId.length() > 0) lc.setAccountId(accountId);
            if (contactId != null && contactId.length() > 0) lc.setContactId(contactId);
            if (createOpportunity) {
                lc.setOpportunityName(opportunityName);
            }
            
            Database.LeadConvertResult lcr = Database.convertLead(lc, true);
            if (lcr.isSuccess()) {
                result.put('AccountID', lcr.getAccountId());
                result.put('ContactID', lcr.getContactId());
                if (createOpportunity) {
                    result.put('OpportunityID', lcr.getOpportunityId());
                }
            } else {
                String error = lcr.getErrors()[0].getMessage();
                throw new ConvertLeadPluginException(error);
            }
        } else { 
            throw new ConvertLeadPluginException('No leads found with Id : "' + leadId + '"');
        }
        return result;
    }
        
        class ConvertLeadPluginException extends Exception {}

/*
 * This section onwards are for the tests
 */
 

/*
 * This is a basic test with just the LeadID and Converted Status specified in the call the Apex Plug-in
 */
 
    static testMethod void basicTestwith() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
    
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1]; 
        
        // Create dummy conversion
        ConvertLead aLeadPlugin = new ConvertLead();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('LeadID',testLead.ID);
        inputParams.put('ConvertedStatus',convertStatus.MasterLabel);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aLeadPlugin.invoke(request);
        
        Lead aLead = [select name, id, isConverted from Lead where id = :testLead.ID];
        System.Assert(aLead.isConverted);
        
    }

/*
 * This is another basic test with just the LeadID and nothing else.
 */
 
    static testMethod void basicTestWithoutConvertedStatus() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
            
        // Create dummy conversion
        ConvertLead aLeadPlugin = new ConvertLead();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('LeadID',testLead.ID);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aLeadPlugin.invoke(request);
        
        Lead aLead = [select name, id, isConverted from Lead where id = :testLead.ID];
        System.Assert(aLead.isConverted);
        
    }
    
 /*
  * This test is to test the convert Lead with the Account ID specified
  */
       static testMethod void basicTestwithAccount() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
        
        Account testAccount = new Account(name='Test Account');
        insert testAccount;
    

        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1]; 
        
        // Create dummy conversion
        ConvertLead aLeadPlugin = new ConvertLead();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('LeadID',testLead.ID);
        inputParams.put('AccountID',testAccount.ID);
        inputParams.put('ConvertedStatus',convertStatus.MasterLabel);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aLeadPlugin.invoke(request);
        
        Lead aLead = [select name, id, isConverted, convertedAccountID from Lead where id = :testLead.ID];
        System.Assert(aLead.isConverted);
        //System.debug('ACCOUNT AFTER' + aLead.convertedAccountID);
        System.AssertEquals(testAccount.ID, aLead.convertedAccountID);
    }

/*
  * This test is to test the convert Lead with the Company matching more than one existing Account Names
  */
       static testMethod void basicTestwithAccounts() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
        
        Account testAccount1 = new Account(name='Test Lead');
        insert testAccount1;
        Account testAccount2 = new Account(name='Test Lead');
        insert testAccount2;


        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1]; 
        
        // Create dummy conversion
        ConvertLead aLeadPlugin = new ConvertLead();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('LeadID',testLead.ID);
        inputParams.put('ConvertedStatus',convertStatus.MasterLabel);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aLeadPlugin.invoke(request);
        
        Lead aLead = [select name, id, isConverted, convertedAccountID from Lead where id = :testLead.ID];
        System.Assert(aLead.isConverted);
    }


 /*
  * -ve Test
  */    
    static testMethod void errorTest() {

        // Create dummy lead
        //Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1]; 
        
        // Create dummy conversion
        ConvertLead aLeadPlugin = new ConvertLead();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();
        inputParams.put('LeadID','00Q7XXXXxxxxxxx');
        inputParams.put('ConvertedStatus',convertStatus.MasterLabel);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        try {
            result = aLeadPlugin.invoke(request);    
        }
        catch (Exception e) {
          System.debug('EXCEPTION' + e);
          System.AssertEquals(1,1);
        }
        
    }
    
    
 /*
  * This test is to test the describe() method
  */ 
        static testMethod void describeTest() {

                ConvertLead aLeadPlugin = new ConvertLead();
                Process.PluginDescribeResult result = aLeadPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 8);
                System.AssertEquals(result.OutputParameters.size(), 3);
        
        }

    

 }