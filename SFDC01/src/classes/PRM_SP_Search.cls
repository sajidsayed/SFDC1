/*=========================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER                WR                   DESCRIPTION                               
|  ====          =========                ==                   =========== 
|  12/8/2010     Saravanan C             Service provider        Initial Creation
|                                                    
 +========================================================================================================*/

public  class PRM_SP_Search {

    
    public PRM_SP_Search(){
        showSearch = true;
     SelectCount =  Integer.valueOf(DataValueMap.get('PRM_SP_Select_Count_Validn').DataValue__c);
    }
  
    /*** Global Variables ***/
    Map<String,PRM_SP_Wrapper> mapSearchHitList = new Map<String,PRM_SP_Wrapper> ();
    Map<String,PRM_SP_Wrapper> mapresults = new Map<String,PRM_SP_Wrapper> ();
    Map<String,String> sortingmap = new Map<String,String> ();
    list<string> sortaccnames = new list<string> ();
    public Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    
    public Integer SelectCount {get;set;}   
    public boolean showSearch {get;set;}
    public boolean showresult {get;set;}
    public boolean showLeadGen {get;set;}
    public Integer resultssize {get;set;}
    public boolean showNoresultsMessage {get;set;}
    
    public String ServiceOffering {get;set;}
    
    String[] Products = new String[]{};
    public String[] getProducts() {
        return Products ;
    }
        
    public void setProducts (String[] Products ) {
        this.Products = Products ;
    }
    
    String[] Theater = new String[]{};
    public String[] getTheater () {
        return Theater ;
    }
        
    public void setTheater  (String[] Theater ) {
        this.Theater = Theater ;
    }
    
    String[] Country = new String[]{};
    public String[] getCountry () {
        return Country ;
    }
        
    public void setCountry  (String[] Country ) {
        this.Country = Country ;
    }
    
    String[] State = new String[]{};
    public String[] getState () {
        return State ;
    }
        
    public void setState  (String[] State ) {
        this.State = State ;
    }
    
    String[] SLA = new String[]{};
    public String[] getSLA () {
        return SLA ;
    }
        
    public void setSLA  (String[] SLA ) {
        this.SLA = SLA ;
    }
    
    public list<String> LeadsSentDetail {get;set;}
    
    public list<PRM_SP_Wrapper> SearchHitList {get;set;}
    
    
  
    public List<SelectOption> options ;
    public list<Service_Provider_Mapping__c> SPResults {get;set;}
   
    public String Querythis ;
    public String QueryWhereClause ;
    string PLValues ;
    public list<Id> logoAttachmentIDs = new list<Id> ();
    public ID logoAttachmentID {get;private set;}
    public list<Id> logoRecordIDs = new list<Id> ();
    
    public map<id,id> SpAccId = new map<id,id>() ;
     public map<id,id> AcclogoId = new map<id,id>() ;
     public map<id,id> SplogoRecId = new map<id,id>() ;
     public map<id,string> logoRecAttchId = new map<id,string>() ;
   
    public String Company {get;set;}
    public String FirstName {get;set;}
    public String LastName {get;set;}
    public String Phone {get;set;}
    public String Email {get;set;}
    public String Street {get;set;}
    public String City {get;set;}
    public String LeadState {get;set;}
    public String Zip {get;set;}
    public String LeadCountry {get;set;}
    Public String LeadDescription; 
   
    public void CreateLead(){
    system.debug(' Selected SearchHitList ===> ' + SearchHitList ); 
    system.debug(' SearchHitList.size() ===> ' + SearchHitList.size()); 
    system.debug(' Company  ===> ' + Company ); 
    
    list<Lead> leads = new list<lead> ();
    
    
      for (PRM_SP_Wrapper wrap:  SearchHitList){
       if(wrap.selectx){
        String LeadOwnerId ;
          if( wrap.LeadAdmin != null ){
              LeadOwnerId = wrap.LeadAdmin;
          }else if ( wrap.LeadQueue != null ){
           QueueSobject QueueObj =  [ Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name =: wrap.LeadQueue limit 1 ];
              LeadOwnerId = QueueObj.QueueId;
          }
          Lead l = new Lead ( recordtypeid = '012700000005Iaa', Company = Company, Status = 'New',
                          FirstName = FirstName, LastName = LastName, Sales_Force__c = 'EMC',
                          Lead_Originator__c = 'Field', LeadSource= 'Manual', Phone = Phone,
                          Email = Email, Street = Street, City = City,
                          State = LeadState,  PostalCode = Zip,
                          Country = LeadCountry, OwnerId = LeadOwnerId,
                          Passed_to_Partner__c=True,
                          Channel__c='Indirect',
                          Originator_Details__c = 'Service Search', 
                          Description =  LeadDescription
          );
          leads.add(l);
      } 
          
     }
     system.debug(' leads ===> ' + leads); 
        Insert Leads;
   }
   
    public void LeadGen() {
        showLeadGen = true;
        showSearch = false;
        showresult = false;
        showNoresultsMessage = false;
         
    }
    
   public PageReference searchClicked(){ 
       doSearch();
       return null;
    } 
    
    public PageReference doSearch() {
    mapSearchHitList = new Map<String,PRM_SP_Wrapper> ();
    mapresults = new Map<String,PRM_SP_Wrapper> ();
    sortingmap = new Map<String,String> ();
    
     system.debug( '===> ' + ServiceOffering  );
     system.debug( '===> ' + Products );
     system.debug( '===> ' + Theater );
     system.debug( '===> ' + Country );
     system.debug( '===> ' + State );
     system.debug( '===> ' + SLA );
     
     String PartnerType = 'Service Provider';
     Querythis =   ' Select id, Service_Offering__r.Service_Offering__c, Service_Offering__r.Country__c, Account__r.logo__r.Id, '
                 + ' Account__r.Name, Account__c,  Account__r.Grouping__r.Name, Account__r.Velocity_Service_Provider_Tier__c, '
                 + ' Account__r.Partner_Administrator__c, Account__r.Queue_Name__c from Service_Provider_Mapping__c '
                 + ' where ( Account__r.PROFILED_ACCOUNT_FLAG__c=true and  Account__r.Partner_Type__c includes ('+'\''+PartnerType+'\'' + ') )' 
                 + ' and ( Account__r.Partner_Administrator__c !=null or Account__r.Queue_Name__c !=null )' ;
                 
      QueryWhereClause = ' AND ( ';
      if( ServiceOffering != null ){
          QueryWhereClause = QueryWhereClause + ' Service_Offering__r.Service_Offering__c =: ServiceOffering ' ;
      }
      
      if( Products.size() >0 ) {
          QueryWhereClause = QueryWhereClause + WhereClauseHelper(Products,'Service_Offering__r.EMC_Products__c');
      }
      
      if( Theater.size() >0 ) {
          QueryWhereClause = QueryWhereClause + WhereClauseHelper(Theater,'Service_Offering__r.Theater__c');
      }  
      
      if( Country.size() >0 ) {
          QueryWhereClause = QueryWhereClause + WhereClauseHelper(Country,'Service_Offering__r.Country__c');
      }
      
      if( State.size() >0 ) {
          QueryWhereClause = QueryWhereClause + WhereClauseHelper(State,'Service_Offering__r.State__c');
        //  string tmpstatefieldName = 'Service_Offering__r.State__c';
         // string tmpstatefieldvalue = 'All';
          
        //  QueryWhereClause = QueryWhereClause + ' OR ( '+ tmpstatefieldName +' = ' +'\''+ tmpstatefieldvalue +'\'' + ' ) ' ;
      }
      
      if( SLA.size() >0 ) {
          QueryWhereClause = QueryWhereClause + WhereClauseHelper(SLA,'Service_Offering__r.SLA__c');
      } 
      
      QueryWhereClause = QueryWhereClause + ' ) ' + ' '  ;
      Querythis = Querythis + QueryWhereClause ;
      system.debug(' Query Build ===> ' + Querythis ); 
      
      SPResults = new list<Service_Provider_Mapping__c> ();
    
      SPResults = Database.Query(Querythis);
      system.debug(' Query results ===> ' + SPResults );    
      
          for ( Service_Provider_Mapping__c  sp: SPResults ){
              logoRecordIDs.add(sp.Account__r.logo__r.id); 
          }
       list<Attachment> logoBlob = [ select id,parentid  from Attachment where parentid in : logoRecordIDs ];  
       for ( Attachment att : logoBlob  ) {
          logoRecAttchId.put( att.parentid,att.id); 
       }
       
       SearchHitList = new list<PRM_SP_Wrapper> ();
      
        for ( Service_Provider_Mapping__c  a: SPResults ){
          
            PRM_SP_Wrapper tmpHit = new PRM_SP_Wrapper () ;
              tmpHit.logoid = logoRecAttchId.get(a.Account__r.logo__r.Id) ;
              tmpHit.serviceoffering = a.Service_Offering__r.Service_Offering__c ;
              tmpHit.profiledaccname = a.Account__r.Name ;
              tmpHit.profiledaccid = a.Account__c ;
              tmpHit.partnergrouping = a.Account__r.Grouping__r.Name ;
              tmpHit.country = a.Service_Offering__r.Country__c ;
              tmpHit.tier = a.Account__r.Velocity_Service_Provider_Tier__c ;
              tmpHit.LeadAdmin = a.Account__r.Partner_Administrator__c ;
              tmpHit.LeadQueue = a.Account__r.Queue_Name__c ;
              system.debug('tmpHit===> '+tmpHit);
             system.debug('checking here ===>'+a.id);
              if( !mapSearchHitList.containskey(a.Account__c) ){
                  mapSearchHitList.put(a.Account__c,tmpHit); 
                  mapresults.put(a.Account__r.name, tmphit) ;
                  sortingmap.put(a.Account__c, a.Account__r.name ) ;
              }
            //  system.debug(' tmpHit  ===> ' + tmpHit );    
        }
     //   system.debug('mapresults===>'+mapresults);
      //  system.debug('sortingmap===>'+sortingmap);
       sortaccnames = sortingmap.values();
       sortaccnames.sort(); 
     //  system.debug('sortaccnames===>'+sortaccnames);
      
       doSorting('Platinum',sortaccnames);
       doSorting('Gold',sortaccnames);
       doSorting('Silver',sortaccnames);
       doSorting('null',sortaccnames);
      
      showresult = true;
      showNoresultsMessage = false;
      resultssize = SearchHitList.size();
      if(SPResults.size() == 0 ){
          showNoresultsMessage = true;
          showresult = false;
      }
      
      if( Products.size() >0 ) {
          LeadDescription = ServiceOffering + ', ' + Products ;
      }else{ 
          LeadDescription = ServiceOffering ;
      }
      
       system.debug(' SearchHitList ===> ' + SearchHitList ); 
     return null;
    }
    
    public PRM_SP_Wrapper doSorting(String tier, list<String> accnames){
       for( String name: accnames ){
          PRM_SP_Wrapper tmp_spwrapper = new PRM_SP_Wrapper ();
            tmp_spwrapper = mapresults.get(name) ;
            String tmp_tier =  tmp_spwrapper.tier ;
           if( tmp_tier  == tier ){
               SearchHitList.add(tmp_spwrapper);
           }
           if( tier == 'null' && tmp_tier  == null ){
               SearchHitList.add(tmp_spwrapper);
           }
          }
      return null;
    }
    
    public String WhereClauseHelper(list<string> values, string fieldname) {
         string tmpValue,tmpValue2,allnone; 
         string stateallvalue = 'All';
         boolean flag;
         integer j = values.size()-1 ;
     for( integer i=0; i <= j ; i++  ) {
               flag = false;
           if( values[i] == 'ALL' ){ 
                allnone = ' != null ' ;                   
                flag = true;
            }
     
             
        if(values.size() == 1){
          tmpValue = ' AND ( ' + fieldname + ' = ' +'\''+values[i]+'\'' + ' ) ' ;  
          tmpValue = values[i] == '--None--' ? ' '  : tmpValue ;
          tmpValue2 = ' AND ( ' + fieldname + allnone  + ' ) ' ;
          if ( fieldname == 'Service_Offering__r.State__c'){
           tmpValue = ' AND ( ' + fieldname + ' = ' +'\''+values[i]+'\'' + ' or '+ fieldname + ' = ' +'\''+stateallvalue+'\'' + ' ) ' ;    
          }
          tmpValue = flag ?   tmpValue2 : tmpValue ; 
          
        }else{
          if( i == 0 ) {
             tmpValue = ' AND ( ' + fieldname + ' = ' +'\''+values[i]+'\'' ;
             tmpValue = values[i] == '--None--' ? ' AND ( '  : tmpValue ;
             tmpValue2 = ' AND ( ' + fieldname + allnone  + ' ' ;
             tmpValue = flag ?   tmpValue2 : tmpValue ; 
            
          }else if( i < j ) {
           
            if ( values[i-1] == '--None--' ){
                 tmpValue = tmpValue  + fieldname + ' = ' +'\''+values[i]+'\'' ;
             }else{
                 tmpValue = tmpValue + ' OR ' + fieldname + ' = ' +'\''+values[i]+'\'' ;
             }
             tmpValue2 = tmpValue + ' OR ' + fieldname + allnone ;
             tmpValue = flag ?   tmpValue2 : tmpValue ; 
             
          }else if( i == j ) {
              if ( values[i-1] == '--None--' ){
                 tmpValue = tmpValue +  fieldname + ' = ' +'\''+values[i]+'\'' + ' ) ';
             }else{
               if ( fieldname == 'Service_Offering__r.State__c'){
                  tmpValue = tmpValue + ' OR ' + fieldname + ' = ' +'\''+values[i]+'\'' +  ' or '+ fieldname + ' = ' +'\''+stateallvalue+'\'' + ' ) ' ;    
               } else{
                  tmpValue = tmpValue + ' OR ' + fieldname + ' = ' +'\''+values[i]+'\'' + ' ) ';
               }
             }
                 tmpValue2 = tmpValue + ' OR ' + fieldname + allnone + ' ) ';
                
                 tmpValue = flag ?   tmpValue2 : tmpValue ; 
          }
        } 
       }
     return tmpValue ;
    } 
    
   
    
    public List<SelectOption> getServiceOfferingList(){
      options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.Service_Offering__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
    
    public List<SelectOption> getProductsList(){
      options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.EMC_Products__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
    
    public List<SelectOption> getTheaterList() {
       options = new List<SelectOption>();
      
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.Theater__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
    
    public List<SelectOption> getCountryList() {
      List<SelectOption> options = new List<SelectOption>();
      
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.Country__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
    
    
    
    public List<SelectOption> getStateList() {
       options = new List<SelectOption>();
      
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.State__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
     //  options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
    
    public List<SelectOption> getSLAList(){
      options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =  Service_Offering__c.SLA__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption ('--None--', '--None--') ); 
       for( Schema.PicklistEntry f : ple) {
          options.add( new SelectOption( f.getLabel(), f.getValue() ) );
       }       
       return options ;
    }
   
   
}