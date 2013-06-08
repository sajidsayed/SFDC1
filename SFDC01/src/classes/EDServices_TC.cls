@isTest(SeeAllData=true)
public class EDServices_TC{
    public static TestMethod void edServices()
    {   
    Education_Services_Contact__c edserv=new Education_Services_Contact__c();
        edserv.Name='test@test.com';
        //edserv.Id=''';
        
        
        
        String rtName = System.label.EDServices_RecordType;
        RecordType rt = [Select Id, Name from RecordType where DeveloperName=:rtName];
        Case c= new Case();
        //c.Id='';
        c.EDS_Contact_Email__c=edserv.Id;
        c.RecordTypeId = rt.Id;
        c.EDS_Email__c = 'test@test.com';
       
        //insert c;
        
        
        
   //Creating New Attachment Object and creating a reocrd for attachment object
        Attachment att = new Attachment();     
        List<Attachment> attLst = new List<Attachment>();  
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        //List<Case> lst_Case = [Select ID,Escalation__c,IsEscalated,CaseNumber,Record_Type_Hidden__c from Case where Id =:lstCase];
        
        //System.debug('CASELIST__>'+caseLst);
      
        att.ParentId=c.Id;
        att.Body=myBlob;
        att.Name='File1';
        att.ContentType = 'doc,txt,jpeg';
        attLst.add(att);

        Test.StartTest();
        try{
            Database.insert(edserv);
        }
        catch(DmlException e){
            //String s = (String)e;
            system.assert(e.getMessage().contains('An active Education Services Contact with this email address already exists in Salesforce.com.'));
        }
        Database.insert(c);
        EmailMessage emsg= new EmailMessage();
        emsg.ParentId=c.Id;
        emsg.FromAddress = 'test1@test.com';
        emsg.Incoming = true;
        Database.insert(emsg);
        c.Status = 'Resolved';
        Database.update(c);
        
        system.debug('edserv--->'+edserv);
        Education_Services_Contact__c edserv1 = new Education_Services_Contact__c();
        edserv1.Name = 'test1@test.com';
        try{
            Database.insert(edserv1);
        }
        catch(DmlException e){
            //String s = (String)e;
            system.assert(e.getMessage().contains('An active Education Services Contact with this email address already exists in Salesforce.com.'));
        }
        Education_Services_Contact__c edserv2 = new Education_Services_Contact__c();
        edserv2.Name = 'test2@test.com';
        Database.insert(edserv2);
        edserv2.Name = 'test3@test.com';
        Database.update(edserv2);

        ApexPages.currentpage().getParameters().put('Id',c.id); 
        //ApexPages.currentpage().getParameters().put('eDServicesContact.Name',edserv);
        ApexPages.StandardController controller = new ApexPages.StandardController(c);  
        //EDServices_Controller caseObj= new EDServices_Controller(controller);
        EDServices_Controller caseObj1= new EDServices_Controller();
        caseObj1.eDServicesContact=edserv;
        caseObj1.newAttachments=attLst;         
        //caseObj1.addMore();
        caseObj1.Save();
        caseObj1.getApplicationID();
        caseObj1.createInstance();
        
        ApexPages.currentpage().getParameters().put('Id',c.id);
        ApexPages.currentpage().getParameters().put('eDServicesContact.Name','test2@test.com');
        ApexPages.StandardController controller1 = new ApexPages.StandardController(c);  
        //EDServices_Controller caseObj= new EDServices_Controller(controller);
        EDServices_Controller caseObj= new EDServices_Controller();
        caseObj.eDServicesContact.Name='test2@test.com';
        //caseObj.newAttachments=attLst;         
        //caseObj.addMore();
        caseObj.Save();
        caseObj.getApplicationID();
        caseObj.createInstance();


        
        Test.StopTest();
        
    } 
}