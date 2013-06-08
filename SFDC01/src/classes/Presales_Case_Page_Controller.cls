/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  12/09/2011     Shalabh Sharma       This controller is associated with EMC_Presales_Page and Presales_SuccessPage.Used to save record in
                                        Case Object 
 |  21/12/2011     Shalabh Sharma 4818  Added Country_Hidden__c field in save method               
 
 |  07/03/2012     Leonard Victor       Added Error Message for internal email address used
 |  10/03/2012     Shalabh Sharma       Added logic to populate service type description table on case page.
 +==================================================================================================================**/
public class Presales_Case_Page_Controller {
    public ApexPages.StandardController stdCon;
    //public Id sobjId{get;set;}
    public Case caseRecord{get;set;}
    public RecordType rt{get;set;}
    PageReference caseUrl;
    //public Boolean flag = false;
    public static ID caseRecordId;
    //public String fileName;
    public List<Attachment> attachments;
    public List<Attachment> newAttachments{get;set;}
    public static final integer attachmentsToAdd = 5;
    //public blob Attach1 {get;set;} 
    //public blob Attach2 {get;set;}
    /*public Boolean getflag(){
        return flag;
    }
    public void setflag(Boolean flag){
        this.flag = flag;
    }*/
    
    public Presales_Case_Page_Controller(){
        newAttachments=new List<Attachment>{new Attachment()};
        system.debug('initial attmt'+newAttachments);
    } 
    
    public Presales_Case_Page_Controller(ApexPages.StandardController stdController){
        stdCon = stdController;
        this.caseRecord = (Case)stdController.getRecord();  
    }
    /*Adding five browse buttons on each click of Add More button*/
    public void addMore(){
        
        for (Integer i=0; i<attachmentsToAdd; i++)
        {
            //flag = true;
            system.debug('first attmt--->'+newAttachments);
            newAttachments.add(new Attachment());
            system.debug('first attmt after adding--->'+newAttachments);
            /*for(Attachment attmt:newAttachments){
            fileName=newAttachments[0].name;
            system.debug('name --->'+fileName); 
        }*/
        }
    } /*
    public String getfileName(){
        
        String name = fileName;
        system.debug('name after return--->'+name);
        return name;
    }*/
    public PageReference save(){
        ApexPages.Message myMsg;
        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your EMC email address in the firstname.lastname@emc.com format');
        String email = caseRecord.contact_Email1__c ; 
        Boolean createCase = true;
        List<String> nameList= email.split('@');
        if (!(nameList[0].contains('.')) && email.contains('@emc.com'))
        {
             ApexPages.addMessage(myMsg);
             createCase = false;
       }

        if(createCase){
         RecordType rt = [select Id, Name from RecordType where Name =:caseRecord.Record_Type_Hidden__c];
        system.debug('record type--->'+rt);
        caseRecord.RecordTypeId = rt.Id;
        caseRecord.Type = caseRecord.Case_Sub_Type__c;
        caseRecord.Theatre__c = caseRecord.Theater_Site_Page__c;
        caseRecord.Priority = caseRecord.Priority_Site_Page__c;
        caseRecord.Country_Hidden__c = caseRecord.Country__c;
        caseRecord.Description = 'Web Division/Geo: '+caseRecord.web_division_geo__c+'\n'+
                    'Web Customer Name/Number: '+caseRecord.Customer_Name_Number__c+'\n'+
                    'Web Opportunity Name/Number: '+caseRecord.opp_name_number__c+'\n'+'\n'+
                    caseRecord.Description;

       try{
        stdCon.save();
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
        
        system.debug('stdCon.getID()--->'+stdCon.getID());
        caseRecordId = stdCon.getID();
        system.debug('record id--->'+caseRecordId);
        system.debug('caseRecord--->'+caseRecord);
        system.debug('attmt size--->'+newAttachments);
        List<Attachment> toInsert=new List<Attachment>();
        if(newAttachments!=null){
            for (Attachment newAtt : newAttachments){
                system.debug('attmt body--->'+newAtt.Body);
                if (newAtt.Body!=null)
                {
                    newAtt.parentId=caseRecordId;
                    toInsert.add(newAtt);
                }
            }
            insert toInsert;
        }
       
        //newAttachments.clear();
        //newAttachments.add(new Attachment());
        
        
        //attachments=null;
        /*delete [select id from Attachment where ParentId=:caseRecordId];
        Blob b1 = Attach1;
        Blob b2 = Attach2;
        
        if(b1!=null){
            Attachment At = new Attachment(Name ='File1',body = b1,ContentType = 'doc,txt,jpeg',parentId=caseRecordId); 
            insert At;
        }
        if(b2!=null){
            Attachment At = new Attachment(Name ='File2',body = b2,ContentType = 'doc,txt,jpeg',parentId=caseRecordId); 
            insert At;  
        }   */
        
        system.debug('case id--->'+caseRecordId);
        if(caseRecordId != Null){
            caseUrl = new PageReference('/apex/Presales_Case_SuccessPage');
            system.debug('case url--->'+caseUrl);
        }}
        return caseUrl;
    

    }
/*Method to return case number on success page*/    
    public String getApplicationID(){
        
        Case newCaseRecord =[select id,CaseNumber from Case where id = :caseRecordId];
            return newCaseRecord.CaseNumber;
    }
    public void createInstance(){
        system.debug('first attmt on load--->'+newAttachments);
        newAttachments=new List<Attachment>{new Attachment()};  
    }
/*Method to return service types for selected theater*/ 
@RemoteAction   
    public static String getDescription (String selectedTheater){
        Map<Id,Presales_ProfileRecordTypeMappingObject__c>  mapProfileRecordTypeMapping = new map<Id,Presales_ProfileRecordTypeMappingObject__c>([Select Id,Name,Record_Type_Id__c,Theater__c from Presales_ProfileRecordTypeMappingObject__c]);
        Map<String,String> mapTheaterServiceType = new Map<String,String>();
        String serviceTypes;
        for(Presales_ProfileRecordTypeMappingObject__c mapping:mapProfileRecordTypeMapping.values()){
            if(mapping.Theater__c!=null){
                mapTheaterServiceType.put(mapping.Theater__c,mapping.Record_Type_Id__c);
            }   
        }
        serviceTypes = mapTheaterServiceType.get(selectedTheater); 
        List<Id> lstId = serviceTypes.split(',');
        String serviceType;
	//Code STARTS here to ignore Proof of concept,solutions support and Vlab Demo record types in web form
        //Declare set to store record type names which should not show in webform
        set<String> setRecordTypesToIgnore = new Set<String>();
        Presales_Restricted_Record_Types__c dataValueMap = Presales_Restricted_Record_Types__c.getValues('Restricted_Record_Types');
        if(dataValueMap != null && dataValueMap.Record_Type_Names__c != null)
        	setRecordTypesToIgnore.addAll(dataValueMap.Record_Type_Names__c.split(',')); 
        RecordType[] lstRT= [Select Id,Name,Description from RecordType where Id in:lstId and name not in: setRecordTypesToIgnore];
        //Code ENDS here to ignore Proof of concept,solutions support and Vlab Demo record types in web form
        Map<String,String> mapServiceTypeDescription = new Map<String,String>();
        for(RecordType rt:lstRT){
            mapServiceTypeDescription.put(rt.Name,rt.Description);
            if(serviceType==null){
                serviceType=rt.Name+'@'+rt.Description;
            }
            else{
                serviceType=serviceType+';'+rt.Name+'@'+rt.Description;
            }
        }
        return serviceType;
    }
    
}