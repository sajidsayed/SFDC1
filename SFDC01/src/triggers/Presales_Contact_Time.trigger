//Trigger to update the first time activity datetime to Case

trigger Presales_Contact_Time on Task (after insert) {

 Presales_CheckRecordType objCheckRecordType = new Presales_CheckRecordType();
 List<Task> lstNewTask = objCheckRecordType.checkTaskRecordType(trigger.new);
    
//List<Task> taskLst= Trigger.new;

if(lstNewTask.size()>0){
PreSalesTask PS = new PreSalesTask();
PS.setFirstTimeContact(lstNewTask);
}
}