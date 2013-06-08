/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 | 05-Oct-11   Deshpande, Medhavi         Class to update the current time for Case after task creation.
 | 23-Dec-11   Leonard Victor             Added null check before updating and  removed Boolean validation
 |  
 | 20-Feb-12   Leonard Victor             Removed lstTask iteration and changed SOQL execution for march release 
 +===========================================================================*/

public class PreSalesTask{

//Method to check If the Contact is set first time
public void setFirstTimeContact(List<Task> lstTask){
  List<ID> taskId = new List<ID>();
  List<ID>caseId = new List<ID>();
  List<Case> listCase = new List<Case>();
  //Iterating the task list which comes from the trigger and assigning the task Id values to the list
  //Commenting the Task list iteration based on SFDC team comments
/*    for(Task t : lstTask){
        taskId.add(t.Id);
     }*/
//SOQL for taking the record name from task
//List<Task> taskLst =[select recordtype.name ,Subject,WhatId from Task where Id IN:taskId ];
//Changed SOQL based on SFDC team comments
List<Task> taskLst =[select recordtype.name ,Subject,WhatId from Task where Id IN:lstTask ];

//Iterating the task list attained from the previous SOQL 
for(Task t:taskLst ){
System.debug('t.recordtype.name--->'+t.recordtype.name);
//Taking whatid from Task and assigning the case id to the list validation done based on custom filed label
    if(t.recordtype.name ==Label.Presales_Task &&
        (t.Subject ==Label.Call_PS || t.Subject ==Label.Email_PS)){  
         caseId.add(t.WhatId); 
         System.debug('t.WhatId--->'+t.WhatId +'---'+t);
      }
}
//SOQL for fetching the caserecords based on the Whatid present in task
List<Case> caseLst=[select id,time_of_first_contact__c  from case where id IN:caseId ];
DateTime currentDate = DateTime.now();
Boolean chkFlag=false;
//Iterating the Case Object and setting the boolean value for update
for(Case c: caseLst){
System.debug('caseLst before--->'+c.time_of_first_contact__c);
    if(c.time_of_first_contact__c  == null){
         //chkFlag=true;
         c.time_of_first_contact__c = currentDate;
         listCase.add(c);
     }
     
}

System.debug('listCase--->'+listCase);

//Updating the Case list
//if(chkFlag == true){
if(listCase.size()>0){
try{
     update listCase;
     System.debug('caseLst-->'+listCase);
    }
catch(DMLException ex){
    throw ex;
  }
}
System.debug('caseId--->'+caseID +'---'+listCase);

}


}