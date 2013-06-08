/*====================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                    DESCRIPTION 
 |  ====          =========               ==                    =========== 
 |  11/05/2011    Prasad Kothawade                             This class is used for Custom Account search  .
 |  27/07/2011    Suman B                3160                  Added AccountSearch filter criteria for filteringout inactive Accounts.
 |  02/08/2011    Suman B									   Modified the Country field selectOptions from CustomSettings CustomSettingCountryTheaterMapping__c 
 |   														   to Country__C field picklist values on the AccountSearch  
 |  12/09/2011    Suman B				 3808				   Added logic to set the Country field with Account Country CustomSetting for 
 |																Macedonia and South Georgia.  
 |  20/09/2011    Suman B                                      Added try catch block in populateValues1() method to avoid the Query Exception and display the error
 |																message on the VF page. 
 |  17/10/2011    Suman B									   Added try catch block in populateAccountInfo() method avoid the Query Exception and display the error
 | 	26/10/2011    Arif                  WR#177286				Set 'IsPortalInsert' as true if insertion of DR takes place while account selection
 |  04/11/2011    Suman B               IM7290735				Populating the CompanyLocal field with Related Account's NameLocal. 
 |  10/11/2011    Suman B	 			IM7312572				To override the local address fields with new related Account Address on DR.
 |  11/11/2011    Suman B	 			WR#178765				Modified AccountSearch for searching based on Party Number.
 |  22/11/2011    Suman B	 			WR#178765				Modified AccountSearch for searching based on Synergy_Account_Number__c also.  
 |  03/07/2012    Ganesh                WR#194416               Account's custom search for Leads 
 |  03/08/2012    Anirudh Singh         Exception Handling      Added try and catch block for exception handling after line#87
 |  12/10/2012     Vivek                195356                  uncommented PostalCode (InputZipCode)
 |  25/03/2013    Karunaker M			223941					Handled Null pointer exception for isdealreg flag. 
 +===================================================================================================================================*/


public class PRM_DEALREG_CustomSearch {
        
 Public List<Account> listAccount   {get;set;}
 public String inputvalue           {get;set;}
 public String inputAccountName     {get;set;}
 public String inputStreet          {get;set;}
 public String inputCity            {get;set;}
 public String inputState           {get;set;}
 public String inputZipCode         {get;set;}
 public String inputCountry         {get;set;}
 public String paramValue           {get;set;}
 public Boolean noResult            {get;set;}
 public String selectedrecord       {get;set;}
 public String hiddenAccId          {get;set;}
 public String inputFirstName       {get;set;}
 public String inputLastName        {get;set;}
 public boolean namesRequired       {get;set;}
 public String inputPartyNumber     {get;set;}  // Added for WR#178765.
 //CustomSearch hiddenFields.
  public String  hiddenStreet      {get;set;}
  public String  hiddenCity        {get;set;}
  public String  hiddenState       {get;set;}
  public String  hiddenZipCode     {get;set;}
  public String  hiddenCountry     {get;set;}

 //PopulateLeadAddress hiddenFields.
  public String  selectedStreet    {get;set;}
  public String  selectedCity      {get;set;}
  public String  selectedState     {get;set;}
  public String  selectedZipCode   {get;set;}
  public String  selectedCountry   {get;set;}
  public Lead   objLead   {get;set;}
  public static boolean flag = false;
  Map<Id,Account> AccountMap= new Map<Id,Account>();
   //Added by Ganesh 
  public string leadId; 
  public boolean isDealReg; 
  public string strLeadRecordTypeID; 
  
    Public List<Account> defaultlistAccount ; 
    string strQuery ;
    string inputAccountName1 ;
    String inputState1 ;
    String inputZipCode1;
    String inputCountry1 ;
    string inputCity1  ;
    String inputStreet1 ;
    String accountStatus = 'Active';
    String inputPartyNumber1 ;
    Public Boolean setlocalAddress = false;   
    //Sorting 
    public string sortField1 {get;set;}
    public Boolean sortAscending1 {get;set;}
    public string defaultsortQuery  {get;set;}
 
    // paging
    public PageManager objPageManager       {get;set;}
    public List<Account> lstAccountDetails  {get;set;}
    
   public PRM_DEALREG_CustomSearch() {
        leadId=ApexPages.currentPage().getParameters().get('LeadId'); 
         //Added by Ganesh        
        strLeadRecordTypeID=ApexPages.currentPage().getParameters().get('RecordTypeId'); 
        if((ApexPages.currentPage().getParameters().get('IsDealReg'))!=null){ 
          isDealReg = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IsDealReg')); 
        } 
        if(strLeadRecordTypeID == 'undefined' && leadId!='00Q'){
        	try{
        	strLeadRecordTypeID = [Select Id,RecordTypeId from Lead where id =: leadId].RecordTypeId;
        	}
        	catch(Exception ex){
        		
        	}
        }         
        listAccount = new List<Account>();
        objLead = new Lead();
        defaultlistAccount = listAccount ;
        if(leadId=='00Q'){
             namesRequired = true;
        }else{
            namesRequired=false;
        }
        lstAccountDetails = new List<Account>();         
        sortAscending1 = TRUE;
       //   sortField1 = 'Name';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c pageDetails = DataValueMap.get('PageSize');
        Integer pageSize = 25;        
        try
        {            
            pageSize  = Integer.valueOf(pageDetails.DataValue__c);
        }
        catch(Exception e)
        {
          pageSize = 25;
        }  
       objPageManager = new PageManager(pageSize);
     }
  
     public void search() {
        
        strQuery = 'Select id,name,type,Owner.alias,BillingStreet,BillingCity,BillingCountry,BillingState, BillingPostalCode,City_Local__c, Country_Local__c, State_Province_Local__c, Street_Local__c, Zip_Postal_Code_Local__c, ' ;
        strQuery =  strQuery +' Party_Number__c,Preferred_Install_Flag__c,NameLocal,Account_Status__c,Synergy_Account_Number__c, ' ;
        strQuery =  strQuery +' Child_Record_Count_Contact__c,Address__c,Address_Local__c ';
        strQuery =  strQuery + ' FROM Account  WHERE ISPARTNER = false AND' ; 
        strQuery =  strQuery + ' Account_Status__c =:accountStatus  AND'  ;        

        // Added for - WR#178765
        if(inputPartyNumber != Null && inputPartyNumber != ''){
           inputPartyNumber1 = inputPartyNumber  ;
           strQuery =  strQuery + ' (Party_Number__c like : inputPartyNumber1  OR Synergy_Account_Number__c like : inputPartyNumber1  ) AND ';
         }
        if(inputAccountName != Null && inputAccountName != ''){
           inputAccountName1 = inputAccountName  ;
           strQuery =  strQuery + ' name like : inputAccountName1  AND';
         }
         if(inputState != Null && inputState != ''){
            inputState1 = inputState  ;
            strQuery =  strQuery + ' BillingState like :inputState1 AND ' ;
         }
         if(inputZipCode != Null && inputZipCode !=''){
            inputZipCode1 = inputZipCode ;
            strQuery =  strQuery + ' BillingPostalCode like : inputZipCode1 AND ';
         }
         if(inputCountry != Null && inputCountry != ''){
             inputCountry1 = inputCountry  ;
             Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
        
             for(CountryMapping__c countryAccLead : countryValueMap.values()){
               if(inputCountry == countryAccLead.LeadCountry__c){
                 inputCountry1 = countryAccLead.AccountCountry__c ; 
               }
             }//End of for loop.         	 
             system.debug('inputCountry1 ######### '+ inputCountry1);
            strQuery =  strQuery + '  BillingCountry  like : inputCountry1 AND ';
         }
         if(inputCity != Null && inputCity !=''){
           inputCity1  =  inputCity  ;
           strQuery =  strQuery + ' BillingCity like :inputCity1 AND ';
         }
         if(inputStreet != Null && inputStreet != ''){
           inputStreet1 = inputStreet   ;
           strQuery =  strQuery + ' BillingStreet like :inputStreet1 AND ' ;
         }
    
       strQuery = strQuery.substring(0,strQuery.length()-4 );
       strQuery += '  LIMIT 100' ;
       system.debug('QUERY##### '+strQuery);
       
       objPageManager.page = 0;
       objPageManager.numberOfRows =0;
       
       try{  
           listAccount = Database.query(strQuery);
       }catch(QueryException qe){
         system.debug('Query Exception' + qe);
       }
      // strQuery = '';
    
   if(listAccount == Null || listAccount.size()==0 ){
    strQuery = 'Select id,name,type,BillingState,BillingPostalCode,BillingStreet, BillingCity,BillingCountry,City_Local__c, Country_Local__c, State_Province_Local__c, Street_Local__c, Zip_Postal_Code_Local__c, ' ;
    strQuery =  strQuery +' Party_Number__c,Preferred_Install_Flag__c,NameLocal,Account_Status__c,Synergy_Account_Number__c, ';
    strQuery =  strQuery +' Child_Record_Count_Contact__c,Address__c,Address_Local__c ';
    strQuery =  strQuery + ' FROM Account WHERE ISPARTNER = false AND' ; 
    strQuery =  strQuery + ' Account_Status__c =:accountStatus  AND'  ;    

    // Added for - WR#178765
    if(inputPartyNumber != Null && inputPartyNumber != ''){
           inputPartyNumber1 = inputPartyNumber  ;
           strQuery =  strQuery + ' (Party_Number__c like : inputPartyNumber1  OR Synergy_Account_Number__c like : inputPartyNumber1  ) AND';
    }
    if(inputAccountName != Null && inputAccountName != ''){
       inputAccountName1 = inputAccountName  ;
       strQuery =  strQuery + ' NameLocal  like : inputAccountName1  AND';
     }
     if(inputState != Null && inputState != ''){
        inputState1 = inputState  ;
        strQuery =  strQuery + ' State_Province_Local__c like :inputState1 AND ' ;
     }
     if(inputZipCode != Null && inputZipCode !=''){
        inputZipCode1 = inputZipCode ;
        strQuery =  strQuery + ' Zip_Postal_Code_Local__c like : inputZipCode1 AND ';
     }
     if(inputCountry != Null && inputCountry != ''){
        inputCountry1 = inputCountry  ;
        Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
        for(CountryMapping__c countryAccLead : countryValueMap.values()){
           if(inputCountry == countryAccLead.LeadCountry__c){
              inputCountry1 = countryAccLead.AccountCountry__c ; 
              }
             }//End of for loop.         	 
          system.debug('Local inputCountry1 ######### '+ inputCountry1);
         strQuery =  strQuery + '  Country_Local__c  like : inputCountry1 AND ';
     }
     if(inputCity != Null && inputCity !=''){
       inputCity1  =  inputCity  ;
       strQuery =  strQuery + ' City_Local__c like :inputCity1 AND ';
     }
     if(inputStreet != Null && inputStreet != ''){
       inputStreet1 = inputStreet   ;
       strQuery =  strQuery + ' Street_Local__c like :inputStreet1 AND ' ;
     }
     strQuery = strQuery.substring(0,strQuery.length()-4 );
     strQuery += '  LIMIT 100' ;
     system.debug('QUERY##### '+strQuery);
   
     try{  
        listAccount = Database.query(strQuery);
       }catch(QueryException qe){
         system.debug('Query Exception' + qe);
     }
   } // END OF SEARCH - LOCAL FIELDS.
       if(listAccount == Null || listAccount.size()==0 ){
        //Ganesh
       	if(!isDealReg)
       	 noResult = FALSE ;
       	else
         noResult = TRUE ;
       }else{
         noResult = FALSE ;
         objPageManager.numberOfRows = listAccount.size() ;
       }
   
     // return null ;
  }
   
    public void clearresults(){
     listAccount = defaultlistAccount ;
     //return null ;
    }

    
   public PageReference populateValues1(){
        PageReference pref=null;
       /* if(namesRequired && (inputFirstName=='' || inputLastName =='') ){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.First_And_Last_Name_Required);
                    ApexPages.AddMessage(msg);
                    return null;
         }*/  
        if( paramvalue != null && paramvalue != '' ){
           //Account selectedAccount=AccountMap.get(paramValue);
           Account selectedAccount= [select id,name,type,Owner.alias,BillingState,BillingPostalCode,BillingCity ,
                                   BillingStreet,BillingCountry,Party_Number__c, City_Local__c, Country_Local__c,State_Province_Local__c,
                                   Child_Record_Count_Contact__c,Address__c,Address_Local__c, NameLocal, Street_Local__c,Zip_Postal_Code_Local__c
                                FROM ACCOUNT WHERE id =: paramValue ] ;
            
                                
             string RecordTypeId=[Select r.Id, r.Name, r.SobjectType 
                                            from RecordType r 
                                            where  name='Deal Registration - Submitted' and SobjectType='Lead'].Id;
          
          Lead DealReg= new lead(Company=selectedAccount.name,LastName='[ENTER LAST NAME]');
          System.debug('leadId '+leadId);
         
          string strURL;
          if(leadId!='00Q'){
             try{  
                 DealReg = [ Select l.City, l.City_Local__c, l.Country, l.Country__c, l.Country_Local__c, l.Name, l.PostalCode, l.Related_Account__c, 
                               l.State, l.State_Province_Local__c, l.Street, l.Street_Local__c, l.Zip_Postal_Code_Local__c,CompanyLocal,l.Status
                               from Lead l 
                               where id =: LeadId];
                }Catch(Exception e ){
                   String exceptionMessage = 'Error : ' + e.getMessage();
                   ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, exceptionMessage);
                   ApexPages.addMessage(errorMessage);
                   return null ;
                } 
           }
                system.debug('selectedAccount.BillingCountry ---'+ selectedAccount.BillingCountry);
                system.debug('DealReg.Country__c ----' + DealReg.Country__c);
                DealReg.Country__c=selectedAccount.BillingCountry;
                DealReg.Country=selectedAccount.BillingCountry;
                DealReg.Street=selectedAccount.BillingStreet;
                DealReg.City=selectedAccount.BillingCity;
                DealReg.PostalCode=selectedAccount.BillingPostalCode;
                DealReg.State=selectedAccount.BillingState;
                DealReg.Related_Account__c=selectedAccount.id;   
                    //Added by Ganesh 
                    if(!isDealReg)
                    {             	
                        DealReg.RecordTypeId=strLeadRecordTypeID;                      
                         
                    }
                    else
                    {
                    DealReg.DealReg_Deal_Registration__c = true ;
 	                DealReg.RecordTypeId=RecordTypeId;
                    }           
               
                
                //DealReg.Name=selectedAccount.name ;
                system.debug('selectedAccount.BillingCountry ---'+ selectedAccount.BillingCountry);
                system.debug('DealReg.Country__c ----' + DealReg.Country__c);
                
                    DealReg.Country_Local__c=selectedAccount.Country_Local__c;
	                DealReg.Street_Local__c=selectedAccount.Street_Local__c;
                    DealReg.City_Local__c=selectedAccount.City_Local__c;
                    DealReg.Zip_Postal_Code_Local__c=selectedAccount.Zip_Postal_Code_Local__c;
                    DealReg.State_Province_Local__c=selectedAccount.State_Province_Local__c ;
                    DealReg.CompanyLocal = selectedAccount.NameLocal ;
 	                
                
                populatedTheaterFromCountryOnLead(DealReg);
             /* Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
                if(mapCountry.ContainsKey(DealReg.Country__c)){
                    DealReg.DealReg_Theater__c=mapCountry.get(DealReg.Country__c).theater__c;
                } */                
          //    Related_Account
                Map<String,CustomSettingDataValueMap__c> datavalueMap = CustomSettingDataValueMap__c.getall();
                String accountNameElementId ;
                if(datavalueMap.containskey('Related_Account')){
                   accountNameElementId = datavalueMap.get('Related_Account').DataValue__c;
                   system.debug('accountNameElementId :'+ accountNameElementId);
                 } 
         if(leadId!='00Q'){
                try{ //added by Arif
                	flag = true;
                	DealReg.IsPortalInsert__c = true;
                    update DealReg;
                    strURL= '/'+DealReg.Id +'/e?'+'&'+accountNameElementId+'='+selectedAccount.name;
                    strURL = strURL + '&retURL='+ DealReg.Id;
                    pref= new PageReference(strURL);
                }Catch(Exception ex){
                    String strErrorMessage = 'Error : '+ ex.getMessage();               
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    }              
                    if(strErrorMessage.endsWith(': []')){
                        strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                    }
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage);
                    ApexPages.addMessage(errorMessage);
                    pref = null;
                }
                
               
         }else{
                try{
                	//added by Arif
                	DealReg.IsPortalInsert__c = true;
                    insert DealReg;
                    strURL= '/'+DealReg.Id +'/e?'+'&'+accountNameElementId+'='+selectedAccount.name;
                    strURL = strURL + '&retURL='+ DealReg.Id;
                    pref= new PageReference(strURL);
                } catch(Exception ex){
                    String strErrorMessage = 'Error : '+ ex.getMessage();               
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    }              
                    if(strErrorMessage.endsWith(': []')){
                        strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                    }
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage);
                    ApexPages.addMessage(errorMessage);                    
                    pref = null;
                }               
                
               
            }
             
              
              system.debug('pref' + pref); 
          }
          return pref;
    }   
   Public PageReference searchAccount(){
    return new PageReference ('/PRM_DEALREG_CustomSearch');
   }    
   
    
   
    /* SORTING */  
  public void runSortAction1(){
   sortListAccounts(sortField1,sortAscending1 );
  }
  
   /* @Method <sortListAccounts(): This method is used  for displaying accounts in sorted order.  
           @param - <String,String>
           @return <void>
           @throws exception - <No Exception>
        */
  public void sortListAccounts(String strSortKey, boolean isASC){
     String sortQuery ;
     if(strquery != Null && strquery !=''){
        sortQuery =  strquery.substring(0,strQuery.length()-9 );
        if(isASC){
           sortQuery += '   ORDER BY ' + strSortKey + ' ASC ' + ' LIMIT 100  ';
        }else{
           sortQuery += '   ORDER BY ' + strSortKey + ' DESC ' + ' LIMIT 100 ';
        }   
         system.debug(sortQuery);    
        listAccount = Database.query(sortQuery);
     }
   } // End - sortListAccounts.
 
     public Pagereference populateAccountInfo() {
        system.debug('Inside PopualteAccountInfo');
        PageReference pref = null;
        /*if(namesRequired && (inputFirstName=='' || inputLastName =='') ){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.First_And_Last_Name_Required);
                    ApexPages.AddMessage(msg);
                    return null;
         } */
         if(inputStreet ==null || inputStreet == '' || inputCity == null ||inputCity== '' ||
            inputCountry== null || inputCountry== ''|| inputAccountName== null || inputAccountName== ''){
                 system.debug('Inside address error message');
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Populate_Address);
                 ApexPages.AddMessage(msg);
                 return null;
         }
      string accountInfoURL ;
          Lead DealReg= new lead(Company=inputAccountName ,LastName='[ENTER LAST NAME]');
          System.debug('leadId '+leadId);
          string RecordTypeId=[Select r.Id, r.Name, r.SobjectType 
                                            from RecordType r 
                                            where  name='Deal Registration - Submitted' and SobjectType='Lead'].Id;
          string strURL;
          if(leadId!='00Q'){
            try{          
               DealReg= [ Select l.City, l.City_Local__c, l.Country, l.Country__c, l.Country_Local__c, l.Name, l.PostalCode, l.Related_Account__c, 
                               l.State, l.State_Province_Local__c, l.Street, l.Street_Local__c, l.Zip_Postal_Code_Local__c,l.company,CompanyLocal 
                               from Lead l 
                               where id=:leadId];
             }catch(Exception e ){
                   String exceptionMessage = 'Error : ' + e.getMessage();
                   ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, exceptionMessage);
                   ApexPages.addMessage(errorMessage);
                   return null ;
             }                 
          }
           
		 
          /** Setting the Custom Setting Value for Country on Lead **/ 
          Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
          for(CountryMapping__c countryAccLead : countryValueMap.values()){
               if(inputCountry == countryAccLead.LeadCountry__c){
                 inputCountry = countryAccLead.AccountCountry__c ; 
               }
             }//End of for loop.         	 
            
             system.debug('company -inputAccountName ' + inputAccountName ); 
                DealReg.Country__c=inputCountry ;
                DealReg.Country=inputCountry ;
                DealReg.Street=inputStreet;
                DealReg.City=inputCity;
                 //Added by Ganesh 
                 if(!isDealReg)
                    {                       
                       DealReg.RecordTypeId=strLeadRecordTypeID;
                         
                    }
                    else
                    {
		                DealReg.DealReg_Deal_Registration__c= true ;          
		                DealReg.RecordTypeId=RecordTypeId;
                    }                    
               
                DealReg.Related_Account__c = null;             
                DealReg.Company = inputAccountName ;
                system.debug('DealReg company ' + DealReg.Company );
                             
               if(inputZipCode !=null && inputZipCode !='' ) {
                  DealReg.PostalCode=inputZipCode ;
               }
               if(inputState != Null && inputState !=''){
                DealReg.State=inputState;
               }
             populatedTheaterFromCountryOnLead(DealReg);               

            /* Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
                if(mapCountry.ContainsKey(DealReg.Country__c)){
                    DealReg.DealReg_Theater__c=mapCountry.get(DealReg.Country__c).theater__c;
                } */
                
            /** FOR LOCAL ADDRESS FIELDS BASED ON APJ PROFILES **/
               String userprofileId = UserInfo.getProfileId();
               system.debug('userprofileId ### ' +userprofileId);
          
               Map<String,APJ_Partner_Profiles__c> APJpartnerprofileMap = APJ_Partner_Profiles__c.getall();
               //system.debug('APJpartnerprofileMap '+ APJpartnerprofileMap.values());
                for(APJ_Partner_Profiles__c profileObj : APJpartnerprofileMap.values()){
                    if(profileObj.ProfileId__c == userprofileId ){
                       system.debug('APJ Local User');  
                       setlocalAddress = true;
                       break;
                    }
                }// End of for loop.
                if(setlocalAddress){
                    DealReg.Country_Local__c= inputCountry;
                    DealReg.Street_Local__c= inputStreet;
                    DealReg.City_Local__c= inputCity;
                    DealReg.CompanyLocal = inputAccountName ;                    
                  if(inputZipCode!=null && inputZipCode != ''){
                      DealReg.Zip_Postal_Code_Local__c= inputZipCode;
                  }
                  if(inputState!=null && inputState!= ''){
                      DealReg.State_Province_Local__c= inputState ;
                  } 
                } // End of setlocalAddress.                          
     
        if(leadId!='00Q'){
             try{
             	flag = true;
                DealReg.IsPortalInsert__c = true;
                System.Debug('DealReg---->'+ DealReg);                            
                update DealReg; 
                strURL= '/'+DealReg.Id +'/e' +'?retURL=' +DealReg.Id ;
                pref= new PageReference(strURL);
                system.debug('pref' + pref); 
             }
             Catch(Exception ex){
                    String strErrorMessage = 'Error : '+ ex.getMessage();               
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    }              
                    if(strErrorMessage.endsWith(': []')){
                        strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                    }
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage);
                    ApexPages.addMessage(errorMessage);
                    pref = null;
                }//End of catch-block.          
            }else{
               try{ 
               	//added by Arif
               	   DealReg.IsPortalInsert__c = true;
                   insert DealReg;
                   strURL= '/'+DealReg.Id +'/e' +'?retURL=' +DealReg.Id ;
                   pref= new PageReference(strURL);
 
               }
               catch(Exception ex){
                    String strErrorMessage = 'Error : '+ ex.getMessage();               
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    }              
                    if(strErrorMessage.endsWith(': []')){
                        strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                    }
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage);
                    ApexPages.addMessage(errorMessage);                    
                    pref = null;
                }  
            }
             
             system.debug('pref' + pref); 
             return pref;
     
     }
   
    public Pagereference cancel() {
      system.debug('Inside cancel' +LeadId   + LeadId!='00Q');
      string cancelURL ;
      
       if(LeadId!='00Q'){
          cancelURL = '/'+LeadId+'/e?nooverride=1';
       }else{
           string RecordTypeId=[Select r.Id, r.Name, r.SobjectType 
                                            from RecordType r 
                                            where  name='Deal Registration' and SobjectType='Lead'].Id;

          //Added by Ganesh                                   
          if(!isDealReg)
          {          	
            cancelURL = '/00Q/e?retURL=/00Q/o&RecordType='+strLeadRecordTypeID;
          }
          else
            cancelURL = '/00Q/e?retURL=/00Q/o&RecordType='+RecordTypeId;
       }
       System.debug(cancelURL);
       return new PageReference(cancelURL) ;
    }
    
   public List<SelectOption> getSearchCriteriaList() {     
     List<SelectOption> options2 = new List<SelectOption>();  
     options2.add(new SelectOption('','--None--'));       
  /* Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
     List<String> CountryList =new List<String>(mapCountry.keySet());
     CountryList.sort(); */
     Schema.DescribeFieldResult fieldResult = Lead.Country__c.getDescribe();
     List<Schema.PicklistEntry> CountryList = fieldResult.getPicklistValues();
     
     for(Schema.PicklistEntry f : CountryList){
       	options2.add(new SelectOption(f.getValue(),f.getValue()));
       }    
     return options2;  
   }
    /* @Method <getAccountDetails(): This property is used to display available for selection in the UI.> 
       @param - <void>
       @return <List<Account> 
       @throws exception - <No Exception>
    */
    public List<Account> getAccountDetails(){
        lstAccountDetails.clear();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<listAccount.size();i++){
            lstAccountDetails.add(listAccount.get(i));
        }
        System.debug('listAccount -->'+listAccount.size());
        System.debug('Final AccountSearch objPageManager.startIndex ------>'+ objPageManager.startIndex);
        System.debug('Final Accountsearch objPageManager.endIndex ------>'+ objPageManager.endIndex);
        System.debug('Final PageAccountDetails-->'+ lstAccountDetails.size());  
        return lstAccountDetails; 
    }

    /* @Method <populatedTheaterOnLead: This method is used to populate Theater value based on the selected Country.> 
       @param - <Lead>
       @return <void> 
       @throws exception - <No Exception>
    */
    public void populatedTheaterFromCountryOnLead(Lead leadObj){
            Map<String,CustomSettingCountryTheaterMapping__c> DataValueMap = CustomSettingCountryTheaterMapping__c.getAll();
            String strCountryname = '';
                System.debug('leadObj.Country__c-->' + leadObj.Country__c);
                if(leadObj.Country__c != null){
                    strCountryname = leadObj.Country__c;
                    System.debug('strCountryname.length()-->' + strCountryname.length());
                    if(strCountryname.length() >= 36){
                        strCountryname = strCountryname.substring(0, 36);
                        System.debug('strCountryname trim-->' + strCountryname);
                    }                   
                    if(DataValueMap.containsKey(strCountryname)){
                        leadObj.DealReg_Theater__c = DataValueMap.get(strCountryname).Theater__c; 
                        system.debug('DealReg_Theater__c --'+ leadObj.DealReg_Theater__c);
                    }                   
               }
      }
 }