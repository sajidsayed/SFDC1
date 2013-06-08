/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  14/09/2011    Shalabh Sharma           This class is used to allow requestor to select record types on click of Clone and Copy Parent Details buttons on case.  
 |  30/11/2011    Leonard Victor           Changes made to include two new fields for case clone
 |  26/04/2012    Leonard Victor           Changes made to include Partner Related Fields for case clone  
 |  01/10/2012    Ganesh Soma              Added filter condition to pick only active record types
 |  26/12/2012    Srinivas Pinnamaneni     Added filter in query to get the record type names in alphabetical order in line no 107
 |  01/02/2013    John Thomson             Added fields for eservices to checkParentCase
 +==================================================================================================================**/

public class Presales_RecordTypeListController{
    public static Id value{get;set;}
    private List<SelectOption> items;
    public ApexPages.standardController stdCon;
    public Case caseRecord;
    public String caseURL;
    public String parentId;
    public Id caseId;
    String lstRecordTypeIds;
    List<String> lstRecordTypeIdsForProfile = new List<String>();
    
    public Presales_RecordTypeListController() {

    }   
    public Presales_RecordTypeListController(ApexPages.StandardController stdController){
        stdCon = stdController;
        caseRecord = (Case)stdController.getRecord();
        caseId = ApexPages.currentPage().getParameters().get('id');
        
        caseURL = ApexPages.currentPage().getURL();
        system.debug('case url--->'+caseURL);
        /*Checking index of case id in case of clone button*/
        integer checkIFCaseId = caseURL.indexOF('CaseID');
        system.debug('index of case id'+checkIFCaseId);
        parentId = caseURL.substring(checkIFCaseId+7,checkIFCaseId+22);
        system.debug('case idppppp--->'+parentId);
    }

// property that reads the value from the Component attribute
    public string sObjectType
    {
        get;
        set;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> items = new List<SelectOption>();

 //default value
        items.add(new SelectOption('','--Select Case Type --'));

 //query force.com database to get the record type of the requested object.
        Map<String,String> mapPresales_ProfileRecordTypeMapping = new Map<String,String>();
        List<Presales_ProfileRecordTypeMappingObject__c> lstPresales_ProfileRecordTypeMapping = [select Id,Name,Record_Type_Id__c from Presales_ProfileRecordTypeMappingObject__c];
        system.debug('lstPresales_ProfileRecordTypeMapping--->'+lstPresales_ProfileRecordTypeMapping);
        for(Presales_ProfileRecordTypeMappingObject__c profileRecordTypeMappingRecord:lstPresales_ProfileRecordTypeMapping){
            mapPresales_ProfileRecordTypeMapping.put(profileRecordTypeMappingRecord.Name,profileRecordTypeMappingRecord.Record_Type_Id__c); 
        }
        system.debug('mapPresales_ProfileRecordTypeMapping--->'+mapPresales_ProfileRecordTypeMapping);
        Id userProfileId = UserInfo.getProfileId();
        system.debug('profile Id'+userProfileId);
        Profile userProfile = [select Id, Name from Profile where Id =:userProfileId];
        system.debug('profile--->'+userProfile);
        
            if(mapPresales_ProfileRecordTypeMapping.containsKey(userProfile.Name)){
                lstRecordTypeIds = mapPresales_ProfileRecordTypeMapping.get(userProfile.Name);

                system.debug('list of record type ids--->'+lstRecordTypeIds);
            }
       /* else if(userProfile.Name == 'EMEA TC'){
            lstRecordTypeIds =(mapCustomSetting.get('EMEA TC1').Record_Type__c+','+mapCustomSetting.get('EMEA TC2').Record_Type__c);
            /*Presales_ProfileRecordTypeMapping__c csValue1 = mapCustomSetting.get('EMEA TC1');
            Presales_ProfileRecordTypeMapping__c csValue2 = mapCustomSetting.get('EMEA TC2');
            if(csValue1!=null && csValue2 != null){
                lstRecordTypeIds.add(csValue1.Record_Type__c);
                lstRecordTypeIds.add(csValue2.Record_Type__c);
            }
            system.debug('list of record type ids--->'+lstRecordTypeIds);   
        }
        else if(userProfile.Name == 'PreSales Service Manager'){
            lstRecordTypeIds =(mapCustomSetting.get('PreSales Service Manager1').Record_Type__c+','+mapCustomSetting.get('PreSales Service Manager2').Record_Type__c);
            /*Presales_ProfileRecordTypeMapping__c csValue1 = mapCustomSetting.get('PreSales Service Manager1');
            Presales_ProfileRecordTypeMapping__c csValue2 = mapCustomSetting.get('PreSales Service Manager2');
            if(csValue1!=null && csValue2 != null){
                lstRecordTypeIds.add(csValue1.Record_Type__c);
                lstRecordTypeIds.add(csValue2.Record_Type__c);
            }
            system.debug('list of record type ids--->'+lstRecordTypeIds);   
        }
        else if(userProfile.Name == 'PreSales Service Rep'){
                string valueOfCustomSetting =mapCustomSetting.get('PreSales Service Rep1').Record_Type__c+',';
                valueOfCustomSetting += mapCustomSetting.get('PreSales Service Rep2').Record_Type__c;
                System.Debug('valueOfCustomSetting--->' +valueOfCustomSetting);
            lstRecordTypeIds =(mapCustomSetting.get('PreSales Service Rep1').Record_Type__c+','+mapCustomSetting.get('PreSales Service Rep2').Record_Type__c);
        }   */
            lstRecordTypeIdsForProfile=lstRecordTypeIds.split(',');

            system.debug('list of record type ids--->'+lstRecordTypeIdsForProfile);
            system.debug('list of record type ids--->'+lstRecordTypeIds);   
            
            List<RecordType> rt= [select id,name from recordtype where Id = :lstRecordTypeIdsForProfile and isactive=true order by name];
                for(RecordType loopVariable: rt){
                    system.debug('Key----------->' +loopVariable.name);
                    system.debug('Value----------->' +loopVariable.Id);
                    items.add(new SelectOption(loopVariable.id,loopVariable.name));
                }
        
        system.debug('record types--->'+items);
             return items;
    }
    
    
    public void checkParentCase(){  
        system.debug('case record1111111111--->'+ApexPages.currentPage().getParameters().get('id'));
        caseRecord = [select Id,Validation_check_for_TC__c,AccountId,Description,Subject,Applications__c,Engineering_Contact__c,Area__c,
                    Business_Unit__c,Competitor_Models__c,Competitors__c,ContactId,Contact_Email1__c,
                    Contact_Phone1__c,Country__c,Customer2_Service_Requirements__c,Division__c,
                    Customer_Account_Name__c,Discount_Product_Class__c,District__c,
                    Host_Server_Environment__c,MWD_Incident_Number__c,
                    Number_of_Configurations__c,Opportunity_Name__c,Order_Number__c,Parts_Missing_Wrong_Damaged__c,
                    PAS_Number__c,QA_Comments__c,Quote_Type__c,RPQ_Deal_Value__c,SoW_Document_Number__c,
                    T_E_Price__c,Theatre__c,Tools__c,Case_Completed_STD_Process__c,Response_Format__c,
                    //Added two new Case field  RPQ_Status__c,Assigned_Service_Group__c field
                    //Commented to Exclude the Assigned_Service_Group__c field
                    //Response_Within_SLA__c,Required_Fields_Populated__c,RPQ_Status__c,Assigned_Service_Group__c from Case where Id = :parentId or Id=:caseId];
                     //Added New Fields Related To Partner
                    Response_Within_SLA__c,Required_Fields_Populated__c,RPQ_Status__c,Partner_Case__c,Partner_Country__c,Partner_Grouping_Name__c,Partner_Theater__c,
                    Inquiry_Type__c, EDS_Contact_Email__c,Case_Resolution_Detail__c,SuppliedEmail
                     from Case where Id = :parentId or Id=:caseId];
           
                        
    }
    public PageReference createChildCase(){
        
        integer checkIFClone = caseURL.indexOf('flag=1');
        system.debug('index value--->'+checkIFClone);
       // setvalue(value);
        Case childCase = new Case();
        childCase = caseRecord.clone(false);
        system.debug('record type id--->'+value);
        childCase.RecordTypeId = value;
        childCase.Validation_check_for_TC__c = true;
        /*childCase.AccountId = caseRecord.AccountId;
        //childCase.Status= caseRecord.Status;
        childCase.Subject= caseRecord.Subject;
        childCase.Description= caseRecord.Description;
        childCase.Type= caseRecord.Type;
        childCase.Applications__c= caseRecord.Applications__c;
        childCase.Area__c= caseRecord.Area__c;
        childCase.Business_Unit__c= caseRecord.Business_Unit__c;
        childCase.Competitor_Models__c= caseRecord.Competitor_Models__c;
        childCase.Competitors__c= caseRecord.Competitors__c;
        //childCase.Contact_Email1__c= caseRecord.Contact_Email1__c;
        childCase.Contact_Phone1__c= caseRecord.Contact_Phone1__c;
        childCase.Country__c= caseRecord.Country__c;
        childCase.Customer2_Service_Requirements__c= caseRecord.Customer2_Service_Requirements__c;
        childCase.Division__c= caseRecord.Division__c;
        childCase.Customer_Account_Name__c= caseRecord.Customer_Account_Name__c;
        childCase.Discount_Product_Class__c= caseRecord.Discount_Product_Class__c;
        childCase.District__c= caseRecord.District__c;
        childCase.Engineering_Contact__c= caseRecord.Engineering_Contact__c;
        //childCase.Escalation__c= caseRecord.Escalation__c;
        childCase.Host_Server_Environment__c= caseRecord.Host_Server_Environment__c;
        childCase.MWD_Incident_Number__c= caseRecord.MWD_Incident_Number__c;
        childCase.Number_of_Configurations__c= caseRecord.Number_of_Configurations__c;
        childCase.Opportunity_Name__c= caseRecord.Opportunity_Name__c;
        childCase.Order_Number__c= caseRecord.Order_Number__c;
        childCase.Parts_Missing_Wrong_Damaged__c= caseRecord.Parts_Missing_Wrong_Damaged__c;
        childCase.PAS_Number__c= caseRecord.PAS_Number__c;
        childCase.Product_Name__c= caseRecord.Product_Name__c;
        childCase.QA_Comments__c= caseRecord.QA_Comments__c;
        childCase.Quote_Type__c= caseRecord.Quote_Type__c;
        childCase.RPQ_Deal_Value__c= caseRecord.RPQ_Deal_Value__c;
        childCase.SoW_Document_Number__c= caseRecord.SoW_Document_Number__c;
        childCase.T_E_Price__c= caseRecord.T_E_Price__c;
        childCase.Theatre__c= caseRecord.Theatre__c;
        childCase.Tools__c= caseRecord.Tools__c;
        childCase.Case_Completed_STD_Process__c= caseRecord.Case_Completed_STD_Process__c;
        childCase.Was_the_resolui__c= caseRecord.Was_the_resolui__c;
        childCase.Response_Format__c= caseRecord.Response_Format__c;
        childCase.Was_the_response_timely__c= caseRecord.Was_the_response_timely__c;
        childCase.Response_Within_SLA__c= caseRecord.Response_Within_SLA__c;
        childCase.Required_Fields_Populated__c= caseRecord.Required_Fields_Populated__c;*/
        if(checkIFClone==-1){
            childCase.ParentId = caseRecord.Id; 
        }
        else{
            childCase.ParentId = null;
        }    
        //stdCon.save();
        try {
        insert childCase;
        system.debug('inserted case--->'+childCase);
        }
        catch(System.DmlException e){
            System.debug('DML exception while Inserting Child Case: ' + e.getDmlMessage(0));   
        }
        
        PageReference childCaseURL = new PageReference('/'+childCase.id+'/e?retURL=%2F'+childCase.id);
        return childCaseURL;
        
    }
    
    /*public List<SelectOption> getItems()
    {
        List<SelectOption> items = new List<SelectOption>();
        items.add(new SelectOption('','--Select Case Type --'));
        List<RecordType> rt= [select id,name from recordtype where isactive=true and developername like 'Presales%'];
            for(RecordType loopVariable: rt){
                items.add(new SelectOption(loopVariable.id,loopVariable.name));
            }
            
        return items;
    
    }*/
}