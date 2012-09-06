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
 * This Apex plug-in for Visual Workflow is a wrapper on top of the standard SendEmail API to send emails
 * This Apex plug-in also supports the ability to send a PDF attachment. 
 *
 * Inputs:
 *  recordID (String)  - Optional
 *  emailAddress (String) - Optional
 *  subject (String) - Required
 *  body (String) - Required
 *  textAttachmentName (String) - Required
 *  textAttachmentBody (String) - Required
 *  pdfAttachmentName (String) - Required
 *  pdfAttachmentBody (String) - Required
 *
 * Outputs:
 *  Status (String) - SUCCESS/ERROR
 *  ErrorMessage(String) - 'Email sent successfully'
 */


// The Apex Plug-in for a flow must implement the Apex Process.Plugin Interface
global with sharing class SendEmail implements Process.Plugin {

    public String pluginStatus;
    public String pluginErrorMessage;
    
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    public static final String SUCCESS_MESSAGE = 'Email sent successfully';

    
    
    /* The main class called by the engine at run-time
     *
     * Inputs:
     *  recordID - Value set in the setTargetObjectId call to SendSingleEmail
     *  emailAddress (String) - set the "To Address" of the email
     *  subject (String) - Self explanatory
     *  body (String) - Self Explanaory
     *  textAttachmentName (String) - Name of the attachment to be sent. The attachment is added to the
     *              attachments section if a record ID is set as long as the record ID is not a User.
     *  textAttachmentBody (String) - Body of the attachment recorded in the attachments related list
     *  pdfAttachmentName (String) - Should contain ".pdf" to convert the pdfAttachmentBody to pdf.
     *  pdfAttachmentBody (String) - PDF body of the attachment.
     *
     * Outputs:
     *  Status (String) - SUCCESS/ERROR
     *  ErrorMessage(String) - 'Email sent successfully'
     */
    
        global Process.PluginResult invoke(Process.PluginRequest request) {    

        // Get all the inputs from the Flow
        String recordID = (String) request.inputParameters.get('recordID');
        String emailAddress = (String) request.inputParameters.get('emailAddress');
        String subject = (String) request.inputParameters.get('subject');
        String body = (String) request.inputParameters.get('body');
       
        //Get the list of Attachments
        String textAttachmentName = (String) request.inputParameters.get('textAttachmentName');
        String textAttachmentContent = (String) request.inputParameters.get('textAttachmentContent');
        String pdfAttachmentName = (String) request.inputParameters.get('pdfAttachmentName');
        String pdfAttachmentContent = (String) request.inputParameters.get('pdfAttachmentContent');
    
    Map<String,Object> attachments = new Map<String,Object>();
    if ( (textAttachmentName !=null &&  textAttachmentName.length() > 0) && (textAttachmentContent !=null &&  textAttachmentContent.length() > 0))
            attachments.put(textAttachmentName, textAttachmentContent);
 
     if ( (pdfAttachmentName !=null &&  pdfAttachmentName.length() > 0) && (pdfAttachmentContent !=null &&  pdfAttachmentContent.length() > 0))
           if(!pdfAttachmentName.contains('.pdf')) pdfAttachmentName = pdfAttachmentName+'.pdf';
            attachments.put(pdfAttachmentName, pdfAttachmentContent);  
                     
    Map<String,Object> result = new Map<String,Object>();
    try {
        //Send email
        SendEmail(recordID, emailAddress, subject, attachments,body);
        result.put('Status', pluginStatus);
        result.put('ErrorMessage', pluginErrorMessage);
    }
    catch (Exception anException) {
        result.put('Status',ERROR);
        result.put('ErrorMessage', anException.getMessage());

    }
     
        return new Process.PluginResult(result); 
    }
    
    /**
     * Implementation of the SendMail Apex plug-in 
     */
    global void sendEmail(
        String recordId,
        String emailAddress,
        String subject,
        Map<String,Object> attachments,
        String body
    ) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Boolean recordIdIsUser = (recordId != null) && recordId.startsWith('005'); //is the record id referencing a user id?
        Boolean saveAsActivity = !recordIdIsUser;
        if (emailAddress != null && emailAddress.length() > 0) {
            message.setToAddresses(new String[] {emailAddress});
        }
        if (recordId != null && recordId.length() > 0) {
            message.setTargetObjectId(recordId);
        }
        message.setSubject(subject);
        message.setHtmlBody(body != null ? body : '');  // If the body is empty, use an empty string
        // Don't set the reply to, because it's auto-calculated.
        message.setUseSignature(true);
        message.setSaveAsActivity(saveAsActivity);
        
        // Convert the attachments, creating the objects to add to the list of attachments if set
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        List<Attachment> attachmentList = new List<Attachment>();
        if (attachments != null) {
            for (String attachKey : attachments.keySet()) {
                String attachValue = (String) attachments.get(attachKey);
                if (attachValue == null || attachValue.length() == 0) continue;
                
                Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
                emailAttach.setFileName(attachKey);
                Blob attachment;
                if (attachKey.endsWith('.pdf')) { // if its a pdf need to convert
                    attachment = Blob.toPdf(attachValue);
                } else {
                    attachment = Blob.valueOf(attachValue);
                }
                
                emailAttach.setBody(attachment);
                emailAttachments.add(emailAttach);
                
                if (recordId != null && recordId.length() != 0 && !recordIdIsUser) {
                    Attachment attach = new Attachment();
                    attach.ParentId = recordId;
                    attach.Name = emailAttach.getFileName();
                    attach.Body = emailAttach.getBody();
                    attachmentList.add(attach);
                }
            }
        }
        message.setFileAttachments(emailAttachments);

            Messaging.SendEmailResult result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message})[0];

            // If the record ID is specified, add the email to the parent object as well.
            if (attachmentList.size() > 0) {
                insert attachmentList;
            }
            if (result.isSuccess()) {
                pluginStatus =  SUCCESS;
                pluginErrorMessage = SUCCESS_MESSAGE;
            } else {
                pluginStatus = ERROR;
                pluginErrorMessage = result.getErrors()[0].getMessage();
            }
    }


    /* This is the method the Cloud Flow Designer calls to show the Apex Plug-ins to the flow author
     * The implemnetation of this method drives how author of the flow interacts in the the Cloud Flow Designer 
     */       
    global Process.PluginDescribeResult describe() {
    
    Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        //Shows the description visible in the Palette tab of the Cloud Flow Designer.    
        result.description = 'The SendEmail Flow Plug-in send an email according to the Messaging.SendSingle Apex API';
        
        //Setting the 'tag' give the Apex Plug-in as its own section on the Cloud Flow Designer Palette tab.
        // Use this attribute to group related Apex Plug-ins together in the Cloud Flow Designer.        
        result.tag = 'Emails';

        //All the Inputs needed, their data type and the requiredness        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('recordID', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('emailAddress', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('subject', 
                Process.PluginDescribeResult.ParameterType.STRING, true),            
            new Process.PluginDescribeResult.InputParameter('body', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('textAttachmentName', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('textAttachmentContent', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('pdfAttachmentName', 
                Process.PluginDescribeResult.ParameterType.STRING, false),
             new Process.PluginDescribeResult.InputParameter('pdfAttachmentContent', 
                Process.PluginDescribeResult.ParameterType.STRING, false)
                                                                                                                 
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
  
    }