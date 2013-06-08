/*============================================================================+
 |  HISTORY |                                                                 
 |                                                                           
 |  DATE       DEVELOPER              WR               DESCRIPTION                               
 |  ====       =========              ==               =========== 
 |  14-Nov-11  Kaustav Debnath   PRM Partner Leverage  Initial Creation - this trigger is to populate the 
                                                        district records
 |  
 +===========================================================================*/

trigger createUpdateDistrict on User_Attribute_Mapping__c (after insert,after update,after delete)
{
    PRM_Partner_Leverage update_user=new PRM_Partner_Leverage();
    List<User_Attribute_Mapping__c> lstUaMapping = new List<User_Attribute_Mapping__c>(); 
       
    List<User_Attribute_Mapping__c> lstPartnerLeverageDistrict = new List<User_Attribute_Mapping__c>(); 
    List<User_Attribute_Mapping__c> lstPartnerLeverageDistrictDelete = new List<User_Attribute_Mapping__c>(); 
    Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
    Integer iCounter=0;
    String strRoles='';
    Set<String> setCustomSettingKeySet=mapCustomSettingDataValueMap.keyset();
    //System.debug('### setCustomSettingKeySet.size=>'+setCustomSettingKeySet.size());
    for(String strObj:setCustomSettingKeySet)
    {
        if(strObj.contains('User_attribute_Mapping_Sales_Role'))
        {
            System.debug('### inside if=>'+iCounter);
            iCounter++;
        }
    }
    System.debug('### iCounter=>'+iCounter);
    for(integer i=1;i<iCounter+1;i++)
    {
        CustomSettingDataValueMap__c userAttributeSalesRoles = (mapCustomSettingDataValueMap.get('User_attribute_Mapping_Sales_Role_'+i));
        System.debug('### userAttributeSalesRoles.DataValue__c=>'+userAttributeSalesRoles.DataValue__c);
        strRoles=strRoles+userAttributeSalesRoles.DataValue__c+',';
    }
    System.debug('### strRoles=>'+strRoles);
    Set<String> split1 = new Set<String>();
    for(String s: strRoles.Split(',')){
        split1.add(s.toLowerCase());
    }
    
    if(Trigger.isInsert)
    {
        for(Integer i=0;i<Trigger.New.size();i++)
        {
            if(split1.contains(Trigger.New[i].Sales_Role__c.toLowerCase()))
            lstPartnerLeverageDistrict.add(Trigger.New[i]);
            /*if(Trigger.New[i]!=Trigger.Old[i] && split1.contains(Trigger.Old[i].Sales_Role__c.toLowerCase()))
            lstPartnerLeverageDistrictDelete.add(Trigger.New[i]);*/
        }   
    }
    
    if(Trigger.isupdate)
    {
        for(Integer i=0;i<Trigger.New.size();i++)
        {
            if(split1.contains(Trigger.New[i].Sales_Role__c.toLowerCase()))
            lstPartnerLeverageDistrict.add(Trigger.New[i]);
            if(Trigger.New[i]!=Trigger.Old[i] && split1.contains(Trigger.Old[i].Sales_Role__c.toLowerCase()) && !(split1.contains(Trigger.New[i].Sales_Role__c.toLowerCase())))
            lstPartnerLeverageDistrictDelete.add(Trigger.New[i]);
        }   
    }
    if(Trigger.isDelete)
    {
        for(Integer i=0;i<Trigger.Old.size();i++)
        {
            if(split1.contains(Trigger.Old[i].Sales_Role__c.toLowerCase()))
            lstPartnerLeverageDistrictDelete.add(Trigger.Old[i]);
        }
    }
    
    if(lstPartnerLeverageDistrict.size()>0 && lstPartnerLeverageDistrict!=null)
    {
        update_user.districtCreateEdit(lstPartnerLeverageDistrict);
    }
    if(lstPartnerLeverageDistrictDelete.size()>0 && lstPartnerLeverageDistrictDelete!=null)
    {
        update_user.districtUpdateOnUserDelete(lstPartnerLeverageDistrictDelete);
    }
}