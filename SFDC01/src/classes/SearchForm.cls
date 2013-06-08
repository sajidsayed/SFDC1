public class SearchForm {

    public String               keyword             {get; set;}
    public String               address             {get; set;}
    public String               unit                {get; set;}
    public Integer              distance            {get; set;}
    public Double               latitude            {get; set;}
    public Double               longitude           {get; set;}
    public List<SelectOption>   distanceOptions     {get; private set;}
    public List<SearchField>    basicFields         {get; private set;}
    public List<SearchField>    advancedFields      {get; private set;}
    private List<SearchField>   allFields           {get; private set;}

    public List<SetOfThreeSearchFields> advancedFieldsSet{get; private set;}
    
    private SearchForm(){
    	Configuration config = Configuration.getInstance();
    	distance = config.searchDistanceDefault;
    	distanceOptions = toSelectOption(config.searchDistanceOptions);
    	if(distanceOptions == null || distanceOptions.isEmpty()){
	        distanceOptions = new List<SelectOption>();
	        for(String aDistance : new List<String>{'5','10','25','50','75','100','200'}){
	            distanceOptions.add(new SelectOption(aDistance,aDistance));
	        }
    	}
        basicFields = SearchField.build(config.searchScreenBasicSearchFields);
        advancedFields = SearchField.build(config.searchScreenAdvancedSearchFields);
        advancedFieldsSet = SetOfThreeSearchFields.createFromList(advancedFields);
        this.allFields = new List<SearchField>();
        this.allFields.addAll(basicFields);
        this.allFields.addAll(advancedFields);
    }
    
    public Boolean isBlank{get{return keywordBlank && geoBlank && basicFieldsAreBlank && advancedFieldsAreBlank;}}
    public Boolean keywordBlank{get{return StringUtils.isBlank(keyword);}}
    public Boolean geoBlank{get{return StringUtils.isBlank(address);}}
    public Boolean basicFieldsAreBlank{get{return areBlank(this.basicFields);}}
    public Boolean advancedFieldsAreBlank{get{return areBlank(this.advancedFields);}}
    
    private static Boolean areBlank(List<SearchField> fields){
    	Boolean returnValue = true;
        if(fields != null && fields.size() > 0){
            for(SearchField field : fields){
                if(field.notBlank){
                	returnValue = false;
                	break;
                }
            }
        }
        return returnValue;
    }
    
    public String toStr{get{return toStr();}}

    public String toStr(){
        return '<#SearchForm[' 
            + 'keyword=' 
            + this.keyword
            + ',address=' 
            + this.address
            + ',unit=' 
            + this.unit
            + ',distance=' 
            + this.distance
            + ',distanceOptions=' 
            + this.distanceOptions
            + ',basicFields=' 
            + this.basicFields
            + ',advancedFields=' 
            + this.advancedFields
            + ']>';
    }

    public Condition getAttributeSearchCriteria(){
    	AndCondition returnValue = null;
        if(StringUtils.isNotBlank(keyword)){
            returnValue = new AndCondition();
            returnValue.add(new OrCondition()
	                .add(new FieldCondition('Account__r.name').likex(keyword))
	                .add(new FieldCondition('name').likex(keyword))
	             );
        }
        if(this.allFields != null && this.allFields.size() > 0){
        	String qualifiedName = '';
        	for(SearchField field : this.allFields){
        		qualifiedName = ('account'.equalsIgnoreCase(field.objectName) ? 'account__r.' : '') + field.applyTo;
        		if(field.notBlank){
                    returnValue = returnValue == null ? new AndCondition() : returnValue;
                    if(field.isMultiselectPicklist){
                        returnValue.add(new SetCondition(qualifiedName).includes(field.values));
                    } else {
                    	Object value = field.typedValue;
                        returnValue.add(new FieldCondition(
                            qualifiedName, 
                            (!field.isPicklist && value instanceof String ? Operator.LIKEX : Operator.EQUALS), 
                            value
                        ));
                    }
        		}
        	}
        }
    	return returnValue;
    }
    
    public GeoSearchCriteria getGeoSearchCriteria(){
    	GeoSearchCriteria returnValue = null;
        if(StringUtils.isNotBlank(address) && latitude != null && longitude != null){
        	try{
	            returnValue = new GeoSearchCriteria(
	                new GeoPoint(latitude,longitude)
	                ,Double.valueOf(''+this.distance)
	                ,StringUtils.equalsIgnoreCase(this.unit,'miles') ? UnitOfLength.MILES : UnitOfLength.KILOMETERS);
        	}catch(IllegalArgumentException e){}
        }
        return returnValue;
    }
    
    public static SearchForm blank(){
        return new SearchForm();
    }
    
    public String serialize(){
    	final Map<String,String> values = new Map<String,String>();
        if(StringUtils.isNotBlank(this.keyword)){ 
        	values.put('keyword',  this.keyword);
        }
        if(StringUtils.isNotBlank(this.address)){ 
            values.put('address',  this.address);
	        values.put('unit',     this.unit);
	        values.put('distance', '' + this.distance);
	        values.put('latitude', '' + this.latitude);
	        values.put('longitude','' + this.longitude);
        }
        if(this.allFields != null && this.allFields.size() > 0){
            for(SearchField field : this.allFields){
            	if(field.notBlank){
                    values.put(
                        StringUtils.lowerCase(field.objectName) + '.' + StringUtils.lowerCase(field.localName),
                        field.isMultiselectPicklist ? serializeList(field.values) : field.value
                    );         		
            	}
            }
        }
        for(String key : values.keySet()){
        	values.put(key,EncodingUtil.urlEncode(values.get(key),'UTF-8'));
        }
        return MapUtils.joinMap(values,'=','&'); 
    }
    
    public static SearchForm deSerialize(String serialized){
    	final SearchForm form = SearchForm.blank(); 
    	final List<String> params = StringUtils.split(serialized, '&');
    	if(params != null && params.size() > 0){
            final Map<String,String> values = new Map<String,String>();
    		for(String param : params){
    			values.put(
                    StringUtils.lowerCase(StringUtils.trim(StringUtils.substringBefore(param,'=')))
                    ,EncodingUtil.urlDecode(StringUtils.trim(StringUtils.substringAfter(param,'=')),'UTF-8'));
    		}
    		final Map<String,SearchField> nameToFieldIndex = new Map<String,SearchField>();
	        if(form.allFields != null && form.allFields.size() > 0){
	            for(SearchField field : form.allFields){
	            	nameToFieldIndex.put(StringUtils.lowerCase(field.objectName) + '.' + StringUtils.lowerCase(field.localName),field);
	            }
	        }
            form.keyword     = values.get('keyword');
            form.address     = values.get('address');
            form.unit        = values.get('unit');
            try{ form.distance = Integer.valueOf(values.get('distance')); } catch(System.TypeException e){} catch(NullPointerException e){}
            try{ form.latitude = Double.valueOf(values.get('latitude')); } catch(System.TypeException e){} catch(NullPointerException e){}
            try{ form.longitude = Double.valueOf(values.get('longitude')); } catch(System.TypeException e){} catch(NullPointerException e){}
            SearchField field = null;
	        for(String fieldName : values.keySet()){
	        	field = nameToFieldIndex.get(fieldName);
	        	if(field != null){
	        		if(field.isMultiselectPicklist){
	        			field.values = deSerializeList(values.get(fieldName));
	        		} else {
	        			field.value = values.get(fieldName);
	        		}
	        	}
	        }
    	}
        return form;
    }
    
    private static String serializeList(List<String> aList){
    	List<String> encoded = new List<String>();
        if(aList != null && aList.size() > 0){
        	for(String value : aList){
        		encoded.add(EncodingUtil.urlEncode(value,'UTF-8'));
        	}
        }
        return StringUtils.joinArray(encoded,',');
    }
    
    private static List<String> deSerializeList(String serializedList){
    	final List<String> decoded = new List<String>();
        final List<String> split = StringUtils.split(serializedList,',');
        if(split != null && split.size() > 0){
            for(String value : split){
                decoded.add(EncodingUtil.urlDecode(value,'UTF-8'));
            }
        }
        return decoded;
    }
    
    public static List<SelectOption> toSelectOption(List<Integer> integers){
    	List<SelectOption> returnValue = new List<SelectOption>();
    	if(integers != null && !integers.isEmpty()){
    		for(Integer anInteger : integers){
    			returnValue.add(new SelectOption(''+anInteger,''+anInteger));
    		}
    	}
    	return returnValue;
    }


}