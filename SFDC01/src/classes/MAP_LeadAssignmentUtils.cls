public class MAP_LeadAssignmentUtils
{
	public static Map<string, string> ruleFieldToLeadFieldMap;
    public static Map<string, string> ruleFieldToOperatorMap;
    public static List<string> leadAttributes;
    public static Map<string, string> profileOptions;
    
	public static Map<string, string> getRuleFieldToLeadFieldMappings()
	{
		if(ruleFieldToLeadFieldMap == null)
		{
			List<Lead_Routing_Field_Mapping__c> fieldMappings  = [SELECT l.Rule_Object_Field_API_Name__c,
			                                                             l.Lead_Object_Field_API_Name__c 
                                                                  FROM   Lead_Routing_Field_Mapping__c l];
            ruleFieldToLeadFieldMap = new Map<string,string>();
            
            for(Lead_Routing_Field_Mapping__c lobj : fieldMappings)
            {
                ruleFieldToLeadFieldMap.put(lobj.Rule_Object_Field_API_Name__c, lobj.Lead_Object_Field_API_Name__c);
            }
		}
		
		return ruleFieldToLeadFieldMap;
	}
	
	public static Map<string, string> getRuleFieldToOperatorMappings()
	{
		if(ruleFieldToOperatorMap == null)
		{
            List<Lead_Routing_Field_Mapping__c> operatorMappings = [SELECT l.Rule_Object_Field_API_Name__c,
                                                                           l.Comparison_Operator__c 
                                                                    FROM   Lead_Routing_Field_Mapping__c l];
            ruleFieldToOperatorMap = new Map<string,string>();
            for(Lead_Routing_Field_Mapping__c lobj : operatorMappings)
            {
                ruleFieldToOperatorMap.put(lobj.Rule_Object_Field_API_Name__c, lobj.Comparison_Operator__c);
            }
		}
		return ruleFieldToOperatorMap;
	}
	
	public static List<string> getLeadAttributes()
	{
		if(leadAttributes == null)
		{
			leadAttributes = new List<string>();
			set<string> uniqueAttrs = new set<string>();
			List<Lead_Routing_Field_Mapping__c> leadAttrs = [SELECT l.Lead_Object_Field_API_Name__c FROM   Lead_Routing_Field_Mapping__c l];
			for(Lead_Routing_Field_Mapping__c lrfm: leadAttrs)
			{
				if(!uniqueAttrs.contains(lrfm.Lead_Object_Field_API_Name__c))
				{
					uniqueAttrs.add(lrfm.Lead_Object_Field_API_Name__c);
				    leadAttributes.add(lrfm.Lead_Object_Field_API_Name__c);
				}
			}
			leadAttributes.sort();
		}
		
		return leadAttributes;
	}
	
	public static string getProfileOptionValue(string profileOptionName)
	{
		if(profileOptions == null)
		{
			profileOptions = new Map<string, string>();
			try
			{
			    List<MAP_Profile_Options__c> optionList = [SELECT Profile_Option_Name__c, Profile_Option_Value__c FROM MAP_Profile_Options__c];
			    for(MAP_Profile_Options__c obj : optionList)
			    {
				    profileOptions.put(obj.Profile_Option_Name__c, obj.Profile_Option_Value__c);
			    }
			}
			catch(Exception ex)
			{
				system.debug('MAP Fatal Error: Unable to retrieve MAP profile options');
				throw ex;
			}
		}
		return profileOptions.get(profileOptionName);
	}
}