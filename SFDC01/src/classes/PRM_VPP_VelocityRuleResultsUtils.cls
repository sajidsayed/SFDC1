global Class PRM_VPP_VelocityRuleResultsUtils{

//@future  webService 
public static void deleteVelocityRuleResults(List<Id> velocityRulesIds){
   list<Id> listRuleIds = new list<Id>();
   if(velocityRulesIds!=null && velocityRulesIds.size()>0){
      listRuleIds = velocityRulesIds;
      System.debug('listRuleIds.size()--->' +listRuleIds.size());
   List<Velocity_Rule_Results__c> listVRR = [SELECT v.Speciality_RuleID__c, v.Id 
                                               FROM Velocity_Rule_Results__c v  
                                               WHERE Speciality_RuleID__c IN : listRuleIds ];
    if(listVRR.size() >0){
      Database.DeleteResult[] resultVelocityRuleResult = Database.delete(listVRR);
     }
   } //End of IF condition.
 } //End of method.
 
 Public static void deleteVelocityRuleResults(List<Account> accounts){
   set<Id> setaccountIds = new set<Id>();
   if(accounts.size()>0){
     for(Account acc : accounts) {
       setaccountIds.add(acc.Id);
     }
   List<Velocity_Rule_Results__c> listVRR = [SELECT v.AccountID__c, v.Id 
                                               FROM Velocity_Rule_Results__c v  
                                               WHERE AccountID__c IN : setaccountIds];
    if(listVRR.size() >0){
     Database.DeleteResult[] resultVelocityRuleResult = Database.delete(listVRR);
     }  
    }
  } //End of method.

 Public static void checkVelocityRuleUpdate(List<Velocity_Rules__c> listVelocityRules_new,List<Velocity_Rules__c> listVelocityRules_old){
   List<Velocity_Rules__c> listVelocityRules = new List<Velocity_Rules__c>();
   List<Id> listRuleIds = new List<ID>();
   for(Integer i=0;i<listVelocityRules_new.size();i++){
      if( (listVelocityRules_new[i].Specialty_Rule_Type__c != listVelocityRules_old[i].Specialty_Rule_Type__c)
             ||(listVelocityRules_new[i].Cluster__c != listVelocityRules_old[i].Cluster__c) ){
         listRuleIds.add(listVelocityRules_new[i].id);
         listVelocityRules.add(listVelocityRules_new[i]);
      }
    }
    deleteVelocityRuleResults(listRuleIds);
    
  } //End of method - checkVelocityRuleUpdate   
  
  public static void createEducationAndEducationGroupMapping(List<Education__c> lstEducation){
        
        Set<Id> setEducationMasterIds= new Set<Id>();
        Map<Id, Set<Id>> mapEducationMasterGroup = new Map<Id, Set<Id>>();
        Education_EducationGroup_Mapping__c objEduGroupMapping = new Education_EducationGroup_Mapping__c();
        List<Education_EducationGroup_Mapping__c> lstEduGroupMapping = new List<Education_EducationGroup_Mapping__c>();
        for(Education__c objEducation : lstEducation){
            if(objEducation.Education_Master__c != null){
                setEducationMasterIds.add(objEducation.Education_Master__c);
            }
        }
        
        if(setEducationMasterIds.size()> 0){
            Map<Id, Education_Group_Member__c> mapEducationGroup = new map<Id, Education_Group_Member__c>(
                                            [Select Education_Group__c, Education_Master__c,Id, Name from Education_Group_Member__c 
                                            Where Education_Master__c in :setEducationMasterIds
                                            ]);
                                            
            if(mapEducationGroup.size() >0){
                for(Education_Group_Member__c objEduGroup : mapEducationGroup.values()){
                    if(mapEducationMasterGroup.containsKey(objEduGroup.Education_Master__c)){
                        mapEducationMasterGroup.get(objEduGroup.Education_Master__c).add(objEduGroup.Education_Group__c);
                    }else{
                        mapEducationMasterGroup.put(objEduGroup.Education_Master__c, new Set<Id>());
                        mapEducationMasterGroup.get(objEduGroup.Education_Master__c).add(objEduGroup.Education_Group__c);
                    }
                }               
            }                                           
        }
        
        for(Education__c objEducation : lstEducation){                  
            if(objEducation.Education_Master__c != null ){
                Set<Id> setEducationGroup = mapEducationMasterGroup.get(objEducation.Education_Master__c);
                if(setEducationGroup!=null && setEducationGroup.size()>0){
                    for(Id groupid :setEducationGroup){
                        objEduGroupMapping = new Education_EducationGroup_Mapping__c();
                        objEduGroupMapping.Education__c = objEducation.Id;
                        objEduGroupMapping.Education_Group__c = groupid; 
                        lstEduGroupMapping.add(objEduGroupMapping); 
                    }
                }                               
            }
        }
        
        if(lstEduGroupMapping.size() >0){
            System.Debug('Education mapping lstEduGroupMapping :: ' + lstEduGroupMapping); 
            Database.SaveResult[] srResult = Database.insert(lstEduGroupMapping, false);
            logFailedRecords(srResult);
        }
  } // End of method -createEducationAndEducationGroupMapping
 
 /*@Method <deleteEducationAndEducationGroupMapping(): This method will be called for 
                                                       deleting EducationAndEducationGroupMapping records
                                                       based on List of Ids.>
       @param - List<Account>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
 */  
 public static void deleteEducationAndEducationGroupMapping(List<Id> listEducationIds){
     if((listEducationIds!= Null) && (listEducationIds.size()>0)){
   List<Education_EducationGroup_Mapping__c> educationMappingList =
                                             [SELECT ID,name 
                                                FROM Education_EducationGroup_Mapping__c
                                                WHERE Education__c IN :listEducationIds];
     Database.DeleteResult[] resultEducationMapping = Database.delete(educationMappingList);                                                        
    }
  }// End of method -deleteEducationAndEducationGroupMapping.

 public static void logFailedRecords(Database.Saveresult[]resultrecords){
 	    List <EMCException> errors = new List <EMCException>();
         for( Database.Saveresult sr : resultrecords) {
            String dataErrs = '';
            if (!sr.isSuccess()) {
               // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + sr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, 'ERROR_VELOCITY_RULE_EVALUATION', new String [] {sr.getId()}));
            }
          }  
      // log any errors that occurred
       if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
       } 
   }  
    
  /*
  public static boolean validationEducationAndEducationGroupMapping(Set<Id> setEduMasterIds, set<Id> setGroupIds){
    Boolean checkmappingRecord = false;
    Map<Id, Education_Group_Member__c> mapEducationGroup = new map<Id, Education_Group_Member__c>(
                                            [Select Education_Group__c, Id, Name from Education_EducationGroup_Mapping__c 
                                            Where Education_Master__c in :setEduMasterIds AND Education_Group__c in: setGroupIds
                                            ]);
                                            
    if(mapEducationGroup.size() > 0){
        checkmappingRecord = true;
    }                                           
    return checkmappingRecord;
  }
  */
}