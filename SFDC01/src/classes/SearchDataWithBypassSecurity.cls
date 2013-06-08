public without sharing class SearchDataWithBypassSecurity {
	private String queryString{get;set ;}
	public SearchDataWithBypassSecurity(){
		
	}
	
	public SearchDataWithBypassSecurity(String queryString){
		this.queryString = queryString;
	}
	
	public list<SObject> getData(){
		return database.query(queryString);
	}

}