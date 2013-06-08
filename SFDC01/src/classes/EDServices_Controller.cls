/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  12/13/2012     Shalabh Sharma       This controller is associated with EDServices_Case_Creation and EDServices_Success.Used to save record in
                                             Case and Education Services Contact Object
 +==================================================================================================================**/
public class EDServices_Controller {
    
    public Case caseRecord{get;set;}
    public Education_Services_Contact__c eDServicesContact{get;set;}
    public static ID caseRecordId;
    public List<Attachment> attachments;
    public List<Attachment> newAttachments{get;set;}
    public List<Education_Services_Contact__c> lstEdServiceContact = new List<Education_Services_Contact__c>();
    public static final integer attachmentsToAdd = 5;
    public Case cs = new Case();
    PageReference caseUrl;
    
    public EDServices_Controller(){
        eDServicesContact = new Education_Services_Contact__c(); 
        caseRecord = new Case();
        //attachments = newAttachments;
        //newAttachments.clear();
    }
    
    /*Adding five browse buttons on each click of Add More button
    public void addMore(){
        try{
            newAttachments.clear();
        for (Integer i=0; i<attachmentsToAdd; i++)
        {            
            newAttachments.add(new Attachment());
        }
        //newAttachments.addAll(attachments);
        system.debug('first attmt on load--->'+attachments);
        }
        catch(Exception e){
            system.debug('exception--->'+e);
        }
    }*/
    
    public PageReference save(){
        string rtName = System.label.EDServices_RecordType;
        RecordType rt = [Select Id, Name from RecordType where DeveloperName=:rtName];
        Education_Services_Contact__c edSer = new Education_Services_Contact__c();
        lstEdServiceContact = [Select Id,Name from Education_Services_Contact__c where Name=:eDServicesContact.Name]; 
        system.debug('edSer--->'+edSer);
        
        if(lstEdServiceContact.size()>0){
            
            cs.Subject = caseRecord.Subject;
            cs.Description = caseRecord.Description+'\n'+'\n'+
            'First Name: '+eDServicesContact.First_Name__c+'\n'+
                    'Last Name: '+eDServicesContact.Last_Name__c+'\n'+
                    'Company Name: '+eDServicesContact.Company_Name__c+'\n'+
                    'Contact Phone: '+eDServicesContact.Contact_Phone__c+'\n'+
                    'Company Address: '+eDServicesContact.Company_Address__c+'\n'+
                    'City: '+eDServicesContact.City__c+'\n'+
                    'Country: '+eDServicesContact.Country__c+'\n'+
                    'Postal Zip Code: '+eDServicesContact.Post_Zip_Code__c+'\n'+
                    'Audience Type: '+eDServicesContact.Audience_Type__c+'\n'+
                    'Preferred Language: '+eDServicesContact.Preferred_Language__c+'\n'
                    ;
            cs.RecordTypeId = rt.Id;
            cs.EDS_Contact_Email__c = lstEdServiceContact[0].Id;
            cs.Inquiry_Type__c = caseRecord.Inquiry_Type__c;

           
                insert cs;
            
            
        }
            
        else {
            Education_Services_Contact__c eDServCon = new Education_Services_Contact__c();
            eDServCon = eDServicesContact.clone();
            
            
                insert eDServCon;
            

            //Case cs = new Case();
            cs.Subject = caseRecord.Subject;
            cs.Description = caseRecord.Description+'\n'+'\n'+
            'First Name: '+eDServicesContact.First_Name__c+'\n'+
                    'Last Name: '+eDServicesContact.Last_Name__c+'\n'+
                    'Company Name: '+eDServicesContact.Company_Name__c+'\n'+
                    'Contact Phone: '+eDServicesContact.Contact_Phone__c+'\n'+
                    'Company Address: '+eDServicesContact.Company_Address__c+'\n'+
                    'City: '+eDServicesContact.City__c+'\n'+
                    'Country: '+eDServicesContact.Country__c+'\n'+
                    'Postal Zip Code: '+eDServicesContact.Post_Zip_Code__c+'\n'+
                    'Audience Type: '+eDServicesContact.Audience_Type__c+'\n'+
                    'Preferred Language: '+eDServicesContact.Preferred_Language__c+'\n'
                    ;
            cs.RecordTypeId = rt.Id;
            cs.EDS_Contact_Email__c = eDServCon.Id;
            cs.Inquiry_Type__c = caseRecord.Inquiry_Type__c;
            
                insert cs;
           
        }
        //caseRecordId = caseRecord.Id;
         List<Attachment> toInsert=new List<Attachment>();
            if(newAttachments!=null){
                for (Attachment newAtt : newAttachments){
                    system.debug('attmt body--->'+newAtt.Body);
                    system.debug('cs.Id--->'+cs.Id);
                    if (newAtt.Body!=null && cs.Id!=null)
                    {
                        newAtt.parentId=cs.Id;
                        toInsert.add(newAtt);
                    }
                }
             system.debug('toInsert--->'+toInsert);
           
                if(toInsert.size()>0){
                    insert toInsert;
                }
           
            
        }
         if(cs.Id != Null){
            caseUrl = new PageReference('/apex/EDServices_Success');
            system.debug('case url--->'+caseUrl);
        }
        return caseUrl;
    }

    /*Method to return case number on success page*/    
    public String getApplicationID(){
        
        Case newCaseRecord =[select id,CaseNumber from Case where id = :cs.Id];
            return newCaseRecord.CaseNumber;
    }
    public void createInstance(){
    
        system.debug('first attmt on load--->'+newAttachments);
        newAttachments=new List<Attachment>{new Attachment()};
        newAttachments.add(new Attachment());
        newAttachments.add(new Attachment());
    }
}