trigger ProfileCustomAfterUnDelete on ProfileCustom__c (after Undelete) {
  /*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  08-Sep-09  Shipra Misra           Trigger to process Undeleted profiles and 
                                      set presence profile exist checkbox true or false whatever necessary                 
 +===========================================================================*/
    
    // process Undeleted profiles and set presence profile exist checkbox true or false whatever necessary
    AH_ChildObjectPresenceIndicators.ProcessProfileCustomUnDelete(trigger.new);
}