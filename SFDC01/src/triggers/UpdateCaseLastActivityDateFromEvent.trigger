/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 12-Oct-2011    Srinivas Nallapati     175586    Add Last Activity Date and Days Since Last Activity Counter to Leads
 +===========================================================================*/
trigger UpdateCaseLastActivityDateFromEvent on Event (before insert) {
    Schema.DescribeSObjectResult R = Lead.SObjectType.getDescribe();
    String keyPrefix = R.getKeyPrefix();
    
    //This code is used here to get record type id
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Event;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('Briefing Event');
    Id rTypeId= record_Type_name_RT.getRecordTypeId();
    
    List<Lead> updateLastActivityLeads = new List<Lead>();
    for(Event ev : trigger.new)
    {
        if(ev.WhoId != null && string.valueOf(ev.WhoId).startswith(keyPrefix) && ev.RecordTypeId != rTypeId)
           updateLastActivityLeads.add(new Lead (id = ev.WhoId, Last_Activity_Date__c= system.today()));
    }
    if(!updateLastActivityLeads.isEmpty())
        Database.update (updateLastActivityLeads, false);
    //what to do when the above update fails (partially/full)
}