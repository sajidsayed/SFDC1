/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 12-Oct-2011    Srinivas Nallapati     175586    Add Last Activity Date and Days Since Last Activity Counter to Leads
 +===========================================================================*/
trigger UpdateCaseLastActivityDateFromTask on Task (before insert) {
    Schema.DescribeSObjectResult R = Lead.SObjectType.getDescribe();
    String keyPrefix = R.getKeyPrefix();
    
    List<Lead> updateLastActivityLeads = new List<Lead>();
    for(Task tk : trigger.new)
    {
        if(tk.WhoId != null && string.valueOf(tk.WhoId).startswith(keyPrefix) )
           updateLastActivityLeads.add(new Lead (id = tk.WhoId,  Last_Activity_Date__c= system.today()));
    }
    if(!updateLastActivityLeads.isEmpty())
        Database.update (updateLastActivityLeads, false);
    //what to do when the above update fails (partially/full)
}