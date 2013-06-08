public class EBC_PresenterLookup
{
    public List<EBC_Topic_Presenters__c> tp= new List<EBC_Topic_Presenters__c>();
    public String searchTopicName;
    public String strTopic;
    public String pName;

    public String searchTopicValue=ApexPages.currentPage().getParameters().get('Topic');
    public String PresenterName=ApexPages.currentPage().getParameters().get('EBCname');    
    public String location {get;set;}
    public String areaOfExpertise {get;set;}
    public Boolean selected = true;
    
    //new experiment
    public String componentid =Apexpages.currentPage().getParameters().get('componentid');    
    public String topicpresenterid =Apexpages.currentPage().getParameters().get('topicpresenterid');
    public String isguestpresenter =Apexpages.currentPage().getParameters().get('isguestpresenter');
    public String guestfirstname =Apexpages.currentPage().getParameters().get('guestfirstname');
    public String guestlastname =Apexpages.currentPage().getParameters().get('guestlastname');
    public String guesttitle =Apexpages.currentPage().getParameters().get('guesttitle');
    public String guestemail =Apexpages.currentPage().getParameters().get('guestemail');
    public String guestcompany =Apexpages.currentPage().getParameters().get('guestcompany');
    public String presenterid =Apexpages.currentPage().getParameters().get('presenterid'); 
    
    
    public EBC_Session_Presenter__c SPresenterforg {get;set;}
    
    //getter-setters
        public String getcomponentid() {
        return componentid;
    }
    public void setcomponentid(String s) {
        componentid= s;
    }
    //getters and setters for new experiment
        public String gettopicpresenterid() {
        return topicpresenterid;
    }
    public void settopicpresenterid(String s) {
        topicpresenterid= s;
    }
        public String getisguestpresenter(){
        return isguestpresenter;
    }
    public void setisguestpresenter(String b){
        isguestpresenter = b;
    }
        public String getguestfirstname() {
        return guestfirstname;
    }
    public void setguestfirstname(String s) {
        guestfirstname= s;
    }
        public String getguestlastname() {
        return guestlastname;
    }
    public void setguestlastname(String s) {
        guestlastname= s;
    }
        public String getguesttitle() {
        return guesttitle;
    }
    public void setguesttitle(String s) {
        guesttitle= s;
    }
        public String getguestemail() {
        return guestemail;
    }
    public void setguestemail(String s) {
        guestemail= s;
    }
        public String getguestcompany() {
        return guestcompany;
    }
    public void setguestcompany(String s) {
        guestcompany= s;
    }
    //End of getters and setters for new experiment
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
    public Boolean getselected() {
        return selected;
    }                    
    public void setselected(Boolean selected) { 
    this.selected = selected;
    }
     
     //Constructor
     public  EBC_PresenterLookup()
     {
        searchTopicName=searchTopicValue;
        pname= PresenterName;
          strTopic = searchTopicName.replace('*', '\\$1'); 
          strTopic = searchTopicName.replace('?', '\\$1');
           
        
       if((strTopic!=Null || strTopic!='') && (pname!=Null || pname!=''))
        tp= (List<EBC_Topic_Presenters__c>)[SELECT id,Name,EBC_Name__c,EBC_Title__c,Organization__c,Discussion_Leader_Location__c,Discussion_Leader_Area_of_Expertise__c,Topic__r.Name,Topic__c,Presenter__r.Name,IsCertified__c from EBC_Topic_Presenters__c WHERE Topic__r.Name LIKE :('%'+strTopic+'%') AND EBC_Name__c LIKE:('%'+pname+'%') and Active__c=true order By IsCertified__c desc,Presenter__r.Name,Topic__r.Name LIMIT 1000];
      
      getguestdetails();  
     }
    
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
             dynamicQuery += ' Presenter__r.EBC_Name__c LIKE \'%' + filterForSOQLInjectionCharacters(presenterName) + '%\'';   
                      
          if(!isBlank(searchTopicName) && !dynamicQuery.endsWith(' AND ('))
             dynamicQuery += ' OR Topic__r.Name LIKE \'%' + filterForSOQLInjectionCharacters(strTopic) + '%\'';
          else if(!isBlank(searchTopicName) && dynamicQuery.endsWith(' AND ('))
             dynamicQuery += ' Topic__r.Name LIKE \'%' + filterForSOQLInjectionCharacters(strTopic) + '%\'';       
           
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
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Topic Presenter')); 
        options.add(new SelectOption('false','Guest Presenter')); 
        return options;
    }
     public void getguestdetails() {
        if(presenterid!=Null && presenterid!='')
       {
       SPresenterforg = [Select Guest_Presenter_First_Name__c, Guest_Presenter_Last_Name__c, Guest_Presenter_Email__c,
                                Guest_Presenter_EBC_Title__c, Guest_Company__c from EBC_Session_Presenter__c where id =:presenterid LIMIT 1];
        }
        else
        {
        SPresenterforg = new EBC_Session_Presenter__c();
        }
    }                            
}