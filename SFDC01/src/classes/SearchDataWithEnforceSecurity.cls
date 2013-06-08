public with sharing class SearchDataWithEnforceSecurity {
	private String queryString{get;set ;}
	public SearchDataWithEnforceSecurity(){
		
	}
	
	public SearchDataWithEnforceSecurity(String queryString){
		this.queryString = queryString;
	}
	
	public list<SObject> getData(){
		return database.query(queryString);
	}
}