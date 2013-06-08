/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER        DESCRIPTION                               

 |  ====          =========        =========== 

 |  24/10/2011    Shalabh Sharma   This class is used to send emails to case owner's manager on escalation of a case.   
    14/11/2011    Shalabh Sharma   Added a static variable to control duplicate emails.
 |  03/05/2012    Shalabh Sharma   Added method addManagerToFollower to add case owner's manager as a case follower on escalation.
 |  08/05/2012    Shalabh Sharma   Added method addOwnerToFollower to add case owner & requestor in the follower list.
 |  08/05/2012    Shalabh Sharma   Added method removeOldOwnerRequestor to remove old case owner & requestor from the follower list.
 |  14/05/2012    Shalabh Sharma   Added method removeFollowersOnClosure to remove every user from the follower list on case closure.
 +==================================================================================================================*/
 public class Presales_SendMailToManager{
 static Boolean isEscalation = false;
 static Boolean isUpdate = false;
 Map<Id,Id> mapUserIdRoleId = new Map<Id,Id>();
 Map<Id,Id> mapManagerOwner= new Map<Id,Id>();
 Map<Id,Id> mapOwnerCase = new Map<Id,Id>();
 Map<Id,List<User>> mapRoleIdUsers = new Map<Id,List<User>>();
 Map<Id,UserRole> mapTLManager = new Map<Id,UserRole>();
 
 /* @Method <This method execute is used to find the user above to case owner in role hierarchy>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/ 
     public void findManagerOfOwner(Map<Id,Case> mapEscalatedCase){
         Map<Id,User> mapCaseOwner = new Map<Id,User>();
         for(Id caseRecordId:mapEscalatedCase.keyset()){
             String s = mapEscalatedCase.get(caseRecordId).OwnerId;
             if(s.substring(0,3)=='005'){
                 mapOwnerCase.put(caseRecordId,mapEscalatedCase.get(caseRecordId).OwnerId);
             }     
        }
        system.debug('mapOwnerCase--->'+mapOwnerCase);
         Map<Id,User> mapUser = new Map<Id,User>([select Id,Name, UserRoleId from User where Id in :mapOwnerCase.values()]);
         system.debug('mapUser--->'+mapUser);
         
         if(mapUser!=null){
             for(User userRecord:mapUser.values()){
                 mapUserIdRoleId.put(userRecord.Id,userRecord.UserRoleId); 
                 //mapOwnerRoleOwnerId.put(userRecord.UserRoleId,userRecord.Id);   
             }
         }
         system.debug('mapUserIdRoleId--->'+mapUserIdRoleId);
         
         Map<Id,UserRole> mapUserRole = new Map<Id,UserRole>([select Id,Name,ParentRoleId from UserRole where Id in:mapUserIdRoleId.values()]);
         system.debug('mapUserRole--->'+mapUserRole);
         
         List<Id> lstUserRoleId = new List<Id>();
         for(UserRole userRole:mapUserRole.values()){
             lstUserRoleId.add(userRole.ParentRoleId);
             mapManagerOwner.put(userRole.Id,userRole.ParentRoleId);
         }
         system.debug('lstUserRoleId--->'+lstUserRoleId);
         system.debug('mapManagerOwner--->'+mapManagerOwner);
         Map<Id,UserRole> mapParentRoleNameID = new Map<Id,UserRole>();
         if(lstUserRoleId!=null){
             mapParentRoleNameID = getParentRole(lstUserRoleId);
         }
         system.debug('mapParentRoleNameID --->'+mapParentRoleNameID);
         if(mapParentRoleNameID!=null){
             getUsersOnRole(mapParentRoleNameID);
         }
         system.debug('mapOwnerCase--->'+mapOwnerCase);
         sendEmail(mapOwnerCase);
         addManagerToFollower(mapOwnerCase);
     }
/* @Method <This method execute is used to find the parent role details of case owner>
@param <This method takes List<Id> as parameter>
@return <Map<Id,UserRole>> - <Map of Map<Id,UserRole>>
@throws exception - <No Exception>
*/ 
     public Map<Id,UserRole> getParentRole(List<Id> lstUserRoleIds){    
         
         /*List<Id> lstParentIds = new List<Id>();
         for(UserRole userRole:mapUserRole.values()){
             lstParentIds.add(userRole.ParentRoleId);
         }*/
         Map<Id,UserRole> mapParent = new Map<Id,UserRole>([select Id,Name,ParentRoleId from UserRole where Id in:lstUserRoleIds]);
         
         /*for(UserRole userRole:mapParent.values()){
             mapManagerTL.put(userRole.ParentRoleId,userRole.Id);
         }*/
         return mapParent;
     }
 /* @Method <This method execute is used to get users on parent role of case owner>
@param <This method takes Map<Id,UserRole> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
     public void getUsersOnRole(Map<Id,UserRole> mapRoleNameId){
         List<Id> lstManagerRoleIds = new List<Id>();
         
         //Map<Id,User> mapToAdd = new Map<Id,User>();
         
         Set<Id> setManagerRoleIds = new Set<Id>();
         for(UserRole parentRole:mapRoleNameId.values()){
             if(parentRole.Name.contains('Team Lead')){  
                 lstManagerRoleIds.add(parentRole.Id);
             }
                 setManagerRoleIds.add(parentRole.Id);    
              
         }
         
         System.debug('setManagerRoleIds--->'+setManagerRoleIds);
         
         if(lstManagerRoleIds!=null){
             mapTLManager = getParentRole(lstManagerRoleIds);
         }
         if(mapTLManager!=null){
             for(UserRole parentRole:mapTLManager.values()){
                 setManagerRoleIds.add(parentRole.ParentRoleId);    
             }
         }
         Map<Id,User> mapToAdd = new Map<Id,User>([select Id,name,Email,UserRoleId from User where UserRoleId in:setManagerRoleIds and isActive=true]);    
         List<String> lstEmails = new List<String>();
         if(mapToAdd!=null){
             for(User userRecord:mapToAdd.values()){
                 if(mapRoleIdUsers.containsKey(userRecord.UserRoleId)){
                    (mapRoleIdUsers.get(userRecord.UserRoleId).add(userRecord));
                 }
                 else{
                    List<User> lstOFUser = new List<User>();
                    lstOFUser.add(userRecord);
                    mapRoleIdUsers.put(userRecord.UserRoleId,lstOFUser);
                 }
             }
         }  
     }
 /* @Method <This method execute is used to send emails to case owner's managers>
@param <This method takes Map<Id,Id> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
     public void sendEmail(Map<Id,Id> mapCaseIdOwner){
     if(isEscalation == false){
         String[] toAdd = new String[]{};
         Id templateId = System.Label.Presales_EscalationTemplate;
         List<User> lstUser = new List<User>();
         List<User> lstManager = new List<User>();
         String setTargetId;
         List<String> lstEmailIds = new List<String>();
         try{
             for(Id caseId:mapCaseIdOwner.keyset()){
                 if(mapRoleIdUsers.size()>0 && mapManagerOwner.size()>0 && mapUserIdRoleId.size()>0 && mapOwnerCase.size()>0){
                     lstUser = mapRoleIdUsers.get(mapManagerOwner.get(mapUserIdRoleId.get(mapOwnerCase.get(caseId))));
                 }
                 if(mapRoleIdUsers.size()>0 && mapTLManager.size()>0 && mapManagerOwner.size()>0 && mapUserIdRoleId.size()>0 && mapOwnerCase.size()>0){
                     lstManager = (mapRoleIdUsers.get(mapTLManager.get(mapManagerOwner.get(mapUserIdRoleId.get(mapOwnerCase.get(caseId)))).ParentRoleId));
                 }
                 system.debug('lstUser--->'+lstUser);
                 system.debug('lstManager --->'+lstManager);
                 if(lstUser!=null){
                     for(User userRecord:lstUser){
                         if(userRecord.PreSales_Case_Escalated__c==true){
                             lstEmailIds.add(userRecord.Email);
                         }
                     }
                 if(lstManager !=null){
                     for(User userRecord:lstManager){
                         if(userRecord.PreSales_Case_Escalated__c==true){
                             lstEmailIds.add(userRecord.Email);
                         }
                     }
                 }    
                     toAdd = lstEmailIds;
                     system.debug('lstEmailIds--->'+lstEmailIds);
                     setTargetId = lstUser[0].Id;
                     }
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setToAddresses(toAdd);
                 mail.setSaveAsActivity(false);
                 mail.setTemplateId(templateId);    
                 mail.setTargetObjectId(setTargetId);
                 mail.setWhatId(caseId);
                 
                 Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
             }
         }
         catch(Exception e){
             system.debug('Exception'+e);
         }    
     }
         isEscalation = true;
   }
/* @Method <This method execute is used to add case owner's manager as a case follower on escalation>
@param <This method takes Map<Id,Id> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void addManagerToFollower(Map<Id,Id> mapCaseIdOwner){
        List<User> lstManager = new List<User>();
        List<User> lstUser = new List<User>();
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
        try{
            for(Id caseId:mapCaseIdOwner.keyset()){
                if(mapRoleIdUsers.size()>0 && mapManagerOwner.size()>0 && mapUserIdRoleId.size()>0 && mapOwnerCase.size()>0){
                    lstUser = mapRoleIdUsers.get(mapManagerOwner.get(mapUserIdRoleId.get(mapOwnerCase.get(caseId))));
                }
                if(mapRoleIdUsers.size()>0 && mapTLManager.size()>0 && mapManagerOwner.size()>0 && mapUserIdRoleId.size()>0 && mapOwnerCase.size()>0){
                    lstManager = (mapRoleIdUsers.get(mapTLManager.get(mapManagerOwner.get(mapUserIdRoleId.get(mapOwnerCase.get(caseId)))).ParentRoleId));
                }    
                    system.debug('lstManager--->'+lstManager);
                    //EntitySubscription entitySubs = new EntitySubscription();
                    if(lstManager.size()>0){
                        for(User usr:lstManager){
                        EntitySubscription entitySubs = new EntitySubscription();                       
                            entitySubs.parentid = caseId;
                            entitySubs.subscriberid = usr.id;
                            lstEntitySubscription.add(entitySubs);
                        }
                    }
                    else if (lstUser.size()>0){
                         for(User usr: lstUser){
                         EntitySubscription entitySubs = new EntitySubscription();                        
                            entitySubs.parentid = caseId;
                            entitySubs.subscriberid = usr.id;
                            lstEntitySubscription.add(entitySubs);
                        }
                    }    
            }
            system.debug('lstEntitySubscription--->'+lstEntitySubscription);           
            insert lstEntitySubscription;
            }
            catch(Exception e){
                system.debug('Exception--->'+e);
            }    
    }
/* @Method <This method execute is used to add case owner & requestor to the case follower list>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void addOwnerToFollower(Map<Id,Case> mapCase, Boolean isRequestor){
    if(!isUpdate){
        //List<String> lstRequestor = new List<String>();
        Map<String,Id> mapUserEmail = new Map<String,Id>();
        Map<Id,User> mapRequestor = new Map<Id,User>();
        Map<Id,String> mapCaseRequestor = new Map<Id,String>();
        
            for(Case caseRecord:mapCase.values()){
                //lstRequestor.add(caseRecord.Contact_Email1__c);
                mapCaseRequestor.put(caseRecord.Id,caseRecord.Contact_Email1__c);    
            }
            if(mapCaseRequestor.size()>0){
            mapRequestor = new Map<Id,User>([Select Id,Email from User where Email in :mapCaseRequestor.values()]);    
            }
            system.debug('mapRequestor--->'+mapRequestor);
            if(mapRequestor.size()>0){
                for(User usr:mapRequestor.values()){
                    mapUserEmail.put(usr.Email,usr.Id);
                }            
            }
            List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
            for(Id caseId:mapCase.keyset()){
            if(!isRequestor){
                String s = mapCase.get(caseId).OwnerId;
                if(s.substring(0,3)=='005'){
                EntitySubscription entitySubs = new EntitySubscription();                       
                entitySubs.parentid = caseId;
                entitySubs.subscriberid = mapCase.get(caseId).OwnerId;
                system.debug('entitySubs--->'+entitySubs);
                lstEntitySubscription.add(entitySubs);    
                }
            }    
             else if(mapUserEmail.size()>0 && mapCaseRequestor.size()>0){
                EntitySubscription entitySubs = new EntitySubscription();
                entitySubs.parentid = caseId;
                entitySubs.subscriberid = mapUserEmail.get(mapCaseRequestor.get(caseId));
                lstEntitySubscription.add(entitySubs);
                }
            }
            system.debug('lstEntitySubscription--->'+lstEntitySubscription);
            try{
            insert lstEntitySubscription;
            }
            catch(Exception e){
                system.debug('e--->'+e);
            }
        
        system.debug('mapCase--->'+mapCase.keyset());
      }
      isUpdate = true;   
    } 
/* @Method <This method execute is used to remove old case owner & requestor from the case follower list>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void removeOldOwnerRequestor(Map<Id,Case> mapOldCase,Boolean isChange){
    List<Id> lstOldOwner = new List<Id>();
    Map<Id,User> mapRequestor = new Map<Id,User>();
    Map<Id,String> mapCaseRequestor = new Map<Id,String>();
    if(isChange){
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
        Map<Id,Case> mapCaseCreatedById = new Map<Id,Case>([Select CreatedById from Case where Id in:mapOldCase.keyset()]);
        Map<Id,Id> mapCaseIdCreator = new Map<id,id>();
        for(Case caseRecord: mapCaseCreatedById.values()){
            mapCaseIdCreator.put(caseRecord.Id,caseRecord.CreatedById);
        }
        for(Case caseRecord: mapOldCase.values()){
            if(mapCaseIdCreator.size()>0 && caseRecord.OwnerId != mapCaseIdCreator.get(caseRecord.Id)){
                lstOldOwner.add(caseRecord.OwnerId);    
            }           
        }
        if(lstOldOwner.size()>0){
            lstEntitySubscription = [Select Id,ParentId from EntitySubscription where subscriberid in:lstOldOwner AND parentid in:mapOldCase.keyset()];
        }
        if(lstEntitySubscription.size()>0){
            delete lstEntitySubscription;
        }
    }
    else{
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
        for(Case caseRecord:mapOldCase.values()){           
            mapCaseRequestor.put(caseRecord.Id,caseRecord.Contact_Email1__c);    
        }
        if(mapCaseRequestor.size()>0){
            mapRequestor = new Map<Id,User>([Select Id,Email from User where Email in :mapCaseRequestor.values()]);    
        }
        if(mapRequestor.size()>0){
            lstEntitySubscription = [Select Id,ParentId from EntitySubscription where subscriberid in:mapRequestor.keyset() AND parentid in:mapOldCase.keyset()];    
        }
        if(lstEntitySubscription.size()>0){
            delete lstEntitySubscription;
        }
    }            
    }
/* @Method <This method execute is used to remove all users from the case follower list on case closure>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void removeFollowersOnClosure(Map<Id,Case> mapClosedCase){
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
        lstEntitySubscription = [Select Id from EntitySubscription where parentid in:mapClosedCase.keyset()];   
        if(lstEntitySubscription.size()>0){
            delete lstEntitySubscription;   
        }   
    }   
 }