//The code has been updated to resolve issue #511
trigger updateUseronEdit on User_Attribute_Mapping__c (before insert,before update)
{
    AttributeOperation update_user=new AttributeOperation();
    List<User_Attribute_Mapping__c> lstUaMapping = new List<User_Attribute_Mapping__c>(); 
    for(User_Attribute_Mapping__c ua: Trigger.new)
    {
        if(ua.Updated_From_Future_Call__C==false)
            lstUaMapping.add(ua);
        else
            ua.Updated_From_Future_Call__C=false;
    }   
    
    if(lstUaMapping.size() > 0)
        update_user.CheckValidRoleName(lstUaMapping);
}