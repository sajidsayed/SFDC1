/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER   	 WR/DEFECT    DESCRIPTION                               
 |  ====       =========  	 =========    =========== 
 |    
 |  10-Apr-13  Ketan Benegal  New Dev    Search Functionality Setup.
 |  24-May-13  Ketan Benegal  New Req	 Search Functionality Setup should run off the profile.
 +===========================================================================*/

public with sharing class SetupSearchComponentCls {

	// Stores the selected Profile id.
	public string selectedProfileId{get;set;}
	public list<SelectOption> selOptProfiles{get;set;}
	public string bypassSecurity{get;set;}
	//Stores the API name of the object selected.
	public String selectedObject{
		get{
			return selectedObject;
		}
		set{
			System.debug('Setter selectedObject: '+ selectedObject + '\t value' + value);
			if((selectedObject!='None' || selectedObject != null) && selectedObject != value){
				unselectedDisplayFieldNames.clear();
				selectedDisplayFieldNames.clear();
				setOfUnSelectedSearchFilterFieldNames.clear();
				setOfSelectedSearchFilterFieldNames.clear();
				mapOfPrevExistingSelectSearchFilterFieldNames.clear();	
			}
			selectedObject = value;
			if(selectedObject == 'None')
				renderChildren = false;

			// System.debug('-----------Selected Object:' + selectedObject);
		}
	}
	private map<String, STRING> mapSelObject{get;set;}
	public list<Selectoption> objectNames{get;set;}
	private list<String> lstFilter{get;set;}
	public Map<String, Schema.SObjectType> objectMap;
	public list<Selectoption> selOptChildren{get;set;}
	public list<Selectoption> selLookupFlds{get;set;}
	/*	public list<Selectoption> displayResultFields{get;set;}
	public list<Selectoption> displayOnlySelectedResultFields{get;set;}
	public list<String> lstDisplayFields{get;set;}
	 */	public map<string, Schema.SObjectField> mapColumnFldName{get;set;}
	 //public list<string> selectedChildren;
	 public string selectedLookupFlds;
	 public map<string, Schema.Sobjecttype> mapFldNameReference{get;set;}
	 public list<Selected_SObject__c> insObj{get;set;}
	 public boolean renderChildren{get;set;}
	 public map<Id,Profile> mapOfProfiles{get;set;}
	 //Display Fields variables.
	 private Set<String> unSelectedDisplayFieldNames = new Set<String>();
	 private Set<String> selectedDisplayFieldNames = new Set<String>();

	 //Search Filter Fields
	 private Set<String> setOfUnSelectedSearchFilterFieldNames = new Set<String>();
	 private Set<String> setOfSelectedSearchFilterFieldNames = new Set<String>();
	 private map<String, String> mapOfPrevExistingSelectSearchFilterFieldNames = new map<String, String>();
	 private map<String, Set<string>> mapOfSetOfSelectedSearchFilterFields = new map<String, Set<String>>();

	 private Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField> ();


	 public SetupSearchComponentCls(){
		 declareAllMembers();
	 }
	 public void declareAllMembers(){
		 renderChildren = false;
		 if(this.lstFilter == null){
			 this.lstFilter = new list<string>();
			 lstFilter.add('User');
			 lstFilter.add('Tag');
			 lstFilter.add('History');
			 lstFilter.add('Feed');
			 lstFilter.add('Share');
			 lstFilter.add('Template');
			 lstFilter.add('Business Process');
			 lstFilter.add('Process');
			 lstFilter.add('Feed');
			 lstFilter.add('Attachment');
			 lstFilter.add('Received Connection ID');
			 lstFilter.add('Created By ID');
			 lstFilter.add('Sent Connection ID');
			 lstFilter.add('Last Modified By ID');
		 }
		 mapFldNameReference = new map<string, Schema.Sobjecttype>();
		 mapColumnFldName = new map<string, Schema.SObjectField>();
		 insObj = new list<Selected_SObject__c> ();
		 objectMap = Schema.getGlobalDescribe();
		 selOptChildren = new list<Selectoption>();
		 selLookupFlds = new list<Selectoption>();
		 /*		displayResultFields = new list<Selectoption>();
		displayOnlySelectedResultFields = new list<Selectoption>();
		lstDisplayFields = new list<string>();
		  */		
		 selOptProfiles = new list<SelectOption>();
		 mapOfProfiles = new map<Id,Profile> ();
		 createListOfProfiles();
		 setupObjectNames();

	 }

	 /**
	  *
	  *
	  *
	  **/
	 private void setupObjectNames(){
		 map<String, String> mapValuesLabels = new Map<String, String>();
		 list<Schema.Sobjecttype> gd = Schema.getGlobalDescribe().values();
		 this.objectNames = new list<Selectoption>();
		 //this.objectNames.add(new SelectOption('None', 'None'));
		 Boolean isSystemObject =  false;
		 for(Schema.Sobjecttype s : gd){
			 mapValuesLabels.put(s.getDescribe().getName(), s.getDescribe().getLabel());
		 }
		 this.objectNames = setupSelectOptions(mapValuesLabels);
		 this.objectNames.sort();
		 this.objectNames.add(0,new SelectOption('None', 'None'));
	 }

	 public void createListOfProfiles(){
		 if(this.mapOfProfiles.values().size() == 0)
			 this.mapOfProfiles = new map<Id, Profile> ([Select p.Id , p.Name, p.UserType, p.PermissionsApiUserOnly From Profile p where p.PermissionsApiUserOnly != true
			 and p.UserType not in ('Partner', 'High Volume Portal', 'Customer Portal User', 'PowerPartner', 'Guest', 'CspLitePortal') order by p.name desc]);

		 System.debug('createListOfProfiles mapOfProfiles: '+ mapOfProfiles);
		 //add the profile ids to the unselected sets.
		 list<profile> tmpLstProf = mapOfProfiles.values();
		 tmpLstProf.sort();
		 for(Profile p: tmpLstProf){
			 //create the selectlist dropdown for profiles.
			 selOptProfiles.add(new selectoption(p.id, p.name));
		 }
	 }

	 public void retrieveFields(){

		 map<string, string> mapFldValLabel = new map<String, String>();
		 if(selectedObject != null){
			 Schema.Sobjecttype obj = objectMap.get(selectedObject);
			 fieldMap = obj.getDescribe().fields.getMap();
			 /*			displayResultFields.clear();
			displayOnlySelectedResultFields.clear();
			  */
			 if(fieldMap.size() > 0){
				 System.debug('fieldMap.values(): '+fieldMap.values());
				 System.debug('fieldMap.values().size(): '+fieldMap.values().size());
				 for(Schema.SObjectField fld : fieldMap.values()){
					 if(fld.getDescribe().getType() == schema.Displaytype.Reference){
						 mapFldValLabel.put(fld.getDescribe().getName(), fld.getDescribe().getLabel());
						 mapFldNameReference.put(fld.getDescribe().getName(), fld.getDescribe().getReferenceTo().get(0));
						 // System.debug('^^^^^^^Field :' + fld.getDescribe().getName() + '\t Relationship: '+ fld.getDescribe().getRelationshipName()+ '\n ReferenceTo: '+ fld.getDescribe().getReferenceTo());
					 }
					 String fldName = fld.getDescribe().getName();
					 fldName =  fldName.toUpperCase();
					 unSelectedDisplayFieldNames.add(fldName);
					 //displayResultFields.add(new SelectOption(fldName, fld.getDescribe().getLabel()));
					 mapColumnFldName.put(fldName, fld);	
					 System.debug('Field: '+ fld);
				 }
			 }

			 this.selLookupFlds = setupSelectOptions(mapFldValLabel) ;
			 this.selLookupFlds.sort();
			 this.selLookupFlds.add(0,new SelectOption(selectedObject,objectMap.get(selectedObject).getDescribe().getLabel()));
			 //displayResultFields.sort();
			 System.debug('@@@@@@@@@@@@SelLookupFlds: ' + this.selLookupFlds);
			 //System.debug('mapColumnFldName.get(OTHERSTATE): ' + mapColumnFldName.get('OTHERSTATE'));
		 }

	 }

	 /**
	  *
	  *
	  */
	 public void retrieveChildren(){
		 if(selectedObject == 'None')
			 return;
		 renderChildren = true;
		 map<String, String> mapValuesLabels = new Map<String, String>();
		 List<Schema.Childrelationship> lstSelChildren = retrieveChildren2();
		 for(Schema.Childrelationship child : lstSelChildren){
			 // System.debug('Child Details:' + child.getChildSObject().getDescribe() + '\n Relationship:' + child.getRelationshipName()+ '\t field:' + child.getField());
			 mapValuesLabels.put(child.getChildSObject().getDescribe().getName(), child.getChildSObject().getDescribe().getLabel());
		 }
		 this.selOptChildren = setupSelectOptions(mapValuesLabels);
		 // System.debug('this.selOptChildren.size(): '+ this.selOptChildren.size() + '\t renderChildren:' + renderChildren);
		 retrieveFields();
	 }

	 public list<schema.Childrelationship> retrieveChildren2(){
		 if(selectedObject != null){
			 Schema.Sobjecttype obj = objectMap.get(selectedObject);
			 if (obj != null){
				 Schema.Describesobjectresult r = obj.getDescribe();
				 return r.getChildRelationships();
			 }
		 }
		 return null;
	 }


	 public list<Selectoption> setupSelectOptions(map<String, String> mapValLabels){
		 Boolean isSystemObject =  false;
		 list<SelectOption> lstOpt = new list<SelectOption>();
		 list<String> lstLabels = mapValLabels.values();
		 Set<String> setVal = mapValLabels.keySet();
		 integer i = 0 ;
		 for(String objName : setVal){
			 String tempVal = mapValLabels.get(objName);
			 // System.debug('11111 objName:' + objName + '\t tempVal:' + tempVal);
			 for(String str : lstFilter){
				 //// System.debug('########## Object: ' + s.getDescribe().getLabel() + '/t str:' + str);
				 if(tempVal.contains(str)){
					 isSystemObject = true;
					 break;
				 }
			 }
			 if(!isSystemObject){
				 // System.debug('22222 objName:' + objName + '\t tempVal:' + tempVal);
				 lstOpt.add(new SelectOption(objName,tempVal));
			 }else{
				 isSystemObject = false;
			 }
		 }

		 return lstOpt;

	 }

	 //method creates the relationship list when an object is selected for search. 
	 public void createRelationship(){
	 }
	 /*public list<string> getSelectedChildren() {
		return selectedChildren;
	}

	public void setSelectedChildren(list<string> selectedChildren) {
		this.selectedChildren = selectedChildren;
	}*/

	 public string getSelectedLookupFlds() {
		 return selectedLookupFlds;
	 }

	 public void setSelectedLookupFlds(string selectedLookupFlds) {
		 System.debug('setSelectedLookupFlds: ' + selectedLookupFlds);
		 this.selectedLookupFlds = selectedLookupFlds;
		 getLookupRecordFields();
	 }

	 //find the record referenced in the selected lookup field, find all the fields for that record.
	 public void getLookupRecordFields(){
		 Map<String, Schema.SObjectField> tmpFieldMap = new Map<String, Schema.SObjectField>(); 
		 String relationshipName;
		 setOfUnSelectedSearchFilterFieldNames.clear();
		 if(selectedObject != null){
			 Schema.Sobjecttype obj = objectMap.get(selectedObject);
			 fieldMap = obj.getDescribe().fields.getMap();
			 if(selectedLookupFlds != selectedObject){
				 //get the field describe for lookup field.
				 System.debug('selectedLookupFlds: '+ this.selectedLookupFlds);
				 Schema.SObjectField fld = fieldMap.get(selectedLookupFlds);
				 //get the object referenced .
				 System.debug('fld: '+ fld);
				 Schema.sObjectType lookUpObj = fld.getDescribe().getReferenceTo().get(0);
				 System.debug('lookUpObj: '+ lookUpObj);
				 //get the relationship name.
				 relationshipName = fld.getDescribe().getRelationshipName();
				 System.debug('relationshipName: '+ relationshipName);
				 tmpFieldMap = lookUpObj.getDescribe().fields.getMap();
			 }else{
				 tmpFieldMap =  fieldMap;
			 }


			 for(Schema.SObjectField fld1 : tmpFieldMap.values()){
				 String fldName = fld1.getDescribe().getName();
				 if(selectedLookupFlds != selectedObject){
					 setOfUnSelectedSearchFilterFieldNames.add(relationshipName+'.'+ fldName);
				 }else{
					 setOfUnSelectedSearchFilterFieldNames.add(fldName);
				 }
			 }

		 }

	 }

	 public void Save(){
		 Savepoint sp;
		 try{
			 List<Schema.Childrelationship> lstSelChildren = retrieveChildren2();
			 integer i = 0;
			 //Save the selected SObject.
			 List<Search_Relationship__c> lstObj = new list<Search_Relationship__c>();
			 List<Search_Relationship__c> lstExistingObj = new list<Search_Relationship__c>();
			 map<String, Search_Relationship__c> mapExistingObj = new map<String, Search_Relationship__c> ();
			 List<Selected_SObject_Profile_Setting__c> lstOfExistingSelSObj_Profiles =  new List<Selected_SObject_Profile_Setting__c>();
			 List<Search_Field__c> lstExistingDisplayColumn = new list<Search_Field__c>();
			 List<Search_Filter_Field__c> lstExistingSearchFilterFields = new List<Search_Filter_Field__c>();
			 /*			map<String, Search_Field__c> mapExistingDispCol = new map<String, Search_Field__c> ();
			List<Search_Field__c> lstDisplayColumnsObj = new list<Search_Field__c>();
			  */
			 /*			List<Selected_SObject_Profile_Setting__c> lstSelSObj_Profiles = new list<Selected_SObject_Profile_Setting__c>();
			map<String, Selected_SObject_Profile_Setting__c> mapExistingSelObj_Profile = new map<String, Selected_SObject_Profile_Setting__c> ();
			List<Selected_SObject_Profile_Setting__c> lstSelSObj_ProfilesToUpdate = new list<Selected_SObject_Profile_Setting__c>();
			  */			
			 sp = Database.setSavepoint();
			 //check if the selected object record exists.
			 if(selectedObject != null){
				 String strUniqueName = selectedObject + '_' + mapOfProfiles.get(selectedProfileId).name;
				 insObj = [Select s.Unique_Name__c, s.Profile_Id__c, s.Name, s.Id, s.Bypass_Sharing__c From Selected_SObject__c s WHERE s.Unique_Name__c = :strUniqueName];
				 if(insObj.size() == 0){
					 //if not, then insert the selected object.
					 insObj.add(new Selected_SObject__c(name=selectedObject, Unique_Name__c=strUniqueName, Bypass_Sharing__c = bypassSecurity, Profile_Id__c=selectedProfileId));
					 Database.insert(insObj, false) ;
				 }else{
					 if(insObj[0].Bypass_Sharing__c != bypassSecurity){
						 insObj[0].Bypass_Sharing__c = bypassSecurity;
						 Database.update(insObj, false);
					 }
					 //get all the records for the selected profile ids and selected object combination.
					 //lstOfExistingSelSObj_Profiles = [Select s.Bypass_Sharing__c, s.Selected_SObject__c, s.Profile_Id__c, s.Name, s.Id From Selected_SObject_Profile_Setting__c s where s.Selected_SObject__c = :insObj[0].id and s.Profile_Id__c in :lstOfSelectedProfileIds];
				 }

				 lstExistingObj = [SELECT Object_1__c, Object_1_Value__c, Object_2__c, Object_2_Value__c, Relationship_Type__c, Relationship_Unique_Name__c, Name, Selected_SObject__c, Id FROM Search_Relationship__c where Selected_SObject__c = :insObj[0].id ];
				 lstExistingDisplayColumn = [SELECT Id, Display_Field_Label__c, Display_Field_Name__c, Name, Selected_SObject__c, Column_Unique_Name__c FROM Search_Field__c  where Selected_SObject__c = :insObj[0].id ];
				 lstExistingSearchFilterFields = [Select s.Selected_SObject__c, s.Name, s.Id, s.Field_Name__c, s.Field_Label__c From Search_Filter_Field__c s where s.Selected_SObject__c  = :insObj[0].id];
				 if(lstExistingObj.size() >0){
					 for(Search_Relationship__c s : lstExistingObj){
						 mapExistingObj.put(s.Relationship_Unique_Name__c, s);
					 }
				 }

				 /*				if(lstExistingDisplayColumn.size() >0){
					for(Search_Field__c s : lstExistingDisplayColumn){
						mapExistingDispCol.put(s.Column_Unique_Name__c.trim().toUpperCase(), s);
					}
				}
				  */				
				 insertOrUpdateDisplayFields(lstExistingDisplayColumn);
				 insertOrUpdateSearchFilterFields(insObj[0], lstExistingSearchFilterFields);
				 System.debug('insertOrUpdateDisplayFields is complete successfully');
				 // insertOrUpdateProfileInformation(lstOfExistingSelSObj_Profiles);

				 // System.debug('Inserted Select Object Id:' + insObj.id);
				 //Add children relationship.
				 /*for(Schema.Childrelationship c : lstSelChildren){
					//i =0;
					if(selectedChildren != null && selectedChildren.size() > 0){
						for(String s: selectedChildren){
							if(c.getChildSObject().getDescribe().getName().equals(s)){
								if(mapExistingObj.values().size() > 0 ){
									if(!mapExistingObj.keySet().contains(selectedObject + ' '+c.getChildSObject().getDescribe().getName())){
										Search_Relationship__c srchRel = new Search_Relationship__c(name=c.getChildSObject().getDescribe().getName(), Selected_SObject__c = insobj[0].id, Relationship_Type__c='Master', Object_1__c=objectMap.get(selectedObject).getDescribe().getLabel(), Object_2__c=c.getChildSObject().getDescribe().getLabel(), Object_1_Value__c=selectedObject, Object_2_Value__c=c.getChildSObject().getDescribe().getName(), Relationship_Unique_Name__c=selectedObject + ' '+c.getChildSObject().getDescribe().getName());
										lstObj.add(srchRel);
									}
								}else{
									Search_Relationship__c srchRel = new Search_Relationship__c(name=c.getChildSObject().getDescribe().getName(), Selected_SObject__c = insobj[0].id, Relationship_Type__c='Master', Object_1__c=objectMap.get(selectedObject).getDescribe().getLabel(), Object_2__c=c.getChildSObject().getDescribe().getLabel(), Object_1_Value__c=selectedObject, Object_2_Value__c=c.getChildSObject().getDescribe().getName(), Relationship_Unique_Name__c=selectedObject + ' '+c.getChildSObject().getDescribe().getName());
									lstObj.add(srchRel);
								}
								// System.debug('Selected Child: '+ c.getChildSObject().getDescribe().getName() + '\t Relationship Field:' + c.getField());
							}
							//i++;
						}

					}
				}*/
				 //Add lookup/master detail relationship record details.
				 /*				 Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField> ();
				 Schema.Sobjecttype obj = objectMap.get(selectedObject);
				 fieldMap = obj.getDescribe().fields.getMap();

				 if(selectedLookupFlds.length() > 0){
					 String str = selectedLookupFlds;
					 System.debug('str: ' + str);
					 //for(String str : selectedLookupFlds){
					 Schema.SObjectField fld = fieldMap.get(str);
					 System.debug('fld: ' + fld);
					 if(mapExistingObj.values().size() > 0 ){
						 if(!mapExistingObj.keySet().contains(selectedObject + ' '+ mapFldNameReference.get(str).getDescribe().getName())){
							 Search_Relationship__c srchRel = new Search_Relationship__c(name=mapFldNameReference.get(str).getDescribe().getName(), Selected_SObject__c = insobj[0].id, Relationship_Type__c='Child', Object_1__c=objectMap.get(selectedObject).getDescribe().getLabel(), Object_2__c=mapFldNameReference.get(str).getDescribe().getLabel(), Object_1_Value__c=selectedObject, Object_2_Value__c=mapFldNameReference.get(str).getDescribe().getName(), Look_up_field_name__c=str, Look_up_field_label__c=fld.getDescribe().getLabel(), Look_up_relationship_name__c=fld.getDescribe().getRelationshipName()  , Relationship_Unique_Name__c=selectedObject + ' '+ str);//mapFldNameReference.get(str).getDescribe().getName() );
							 System.debug('srchRel: '+ srchRel);
							 lstObj.add(srchRel);
						 }
					 }else{
						 System.debug('mapExistingObj is empty!!');
						 Search_Relationship__c srchRel = new Search_Relationship__c(name=mapFldNameReference.get(str).getDescribe().getName(), Selected_SObject__c = insobj[0].id, Relationship_Type__c='Child', Object_1__c=objectMap.get(selectedObject).getDescribe().getLabel(), Object_2__c=mapFldNameReference.get(str).getDescribe().getLabel(), Object_1_Value__c=selectedObject, Object_2_Value__c=mapFldNameReference.get(str).getDescribe().getName(), Look_up_field_name__c=str, Look_up_field_label__c=fld.getDescribe().getLabel(), Look_up_relationship_name__c=fld.getDescribe().getRelationshipName()  , Relationship_Unique_Name__c=selectedObject + ' '+ str);//mapFldNameReference.get(str).getDescribe().getName() );
						 System.debug('srchRel: '+ srchRel);
						 lstObj.add(srchRel);
					 }
					 // System.debug('Selected Child: '+ c.getChildSObject().getDescribe().getName() + '\t Relationship Field:' + c.getField());
					 //}
				 }
				 if(lstObj.size() > 0 ){
					 System.debug('Inserting Child Objects:' + lstObj);
					 Database.insert(lstObj, false) ;
				 }
				  */


				 /*				//Add search results display columns details.
				list<String> lstDisplayFields  = selectedDisplayFields;
				if(lstDisplayFields.size() > 0){
					for(String str2 : lstDisplayFields){
						str2 = str2.trim().toUpperCase();
						if(mapExistingDispCol.values().size() > 0 ){
							if(!mapExistingDispCol.keySet().contains(selectedObject+ ' '+ str2)){
								Search_Field__c  DispColObj = new Search_Field__c(name=str2, Selected_SObject__c = insobj[0].id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=str2, Column_Unique_Name__c=selectedObject+ ' '+ str2 );
								lstDisplayColumnsObj.add(DispColObj);
							}
						}else{
							System.debug('mapColumnFldName.size(): '+mapColumnFldName.size() );
							System.debug('str2:'+ str2+ '\t mapColumnFldName.get(str2): ' + mapColumnFldName.get(str2));
							Search_Field__c  DispColObj = new Search_Field__c(name=str2, Selected_SObject__c = insobj[0].id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=str2, Column_Unique_Name__c=selectedObject+ ' '+ str2 );
							//						Search_Field__c  DispColObj = new Search_Field__c(name=mapColumnFldName.get(str2).getDescribe().getName(), Selected_SObject__c = insobj.id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=mapColumnFldName.get(str2).getDescribe().getName() , Column_Unique_Name__c=selectedObject+ ' '+ mapColumnFldName.get(str2).getDescribe().getName() );
							lstDisplayColumnsObj.add(DispColObj);
						}
					}
				}

				if(lstDisplayColumnsObj.size() > 0 ){
					// System.debug('Inserting Display Column Objects:' + lstObj);
					Database.insert(lstDisplayColumnsObj, false) ;
				}
				System.debug('Save Method: lstDisplayFields:' + lstDisplayFields);*/
			 }
			 //return null;
		 }catch(Exception e)
		 {
			 Database.rollback(sp);
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+e.getMessage()));
			 //return null;
		 }
	 }

	 private void insertOrUpdateSearchFilterFields(Selected_SObject__c insObj, List<Search_Filter_Field__c> lstExistingSearchFilterFields){
		 System.debug('insertOrUpdateSearchFilterFields start');
		 List<Search_Filter_Field__c> lstInsertSearchFilterFields = new List<Search_Filter_Field__c> ();
		 String strProfileId = insObj.Profile_Id__c ;
		 String strSelectedObjId = insObj.id;
		 Schema.SObjectType sLookUpObj = objectMap.get(selectedLookupFlds);
		 Map<String, Schema.SObjectField> lookUpObjfieldMap = new Map<String, Schema.SObjectField>();

		 if(sLookUpObj != null)
			 lookUpObjfieldMap = sLookUpObj.getDescribe().fields.getMap();
		 System.debug('sLookUpObj: ' + sLookUpObj + '\tselectedSearchFilterFields: '+ selectedSearchFilterFields);
		 if(selectedSearchFilterFields.size() == 0)
			 selectedSearchFilterFields.addAll(setOfSelectedSearchFilterFieldNames);

		 list<String> lstSearchFilterFields  = selectedSearchFilterFields;
		 if(lstExistingSearchFilterFields.size() > 0){
			 for(Search_Filter_Field__c sObj : lstExistingSearchFilterFields){
				 String tmpSelObjId = sObj.Selected_SObject__c;
				 if( tmpSelObjId== strSelectedObjId){
					 for(String srchFilterField : lstSearchFilterFields)
						 if(!sObj.Field_Name__c.equals(srchFilterField)){
							 lstInsertSearchFilterFields.add(new Search_Filter_Field__c(Selected_SObject__c=strSelectedObjId, Field_Name__c=srchFilterField, Field_Label__c = lookUpObjfieldMap.get(srchFilterField).getDescribe().getLabel(), name= selectedObject + '_'+ strProfileId+'_'+ srchFilterField) );
						 }
				 }
			 }
		 }else{
			 System.debug('lstSearchFilterFields: '+ lstSearchFilterFields);
			 for(String srchFilterField : lstSearchFilterFields){
				 string fieldLabel =mapOfPrevExistingSelectSearchFilterFieldNames.get(srchFilterField);
				 System.debug('11111111 srchFilterField: ' + srchFilterField + '\tfieldLabel:' + fieldLabel);
				 System.debug('srchFilterField: ' + srchFilterField + '\tfieldLabel:' + fieldLabel);
				 lstInsertSearchFilterFields.add(new Search_Filter_Field__c(Selected_SObject__c=strSelectedObjId, Field_Name__c=srchFilterField, Field_Label__c = fieldLabel, name= selectedObject + '_'+ strProfileId+'_'+ srchFilterField) );
			 }
		 }

		 if(lstInsertSearchFilterFields.size() >0)
			 insert lstInsertSearchFilterFields;
		 System.debug('insertOrUpdateSearchFilterFields end');
	 }

	 private void insertOrUpdateDisplayFields(List<Search_Field__c> lstExistingDisplayColumn){
		 List<Search_Field__c> lstDisplayColumnsObj = new list<Search_Field__c>();
		 map<String, Search_Field__c> mapExistingDispCol = new map<String, Search_Field__c> ();

		 if(lstExistingDisplayColumn.size() >0){
			 for(Search_Field__c s : lstExistingDisplayColumn){
				 mapExistingDispCol.put(s.Column_Unique_Name__c.trim().toUpperCase(), s);
			 }
		 }

		 //Add search results display columns details.
		 System.debug('selectedDisplayFields: ' + selectedDisplayFields + '\tselectedDisplayFieldNames: ' + selectedDisplayFieldNames);
		 //if selectedDisplayFields is null, copy from selectedDisplayFieldNames.
		 if(selectedDisplayFields.size() == 0)
			 selectedDisplayFields.addAll(selectedDisplayFieldNames);
		 list<String> lstDisplayFields  = selectedDisplayFields;
		 if(lstDisplayFields.size() > 0){
			 for(String str2 : lstDisplayFields){
				 str2 = str2.trim().toUpperCase();
				 if(mapExistingDispCol.values().size() > 0 ){
					 if(!mapExistingDispCol.keySet().contains(selectedObject+ ' '+ str2)){
						 Search_Field__c  DispColObj = new Search_Field__c(name=str2, Selected_SObject__c = insobj[0].id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=str2, Column_Unique_Name__c=selectedObject+ ' '+ str2 );
						 lstDisplayColumnsObj.add(DispColObj);
					 }
				 }else{
					 System.debug('mapColumnFldName.size(): '+mapColumnFldName.size() );
					 System.debug('str2:'+ str2+ '\t mapColumnFldName.get(str2): ' + mapColumnFldName.get(str2));
					 Search_Field__c  DispColObj = new Search_Field__c(name=str2, Selected_SObject__c = insobj[0].id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=str2, Column_Unique_Name__c=selectedObject+ ' '+ str2 );
					 //						Search_Field__c  DispColObj = new Search_Field__c(name=mapColumnFldName.get(str2).getDescribe().getName(), Selected_SObject__c = insobj.id, Display_Field_Label__c=mapColumnFldName.get(str2).getDescribe().getLabel(), Display_Field_Name__c=mapColumnFldName.get(str2).getDescribe().getName() , Column_Unique_Name__c=selectedObject+ ' '+ mapColumnFldName.get(str2).getDescribe().getName() );
					 lstDisplayColumnsObj.add(DispColObj);
				 }
			 }
		 }

		 if(lstDisplayColumnsObj.size() > 0 ){
			 // System.debug('Inserting Display Column Objects:' + lstObj);
			 Database.insert(lstDisplayColumnsObj, false) ;
		 }
		 System.debug('Save Method: lstDisplayFields:' + lstDisplayFields);		
	 }

	 /*	 private void insertOrUpdateProfileInformation(List<Selected_SObject_Profile_Setting__c> lstOfExistingSelSObj_Profiles){
		 List<Selected_SObject_Profile_Setting__c> lstSelSObj_Profiles = new list<Selected_SObject_Profile_Setting__c>();
		 map<String, Selected_SObject_Profile_Setting__c> mapExistingSelObj_Profile = new map<String, Selected_SObject_Profile_Setting__c> ();
		 List<Selected_SObject_Profile_Setting__c> lstSelSObj_ProfilesToUpdate = new list<Selected_SObject_Profile_Setting__c>();

		 //create a map of existing profile ids and selected object combination.
		 if(lstOfExistingSelSObj_Profiles.size() >0){
			 for(Selected_SObject_Profile_Setting__c s : lstOfExistingSelSObj_Profiles){
				 mapExistingSelObj_Profile.put(s.Selected_SObject__c + '_'+ s.Profile_Id__c , s);
			 }
		 }

		 //Insert Profile details
		 transient list<String> lstOfBypassSecProfileIds = new list<string>();
		 transient list<String> lstOfEnforceSecProfileIds = new list<string>();

		 if(selectedBypassSecProfNames.size() > 0 ){
			 lstOfBypassSecProfileIds.addAll(selectedBypassSecProfNames);
		 }

		 if(selectedEnforceSecProfNames.size() > 0 ){
			 lstOfEnforceSecProfileIds.addAll(selectedEnforceSecProfNames);
		 }

		 //Bypass Security profiles update/insert.
		 for(String anId : lstOfBypassSecProfileIds){
			 //check if it exists
			 if(mapExistingSelObj_Profile.get(selectedObject +'_'+ anId) != null){
				 Selected_SObject_Profile_Setting__c tmp = mapExistingSelObj_Profile.get(selectedObject +'_'+ anId) ;
				 //if bypass security is no, set it to yes and add it to update list.
				 if(tmp.Bypass_Sharing__c == 'No'){
					 tmp.Bypass_Sharing__c = 'Yes';
					 lstSelSObj_ProfilesToUpdate.add(tmp);
				 }
			 }else{//if rec. doesn't exist, add to insert list.
				 Selected_SObject_Profile_Setting__c tmpSelObj_Profile = new Selected_SObject_Profile_Setting__c( Selected_SObject__c=insobj[0].id, Profile_Id__c=anId, name=selectedObject+'_'+ mapOfProfiles.get(anId).Name, Bypass_Sharing__c='Yes');
				 System.debug('ByPass Profiles: ' + tmpSelObj_Profile);
				 lstSelSObj_Profiles.add(tmpSelObj_Profile);
			 }
		 }

		 //Enforce Security profiles update/insert.
		 for(String anId : lstOfEnforceSecProfileIds){
			 //check if it exists
			 if(mapExistingSelObj_Profile.get(selectedObject +'_'+ anId) != null){
				 Selected_SObject_Profile_Setting__c tmp = mapExistingSelObj_Profile.get(selectedObject +'_'+ anId) ;
				 //if bypass security is yes, set it to no and add it to update list.
				 if(tmp.Bypass_Sharing__c == 'Yes'){
					 tmp.Bypass_Sharing__c = 'No';
					 lstSelSObj_ProfilesToUpdate.add(tmp);
				 }
			 }else{//if rec. doesn't exist, add to insert list.
				 Selected_SObject_Profile_Setting__c tmpSelObj_Profile = new Selected_SObject_Profile_Setting__c( Selected_SObject__c=insobj[0].id, Profile_Id__c=anId, name=selectedObject+'_'+ mapOfProfiles.get(anId).Name, Bypass_Sharing__c='No');
				 lstSelSObj_Profiles.add(tmpSelObj_Profile);
			 }
		 }


		 //insert profile security information.
		 if(lstSelSObj_Profiles.size() > 0 ){
			 System.debug('Inserting Profiles:' + lstSelSObj_Profiles);
			 //Database.insert(lstSelSObj_Profiles, false) ;
			 insert lstSelSObj_Profiles;
			 System.debug('lstSelSObj_Profiles: '+ lstSelSObj_Profiles);
		 }
		 //update profile security information.
		 System.debug('Calling update.');
		 if(lstSelSObj_ProfilesToUpdate.size() > 0 ){
			 System.debug('Updating Profiles:' + lstSelSObj_ProfilesToUpdate);
			 //Database.insert(lstSelSObj_Profiles, false) ;
			 update lstSelSObj_ProfilesToUpdate;
			 System.debug('lstSelSObj_ProfilesToUpdate[0]: '+ lstSelSObj_ProfilesToUpdate[0]);
		 }

	 }*/


	 public list<SelectOption> getBypassSecurityOptions(){
		 List<SelectOption> options = new List<SelectOption>();
		 options.add(new SelectOption('Yes', 'Yes'));
		 options.add(new SelectOption('No', 'No'));
		 return options;
	 }


	 // Create the select options for the two lists of Display fields on the page
	 public List<SelectOption> getSelectedDisplayFieldsOptions() {
		 System.debug('unselectedDisplayFieldNames: '+ unselectedDisplayFieldNames);
		 System.debug('selectedDisplayFieldNames: '+ selectedDisplayFieldNames);
		 return selectOptionsFromSet(selectedDisplayFieldNames, 'DisplayFields');
	 }
	 public List<SelectOption> getUnSelectedDisplayFieldsOptions() {
		 System.debug('unselectedDisplayFieldNames: '+ unselectedDisplayFieldNames);
		 System.debug('selectedDisplayFieldNames: '+ selectedDisplayFieldNames);
		 return selectOptionsFromSet(unselectedDisplayFieldNames, 'DisplayFields');
	 }

	 // Create the select options for the two lists of Search Filter fields on the page
	 public List<SelectOption> getSelectedSearchFilterFieldsOptions() {
		 System.debug('From Selected list setOfUnSelectedSearchFilterFieldNames: '+ setOfUnSelectedSearchFilterFieldNames);
		 System.debug('From Selected list setOfSelectedSearchFilterFieldNames: '+ setOfSelectedSearchFilterFieldNames);
		 list<selectOption> lst = selectOptionsFromSet2(setOfSelectedSearchFilterFieldNames, 'SelectedSearchFilterFields');
		 System.debug('After selectOptionsFromSet2 lst: ' + lst);
		 return lst ;
	 }
	 public List<SelectOption> getUnSelectedSearchFilterFieldsOptions() {
		 System.debug('From unSelected list setOfUnSelectedSearchFilterFieldNames: '+ setOfUnSelectedSearchFilterFieldNames);
		 System.debug('From unSelected list setOfSelectedSearchFilterFieldNames: '+ setOfSelectedSearchFilterFieldNames);
		 list<selectOption> lst = selectOptionsFromSet(setOfUnSelectedSearchFilterFieldNames, 'unSelectedSearchFilterFields');
		 System.debug('After selectOptionsFromSet lst: ' + lst);
		 return lst ;
	 }

	 //Create multiselect lists for unselected and selected items.

	 private List<SelectOption> selectOptionsFromSet(Set<String> opts, String setName) {
		 List<SelectOption> options = new List<SelectOption>();
		 if(setName.trim().equals('DisplayFields')){
			 if(selectedObject != null && selectedObject != 'None'){
				 Schema.Sobjecttype obj = objectMap.get(selectedObject);
				 fieldMap = obj.getDescribe().fields.getMap();
			 }
			 if((opts == null || opts.size() ==0) || selectedObject ==null){
				 options.add(new SelectOption('None', 'None'));

			 }else{
				 System.debug('111 + setName: '+ setName);
				 List<String> optionsList = new List<String>(opts);
				 System.debug('222');
				 optionsList.sort();
				 System.debug('333 + optionsList: ' + optionsList.size());
				 for (String s : optionsList) {
					 System.debug('s: ' + s + '\t fieldMap.get(s): ' + fieldMap.get(s) );
					 options.add(new SelectOption(s, fieldMap.get(s).getDescribe().getLabel() ));
				 }
			 }

		 }else{
			 if(setName.trim().equals('Profiles')){
				 List<String> optionsList = new List<String>(opts);
				 //optionsList.sort();
				 System.debug('333 + optionsList: ' + optionsList.size());
				 for (Id id : optionsList) {
					 System.debug('id: ' + id + '\t mapOfProfiles: ' + mapOfProfiles.get(id) );
					 options.add(new SelectOption(id, mapOfProfiles.get(id).name));
				 }
				 options.sort();
			 }else{
				 if(setName.trim().contains('SearchFilterFields')){
					 if((opts == null || opts.size() ==0) || selectedObject ==null){
						 options.add(new SelectOption('None', 'None'));

					 }else{
						 List<String> optionsList = new List<String>(opts);
						 Map<String, Schema.SObjectField> tmpFieldMap = new Map<String, Schema.SObjectField>(); 
						 String relationshipName, strObjectName;
						 System.debug('222 SearchFilterFields');
						 //optionsList.sort();
						 System.debug('333 + optionsList: ' + optionsList);
						 ///////////////////////////
						 if(selectedLookupFlds != selectedObject){
							 //get the field describe for lookup field.
							 System.debug('selectedLookupFlds: '+ this.selectedLookupFlds);
							 Schema.SObjectField fld = fieldMap.get(selectedLookupFlds);
							 //get the object referenced .
							 System.debug('fld: '+ fld);
							 Schema.sObjectType lookUpObj = fld.getDescribe().getReferenceTo().get(0);
							 strObjectName = lookUpObj.getDescribe().getLabel();
							 System.debug('lookUpObj: '+ lookUpObj);
							 //get the relationship name.
							 relationshipName = fld.getDescribe().getRelationshipName();
							 System.debug('relationshipName: '+ relationshipName);
							 tmpFieldMap = lookUpObj.getDescribe().fields.getMap();
							 System.debug('tmpFieldMap: '+ tmpFieldMap);
						 }else{
							 if(selectedObject != null && selectedObject != 'None')
								 strObjectName = objectMap.get(selectedObject).getDescribe().getLabel();
							 tmpFieldMap =  fieldMap;
						 }

						 if(setName.trim().equals('unSelectedSearchFilterFields')){
							 for(Schema.SObjectField fld1 : tmpFieldMap.values()){
								 String fldName = fld1.getDescribe().getName();
								 if(selectedLookupFlds != selectedObject){
									 setOfUnSelectedSearchFilterFieldNames.add(relationshipName+'.'+ fldName);
								 }else{
									 setOfUnSelectedSearchFilterFieldNames.add(fldName);
								 }
							 }
							 System.debug('setOfUnSelectedSearchFilterFieldNames: '+ setOfUnSelectedSearchFilterFieldNames);
						 }

						 /////////////////////////////
						 SelectOption selOpt ;
						 for (String s2 : optionsList) {
							 System.debug('s2: ' + s2  );
							 boolean fldExists = false;
							 String subStrFldName = s2;
							 if(selectedLookupFlds != selectedObject)
								 subStrFldName= s2.remove(relationshipName + '.');
							 String strFldLabel = tmpFieldMap.get(subStrFldName).getDescribe().getLabel();
							 System.debug('strFldLabel: '+ strFldLabel);
							 //use mapOfPrevExistingSelectSearchFilterFieldNames
							 fldExists = mapOfPrevExistingSelectSearchFilterFieldNames.keySet().contains(s2);
							 selOpt = new SelectOption(s2, strObjectName + '.' + strFldLabel);
/*							 if(selectedLookupFlds != selectedObject)
								 selOpt = new SelectOption(relationshipName + '.' + s2, strObjectName + '.' + strFldLabel);
							 else
								 selOpt = new SelectOption(s2, strObjectName + '.' + strFldLabel);
*/
							 System.debug('unSelectedSearchFilterFields--> selOpt:' + selOpt);
							 //if fld doesn't exist in selected list, then add to unselected list.
							 if(!fldExists)
								 options.add(selOpt);
						 }
					 }
				 }				 
			 }
		 }
		 if(options != null)
			 options.sort();
		 return options;
	 }

	 private List<SelectOption> selectOptionsFromSet2(Set<String> opts, String setName) {
		 List<SelectOption> options = new List<SelectOption>();
		 System.debug('selectOptionsFromSet2-->mapOfPrevExistingSelectSearchFilterFieldNames: ' + mapOfPrevExistingSelectSearchFilterFieldNames.keySet());
		 if((opts == null || opts.size() == 0) && mapOfPrevExistingSelectSearchFilterFieldNames.values().size() > 0)
			 opts.addAll(mapOfPrevExistingSelectSearchFilterFieldNames.keySet());

		 if((opts == null || opts.size() ==0) || selectedObject ==null){
			 options.add(new SelectOption('None', 'None'));

		 }else{
			 if(mapOfPrevExistingSelectSearchFilterFieldNames.values().size() > 0){
				 opts.addAll(mapOfPrevExistingSelectSearchFilterFieldNames.keySet());
			 }
			 List<String> optionsList = new List<String>(opts);
			 Map<String, Schema.SObjectField> tmpFieldMap = new Map<String, Schema.SObjectField>(); 
			 String relationshipName, strObjectName;
			 System.debug('222 selectOptionsFromSet2');
			 //optionsList.sort();
			 System.debug('selectOptionsFromSet2 + optionsList: ' + optionsList);
			 ///////////////////////////
			 if(selectedLookupFlds != selectedObject){
				 //get the field describe for lookup field.
				 System.debug('selectOptionsFromSet2-->selectedLookupFlds: '+ this.selectedLookupFlds);
				 Schema.SObjectField fld = fieldMap.get(selectedLookupFlds);
				 //get the object referenced .
				 System.debug('selectOptionsFromSet2-->fld: '+ fld);
				 Schema.sObjectType lookUpObj = fld.getDescribe().getReferenceTo().get(0);
				 strObjectName = lookUpObj.getDescribe().getLabel();
				 System.debug('selectOptionsFromSet2-->lookUpObj: '+ lookUpObj);
				 //get the relationship name.
				 relationshipName = fld.getDescribe().getRelationshipName();
				 System.debug('selectOptionsFromSet2-->relationshipName: '+ relationshipName);
				 tmpFieldMap = lookUpObj.getDescribe().fields.getMap();
				 System.debug('selectOptionsFromSet2-->tmpFieldMap: '+ tmpFieldMap);
			 }else{
				 if(selectedObject != null && selectedObject != 'None')
					 strObjectName = objectMap.get(selectedObject).getDescribe().getLabel();
				 tmpFieldMap =  fieldMap;
			 }

			 System.debug('setOfSelectedSearchFilterFieldNames: '+ setOfSelectedSearchFilterFieldNames);

			 /////////////////////////////
			 SelectOption selOpt ;
			 Set<String> currentSetOfSelSrchFld = new Set<String>();
			 currentSetOfSelSrchFld.addAll(optionsList);
			 for (String s2 : optionsList) {
				 System.debug('s2: ' + s2  );
				 boolean fldExists = false;
				 String strFldLabel ='' ;
				 String subStrFldName = s2;

				 if(selectedLookupFlds != selectedObject){
					 subStrFldName= s2.remove(relationshipName + '.');
				 }
				 System.debug('subStrFldName: '+ subStrFldName + '\tstrObjectName: '+ strObjectName);

				 strFldLabel = mapOfPrevExistingSelectSearchFilterFieldNames.get(s2);
				 if(strFldLabel == '' || strFldLabel ==  null){
					 strFldLabel = tmpFieldMap.get(subStrFldName).getDescribe().getLabel();
					 System.debug('strFldLabel: '+ strFldLabel);
					 selOpt = new SelectOption(s2, strObjectName+'.'+strFldLabel);
					 mapOfPrevExistingSelectSearchFilterFieldNames.put(s2, strObjectName+'.'+strFldLabel);
				 }else{
					 selOpt = new SelectOption(s2, strFldLabel);
				 }
				 System.debug(' SelectedSearchFilterFields--> selOpt:' + selOpt);
				 options.add(selOpt);
			 }
		 }				 
		 if(options != null)
			 options.sort();
		 return options;

	 }

	 /*	 private void addToMapOfFields(String objName, String fieldName){
		 System.debug('addToMapOfFields\tobjName:'+ objName+ '\tfieldName:'+ fieldName);
		 if(mapOfSetOfSelectedSearchFilterFields.get(objName) != null){
			 mapOfSetOfSelectedSearchFilterFields.get(objName).add(fieldName);
		 }
		 else{
			 mapOfSetOfSelectedSearchFilterFields.put(objName, new Set<string>());
			 mapOfSetOfSelectedSearchFilterFields.get(objName).add(fieldName);
		 }		 
	 }

	 private boolean checkIfFieldExistsInMap(String objName, String fieldName){
		 System.debug('mapOfSetOfSelectedSearchFilterFields: '+ mapOfSetOfSelectedSearchFilterFields.keySet()); 		
		 boolean bval=false;
		 if(selectedLookupFlds != selectedObject){
			 Schema.SObjectField fld = fieldMap.get(selectedLookupFlds);
			 //get the object referenced .
			 System.debug('checkIfFieldExistsInMap-->fld: '+ fld );
			 Schema.sObjectType lookUpObj = fld.getDescribe().getReferenceTo().get(0);
			 System.debug('checkIfFieldExistsInMap-->lookUpObj: '+ lookUpObj );
			 //get the relationship name.
			 String relationshipName = fld.getDescribe().getRelationshipName();
			 System.debug('selectedLookupFlds: '+ selectedLookupFlds + '\trelationshipName: ' + relationshipName + '\tobjName:'+ objName+ '\tfieldName:'+ fieldName);

			 if(objName.equals(relationshipName)){
				 System.debug('objName equals selectedLookupFlds.');
				 return false;
			 }
		 }
		 if(mapOfSetOfSelectedSearchFilterFields.get(objName) != null){
			 Set<String> setOfSearchFilterFields = mapOfSetOfSelectedSearchFilterFields.get(objName);
			 bval= setOfSearchFilterFields.contains(fieldName);
			 System.debug('bval: '+ bval);

		 }else{
		 }
		 return bval;
	 }
	  */
	 // These properties receive the customization form postback data
	 // Each time the [<<] or [>>] button is clicked, these get the contents
	 // of the respective selection lists from the form
	 public transient List<String> selectedDisplayFields;
	 public  List<String> selectedSearchFilterFields;

	 public list<String> getSelectedDisplayFields(){
		 System.debug('getter selectedDisplayFields: '+ selectedDisplayFields);
		 return selectedDisplayFields;
	 }

	 public void setSelectedDisplayFields(List<String> val){
		 System.debug('setter selectedDisplayFields: '+ val); 
		 this.selectedDisplayFields = val;
	 }

	 public list<String> getSelectedSearchFilterFields(){
		 System.debug('getter selectedSearchFilterFields: '+ selectedSearchFilterFields);
		 return selectedSearchFilterFields;
	 }

	 public void setSelectedSearchFilterFields(List<String> val){
		 System.debug('setter selectedSearchFilterFields: '+ val); 
		 this.selectedSearchFilterFields = val;
	 }

	 public transient List<String> unselectedDisplayFields { get; set; }
	 public transient List<String> unselectedSearchFilterFields { get; set; }


	 // Handle the actual button clicks. Page gets updated via a
	 // rerender on the form
	 public void doAdd() {
		 System.debug('selectedDisplayFields:' + selectedDisplayFields);
		 System.debug('selectedDisplayFieldNames:' + selectedDisplayFieldNames);
		 System.debug('unSelectedDisplayFieldNames:' + unSelectedDisplayFieldNames);
		 moveFields(selectedDisplayFields, selectedDisplayFieldNames, unSelectedDisplayFieldNames);
	 }
	 public void doRemove() {
		 moveFields(unselectedDisplayFields, unSelectedDisplayFieldNames, selectedDisplayFieldNames);
	 }

	 public void doAddSearchFilterFields() {
		 System.debug('doAddSearchFilterFields-->selectedSearchFilterFields:' + selectedSearchFilterFields);
		 System.debug('doAddSearchFilterFields-->setOfSelectedSearchFilterFieldNames:' + setOfSelectedSearchFilterFieldNames);
		 System.debug('doAddSearchFilterFields-->setOfUnSelectedSearchFilterFieldNames:' + setOfUnSelectedSearchFilterFieldNames);
		 moveFields(selectedSearchFilterFields, setOfSelectedSearchFilterFieldNames, setOfUnSelectedSearchFilterFieldNames);
	 }
	 public void doRemoveSearchFilterFields() {
		 set<String> tmpSet = new Set<String>();
		 moveFields(unselectedDisplayFields, tmpSet, selectedDisplayFieldNames);
	 }

	 private void moveFields(List<String> items, Set<String> moveTo, Set<String> removeFrom) {
		 //System.debug('selectedDisplayFields:' + selectedDisplayFields);
		 for (String s: items) {
			 moveTo.add(s);
			 removeFrom.remove(s);
		 }
	 }

	 public void sampleMethod(){
		 System.debug('setSelectedLookupFlds: ' + selectedLookupFlds);
	 }
}