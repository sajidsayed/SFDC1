//DO NOT CHANGE THE API VERSION,The API Version must be 16.0
/*
* Last Modified by:- Sunil Arora
* Reason          :- Updated the Code to check the record typoe id before doing the functionality so that it will not work for Events with "Briefing Event" record type.
*/
trigger PopulateRelatedToFieldOnEvent on Event (before insert,before Update,after insert,after Update) {
    //This code is used here to get record type id
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Event;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('Briefing Event');
    Id rTypeId= record_Type_name_RT.getRecordTypeId();

    Map <String,String> activities= new Map <String,String>();
    List<Event>events = new List<Event>();
    List<String> contact_ids= new List<String>();
    
    for(integer i=0;i<trigger.new.size();i++){
          if(trigger.new[i].RecordTypeId!=rTypeId)
          {
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
                events.add(Trigger.new[i]); 
            }
          } 
        
    }
    System.debug('activities.size() '+activities.size());
    if(Trigger.isAfter && activities.size()>0  && Util.isFeatureCalledonAcitivity){
          Util.isFeatureCalledonAcitivity=false;  
          RelateAccountonActivities.populateAccountOfLeadOnEvenet(activities);
    }
    if(Trigger.isBefore && contact_ids.size()>0){
        new RelateAccountonActivities().populateAccountOfContactOnEvent(events,contact_ids);
    }

}