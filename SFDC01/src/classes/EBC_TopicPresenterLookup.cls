/*
Author:     Sunil Arora
Created on: 8-april-2010
Description: This page is used to show topic Presenter lookup Page.
This class is controller for Page(s): EBC_TopicPresenterLookup
Modified by: Sunil Arora
Modified on: 13-April-2010
Reason: Modified based on further inputs from the business
Modified by: Devi Prasad Bal
Modified on: 13-July-2010
Reason: WR#165071: Modified to search for new fields of Topic Presenters needed to be displayed on the search page
Modified by: Naveen Hiremath/Bluewolf
Modified on: 12-Jan-2012
Reason: Added search functionality for "Area of Expertise and Location" on the page and all the four criteria will be an OR

Modified by	: 	Avinash Kaltari
Modified on	: 	27-Jun-2012
Reason		: 	Added a if-stmt to eliminate the "Attempt to de-reference a null object" exception in EBC_TopicPresenterLookup method

*/
public class EBC_TopicPresenterLookup
{
    public List<EBC_Topic_Presenters__c> tp= new List<EBC_Topic_Presenters__c>();
    public String searchTopicName;
    public String strTopic;
    public String pName;    
    public String searchTopicValue=ApexPages.currentPage().getParameters().get('Topic');
    public String PresenterName;    
    public String location {get;set;}
    public String areaOfExpertise {get;set;}
    
    //getter-setters
    public String getsearchTopicName() {
        return searchTopicName;
    } 
    public void setsearchTopicName(String s) {
        searchTopicName= s;
    }
    
    public String getPresenterName() {
        return PresenterName;
    }
    public void setPresenterName(String s) {
        PresenterName= s;
    }

     
     //Constructor
     public  EBC_TopicPresenterLookup()
     {
        //tp=[Select Id,FirstName,LastName from Lead limit 10];
        searchTopicName=searchTopicValue;
        
//Following if-statement added by Avinash to avoid the "Attempt to de-reference a null object" exception
        if(searchTopicName != null)
        {
        	strTopic = searchTopicName.replace('*', '\\$1'); 
        	strTopic = searchTopicName.replace('?', '\\$1'); 
        }
        
       
        tp= (List<EBC_Topic_Presenters__c>)[SELECT id,Name,EBC_Name__c,EBC_Title__c,Organization__c,Discussion_Leader_Location__c,Discussion_Leader_Area_of_Expertise__c,Topic__r.Name,Topic__c,Presenter__r.Name,IsCertified__c from EBC_Topic_Presenters__c WHERE Topic__r.Name LIKE :('%'+strTopic+'%') and Active__c=true order By IsCertified__c desc,Presenter__r.Name,Topic__r.Name];
     }
     String searchName;
     
     
     //Pagereference method to filter with Search Criteria.   
     public PageReference doSearch() {
    
         strTopic = searchTopicName.replace('*',''); 
         strTopic = searchTopicName.replace('?','');
         pName = PresenterName.replace('*',''); 
         pName = PresenterName.replace('?',''); 

       	 String orderByQuery = ' Order By IsCertified__c desc,Presenter__r.Name,Topic__r.Name';
         String dynamicQuery = 'SELECT id,Name,EBC_Name__c,EBC_Title__c,Organization__c,Discussion_Leader_Location__c,Discussion_Leader_Area_of_Expertise__c,Topic__r.Name,Topic__c,Presenter__r.Name,IsCertified__c from EBC_Topic_Presenters__c WHERE Active__c=true';
         
         if(isBlank(presenterName) && 
            isBlank(searchTopicName) && 
            isBlank(location) && 
            isBlank(areaOfExpertise)) {
         	dynamicQuery += orderByQuery;
         } else {
         	dynamicQuery += ' AND (';
         		
	        if(!isBlank(presenterName)) 
	         	dynamicQuery += ' Presenter__r.Name LIKE \'%' + pName + '%\'';   
	         	       	
	        if(!isBlank(searchTopicName) && !dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' OR Topic__r.Name LIKE \'%' + strTopic + '%\'';
	        else if(!isBlank(searchTopicName) && dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' Topic__r.Name LIKE \'%' + strTopic + '%\'';       
	         
	        if(!isBlank(location) && !dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' OR Discussion_Leader_Location__c LIKE \'%' + filterForSOQLInjectionCharacters(location) + '%\'';
	        else if(!isBlank(location) && dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' Discussion_Leader_Location__c LIKE \'%' + filterForSOQLInjectionCharacters(location) + '%\'';
	         
	        if(!isBlank(areaOfExpertise) && !dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' OR Discussion_Leader_Area_of_Expertise__c LIKE \'%' + filterForSOQLInjectionCharacters(areaOfExpertise) + '%\'';
	        else if(!isBlank(areaOfExpertise) && dynamicQuery.endsWith(' AND ('))
	         	dynamicQuery += ' Discussion_Leader_Area_of_Expertise__c LIKE \'%' + filterForSOQLInjectionCharacters(areaOfExpertise) + '%\'';
	        
	        dynamicQuery += ' ) ';
	        dynamicQuery += orderByQuery;
         }
         dynamicQuery += ' Limit 1000';

         tp = Database.query(dynamicQuery);
         
        return null; 
     }
     
     private static Boolean isBlank(String field) {
     	return (field == null || field.trim() == '');
     }
     
     private static String filterForSOQLInjectionCharacters(String rawInput) {
     	return (rawInput != null) ? String.escapeSingleQuotes(rawInput) : rawInput; 
     }
     
     public List<EBC_Topic_Presenters__c> gettp() {
      return tp;
     }
}