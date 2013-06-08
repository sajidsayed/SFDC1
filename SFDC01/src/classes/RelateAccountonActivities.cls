//DO NOT CHANGE THE API VERSION,The API Version must be 16.0

global class RelateAccountonActivities{

@future
public static void populateAccountOfLeadOnTask(Map<String,String>activities ){

    Map<Id,Lead> Leads = new Map<Id,Lead>([Select id,Related_Account__c from Lead where Id in :activities.values() ]);
      List <Task> tasks = [Select id,whatid,whoid from Task where id in :activities.keySet()];         
    System.debug('Hi');
     for(integer i=0; i<tasks.size();i++){
        Lead whoLead=Leads.get(tasks[i].whoId);
        if(whoLead != null){
            tasks[i].WhatId=whoLead.Related_Account__c;
        }
    }
   update tasks; 
}

@future
public static void populateAccountOfLeadOnEvenet(Map<String,String>activities ){
       Map<Id,Lead> Leads = new Map<Id,Lead>([Select id,Related_Account__c from Lead where Id in :activities.values() ]);
       List <Event> events = [Select id,whatid,whoid from Event where id in :activities.keySet()];         
        System.debug('Hi');
         for(integer i=0; i<events.size();i++){
            Lead whoLead=Leads.get(events[i].whoId);
            if(whoLead != null){
                events[i].WhatId=whoLead.Related_Account__c;
            }
        }
       update events; 
    
}   

public void populateAccountOfContactOnTask(List<Task>tasks, List<String> contact_ids){
    
    Map<Id,Contact> contacts = new Map<Id,Contact>([Select id,AccountId from Contact where Id in :contact_ids]);
    System.debug('Hi');
    for(integer i=0; i< tasks.size();i++){
        Contact con =contacts.get((tasks[i]).whoId);
        if(con != null){
            tasks[i].WhatId=con.accountId;
        }
    }
    
  }   
 
public void populateAccountOfContactOnEvent(List<Event>events, List<String> contact_ids){
    
    Map<Id,Contact> contacts = new Map<Id,Contact>([Select id,AccountId from Contact where Id in :contact_ids]);
    System.debug('Hi');
    for(integer i=0; i< events.size();i++){
        Contact con =contacts.get((events[i]).whoId);
        if(con != null){
            events[i].WhatId=con.accountId;
        }
    }
    
  }   


}