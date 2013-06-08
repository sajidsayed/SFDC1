trigger ProfileCustomAfterDelete on ProfileCustom__c (after delete) {
 /*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  08-Sep-09  Shipra Misra           Trigger to process deleted profiles and 
                                      set presence profile exist checkbox true or false whatever necessary                 
 +===========================================================================*/
   
    // process deleted profiles and set presence profile exist checkbox true or false whatever necessary
    AH_ChildObjectPresenceIndicators.ProcessProfileCustomDelete(trigger.old);
}