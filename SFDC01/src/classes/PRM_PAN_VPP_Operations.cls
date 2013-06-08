/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |23-July-2012    Prasad Kothawade                  To create Velocity rule results for PAN Theater model.
 |24-Apr-2013  	  Suresh D				210949	    Method has been added for rolling up the specialities achieved at logical block to Pan level.                                                                                          
 |        										    check for the specialities deployed at each LB and apply that speciality at pan level.
 |09-May-2013  	  Suresh D				239600	    Addded the Isilon_Track_Specialty__c to enabled the Isilon Track speciality to be available at 
 |													the Pan and Logical block level.		
 +=======================================================================================================*/

public class PRM_PAN_VPP_Operations {
    
    public static boolean rollupcheck = false;
    
    /* @markGroupingToProcess <PRM_PAN_VPP_Operations(): This method get called from Grouping Before Update Trigger.  This method checks if logical block or PAN Theater 
                                                        are valid values to evaluate.>
       @param - Map<id,Account_Groupings__c> oldGrouping,Map<id,Account_Groupings__c> newGrouping - Old and new maps from trigger
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    public void markGroupingToProcess(Map<id,Account_Groupings__c> oldGrouping,Map<id,Account_Groupings__c> newGrouping){
        map<Id,Account_Groupings__c> mapQueriedGrouping = new map<Id,Account_Groupings__c>([Select Id,Account__c,Active__c,Cluster__c,Process_On_After__c,Process_Rules__c,RecordType.DeveloperName,
                                                                                            Target_Tier__c,Theater2__c,Local_Requirment_Set__c from Account_Groupings__c 
                                                                                             where Id in: newGrouping.keyset()]);
        for(Account_Groupings__c newGrping: newGrouping.values()){
            // check if it Logical block and cluster, tier poupulated or Local requirment set populated then set Process_Rules__c = true
            if(mapQueriedGrouping.get(newGrping.Id).RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){
                if((newGrping.Cluster__c != null && newGrping.Cluster__c != '' && oldGrouping.get(newGrping.Id).Cluster__c != newGrping.Cluster__c
                   && newGrping.Target_Tier__c != null && newGrping.Target_Tier__c != '' && oldGrouping.get(newGrping.Id).Target_Tier__c != newGrping.Target_Tier__c)
                    || (newGrping.Local_Requirment_Set__c != null && newGrping.Local_Requirment_Set__c != '' && oldGrouping.get(newGrping.Id).Local_Requirment_Set__c != newGrping.Local_Requirment_Set__c)){
                    newGrping.Process_Rules__c = true;
                    newGrping.Process_On_After__c = System.Now();
                }
            }
        
            // check if it PAN Theater and cluster, tier poupulated set populated then set Process_Rules__c = true
            if(mapQueriedGrouping.get(newGrping.Id).RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                if(newGrping.Theater2__c != null && newGrping.Theater2__c != '' && oldGrouping.get(newGrping.Id).Theater2__c != newGrping.Theater2__c
                   && newGrping.Target_Tier__c != null && newGrping.Target_Tier__c != '' && oldGrouping.get(newGrping.Id).Target_Tier__c != newGrping.Target_Tier__c){
                    newGrping.Process_Rules__c = true;
                    newGrping.Process_On_After__c = System.Now();
                }
            }
        // In both cased - Change Process_ON/After date with current time  
        }
        
    }
    
    
    /* @syncPANAttributes <PRM_PAN_VPP_Operations(): This method get called from Grouping Before Update Trigger checks if attributes updated and 
                                                    sets back to account.>
       @param -  Map<id,Account_Groupings__c> oldGrouping,Map<id,Account_Groupings__c> newGrouping - Old and new maps from trigger
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    public void syncPANAttributes(Map<id,Account_Groupings__c> oldGrouping,Map<id,Account_Groupings__c> newGrouping){
        map<Id,Account_Groupings__c> mapPAN = new map<Id,Account_Groupings__c>();
        map<Id,Account_Groupings__c> mapLogicalBlock = new map<Id,Account_Groupings__c>();
        map<Id,Account_Groupings__c> mapLogicalBlockUnderPAN = new map<Id,Account_Groupings__c>();
        map<Id,Account_Groupings__c> mapCountryGrouping = new map<Id,Account_Groupings__c>();
        list<Account_Groupings__c> lstGroupingToUpdate = new list<Account_Groupings__c>();
        list<Account> lstAccountUnderCountryGrouping = new list<Account>();
        list<Account> lstAccount = new list<Account>();
        map<Id,Account_Groupings__c> mapQueriedGrouping = new map<Id,Account_Groupings__c>([Select Id,Account__c,Profiled_Account__c,Active__c,Cluster__c,
                                                    Target_Tier__c,Deployed_To__c,Pan_Theater_Level_Grouping__c,Velocity_Specaility_Achieved__c,Logical_Block_Level_Grouping__c,
                                                    Theater2__c,Local_Requirment_Set__c,Process_On_After__c,Process_Rules__c,RecordType.DeveloperName
                                                    from Account_Groupings__c
                                                    where Id in: newGrouping.keyset()]); 
          system.debug('mapQueriedGrouping at the top----->' +mapQueriedGrouping );    
        
         for(Account_Groupings__c newGrping: newGrouping.values()){
             // check if Grouping is PAN Theater type and folowing attributes updated
             //1) Deployed_To__c
             //2) Velocity Specialties achieved
             // Update the values All Profiled accounts under PAN Theater from PAN Theater 
             // Change Process_ON/After date with current time 
            if(mapQueriedGrouping.get(newGrping.Id).RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                if(oldGrouping.get(newGrping.Id).Deployed_To__c != newGrping.Deployed_To__c
                   ){
                    mapPAN.put(newGrping.Id,newGrping);                
                }
            }
        
            // check if Grouping is Logical Block type and folowing attributes updated
            //1) PAN Theater 
           //2) Deployed_To__c
           //3) Velocity Specialties achieved 
          // Update All Profiled accounts under Logical Block  with values from PAN Theater/Logical block (if PAN Theater is not null else from Logical Block)
          // Change Process_ON/After date with current time 
            if(mapQueriedGrouping.get(newGrping.Id).RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){
                if(newGrping.Pan_Theater_Level_Grouping__c != null && oldGrouping.get(newGrping.Id).Pan_Theater_Level_Grouping__c != newGrping.Pan_Theater_Level_Grouping__c || 
                   (oldGrouping.get(newGrping.Id).Consolidate_Specialty__c != newGrping.Consolidate_Specialty__c ||
                    oldGrouping.get(newGrping.Id).Advanced_Consolidate_Specialty__c  != newGrping.Advanced_Consolidate_Specialty__c  ||
                    oldGrouping.get(newGrping.Id).Backup_and_Recovery_Specialty__c  != newGrping.Backup_and_Recovery_Specialty__c  ||
                    oldGrouping.get(newGrping.Id).Governance_and_Archive_Specialty__c  != newGrping.Governance_and_Archive_Specialty__c  ||
                    oldGrouping.get(newGrping.Id).Isilon_Track_Specialty__c  != newGrping.Isilon_Track_Specialty__c  ||
                    oldGrouping.get(newGrping.Id).Cloud_Builder_Specialty__c  != newGrping.Cloud_Builder_Specialty__c ||
                    oldGrouping.get(newGrping.Id).Cloud_Provider_Practice__c  != newGrping.Cloud_Provider_Practice__c )                  
                 ){
                    mapLogicalBlockUnderPAN.put(newGrping.Id,newGrping);
                }
                if((newGrping.Pan_Theater_Level_Grouping__c == null && oldGrouping.get(newGrping.Id).Pan_Theater_Level_Grouping__c != newGrping.Pan_Theater_Level_Grouping__c)
                || (newGrping.Pan_Theater_Level_Grouping__c == null && 
                (oldGrouping.get(newGrping.Id).Deployed_To__c != newGrping.Deployed_To__c || 
                 oldGrouping.get(newGrping.Id).Consolidate_Specialty__c != newGrping.Consolidate_Specialty__c ||
                 oldGrouping.get(newGrping.Id).Advanced_Consolidate_Specialty__c  != newGrping.Advanced_Consolidate_Specialty__c  ||
                 oldGrouping.get(newGrping.Id).Backup_and_Recovery_Specialty__c  != newGrping.Backup_and_Recovery_Specialty__c  ||
                 oldGrouping.get(newGrping.Id).Governance_and_Archive_Specialty__c  != newGrping.Governance_and_Archive_Specialty__c  ||
                 oldGrouping.get(newGrping.Id).Isilon_Track_Specialty__c  != newGrping.Isilon_Track_Specialty__c  ||
                 oldGrouping.get(newGrping.Id).Cloud_Builder_Specialty__c  != newGrping.Cloud_Builder_Specialty__c ||
                 oldGrouping.get(newGrping.Id).Cloud_Provider_Practice__c  != newGrping.Cloud_Provider_Practice__c            
                ))){ 
                    mapLogicalBlock.put(newGrping.Id,newGrping);
                }
            }
            // check if Grouping is Coutnry Level type and folowing attributes updated
          //1) Logical Block
          // Update Profield Account on Grouping to populate values from PAN Theater/Logical block (if PAN Theater is not null else from Logical Block)
          // Change Process_ON/After date with current time 
             if(mapQueriedGrouping.get(newGrping.Id).RecordType.DeveloperName == 'Partner_Grouping'){
                if(oldGrouping.get(newGrping.Id).Logical_Block_Level_Grouping__c != newGrping.Logical_Block_Level_Grouping__c){  
                    mapCountryGrouping.put(newGrping.Id,newGrping);
                }
            }
    
        }
        if(!mapPAN.isEmpty()){
            if(lstAccount.size()>0){
                lstAccount.addAll(updateProfiledAccountUnderPANLevel(mapPAN));
            }else{
                system.debug('BEFORE-------->' +lstAccount);
                lstAccount = updateProfiledAccountUnderPANLevel(mapPAN);
                system.debug('AFTER-------->' +lstAccount);
            }
        }
        if(!mapLogicalBlockUnderPAN.isEmpty()){
            if(lstAccount.size()>0){
                lstAccount.addAll(updateProfiledAccountOnPANUpdationOnLB(mapLogicalBlockUnderPAN));
            }else{
                lstAccount = updateProfiledAccountOnPANUpdationOnLB(mapLogicalBlockUnderPAN);
            }
        }
        if(!mapLogicalBlock.isEmpty()){
            if(lstAccount.size()>0){
                lstAccount.addAll(updateProfiledAccountUnderLogicalBlock(mapLogicalBlock));
            }else{
                lstAccount = updateProfiledAccountUnderLogicalBlock(mapLogicalBlock);
            }           
        }
        if(!mapCountryGrouping.isEmpty()){
            if(lstAccount.size()>0){
                lstAccount.addAll(updateProfiledAccountOnLogicalBlockUpdationOnGrouping(mapCountryGrouping));
            }else{
                lstAccount = updateProfiledAccountOnLogicalBlockUpdationOnGrouping(mapCountryGrouping);
            }
        }

        if(lstAccount.size()>0){
             system.debug('IN-------->' +lstAccount);
            //Util.isPopulateVelocitySpecialty = false;
            update lstAccount;
            system.debug('AFTER UPDATE------->' +lstAccount);
        }          
    }
    
    /* @syncPANAttributes <PRM_PAN_VPP_Operations(): This method get called from Account Before Update Trigger checks if attributes updated and 
                                                    sets back to account.>
       @param -  Map<id,Account> oldAccounts,Map<id,Account> newAccounts- Old and new maps from trigger
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    public void syncPANAttributes(Map<id,Account> oldAccounts,Map<id,Account> newAccounts){     
        map<Id,Account> mapAccounts = new map<Id,Account>();
        list<Account> lstAccount = new list<Account>();
        // check if Grouping is updated on Account and Grouping has Logical Block or PAN Theater on it
        //update below values on current profiled account from PAN Theater/Logical Block
        //2) Deployed_To__c
        //3) Velocity Specialties achieved 
        for(Account profiledAccount: newAccounts.values()){
            if(profiledAccount.Grouping__c != null && profiledAccount.Grouping__c != oldAccounts.get(profiledAccount.Id).Grouping__c){
                mapAccounts.put(profiledAccount.Id,profiledAccount);
            }
        }
        if(!mapAccounts.isEmpty()){
            lstAccount = [Select a.Grouping__c,a.PROFILED_ACCOUNT_FLAG__c,Velocity_Specialties_Achieved__c,a.Id,a.Grouping__r.Logical_Block_Level_Grouping__c,a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,
                            a.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c,
                            Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c,Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c,
                            a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c
                            from Account a where a.Id in: mapAccounts.keyset()];
        }
        if(lstAccount.size()>0){
            for(Account profiledAccount:lstAccount){
                if(profiledAccount.Grouping__r.Logical_Block_Level_Grouping__c != null){
                    if(profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c != null){
                        //mapAccounts.get(profiledAccount.Id).Velocity_Specialties_Achieved__c = //profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c;
                    }else{
                       //mapAccounts.get(profiledAccount.Id).Velocity_Specialties_Achieved__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c;
                    }
                }
            }
        }
    }

    public list<Account> updateProfiledAccountUnderPANLevel(map<Id,Account_Groupings__c> mapPAN){
        list<Account> lstAccountUnderPAN = new list<Account>();
        if(!mapPAN.isEmpty()){
            lstAccountUnderPAN = [Select a.Grouping__c,Velocity_Solution_Provider_Tier__c,a.PROFILED_ACCOUNT_FLAG__c,Velocity_Specialties_Achieved__c,a.Id,a.Grouping__r.Logical_Block_Level_Grouping__c,a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,
                                  a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                  a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c 
                                  from Account a where a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c in: mapPAN.keyset() and a.PROFILED_ACCOUNT_FLAG__c = true];
        }
        if(lstAccountUnderPAN.size()>0){
            for(Account profiledAccount: lstAccountUnderPAN){
                //profiledAccount.Velocity_Specialties_Achieved__c = //profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c;
                profiledAccount.Velocity_Solution_Provider_Tier__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c;
            }
        }
        return lstAccountUnderPAN;
    }

    public list<Account> updateProfiledAccountUnderLogicalBlock(map<Id,Account_Groupings__c> mapLogicalBlock){
        list<Account> lstAccountUnderLogicalBlock = new list<Account>();
        lstAccountUnderLogicalBlock = [Select a.Grouping__c,Velocity_Solution_Provider_Tier__c,a.PROFILED_ACCOUNT_FLAG__c,a.Velocity_Specialties_Achieved__c,a.Id,a.Grouping__r.Logical_Block_Level_Grouping__c,
                                       a.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c,Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c,
                                       Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c   
                                       from Account a where a.Grouping__r.Logical_Block_Level_Grouping__c in: mapLogicalBlock.keyset() and a.PROFILED_ACCOUNT_FLAG__c = true];
        if(lstAccountUnderLogicalBlock.size()>0){
            for(Account profiledAccount: lstAccountUnderLogicalBlock){
               //profiledAccount.Velocity_Specialties_Achieved__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c;
               profiledAccount.Velocity_Solution_Provider_Tier__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c;
               profiledAccount.Cloud_Builder_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c;
               profiledAccount.Cloud_Provider_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c;
               profiledAccount.Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c;
               profiledAccount.Advanced_Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c;
               profiledAccount.Backup_and_Recovery_Speciality__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c;
               profiledAccount.Governance_and_Archive_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c;
               profiledAccount.Isilon_Track_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c;
            }
        }
        return lstAccountUnderLogicalBlock;
    }
    
    public list<Account> updateProfiledAccountOnPANUpdationOnLB(map<Id,Account_Groupings__c> mapLogicalBlockUnderPAN){
        list<Account> lstAccountUnderPANOnUpdation = new list<Account>();
        if(!mapLogicalBlockUnderPAN.isEmpty()){ 
            lstAccountUnderPANOnUpdation = [Select a.Grouping__c,Velocity_Solution_Provider_Tier__c,a.PROFILED_ACCOUNT_FLAG__c,Velocity_Specialties_Achieved__c,a.Id,a.Grouping__r.Logical_Block_Level_Grouping__c,a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,
                                            a.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c,a.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c,Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c                    
                                            from Account a where a.Grouping__r.Logical_Block_Level_Grouping__c in: mapLogicalBlockUnderPAN.keyset() and a.PROFILED_ACCOUNT_FLAG__c = true];
        }
        if(lstAccountUnderPANOnUpdation.size()>0){
            for(Account profiledAccount: lstAccountUnderPANOnUpdation){
               //profiledAccount.Velocity_Specialties_Achieved__c = //profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c;
               profiledAccount.Velocity_Solution_Provider_Tier__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c; 
               profiledAccount.Cloud_Builder_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c;
               profiledAccount.Cloud_Provider_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c;
               profiledAccount.Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c;
               profiledAccount.Advanced_Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c;
               profiledAccount.Backup_and_Recovery_Speciality__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c;
               profiledAccount.Governance_and_Archive_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c;
               profiledAccount.Isilon_Track_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c;
            }
        }
        return lstAccountUnderPANOnUpdation;
    }

    public list<Account> updateProfiledAccountOnLogicalBlockUpdationOnGrouping(map<Id,Account_Groupings__c> mapLogicalBlock){
        list<Account> lstAccountUnderPANOnUpdation = new list<Account>();
        if(!mapLogicalBlock.isEmpty()){
            lstAccountUnderPANOnUpdation = [Select a.Grouping__c,Velocity_Solution_Provider_Tier__c,a.PROFILED_ACCOUNT_FLAG__c,Velocity_Specialties_Achieved__c,a.Id,a.Grouping__r.Logical_Block_Level_Grouping__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c,a.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c,Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c,
                                            Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c  
                                            from Account a where a.Grouping__c in: mapLogicalBlock.keyset() and a.PROFILED_ACCOUNT_FLAG__c = true];
        }
        if(lstAccountUnderPANOnUpdation.size()>0){
            for(Account profiledAccount: lstAccountUnderPANOnUpdation){
                if(profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__c != null){
                    //profiledAccount.Velocity_Specialties_Achieved__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Velocity_Specaility_Achieved__c;
                    profiledAccount.Velocity_Solution_Provider_Tier__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Pan_Theater_Level_Grouping__r.Deployed_To__c;
                    profiledAccount.Cloud_Builder_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c;
                    profiledAccount.Cloud_Provider_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c;
                    profiledAccount.Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c;
                    profiledAccount.Advanced_Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c;
                    profiledAccount.Backup_and_Recovery_Speciality__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c;
                    profiledAccount.Governance_and_Archive_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c;
                    profiledAccount.Isilon_Track_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c;
                } 
                else if(profiledAccount.Grouping__r.Logical_Block_Level_Grouping__c != null){
                    //profiledAccount.Velocity_Specialties_Achieved__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Velocity_Specaility_Achieved__c;
                    profiledAccount.Velocity_Solution_Provider_Tier__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Deployed_To__c;
                    profiledAccount.Cloud_Builder_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c;
                    profiledAccount.Cloud_Provider_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c;
                    profiledAccount.Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c;
                    profiledAccount.Advanced_Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c;
                    profiledAccount.Backup_and_Recovery_Speciality__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c;
                    profiledAccount.Governance_and_Archive_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c;
                    profiledAccount.Isilon_Track_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c;  
                }
                else if(profiledAccount.Grouping__r.Logical_Block_Level_Grouping__c == null){
                    //profiledAccount.Velocity_Specialties_Achieved__c = '';
                    profiledAccount.Velocity_Solution_Provider_Tier__c = ''; 
                    profiledAccount.Cloud_Builder_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Builder_Specialty__c;
                    profiledAccount.Cloud_Provider_Practice__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Cloud_Provider_Practice__c;
                    profiledAccount.Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Consolidate_Specialty__c;
                    profiledAccount.Advanced_Consolidate_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Advanced_Consolidate_Specialty__c;
                    profiledAccount.Backup_and_Recovery_Speciality__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Backup_and_Recovery_Specialty__c;
                    profiledAccount.Governance_and_Archive_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Governance_and_Archive_Specialty__c;
                    profiledAccount.Isilon_Track_Specialty__c = profiledAccount.Grouping__r.Logical_Block_Level_Grouping__r.Isilon_Track_Specialty__c;  
                }          
            }
        }
        return lstAccountUnderPANOnUpdation;
    }
    public void syncSpecialitiesAcheived(List<Account_Groupings__c> lstAccountGroupingToSync){ 
        List<Account_Groupings__c> lstAccGroupingToUpdate = new list<Account_Groupings__c>();
        for(Account_Groupings__c groupingObj : lstAccountGroupingToSync){
           groupingObj.Velocity_Specaility_Achieved__c = '';                       
           if ( groupingObj.Consolidate_Specialty__c == 'Deployed'){              
                groupingObj.Velocity_Specaility_Achieved__c = 'Consolidate;' ;                
           }       
           if ( groupingObj.Advanced_Consolidate_Specialty__c == 'Deployed'){              
                groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Advanced Consolidate;' ;               
           }           
           if ( groupingObj.Backup_and_Recovery_Specialty__c == 'Deployed'){             
                groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Backup and Recovery;' ;                
           }           
           //Commented as part of the WR239600
           /*if ( groupingObj.Governance_and_Archive_Specialty__c == 'Deployed'){              
                    groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Governance and Archive;' ;               
           }*/           
           if ( groupingObj.Cloud_Builder_Specialty__c == 'Deployed'){              
                    groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Cloud Builder;' ;
               
           }
           //Commented as part of the WR239600    
           /*if ( groupingObj.Cloud_Provider_Practice__c == 'Deployed'){              
                    groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Cloud Provider;' ;
               
           }*/
           if ( groupingObj.Isilon_Track_Specialty__c == 'Deployed'){              
                    groupingObj.Velocity_Specaility_Achieved__c = groupingObj.Velocity_Specaility_Achieved__c+'Isilon Track;' ;
               
           }
           if (groupingObj.Velocity_Specaility_Achieved__c != null){
               groupingObj.Velocity_Specaility_Achieved__c = ((string)groupingObj.Velocity_Specaility_Achieved__c).replace('null', '');
               lstAccGroupingToUpdate.add(groupingObj);
           }
        }         
    }
   //WR 210949 -- Method has been added for rolling up the specialities achieved at logical block to Pan level.  
    public void RollupSpecialitiesPanlevel(List<Account_Groupings__c> lstLogicalBlocks){
    	
    	List<Account_Groupings__c> lstPanAccGroupingToUpdate = new list<Account_Groupings__c>();
    	map<Id,Account_Groupings__c> accntGroupIds = new map<Id,Account_Groupings__c>();
    	map<Id,Account_Groupings__c> finalaccntGroupIds = new map<Id,Account_Groupings__c>();  	
    	for(Account_Groupings__c accntGroup: lstLogicalBlocks){
    		system.debug('lstLogicalBlocks is  ----->' +lstLogicalBlocks );
    		system.debug('accntGroup.RecordType.DeveloperName is  ----->' +accntGroup.RecordType.DeveloperName );
    		//if(accntGroup.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block')
    		accntGroupIds.put(accntGroup.id, accntGroup);
    	}    	
    	system.debug('accntGroupIds is  ----->' +accntGroupIds );
    	Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();    
    	if(accntGroupIds != null && accntGroupIds.size() > 0 && DataValueMap.get('Partner Grouping Logical Block') != null){
    		list<id> panGroupIds = new list<id>();
    		String logicalblockrecordId = DataValueMap.get('Partner Grouping Logical Block').DataValue__c;
    		system.debug('panlogicalblock is  ----->' +logicalblockrecordId);
    		//list<Account_Groupings__c> panGroups = [Select id, Pan_Theater_Level_Grouping__c,RecordType.DeveloperName from Account_Groupings__c where id in :accntGroupIds.keySet()];
    		//system.debug('panGroups is  ----->' +panGroups);
    		
    		for(Account_Groupings__c pangroup: lstLogicalBlocks){
    			if(pangroup.RecordTypeId == logicalblockrecordId)
    				panGroupIds.add(pangroup.Pan_Theater_Level_Grouping__c);
    		}
    		list<Account_Groupings__c> accntGroups = new list<Account_Groupings__c>();
    		if(panGroupIds.size() > 0){
	    			accntGroups = [Select Consolidate_Specialty__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, 
		    	Governance_and_Archive_Specialty__c, Cloud_Builder_Specialty__c, Cloud_Provider_Practice__c,Isilon_Track_Specialty__c, Pan_Theater_Level_Grouping__c 
		    	from Account_Groupings__c where id in :panGroupIds];
    		} 
    		system.debug('accntGroups is  ----->' +accntGroups);	    		    	   	
	    	list<id> panIds = new list<id>();
	    	for(Account_Groupings__c panId: accntGroups){
	    		finalaccntGroupIds.put(panId.Id, panId);
	    		panIds.add(panId.id);
	    			    		
	    	}
	    	system.debug('finalaccntGroupIds is  ----->' +finalaccntGroupIds );    
	    	
	    	PRM_PAN_VPP_VelocityRuleResultsUtils panUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
	    	Map<Id,List<Account_Groupings__c>> mapPANAndLogicalBlock = panUtils.getLogicalBlockUnderPAN(panIds);
	    	system.debug('mapPANAndLogicalBlock is  ----->' +mapPANAndLogicalBlock ); 
	    	integer i = 1;
	    	
	    	for(Account_Groupings__c newPanIds: finalaccntGroupIds.Values()){
	    		system.debug('accntGroups is  -----> '+i+' '+accntGroups ); 
	    		list<Account_Groupings__c> logblocks = mapPANAndLogicalBlock.get(newPanIds.Id);
	    		if(logblocks != null && logblocks.size() > 0){
	    			system.debug('logblocks is  -----> '+i+' '+logblocks ); 
	    			newPanIds.Consolidate_Specialty__c = 'Not Deployed';
					newPanIds.Advanced_Consolidate_Specialty__c = 'Not Deployed';
					newPanIds.Backup_and_Recovery_Specialty__c = 'Not Deployed'; 
			    	newPanIds.Governance_and_Archive_Specialty__c = 'Not Deployed';
					newPanIds.Cloud_Builder_Specialty__c = 'Not Deployed';
					newPanIds.Cloud_Provider_Practice__c = 'Not Deployed';
					newPanIds.Isilon_Track_Specialty__c = 'Not Deployed'; 		
		    		    		    		
		    		for(Account_Groupings__c accntgrp:logblocks){
			    		if(accntgrp.Consolidate_Specialty__c == 'Deployed' && newPanIds.Consolidate_Specialty__c != 'Deployed'){
			    			system.debug('Consolidate_Specialty__c is Deployed '+i+' '+accntgrp.Consolidate_Specialty__c ); 
			    			newPanIds.Consolidate_Specialty__c = 'Deployed';
			    		}
			    		if(accntgrp.Advanced_Consolidate_Specialty__c == 'Deployed' && newPanIds.Advanced_Consolidate_Specialty__c != 'Deployed'){
			    			system.debug('Advanced_Consolidate_Specialty__c is Deployed '+i+' '+accntgrp.Advanced_Consolidate_Specialty__c );
			    			newPanIds.Advanced_Consolidate_Specialty__c = 'Deployed';
			    		}
			    		if(accntgrp.Backup_and_Recovery_Specialty__c == 'Deployed' && newPanIds.Backup_and_Recovery_Specialty__c != 'Deployed'){
			    			system.debug('Backup_and_Recovery_Specialty__c is Deployed '+i+' '+accntgrp.Backup_and_Recovery_Specialty__c );
			    			newPanIds.Backup_and_Recovery_Specialty__c = 'Deployed';
			    		}
			    		//Commented as part of the WR239600
			    		/*if(accntgrp.Governance_and_Archive_Specialty__c == 'Deployed' && newPanIds.Governance_and_Archive_Specialty__c != 'Deployed'){
			    			system.debug('Governance_and_Archive_Specialty__c is Deployed '+i+' '+accntgrp.Governance_and_Archive_Specialty__c );
			    			newPanIds.Governance_and_Archive_Specialty__c = 'Deployed';
			    		}*/
			    		if(accntgrp.Cloud_Builder_Specialty__c == 'Deployed' && newPanIds.Cloud_Builder_Specialty__c != 'Deployed'){
			    			system.debug('Cloud_Builder_Specialty__c is Deployed '+i+' '+accntgrp.Cloud_Builder_Specialty__c );
			    			newPanIds.Cloud_Builder_Specialty__c = 'Deployed';
			    		}
			    		//Commented as part of the WR239600
			    		/*if(accntgrp.Cloud_Provider_Practice__c == 'Deployed' && newPanIds.Cloud_Provider_Practice__c != 'Deployed'){
			    			system.debug('Cloud_Provider_Practice__c is Deployed '+i+' '+accntgrp.Cloud_Provider_Practice__c );
			    			newPanIds.Cloud_Provider_Practice__c = 'Deployed';
			    		}*/
			    		if(accntgrp.Isilon_Track_Specialty__c == 'Deployed' && newPanIds.Isilon_Track_Specialty__c != 'Deployed'){
			    			system.debug('Isilon_Track_Specialty__c is Deployed '+i+' '+accntgrp.Isilon_Track_Specialty__c );
			    			newPanIds.Isilon_Track_Specialty__c = 'Deployed';
			    		}
			    	}
	    		}
		    	lstPanAccGroupingToUpdate.add(newPanIds);
		    	system.debug('lstPanAccGroupingToUpdate is '+i+' '+newPanIds);
		    	i++;
	    	}
    	}
    	if(lstPanAccGroupingToUpdate.size() > 0 && rollupcheck == false){
    		try{
    			system.debug('lstPanAccGroupingToUpdate inside commit is '+lstPanAccGroupingToUpdate);
    			Database.update(lstPanAccGroupingToUpdate);
    			rollupcheck = true;
    		}catch(exception e){
    			rollupcheck = false;
    		}
    		
    	}   	
    	
    }
    
    
}