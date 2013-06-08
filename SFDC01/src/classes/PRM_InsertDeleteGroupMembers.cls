/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  26.06.2012      Arif           #194177      This class is used to insert/delete group members for Inside Sales users           
 +========================================================================================================================*/
public class PRM_InsertDeleteGroupMembers{
    @future
    public static void insertGroupMember(set<Id> setUserId){
        map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
        map<Id,list<Id>> mapProfileIdAndListOfUserId = new map<Id,list<Id>>();
        list<GroupMember> lstGroupMember = new list<GroupMember>();
        if(setUserId.size()>0){
            list<User> lstUser = [Select Id,ProfileId from User where Id in:setUserId];
            if(lstUser.size()>0){
                for(User user:lstUser){
                   if(mapProfileIdAndListOfUserId.containsKey(user.ProfileId)){
                          mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);            
                   }else{   
                         mapProfileIdAndListOfUserId.put(user.ProfileId,new list<Id>());
                         mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);
                   }
               }    
            }
        }
         if(!mapCustomSetting.isEmpty() && !mapProfileIdAndListOfUserId.isEmpty()){
            for(Id profileId: mapProfileIdAndListOfUserId.keyset()){
                if(mapCustomSetting.containsKey(profileId)){
                    GroupMember grpMem = new GroupMember();
                    if(mapProfileIdAndListOfUserId.get(profileId).size()>0){
                        for(Id userId: mapProfileIdAndListOfUserId.get(profileId)){
                            grpMem.GroupId = mapCustomSetting.get(profileId).GroupId__c;
                            grpMem.UserOrGroupId = userId;
                            lstGroupMember.add(grpMem);
                        }
                    }
                }
            }
            if(lstGroupMember.size()>0){
                insert lstGroupMember;
            }
        }
    }  
    @future
    public static void deleteGroupMember(set<Id> setUserId){
        map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
        map<Id,list<Id>> mapProfileIdAndListOfUserId = new map<Id,list<Id>>();
        list<Id> lstUserId = new list<Id>();
        list<Id> lstGroupId = new list<Id>();
        list<GroupMember> lstGroupMember = new list<GroupMember>();
        if(setUserId.size()>0){
            list<User> lstUser = [Select Id,ProfileId from User where Id in:setUserId];
            if(lstUser.size()>0){
                for(User user:lstUser){
                   if(mapProfileIdAndListOfUserId.containsKey(user.ProfileId)){
                          mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);            
                   }else{   
                         mapProfileIdAndListOfUserId.put(user.ProfileId,new list<Id>());
                         mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);
                   }
               }    
            }
        }
        if(!mapCustomSetting.isEmpty() && !mapProfileIdAndListOfUserId.isEmpty()){
            for(Id profileId: mapProfileIdAndListOfUserId.keyset()){
                if(mapCustomSetting.containsKey(profileId)){
                    if(mapProfileIdAndListOfUserId.get(profileId).size()>0){
                        for(Id userId: mapProfileIdAndListOfUserId.get(profileId)){
                            lstGroupId.add(mapCustomSetting.get(profileId).GroupId__c);
                            lstUserId.add(userId);
                        }
                    }
                }
            }
            if(lstUserId.size()>0 && lstGroupId.size()>0){
                lstGroupMember = [Select Id,UserOrGroupId,GroupId from GroupMember where UserOrGroupId in: lstUserId and GroupId in: lstGroupId];
            }
            if(lstGroupMember.size()>0){
                delete lstGroupMember;
            }
        } 
    }          
        
    public void insertGroupMember(list<User> lstUser){
        map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
        map<Id,list<Id>> mapProfileIdAndListOfUserId = new map<Id,list<Id>>();
        list<GroupMember> lstGroupMember = new list<GroupMember>();
        for(User user:lstUser){
               if(mapProfileIdAndListOfUserId.containsKey(user.ProfileId)){
                      mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);            
               }else{   
                     mapProfileIdAndListOfUserId.put(user.ProfileId,new list<Id>());
                     mapProfileIdAndListOfUserId.get(user.ProfileId).add(user.Id);
               }
        }
        if(!mapCustomSetting.isEmpty() && !mapProfileIdAndListOfUserId.isEmpty()){
            for(Id profileId: mapProfileIdAndListOfUserId.keyset()){
                if(mapCustomSetting.containsKey(profileId)){
                    GroupMember grpMem = new GroupMember();
                    if(mapProfileIdAndListOfUserId.get(profileId).size()>0){
                        for(Id userId: mapProfileIdAndListOfUserId.get(profileId)){
                            grpMem.GroupId = mapCustomSetting.get(profileId).GroupId__c;
                            grpMem.UserOrGroupId = userId;
                            lstGroupMember.add(grpMem);
                        }
                    }
                }
            }
            if(lstGroupMember.size()>0){
                insert lstGroupMember;
            }
        }
        
    }
    public void deleteGroupMember(map<Id,User> mapUserNew,map<Id,User> mapUserOld){
        map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
        map<Id,list<Id>> mapProfileIdAndListOfUserId = new map<Id,list<Id>>();
        list<Id> lstUserId = new list<Id>();
        list<Id> lstGroupId = new list<Id>();
        list<GroupMember> lstGroupMember = new list<GroupMember>();
        for(User user:mapUserNew.values()){
               if(mapProfileIdAndListOfUserId.containsKey(mapUserOld.get(user.Id).ProfileId)){
                      mapProfileIdAndListOfUserId.get(mapUserOld.get(user.Id).ProfileId).add(user.Id);            
               }else{   
                     mapProfileIdAndListOfUserId.put(mapUserOld.get(user.Id).ProfileId,new list<Id>());
                     mapProfileIdAndListOfUserId.get(mapUserOld.get(user.Id).ProfileId).add(user.Id);
               }
        }
        if(!mapCustomSetting.isEmpty() && !mapProfileIdAndListOfUserId.isEmpty()){
            for(Id profileId: mapProfileIdAndListOfUserId.keyset()){
                if(mapCustomSetting.containsKey(profileId)){
                    if(mapProfileIdAndListOfUserId.get(profileId).size()>0){
                        for(Id userId: mapProfileIdAndListOfUserId.get(profileId)){
                            lstGroupId.add(mapCustomSetting.get(profileId).GroupId__c);
                            lstUserId.add(userId);
                        }
                    }
                }
            }
            if(lstUserId.size()>0 && lstGroupId.size()>0){
                lstGroupMember = [Select Id,UserOrGroupId,GroupId from GroupMember where UserOrGroupId in: lstUserId and GroupId in: lstGroupId];
            }
            if(lstGroupMember.size()>0){
                delete lstGroupMember;
            }
        } 
    } 
    
     public void convertLeadtoDealReg(list<lead> lstLead,Boolean isInsert){
        //list<Lead> lstLeadWithAccount = new list<Lead>(); //for keeping leads which have related account
        set<Id> setLeadId = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        CustomSettingDataValueMap__c recordTypes = new CustomSettingDataValueMap__c(); 
        map<Id,Lead> mapLeadWithRelatedAccount;
        map<Id,Account> mapAccountIdRelatedAccount;
        if(lstLead.size()>0){
            for(Lead lead: lstLead){
                if(lead.related_account__c != null){
                    if(!isInsert){
                        setLeadId.add(lead.Id);
                    }else{
                        setAccountId.add(lead.related_account__c);
                    }        
                }
            }
        }
        
        if(setLeadId.size()>0){
            mapLeadWithRelatedAccount = new map<Id,Lead>([Select related_account__r.Id,related_account__r.name,related_account__r.type,related_account__r.owner.alias,
                          related_account__r.BillingState,related_account__r.BillingPostalCode,related_account__r.BillingCity,
                          related_account__r.BillingStreet,related_account__r.BillingCountry,related_account__r.Party_Number__c,
                          related_account__r.City_Local__c,related_account__r.Country_Local__c,related_account__r.State_Province_Local__c,
                          related_account__r.Child_Record_Count_Contact__c,related_account__r.Address__c,related_account__r.NameLocal,
                          related_account__r.Address_Local__c,related_account__r.Street_Local__c,
                          related_account__r.Zip_Postal_Code_Local__c from Lead where Id in: setLeadId]);
        }
        if(setAccountId.size()>0){
            mapAccountIdRelatedAccount = new map<Id,Account>([Select Id,name,type,owner.alias,
                          BillingState,BillingPostalCode,BillingCity,
                          BillingStreet,BillingCountry,Party_Number__c,
                          City_Local__c,Country_Local__c,State_Province_Local__c,
                          Child_Record_Count_Contact__c,Address__c,NameLocal,
                          Address_Local__c,Street_Local__c,
                          Zip_Postal_Code_Local__c from Account where Id in: setAccountId]);
        }
            
        if(lstLead.size()>0){
            for(Lead lead: lstLead){
                if(!isInsert){
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
                    recordTypes = DataValueMap.get('DealRegistrationSubmittedRecordType');
                    if(lead.related_account__c != null && mapLeadWithRelatedAccount.containsKey(lead.Id)){                                                     
                         lead.Country__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingCountry;
                         lead.Country = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingCountry;
                         lead.Street = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingStreet;
                         lead.City = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingCity;
                         lead.PostalCode = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingPostalCode;
                         lead.State = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.BillingState;
                         //DealReg.Name=selectedAccount.name ;
                         if(mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Country_Local__c!=null ){
                             lead.Country_Local__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Country_Local__c;
                         }
                         if(mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Street_Local__c!=null ){
                             lead.Street_Local__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Street_Local__c;
                         }
                         if(mapLeadWithRelatedAccount.get(lead.Id).related_account__r.City_Local__c!=null ){
                             lead.City_Local__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.City_Local__c;
                         }
                         if(mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Zip_Postal_Code_Local__c!=null ){
                             lead.Zip_Postal_Code_Local__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.Zip_Postal_Code_Local__c;
                         }
                         if(mapLeadWithRelatedAccount.get(lead.Id).related_account__r.State_Province_Local__c!=null ){
                             lead.State_Province_Local__c = mapLeadWithRelatedAccount.get(lead.Id).related_account__r.State_Province_Local__c ;
                         }
                    }
                    Id dealRegRecordtypeId = recordTypes.DataValue__c;
                    lead.RecordTypeId = dealRegRecordtypeId;
                    lead.DealReg_Deal_Registration__c = true;
                    lead.Lead_Converted_to_DR_Date_Time__c = SYSTEM.NOW();
                    lead.DealReg_Deal_Registration_Status__c = 'New';
                    lead.DealReg_Submission_Source__c = 'Partner Central';
                    lead.DealReg_Deal_Registration_Type__c = 'Base';         
                    Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
                    if(mapCountry.ContainsKey(lead.Country__c)){
                        lead.DealReg_Theater__c = mapCountry.get(lead.Country__c).theater__c;
                    }
                }else{
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
                    recordTypes = DataValueMap.get('DealRegistrationSubmittedRecordType');
                    if(lead.related_account__c != null && mapAccountIdRelatedAccount.containsKey(lead.related_account__c)){                                                     
                         lead.Country__c = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingCountry;
                         lead.Country = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingCountry;
                         lead.Street = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingStreet;
                         lead.City = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingCity;
                         lead.PostalCode = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingPostalCode;
                         lead.State = mapAccountIdRelatedAccount.get(lead.related_account__c).BillingState;
                         //DealReg.Name=selectedAccount.name ;
                         if(mapAccountIdRelatedAccount.get(lead.related_account__c).Country_Local__c!=null ){
                             lead.Country_Local__c = mapAccountIdRelatedAccount.get(lead.related_account__c).Country_Local__c;
                         }
                         if(mapAccountIdRelatedAccount.get(lead.related_account__c).Street_Local__c!=null ){
                             lead.Street_Local__c = mapAccountIdRelatedAccount.get(lead.related_account__c).Street_Local__c;
                         }
                         if(mapAccountIdRelatedAccount.get(lead.related_account__c).City_Local__c!=null ){
                             lead.City_Local__c = mapAccountIdRelatedAccount.get(lead.related_account__c).City_Local__c;
                         }
                         if(mapAccountIdRelatedAccount.get(lead.related_account__c).Zip_Postal_Code_Local__c!=null ){
                             lead.Zip_Postal_Code_Local__c = mapAccountIdRelatedAccount.get(lead.related_account__c).Zip_Postal_Code_Local__c;
                         }
                         if(mapAccountIdRelatedAccount.get(lead.related_account__c).State_Province_Local__c!=null ){
                             lead.State_Province_Local__c = mapAccountIdRelatedAccount.get(lead.related_account__c).State_Province_Local__c ;
                         }
                    }
                    Id dealRegRecordtypeId = recordTypes.DataValue__c;
                    lead.RecordTypeId = dealRegRecordtypeId;
                    lead.DealReg_Deal_Registration__c = true;
                    lead.Lead_Converted_to_DR_Date_Time__c = SYSTEM.NOW();
                    lead.DealReg_Deal_Registration_Status__c = 'New';
                    lead.DealReg_Submission_Source__c = 'Partner Central';
                    lead.DealReg_Deal_Registration_Type__c = 'Base';         
                    Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
                    if(mapCountry.ContainsKey(lead.Country__c)){
                        lead.DealReg_Theater__c = mapCountry.get(lead.Country__c).theater__c;
                    }
               }     
           }    
                               
         // update lstLead;    
       }
    }
}