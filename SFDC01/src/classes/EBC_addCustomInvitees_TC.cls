/**
   25-May-2011      Srinivas Nallapati          Chnaged for June11 release
   15-Apr-2013      Prachi Bhasin               To improve coverage
 */
@isTest
private class EBC_addCustomInvitees_TC {

    static testMethod void EBC_addCustomInvitees()
    {
        //donotchange
            //This code is used here to get record type id
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Event;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('Briefing Event');
    Id rTypeId= record_Type_name_RT.getRecordTypeId();
        
        //Prachi
         List<User> lstUser = [Select id,Email from user where IsActive = true and Theater__c in ('APJ')limit 4];
         Set<String> userEmailSet = new Set<string>();
         userEmailSet.add(lstUser[0].Email);
        EBC_Briefing_Event__c objBri = new EBC_Briefing_Event__c();
        objBri.Briefing_Name__c='briefing event';
        objBri.CreatedById=lstUser[0].id;
        insert objBri;
        EBC_Invitees__c objInv= new EBC_Invitees__c();
        objInv.Briefing_Team_Role__c='EMC Employee';
        objInv.Briefing_Event__c =objBri.id;
        insert objInv;
        EBC_addCustomInvitees objAdd = new EBC_addCustomInvitees();
        objAdd.createSchedulerInvitee(objBri.id,objBri.CreatedById);
        Contact con = new Contact();
        con.Email=lstUser[0].Email;
        con.Active__c=true;
        con.LastName='abc';
        insert con;
        Set<Id> contactIdSet = new Set<Id>();
        contactIdSet.add(con.id);
                
        EBC_addCustomInvitees.createInvitees(objBri.id);
        objAdd.createSchedulerInvitee(objBri.id,objBri.CreatedById);
        
        //Prachi
        
        EBC_addCustomInvitees.createInvitees=true;
        // '02370000000nVuJ' is Hopkinton's calendar Id, we need at least one record of event for a calendar
        Event ev=[Select Id,Subject,whatId from Event where recordtypeid=:rTypeId and  OwnerId = '02370000000nVuJ'limit 1];
        update ev;
        EBC_addCustomInvitees.createInvitees=false;
        delete ev;
        
        

        
    }
}