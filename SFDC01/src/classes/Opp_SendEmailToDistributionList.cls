/*
* Created By   :-  Sunil Arora
* Created Date :-  11th June,2010 
* Modified By  :-  Sunil Arora
* Modified Date:-  16th June,2010
* Modify Reason:-  
* Description  :-  This is a batch apex class, used to send email, when the No. of opportunity Log records with open status are more than 1000.

  Modified By   :-   Sunil Arora
  
*/
global class Opp_SendEmailToDistributionList implements Database.Batchable<SObject> {
  
 final static String DEFAULT_QUERY = 'Select id,Status__c from Opportunity_Integration_Log__c where Status__c = \'Open\' Limit 1';
 
 public String query;
 //Integer counter=0;
   //This method is used here to start context.
   global database.querylocator start(Database.BatchableContext BC) 
   {       
        if (query == null || query.length() == 0)
            { query = DEFAULT_QUERY; }
        return Database.getQueryLocator(query);
   }
   
   
    //This method is used here to excecute context.  
    global void execute(Database.BatchableContext BC,SObject[] scope)
    {
        Opportunity_Integration_Log__c[] oppLog =[Select Id,Status__c from Opportunity_Integration_Log__c where Status__c = 'Open' Limit 1000];
        
        if(oppLog.size()==1000)
        {
             
             //List<String> address=new List<String>();
             List<String> ccAddress=new List<String>();
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             /*address.add('Basayyagari_vanajakshi@emc.com');
             address.add('sunil.arora@emc.com');
             address.add('sunil.bansal@emc.com');*/
            // List<Email_Ids__c> emailsLst = Email_Ids__c.getAll().keySet();
             List<Email_Ids__c> toEmailLst = Email_Ids__c.getAll().values();
             List<Email_Ids_CCAddress__c> ccEmailLst = Email_Ids_CCAddress__c.getAll().values();
             List<String> to_address=new List<String>();
              List<String> cc_address=new List<String>();
             for(Integer i=0;i<toEmailLst.size();i++)
             {
             	to_address.add(toEmailLst[i].Name+'');
             }
              for(Integer i=0;i<ccEmailLst.size();i++)
             {
             	cc_address.add(ccEmailLst[i].Name+'');
             }
            // System.debug(addressLst+'CHECK');
             //mail.setCcAddresses.add(cc_address);
             EmailTemplate e = [select Id,Name,Subject,body from EmailTemplate where Name='Opp_SendEmailToDistributionList' Limit 1];
            mail.saveAsActivity = false;
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setToAddresses(to_address);
            mail.setCcAddresses(cc_address);
            mail.setReplyTo('SFDC_Production_Support@emc.com');
            //mail.fromAddress('SFDC_Production_Support@emc.com');
           // mail.setCcAddresses(ccAddress);
            mail.setTemplateId(e.Id);
           
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
  }  //execute
   
  
          //This method is used here to finish context.
          global void finish(Database.BatchableContext BC)
          { //We don't need to do anything.
          }

}