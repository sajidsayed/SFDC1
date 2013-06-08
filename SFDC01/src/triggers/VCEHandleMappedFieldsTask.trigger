trigger VCEHandleMappedFieldsTask on Task (before update) {
    String taskAssignedTo = 'EMC';
    String userName = UserInfo.getName();
    Task oldTask;           

    for (Task newTask : Trigger.new) {
        if(newTask.VCE_Assigned_To__c == taskAssignedTo && userName.equalsIgnoreCase('Connection User')) {
            oldTask = trigger.oldmap.get(newTask.id);
            // Allow the task status to be updated
            // from the shared org only when
            // the old value of task status was 'System Rejected' or 'Completed'
            // and the updated value of task status is 'New'.
            // Else keep the previous task status.
            if((newTask.Status != oldTask.Status) && 
               (!(newTask.Status == 'New' && 
                 (oldTask.Status == 'Completed' || 
                  oldTask.Status == 'System Rejected' ||
                  oldTask.Status == 'Closed' ||
                  oldTask.Status == 'Cancelled' ||
                  oldTask.Status == 'Closed - No Cust. Validation' ||
                  oldTask.Status == 'Closed - Initial Call' ||
                  oldTask.Status == 'Closed - Defect Logged' ||
                  oldTask.Status == 'Closed - CHAT'))))
            newTask.Status = oldTask.Status;
        }
    }      
}