global class EMC_SFA_ConvertLead{

    webService static String convertLead(String leadId){
       String ConvertLead =  EMC_ConvertLead.convertLead(leadId);    
       return ConvertLead;
    }
    
    //Test method
    public static testmethod void testEMC_SFA_ConvertLead(){
    Account acc= new Account(name='Deploy');
    insert acc;
    Contact contact1 =new Contact(FirstName='John' , LastName='Doe',Email='doe_john@salesforce.com',accountid=acc.id);        
    insert contact1;        
    Lead lead= new Lead(Company='Deploy Lead',LastName='Doe',Related_Account__c=acc.id,Related_Contact__c=contact1.id,email='doe_john1@salesforce.com');        
    insert lead;
    convertLead(''+lead.id);
}
}