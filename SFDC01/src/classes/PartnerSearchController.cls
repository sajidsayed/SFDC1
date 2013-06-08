/*======================================================================================================

    1/Jan/2011     Defect #207   Added sort logic
    7/Jan/2011     Defect #229   Custom settings for API Key and dynamic rendering the header and footer
                   #232,#228                         
	17/04/2013     WR#237834     Checking the code statements if code statements are exceed   displaying the Message to user.
	13/05/2013	   WR264811		 Removed the harcoded message and replaced with custom label system.Label.PartnerSearch_ERROR
========================================================================================================*/
global class PartnerSearchController extends PartnerFinderBaseController implements ObjectPaginatorListener{

    //==================================================
    // PROPERTIES
    //==================================================
    public Configuration                config                      {get; private set;} 
    public SearchForm                   form                        {get; private set;}
    public List<SearchHitWrapper>       hits                        {get; private set;} 
    public ObjectPaginator              paginator                   {get; set;} 
    public Boolean                      displayAdvancedSearchFlag   {get; set;}
    public Boolean                      displaySearchResultsFlag    {get; set;}
    public String                       sortColumn                  {get; set;}
    public String                       searchSerialized            {get; private set;}
    public String                       paramString                 {get; set; }
    public String                       countryCode                 {get; set; }
    Map<String,CustomSettingDataValueMap__c> googleMapApi = CustomSettingDataValueMap__c.getall();
    public boolean                    isSitePage                    {get; set; }     
           
    
    //==================================================
    // CONSTRUCTOR  
    //==================================================
    public PartnerSearchController(){
        this.paramString = StringUtils.substringAfter(ApexPages.currentPage().getUrl(),'?');
        this.countryCode = PageUtils.param('c');
         String PartnerProfileId = Profiles__c.getInstance().Partner_Finder_Profile__c;
        isSitePage=(UserInfo.getProfileId()== PartnerProfileId ? true:false);  
    }  
    
    //==================================================
    // ACTIONS
    //==================================================
    public PageReference doOnLoad(){
        this.config = Configuration.getInstance();
        this.hits = new List<SearchHitWrapper>();
        this.paginator = new ObjectPaginator(this);
        this.form = SearchForm.deSerialize(this.paramString);
        if(!form.isBlank){
            return search(); 
        }
        this.displayAdvancedSearchFlag = !form.advancedFieldsAreBlank;
        return null; 
    }
     
    public PageReference searchClicked(){ 
        return search(); 
    } 
    
    public PageReference refresh(){ 
        return null; 
    } 
    
       public PageReference search(){ 
        if(form != null){
            this.paginator.setRecords(
                wrap(
                    new Search(
                        form.getAttributeSearchCriteria()
                        ,form.getGeoSearchCriteria()
                        ,sortColumn                  
                    )
                    .addFields(buildFieldsInResultListForQueryAsSet(this.config))
                    .execute()
                )
            );
            this.displaySearchResultsFlag = true;
            this.searchSerialized = this.form.serialize();
        }
        return null; 
    } 
    
    public PageReference skipToLocation(){ 
        try{
            this.paginator.skipToPage(Integer.valueOf(PageUtils.param('pageNumber')));
        }catch(Exception e){}
        return null; 
    } 
    
    public PageReference toggleFilter(){ 
        System.debug('this.displayAdvancedSearchFlag' 
        +this.displayAdvancedSearchFlag);
        if(this.displayAdvancedSearchFlag==null){
            this.displayAdvancedSearchFlag = true;
        }else{
            this.displayAdvancedSearchFlag = !this.displayAdvancedSearchFlag;            
        }
        
        return null; 
    } 
    
    public PageReference sortData(){ 
        return search(); 
    } 

    //==================================================
    // DERIVED PROPERTIES
    //==================================================
    public String googleMapsApiKey  {get{return isSitePage?googleMapApi.get('GoogleMapAPISite').DataValue__c: googleMapApi.get('GoogleMapApi').DataValue__c;}}
   // public String googleMapsApiKey {get{return 'ABQIAAAAm-untwTxP_ZjAI60NpPG4RRSkD9V0tugsOV4f_u79GCL6KqazRRnK1t2PGz-EDmFCpQw2SSXZteePw';}}  
    //{ get{return config == null ? null : (StringUtils.isEmpty(Site.getName()) ? config.googleMapsApiKey : config.googleMapsApiKeyForSites);}}
    public String locationsJSON     { get{return SearchHitWrapper.toJSON(hits);} set;}
    
    //==================================================
    // HELPER METHODS
    //==================================================
    global void handlePageChange(List<Object> records){
    	Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);       
        this.hits.clear();
        if(records != null && records.size() > 0){
            for(Object record : records){               
                Integer myCodeStatements = Limits.getScriptStatements();    
		   		  if( myCodeStatements >= totalCodestatements){
			       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.Label.PartnerSearch_ERROR);	    		
					ApexPages.addMessage(myMsg);					
		           } 
                this.hits.add((SearchHitWrapper)record);               
            }
        }
    }

    public List<SelectOption> getSortColumnList() {
    	Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);
        final List<SelectOption> returnValue = new List<SelectOption>();
        if( config != null 
            && config.searchScreenSortableFields != null 
            && config.searchScreenSortableFields.size() > 0){
            for(FieldConfiguration field : config.searchScreenSortableFields){
                 Integer myCodeStatements = Limits.getScriptStatements();    
		   		  if( myCodeStatements >= totalCodestatements){
			       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.Label.PartnerSearch_ERROR);	    		
					ApexPages.addMessage(myMsg);	
					return null;
		           } 
                if(field != null){
                    returnValue.add(new SelectOption(field.name,field.label));
                }
            }
        }
        return returnValue;
    }

    public List<String> getMessages(){
        List<String> msgList= new List<String>();
        for(ApexPages.Message msg:ApexPages.getMessages()){
            msgList.add(msg.getSummary());
        }
        return msgList;
    }
    
    private List<SearchHitWrapper> wrap(List<SearchHit> hits){     
       Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);       
        final List<SearchHitWrapper> wrappedHits = new List<SearchHitWrapper>();
        if(hits != null && hits.size() > 0){
            final FieldIndex fieldIndex = new FieldIndex().indexType(
                new List<Schema.DescribeSObjectResult>{
                    Schema.sObjectType.Account,
                    Schema.sObjectType.Partner_Location__c
                }
            );
            for(SearchHit hit : hits){
            	  Integer myCodeStatements = Limits.getScriptStatements();    
		   		  if( myCodeStatements >= totalCodestatements){
			       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.Label.PartnerSearch_ERROR);	    		
					ApexPages.addMessage(myMsg);	
					return null;
	           } 
                wrappedHits.add(new SearchHitWrapper(hit,this.config));
            }
        }
        return wrappedHits;
    }

    private static Set<Object> buildFieldsInResultListForQueryAsSet(Configuration config){
        final Set<Object> fields = new Set<Object>();
        Integer totalCodestatements = (limits.getLimitScriptStatements()-10000);
        if( config != null 
            && config.searchScreenFieldsInResultList != null 
            && config.searchScreenFieldsInResultList.size() > 0){
            for(FieldConfiguration fieldConfiguration : config.searchScreenFieldsInResultList){
                		 Integer myCodeStatements = Limits.getScriptStatements();    
				   		  if( myCodeStatements >= totalCodestatements){
					       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.Label.PartnerSearch_ERROR);	    		
							ApexPages.addMessage(myMsg);	
							return null;
				           } 
                if(fieldConfiguration != null){
                    fields.add(fieldConfigurationToFieldName(fieldConfiguration));
                }
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