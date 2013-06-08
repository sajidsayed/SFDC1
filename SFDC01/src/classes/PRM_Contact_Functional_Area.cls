/*=====================================================================================================================================

History 
DATE            DEVELOPER                WR             DESCRIPTION                               
====            =========                ==             =========== 
22 April  12    Anirudh Singh           189799          This class is used to for the Contact Functional Area Updates
02 Aug    12    Ganesh                  196693          Reverted Multiple Theaters functionality of EMCBusinessRule
15/11/2012      vivek kodi              197607          To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
============================================================================================================================================*/
public class PRM_Contact_Functional_Area{

/* @Method <This method is written to update the Functional Aread for all the contacts>.
       @param  <This is taking a list of Contact object records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
*/
    public static void contactFunctionalAreaUpdate(list<Contact> lstPartnerContacts,string Batchid,List<EMCException> emailerrors)
    {
        System.Debug('lstPartnerContacts---->' +lstPartnerContacts);
        Map<String,List<EMC_Business_Rules__c>> mapTheaterWiseFunctionalAreaRule=new Map<String,List<EMC_Business_Rules__c>>();
        Map<Id,List<EMC_BR_Education_Group_Record__c>> mapFuntionalAreaWithEducationGroupRecords=new Map<Id,List<EMC_BR_Education_Group_Record__c>>();
        Map<Id,List<Id>> mapContactWithEduMaster= new Map<Id,List<Id>>();   
        Map<Id,List<Id>> mapContactWithEducationGroup = new Map<Id,List<Id>>(); 
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();         
        CustomSettingDataValueMap__c FA_EMC_BR_RecordtypeId = (mapCustomSettingDataValueMap.get('PRM_FA_EMC_BR_Rec_Type'));   
        String strFAEMCBRRecordtypeId = FA_EMC_BR_RecordtypeId.DataValue__c;
        Set<String> contactfunctionalArea=new set<string>();
        string finalFunctionalArea;
        
       
        List<EMC_Business_Rules__c> lstFunctionalAreaRules=[select id,AND_OR__c,name,Functional_Area__c,Field_Name__c,Theater__c,weight__c,Maximum_Score__c,unit__c,(SELECT Group__c,Name,Speciality_Rule__c FROM Rule_Groups__r) from EMC_Business_Rules__c where recordtypeid=:strFAEMCBRRecordtypeId  order by Theater__c];
        if(lstFunctionalAreaRules!=null && lstFunctionalAreaRules.size()>0)
        {            
            for(EMC_Business_Rules__c faRule:lstFunctionalAreaRules)
            {   List<EMC_Business_Rules__c> lstTempBusinessRules;
                List<EMC_BR_Education_Group_Record__c> lstTempEduGroupRecords= faRule.Rule_Groups__r;
                lstTempBusinessRules=mapTheaterWiseFunctionalAreaRule.get(faRule.Theater__c);
                if(lstTempBusinessRules==null){
                    lstTempBusinessRules=new list<EMC_Business_Rules__c>();
                }
                lstTempBusinessRules.add(faRule);
                mapTheaterWiseFunctionalAreaRule.put(faRule.Theater__c,lstTempBusinessRules);
                if(!mapFuntionalAreaWithEducationGroupRecords.containsKey(faRule.Id))
                    {
                        mapFuntionalAreaWithEducationGroupRecords.put(faRule.Id,lstTempEduGroupRecords);
                    }                
            }
        } 
            
        
        /*
        //Added by Ganesh   
        List<EMC_Business_Rules__c> lstFunctionalAreaRules=[select id,AND_OR__c,name,Functional_Area__c,Field_Name__c,Theater__c,weight__c,Maximum_Score__c,unit__c,(SELECT Group__c,Name,Speciality_Rule__c FROM Rule_Groups__r) from EMC_Business_Rules__c where recordtypeid=:strFAEMCBRRecordtypeId];   
        String[] arrTheaters = new String[]{}; 
        if(lstFunctionalAreaRules!=null && lstFunctionalAreaRules.size()>0)
        {            
            for(EMC_Business_Rules__c faRule:lstFunctionalAreaRules)
            {            	
            	//split the theater's, if more than one is prestent in Theater__c field  	
            	if(faRule.Theater__c!=null)            	
            	arrTheaters =  faRule.Theater__c.split(';');            
            	
            	if(arrTheaters.size()>0)
            	{
            		//Iterate through each theater 
	            	for(string theater:arrTheaters)
	            	{            	
                        List<EMC_Business_Rules__c> lstTempBusinessRules;
		                List<EMC_BR_Education_Group_Record__c> lstTempEduGroupRecords= faRule.Rule_Groups__r;
		                lstTempBusinessRules=mapTheaterWiseFunctionalAreaRule.get(theater);
		                if(lstTempBusinessRules==null){
		                    lstTempBusinessRules=new list<EMC_Business_Rules__c>();
		                }
		                lstTempBusinessRules.add(faRule);
		                mapTheaterWiseFunctionalAreaRule.put(theater,lstTempBusinessRules);
		                if(!mapFuntionalAreaWithEducationGroupRecords.containsKey(faRule.Id)){
		                    mapFuntionalAreaWithEducationGroupRecords.put(faRule.Id,lstTempEduGroupRecords);
		                }                     
	            	}                           
                }
            }         
        }
        */ 
           
        list<Contact> lstContactToUpdate=new list<Contact>();
        List<Education__c> lstEducation=new List<Education__c>();        
        Set<Id> setEducationMasterIds=new Set<Id>();
        Database.SaveResult[] results; 
        List <EMCException> errors = new List <EMCException>();              
        List<Education_Group_Member__c> lstEducationMasterEducationGroup=new List<Education_Group_Member__c>();
        Map<Id,List<Id>> mapEducationMasterEducationGroup=new Map<Id,List<Id>>();
        if(lstPartnerContacts!=null && mapTheaterWiseFunctionalAreaRule!=null && lstPartnerContacts.size()>0 && mapTheaterWiseFunctionalAreaRule.size()>0)
        {          
         lstEducation=[select id,contact__c,type__c,category__c,level__c,Education_Master__c,Education_Master__r.name from education__c where contact__c in :lstPartnerContacts order by              contact__c];            
            if(lstEducation!=null && lstEducation.size()>0)
            {
             for(Education__c eduObj:lstEducation)
                {
                    setEducationMasterIds.add(eduObj.Education_Master__c);
                    List<Id> lstTemp;                   
                    lstTemp=mapContactWithEduMaster.get(eduObj.contact__c);                        
                    if(lstTemp==null)
                    {
                        lstTemp=new List<Id>();
                    }
                    lstTemp.add(eduObj.Education_Master__c);
                    mapContactWithEduMaster.put(eduObj.contact__c,lstTemp);                        
                }                
                lstEducationMasterEducationGroup=[SELECT id,name,Education_Group__c, Education_Master__c FROM Education_Group_Member__c where Education_Master__c in :setEducationMasterIds                                  order by Education_Master__c];
            }
            if(lstEducationMasterEducationGroup!=null && lstEducationMasterEducationGroup.size()>0)
            {
                for(Education_Group_Member__c eduGroupMemberObj:lstEducationMasterEducationGroup)
                {    
                    List<Id> lstEducationGroupIds; 
                    lstEducationGroupIds= mapEducationMasterEducationGroup.get(eduGroupMemberObj.Education_Master__c);
                    if(lstEducationGroupIds==null)
                    {
                        lstEducationGroupIds=new list<Id>();   
                    }
                    lstEducationGroupIds.add(eduGroupMemberObj.Education_Group__c);
                    mapEducationMasterEducationGroup.put(eduGroupMemberObj.Education_Master__c,lstEducationGroupIds);
                }                
            }
            if(mapEducationMasterEducationGroup.size()>0 && mapContactWithEduMaster.size()>0){
                
                for(id conId :mapContactWithEduMaster.keyset()){
                    list<Id> lstEducationGrpId = new list<Id>();
                    for(id masterid :mapContactWithEduMaster.get(conId)){
                        list<id> lstTempEducationGrpId = new List<Id>();
                        lstTempEducationGrpId =mapEducationMasterEducationGroup.get(masterid);
                        if(lstTempEducationGrpId!=null && lstTempEducationGrpId.size()>0){
                            for(Id tempEduGrpId :lstTempEducationGrpId){
                                lstEducationGrpId.add(tempEduGrpId);
                            }
                        }
                    }
                    mapContactWithEducationGroup.put(conId,lstEducationGrpId);
                }
            }           
            for(Contact contObj:lstPartnerContacts)
            {
                System.Debug('exsitingFunctionalAreabeforeIf--->'+contObj.Functional_Area1__c);
                if(mapContactWithEducationGroup.containsKey(contObj.id) && mapTheaterWiseFunctionalAreaRule.size()>0)
                {
                    contactfunctionalArea=evaluateFunctionalArea(mapContactWithEducationGroup.get(contObj.id),mapTheaterWiseFunctionalAreaRule.get(contObj.Account_Theater__c),mapFuntionalAreaWithEducationGroupRecords);
                    System.Debug('contactfunctionalAreaReturned--->'+contactfunctionalArea);
                    System.Debug('exsitingFunctionalArea--->'+contObj.Functional_Area1__c);
                    if(contactfunctionalArea!=null){
                      
                         for(string toAddFunctArea :contactfunctionalArea){
                             if(contObj.Functional_Area1__c!=null){
                                 if(!contObj.Functional_Area1__c.contains(toAddFunctArea)){
                                    contObj.Functional_Area1__c= contObj.Functional_Area1__c+';'+toAddFunctArea;
                                 }
                                 if(contObj.Functional_Area1__c.contains('Pre-Sales') && toAddFunctArea =='Sales' && !contObj.Functional_Area1__c.contains(';Sales')){
                                    contObj.Functional_Area1__c= contObj.Functional_Area1__c+';'+toAddFunctArea;
                                 }
                                 
                         }
                         if(contObj.Functional_Area1__c==null){
                             contObj.Functional_Area1__c=toAddFunctArea;
                         }
                       }
                   }
                       
                }
                
                lstContactToUpdate.add(contObj);
                
            }
            if(lstContactToUpdate!=null && lstContactToUpdate.size()>0)
            {
               results = Database.update(lstContactToUpdate,false);
            }
            
             /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }		       
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors); 
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors); 
		        }
            
            
        }
    }
    
/* @Method <This method is written to evaluate Functional Area of contact based on Business Rules>.
       @param  <This is taking a list of education object records,weight and max score as arguments>
       @return  - <return string value>  
       @throws exception - <No Exception>
*/
    public static set<string> evaluateFunctionalArea(List<Id> lstEducationGrpId,List<EMC_Business_Rules__c> lstFunctionalAreaRule,Map<Id,List<EMC_BR_Education_Group_Record__c>> mapFuntionalAreaWithEducationGroupRecords)
    {
        set<string> functionalAreaSet = new set<String>();
        set<Id> setBusinessRuleEducationGrp;
        set<Id> setNonMatchedEducationGroups=new Set<Id>();        
        if(lstEducationGrpId!=null && lstEducationGrpId.size()>0)
        {
            for(EMC_Business_Rules__c FARule:lstFunctionalAreaRule)
            {   
                setBusinessRuleEducationGrp=new set<id>();
                for(EMC_BR_Education_Group_Record__c EduBRGrp :mapFuntionalAreaWithEducationGroupRecords.get(FARule.Id)){
                        setBusinessRuleEducationGrp.add(EduBRGrp.Group__c);
                }
                if(FARule.AND_OR__c=='AND'){                   
                   for(Id ConEducGrpId :lstEducationGrpId){
                        if(!setBusinessRuleEducationGrp.contains(ConEducGrpId)){
                            setNonMatchedEducationGroups.add(ConEducGrpId);
                        }
                   }
                   if(setNonMatchedEducationGroups.size()==0){
                      functionalAreaSet.add(FARule.Functional_Area__c);
                   }
                   
                }
                if(FARule.AND_OR__c=='OR'){                
                   for(Id ConEducGrpId :lstEducationGrpId){
                        if(setBusinessRuleEducationGrp.contains(ConEducGrpId)){
                            functionalAreaSet.add(FARule.Functional_Area__c);
                        }
                   }
                   
                   
                }
                
            }
            
        }
         System.Debug('functionalAreaSettoReturn---->'+functionalAreaSet);       
        return functionalAreaSet;
    }
 }