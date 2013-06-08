/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to update Presenter in Topic Presenter
*/
trigger EBC_updateName on EBC_Topic_Presenters__c (before insert, before update)
{
   Set<Id> presentSet=new Set<Id>();
   for(EBC_Topic_Presenters__c pt:trigger.new)
   {
     presentSet.add(pt.Presenter__c);
   }
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
    Id internalContact= record_Type_name_RT.getRecordTypeId();
   
   //This call is used here to fetch Presenter name.
   Map<Id,Contact> presentMap =new map<Id,Contact>([Select Id,Name,EBC_Name__c,EBC_Title__c,RecordTypeId,Active__c from Contact where Id IN: presentSet]);
   for(EBC_Topic_Presenters__c pt:trigger.new)
   {
     if(presentMap.containskey(pt.Presenter__c))
     {
       if(presentMap.get(pt.Presenter__c).Active__c==false)
       {
       	 pt.addError(System.Label.EBC_Inactive_Contact);
       }
       if(presentMap.get(pt.Presenter__c).RecordTypeId!=internalContact)
       {
       	pt.addError(System.Label.EBC_NonInternalContact);
       }
       pt.Name=presentMap.get(pt.Presenter__c).Name;
     }
   }
}