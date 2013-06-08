/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |
 |   05/08/2012    Prasad                       This class is basically for identifiying the delta. 
 |   13-Sep-2012   Prasad                       Added delta for all VPP related jobs - PAN,PL,Funcational Area
 |   26-Sep-2012   Prasad                       Fixed defect #945, bypassed updating the "PorcessOnAfeter" logic on update 
                                                "Specilities acheived" and "Tier deployed to". Added on exsting logic for inactive
     10-Sep-2012   Prasad                       Fix duplicate Id issue - Grouping Id geting added multiple times - 
                                                1)Fix on account delta marking
                                                2)Fix on MarkGrouping
 +==================================================================================================================*/
public class PRM_VPP_DeltaIdentifer { 
    
    
    public static boolean ProcessOnAfterUpdating=false;
    
   public void deltaRevenueMarking(Map<Id,Revenue__c>oldRevenueMap,Map<Id,Revenue__c>newRevenueMap ){
       Set<Id>GroupingID_Set = new Set<Id>();
       Set<Id>AccountID_Set = new Set<Id>();
       Education__c OldEdu;
       
       // Delete Trigger
       if(newRevenueMap==null){
            for(Revenue__c UpdatedRevenue : oldRevenueMap.values()){
              AccountID_Set.add(UpdatedRevenue.account__c);
              //GroupingID_Set.add(UpdatedRevenue.Grouping__c);             
            }
       }
       
       // New Trigger
       if(oldRevenueMap==null){
            for(Revenue__c UpdatedRevenue : newRevenueMap.values()){
              AccountID_Set.add(UpdatedRevenue.account__c);
              //GroupingID_Set.add(UpdatedRevenue.Grouping__c);             
            }
       }
       
       //Update Trigger
       if(oldRevenueMap!=null && newRevenueMap!=null){
           Revenue__c OldRevenue;
           Map<String, Schema.SObjectField> RevenueFields = Schema.SObjectType.Revenue__c.fields.getMap();
           
           Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();             
           CustomSettingDataValueMap__c EducationDeltaFieldsToSkip =DataValueMap.get('PRM_VPP_Revenue_NON_Delta_Fields');
           String  fieldsToSkip =(EducationDeltaFieldsToSkip.DataValue__c);
            
           for(Revenue__c UpdatedRevenue : newRevenueMap.values()){
               OldRevenue=oldRevenueMap.get(UpdatedRevenue.id);
               for(String fieldName: RevenueFields.keySet()){    
                    if( fieldName.indexOf('__c')!=-1 && fieldsToSkip.indexOf(fieldName)==-1 &&  OldRevenue.get(fieldName) !=UpdatedRevenue.get(fieldName)){
                            AccountID_Set.add(UpdatedRevenue.account__c);
                            AccountID_Set.add(OldRevenue.account__c);
                            //GroupingID_Set.add(UpdatedRevenue.Grouping__c);
                            //GroupingID_Set.add(OldRevenue.Grouping__c);
                    }          
                }
           }
       }
       if(AccountID_Set.size()>0){
            for(account acc: [select id, grouping__c from account where id in:AccountID_Set]){
                GroupingID_Set.add(acc.Grouping__c);
            }
       }
       if(GroupingID_Set.size()>0){
            MarkGroupings(GroupingID_Set);
        }
      }
   
    public void deltaAccountMarking(Map<Id,Account>oldAccountMap,Map<Id,Account>newAccountMap ){
        System.debug('ProcessOnAfterUpdating '+ProcessOnAfterUpdating);
        if(ProcessOnAfterUpdating){
            return;
        }
        
        //Update Trigger
         Set<Id>GroupingID_Set = new Set<Id>();
         Account oldeAcc;
       if(oldAccountMap!=null && newAccountMap!=null){
             for(Account newAcc:newAccountMap.values()){
                oldeAcc=oldAccountMap.get(newAcc.id);   
                
                //Check value updated for education master
                if(  
                        (oldeAcc.profiled_Account_flag__c!=newAcc.profiled_Account_flag__c  && !ProcessOnAfterUpdating) ||
                        (oldeAcc.Grouping__c!=newAcc.Grouping__c  && !ProcessOnAfterUpdating )||
                        oldeAcc.Theater1__c!=newAcc.Theater1__c ||
                        oldeAcc.Cluster__c!=newAcc.Cluster__c ||
                        oldeAcc.Specialty_Rule_Type__c!=newAcc.Specialty_Rule_Type__c || 
                        oldeAcc.Velocity_Services_Implement__c!=newAcc.Velocity_Services_Implement__c ||
                        oldeAcc.Solution_Center_Implemented__c!=newAcc.Solution_Center_Implemented__c ||
                        oldeAcc.Advanced_Consolidate_Compliance_Status__c!=newAcc.Advanced_Consolidate_Compliance_Status__c ||
                        oldeAcc.Backup_and_Recovery_Compliance_Status__c!=newAcc.Backup_and_Recovery_Compliance_Status__c ||
                        oldeAcc.Consolidate_Compliance_Status__c!=newAcc.Consolidate_Compliance_Status__c ||
                        oldeAcc.Governance_and_Archive_Compliance_Status__c!=newAcc.Governance_and_Archive_Compliance_Status__c ||
                        oldeAcc.Velocity_Compliance_Status__c!=newAcc.Velocity_Compliance_Status__c ||
                        oldeAcc.Deployed_Velocity_Services__c!=newAcc.Deployed_Velocity_Services__c ||
                        
                          ( newAcc.Account_Level__c=='COUNTRY'  && 
                        
                            (    
                                 oldeAcc.Velocity_Solution_Provider_Tier__c != oldeAcc.Velocity_Solution_Provider_Tier__c ||
                                 oldeAcc.Cloud_Builder_Practice__c != oldeAcc.Cloud_Builder_Practice__c ||
                                 oldeAcc.Cloud_Provider_Practice__c != oldeAcc.Cloud_Provider_Practice__c ||
                                 oldeAcc.Consolidate_Specialty__c != oldeAcc.Consolidate_Specialty__c ||
                                 oldeAcc.Advanced_Consolidate_Specialty__c != oldeAcc.Advanced_Consolidate_Specialty__c ||
                                 oldeAcc.Backup_and_Recovery_Speciality__c != oldeAcc.Backup_and_Recovery_Speciality__c ||
                                 oldeAcc.Governance_and_Archive_Specialty__c != oldeAcc.Governance_and_Archive_Specialty__c
                            )
                        
                           )
                         ){
                            GroupingID_Set.add(newAcc.Grouping__c);
                            GroupingID_Set.add(oldeAcc.Grouping__c);        
                    }
             } 
       }
       if(GroupingID_Set.size()>0){
            MarkGroupings(GroupingID_Set);
        }
   }
   
   
   public void deltaEducationMarking(Map<Id,Education__c>oldEducationMap,Map<Id,Education__c>newEducationMap ){
       Set<Id>GroupingID_Set = new Set<Id>();
       Set<ID> ContactIds = new Set<ID>();
       Map<Id,Education__c> EducationForMappings = new Map<Id,Education__c>();
       Education__c OldEdu;
       
       // Delete Trigger
       if(newEducationMap==null){
            for(Education__c UpdatedEdu :oldEducationMap.values()){           
                ContactIds.add(UpdatedEdu.contact__c); 
                          
            }
            // Delete Education_EducationGroupings
            List<Id>lstEducationIds =new List<Id>(oldEducationMap.keySet());
            PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(lstEducationIds);
       }
       
       // New Trigger
       if(oldEducationMap==null){
            for(Education__c UpdatedEdu :newEducationMap.values()){
              
                ContactIds.add(UpdatedEdu.contact__c); 
                          
            }  
            //create Education_EducationGroupings
            PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(newEducationMap.values());
       }
       
       //Update Trigger
       if(oldEducationMap!=null && newEducationMap!=null){
            Map<String, Schema.SObjectField> EducationFields = Schema.SObjectType.Education__c.fields.getMap();
            Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
            CustomSettingDataValueMap__c EducationDeltaFieldsToSkip =DataValueMap.get('PRM_VPP_Education_NON_Delta_Fields');
            String  fieldsToSkip =(EducationDeltaFieldsToSkip.DataValue__c);
                 
             for(Education__c newedu:newEducationMap.values()){
                oldedu=oldEducationMap.get(newedu.id);  
                for(String fieldName: EducationFields.keySet()){
                    if( fieldName.indexOf('__c')!=-1 && fieldsToSkip.indexOf(fieldName)==-1 && (oldedu.get(fieldName))!=(newedu.get(fieldName))){
                        ContactIds.add(newedu.contact__c);
                        ContactIds.add(oldedu.contact__c);  
                        newedu.Delta_Fields__c=newedu.Delta_Fields__c+' ;'+fieldName;   
                    }   
                } 
                //Check value updated for education master
                if(  oldedu.Education_Master__c!=newedu.Education_Master__c){
                        EducationForMappings.put(newedu.id,newedu);         
                    }
             }
       }
       if(EducationForMappings.size()>0){
            // Delete Education_EducationGroupings
            List<Id>lstEducationIds =new List<Id>(EducationForMappings.keySet());
            PRM_VPP_VelocityRuleResultsUtils.deleteEducationAndEducationGroupMapping(lstEducationIds);
            //create Education_EducationGroupings
            PRM_VPP_VelocityRuleResultsUtils.createEducationAndEducationGroupMapping(EducationForMappings.values());
      
       }
       if(ContactIds.size()>0){
             for(contact con : [select id, Account.Grouping__c from contact where id in :ContactIds ]){
                     if(con.Account !=null && con.Account.Grouping__c!=null){
                        GroupingID_Set.add(con.Account.Grouping__c); 
                    }
            }  
        }
       if(GroupingID_Set.size()>0){
            MarkGroupings(GroupingID_Set);
        }
      } 

    /*public void MarkGroupings(Set<Id> GroupingID_Set)   {
        List <Account_Groupings__c>LB_PAN_Groupings = new List <Account_Groupings__c>();
        
        if(GroupingID_Set.size()>0){
          List <Account_Groupings__c>UpdatedGroupgings=[select id,Logical_Block_Level_Grouping__c,Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,Process_On_After__c from Account_Groupings__c where id in:GroupingID_Set];
           for(Account_Groupings__c grp: UpdatedGroupgings){
                   grp.Process_On_After__c=system.now(); 
                    if(grp.Logical_Block_Level_Grouping__c!=null ){   
                        LB_PAN_Groupings.add((new Account_Groupings__c(id=grp.Logical_Block_Level_Grouping__c,Process_On_After__c=system.now() )));
                        
                    }
                    if(grp.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c!=null ){   
                        LB_PAN_Groupings.add((new Account_Groupings__c(id=grp.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c , Process_On_After__c=system.now())));
                       
                    }                       
           }
           ProcessOnAfterUpdating=true;
           UpdatedGroupgings.addAll(LB_PAN_Groupings);
           update UpdatedGroupgings;
        }
    }*/
    
    
    public void MarkGroupings(Set<Id> GroupingID_Set)   {
        Map<Id,Account_Groupings__c>LB_PAN_Groupings = new Map <Id,Account_Groupings__c>();
        if(GroupingID_Set.size()>0){
         
          Map<Id,Account_Groupings__c> UpdatedGroupgings = new Map<Id,Account_Groupings__c>([select id,Logical_Block_Level_Grouping__c,Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,Process_On_After__c from Account_Groupings__c where id in:GroupingID_Set]);
           for(Account_Groupings__c grp: UpdatedGroupgings.values()){
                   grp.Process_On_After__c=system.now(); 
                    if(grp.Logical_Block_Level_Grouping__c!=null){   
                        LB_PAN_Groupings.put(grp.Logical_Block_Level_Grouping__c,(new Account_Groupings__c(id=grp.Logical_Block_Level_Grouping__c,Process_On_After__c=system.now() )));
                    }
                    if(grp.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c!=null){   
                        LB_PAN_Groupings.put(grp.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,(new Account_Groupings__c(id=grp.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c , Process_On_After__c=system.now())));
                    }                       
           }
           ProcessOnAfterUpdating=true;
           UpdatedGroupgings.putAll(LB_PAN_Groupings);
           update UpdatedGroupgings.values();
        }
    }
    
    
    public void deltaPartnerGroupingMarking(Map<Id,Account_Groupings__c>oldPartnerGroupingMap,Map<Id,Account_Groupings__c>newPartnerGroupingMap ){
        // Delete Trigger
       if(newPartnerGroupingMap==null){
            for(Account_Groupings__c  grouping : oldPartnerGroupingMap.values()){
                 grouping.Process_On_After__c=system.now();  
                 ProcessOnAfterUpdating=true;  
            }
       }
        
        // New Trigger
       if(oldPartnerGroupingMap==null){
            for(Account_Groupings__c grouping : newPartnerGroupingMap.values()){
              grouping.Process_On_After__c=system.now();   
              ProcessOnAfterUpdating=true;           
            }
       }
       
         //Update Trigger
        if(oldPartnerGroupingMap!=null && newPartnerGroupingMap!=null){
            
             Account_Groupings__c oldgrouping; 
             for(Account_Groupings__c newgrouping:newPartnerGroupingMap.values()){  
                    oldgrouping=oldPartnerGroupingMap.get(newgrouping.id);
                    if (oldgrouping.Active__c != newgrouping.Active__c || 
                        oldgrouping.Profiled_Account__c != newgrouping.Profiled_Account__c ||
                        oldgrouping.Deployed_To__c != newgrouping.Deployed_To__c ||
                        oldgrouping.Velocity_Specaility_Achieved__c != newgrouping.Velocity_Specaility_Achieved__c ){
                        newgrouping.Process_On_After__c=system.now();  
                        ProcessOnAfterUpdating=true;
                        System.debug('ProcessOnAfterUpdating 1' +ProcessOnAfterUpdating);                       
                    }               
             }
         }
        
    }
    public void deltaEducationMasterMarking(Map<Id,Education_Group_Member__c>oldEducationGrpMemberMap,Map<Id,Education_Group_Member__c>newEducationGrpMemberMap ){
        List<ID>RuleIds = new List<ID>();
        
        // Delete Trigger
       if(newEducationGrpMemberMap==null){
            for(Education_Group_Member__c  Member : oldEducationGrpMemberMap.values()){
                 RuleIds.add(Member.Education_Master__c);     
            }
       }
        
        // New Trigger
       if(oldEducationGrpMemberMap==null){
            for(Education_Group_Member__c Member : newEducationGrpMemberMap.values()){
              RuleIds.add(Member.Education_Master__c);             
            }
       }
       
         //Update Trigger
        if(oldEducationGrpMemberMap!=null && newEducationGrpMemberMap!=null){
            
             Education_Group_Member__c oldMember; 
             for(Education_Group_Member__c newMember:newEducationGrpMemberMap.values()){    
                    oldMember=oldEducationGrpMemberMap.get(newMember.id);
                    if (oldMember.Education_Master__c != newMember.Education_Master__c || oldMember.Education_Group__c != newMember.Education_Group__c){
                        RuleIds.add(oldMember.Education_Master__c);
                        RuleIds.add(newMember.Education_Master__c);
                        
                    }               
             }
         } 
         if(RuleIds.size()>0){
             List<Education_Master__c> educations =[Select id,Process_On_After__c from Education_Master__c where id in :RuleIds];
             for(Education_Master__c edu :educations){
                 edu.Process_On_After__c=system.now(); 
             }
         }
    }
    public void deltaRuleMarking(Map<Id,Velocity_Rule_Member__c>oldRuleMemberMap,Map<Id,Velocity_Rule_Member__c>newRuleMemberMap ){
        List<ID>RuleIds = new List<ID>();
        
        // Delete Trigger
       if(newRuleMemberMap==null){
            for(Velocity_Rule_Member__c ruleMember : oldRuleMemberMap.values()){
                 RuleIds.add(ruleMember.Speciality_Rule__c);     
            }
       }
        
        // New Trigger
       if(oldRuleMemberMap==null){
            for(Velocity_Rule_Member__c ruleMember : newRuleMemberMap.values()){
              RuleIds.add(ruleMember.Speciality_Rule__c);             
            }
       }
       
         //Update Trigger
        if(oldRuleMemberMap!=null && newRuleMemberMap!=null){
            
             Velocity_Rule_Member__c oldRuleMember; 
             for(Velocity_Rule_Member__c newruleMember:newRuleMemberMap.values()){  
                    oldRuleMember=oldRuleMemberMap.get(newruleMember.id);
                    if (oldRuleMember.Group__c != newruleMember.Group__c || oldRuleMember.Speciality_Rule__c != newruleMember.Speciality_Rule__c){
                        RuleIds.add(oldRuleMember.Speciality_Rule__c);
                        RuleIds.add(newruleMember.Speciality_Rule__c);  
                    }               
             }
         }
         System.debug('Velocity_Rules__c '+RuleIds.size());
         if(RuleIds.size()>0){
             List<Velocity_Rules__c> Rules =[Select RecordTypeId,RecordType.DeveloperName,Specialty_Rule_Type__c,id,Theater__c,Tier__c,Cluster__c from Velocity_Rules__c where id in :RuleIds];
             for(Velocity_Rules__c rule :Rules){
                 MarkRules(rule, rule); 
             }
         }
    }
     public void deltaRuleMarking(Map<Id,Velocity_Rules__c>oldRuleMap,Map<Id,Velocity_Rules__c>newRuleMap ){
        
        // Delete Trigger
       if(newRuleMap==null){
            for(Velocity_Rules__c rule : oldRuleMap.values()){
              MarkRules(rule, rule);            
            }
       }
       
       // New Trigger
       if(oldRuleMap==null){
            for(Velocity_Rules__c rule : newRuleMap.values()){
              MarkRules(rule, rule);             
            }
       }
       
        //Update Trigger
        if(oldRuleMap!=null && newRuleMap!=null){
            Map<String, Schema.SObjectField> RulesFields = Schema.SObjectType.Velocity_Rules__c.fields.getMap();
             Velocity_Rules__c oldRule;
             
             
             for(Velocity_Rules__c newrule:newRuleMap.values()){    
                    oldRule=oldRuleMap.get(newrule.id);
                    for(String fieldName:  RulesFields.keySet()){
                        if( fieldName.indexOf('__c')!=-1 &&  oldRule.get(fieldName)!=newrule.get(fieldName)){
                            MarkRules(newrule, oldRule);
                        }   
                    }       
                }
           }  
     }
      public void deltaContactMarking(Map<Id,Contact>oldContactMap,Map<Id,Contact>newContactMap ){
        
        set<Id>AccountIds = new set<Id>();
        set<Id>GroupingID_Set = new set<Id>();
        // Delete Trigger
       if(oldContactMap==null){
            for(Contact con : newContactMap.values()){
                AccountIds.add(con.AccountId); 
                         
            }
       }
       
       // New Trigger
       if(newContactMap==null){
            for(Contact con : oldContactMap.values()){
              AccountIds.add(con.AccountId);             
            }
       }
       
        //Update Trigger
        if(oldContactMap!=null && newContactMap!=null){
            Map<String, Schema.SObjectField> RulesFields = Schema.SObjectType.Contact.fields.getMap();
             Contact oldCon;
             
             
             for(Contact newCon:newContactMap.values()){    
                     oldCon=oldContactMap.get(newCon.id);
                        if(oldCon.AccountId!=newCon.AccountId){
                             AccountIds.add(oldCon.AccountId);
                             AccountIds.add(newCon.AccountId);
                               
                        }   
                            
                }
          }  
     
           if(AccountIds.size()>0){
             for(Account acc : [select id, Grouping__c from Account where id in :AccountIds and Grouping__c != null]){
                     
                        GroupingID_Set.add(acc.Grouping__c); 
                    
            }  
         }
         if(GroupingID_Set.size()>0){
            MarkGroupings(GroupingID_Set);
         }
     
     }
      private void MarkRules(Velocity_Rules__c newRule, Velocity_Rules__c OldRule){
            Set<String> Theaters =new Set<String> ();
            Set<String> Clusters =new Set<String> ();
            Set<String> Tiers =new Set<String> ();
            Set<Id>GroupRuleId= new Set<Id>();
            Set<String>SpecialtyType= new Set<String>();    
                        System.debug('newrule.RecordType.DeveloperName  '+newrule.RecordType.DeveloperName);    
                        if( newrule.RecordTypeId=='01270000000Q6iNAAS' ){
                            System.debug('Group_Rule');
                            GroupRuleId.add(newrule.id);
                                                        
                        }else if( newrule.RecordTypeId=='01270000000Q6iXAAS' || newrule.RecordTypeId=='012V00000008bAAIAY'){
                            SpecialtyType.add(newrule.Specialty_Rule_Type__c);
                            SpecialtyType.add(oldRule.Specialty_Rule_Type__c);                              
                            System.debug('Specialty_Rule/Field base rule');
                        }else if( newrule.RecordTypeId=='01270000000Q6iSAAS' ){
                            Theaters.add(newrule.Theater__c);
                            Theaters.add(oldRule.Theater__c);
                            System.debug('Roll_Up_Rule');
                        }else if( newrule.RecordTypeId=='01270000000Q6icAAC' ){
                            Tiers.add(newrule.Tier__c);
                            Tiers.add(oldRule.Tier__c);
                            Clusters.add(newrule.Cluster__c);
                            Clusters.add(oldRule.Cluster__c);
                            System.debug('Tier_Rule');
                        }else if( newrule.RecordTypeId=='01270000000Q8iDAAS' ){
                            Tiers.add(newrule.Tier__c);
                            Tiers.add(oldRule.Tier__c);
                            System.debug('Services_Rule');
                        }
                        else{
                            Theaters.add(newrule.Theater__c);
                            Theaters.add(oldRule.Theater__c);
                            System.debug('other rule');
                        }
                    
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
                    if(Theaters.size()!=0){  
                        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTheater =DataValueMap.get('PRM_VPP_ProcessWholeTheater');
                        PRM_VPP_ProcessWholeTheater.DataValue__c=listToString(Theaters,PRM_VPP_ProcessWholeTheater.DataValue__c);
                        update PRM_VPP_ProcessWholeTheater;
                    }   
                    
                    if(Clusters.size()!=0){
                    
                        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeCluster =DataValueMap.get('PRM_VPP_ProcessWholeCluster');
                        PRM_VPP_ProcessWholeCluster.DataValue__c=listToString(Clusters,PRM_VPP_ProcessWholeCluster.DataValue__c);    
                       
                        update PRM_VPP_ProcessWholeCluster;
                    }
                    if(Tiers.size()!=0){
                    
                        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTier =DataValueMap.get('PRM_VPP_ProcessWholeTier');
                        PRM_VPP_ProcessWholeTier.DataValue__c=listToString(Tiers,PRM_VPP_ProcessWholeTier.DataValue__c); 
                        
                        update PRM_VPP_ProcessWholeTier;
                    }   
                    if(GroupRuleId.size()>0){
                        for (Velocity_Rules__c rule : [select Specialty_Rule_Type__c from Velocity_Rules__c where Velocity_Rule_1__c in :GroupRuleId or  Velocity_Rule_2__c in :GroupRuleId or  Group_Rule_3__c in :GroupRuleId  or  Group_Rule_4__c in :GroupRuleId or  Group_Rule_5__c in :GroupRuleId ]){
                            SpecialtyType.add(rule.Specialty_Rule_Type__c);
                        }
                        
                    }
                    if(SpecialtyType.size()!=0){
                    
                        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeSpecialityType =DataValueMap.get('PRM_VPP_ProcessWholeSpecialityType');
                        PRM_VPP_ProcessWholeSpecialityType.DataValue__c=listToString(SpecialtyType,PRM_VPP_ProcessWholeSpecialityType.DataValue__c); 
                        
                        
                        update PRM_VPP_ProcessWholeSpecialityType;
                    }
            } 
    
            private String listToString(Set<String>lst,String PrefixValue){
                 String ListString='';
                 ListString=(PrefixValue=='None')? '' : PrefixValue;
                 
                 for(String str :lst){
                    if(ListString.indexOf('\''+str+'\'')==-1){
                        ListString =ListString + ( ListString==''?  '\''+str+'\'' : ',\'' +str+'\'');
                    }
                }
                return ListString;
            }        
            
}