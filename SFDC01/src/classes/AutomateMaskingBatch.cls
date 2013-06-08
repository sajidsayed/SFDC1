global class AutomateMaskingBatch implements Database.Batchable<sObject>{
	public String Query; 
	public List<String> Fields = new List<String>();
	public String MaskingText;
	
	global AutomateMaskingBatch(String objectName, List<String> maskingFields, String maskText, String citeria ){
	    MaskingText=maskText;
	    Fields.addall(maskingFields);
	    Query='Select ' ;
	    System.debug('Query'+Query);
	    for(integer i=0; i<maskingFields.size(); i++){
	        Query = Query  + maskingfields[i] + ' , ';
		}
		
		if(Query != null && Query != '' && Query !='Select ' && query.endsWith(', ')) {
	    	Query = Query.substring(0,Query.length() -2);
	    }
	    Query=Query +' '+ 'from' + ' '+ objectName + ' ' + 'where' + '( ';
	    for(integer i=0; i<maskingFields.size(); i++){
	        Query = Query +'('+maskingfields[i] + ' ' + '!=Null' + ' and (NOT (' +  maskingfields[i] + ' ' + 'like \'%'+MaskingText  + '\' )))' + ' OR ' ;
	    }
	    if(Query != null && Query != '' && Query !='Select ' && query.endsWith('OR ')) {
	    	Query = Query.substring(0,Query.length() -3) + ' )';
	    }  
		/*
        integer z=maskingfields.size()-1;
        Query = Query +'('+maskingfields[Z] + ' ' + '!=Null' + ' and (NOT (' +  maskingfields[z] + ' ' + 'like \'%'+MaskingText  + '\' ))))'  ;
        */
        if(citeria != null && citeria !=''){
            Query = Query + ' and (' +citeria +')'; 
        }
        System.debug('Query '+Query);
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		for(sobject s : scope){
		    for(String Field: Fields ){
		       if(s.get(Field)!=null && s.get(Field)!='')
		        s.put(Field,s.get(Field)+ MaskingText ) ;
		    }
		}
		Database.SaveResult[] Results=database.update(scope,false);
	}
	global void finish(Database.BatchableContext BC){
	}
}