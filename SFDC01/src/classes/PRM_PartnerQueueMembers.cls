/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  03.11.2010      Suman B         #1297      This Class will be used for Email Notification to Partner Queue
 |                                               Users when assigned to a lead.           
 |  23.11.2010      Suman B                    Modified the getGroupMembers() method as per the change in the
 |                                               approach.    
 |  30.05.2011      Saravanan C    Prodn -     Fix on the production validation error (June Release) -  
 |                                Validn Error  System.QueryException: Aggregate query has too many rows for direct
 |                                              assignment, use FOR loop stack Class.PRM_PartnerQueueMembers.getGroupMembers:
 |                                              
 +========================================================================================================================*/
Public Class PRM_PartnerQueueMembers {
  
  Public List<Lead> listLead = new List<Lead>(); 

/* @Method <getPartnerQueueLeads():  Retrives the Leads assigned to 
                                     Queues starting with name 'Partner'  
                                     and modified in last 24hours>
       @param - <void>
       @return  <Lead List> 
       @throws exception - <No Exception>
    */
  Public List<Lead> getPartnerQueueLeads(){
    DateTime yesterdayDate = system.now() -1 ;
    system.debug('#####  ' + yesterdayDate );
    String inputqry =   'Partner' + '%' ;
    List<Id> listGroupid = new List<Id>();
    List<Group>   listGroupQueue = [SELECT g.Id, g.name 
                                    FROM Group g 
                                    WHERE g.name like : inputqry ];

     for(Group gp : listGroupQueue ){ 
       listGroupid.add(gp.id) ;
     }
     listLead = [ select id,name,ownerId,owner.name from lead where ownerid in:listGroupid and lastmodifieddate > : yesterdayDate ] ;
     system.debug('LEADDDDDDDDDDDDDDDDDDDD ######################### ' + listLead) ;
     return listLead ;
   } // End of method - getPartnerQueueLeads . 

  /* @Method <getGroupMembers(): Retrives the Users in a Queue through  
                                  the Contacts associated with Account>
       @param - <void>
       @return  <User List> 
       @throws exception - <No Exception>
    */
  Public List<User> getGroupMembers(){
     List<Lead> leadlist = getPartnerQueueLeads();
     set<String> setQueuename = new set<string>();
     set<Contact> setContact = new set<Contact>();
     List<User> listUsers = new List<User>() ;
      if(leadlist !=null && leadlist.size() >0 ) {
        for(Lead leadobj :leadlist) { 
         setQueuename.add(leadobj.owner.name);
        }
    List<Id> listId = new List<Id>();
    
    Account[] acc = [SELECT id, name, Queue_Name__c, 
                            (SELECT id,name,Email  
                                   FROM contacts 
                                   WHERE Active__c = TRUE AND
                                   RecordType.DeveloperName = 'Partner_Contact')
                              FROM Account 
                              WHERE Queue_Name__c in : setQueuename ];
                              
       for (Account a: acc){
           for(Contact c: a.contacts){
             listId.add(c.id);
           }
       }                       
    
  /*   for (Account acc : [SELECT id, name, Queue_Name__c, 
                            (SELECT id,name,Email  
                                   FROM contacts 
                                   WHERE Active__c = TRUE AND
                                   RecordType.DeveloperName = 'Partner_Contact')
                              FROM Account 
                              WHERE Queue_Name__c in : setQueuename ]) {
           if(acc.contacts.size() > 0 ){
             setContact.addall(acc.contacts);
            }
        }
       for(Contact contactObj : setContact){
           listId.add(contactObj.id);
        }
     */  listUsers = [SELECT id,name,email 
                           FROM User 
                           WHERE Opt_Out_of_Notifications__c = FALSE
                           AND ContactId in : listId ];
                           
      system.debug('USER LIST #### ::' + listUsers); 
     } 
     return listUsers ;
   } // End of Method - getGroupMembers.
 
 }