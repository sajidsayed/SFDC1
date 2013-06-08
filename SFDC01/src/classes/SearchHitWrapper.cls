/*======================================================================================================

	17/04/2013     WR#237834     checking the code statements if code statements are exceed   displaying the Message to user.
	13/05/2013	   WR264811		 Removed the harcoded message and replaced with custom label system.Label.PartnerSearch_ERROR
========================================================================================================*/

global class SearchHitWrapper {

    global SearchHit wrapped {get;private set;}
    
    global Integer resultSequenceNumber {get{return wrapped.resultSequenceNumber;}}
    global String locationName {get{return wrapped.locationName;}}
    global ID locationId {get{return wrapped.locationId;}}
    global String partnerName {get{return wrapped.partnerName;}}
    global ID partnerAccountId {get{return wrapped.partnerAccountId;}}
    global String website {get{return wrapped.website;}}
    global Boolean isPrimary {get{return wrapped.isPrimary;}}
    global String pointOfContactPhone {get{return wrapped.pointOfContactPhone;}}
    global String pointOfContactName {get{return wrapped.pointOfContactName;}}
    global String pointOfContactEmail {get{return wrapped.pointOfContactEmail;}}
    global String description {get{return wrapped.description;}}
    global String street {get{return wrapped.street;}}
    global String city {get{return wrapped.city;}}
    global String stateProvince {get{return wrapped.stateProvince;}}
    global String postalCode {get{return wrapped.postalCode;}}
    global String country {get{return wrapped.country;}}
    global Double longitude {get{return wrapped.longitude;}}
    global Double latitude {get{return wrapped.latitude;}}
    global GeoPoint point {get{return wrapped.point;}}
    global Boolean containsDistance {get{return wrapped.containsDistance;}}
    global Double distanceInKilometers {get{return wrapped.distanceInKilometers;}}
    global Double distanceInMiles {get{return wrapped.distanceInMiles;}}
    global Boolean isRecommended {get{return wrapped.isRecommended;}}
    global String logoId {get{return wrapped.logoId;}}   
    public Integer totalCodestatements;	
    global List<FormField> customFields{get;set;}

    global SearchHitWrapper(SearchHit wrapped, Configuration configuration){    	
    	 Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);  
        if(wrapped == null){
            throw new IllegalArgumentException('Invalid argument: wrapped is null');
        }
        if(configuration == null){
            throw new IllegalArgumentException('Invalid argument: configuration is null');
        }
        this.wrapped = wrapped;
        this.customFields = new List<FormField>();
        final Map<String,FormField> fieldLookup = buildFieldsInResultListForQuery(configuration);
        final List<String> fields = buildFieldsInResultListForQueryAsList(configuration);
        if(fields != null && fields.size() > 0){
        	FormField formField = null;
        	for(String field : fields){        		
        		formField = fieldLookup.get(field);
        		if(wrapped != null && wrapped.userRequestedFieldValues != null && wrapped.userRequestedFieldValues.get(field) != null 
        		  && wrapped.userRequestedFieldValues.get(field) instanceof String){
                    formField.populate((String) wrapped.userRequestedFieldValues.get(field));
	                this.customFields.add(formField);
        		}
        	}
        }
    }
    
    global static String toJson(List<SearchHitWrapper> hits){  
    	Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);   	
        String json = '';
        final List<String> locationsJSONEncoded = new List<String>();
        if(hits != null && hits.size() > 0){
            for(SearchHitWrapper hit : hits){            	                     	          	
                locationsJSONEncoded.add(
                    '{' 
                    + MapUtils.joinMap(
                        new Map<String,String>{
                            '"recordNumber"'=>SearchHitWrapper.toJSONString(String.valueOf(hit.resultSequenceNumber)),
                            '"id"'=>SearchHitWrapper.toJSONString(hit.locationId),
                            '"name"'=>SearchHitWrapper.toJSONString(hit.locationName),
                            '"latitude"'=>''+hit.latitude,
                            '"longitude"'=>''+hit.longitude,
                            '"street"'=>SearchHitWrapper.toJSONString(hit.street),
                            '"city"'=>SearchHitWrapper.toJSONString(hit.city),
                            '"state"'=>SearchHitWrapper.toJSONString(hit.stateProvince),
                            '"postalCode"'=>SearchHitWrapper.toJSONString(hit.postalCode),
                            '"country"'=>SearchHitWrapper.toJSONString(hit.country)
                        }
                       ,':'
                       ,','
                    )
                    + '}'
                );
            }
        }
        json = '{ "locations" : [' + StringUtils.joinArray(locationsJSONEncoded,',') + ']}';
        return json;
    }
    
    private static String toJSONString(String aString){
        return (aString == null) ? 'null' : '"' + 
            StringUtils.replaceEach(aString,new String[]{
                    '"','\\','\n','\t','\f','\r','/'
            },new String[]{
                    '\\"','\\\\','\\n','\\t','\\f','\\r','\\/'
            }) 
            + '"';
    }
    
    private static Map<String,FormField> buildFieldsInResultListForQuery(Configuration configuration){
    	 Integer totalCodestatements = (limits.getLimitScriptStatements()-1000);    	
        final Map<String,FormField> fields = new Map<String,FormField>();
        if( configuration != null 
            && configuration.searchScreenFieldsInResultList != null 
            && configuration.searchScreenFieldsInResultList.size() > 0){
            for(FieldConfiguration fieldConfiguration : configuration.searchScreenFieldsInResultList){  
            	Integer  myCodeStatements = Limits.getScriptStatements();        	
                 if( myCodeStatements >= totalCodestatements){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.PartnerSearch_ERROR);             
                    ApexPages.addMessage(myMsg);   
                    return null;
                }          	
                if(fieldConfiguration != null){
                    fields.put(
                         fieldConfigurationToFieldName(fieldConfiguration)
                        ,new FormField(fieldConfiguration)
                    );
                }
            }
        }
        return fields;
    }
    
    private static List<String> buildFieldsInResultListForQueryAsList(Configuration configuration){
    	 Integer totalCodestatements = (limits.getLimitScriptStatements()-1000); 
        final List<String> fields = new List<String>();
        if( configuration != null 
            && configuration.searchScreenFieldsInResultList != null 
            && configuration.searchScreenFieldsInResultList.size() > 0){
            for(FieldConfiguration fieldConfiguration : configuration.searchScreenFieldsInResultList){
            	Integer  myCodeStatements = Limits.getScriptStatements();  
                if( myCodeStatements >= totalCodestatements){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.PartnerSearch_ERROR);             
                    ApexPages.addMessage(myMsg);    
                    return null;
                } 
                if(fieldConfiguration != null){
                    fields.add(fieldConfigurationToFieldName(fieldConfiguration));
                }
            }  
            Integer  myCodeStatements = Limits.getScriptStatements();  
	            if( myCodeStatements >= totalCodestatements){
	                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.PartnerSearch_ERROR);             
	                ApexPages.addMessage(myMsg);    
	                return null;
	            }          
        }
        return fields;
    }

    private static String fieldConfigurationToFieldName(FieldConfiguration fieldConfiguration){
        String returnValue = null;
        if(fieldConfiguration != null){
            returnValue = ('Account'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Account__r.' : '') 
                + fieldConfiguration.fieldName;
        }
        return returnValue;
    }
    
}