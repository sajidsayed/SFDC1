public class SearchController {
	//stores the parameter value passed into the page url
	public String strParamValue{get;set;}
	//stores the map of selected objects available for the current user;
	public map<id, Selected_SObject__c> mapSObj {get;set;}
	//stores describe map of all the objects.
	public Map<String, Schema.SObjectType> objectMap{get;set;}
	//list of objects available for searching.
	public list<Selectoption> selObjects{get;set;}
	//map storing api name and label of theMap<K, V>ject selected for search.
	private map<String, STRING> mapSelObject{get;set;}
	//list of lookup objects available for search criteria selection.
	public list<Selectoption> selLookupFlds{get;set;}
	public map<id,Search_Relationship__c> mapRel {get;set;}
	public map<String, String> mapRelationShipObjectName{get;set;}
	//stores selected object from the dropdown.
	//****NOTE: mapSelObject needs to be removed....refactor the code..

	public string sSelectedObject ;

	//setter for sSelectedObject.
	public void setSSelectedObject(String selectedObject){
		if(this.sSelectedObject != selectedObject){
			this.sSelectedObject = selectedObject;
			if(lstQueryResult != null)
				lstQueryResult.clear();
			//filters.clear();
			bDisplayResults = false;
			if(selectedObject == 'None'){
				selLookupFlds.clear();
				filters.clear();
				//createFilters();
				return;
			}
			for(Schema.Sobjecttype obj : objectMap.values()){
				if(obj.getDescribe().getName()==selectedObject){
					//store in the map selected object name and label.
					mapSelObject.clear();
					mapSelObject.put(obj.getDescribe().getName(),obj.getDescribe().getLabel());
				}

			}
			//System.debug('before calling mapSelObject: '+ mapSelObject + '\t selectedOBject: '+ sSelectedObject);
			//create list of relationships available for the search object.
			createRelationship();
			//System.debug('after calling mapSelObject: '+ mapSelObject);
			//System.debug('Setter sSelectedObject selLookupFlds: '+ selLookupFlds + '\t lstSelectedObjects: '+ lstSelectedObjects);

		}

	}

	//getter for sSelectedObject.
	public String getSSelectedObject(){
		return this.sSelectedObject;
	}

	//list of objects for which fields are available in search criteria.
	public list<Schema.SObjectType> lstSelectedObjects;
	//public map<string, Schema.SObjectType> mapOfSelObjects;
	//setter for lstSelectedObjects
	public void setLstSelectedObjects(list<Schema.SObjectType> lstOfObjects){
		this.lstSelectedObjects = lstOfObjects;
		//System.debug('Setting lstSelectedObjects:' + lstOfObjects);
		getFieldTypeOptions();
		//createLstOfSearchFields();
	}
	//getter for lstSelectedObjects.
	public list<Schema.SObjectType> getLstSelectedObjects(){return this.lstSelectedObjects;}

	//list of object fields available for search criteria.
	public list<SelectOption> selSearchFields{get;set;}
	public String selectedSrchFld{get;set;}
	public map<string, string> objectNameLabelMap{get;set;}
	//map of object fields available for search criteria.
	list<Map<String, Schema.SObjectField>> listOfMapOfObjectFields;
	Map<String, Schema.SObjectField> Object1Fields;
	Map<String, Schema.SObjectField> Object2Fields;
	Map<String, Schema.SObjectField> UserFields;
	public String primaryObject, secondaryObject;//will store the object name for the query creation. 
	public List<String> columnHeader{get;set;}
	public List<String> columnHeaderLabels{get;set;}
	public List<SObject> lstQueryResult{get; set;}
	public List<SObject>listOfSearchResultObjects{
		get{
			//System.debug('lstQueryResult size: ' + lstQueryResult.size());
			List<SObject> data = new List<SObject>();
			for(integer i=pmOffering.startIndex;i<pmOffering.endIndex&&i<lstQueryResult.size();i++){
				/*	        	SObject sObj = lstQueryResult.get(i);
	        	System.debug('sObj: ' + sObj);
				 */	            data.add(lstQueryResult.get(i));
				 // System.debug('lstQueryResult.get(i):' + lstQueryResult.get(i));

			}
			//System.debug(' Data.size(): ' + data.size());
			//System.debug(' Data: ' + data);
			listOfSearchResultObjects = data;
			return listOfSearchResultObjects;
		}
		set;
	}

	/*	public map<Id, map<String, String>> mapOfSObjectValues{get;set;}*/
	public PageManager pmOffering {get; set;}{pmOffering = new PageManager();}

	//stores selected relationship for the search object.
	public String strSelRelationship{get;
	set{
		List<String> lstOfObjNames  = new list<string>();
		List<String> lstOfTmpObjRef = new List<String>();
		Set<String> setOfObj = new set<String>();
		if(value != null){
			//System.debug('strSelRelationship value: ' + value);
			this.strSelRelationship = value;
			lstOfObjNames = value.split('&', 5);
		}else{
			if(selLookupFlds.size() > 0){
				if(bDisplayRelation){
					this.strSelRelationship = selLookupFlds.get(0).getValue();
					lstOfTmpObjRef = this.strSelRelationship.split('&', 5);
					//System.debug('lstOfTmpObjRef: '+ lstOfTmpObjRef[1] + '\t mapRelationShipObjectName: '+ mapRelationShipObjectName.get(lstOfTmpObjRef[1].trim()));
					lstOfObjNames.addAll(lstOfTmpObjRef);
					//lstOfObjNames.add(mapRelationShipObjectName.get(lstOfTmpObjRef[1].trim()));
				}else{
					//System.debug('strSelRelationship bDisplayRelation: '+ bDisplayRelation);
					lstOfObjNames.clear();
					for(SelectOption strLookup : selLookupFlds){
						lstOfTmpObjRef.clear();
						List<string> lstTmpStr = strLookup.getValue().split('&', 5);
						lstOfTmpObjRef.addAll(lstTmpStr);
						//						lstOfTmpObjRef.add(mapRelationShipObjectName.get(lstTmpStr[1].trim()));
						//System.debug('lstOfTmpObjRef: '+ lstOfTmpObjRef);
						setOfObj.addAll(lstOfTmpObjRef);
						//System.debug('lstTmpStr: '+ lstTmpStr + '\t setOfObj:' + setOfObj);
					}
					lstOfObjNames.addAll(setOfObj);
					createFilters();					
				}
			}
		}
		//System.debug('lstOfObjNames: ' + lstOfObjNames);
		//bDisplayFilters = true;
		//get the names of objects for which fields will be available for search criteria.
		lstSelectedObjects.clear();
		for(String strObjName : lstOfObjNames){
			Schema.SObjecttype tmpObj = objectMap.get(strObjName.trim());
			//check if strObjName is a relation, tmpObj will be null then fetch from mapRelationShipObjectName.
			if(tmpObj == null){
				String relObjectNameString =mapRelationShipObjectName.get(strObjName.trim()); 
				tmpObj = objectMap.get(relObjectNameString.trim());
			}
			lstSelectedObjects.add(tmpObj);
		}
		//System.debug('Setter strSelRelationship lstSelectedObjects: '+ lstSelectedObjects);
		//		lstSelectedObjects = obtainObjectDetails(lstOfObjNames);
	}
	}
	public boolean bDisplaySelectedObject{get;set;}
	public boolean bDisplayRelation{get;set;}
	public boolean bDisplayFilters{get;set;}
	public boolean bDisplayResults{get;set;}

	//customException
	public class SearchException extends Exception{}


	//Wrapper class for filters displayed.
	public class Filter{

		public String filterField{get;set;}//Varible corresponds to field Selected in filter
		public String filterOperator{get;set;}//Varible corresponds to operator Selected in filter
		public List<SelectOption> validOperators = new List<SelectOption>();//List Stores valid operators corresponding to the field selected
		public String filterFieldValue{get;set;}//Varible corresponds to value entered in filter
		public String filterIndex{get;set;}//Index displayed on filter
		public String filterSuffix{get;set;}

		//Setter and Getter
		public void setValidOperators(List<SelectOption> setterList){this.validOperators.addAll(setterList); } 
		public List<SelectOption> getValidOperators(){ return this.validOperators;}
		public void clear(){
			filterField ='';
			filterOperator ='';
			validOperators.clear();
			filterFieldValue ='';
			filterIndex ='';
			filterSuffix ='';
		}
	}
	Map<String, List<String>> field_ValidOperatorsMap = new Map<String, List<String>>();//Map stores data type and corresponding valid operators
	Map<String, String> field_FieldDataTypeMap = new Map<String, String>();//Map stores field type and corresponding data type
	public List<Filter> filters = new List<Filter>();//List for filters displayed on Page
	Map<String, String> operator_NameMap =  new Map<String, String>();//Map to store string name of a operator
	Map<String, String> altOperatorMap =  new Map<String, String>();//Map to store alernative operator for a operator such as 'in' can be alternative operator for '='

	//Setter and Getters
	public void setFilters(List<Filter> setterList){this.filters.addAll(setterList); } public List<Filter> getFilters(){ return this.filters;}

	//Constructor
	public SearchController(){
		declareAllMembers();
		bDisplayResults = false;
		strParamValue = ApexPages.currentPage().getParameters().get('selectedobject');
		if(strParamValue != null){
			setSSelectedObject(strParamValue);
			bDisplaySelectedObject = false;
			bDisplayRelation = false;
			//fetch all records of relationship.
			strSelRelationship = null;			
		}else{
			bDisplaySelectedObject = true;
			bDisplayRelation = true;
		}
		selObjects = createList();
		createFieldMaps();   
		createFilters();  
		//	createRelationship();
	}

	//Constructor
	public SearchController(string seletedObjectName){
		declareAllMembers();
		bDisplayResults = false;
		strParamValue = seletedObjectName;
		if(strParamValue != null){
			setSSelectedObject(strParamValue);
			bDisplaySelectedObject = false;
			bDisplayRelation = false;
			//fetch all records of relationship.
			strSelRelationship = null;			
		}else{
			bDisplaySelectedObject = true;
			bDisplayRelation = true;
		}
		selObjects = createList();
		createFieldMaps();   
		createFilters();  
		//	createRelationship();
	}

	private void declareAllMembers(){
		lstSelectedObjects = new list<Schema.SObjectType>();		
		objectMap = Schema.getGlobalDescribe();
		objectNameLabelMap = new map<string, string>();
		mapSelObject = new map<string, string>();
		//mapOfSelObjects = new map<string, Schema.SObjectType> ();
		selObjects = new list<Selectoption>();
		selLookupFlds = new list<Selectoption>();
		selSearchFields = new list<Selectoption>();
		mapRel = new map<id,Search_Relationship__c> ();
		mapRelationShipObjectName = new map<String, String> ();
		columnHeader = new list<String>();
		columnHeaderLabels = new list<String>();
		lstQueryResult = new List<SObject> ();
		listOfMapOfObjectFields = new list<Map<String, Schema.SObjectField>> ();
		try{
			if(strParamValue == null || strParamValue == '')
				mapSObj = new map<id, Selected_SObject__c>([Select s.Unique_Name__c, s.Profile_Id__c, s.OwnerId, s.Name, s.Id, s.Bypass_Sharing__c From Selected_SObject__c s where s.Profile_Id__c = :UserInfo.getProfileId() ]);
				else{
					string tmpParam = strParamValue + '%';
					mapSObj = new map<id, Selected_SObject__c>([Select s.Unique_Name__c, s.Profile_Id__c, s.OwnerId, s.Name, s.Id, s.Bypass_Sharing__c From Selected_SObject__c s where s.Profile_Id__c = :UserInfo.getProfileId() and s.Unique_Name__c like :tmpParam ]);
				}
			if(mapSObj.values().size() == 0)
				throw new NoDataException();
			System.debug('mapSObj: ' + mapSObj);


		}catch(NoDataException ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Search Utility not enabled! Please contact Administrator to enable search.');
			ApexPages.addMessage(myMsg);
		}

		//listOfObjects = new List<SObject> ();
		/*		mapOfSObjectValues = new map<Id, map<String, String>> ();*/
	}

	public void sampleMethod(){
		System.debug('Sample Method!!');
	}
	//Create a list of objects available for Search.
	private list<Selectoption> createList(){
		list<SelectOption> lstOpt = new list<SelectOption>();
		list<string> lstSObj = new list<string> ();

		lstOpt.add(new SelectOption('None', 'None'));
		for(Selected_SObject__c sobj : mapSObj.values()){
			lstSObj.add(sobj.name);
		}
		Set<String> setObjNames = new set<string> ();
		setObjNames.addAll(lstSObj);

		for(Schema.Sobjecttype obj : objectMap.values()){
			if(setObjNames.contains(obj.getDescribe().getName())){
				lstOpt.add(new SelectOption(obj.getDescribe().getName(),obj.getDescribe().getLabel()));
			}

		}

		return lstOpt;
	}

	//method creates the relationship list when an object is selected for search. 
	public void createRelationship(){

		if(mapSelObject.size() > 0){
			// System.debug('setObjName: '+ setObjName);
			//First clear all the available relationship in the list.
			selLookupFlds.clear();
			//System.debug('CreateRelationship sSelectedObject: ' + sSelectedObject);
			mapRel = new map<id, Search_Relationship__c>([Select s.Selected_SObject__r.Name, s.Selected_SObject__c, s.Relationship_Unique_Name__c, s.Relationship_Type__c, s.Object_2__c, s.Object_2_Value__c, s.Object_1__c, s.Object_1_Value__c, s.Name, s.Look_up_relationship_name__c, s.Look_up_field_name__c, s.Look_up_field_label__c, s.Id From Search_Relationship__c s where s.Selected_SObject__r.name = :sSelectedObject ]);
			//System.debug('mapRel: '+ mapRel);
			for(Search_Relationship__c sr : mapRel.values()){
				selLookupFlds.add(new SelectOption(sr.Object_1_Value__c+ ' & '+ sr.Look_up_relationship_name__c, sr.Object_1__c + ' & ' + sr.Look_up_field_label__c));
				mapRelationShipObjectName.put(sr.Look_up_relationship_name__c, sr.Object_2_Value__c);
			}
			selLookupFlds.sort();
			//System.debug('mapRelationShipObjectName: ' + mapRelationShipObjectName);

		}
	}

	/*	//creates a list of sobjects for which search fields should be available. 
	//Param: list of object names.
	public list<Schema.sobjecttype> obtainObjectDetails(list<string> lstStr){
		integer i = 0 ;
		//System.debug('lstStr: '+ lstStr);
		list<string> lstOfSearchObjectNames = new list<string>();
		if(objectNameLabelMap.size() == 0){
			for(Schema.Sobjecttype obj : objectMap.values()){
				objectNameLabelMap.put(obj.getDescribe().getName(),obj.getDescribe().getLabel());
			}
		}
		set<string> setObjName = objectNameLabelMap.keySet();

		//System.debug('objectNameLabelMap:'+ objectNameLabelMap.get('Contact'));
		//	System.debug('setObjName:'+ setObjName);

		//get the api names of object labels.
		for(String str2 : lstStr){
			for(string str : setObjName){
				 //System.debug('str2:' + str2 + '\t str: '+ str + '\t objectNameLabelMap.get(str):'+ objectNameLabelMap.get(str));
				// System.debug('objectNameLabelMap.get(str).equalsIgnoreCase(str2):'+ objectNameLabelMap.get(str).equalsIgnoreCase(str2));
				// System.debug('objectNameLabelMap.get(str).compareTo(str2):'+ objectNameLabelMap.get(str).compareTo(str2));
				//String tmpObjName = objectNameLabelMap.get(str).trim();
				// System.debug('str2.length():'+ str2.trim().length());
				// System.debug('tmpObjName.length():'+ tmpObjName.length());
				// System.debug('tmpObjName.equalsIgnoreCase(str2):'+ tmpObjName.equalsIgnoreCase(str2.trim()));

				if(str.equalsIgnoreCase(str2.trim())){
					// System.debug('Found match!!');
					lstOfSearchObjectNames.add(str);
					break;
				}
			}

		}
		//System.debug('lstOfSearchObjectNames: '+ lstOfSearchObjectNames);
		list<Schema.sobjecttype> lstSelectedObjectType = new list<Schema.sobjecttype>();
		lstSelectedObjectType.add(objectMap.get(lstOfSearchObjectNames.get(0)));
		lstSelectedObjectType.add(objectMap.get(lstOfSearchObjectNames.get(1)));
		// System.debug('lstSelectedObjectType: '+ lstSelectedObjectType);
		return lstSelectedObjectType;
	}
	 */
	/*	public void createLstOfSearchFields(){
		list<Selectoption> tmpSelLst = new list<Selectoption>();
		Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField> ();
		map<string, string> mapFldValLabel = new map<String, String>();
		// // System.debug('createLstOfSearchFields 111111');
		if(lstSelectedObjects != null && lstSelectedObjects.size() > 0){
			// System.debug('createLstOfSearchFields 222222');
			for(Schema.Sobjecttype strObj : lstSelectedObjects){
				// System.debug('createLstOfSearchFields 333333');
				Schema.Sobjecttype obj = objectMap.get(strObj.getDescribe().getName());
				fieldMap = obj.getDescribe().fields.getMap();

				if(fieldMap.size() > 0){
					for(Schema.SObjectField fld : fieldMap.values()){
						mapFldValLabel.put(fld.getDescribe().getName(), fld.getDescribe().getLabel());
						//System.debug('^^^^^^^Field :' + fld.getDescribe().getName() + '\t Relationship: '+ fld.getDescribe().getRelationshipName()+ '\n ReferenceTo: '+ fld.getDescribe().getReferenceTo());
					}
				}
			}
			SetupSearchComponentCls cls = new SetupSearchComponentCls();
			this.selSearchFields = cls.setupSelectOptions(mapFldValLabel) ;
			//System.debug('Search Fields:' + selSearchFields);
		}

		//return tmpSelLst;
	}
	 */
	public void createFieldMaps(){
		//Creating FieldTypeMap
		field_FieldDataTypeMap.put('STRING','String');
		field_FieldDataTypeMap.put('PICKLIST','String');
		field_FieldDataTypeMap.put('ID','String');
		field_FieldDataTypeMap.put('TEXTAREA','String');
		field_FieldDataTypeMap.put('MULTIPICKLIST','String');
		field_FieldDataTypeMap.put('EMAIL','String');
		field_FieldDataTypeMap.put('URL','String');    
		field_FieldDataTypeMap.put('PHONE','String'); 

		field_FieldDataTypeMap.put('DATETIME','Number');
		field_FieldDataTypeMap.put('DATE','Number');
		field_FieldDataTypeMap.put('PERCENT','Number');   
		field_FieldDataTypeMap.put('DOUBLE','Number');   
		field_FieldDataTypeMap.put('CURRENCY','Number');     

		field_FieldDataTypeMap.put('REFERENCE','Id'); 
		field_FieldDataTypeMap.put('ID','Id'); 

		field_FieldDataTypeMap.put('BOOLEAN','Boolean'); 
		field_FieldDataTypeMap.put('BOOLEAN','Boolean'); 

		//Creating Operator Map 
		field_ValidOperatorsMap.put('Id', new List<String>());
		field_ValidOperatorsMap.get('Id').add('=');
		field_ValidOperatorsMap.get('Id').add('!=');

		field_ValidOperatorsMap.put('Boolean', new List<String>());
		field_ValidOperatorsMap.get('Boolean').add('=');
		field_ValidOperatorsMap.get('Boolean').add('!=');

		field_ValidOperatorsMap.put('String', new List<String>());
		field_ValidOperatorsMap.get('String').add('=');
		field_ValidOperatorsMap.get('String').add('!=');
		field_ValidOperatorsMap.get('String').add('_%');
		field_ValidOperatorsMap.get('String').add('%_');
		field_ValidOperatorsMap.get('String').add('%_%');

		field_ValidOperatorsMap.put('Number', new List<String>());
		field_ValidOperatorsMap.get('Number').add('=');
		field_ValidOperatorsMap.get('Number').add('!=');
		field_ValidOperatorsMap.get('Number').add('<');
		field_ValidOperatorsMap.get('Number').add('>');

		//Creating operator and name map
		operator_NameMap.put('=','Equals');
		operator_NameMap.put('!=','not equal to');
		operator_NameMap.put('<','LessThan');
		operator_NameMap.put('>','GreaterThan');
		operator_NameMap.put('_%','startsWith');
		operator_NameMap.put('%_','endsWith');
		operator_NameMap.put('%_%','contains');

		//Creating alernative operator map
		altOperatorMap.put('=','IN');
		altOperatorMap.put('!=','NOT IN');

	}

	public void createFilters(){
		filters.clear();
		for(Integer i=0; i<5; i++){
			Filter tempFilter = new Filter();
			tempFilter.filterField='None:None:None';
			tempFilter.validOperators.add(new SelectOption('None','-- None --'));
			tempFilter.filterIndex = String.valueOf(i+1);
			if(i!=4){
				tempFilter.filterSuffix = 'AND';
			}
			filters.add(tempFilter);
		}
		//System.debug('inside createFilters'+ filters);
	}

	// Method filters operator corresponding to the field selected

	public void filterOperators(){
		String fieldType, fieldDataType;
		for(Integer i=0; i<5; i++){
			//System.debug('######################'+filters[i].filterField);
			fieldType = filters[i].filterField.split(':')[2];
			if(fieldType!='None'){
				fieldDataType = field_FieldDataTypeMap.get(fieldType);
				filters[i].validOperators.clear();
				filters[i].validOperators.add(new SelectOption('None','-- None --'));
				for(String operator: field_ValidOperatorsMap.get(fieldDataType)){
					filters[i].validOperators.add(new SelectOption(operator,operator_NameMap.get(operator)));
				}
			}
			else{
				filters[i].validOperators.clear();
				filters[i].validOperators.add(new SelectOption('None','-- None --'));
			}
		}
	}
	public List<SelectOption> getFieldTypeOptions() {                
		List<SelectOption> options = new List<SelectOption>();     
		string strObjectLabel='';
		options.add(new SelectOption('None:None:None',System.Label.EMC_None));  
		if(lstSelectedObjects!= null && lstSelectedObjects.size() > 0){
			listOfMapOfObjectFields.clear();
			map<String, Schema.Sobjecttype> mapOfSelectedObjects = new map<String, Schema.Sobjecttype>();
			//System.debug('inside getFieldTypeOptions lstSelectedObjects: ' + lstSelectedObjects);
			for(Integer  j=0; j<lstSelectedObjects.size() ; j++){
				mapOfSelectedObjects.put(lstSelectedObjects.get(j).getDescribe().getName(),lstSelectedObjects.get(j));
			}
			listOfMapOfObjectFields = new list<Map<String, Schema.SObjectField>> ();			
			integer iCounter=0;
			integer listPosition = 0;
			//System.debug('mapOfSelectedObjects: '+mapOfSelectedObjects+ '\tlistOfMapOfObjectFields: ' + listOfMapOfObjectFields);
			iCounter=0;
			//boolean bSelectedObjCounted=false;
			Set<String> setOfObjectNames = new Set<String>();
			Set<String> setOfObjectLabels = new Set<String>();
			Set<String> setOfRelNames = mapRelationShipObjectName.keySet();
			Set<String> setOfRelNamesClone = setOfRelNames.clone();
			list<Selectoption> selLookupFldsClone = new list<SelectOption>();
			if(bDisplaySelectedObject){
				for(SelectOption selectedLoopUp : selLookupFlds){
					if(selectedLoopUp.getValue().equalsIgnoreCase(strSelRelationship)){
						selLookupFldsClone.add(new SelectOption(selectedLoopUp.getValue(),selectedLoopUp.getLabel()));
					}
				}

			}else{
				selLookupFldsClone = selLookupFlds;	
			}

			System.debug('selLookupFldsClone: '+ selLookupFldsClone);


			for(SelectOption strLookup : selLookupFldsClone){
				List<string> lstTmpStr = strLookup.getValue().split('&', 5);
				List<string> lstTmpStrLabels = strLookup.getLabel().split('&', 5);
				iCounter=0;
				/*if(bDisplaySelectedObject){
					if(!bSelectedObjCounted)
						bSelectedObjCounted=true;
					else
						continue;
				}*/
				for(String strLookUpObj : lstTmpStr){
					System.debug('strLookUpObj: '+ strLookUpObj);
					if(setOfObjectNames.contains(strLookUpObj))
						continue;

					setOfObjectNames.add(strLookUpObj);
					if(!setOfObjectLabels.contains(lstTmpStrLabels.get(iCounter))){
						strObjectLabel = lstTmpStrLabels.get(iCounter++);
					}
					else{
						strObjectLabel = lstTmpStrLabels.get(++iCounter);
					}
					setOfObjectLabels.add(strObjectLabel);
					Schema.SObjectType obj1 = objectMap.get(strLookUpObj.trim());
					if(obj1 == null){
						obj1= objectMap.get(mapRelationShipObjectName.get(strLookUpObj.trim()));
					}
					System.debug('obj1.getDescribe().getName: '+ obj1.getDescribe().getName());
					string strObjectName = strLookUpObj.trim();

					Map<String, Schema.SObjectField> mapOfObjFlds = obj1.getDescribe().fields.getMap();
					List<String> Obj1Keys = sortByFieldLabel(mapOfObjFlds);
					System.debug('setOfRelNamesClone: ' + setOfRelNamesClone );
					for(String key:Obj1Keys) {
						Schema.DescribeFieldResult d = mapOfObjFlds.get(key).getDescribe();

						if(d.isAccessible() ) {
							//if (isSupportedFieldType(d)) {
							String label = d.getLabel();
							label =strObjectLabel +': '+label ;
							String fieldType = (d.getType()).name();
							if(key=='OwnerId'){
								continue;
							}
							if(label=='Opportunity: Account Owner'){
								System.debug('----------Relationship Name----->'+d.getRelationshipName());
								label = 'Opportunity: Account Owner Name';
								key = d.getRelationshipName()+'.Name';
								fieldType = 'STRING';
							}
							if(fieldType=='Reference'){
								key = d.getRelationshipName()+'.Name';
								fieldType = 'STRING';
							}
							SelectOption opt =new SelectOption(strObjectName+':'+key+':'+fieldType, label); 
							System.debug('Opt: ' + opt);
							options.add(opt);
						}
						//}
					}
				}
			}

		}else{

		}
		System.debug('test----->'+options);
		//options.sort();
		return options;

	}

	//new getFieldTypeOptions
	public List<SelectOption> getFieldTypeOptions2() {                
		List<SelectOption> options = new List<SelectOption>();     
		string strObjectLabel='';
		options.add(new SelectOption('None:None:None',System.Label.EMC_None));  
		if(lstSelectedObjects!= null && lstSelectedObjects.size() > 0){
			/*Set<String> userFieldsVisible = new Set<String>();
			userFieldsVisible.add('Alias');
			userFieldsVisible.add('FirstName');
			userFieldsVisible.add('LastName');
			userFieldsVisible.add('Name');
			userFieldsVisible.add('District__c');
			userFieldsVisible.add('Area__c');
			userFieldsVisible.add('Division__c');
			userFieldsVisible.add('Forecast_Group__c');
			userFieldsVisible.add('BU_Attribute__c');*/

			//createFiters(); 
			//list<Schema.SObjectType> lstSelectedObjects;
			//System.debug('inside getFieldTypeOptions lstSelectedObjects: ' + lstSelectedObjects);
			listOfMapOfObjectFields.clear();
			map<String, Schema.Sobjecttype> mapOfSelectedObjects = new map<String, Schema.Sobjecttype>();
			//System.debug('inside getFieldTypeOptions lstSelectedObjects: ' + lstSelectedObjects);
			for(Integer  j=0; j<lstSelectedObjects.size() ; j++){
				mapOfSelectedObjects.put(lstSelectedObjects.get(j).getDescribe().getName(),lstSelectedObjects.get(j));
			}
			listOfMapOfObjectFields = new list<Map<String, Schema.SObjectField>> ();			
			integer iCounter=0;
			integer listPosition = 0;
			for( Schema.Sobjecttype tmpObj1 : lstSelectedObjects){
				String strObjKey = tmpObj1.getDescribe().getName();
				listOfMapOfObjectFields.add(objectMap.get(strObjkey).getDescribe().fields.getMap());
			}
			/*for(String strObjkey : mapOfSelectedObjects.keySet()){
				//System.debug('strObjkey: '+ strObjkey+ '\tobjectMap.get(strObjkey).getDescribe()'+ objectMap.get(strObjkey).getDescribe());
				listOfMapOfObjectFields.add(objectMap.get(strObjkey).getDescribe().fields.getMap());
			}*/
			/*Object1Fields = objectMap.get(object1).getDescribe().fields.getMap();
			 Object2Fields = objectMap.get(object2).getDescribe().fields.getMap();*/
			//System.debug('mapOfSelectedObjects: '+mapOfSelectedObjects+ '\tlistOfMapOfObjectFields: ' + listOfMapOfObjectFields);
			iCounter=0;
			Set<String> setOfRelNames = mapRelationShipObjectName.keySet();
			Set<String> setOfRelNamesClone = setOfRelNames.clone();
			for( Map<String, Schema.SObjectField> mapOfObjFlds : listOfMapOfObjectFields){
				List<String> Obj1Keys = sortByFieldLabel(mapOfObjFlds);
				System.debug('setOfRelNamesClone: ' + setOfRelNamesClone );
				for(String strRelationshipName : setOfRelNamesClone){
					for( Schema.Sobjecttype tmpObj1 : lstSelectedObjects){
						System.debug('setOfRelNames: ' + setOfRelNames + 'strRelationshipName: '+ strRelationshipName+ '\t tmpObj1.getDescribe().getName() ' + tmpObj1.getDescribe().getName());
						if(mapRelationShipObjectName.get(strRelationshipName).equalsIgnoreCase(tmpObj1.getDescribe().getName())){
							if(strObjectLabel == '' ){
								strObjectLabel = strRelationshipName;
								if(!bDisplaySelectedObject ){
									/*System.debug('strSelRelationship.split.get(1).equalsIgnoreCase(strRelationshipName): '+ strSelRelationship.split('&',5).get(1));
									if( strSelRelationship.split('&',5).get(1).trim().equalsIgnoreCase(strRelationshipName)){
										strObjectLabel = strRelationshipName;
										break;
									}
								}else{*/
									setOfRelNamesClone.remove(strRelationshipName);
									break;
								}
							}
						}
					}

					/*					if(mapRelationShipObjectName.get(strRelationshipName).equalsIgnoreCase(mapOfSelectedObjects.values().get(iCounter).getDescribe().getName())){
												if(mapOfSelectedObjects.values().get(iCounter).getDescribe().isCustom()){
							if(strObjectLabel != '')
							  strObjectLabel = strRelationshipName;
						}else{

						if(strObjectLabel == '' ){
							if(bDisplaySelectedObject ){
								System.debug('strSelRelationship.split.get(1).equalsIgnoreCase(strRelationshipName): '+ strSelRelationship.split('&',5).get(1).equalsIgnoreCase(strRelationshipName));
								if( strSelRelationship.split('&',5).get(1).trim().equalsIgnoreCase(strRelationshipName)){
									strObjectLabel = strRelationshipName;
									break;
								}
							}else{
								System.debug('setOfRelNames: ' + setOfRelNames + 'strRelationshipName: '+ strRelationshipName+ '\tmapRelationShipObjectName.get(strRelationshipName): ' + mapRelationShipObjectName.get(strRelationshipName)+ '\nmapOfSelectedObjects.values().get(iCounter).getDescribe().getName(): '+ mapOfSelectedObjects.values().get(iCounter).getDescribe().getName());
								strObjectLabel = strRelationshipName;
								setOfRelNames.remove(strRelationshipName);
								break;
							}
						}
						//						}
					}
					 */				}

				System.debug('111 strObjectLabel: ' + strObjectLabel);
				if(strObjectLabel==''){
					//strObjectLabel = mapOfSelectedObjects.values().get(iCounter).getDescribe().getName();
					strObjectLabel = sSelectedObject;
				}
				System.debug('222 strObjectLabel: ' + strObjectLabel);
				for(String key:Obj1Keys) {
					Schema.DescribeFieldResult d = mapOfObjFlds.get(key).getDescribe();

					if(d.isAccessible() ) {
						//if (isSupportedFieldType(d)) {
						String label = d.getLabel();
						label =strObjectLabel +': '+label ;
						String fieldType = (d.getType()).name();
						if(key=='OwnerId'){
							continue;
						}
						if(label=='Opportunity: Account Owner'){
							System.debug('----------Relationship Name----->'+d.getRelationshipName());
							label = 'Opportunity: Account Owner Name';
							key = d.getRelationshipName()+'.Name';
							fieldType = 'STRING';
						}
						if(fieldType=='Reference'){
							key = d.getRelationshipName()+'.Name';
							fieldType = 'STRING';
						}
						SelectOption opt =new SelectOption(strObjectLabel+':'+key+':'+fieldType, label); 
						//System.debug('Opt: ' + opt);
						options.add(opt);
					}
					//}
				}
				strObjectLabel='';
				iCounter++;
			}

			/*			 List<String> Obj1Keys = sortByFieldLabel(Object1Fields);
			 List<String> Obj2Keys = sortByFieldLabel(Object2Fields);
			 //List<String> Userkeys = sortByFieldLabel(UserFields);

			 System.debug('Obj1Keys: '+Obj1Keys );
			 System.debug('Obj1Keys size: '+Obj1Keys.size() );

			 System.debug('Obj2Keys: '+Obj2Keys);
			 System.debug('Obj2Keys size: '+Obj2Keys.size() );

			 //if(selectedObject.split(';')[1]!='OpportunitySplit'){           
			 for(String key:Obj1Keys) {
				 Schema.DescribeFieldResult d = Object1Fields.get(key).getDescribe();

				 if(d.isAccessible() ) {
					 if (isSupportedFieldType(d)) {
						 String label = d.getLabel();
						 label = object1Label+': '+label ;
						 String fieldType = (d.getType()).name();
						 if(key=='OwnerId'){
							 continue;
						 }
						 if(label=='Opportunity: Account Owner'){
							 System.debug('----------Relationship Name----->'+d.getRelationshipName());
							 label = 'Opportunity: Account Owner Name';
							 key = d.getRelationshipName()+'.Name';
							 fieldType = 'STRING';
						 }
						 if(fieldType=='Reference'){
							 key = d.getRelationshipName()+'.Name';
							 fieldType = 'STRING';
						 }
						 options.add(new SelectOption(lstSelectedObjects[0]+':'+key+':'+fieldType, label));
					 }
				 }
			 }
			 //}
			 for(String key:Obj2Keys) {
				 Schema.DescribeFieldResult d = Object2Fields.get(key).getDescribe();
				 if(d.isAccessible() ) {
					 if (isSupportedFieldType(d)) {
						 String label = d.getLabel();
						 label = object2Label+': '+label ;
						 String fieldType = (d.getType()).name();
						 System.debug('---------in Options------'+object2+'-------------'+key+'----------'+userFieldsVisible.contains(key));
						 if(object2 == 'User' && (!userFieldsVisible.contains(key))){
							 continue;
						 }
						 if(object2 == 'User' && (userFieldsVisible.contains(key))){
							 key = 'User.'+key;
						 }
						 if(fieldType=='Reference'){
							 key = d.getRelationshipName()+'.Name';
							 fieldType = 'STRING';
						 }
						 options.add(new SelectOption(lstSelectedObjects[1]+':'+key+':'+fieldType, label));
					 }
				 }
			 }*/
			/*        if(object2 == 'User'){
                options.add(new SelectOption(selectedObject.split(';')[1]+':'+'TeamMemberRole'+':'+'PICKLIST', 'Opportunity Team Member: Team Role'));
            }
			 */        /*for(String key:OpptySplitkeys) {
                Schema.DescribeFieldResult d = SplitFields.get(key).getDescribe();

                if(d.isAccessible() ) {
                    if (isSupportedFieldType(d)) {
                        String label = d.getLabel();
                        label = 'Split'+': '+label ;
                        System.debug('Split labels----->'+label);
                        options.add(new SelectOption('Split.'+key, label));
                    }
                }

            }*/

		}else{

		}
		System.debug('test----->'+options);
		//options.sort();
		return options;

	}

	public List<SelectOption> getFieldTypeOptions(integer oldFunction) {                
		List<SelectOption> options = new List<SelectOption>();      
		options.add(new SelectOption('None:None:None',System.Label.EMC_None));  
		if(lstSelectedObjects!= null && lstSelectedObjects.size() > 0){
			Set<String> userFieldsVisible = new Set<String>();
			userFieldsVisible.add('Alias');
			userFieldsVisible.add('FirstName');
			userFieldsVisible.add('LastName');
			userFieldsVisible.add('Name');
			userFieldsVisible.add('District__c');
			userFieldsVisible.add('Area__c');
			userFieldsVisible.add('Division__c');
			userFieldsVisible.add('Forecast_Group__c');
			userFieldsVisible.add('BU_Attribute__c');

			//createFiters(); 
			System.debug('inside getFieldTypeOptions lstSelectedObjects: ' + lstSelectedObjects);
			String object1 = lstSelectedObjects.get(0).getDescribe().getName();
			String object2 = lstSelectedObjects.get(1).getDescribe().getName();

			/*        if(object2=='OpportunityTeamMember'){
                object2 = 'User';
            }
			 */        System.debug('-------------Object 2 Name-----------'+object2);


			 String object1Label = lstSelectedObjects.get(0).getDescribe().getLabel();
			 String object2Label = lstSelectedObjects.get(1).getDescribe().getLabel();

			 Object1Fields = objectMap.get(object1).getDescribe().fields.getMap();
			 Object2Fields = objectMap.get(object2).getDescribe().fields.getMap();

			 System.debug('--------------OBJECT 1 LABEL: '+object1Label);
			 //Object1Fields = Schema.SObjectType.Opportunity.fields.getMap();
			 //Object2Fields = Schema.SObjectType.Account.fields.getMap();
			 //SplitFields = Schema.SObjectType.OpportunitySplit.fields.getMap();

			 System.debug('Object1Fields: '+Object1Fields);
			 System.debug('Object1Fields size: '+Object1Fields.size() );

			 System.debug('Object2Fields: '+Object2Fields);
			 System.debug('Object2Fields size: '+Object2Fields.size() );

			 //System.debug('fieldMapOpptySplit Fields'+SplitFields);
			 //System.debug('fieldMapOpptySplit size'+SplitFields.size() );

			 List<String> Obj1Keys = sortByFieldLabel(Object1Fields);
			 List<String> Obj2Keys = sortByFieldLabel(Object2Fields);
			 //List<String> Userkeys = sortByFieldLabel(UserFields);

			 System.debug('Obj1Keys: '+Obj1Keys );
			 System.debug('Obj1Keys size: '+Obj1Keys.size() );

			 System.debug('Obj2Keys: '+Obj2Keys);
			 System.debug('Obj2Keys size: '+Obj2Keys.size() );

			 //if(selectedObject.split(';')[1]!='OpportunitySplit'){           
			 for(String key:Obj1Keys) {
				 Schema.DescribeFieldResult d = Object1Fields.get(key).getDescribe();

				 if(d.isAccessible() ) {
					 // if (isSupportedFieldType(d)) {
					 String label = d.getLabel();
					 label = object1Label+': '+label ;
					 String fieldType = (d.getType()).name();
					 if(key=='OwnerId'){
						 continue;
					 }
					 if(label=='Opportunity: Account Owner'){
						 System.debug('----------Relationship Name----->'+d.getRelationshipName());
						 label = 'Opportunity: Account Owner Name';
						 key = d.getRelationshipName()+'.Name';
						 fieldType = 'STRING';
					 }
					 if(fieldType=='Reference'){
						 key = d.getRelationshipName()+'.Name';
						 fieldType = 'STRING';
					 }
					 options.add(new SelectOption(lstSelectedObjects[0]+':'+key+':'+fieldType, label));
					 //}
				 }
			 }
			 //}
			 for(String key:Obj2Keys) {
				 Schema.DescribeFieldResult d = Object2Fields.get(key).getDescribe();
				 if(d.isAccessible() ) {
					 // if (isSupportedFieldType(d)) {
					 String label = d.getLabel();
					 label = object2Label+': '+label ;
					 String fieldType = (d.getType()).name();
					 System.debug('---------in Options------'+object2+'-------------'+key+'----------'+userFieldsVisible.contains(key));
					 if(object2 == 'User' && (!userFieldsVisible.contains(key))){
						 continue;
					 }
					 if(object2 == 'User' && (userFieldsVisible.contains(key))){
						 key = 'User.'+key;
					 }
					 if(fieldType=='Reference'){
						 key = d.getRelationshipName()+'.Name';
						 fieldType = 'STRING';
					 }
					 options.add(new SelectOption(lstSelectedObjects[1]+':'+key+':'+fieldType, label));
					 // }
				 }
			 }
			 /*        if(object2 == 'User'){
                options.add(new SelectOption(selectedObject.split(';')[1]+':'+'TeamMemberRole'+':'+'PICKLIST', 'Opportunity Team Member: Team Role'));
            }
			  */        /*for(String key:OpptySplitkeys) {
                Schema.DescribeFieldResult d = SplitFields.get(key).getDescribe();

                if(d.isAccessible() ) {
                    if (isSupportedFieldType(d)) {
                        String label = d.getLabel();
                        label = 'Split'+': '+label ;
                        System.debug('Split labels----->'+label);
                        options.add(new SelectOption('Split.'+key, label));
                    }
                }

            }*/

		}else{

		}
		System.debug('test----->'+options);
		//options.sort();
		return options;

	}


	private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> gd) {
		List<String> keys = new List<String>();

		Map<String, List<String>> labelMap = new Map<String, List<String>>();

		for(Schema.SObjectField s:gd.values()) {
			String label = s.getDescribe().getLabel();
			if(labelMap.get(label) == null) {
				labelMap.put(label, new List<String>());
			}

			labelMap.get(label).add(s.getDescribe().getName());        
		}

		List<String> labels = new List<String>(labelMap.keySet());
		labels.sort();

		for(String label:labels){
			keys.addAll(labelMap.get(label));
		}

		return keys;
	}
	private boolean isSupportedFieldType(DescribeFieldResult d) {

		// always return true for now, but in future some fields might not be supported
		return true;
	}        


	//Old Version
	/*
    Method to create Query from filters
	 */
	public String createQuery(){
		try{
			System.debug('Throwing SearchException. sSelectedObject: ' + sSelectedObject);
			if(sSelectedObject == 'None'){
				//System.debug('Throwing SearchException.');
				throw new SearchException();
			}
			Set<String> objectsSelected = new Set<String>();
			String query='Select Id, Name';
			String strFrom = ' from ' + sSelectedObject+ ' ';
			String condition = '';
			String strLimit = ' limit 100';
			List<Filter> validFilters = new List<Filter>();

			columnHeader.clear();
			columnHeaderLabels.clear();
			//columnHeader.add('Id');
			columnHeader.add('Name');
			columnHeaderLabels.add('Name');
			System.debug('sSelectedObject: ' + sSelectedObject);

			for(Search_Field__c sf : [SELECT  Id, Display_Field_Label__c, Display_Field_Name__c, Name, Selected_SObject__c, Column_Unique_Name__c FROM Search_Field__c  where Selected_SObject__r.name = :sSelectedObject ]){
				System.debug('Search field: ' + sf);
				String fldName = sf.Display_Field_Name__c.trim().toUpperCase();

				if(!(fldName.equals('ID') || fldName.equalsIgnoreCase('NAME'))){
					query+= ' , '+ sf.Display_Field_Name__c + ' ';
					columnHeader.add(sf.Display_Field_Name__c);
					columnHeaderLabels.add(sf.Display_Field_Label__c);
				}
			}

			for(Integer i=0; i<5; i++){
				if(filters[i].filterField.split(':')[1] != 'None' && filters[i].filterOperator!='None' && (filters[i].filterFieldValue!=null && (filters[i].filterFieldValue.trim()).length()>0)){
					objectsSelected.add(filters[i].filterField.split(':')[0]);
					validFilters.add(filters[i]);
				}
			}
			System.debug('validFilters: ' + validFilters);
			primaryObject = this.sSelectedObject;
			/*        
	        if(objectsSelected.size()==0){//Error: filter criteria not specified properly
	            query = 'ERROR';
	            return query;
	        }
	        else if(objectsSelected.size()==1){//When fields of only one object is selected
	            for(String tempObj: objectsSelected){
	                primaryObject = tempObj;
	            }
	            if(primaryObject=='Product2'){
	                primaryObject= 'OpportunityLineItem';
	            }
	        }
	        else{//When fields of both object are selected
	            if(objectsSelected.contains('Account')){
	                primaryObject= 'Opportunity';
	                secondaryObject = 'Account';
	            }
	            else if(objectsSelected.contains('Product2')){
	                primaryObject= 'OpportunityLineItem';
	                secondaryObject = 'Opportunity';
	            }
	            else{
	                secondaryObject = 'Opportunity';
	                for(String tempObj: objectsSelected){
	                    if(tempObj!=secondaryObject){
	                        primaryObject = tempObj;
	                    }
	                }
	            }
	        }
	        //WR-170870
	        if(primaryObject == 'Opportunity'){
	            query += 'Select Id,Opportunity_Number__c, Account.Name, Amount, CloseDate, Name, Owner.Alias, CurrencyIsoCode,'+
	                    ' StageName, Owner.Name, Owner.isActive, Sales_Force__c, LeadSource,'+ 
	                    ' Account.BillingState, Account.BillingCountry from '+primaryObject+' where IsClosed=false and';
	        }
	        else if(primaryObject == 'OpportunityLineItem'){
	            query += ' OpportunityId, Opportunity.Account.Name, Opportunity.Amount, Opportunity.CloseDate, Opportunity.Name, Opportunity.Owner.Alias, Opportunity.CurrencyIsoCode,'+
	                    ' Opportunity.StageName, Opportunity.Owner.Name, Opportunity.Owner.isActive, Opportunity.Sales_Force__c, Opportunity.LeadSource,'+ 
	                    ' Opportunity.Account.BillingState, Opportunity.Account.BillingCountry from '+primaryObject+' where Opportunity.IsClosed=false and';
	        }
	        else if(primaryObject == 'OpportunitySplit'){
	            query += ' Select OpportunityId from '+primaryObject+' where';
	        }
	        else{
	            query += ' Select OpportunityId from '+primaryObject+' where Opportunity.IsClosed=false and';
	        }
			 */      
			String fieldObject, fieldName, fieldType, operator, value;
			System.debug('-----------VALID FILTERS:'+validFilters.size());
			System.debug('--------Primary Object:'+primaryObject);
			for(Integer i=0; i<validFilters.size(); i++){
				System.debug('-----------ITERATION:'+i);
				fieldObject = validFilters[i].filterField.split(':')[0];
				fieldName = validFilters[i].filterField.split(':')[1];
				fieldType = validFilters[i].filterField.split(':')[2];
				operator = validFilters[i].filterOperator;
				value = validFilters[i].filterFieldValue;
				value = value.replace('\'','\\\'');
				String bigValue='(';
				for(String val: value.split(',')){
					val = val.trim();
					bigValue +='\''+val+'\','; 
				}
				//Processing field name
				System.debug('------Field Object:'+fieldObject+'-----Field Name:'+fieldName+'-----Field Type:'+fieldType);
				if(primaryObject != 'OpportunityLineItem'){//Field of Primary Object fetch directly
					System.debug('-----1-----');
					if(fieldObject == primaryObject){//Field of Primary Object fetch directly
						System.debug('-----2-----');
						condition += ' '+fieldName;
					}
					else{//Field of Primary Object fetch using relationship
						System.debug('-----3-----');
						//condition += createSecondaryObjectsQueryString(fieldObject, fieldName);
						condition += ' '+fieldObject+'.'+fieldName;
						//condition += ' '+secondaryObject+'.'+fieldName;
					}
				}
				else{
					System.debug('-----4-----');
					if(fieldObject == 'Product2'){//Field of Product fetch using OpportunityLineItem relationship with Product
						System.debug('-----5-----');
						condition += ' '+primaryObject+'.PriceBookEntry.Product2.'+fieldName;
					}
					else{//Field of Opportunity fetch using OpportunityLineItem relationship with Opportunity
						System.debug('-----6-----');
						condition += ' '+secondaryObject+'.'+fieldName;
					}
				}

				//Processing operator and value.
				if(field_FieldDataTypeMap.get(fieldType)=='String' || field_FieldDataTypeMap.get(fieldType)=='Id'){//Field of type String processed with quotes
					System.debug('-----7-----');
					if(operator.contains('%')){//like operator to be used
						System.debug('-----8-----');
						condition += ' like'+' \''+operator.replace('_',value)+'\'';
					}   
					else{
						System.debug('-----9-----');
						if(bigValue.length()>1){
							bigValue = bigValue.substring(0,bigValue.length()-1);
							System.debug('-----9.5-----');
							operator = altOperatorMap.get(operator);
							condition += ' '+operator+' '+bigValue+')';
						}
						else{
							condition += ' '+operator+' \''+value+'\'';
						}
					}
				}
				else{//Non-String type field processed without quotes
					System.debug('-----10-----');
					condition += ' '+operator+''+value+'';
				}

				if(i!=(validFilters.size()-1)){//Appending "and" in query
					System.debug('-----11-----');
					condition += ' and';
				}
			}
			if (condition != ''){
				condition += ' order by ' + primaryObject+ '.Name';
				condition = ' where '+ condition;
			}
			System.debug('-----------Condition:'+condition);
			query+= strFrom;
			query +=condition;
			query +=strLimit;
			System.debug('CreateQuery query: '+ query);
			return query;			
		}catch(SearchException e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select an object to search.');
			ApexPages.addMessage(myMsg);
			return null;
		}


	}
	public PageReference Search(){
		String queryString = createQuery();
		bDisplayResults = true;
		map<String, String> mapOfNameValue;
		System.debug('Search function ' + queryString);
		try{
			pmOffering.page = 0;
			if(queryString == null){
				throw new SearchException();
			}
			//check if userprofile is enabled for bypass security for the selected object.
			for(Selected_SObject__c sObj1 : mapSObj.values()){
				if(sSelectedObject== sObj1.name){
					if(sObj1.Bypass_Sharing__c =='Yes' ){
						SearchDataWithBypassSecurity bypassSecurityObj = new SearchDataWithBypassSecurity(queryString);
						lstQueryResult = bypassSecurityObj.getData();
					}else{
						SearchDataWithEnforceSecurity enforceSecurityObj = new SearchDataWithEnforceSecurity(queryString);
						lstQueryResult = enforceSecurityObj.getData(); 
					}
				}
			}
			lstQueryResult = database.query(queryString);
			//contact c  = (contact)lstQueryResult.get(0);
			pmOffering.numberOfRows = lstQueryResult.size();
			System.debug('pmOffering.numberOfRows: ' + pmOffering.numberOfRows);
			/*			for(SObject object1: lstQueryResult){
				System.debug('Object id: ' + object1.id);
				if(mapOfSObjectValues == null)
					mapOfSObjectValues = new map<Id, map<String, String>> ();
				if(!mapOfSObjectValues.containsKey(object1.id)){
					mapOfNameValue = new map<String, String>();
					mapOfNameValue.put('Name', (String)object1.get('Name'));
					mapOfSObjectValues.put(object1.id, mapOfNameValue);
				}else{
					mapOfNameValue = mapOfSObjectValues.get(object1.id);
					mapOfNameValue.put('Name', (String)object1.get('Name'));
					mapOfSObjectValues.put(object1.id, mapOfNameValue);
				}
			}
			System.debug('mapOfSObjectValues: '+ mapOfSObjectValues);
			 */
		}catch(QueryException e){
			String errMsg = e.getMessage();
			System.debug('----------IN EXCEPTION------'+errMsg+'----'+errMsg.contains('invalid ID field:'));
			if(errMsg.contains('invalid ID field:')){
				errMsg = errMsg.replace('invalid ID field:','Please enter salesforce Id rather than'); 
				System.debug('-----------'+errMsg.replace('invalid ID field:','Please enter salesforce Id rather than'));
			}
			ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please check the filter criteria and advance criteria :- '+ errMsg);
			ApexPages.addMessage(msg2);
			//throw e;
		}
		catch(SearchException e){
			ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please select an object to search.');
			ApexPages.addMessage(msg2);
		}
		return null;
	}

	//Create query string for the secondary objects. 
	//Input parameters: Object label and field name.
	//find if the object is a custom object then use Relationship name else use ReferenceTo value.
	public string createSecondaryObjectsQueryString(String fieldObject, String fieldName){
		String qryStr='';
		//get the describe result of the fieldObject.
		Schema.DescribeSObjectResult objResult = objectMap.get(fieldObject.trim()).getDescribe() ;
		//System.debug('fieldObject: ' + fieldObject + '\t fieldName: ' + fieldName + '\n objResult: ' + objResult );

		//fieldMap of the fieldObject
		Map<String, Schema.SObjectField> fieldObjectFieldMap = new Map<String, Schema.SObjectField> ();
		string strFieldApiName = '';

		//get the fieldMap of the selectedObject.
		Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField> ();
		Map<String, Schema.SObjectField> referenceTypefieldMap = new Map<String, Schema.SObjectField> ();
		Schema.Sobjecttype obj = objectMap.get(sSelectedObject);
		fieldMap = obj.getDescribe().fields.getMap();
		//create a fieldmap of reference type fields only.
		for(Schema.SObjectField fld : fieldMap.values()){
			if(fld.getDescribe().getType() == schema.Displaytype.Reference){
				referenceTypefieldMap.put(fld.getDescribe().getName(), fld);
			}
		}

		if(objResult != null){
			for(Schema.SObjectField refFld : referenceTypefieldMap.values()){
				fieldObjectFieldMap.clear();
				String strObjectLabel = refFld.getDescribe().getReferenceTo()[0].getDescribe().getName().trim().toUpperCase();
				fieldObject = fieldObject.trim().toUpperCase();
				//System.debug('fieldObject: ' + fieldObject + '\t strObjectLabel: ' + strObjectLabel);
				if(strObjectLabel.equals(fieldObject)){
					//create map of fields of the secondary object.
					fieldObjectFieldMap = refFld.getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
					for(Schema.SObjectField fld2 : fieldObjectFieldMap.values()){
						fieldName = fieldName.trim().toUpperCase();
						string tmpFldLabel = fld2.getDescribe().getName().trim().toUpperCase();
						//System.debug('fieldName: ' + fieldName + '\t tmpFldLabel:' + tmpFldLabel);
						if(fieldName.equals(tmpFldLabel) ){
							strFieldApiName = tmpFldLabel;
							break;
						}
					}

					if(objResult.isCustom()){
						qryStr= ' ' + refFld.getDescribe().getRelationshipName() + '.'+ strFieldApiName;
					}else{

						qryStr= ' ' + refFld.getDescribe().getReferenceTo().get(0) + '.'+ strFieldApiName;
					}
					break;
				}
			}

		}else{
			System.debug('objResult is NULL !!!!!');
		}

		//System.debug('qryStry: ' + qryStr);
		return qryStr;
	}

	public class NoDataException extends Exception {}
}