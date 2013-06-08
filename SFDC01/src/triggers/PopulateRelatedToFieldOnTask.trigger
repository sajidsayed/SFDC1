//DO NOT CHANGE THE API VERSION,The API Version must be 16.0


trigger PopulateRelatedToFieldOnTask on Task (before insert,before Update,after insert,after Update) {
    Map <String,String> activities= new Map <String,String>();

    List<Task>tasks = new List<Task>();
    List<String> contact_ids= new List<String>();
    
    for(integer i=0;i<trigger.new.size();i++){
        String whoid=Trigger.new[i].WhoId;
        if(whoid==null){
            continue;
        }
        System.debug('whoid '+ whoid);
        System.debug('WhatId '+ Trigger.new[i].WhatId); 
        if( whoid.startsWith('00Q')&& Trigger.new[i].WhatId==null){
            activities.put(Trigger.new[i].id,Trigger.new[i].WhoId);
        }
        else if(whoid.startsWith('003')&& Trigger.new[i].WhatId==null){
            contact_ids.add(whoid);
            tasks.add(Trigger.new[i]); 
        }
    }
    System.debug('activities.size() '+activities.size());
    if(Trigger.isAfter && activities.size()>0 && Util.isFeatureCalledonAcitivity ){
          Util.isFeatureCalledonAcitivity=false;  
          RelateAccountonActivities.populateAccountOfLeadOnTask(activities);
    }
    if(Trigger.isBefore && contact_ids.size()>0){
        new RelateAccountonActivities().populateAccountOfContactOnTask(tasks,contact_ids);
    }

}