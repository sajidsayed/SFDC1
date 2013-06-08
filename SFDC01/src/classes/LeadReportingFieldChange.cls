/*==============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 | 3 May 2013   Prachi Bhasin           246408      Creation
 +==============================================================================================================*/
public class LeadReportingFieldChange{
    public Static Boolean restrictDuplicate = false;

public void updateReportField( Map<Id,Lead> leadNewRecordsMap,  Map<Id,Lead> leadOldRecordsMap , List<Id> newOwnerId, List<Id> oldOwnerId){

        if(!restrictDuplicate){

        Set<String> restrictedProfileSet = new Set<String>();
        Set<String> allowedProfileSet = new Set<String>();

        Map<String,restrictedProfiles__c> mapRestrictedProfiles = restrictedProfiles__c.getall();

        for(restrictedProfiles__c restProf : mapRestrictedProfiles.values()){

            restrictedProfileSet.add(restProf.Profile_Name__c);
        }

        Map<String,allowedProfiles__c> mapAllowedProfiles = allowedProfiles__c.getall();

        for(allowedProfiles__c allowedProf : mapAllowedProfiles.values()){

            allowedProfileSet.add(allowedProf.Profile_Name__c);

         }

        Map<Id,User> newOwnersMap = new Map<Id,User>([select id,Profile.Name from User where Id IN :newOwnerId]);
        Map<Id,User> oldOwnersMap = new Map<Id,User>([select id,Profile.Name from User where Id IN :oldOwnerId]);
        List<User> runningUser = [Select id,Profile.Name,Theater__c from User where Id =: UserInfo.getUserid()];
        System.debug('newOwnersMap'+newOwnersMap);
        System.debug('oldOwnersMap'+oldOwnersMap);
        System.debug('restrictedProfileSet+++'+restrictedProfileSet);
        System.debug('allowedProfileSet+++'+allowedProfileSet);
        System.debug('mapRestrictedProfiles+++'+mapRestrictedProfiles);
        System.debug('mapAllowedProfiles+++'+mapAllowedProfiles);
        
                                                

        for(Lead leadObj : leadNewRecordsMap.values()){
            if(oldOwnersMap.containskey(leadOldRecordsMap.get(leadObj.id).ownerId) && newOwnersMap.containskey(leadObj.ownerid)){
         
           if(allowedProfileSet.contains(oldOwnersMap.get(leadOldRecordsMap.get(leadObj.id).ownerId).Profile.Name)){

                   if(!restrictedProfileSet.contains(newOwnersMap.get(leadObj.ownerid).Profile.Name)){


                          leadObj.Passed_from_Inside_Sales__c=true;
                          leadObj.Passed_from_Inside_Sales_Date_Time__c=System.now();
                          leadObj.Passed_from_Inside_Sales_Profile__c = oldOwnersMap.get(leadOldRecordsMap.get(leadObj.id).ownerid).Profile.Name;
                          leadObj.Passed_from_Inside_Sales_Name__c= UserInfo.getName();
                          leadObj.Passed_from_Inside_Sales_Theatre__c= runningUser[0].Theater__c;

                     }
            }
        }
        }

        restrictDuplicate = true;

    }
   }

}