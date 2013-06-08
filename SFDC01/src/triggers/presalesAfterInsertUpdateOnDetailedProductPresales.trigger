/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                 WR          DESCRIPTION                               

 |  ====          =========                 ==          =========== 

 |  09/12/2012    Srinivas Pinnamaneni      185712      Code added to update Product Bucket value in case object when 
                                                        ever detailed product is assigned to case record
 +==================================================================================================================**/

trigger presalesAfterInsertUpdateOnDetailedProductPresales on Detailed_Product_Presales__c (After Insert,After Update,After Delete) {

     //WR185712:Declare a Map to store case id's as key and value as Product Bucket if more than one 
    //product bucket add as comma sepertaed 
    Map<ID,String> MapCaseIdProducts = new Map<ID,String>();
    //WR185712:Declare set variable to store case ids 
    Set<ID> setCaseIds = new Set<ID>();
    
    //WR185712:Declare a string variable here and assign empty value 
    String strProduct = '';
	
 	if(Trigger.isInsert || Trigger.isUpdate)
 	{
 		
 		//WR185712: Iterate the updated/inserted records here
	 	for(Detailed_Product_Presales__c objDetailedProduct : Trigger.New)
	 	{
	 		//WR185712:Check if the case is assigned to this detailed product record then only
	 		//we have to insert the Product Bucket value in that case record.
	 		if(objDetailedProduct.Case__c == null)  return;
	 		
	 		//WR185712:Add Id's to Set variable
	 		setCaseIds.add(objDetailedProduct.Case__c);
	 	}
	 	//WR185712:Iterate all Detailed products here
	 	for(Detailed_Product_Presales__c objDetailedProduct : [select id,Case__c,Product_Bucket__c from Detailed_Product_Presales__c where Case__c in: setCaseIds])
	 	{
	 	
		 	//WR185712:Check if Map contains case id and then add product bucket as value with comma seperated.
		 	//else we can directly add these to map assuming this is new case record in map. 
		 	if(MapCaseIdProducts != null && MapCaseIdProducts.containsKey(objDetailedProduct.Case__c))
		 	{
		 		//WR185712:Get the value of product bucket in variable
		 		strProduct = '';
		 		strProduct = MapCaseIdProducts.get(objDetailedProduct.Case__c);
		 		  
		 		//WR185712:As here we know that this case has more than one detailed product so we need to append the values as comma seperated
		 		MapCaseIdProducts.put(objDetailedProduct.Case__c,strProduct+','+objDetailedProduct.Product_Bucket__c);
		 	}
		 	else
		 	{
		 		//WR185712:Add Case ids and product bucket to the map here
		 		MapCaseIdProducts.put(objDetailedProduct.Case__c,objDetailedProduct.Product_Bucket__c);
		 	}	
	 	}
	 	
	 	//WR185712:Get the case records and iterate them using the Map we used above
	 	//WR185712:Check null condition on Map if it is null then return from here
	 	if(MapCaseIdProducts == null) return;
	 	//WR185712:Get the records and add them in list variable
	 	List<Case> lstCaseDetails = [select id,Products__c from case where id in: MapCaseIdProducts.keySet()];
	 	//WR185712:Iterate the list of case records here
	 	for(Case objCase : lstCaseDetails)
	 	{
	 	  //WR185712:Get the matching case id using map and add the product bucket value to case record
	 	  objCase.Products__c = MapCaseIdProducts.get(objCase.Id);
	 	}
	 	
	 	//try
	 	//{
	 		//WR185712: Update the case records
	 		update lstCaseDetails;
	 	//}
	 	//catch(Exception ex)
	 	//{
	 	 
	 	//}
 	}
 	//WR185712: Check if the operation on trigger is delete
 	if(Trigger.isDelete)
 	{
 		//WR185712: Iterate the updated/inserted records here
 		for(Detailed_Product_Presales__c objDetailedProduct : Trigger.Old)
	 	{
	 		//WR185712:Check if the case is assigned to this detailed product record then only
	 		//we have to insert the Product Bucket value in that case record.
	 		if(objDetailedProduct.Case__c == null)  return;
	 		
	 		//WR185712:Add Id's to Set variable
	 		setCaseIds.add(objDetailedProduct.Case__c);
	 		if(MapCaseIdProducts != null && MapCaseIdProducts.containsKey(objDetailedProduct.Case__c))
		 	{
		 		//WR185712:Get the value of product bucket in variable
		 		strProduct = '';
		 		strProduct = MapCaseIdProducts.get(objDetailedProduct.Case__c);
		 		  
		 		//WR185712:As here we know that this case has more than one detailed product so we need to append the values as comma seperated
		 		MapCaseIdProducts.put(objDetailedProduct.Case__c,strProduct+','+objDetailedProduct.Product_Bucket__c);
		 	}
		 	else
		 	{
		 		//WR185712:Add Case ids and product bucket to the map here
		 		MapCaseIdProducts.put(objDetailedProduct.Case__c,objDetailedProduct.Product_Bucket__c);
		 	}	
	 	}
	 	system.debug('setCaseIds == '+setCaseIds);	
 	   //WR185712: Get all case records based on set ids
 	   List<Case> lstCase =  [select id,Products__c from Case where id in: setCaseIds];
 	   for(Case objCase : lstCase)
 	   {
 	   	   system.debug('objCase == '+objCase);	
 	   	   system.debug('MapCaseIdProducts == '+MapCaseIdProducts);	
 	   	   strProduct = objCase.Products__c.replace(MapCaseIdProducts.get(objCase.ID),'');
 	   	   objCase.Products__c = strProduct.replace(',,','');
 	   	   //String str = objCase.Products__c.replace(','+MapCaseIdProducts.get(objCase.ID),''); 
 	   	   system.debug('objCase.Products__c == '+objCase.Products__c);	
 	   }
 	   
 	   update lstCase;
 	}
    
}