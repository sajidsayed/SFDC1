/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER           WR          DESCRIPTION                               
 |  ====            =========           ==          =========== 
 | TestclassName                                    ValidateEMCinstallrectype_TC
 |  28.dec.2012     Krishna Pydavula   212171       Validate the EMC Install Record Type for particular profiles. 
+========================================================================================================================*/
trigger ValidateEMCinstallrectype on Asset__c (before delete) {

RecordType rectype=[SELECT id,Name,SobjectType FROM RecordType where isactive = true and SobjectType = 'Asset__c' and name='EMC Install'];
User u=[select id,name,Profile_Name__c,Profileid from user where id=:userinfo.getuserid()];
Profile ProfileName = [select Name from profile where id = :u.ProfileId];
for(Asset__c asst:trigger.old)
{
	if((asst.RecordTypeId==rectype.id) && (!(ProfileName.name.Contains('System Administrator'))))
	{
		asst.name.addError(asst.Custom_Asset_Name__c+' You cannot delete EMC Install Record Type records');
		
		
	}		
	
}


}