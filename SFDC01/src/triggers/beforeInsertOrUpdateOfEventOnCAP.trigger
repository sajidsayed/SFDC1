/*================================================================================
Date        Name            WR       Description
9/12/2010   Ashwini Gowda    -       This trigger is invoked when trying to insert
                                     or update a Event for a Locked CAP.  
===================================================================================*/
trigger beforeInsertOrUpdateOfEventOnCAP on Event(before insert,before update) { 
    PRM_ActivityLockonCAP activityLockOnCAP = new PRM_ActivityLockonCAP();
    activityLockOnCAP.getEventUpdatesOnCAP(trigger.new); 
}