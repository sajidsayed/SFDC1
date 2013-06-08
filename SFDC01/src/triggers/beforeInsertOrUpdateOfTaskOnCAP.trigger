/*================================================================================
Date        Name            WR       Description
9/12/2010   Ashwini Gowda    -       This trigger is invoked when trying to insert
                                     or update a Task for a Locked CAP.  
===================================================================================*/
trigger beforeInsertOrUpdateOfTaskOnCAP on Task (before insert,before update) { 
    PRM_ActivityLockonCAP activityLockOnCAP = new PRM_ActivityLockonCAP();
    activityLockOnCAP.getTaskUpdatesOnCAP(trigger.new); 
}