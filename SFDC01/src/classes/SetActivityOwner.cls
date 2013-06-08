global class SetActivityOwner{
@future
public static void updateOwner(String [] leadids){
    Map <String,String> historyMap = new Map <String,String>();

    /*List <Lead_History__c> histories = [Select CreatedDate,New_Owner__c, Previous_Owner__c, Lead__c from Lead_History__c  where Type__c='Owner Change' and Lead__c in :leadids order by createddate]; 
    List <LeadHistory> histories = [select LeadId,id,Field,oldvalue,NewValue,CreatedDate From LeadHistory where Leadid='00QS0000002TNmx' and Field='Owner'and LeadId in :leadids order by CreatedDate];
    System.debug('histories '+histories );
   System.debug('histories .size() '+histories.size());
    for(LeadHistory history :histories ){
        historyMap.put(''+history.LeadId,''+history.oldValue);
    }
    System.debug('historyMap.size() '+historyMap.size());
     System.debug('historyMap '+historyMap);
    */
   // Get all open activites
    List <Lead> leads=[select id,ownerid,Previous_Owner__c from lead where id in :leadids];
    Map <String,String> leadowners= new Map<String,String>();
    for(Lead lead :leads){
        leadowners.put(''+lead.id,''+lead.ownerid);
        historyMap.put( ''+lead.id,''+lead.Previous_Owner__c);
    }
    List <Event> events=new List <Event>(); 
    events = [Select id, EndDateTime,StartDateTime,ownerId,whoid,IsArchived,IsRecurrence, RecurrenceActivityId, RecurrenceDayOfMonth,IsAlldayEvent from Event  where whoid in:leadids  and Type='Appointment Set (SA)' and  endDateTime >=:System.now() and startDateTime>=:System.now()  and ownerid in :leadowners.values() ]; 
    System.debug('events.size() '+events.size());
    if(events.size()>0){
        for(Event et :events){
            System.debug('ownerId '+et.ownerId);
            System.debug('id '+et.id);
            
            if(leadowners.get(''+et.whoid)==et.ownerId){
                System.debug('IsRecurrence '+et.IsRecurrence);
                System.debug('RecurrenceActivityId '+et.RecurrenceActivityId );                
                if( (et.IsRecurrence==true && et.RecurrenceActivityId != null) || 
                    (et.IsRecurrence==false && et.RecurrenceActivityId == null)){
                    System.debug('lead '+et.whoid);
                    et.ownerid=historyMap.get(et.whoid);
                    System.debug(et.ownerid);
                }
                et.Original_Appointment_Start__c= et.StartDateTime; 
                et.Original_Appointment_End__c= et.EndDateTime;  
                System.debug(et.Original_Appointment_Start__c);
                System.debug(et.Original_Appointment_End__c);
            }
        }       
        update events;

        System.debug('events updated...'+events);
    }
 }
  
}