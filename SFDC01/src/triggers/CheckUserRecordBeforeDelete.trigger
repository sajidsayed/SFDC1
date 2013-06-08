trigger CheckUserRecordBeforeDelete on User_Attribute_Mapping__c (before delete) {

AttributeOperation Del_Atr=new AttributeOperation ();
 Del_Atr.fetchUsers(Trigger.old);

}