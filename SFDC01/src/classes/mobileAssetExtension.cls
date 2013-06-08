public class mobileAssetExtension {

   public String name{get;set;} 
   public String dispStat {get;set;} 
   public String configDetails {get;set;} 
   public String vendor{get;set;} 
   
   public String prodFamily{get;set;} 
   public String model{get;set;} 
   public String orderDate {get;set;} 
   public String installDate{get;set;} 
   public String serialNum{get;set;} 
   public String errorMessage{get;set;} 
   public String insertStatus{get;set;}
   public Asset__c newAssetCreated{get;set;}
   public Mobjects__c mobject{get;set;}
   public Asset__c accountLKP{get;set;} 
   public String field1Name{get;set;}
   public String field1Type{get;set;} 
   public String field1Values{get;set;} 
   public String field2Name{get;set;} 
   public String field2Type{get;set;}
   public String field2Values{get;set;}
   public String field3Name{get;set;}
   public String field3Type{get;set;} 
   public String field3Values{get;set;}
    public String field4Name{get;set;}
   public String field4Type{get;set;} 
   public String field4Values{get;set;} 
   public String field5Name{get;set;} 
   public String field5Type{get;set;}
   public String field5Values{get;set;}
   public String field6Name{get;set;}
   public String field6Type{get;set;} 
   public String field6Values{get;set;} 
  
    public mobileAssetExtension(){
         accountLKP = new Asset__c();
       //getbuildTable ();
        getTableFields('Asset__c');
    }

     
    public Pagereference save ()
    
    {
       System.debug('Sajid caling save' ) ;
                
       name=ApexPages.currentPage().getParameters().get('AssetName');
       dispStat= ApexPages.currentPage().getParameters().get('dispStat');
       configDetails =ApexPages.currentPage().getParameters().get('configDetails');
       vendor=ApexPages.currentPage().getParameters().get('vendor');


        prodFamily=ApexPages.currentPage().getParameters().get('prodFamily');
       model= ApexPages.currentPage().getParameters().get('model');
       orderDate =ApexPages.currentPage().getParameters().get('orderDate');
       installDate=ApexPages.currentPage().getParameters().get('installDate');
       serialNum=ApexPages.currentPage().getParameters().get('serialNum');


       System.debug('Sajid'+ name ) ;
       System.debug('Sajid'+ dispStat ) ;        
        return null;      
                
     }
     public Account[] getListOFAccounts()
     {
        Account[] myAccount = [Select id, Name from Account limit 10];
        
        return myAccount;
     }
     public Asset__c[] getListOFAssets()
     {
        Asset__c[] myAsset = [Select id, Name from asset__c limit 10];
        
        return myAsset;
     }
     public Mobjects__c[] getListOFMobject()
     {
        Mobjects__c[] mobject = [Select id, Name, objectName__c, FieldName__c from mobjects__c limit 10];
        
        return mobject;
     }
    public String getbuildTable()
     {
         Mobjects__c[] mobject = getListOFMobject();
         String objectName='Asset__c';
         Sobject dynObject ;
         String buildTable;
         String fieldType;
         Integer cellCount =0;
         String tableCell;
         
         
             
         //Schema.DescribeSObjectResult d = 
  //Account.sObjectType.getDescribe();
         
         Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	Schema.SObjectType leadSchema = schemaMap.get(objectName);
         
         Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		//for (String fieldName: fieldMap.keySet()) {
			//	System.debug('##Field API Name='+fieldName);// list of all field API name
 			//	fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
			// }
         
         for (Mobjects__c mx : mobject) {
 			   //code_block
             // dynObject= Schema.getGlobalDescribe().get( objectName).newSObject() ;
             for (String fieldName: fieldMap.keySet()) {
				System.debug('##Field API Name='+fieldName);// list of all field API name
 				//It provides to get the object fields label.
                 if (mx.FieldName__c==fieldName)
             	{     
                    if (cellCount ==0)
                    {
                     	field1Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                        field1Name=fieldMap.get(fieldName).getDescribe().getLabel()+'fieldType='+field1Type;
                     	System.debug('Match found='+fieldName);
                     cellCount=cellCount+1;
                      }    
                    //if (cellCount ==0)
         			//{tableCell='<TR>';}
         
                    
                    fieldType =   ''+fieldMap.get(fieldName).getDescribe().getType();
                    if (cellCount ==0)
                    {
                        tableCell=tableCell+'<TR>';
                    }
                   
                    
                    tableCell=tableCell+'<TD><label for="basic">'+fieldMap.get(fieldName).getDescribe().getLabel()+'</label></TD>';
                    cellCount = cellCount +1;
                    
                    if (fieldType== 'PICKLIST')
                    {   
                       tableCell=tableCell+'<TD><select id="'+fieldName+'" name="'+fieldName+'">';
                        field2Name= fieldMap.get(fieldName).getDescribe().getLabel(); 
                        field2Type='PICKLIST';
                       List<Schema.PicklistEntry> pick_list_values = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
                       String selectTag='<select id=\"dispStat\" name=\"dispStat\">'; 
                       String optionvalues=selectTag; 
                      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                  
            				//options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
      					 optionvalues=optionvalues+'<option value=\"'+a.getValue()+'\">'+a.getLabel()+'</option>';
                          
                      }
                        field2Values=optionvalues+'</select>';
                        tableCell=tableCell+optionvalues+'</TD>';
                       // cellCount=cellCount+1;
                        //<option value="Installed">Installed</option>    <option value="Pipeline">Pipeline</option>    <option value="Upside">Upside</option>    <option value="Comit">Comit</option></select>
                    }
                    else
                    { 
                        
                      tableCell=tableCell+'<TD><input id="'+fieldName+'" name="'+fieldName+'" value="" type="'+fieldType+'" data-clear-btn="true"/></TD>';
                        
                        //cellCount=cellCount+1;
                    }
                    
                    if (cellCount==1)
                    {tableCell=tableCell+'</TR> Closing row';
                     cellCount=0;
                    }
             	}
			 }
             
             
			}
         //Schema.DescribeSObjectResult d1 =  dynObject.sObjectType.getDescribe();
         
        //Schema.DescribeSObjectResult d = objectName+ 
       // String buildTable='<label for="basic">Customer Asset Name</label><input id="text-3" name="AssetName" value="" type="text" data-clear-btn="true"/>';
       
        return tableCell;
     }
     
    public String buildPickList(String fieldNameP,Map<String, Schema.SObjectField> fieldMapP )
    {
    	String selectTag ;
       	selectTag='<select id="'+fieldNameP+'" name="'+fieldNameP+'">';
                        
        List<Schema.PicklistEntry> pick_list_values = fieldMapP.get(fieldNameP).getDescribe().getPickListValues(); 
        String optionvalues; 
       	for (Schema.PicklistEntry a : pick_list_values) 
        { //for all values in the picklist list
           optionvalues=optionvalues+'<option value=\"'+a.getValue()+'\">'+a.getLabel()+'</option>';
        }
        
        selectTag=selectTag+optionvalues+'</select>';
        
        return selectTag;
    }
    
    public String buildtextbox(String fieldName)
    { 
        String textBox;
        textBox='<input id="'+fieldName+'" name="'+fieldName+'" value="" type="text" data-clear-btn="true"/>';
        return textBox;
    }  
    public String buildtextarea(String fieldName)
    { 
        String textarea;
        
        textarea='<textarea name="'+fieldName+'" data-mini="true" id="textarea-a">';
        return textarea;
    }
     public void getTableFields(String objectToFetch)
     {
         Mobjects__c[] mobject = getListOFMobject();
         String objectName='Asset__c';
         //Sobject dynObject ;
        // String buildTable;
         //String fieldType;
         Integer cellCount =0;
         //String tableCell;
         
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = schemaMap.get(objectName);
         
         Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
		
         
         for (Mobjects__c mx : mobject) {
 			 
             for (String fieldName: fieldMap.keySet()) {
				System.debug('##Field API Name='+fieldName);// list of all field API name
 				//It provides to get the object fields label.
                 if (mx.FieldName__c==fieldName && mx.objectName__c==objectToFetch)
             	{     
                    if (cellCount==0)
                    {
					 field1Name=fieldMap.get(fieldName).getDescribe().getLabel();
					 field1Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                        
                        if (field1Type== 'PICKLIST')
                         {	field1Values = buildPickList(fieldName,fieldMap);}
                        /* else if (field1Type== 'STRING')
                         {	field1Values = buildtextbox(fieldName);}
                         else if (field1Type== 'TEXTAREA')
                         {	field1Values = buildtextarea(fieldName);}*/
                        
                     cellCount=cellCount+1;
                        
                    }
                    else if (cellCount==1)
                    { 
					    field2Name=fieldMap.get(fieldName).getDescribe().getLabel();
						field2Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                        if (field2Type== 'PICKLIST')
                         {	field2Values = buildPickList(fieldName,fieldMap);}
                       /*  else if (field2Type== 'STRING')
                         {	field2Values = buildtextbox(fieldName);}
                         else if (field2Type== 'TEXTAREA')
                         {	field2Values = buildtextarea(fieldName);}*/
                    	cellCount=cellCount+1;
                    }
                     else if (cellCount==2)
                    {
                      field3Name=fieldMap.get(fieldName).getDescribe().getLabel();
					  field3Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                        if (field3Type== 'PICKLIST')
                         {	field3Values = buildPickList(fieldName,fieldMap);}
                        /* else if (field3Type== 'STRING')
                         {	field3Values = buildtextbox(fieldName);}
                         else if (field3Type== 'TEXTAREA')
                         {	field3Values = buildtextarea(fieldName);}*/
                       cellCount=cellCount+1; 
                    }
                    else if (cellCount==3)
                    {	field4Name=fieldMap.get(fieldName).getDescribe().getLabel();
						field4Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                     if (field4Type== 'PICKLIST')
                         {	field4Values = buildPickList(fieldName,fieldMap);}
                    /*  else if (field4Type== 'STRING')
                         {	field4Values = buildtextbox(fieldName);}
                         else if (field4Type== 'TEXTAREA')
                         {	field4Values = buildtextarea(fieldName);}*/
                        cellCount=cellCount+1;
                    }
                    else if (cellCount==4)
                    {  
                        field5Name=fieldMap.get(fieldName).getDescribe().getLabel();
					    field5Type= ''+fieldMap.get(fieldName).getDescribe().getType();	
                     
                        if (field5Type== 'PICKLIST')
                         {	field5Values = buildPickList(fieldName,fieldMap);}
                      /*	else if (field5Type== 'STRING')
                         {	field5Values = buildtextbox(fieldName);}
                         else if (field5Type== 'TEXTAREA')
                         {	field5Values = buildtextarea(fieldName);*/
                        
                    	cellCount=cellCount+1;
                    }
                    else if (cellCount==5)
                    {	field6Name=fieldMap.get(fieldName).getDescribe().getLabel();
						field6Type= ''+fieldMap.get(fieldName).getDescribe().getType();
                     if (field6Type== 'PICKLIST')
                         {	field6Values = buildPickList(fieldName,fieldMap);}
                     /* else if (field6Type== 'STRING')
                         {	field6Values = buildtextbox(fieldName);}
                         else if (field6Type== 'TEXTAREA')
                         {	field6Values = buildtextarea(fieldName);}*/
                    	cellCount=cellCount+1;
                    }
                     
                    System.debug('Match found='+fieldName);
                    
			 }
             
             }
			}
         //Schema.DescribeSObjectResult d1 =  dynObject.sObjectType.getDescribe();
         
        //Schema.DescribeSObjectResult d = objectName+ 
       // String buildTable='<label for="basic">Customer Asset Name</label><input id="text-3" name="AssetName" value="" type="text" data-clear-btn="true"/>';
       
        //return tableCell;
     }
    
     public PageReference saveData ()
    {
     try{    
       System.debug('Sajid caling save data' ) ;
       
        String error ;
       
       Asset__c  assetc = new Asset__c();       
                
       name=ApexPages.currentPage().getParameters().get('AssetName');
       dispStat= ApexPages.currentPage().getParameters().get('dispStat');
       configDetails =ApexPages.currentPage().getParameters().get('configDetails');
       vendor=ApexPages.currentPage().getParameters().get('vendor');


       prodFamily=ApexPages.currentPage().getParameters().get('prodFamily');
       model= ApexPages.currentPage().getParameters().get('model');
       orderDate =ApexPages.currentPage().getParameters().get('orderDate');
       installDate=ApexPages.currentPage().getParameters().get('installDate');
       serialNum=ApexPages.currentPage().getParameters().get('serialNum');

//Date orderDateD = 
  // date.valueOf(orderDate );
   
//Date installDateD = 
  // date.valueOf(installDate);
      
        assetc.name =   name;  
        assetc.Disposition_Status__c=dispStat;   
        assetc.Configuration_Details__c =configDetails ; 
        //assetc.Vendor__c=vendor;     
        assetc.Product_Family__c=prodFamily;
        assetc.Model__c=model;
        //assetc.Order_Date__c=orderDateD;     
        //asset.Install_Date__c =  installDateD;
        assetc.Serial_Number__c =serialNum;
        assetc.Customer_Name__c ='0017000000dCpbb';
        List<Asset__c> listOfAsset = new List<Asset__c>();
        listOfAsset.add(assetc);
 
     //Insert listOfAsset;
     //Database.SaveResult[] result = Database.Insert(listOfAsset);
     Insert assetc;
    errorMessage= assetc.id ;
    
    if (assetc.id!=null )
    {
        insertStatus= 'Success';
       newAssetCreated =assetc;
    }

    //ApexPages.Message aperrorMessage = new ApexPages.Message(ApexPages.Severity.Error, errorMessage);
    //ApexPages.addMessage(aperrorMessage); 
    
  }  
 catch(Exception ex){
 
       errorMessage= ex.getStackTraceString();  
       //errorMessage=errorMessage +'Error';
       ApexPages.Message aperrorMessage = new ApexPages.Message(ApexPages.Severity.Error, errorMessage);
       ApexPages.addMessage(aperrorMessage);     
       return null   ;
 }
       

        
       System.debug('Sajid'+ name ) ;
       System.debug('Sajid'+ dispStat ) ;       
       return null;      
                
     }     
}