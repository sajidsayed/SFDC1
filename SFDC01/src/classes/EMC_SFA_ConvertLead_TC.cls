@isTest
Private Class EMC_SFA_ConvertLead_TC{
    Private static testMethod void startTest(){
        Account acc= new Account(name='Deploy');
        insert acc;
        Contact contact1 =new Contact(FirstName='John' , LastName='Doe',Email='doe_john@salesforce.com',accountid=acc.id);        
        insert contact1;        
        Lead lead= new Lead(Company='Deploy Lead',LastName='Doe',Related_Account__c=acc.id,Related_Contact__c=contact1.id,email='doe_john1@salesforce.com');        
        insert lead;
        EMC_SFA_ConvertLead.convertLead(''+lead.id);
    }
}