trigger beforeInsertOnEduation on Education__c (before insert) {

for(Education__c edu :Trigger.new){      
      edu.Batch_Job_Operation__c='Eduation Created';    
}

}