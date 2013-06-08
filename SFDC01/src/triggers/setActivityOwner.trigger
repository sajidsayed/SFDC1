/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/

trigger setActivityOwner on Lead (after update) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
     }     
        String [] leadids= new String [200];  
        integer counter=0;         
                  
         if(!Util.setActivityOwnerAfter){
              return;  
          }
          Util.setActivityOwnerAfter=false;
            
          // if lead is not accepted 
            
            // Get all Configurations
            List <Configuration__c> Configs=new List <Configuration__c>(); 
            Configs = [Select Module__c, Type__c, Value__c, Value2__c from Configuration__c where Module__c='Commercial & CMA' and Key__c='SetActivityOwner']; 
            System.debug(Configs);
           
            Set<String> owners= new Set<String>(); 
            for(Integer i=0;i<Trigger.new.size();i++){  
                owners.add(Trigger.new[i].ownerid);      
                owners.add(Trigger.old[i].ownerid);      
            }

            Map <id,User> users=Util.getUsers(Configs,owners);
            System.debug('users '+users);
            
            for(Integer i=0;i<Trigger.new.size();i++){  
                if(Trigger.new[i].OwnerId != Trigger.old[i].OwnerId || Trigger.new[i].Accept_Lead__c  != Trigger.old[i].Accept_Lead__c ) {
                         System.debug('hi 1'+Trigger.new[i].Ownerid);
                         System.debug('hi 1'+Trigger.old[i].Ownerid);
                    if( users.get(Trigger.new[i].Ownerid)!=null &&  users.get(Trigger.old[i].Ownerid)!=null ){
                                    System.debug('((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c ' +((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c);
                                    System.debug('((User)users.get(Trigger.old[i].Ownerid)).Profile_Name__c ' +((User)users.get(Trigger.old[i].Ownerid)).Profile_Name__c);
                            for(Configuration__c confg :Configs){
                                String UserProfileTo=confg.Value2__c+',';
                                String UserProfileFrom=confg.Value__c+',';
                                System.debug('((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c+'+((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c+',');
                                if(  UserProfileTo.Contains(((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c+',') && 
                                     (UserProfileFrom.Contains(((User)users.get(Trigger.old[i].Ownerid)).Profile_Name__c+',') ||
                                      UserProfileFrom.Contains(((User)users.get(Trigger.old[i].Ownerid)).Profile_Name__c+',')) &&
                                    Trigger.new[i].Accept_Lead__c ==false){ 
                                         leadids[counter]=Trigger.new[i].id;
                                         counter++;  
                                         break;
                                }
                            }
                     }
                }
             }

             if(counter!=0){        
                System.debug('Going to call ........'+leadids);
                SetActivityOwner.updateOwner(leadids); 
                return;
            }

            // if lead is accepted

            Map <String,String> LeadOwners = new Map <String,String>();
            for(Integer i=0;i<Trigger.new.size();i++){  
               if(Trigger.new[i].OwnerId != Trigger.old[i].OwnerId || Trigger.new[i].Accept_Lead__c  != Trigger.old[i].Accept_Lead__c ) {
                    if( users.get(Trigger.new[i].Ownerid)!=null){  
                        for(Configuration__c confg :Configs){
                               String UserProfileTo=confg.Value2__c+',';
                               String UserProfileFrom=confg.Value__c+',';
                            if(  UserProfileTo.Contains(((User)users.get(Trigger.new[i].Ownerid)).Profile_Name__c+',') && Trigger.new[i].Accept_Lead__c ==true){
                                    LeadOwners.put(Trigger.new[i].id,Trigger.new[i].OwnerId);
                            }
                        }
                    }
                 }
             }
            
           // Get all open activites
            List <Event> events=new List <Event>(); 
            events = [Select id, EndDateTime,StartDateTime,ownerId,whoid from Event  where whoid in:LeadOwners.keyset() and Type='Appointment Set (SA)' and  endDateTime >=:System.now() and startDateTime>=:System.now()]; 
            if(events.size()>0){
                for(Event et :events){
                          et.ownerid=LeadOwners.get(et.whoid);
                }       
                 update events;
            }
         
     }