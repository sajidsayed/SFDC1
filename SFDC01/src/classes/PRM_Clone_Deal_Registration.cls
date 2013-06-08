/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR       DESCRIPTION                               

 |  ====          =========          ==       =========== 

 |  9/5/2012     Anirudh Singh      189663    This class will allow designated internal
                                              EMC users to clone DealRegistrations and it's
                                              associated Registration Products  
 |  18-Oct-2012  Raghunath Utpala			  Synergy Lead Id for the Clone DR is set to null.  
 |  03-May-2013	 Krishna Pydavula	232602    Assigning null values for three fields. 	                                                                                                                        
 +=======================================================================================================================**/

global class PRM_Clone_Deal_Registration {
    
/*@Method <cloneRegistrationProduct(): This Method would create copy of Registration
                                    Products for Submitted Deal Registration being cloned.>
@param - <This method is taking list of cloned DealRegistrations as input parameters>
@return - <None>
@throws exception - <No Exception>
*/
     public void cloneRegistrationProduct(List<Lead> triggerList){                
        String StrParentDealId=''; 
        Map<Id,Id>ParentDealWithClonedDealId = new Map<Id,Id>();              
        for(Lead dealObj :triggerList){
            if(StrParentDealId==''){
                StrParentDealId='\''+dealObj.Parent_Deal_Registration__c;
            }else{
                StrParentDealId=StrParentDealId+'\',\''+dealObj.Parent_Deal_Registration__c;    
            }
            ParentDealWithClonedDealId.put(dealObj.Parent_Deal_Registration__c,dealObj.Id);
        }
       StrParentDealId=StrParentDealId+'\'';
       Map<Id,Lead> mapSubmittedDeal = new map<Id,Lead>([Select id,Name,DealReg_Deal_Registration_Status__c from Lead where id in
                                                        :ParentDealWithClonedDealId.keyset()]);      
       Map<String, Schema.SObjectField> RegistrationProductFieldMap = Schema.SObjectType.Registration_Product__c.fields.getMap();
       String fields='';
       for(String name :RegistrationProductFieldMap.keySet()){
            if(name.toLowerCase()=='id') continue;
            if(fields==''){
                fields=name;
            }else{
                fields=fields+','+name;    
            }
        }      
       String registrationProductQuery='Select '+fields + ' from Registration_Product__c where Deal_Registration__c in ('+StrParentDealId + ')';
       List<Registration_Product__c> RegistrationProduct = Database.query(registrationProductQuery);
       List<Registration_Product__c> ClonedRegistrationProduct = new List<Registration_Product__c>(); 
       if(RegistrationProduct.size()>0){
           
           for(Registration_Product__c item: RegistrationProduct){
               if(mapSubmittedDeal.containskey(item.Deal_Registration__c)){
                   Registration_Product__c obj=item.clone(false,false,false,false);                              
                   obj.Deal_Registration__c = ParentDealWithClonedDealId.get(obj.Deal_Registration__c);   
                   obj.OwnerId=UserInfo.getUserId();             
                   ClonedRegistrationProduct.add(obj);
               }
               
           }
           insert ClonedRegistrationProduct;
       }
     }       
     
     
     /*@Method <cloneRegistrationProductForPartners(): This is a webservice Method which is taking a deal id
                                                        and creating a clone and nullifies field values.>
    @param - <This method is taking a deal registration id as input parameters>
    @return - <None>
    @throws exception - <No Exception>
    */
     webservice static string cloneDealRegistration(Id ParentDealId){        
        
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
        string status='';
        CustomSettingDataValueMap__c DealRegSubmittedRecType = (mapCustomSettingDataValueMap.get('DealRegistrationSubmittedRecordType'));           
        String strRecType = DealRegSubmittedRecType.DataValue__c;        
        Map<String, Schema.SObjectField> LeadFieldsMap = Schema.SObjectType.Lead.fields.getMap();
        
       String fields='';
       for(String name :LeadFieldsMap.keySet()){
       	system.debug('schema keyset'+LeadFieldsMap.keySet());
            if(name.toLowerCase()=='id') continue;
            system.debug('name'+name.toLowerCase());
            if(fields==''){
                fields=name;
                system.debug('if condition'+fields);
            }else{            	 
                fields=fields+','+name;    
                system.debug('else condition'+fields);
            }
        }
        String DealRegistrationtQuery='Select '+fields + ' from Lead where id ='+'\''+ParentDealId +'\'';
        Lead ParentDeal = Database.Query(DealRegistrationtQuery);
        Lead leadObj = ParentDeal.clone(false,false,false,false);
        //code added for "Synergy Lead Id for the Clone DR is set to null."
        leadObj.Synergy_Lead_ID__c=null;
        //End of the code  for "Synergy Lead Id for the Clone DR is set to null."
        leadObj.Parent_Deal_Registration__c=ParentDeal.Id;        
        leadObj.DealReg_Deal_Registration_Type__c='Base';
        leadObj.DealReg_Submission_Source__c='Partner Central';
        leadObj.Partner_Campagin_Ref_ID__c=null;
        leadObj.Campaign_Event_Name__c=null;
        LeadObj.Deal_Reg_to_link__c=null;
        leadObj.External_Comments__c=null;
        leadObj.DealReg_Rejection_Reason__c=null;
        leadObj.DealReg_PSC_SLA_Expire_On__c=null;
        leadObj.DealReg_Field_SLA_Expire_on__c=null;
        leadObj.DealReg_Submission_Date__c=null;
        leadObj.DealReg_PSC_Approval_Rejection_Date_Time__c=null;
        leadObj.DealReg_Expiration_Date__c=null;
        leadObj.Related_Opportunity__c=null;
        leadObj.DealReg_Create_New_Opportunity__c=false;
        leadObj.DealReg_PSC_Owner__c=null;
        leadObj.Deal_Reg_TRACK_Owner__c=null;
        leadObj.DealReg_Handoff_to_TRACK__c=false;
        leadObj.Approved_to_Closed_Expired_Date_Time__c=null;
        leadObj.Related_Account_Populated_Date_Time__c=null;
        leadObj.Lead_Converted_to_DR_Date_Time__c=null;
        leadObj.Deal_Field_Approval_Rejection_Date_Time__c=null;
        leadObj.DealReg_of_Extension_Requests__c=0;
        leadObj.DealReg_Expected_Close_Date__c=null;
        leadObj.EMC_Convert_To_Deal_Reg__c=false;
        leadObj.Aprimo_Lead_ID__c=null;
        leadObj.DealReg_Deal_Registration_Status__c='New';
        leadObj.status='New';
        leadObj.recordtypeid=strRecType;
        leadObj.OwnerId=UserInfo.getUserId();
        //Added by Krishna for WR 232602
        leadObj.Original_Submission_Time__c=null;
        leadObj.Partner_Manager__c=null;
        leadObj.Additional_Notification_Email_1__c=null;
        try{       
            insert leadObj;
            status=leadObj.Id;        
        }
        catch(DMLException ex){
            status = 'Error : '+ ex.getMessage();
            if(status.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                status = status.substring(status.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
            }
            if(status.endsWith(': []')){
                status = status.substring(0, status.length() -4);

            }
        }
        return status;
     }
     
     
}