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
 * This Flow plugin submits a record for approval
 * Inputs: 
 *    Record ID (Required)
 
 * Outputs:
 *    Status = SUCCESS/ERROR if all is well or if there is an error
 *    ErrorMessage is status is ERROR with the appropriate error message
 */

// The Apex Plug-in for a flow must implement the Apex Process.Plugin Interface
global with sharing class submitForApproval implements Process.Plugin {

 // Member variables for status
    public static final String SUCCESS_CODE = 'SUCCESS';
    public static final String ERROR_CODE = 'ERROR';
    public static final String BAD_ID = 'INVALIDID';

    
    public String aCurrentApprover;
    public String aStatus;
    public String anErrorDescription;
 
 
 // The main method invoked by the Flow engine at run-time.
    global Process.PluginResult invoke(Process.PluginRequest request) {    

//Get the record to which the pdf needs to be attached
        String recordID = (String) request.inputParameters.get('recordID');
    
//Submit the record for approval    
    Submit4Approval(recordID);
                     
    Map<String,Object> result = new Map<String,Object>();
    result.put('Status', aStatus);
    result.put('Error Message', anErrorDescription);
     
        return new Process.PluginResult(result); 
    }
    

 /* This is the method the Cloud Flow Designer calls to show the Apex Plug-ins to the flow author
     * The implemnetation of this method drives how author of the flow interacts in the the Cloud Flow Designer 
     */   
         
    global Process.PluginDescribeResult describe() {
    
    Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        //Shows the description visible in the Palette tab of the Cloud Flow Designer.    
        result.description = 'The submitForApproval Flow Plug-in submits the specified record ID for approval';
        
        //Setting the 'tag' give the Apex Plug-in as its own section on the Cloud Flow Designer Palette tab.
        // Use this attribute to group related Apex Plug-ins together in the Cloud Flow Designer.        
        result.tag = 'Approvals';
  
          //All the Inputs needed, their data type and the requiredness      
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('recordID', 
                Process.PluginDescribeResult.ParameterType.STRING, true)
                };

        //All the Outputs and their data type
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Status', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Error Message', 
                Process.PluginDescribeResult.ParameterType.STRING)    
                };
   
        
        return result;
        }
        
/* 
 * Method which uses the standard "Process" methods to submit the record for approval
 * As such, this assumes that an approval process is defined and activated for any object
 * which is submitted for approval through the flow.
 * 
 */      
        public void Submit4Approval(String recordID) {
        
            // Create an approval request for the record 
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
            req1.setObjectId(recordID);
            
            
           // Submit the approval request for the account 
           try {
            Approval.ProcessResult result = Approval.process(req1);
            
            aStatus = SUCCESS_CODE;
            } catch (Exception anException) {
                // Set the status to Error so that flow authors can branch off
                aStatus = ERROR_CODE;
                anErrorDescription = anException.getMessage();
            }
        } 
 
 
 /* 
 * Basic test. The test does not have an assert for the status as there the Process.submit depends on 
 * approval processes defined in the org. If that is the case, the status will be set to ERROR. Howecer
 * if the lead record enters an approval process, then the status will be SUCCESS. 

 */   
        static testMethod void basicTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
        ProcessInstance[] anApprovalList;
        
        submitForApproval anApprovalPlugin = new submitForApproval();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = anApprovalPlugin.invoke(request);     
        anApprovalList = [select id, status from processInstance where targetObjectID = :testLead.Id];   
        if (anApprovalList.size() > 0)
            System.AssertEquals(result.OutputParameters.get('Status'), SUCCESS_CODE);
        else
            System.AssertEquals(result.OutputParameters.get('Status'), ERROR_CODE);
        }

 /* 
 * -ve test. This tests the fact that bad ids or non-existant IDs will always result in an ERROR status
 */ 
        static testMethod void negativeTest() {
        
        submitForApproval anApprovalPlugin = new submitForApproval();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',BAD_ID);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = anApprovalPlugin.invoke(request);
        System.AssertEquals(result.OutputParameters.get('Status'), ERROR_CODE);
        }        
        
        static testMethod void describeTest() {

                submitForApproval anApprovalPlugin = new submitForApproval();
                Process.PluginDescribeResult result = anApprovalPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 1);
                System.AssertEquals(result.OutputParameters.size(), 2);
        
        }

        
  }