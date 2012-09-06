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




 * Salesforce version written for: Winter '12
 * This Apex plug-in for Visual Workflow creates a pdf document and attaches to the notes and attachmetns section of any record in salesforce.
 * Inputs: 
 *    Record ID (Required)
 *    Attachment Name (Required)
 *    Attachment content (Required)
 *
 * Outputs:
 *    Status = SUCCESS/ERROR if all is well or any Error
 *    ErrorMessage if status is ERROR with the apprporiate error message
 */



// The Apex Plug-in for a flow must implement the Apex Process.Plugin Interface
global with sharing class createAndAttachPDF implements Process.Plugin {

 // Member variables for status
    public static final String SUCCESS_CODE = 'SUCCESS';
    public static final String ERROR_CODE = 'ERROR';
    
    public String aStatus;
    public String anErrorDescription;
 
 
    // This is the main method the Flow engine calls at run-time. 
    global Process.PluginResult invoke(Process.PluginRequest request) {    

        //Get the record to which the pdf needs to be attached
        String recordID = (String) request.inputParameters.get('recordID');
       
        //Get the attachment content
        String pdfAttachmentName = (String) request.inputParameters.get('pdfAttachmentName');
        String pdfAttachmentContent = (String) request.inputParameters.get('pdfAttachmentContent');
    
                     
        Map<String,Object> result = new Map<String,Object>();
    
        //Do the magic!
        AttachPDF(recordID, pdfAttachmentName, pdfAttachmentContent);
        result.put('Status', aStatus);
        result.put('ErrorMessage', anErrorDescription);
     
        return new Process.PluginResult(result); 
    }


    /* This is the method the Cloud Flow Designer calls to show the Apex Plug-ins to the flow author
    * The implemnetation of this method drives how author of the flow interacts in the the Cloud Flow Designer 
    */      
    global Process.PluginDescribeResult describe() {
    
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        //Shows the description visible in the Palette tab of the Cloud Flow Designer.
        result.description = 'The createAndAttachPDF Flow Plug-in create a PDF document and attaches it to the specified record ID';
        
        //Setting the 'tag' give the Apex Plug-in as its own section on the Cloud Flow Designer Palette tab.
        result.tag = 'PDF Utils';
        
        //All the Inputs needed, their data type and the requiredness
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('recordID', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('pdfAttachmentName', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
             new Process.PluginDescribeResult.InputParameter('pdfAttachmentContent', 
                Process.PluginDescribeResult.ParameterType.STRING, true)
                                                                                                                 
                };
        //All the Outputs and their data type
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Status', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ErrorMessage', 
                Process.PluginDescribeResult.ParameterType.STRING)    
                };     
        return result;
        }
        
    /*
     * The Implementation of the Create and Attach PDF
     */
        public void  AttachPDF(String recordID, String pdfAttachmentName, String pdfAttachmentContent) {
        
        Blob pdfattachment;
            try {
                pdfattachment = Blob.toPdf(pdfAttachmentContent);
                Attachment attach = new Attachment();
                attach.ParentId = recordId;
                attach.Name = pdfAttachmentName;
                attach.Body = pdfattachment;
                insert(attach);
                
                aStatus = SUCCESS_CODE;
            } catch (Exception anException) {
                aStatus = ERROR_CODE;
                anErrorDescription = anException.getMessage();
            }
        
        }

 
/*
 * This section onwards are for the tests
 */
 

/*
 * This is a basic test where the PDF is created and attached to a Lead record
 */
    
        static testMethod void basicTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;

        createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('pdfAttachmentName','PDF Attachment');
        inputParams.put('pdfAttachmentContent','Dear All This is a test');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aPdfPlugin.invoke(request);
        System.debug(result);
        
        System.assertEquals(result.OutputParameters.get('Status'),'SUCCESS');     

        Attachment anAttach = [select parentID, name from attachment where parentiD =:testLead.ID];
        System.AssertEquals(anAttach.name, 'PDF Attachment' );            
        
        
        }
        
        /*
        * basic -eve test with an invalid recordID
        */        
        static testMethod void negativeTest() {


        createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        //Pass in invalid ID
        inputParams.put('recordID','blah');
        inputParams.put('pdfAttachmentName','PDF Attachment');
        inputParams.put('pdfAttachmentContent','Dear All This is a test');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aPdfPlugin.invoke(request);
   
        System.debug(result);
        System.assertEquals(result.OutputParameters.get('Status'),'ERROR');     
        
        }


 /*
  * This test is to test the describe() method
  */ 
        static testMethod void describeTest() {

                createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
                Process.PluginDescribeResult result = aPdfPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 3);
                System.AssertEquals(result.OutputParameters.size(), 2);
        
        }
                
  }