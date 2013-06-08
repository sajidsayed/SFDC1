/*=============================================================================
	HISTORY                                                                  
                                                               
	DATE          	DEVELOPER                WR       		DESCRIPTION                               
	====          	=========                ==       		=========== 
	06-Sep-2010		Pratibh Prakash			136350			Batch class to update any User Attribute Mappings to
															match the exact role name, by using the Role ID field to match.
															
	28/11/2011		Anand Sharma			178714   		Added PRM_Partner_Leverage.districtCreateEdit method to 
															populate District manage on District record.		
	28/05/2012		Kaustav Debnath					   		Code added for null check of role ids before district manager update													
==============================================================================*/
global class UpdateUserAttrMappingfromRoleBatch implements Database.Batchable<SObject>{
	public String Query;

	
	global UpdateUserAttrMappingfromRoleBatch(String query){
       this.Query = query;
       System.debug('Query is---->'+query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope){    
    	Set<String> roleIds =  new Set<String>();
    	//Map to Store RoleIds and corresponding User Attribute Mapping record.
    	Map<String,User_Attribute_Mapping__c> userAtt_RoleIdMap = new Map<String,User_Attribute_Mapping__c>(); 
    	List<User_Attribute_Mapping__c> userAttForUpdate = new List<User_Attribute_Mapping__c>();
    	//List added by Kaustav for null check of role ids before district manager update
    	List<User_Attribute_Mapping__c> userAttForDistrictManagerUpdate = new List<User_Attribute_Mapping__c>();
    	//Populating RoleId and corresponding User Attribute Mapping record map.
    	for(SObject sobjects:scope){
            User_Attribute_Mapping__c userAttrMapping = (User_Attribute_Mapping__c)sobjects;
            if(userAttrMapping.Role_Id__c != null){
	            userAtt_RoleIdMap.put(userAttrMapping.Role_Id__c, userAttrMapping);
	            roleIds.add(userAttrMapping.Role_Id__c);
	            //Code added by Kaustav for null check of role ids before district manager update
	            userAttForDistrictManagerUpdate.add(userAttrMapping);
            }
        }
        
        //Processing User Attribute Mapping records
        if(roleIds.size()>0){
	        for(UserRole roleObj: [Select Id, Name from UserRole where Id in: roleIds]){
	        	//Updated on 05/27/2011 added new condition if role name does not match then only update.
	        	if(userAtt_RoleIdMap.get(roleObj.Id).Name != roleObj.Name)
	        	{
	        		userAtt_RoleIdMap.get(roleObj.Id).Name = roleObj.Name;
		        	userAtt_RoleIdMap.get(roleObj.Id).Updated_From_Future_Call__C=true;
		        	userAttForUpdate.add(userAtt_RoleIdMap.get(roleObj.Id));
				}
	        }
	        if(userAttForUpdate.size()>0) 
	        {
	        	update userAttForUpdate;
	        }
        }
        // Anand Sharma : Added to populate District manager on district record.
        PRM_Partner_Leverage objPRMPartnerLeverage = new PRM_Partner_Leverage();
        //Code added by Kaustav for null check of role ids before district manager update
        if(userAttForDistrictManagerUpdate.size()>0)
        {
        	objPRMPartnerLeverage.districtCreateEdit(userAttForDistrictManagerUpdate);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    	// Anand Sharma : Added to populate District manager on district record.
        PRM_Partner_Leverage objPRMPartnerLeverage = new PRM_Partner_Leverage();
        List<User_Attribute_Mapping__c>  lstUAMRecords =[Select Id, Name, Role_ID__c,district__c, area__c,BU__c, 
        												Country__c, Division__c, Forecast_Group__c, Region__c, Sales_Role__c, Super_Area__c,
        												Super_Division__c,Theater__c, Updated_From_Future_Call__c from User_Attribute_Mapping__c where Role_ID__c!=null];
        
        objPRMPartnerLeverage.districtCreateEdit(lstUAMRecords);
    }
}