/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  16.12.2011      Anand Sharma               Controller for the Partner SE Search page.
 |  05.01.2012      Anand Sharma               Updated logic for uniqueness
 |  06.01.2012      Anand Sharma               Updated to display both Skill and District details
 |  06.01.2012      Anand Sharma               Created method populateLastedModifiedSESkill to Latest_Modified_Skill_Rating__c field value as false
 |  09.01.2012      Kaustav Debnath            Updated the Latest_Modified_Skill_Rating__c field in the dynamic queries strQuery at 2 places
 |  30.01.2012      Anand Sharma               Added Partner_Leverage_Factor__c field in Query
 |  23/04/2012		Anil Sure		  188166   Added Data Warehouse and Citrix fields in Excel as per May Release 
 +=========================================================================================================================*/
public class PRM_PartnerSESearchController {
    
    public District_to_Partner_SE_Mapping__c objDistrictPartner {get; set;}
    public District__c objDistrict {get; set;}
    public List<PartnerSearchContainer> lstPartnerSearchContainer {get; set;}
    public List<PartnerSESearchResultWrapper> lstPartnerSearchresult {get; set;}
    public List<Contact> lstPartWithAccWrap {get; set;}
    public List<SelectOption> countryList {get;set;}
    public List<SelectOption> areaList {get;set;}
    public String strCountryValue{get; set;}
    public String strAreaValue{get; set;}   
    public Boolean bDisplaySearchBlock{get; Set;} 
    public Boolean isSelected{get; Set;}
        
    Map<String, List<CustomSettingPartnerSESeach__c>> mapPartnerSESeach = new Map<String, List<CustomSettingPartnerSESeach__c>>(); 
    
    /* constructor of the class */
    public PRM_PartnerSESearchController(){
        objDistrictPartner = new District_to_Partner_SE_Mapping__c(); 
        objDistrict = new District__c();
        lstPartWithAccWrap = new List<Contact>();
        lstPartnerSearchresult = new List<PartnerSESearchResultWrapper>(); 
        isSelected = false;         
        strCountryValue =''; 
        strAreaValue='';
        countryList = new List<SelectOption>(); 
        areaList = new List<SelectOption>();        
        bDisplaySearchBlock = true;
        /* Build Product Type List of Values */
        Schema.DescribeFieldResult fieldResultDistrict = District__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> pt = fieldResultDistrict.getPicklistValues();
        for (Schema.PicklistEntry f : pt) {         
           countryList.add(new SelectOption(f.getLabel(), f.getValue()));            
        }
   
        /* Build License Type List of Values */
        
        Schema.DescribeFieldResult fieldResultArea = District__c.Area__c.getDescribe();
        List<Schema.PicklistEntry> lt = fieldResultArea.getPicklistValues();
        for( Schema.PicklistEntry f : lt) {    
           areaList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        List<CustomSettingPartnerSESeach__c> lstPartnerSESearch = [Select Id, Name, Competency__c,DisplayName__c, FilterValue__c, Type__c, Order__c 
                                                                    from CustomSettingPartnerSESeach__c order by Order__c asc];
        
        List<String>SectionOrder= new List<String>();
                                                                     
        if(lstPartnerSESearch.size() >0){
            lstPartnerSearchContainer = new List<PartnerSearchContainer>();
            
            for(CustomSettingPartnerSESeach__c objRecord: lstPartnerSESearch){
                if(mapPartnerSESeach.containsKey(objRecord.Competency__c)){
                    mapPartnerSESeach.get(objRecord.Competency__c).add(objRecord);
                }else{
                    mapPartnerSESeach.put(objRecord.Competency__c, new List<CustomSettingPartnerSESeach__c>());
                    mapPartnerSESeach.get(objRecord.Competency__c).add(objRecord);
                    SectionOrder.add(objRecord.Competency__c);
                }
            }
            
            PartnerSearchContainer objTempPartnerSearchContainer = new PartnerSearchContainer();
            for(String strCompetency :SectionOrder) {
                if(mapPartnerSESeach.ContainsKey(strCompetency)){
                    objTempPartnerSearchContainer = new PartnerSearchContainer();
                    List<CustomSettingPartnerSESeach__c> templstCustomSettingPartnerSESeach = mapPartnerSESeach.get(strCompetency);
                    if(templstCustomSettingPartnerSESeach!= null && templstCustomSettingPartnerSESeach.size() >0){
                        List<DataContainer> lstTempDataContainer = new List<DataContainer>();
                        //List<CustomSettingPartnerSESeach__c> lstTempDataPartnerSESeach = new List<CustomSettingPartnerSESeach__c>();
                        for(CustomSettingPartnerSESeach__c objTempPartnerSESearch : templstCustomSettingPartnerSESeach){
                            
                            DataContainer objTempDataContainer = new DataContainer();
                            objTempDataContainer.isSelected = false;
                            objTempDataContainer.objCustomSettingPartnerSESeach = objTempPartnerSESearch;
                            
                            lstTempDataContainer.add(objTempDataContainer);
                        }
                        objTempPartnerSearchContainer.CompetencyName = strCompetency;                       
                        objTempPartnerSearchContainer.lstDataContainer =lstTempDataContainer;
                        lstPartnerSearchContainer.add(objTempPartnerSearchContainer);   
                    }
                    
                }               
            }
        }
             
    }
    
    public void seachPartnerSE(){ 
        bDisplaySearchBlock = false;    
        List<District_to_Partner_SE_Mapping__c> lstDistrictPartnerSE = new List<District_to_Partner_SE_Mapping__c>();
        //Map<String, Map<String, Contact>> mapAccountContacts = new Map<String, Map<String,Contact>>();
        Map<String, Map<String, PartnerSESearchResultWrapper>> mapAccountContacts = new Map<String, Map<String,PartnerSESearchResultWrapper>>();
        //List<PartnerSESearchResultWrapper> lstPartnerSESearchResultWrapper = new List<PartnerSESearchResultWrapper>();
        List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSE = new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        Set<String> setContactIds = new Set<String>();
        String strDemographicInfo = '';
        lstDistrictPartnerSE.clear();
        lstPartWithAccWrap.clear();
        lstPartnerSearchresult.clear();
        String strDemographicInfoFinal = '';
        if(objDistrict.Theater__c != null && objDistrict.Theater__c !='' && objDistrict.Theater__c !='-None-'){
            strDemographicInfo +=  ' Theater__c = \'' + objDistrict.Theater__c + '\' AND ' ;
        }
        if(strCountryValue != '' && strCountryValue != '[]'){           
            strDemographicInfo +=  ' District__r.Country__c in (' + getfilterForPickList(strCountryValue) + ') AND ' ;
        }
        if(strAreaValue != '' && strAreaValue != '[]'){
            strDemographicInfo +=  '  Area__c in (' + getfilterForPickList(strAreaValue) + ') AND ' ;
        } 
        if(objDistrictPartner.District__c != null ){
            strDemographicInfo +=  ' District__c = \'' + objDistrictPartner.District__c + '\' AND ' ;
        }
        if(objDistrict.District_Manager__c != null){
            strDemographicInfo +=  ' District__r.District_Manager__c = \'' + objDistrict.District_Manager__c + '\' AND ' ;
        }       
        if(strDemographicInfo.endsWith('AND ')){                                
            strDemographicInfo = strDemographicInfo.substring(0,strDemographicInfo.length() -4);                           
        }
        if(strDemographicInfo != ''){
            strDemographicInfoFinal = 'Select Id, Name, Partner_SE__c, District__r.Name, Partner_SE__r.Name, Partner_SE__r.AccountId,District__r.Country__c, Partner_SE__r.Account.Name, Partner_SE__r.Email, Partner_SE__r.Office_Location__c, Partner_SE__r.Partner_Leverage_Factor__c, Partner_SE__r.Phone, Area__c, District__c, District_Division__c, District_Manager__c,  Theater__c from District_to_Partner_SE_Mapping__c where Partner_SE__r.Partner_SE__c = true AND ' + strDemographicInfo ;                                    
            System.Debug('strDemographicInfo -----> ' + strDemographicInfoFinal);                                    
            lstDistrictPartnerSE = database.Query(strDemographicInfoFinal);
            System.debug('lstDistrictPartnerSE ---------->' + lstDistrictPartnerSE);  
        }
        
        String StrQuery = createQuery();
        System.debug('StrQuery ---------->' + StrQuery);
        if(StrQuery !=null && StrQuery !=''){
            StrQuery = 'Select  Id,  Partner_SE__c, Partner_SE__r.Name, Partner_SE__r.AccountId, Partner_SE__r.Account.Name, Partner_SE__r.Email,  Partner_SE__r.MailingStreet, ' +
                        'BRS_Avamar_Skill__c, BRS_Data_Domain_Skill__c, BRS_Networker_Skill__c, IP_Networking_Skill__c, Isilon_Skill__c, Replication_Skill__c, RSA_Security_Skill__c, Symmetrix_Skill__c, ' +
                        'Unified_Skill__c, VCE_Skill__c, VMware_Skill__c, BRS_Avamar_Sales__c, BRS_Data_Domain_Sales__c, BRS_Networker_Sales__c, IP_Networking_Sales__c, Isilon_Sales__c, Replication_Sales__c, ' +
                        'RSA_Security_Sales__c, Symmetrix_Sales__c, Unified_Sales__c, VCE_Sales__c, VMware_Sales__c, Partner_SE_Overall_Sales_Acumen_Rating__c,Partner_SE_Overall_Skill_Rating__c , Oracle_App_Competence__c, Data_Warehouse_App_Competence__c, Citrix_App_Competence__c, SAP_App_Competence__c, SQL_App_Competence__c, VCE_App_Competence__c, VMware_App_Competence__c, ' +
                       ' Partner_SE__r.Office_Location__c, Partner_SE__r.Partner_Leverage_Factor__c,  Partner_SE__r.Phone from Partner_SE_Skill_Sales_Acumen_Rating__c where Partner_SE__r.Partner_SE__c = true AND Latest_Modified_Skill_Rating__c = true AND ' + StrQuery  + ' order by LastModifiedDate ';
        }else{
            StrQuery = '';
        }
        if(StrQuery != ''){
            lstPartnerSE = Database.Query(StrQuery); 
            System.debug('lstPartnerSE ---------->' + lstPartnerSE);
                    
        }
        if(lstPartnerSE.size()==0 && lstDistrictPartnerSE.size()==0 ){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,System.Label.Partner_SE_No_Filter_Selected);
            ApexPages.addMessage(msg);
        }
        if(StrQuery != '' && strDemographicInfoFinal != ''){
            if(lstDistrictPartnerSE.size() ==0 || lstPartnerSE.size() ==0 ){
                lstPartnerSearchresult.clear();
                return;
            }
        }
        //mapAccountContacts  =  populatePartnerSEData(lstDistrictPartnerSE, lstPartnerSE);
        if((StrQuery !='') && (strDemographicInfoFinal !='')){
            setContactIds = getValidContact(lstDistrictPartnerSE, lstPartnerSE );
        }else if((StrQuery !='') && (strDemographicInfoFinal =='')){            
            if(lstPartnerSE != null && lstPartnerSE.size() > 0){
                for(Partner_SE_Skill_Sales_Acumen_Rating__c objPartnerSESkill: lstPartnerSE){
                    if(objPartnerSESkill.Partner_SE__c != null ){
                        setContactIds.add(objPartnerSESkill.Partner_SE__c);
                    }
                }
                strDemographicInfoFinal = 'Select Id, Name, Partner_SE__c, District__r.Name, Partner_SE__r.Name, Partner_SE__r.AccountId,District__r.Country__c, Partner_SE__r.Account.Name, Partner_SE__r.Email, Partner_SE__r.Office_Location__c,Partner_SE__r.Partner_Leverage_Factor__c, Partner_SE__r.Phone, Area__c, District__c, District_Division__c, District_Manager__c,  Theater__c from District_to_Partner_SE_Mapping__c where Partner_SE__r.Partner_SE__c = true AND Partner_SE__c in:setContactIds ';
                lstDistrictPartnerSE = database.Query(strDemographicInfoFinal);
                System.debug('lstDistrictPartnerSE ---------->' + lstDistrictPartnerSE); 
            }
            
            
        }else if((StrQuery =='') && (strDemographicInfoFinal !='')){
            if(lstDistrictPartnerSE != null && lstDistrictPartnerSE.size() >0 ){
                for(District_to_Partner_SE_Mapping__c objDistPatnerSE: lstDistrictPartnerSE){
                    if(objDistPatnerSE.Partner_SE__c != null ){
                        setContactIds.add(objDistPatnerSE.Partner_SE__c);
                    }
                }
                
                StrQuery = 'Select  Id,  Partner_SE__c, Partner_SE__r.Name, Partner_SE__r.AccountId, Partner_SE__r.Account.Name, Partner_SE__r.Email,  Partner_SE__r.MailingStreet, ' +
                        'BRS_Avamar_Skill__c, BRS_Data_Domain_Skill__c, BRS_Networker_Skill__c, IP_Networking_Skill__c, Isilon_Skill__c, Replication_Skill__c, RSA_Security_Skill__c, Symmetrix_Skill__c, ' +
                        'Unified_Skill__c, VCE_Skill__c, VMware_Skill__c, BRS_Avamar_Sales__c, BRS_Data_Domain_Sales__c, BRS_Networker_Sales__c, IP_Networking_Sales__c, Isilon_Sales__c, Replication_Sales__c, ' +
                        'RSA_Security_Sales__c, Symmetrix_Sales__c, Unified_Sales__c, VCE_Sales__c, VMware_Sales__c, Partner_SE_Overall_Sales_Acumen_Rating__c,Partner_SE_Overall_Skill_Rating__c , Oracle_App_Competence__c, Data_Warehouse_App_Competence__c, Citrix_App_Competence__c, SAP_App_Competence__c, SQL_App_Competence__c, VCE_App_Competence__c, VMware_App_Competence__c, ' +
                       ' Partner_SE__r.Office_Location__c, Partner_SE__r.Partner_Leverage_Factor__c,  Partner_SE__r.Phone from Partner_SE_Skill_Sales_Acumen_Rating__c where Partner_SE__r.Partner_SE__c = true AND Latest_Modified_Skill_Rating__c = true AND Partner_SE__c in:setContactIds order by LastModifiedDate ';
                lstPartnerSE = Database.Query(StrQuery); 
                System.debug('lstPartnerSE ---------->' + lstPartnerSE);
            }
        }       
        populatePartnerSEData(lstDistrictPartnerSE, lstPartnerSE, setContactIds);
        
    }
    
    public PageReference DisplayPrintableResults(){       
       return new PageReference ('/apex/PRM_PartnerSESearchResult');
        
    }
    public PageReference DisplayExportResults(){       
       return new PageReference ('/apex/PRM_PartnerSESearchExportExcel');
        
    }
    public void displayFilter(){
        bDisplaySearchBlock = true;
    }
    public PageReference clearFilter(){
        PageReference seSearchPage;
        seSearchPage = new PageReference ('/apex/PRM_PartnerSESearch');
        seSearchPage.setRedirect(true);
        return seSearchPage;
    }
     
    private String getfilterForPickList(String strFilerCriteria){
        String returnString ='';
        if(strFilerCriteria != '' && strFilerCriteria != '[]'){
            strFilerCriteria = + strFilerCriteria.substring(1, strFilerCriteria.length() -1);           
        }
        String[] arrValues = strFilerCriteria.split(',');
        System.Debug('arrValues -----> ' + arrValues);
        
        for(Integer i=0; i< arrValues.size() ; i++){
            returnString = returnString + '\'' + String.escapeSingleQuotes(arrValues[i].trim()) + '\',';
            System.Debug('returnString inside-----> ' + returnString); 
        }
        if(returnString.endsWith(',')){                                
            returnString = returnString.substring(0,returnString.length() -1);                           
        }
        System.Debug('returnString -----> ' + returnString); 
        return returnString;
    }
    public String createQuery(){
        
        Map<String, String > mapQuery = new Map<String, String>();      
        for(PartnerSearchContainer objPartnerSearchContainer : lstPartnerSearchContainer){
            String query ='';
            if(mapQuery.containsKey(objPartnerSearchContainer.CompetencyName)){
                query = mapQuery.get(objPartnerSearchContainer.CompetencyName);             
            }else{
                query = mapQuery.put(objPartnerSearchContainer.CompetencyName, ''); 
                query = mapQuery.get(objPartnerSearchContainer.CompetencyName);
            }
            mapQuery.put(objPartnerSearchContainer.CompetencyName, query);
            System.debug('objPartnerSearchContainer.lstDataContainer.size() ---------->' + objPartnerSearchContainer.lstDataContainer.size());
            if(objPartnerSearchContainer.lstDataContainer.size() >0){
                for(DataContainer objDataContainer : objPartnerSearchContainer.lstDataContainer){
                    String strTemp ='';
                    if(objDataContainer.isSelected){
                        String strField = objDataContainer.objCustomSettingPartnerSESeach.Name ;
                        String strValue = objDataContainer.objCustomSettingPartnerSESeach.FilterValue__c ;
                        if(strField.contains('__c')){
                            strTemp = strField + ' ' + strValue ;                        
                            query = query + strTemp + ' AND ' + strField + ' != \'N/A\''  + ' AND ';
                        }else{
                            strTemp = strField + '_Skill__c ' + strValue  + ' AND ' + strField + '_Sales__c ' + strValue;                        
                            query = query + strTemp + ' AND ' + strField + '_Skill__c ' + ' != \'N/A\''  + ' AND ' + strField + '_Sales__c ' + ' != \'N/A\''  + ' AND ';
                        }
                    }
                }
                mapQuery.put(objPartnerSearchContainer.CompetencyName, query);
            }
        }
        String FinalQuery ='';
        for(String strCompetancy : mapQuery.keySet()){
            if(mapQuery.get(strCompetancy).endsWith('AND ')){                                
                FinalQuery = FinalQuery +  '(' + mapQuery.get(strCompetancy).substring(0,mapQuery.get(strCompetancy).length() -4) + ') AND ';                               
            }           
        }
        
        if(FinalQuery.endsWith('AND ')){                                
            FinalQuery = FinalQuery.substring(0,FinalQuery.length() -4);                               
        }
        System.debug('mapQuery ---------->' + mapQuery);
        System.debug('FinalQuery ---------->' + FinalQuery);    
        
        return FinalQuery;  
    }
    //Map<String, Map<String, Contact>>
    public void populatePartnerSEData(List<District_to_Partner_SE_Mapping__c> lstDistrictPartnerSE, List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSE, Set<String> setContactIds){
        Map<String, Map<String, List<District_to_Partner_SE_Mapping__c>>> mapAccountContactsDistricts = new Map<String, Map<String, List<District_to_Partner_SE_Mapping__c>>>();
        Map<String, Map<String, Partner_SE_Skill_Sales_Acumen_Rating__c>> mapAccountContactsSkills = new Map<String, Map<String,Partner_SE_Skill_Sales_Acumen_Rating__c>>();
        Map<String, Set<String>> mapAccountWithContacts = new Map<String, Set<String>>();
        Map<String, String> mapAccountWithName = new Map<String,String>();
        Set<String> setAccountIds = new Set<String>();
        if(setContactIds.size() ==0){
            return;
        }
        if(lstDistrictPartnerSE != null && lstDistrictPartnerSE.size() >0 ){
            for(District_to_Partner_SE_Mapping__c objDistPatnerSE: lstDistrictPartnerSE){
                if(objDistPatnerSE.Partner_SE__c != null && setContactIds.contains(objDistPatnerSE.Partner_SE__c)){
                    if(!mapAccountContactsDistricts.containsKey(objDistPatnerSE.Partner_SE__r.AccountId)){
                        mapAccountContactsDistricts.put(objDistPatnerSE.Partner_SE__r.AccountId, new Map<String,List<District_to_Partner_SE_Mapping__c>>());                    
                    }
                    if(!mapAccountContactsDistricts.get(objDistPatnerSE.Partner_SE__r.AccountId).containsKey(objDistPatnerSE.Partner_SE__c)){
                        mapAccountContactsDistricts.get(objDistPatnerSE.Partner_SE__r.AccountId).put(objDistPatnerSE.Partner_SE__c, new List<District_to_Partner_SE_Mapping__c>());                 
                    }
                    mapAccountContactsDistricts.get(objDistPatnerSE.Partner_SE__r.AccountId).get(objDistPatnerSE.Partner_SE__c).add(objDistPatnerSE);
                    
                    if(!mapAccountWithContacts.containsKey(objDistPatnerSE.Partner_SE__r.AccountId)){
                        mapAccountWithContacts.put(objDistPatnerSE.Partner_SE__r.AccountId, new Set<String>());
                    }
                    mapAccountWithContacts.get(objDistPatnerSE.Partner_SE__r.AccountId).add(objDistPatnerSE.Partner_SE__c);
                    mapAccountWithName.put(objDistPatnerSE.Partner_SE__r.AccountId, objDistPatnerSE.Partner_SE__r.Account.Name);
                }
            }               
        }   
        
        if(lstPartnerSE != null && lstPartnerSE.size() > 0){
            for(Partner_SE_Skill_Sales_Acumen_Rating__c objPartnerSESkill: lstPartnerSE){
                if(objPartnerSESkill.Partner_SE__c != null && setContactIds.contains(objPartnerSESkill.Partner_SE__c)){
                    if(!mapAccountContactsSkills.containsKey(objPartnerSESkill.Partner_SE__r.AccountId)){
                        mapAccountContactsSkills.put(objPartnerSESkill.Partner_SE__r.AccountId, new Map<String,Partner_SE_Skill_Sales_Acumen_Rating__c>());
                    }
                    if(!mapAccountContactsSkills.get(objPartnerSESkill.Partner_SE__r.AccountId).containsKey(objPartnerSESkill.Partner_SE__c)){                  
                        mapAccountContactsSkills.get(objPartnerSESkill.Partner_SE__r.AccountId).put(objPartnerSESkill.Partner_SE__c, objPartnerSESkill);
                    }
                    
                    if(!mapAccountWithContacts.containsKey(objPartnerSESkill.Partner_SE__r.AccountId)){
                        mapAccountWithContacts.put(objPartnerSESkill.Partner_SE__r.AccountId, new Set<String>());
                    }
                    mapAccountWithContacts.get(objPartnerSESkill.Partner_SE__r.AccountId).add(objPartnerSESkill.Partner_SE__c);
                    mapAccountWithName.put(objPartnerSESkill.Partner_SE__r.AccountId, objPartnerSESkill.Partner_SE__r.Account.Name);                    
                }
            }
        }
                
        List<Contact> lstTempContact = new List<Contact>(); 
        Contact objtempContact = new Contact();
        for(String strAccountId :mapAccountWithContacts.KeySet()){
            objtempContact = new Contact();
            objtempContact.AccountId = strAccountId;            
            objtempContact.Partner_Leverage_Factor__c = mapAccountWithContacts.get(strAccountId).size();
            lstTempContact.add(objtempContact);
        }
        System.debug('lstTempContact ---------->' + lstTempContact);
        lstTempContact = sortList(lstTempContact,'Partner_Leverage_Factor__c', false);
        
        System.debug('after sort lstTempContact ---------->' + lstTempContact); 
        List<String> lstAccount = new List<String>();
        Set<String> setAccount = new Set<String>();
        for(Contact objCon : lstTempContact){
            if(!setAccount.contains(objCon.AccountId)){
                lstAccount.add(objCon.AccountId);
                setAccount.add(objCon.AccountId);
            }           
        }
        System.debug('setAccount ---------->' + setAccount);
        System.debug('lstAccount ---------->' + lstAccount);
        PartnerSESearchResultWrapper objPartnerSESearchResultWrapper = new PartnerSESearchResultWrapper();
        District_to_Partner_SE_Mapping__c objDistrictPartnerSE = new District_to_Partner_SE_Mapping__c();
        Contact objContact = new Contact();
        Set<String> duplicateCheck = new Set<String>();
        if(mapAccountWithContacts != null && mapAccountWithContacts.size() >0){
            for(String strAccount : lstAccount){
                objPartnerSESearchResultWrapper = new PartnerSESearchResultWrapper();
                objPartnerSESearchResultWrapper.NumberOfContacts = mapAccountWithContacts.get(strAccount).size();                   
                objPartnerSESearchResultWrapper.AccountName = mapAccountWithName.get(strAccount);//mapAccountContactsDistricts.get(strAccount).values().get(0).get(0).Partner_SE__r.Account.Name;
                objPartnerSESearchResultWrapper.Accountid = strAccount; //mapAccountContactsDistricts.get(strAccount).values().get(0).Partner_SE__r.AccountId;
                lstPartnerSearchresult.add(objPartnerSESearchResultWrapper);                
                if(mapAccountWithContacts.containsKey(strAccount) && mapAccountWithContacts.get(strAccount).size() >0){
                    for(String strContactId : mapAccountWithContacts.get(strAccount)){                      
                        objPartnerSESearchResultWrapper = new PartnerSESearchResultWrapper();
                        objContact = new Contact();
                        
                        objPartnerSESearchResultWrapper.ContactId = strContactId;
                        if(mapAccountContactsDistricts.containsKey(strAccount) && mapAccountContactsDistricts.get(strAccount).containsKey(strContactId)){                       
                            objPartnerSESearchResultWrapper.ContactName = mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Name;
                            objContact.FirstName = mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Name;
                            objContact.Office_Location__c = mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Office_Location__c;
                            objContact.Partner_Leverage_Factor__c =  mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Partner_Leverage_Factor__c;
                            objContact.Phone = mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Phone;
                            objContact.Email =  mapAccountContactsDistricts.get(strAccount).get(strContactId).get(0).Partner_SE__r.Email;                   
                            
                            for(District_to_Partner_SE_Mapping__c objDistrictSE: mapAccountContactsDistricts.get(strAccount).get(strContactId)){
                                if(objDistrictSE.District__r.Name != null && objDistrictSE.District__r.Name !=''){
                                    if(objPartnerSESearchResultWrapper.DistrictName == null){
                                        objPartnerSESearchResultWrapper.DistrictName = objDistrictSE.District__r.Name + ', ' ;
                                    }else{
                                        duplicateCheck.clear();
                                        if(! checkDuplicate(objPartnerSESearchResultWrapper.DistrictName, objDistrictSE.District__r.Name)){
                                            objPartnerSESearchResultWrapper.DistrictName = objPartnerSESearchResultWrapper.DistrictName +  objDistrictSE.District__r.Name + ', ' ;  
                                        }                                           
                                    }                                   
                                }
                                if(objDistrictSE.District_Manager__c != null && objDistrictSE.District_Manager__c !=''){
                                    if(objPartnerSESearchResultWrapper.DistrictManager == null){
                                        objPartnerSESearchResultWrapper.DistrictManager = objDistrictSE.District_Manager__c + ', ' ;
                                    }else{
                                        if(! checkDuplicate(objPartnerSESearchResultWrapper.DistrictManager, objDistrictSE.District_Manager__c)){
                                            objPartnerSESearchResultWrapper.DistrictManager = objPartnerSESearchResultWrapper.DistrictManager +  objDistrictSE.District_Manager__c + ', ' ;
                                        }
                                    }                                   
                                }
                                if(objDistrictSE.Area__c != null && objDistrictSE.Area__c !=''){
                                    if(objPartnerSESearchResultWrapper.Area == null){
                                        objPartnerSESearchResultWrapper.Area = objDistrictSE.Area__c + ', ';
                                    }else{
                                        if(! checkDuplicate(objPartnerSESearchResultWrapper.Area, objDistrictSE.Area__c)){
                                            objPartnerSESearchResultWrapper.Area = objPartnerSESearchResultWrapper.Area + objDistrictSE.Area__c + ', ';
                                        }
                                        
                                    }   
                                } 
                                if(objDistrictSE.District__r.Country__c != null && objDistrictSE.District__r.Country__c !=''){
                                    if(objPartnerSESearchResultWrapper.Country == null){
                                        objPartnerSESearchResultWrapper.Country = objDistrictSE.District__r.Country__c + ', ';
                                    }else{
                                        if(! checkDuplicate(objPartnerSESearchResultWrapper.Country, objDistrictSE.District__r.Country__c)){
                                            objPartnerSESearchResultWrapper.Country = objPartnerSESearchResultWrapper.Country + objDistrictSE.District__r.Country__c + ', ';
                                        }
                                            
                                    }
                                }
                                if(objDistrictSE.Theater__c != null && objDistrictSE.Theater__c !=''){
                                    if(objPartnerSESearchResultWrapper.Theater == null){
                                        objPartnerSESearchResultWrapper.Theater = objDistrictSE.Theater__c + ', ';
                                    }else{
                                        if(! checkDuplicate(objPartnerSESearchResultWrapper.Theater, objDistrictSE.Theater__c)){
                                            objPartnerSESearchResultWrapper.Theater = objPartnerSESearchResultWrapper.Theater + objDistrictSE.Theater__c + ', ';
                                        }
                                        
                                    }
                                }
                            }
                            if(objPartnerSESearchResultWrapper.DistrictName != null && objPartnerSESearchResultWrapper.DistrictName != '' && objPartnerSESearchResultWrapper.DistrictName.endsWith(', ')){
                                objPartnerSESearchResultWrapper.DistrictName = objPartnerSESearchResultWrapper.DistrictName.substring(0,objPartnerSESearchResultWrapper.DistrictName.length() -2) ;
                            }
                            if(objPartnerSESearchResultWrapper.DistrictManager != null && objPartnerSESearchResultWrapper.DistrictManager != '' && objPartnerSESearchResultWrapper.DistrictManager.endsWith(', ')){
                                objPartnerSESearchResultWrapper.DistrictManager = objPartnerSESearchResultWrapper.DistrictManager.substring(0,objPartnerSESearchResultWrapper.DistrictManager.length() -2) ;
                            }
                            if(objPartnerSESearchResultWrapper.Area != null && objPartnerSESearchResultWrapper.Area != '' && objPartnerSESearchResultWrapper.Area.endsWith(', ')){
                                objPartnerSESearchResultWrapper.Area = objPartnerSESearchResultWrapper.Area.substring(0,objPartnerSESearchResultWrapper.Area.length() -2) ;
                            }
                            if(objPartnerSESearchResultWrapper.Country != null && objPartnerSESearchResultWrapper.Country != '' && objPartnerSESearchResultWrapper.Country.endsWith(', ')){
                                objPartnerSESearchResultWrapper.Country = objPartnerSESearchResultWrapper.Country.substring(0,objPartnerSESearchResultWrapper.Country.length() -2) ;
                            }
                            if(objPartnerSESearchResultWrapper.Theater != null && objPartnerSESearchResultWrapper.Theater != '' && objPartnerSESearchResultWrapper.Theater.endsWith(', ')){
                                objPartnerSESearchResultWrapper.Theater = objPartnerSESearchResultWrapper.Theater.substring(0,objPartnerSESearchResultWrapper.Theater.length() -2) ;
                            }   
                        }
                        
                        if(mapAccountContactsSkills.containsKey(strAccount) && mapAccountContactsSkills.get(strAccount).containsKey(strContactId)){
                            objPartnerSESearchResultWrapper.ContactName = mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Name;
                            objPartnerSESearchResultWrapper.PartnerSESkillRating = mapAccountContactsSkills.get(strAccount).get(strContactId);
                            objContact.FirstName = mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Name;
                            objContact.Office_Location__c = mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Office_Location__c;
                            objContact.Partner_Leverage_Factor__c =  mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Partner_Leverage_Factor__c;
                            objContact.Phone = mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Phone;
                            objContact.Email =  mapAccountContactsSkills.get(strAccount).get(strContactId).Partner_SE__r.Email;
                        }
                        
                        objPartnerSESearchResultWrapper.PartnerSE = objContact; 
                        lstPartnerSearchresult.add(objPartnerSESearchResultWrapper);                    
                    }
                }
                
            }
        }
        
        
        //System.debug('mapAccountContacts inside method---------->' + mapAccountContacts);
        //return mapAccountContacts;
    }
    /**/
    public Set<String> getValidContact(List<District_to_Partner_SE_Mapping__c> lstDistrictPartnerSE, List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSE){
        Set<String> setContactIds = new Set<String>();
        Set<String> setContactDistrictIds = new Set<String>();
        Set<String> setContactSkillIds = new Set<String>();
        if(lstDistrictPartnerSE != null && lstDistrictPartnerSE.size() >0 ){
            for(District_to_Partner_SE_Mapping__c objDistPatnerSE: lstDistrictPartnerSE){
                if(objDistPatnerSE.Partner_SE__c != null ){
                    setContactDistrictIds.add(objDistPatnerSE.Partner_SE__c);
                }
            }
        }
        if(lstPartnerSE != null && lstPartnerSE.size() > 0){
            for(Partner_SE_Skill_Sales_Acumen_Rating__c objPartnerSESkill: lstPartnerSE){
                if(objPartnerSESkill.Partner_SE__c != null ){
                    setContactSkillIds.add(objPartnerSESkill.Partner_SE__c);
                }
            }
        }
        if(setContactDistrictIds.size() > 0){
            for(String strContactid :setContactDistrictIds){
                if(setContactSkillIds.contains(strContactid)){
                    setContactIds.add(strContactid);
                }
            }
        }
        return setContactIds;
    }
    public Boolean checkDuplicate(String strResult, String keyStr){
        Set<String> arrResult = new Set<String>();
        Boolean result = false;
        
        List<String> arrString = strResult.split(',');      
        for(String strObj: arrString){
            arrResult.add(strObj.Trim());
        }
        if(arrResult.contains(keyStr.trim())){
            result = true;
        }
        return result;
    }
    public class PartnerSESearchResultWrapper{ 
        public Integer NumberOfContacts{get; set;}
        public String AccountName{get;set;}
        public String AccountId{get;set;} 
        public String ContactName{get;set;}
        public String ContactId{get;set;}  
        public String DistrictName{get;set;}
        public String DistrictManager{get;set;} 
        public String Area{get;set;}
        public String Country{get;set;}
        public String Theater{get;set;}
        public Contact PartnerSE {get; set;}
        public District_to_Partner_SE_Mapping__c DistrictPartnerSE {get; set;}
        public Partner_SE_Skill_Sales_Acumen_Rating__c PartnerSESkillRating{get; set;}      
    }
    
    public class DataContainer{
        public Boolean isSelected{get; set;}
        public CustomSettingPartnerSESeach__c objCustomSettingPartnerSESeach{get; set;}         
    }
    
    public class PartnerSearchContainer{        
        public String CompetencyName {get; set;}
        public List<DataContainer> lstDataContainer{get; set;}      
    } 
    public class PartnerWithAccountWrapper{
        public String AccountName {get; set;}
        public String AccountId {get; set;}
        public String Size {get; set;} 
        public String ContactId {get; set;}
        public Contact objPartnerSERecord {get; set;}   
    }
    
    //This function will take list as input parameter
    public static List<SObject> sortList(List<SObject> soListInput, String strSortKey, boolean isASC){
        List<SObject> soListOutput = soListInput.clone();
        soListOutput.clear();
        Map<Object, List<SObject>> soMapKey = new Map<Object, List<SObject>>();
        List<SObject> soListNulls = soListOutput.clone();
        for(SObject so : soListInput) {
            //Object oKey = so.get(strSortKey);
            Object oKey = getObject(so, strSortKey);
            if(oKey != null) {
                List<SObject> soList = soMapKey.get(oKey);
                if(soList == null) {
                    soList = soListOutput.clone();
                    soMapKey.put(oKey, soList);
                }
                soList.add(so);
            }else{
                soListNulls.add(so);
            }
        }
        List<Object> oListKey = new List<Object>( soMapKey.keySet());
        oListKey.sort();
       
        for(integer i=0; i< oListKey.size(); i++){
            Object oKey = oListKey[isASC ? i : (oListKey.size() - i - 1)];
            List<SObject> soList = soMapKey.get(oKey);
            for(SObject so : soList) soListOutput.add(so);
        }
        System.debug('soListNulls:'+soListNulls);
        for(integer i=0; i< soListNulls.size(); i++){
            System.debug(soListNulls[i]);
            soListOutput.add(soListNulls[i]);
        }
        return soListOutput;
    }
    //Get sort key.
    private static Object getObject(SObject so, String strKey){
        if(strKey == null) return null;
        if(strKey.indexOf('.') == -1) return so.get(strKey);
        String strPre = strKey.substring(0, strKey.indexOf('.'));
        String strPost = strKey.substring(strKey.indexOf('.')+1);
        SObject so2 = so.getSObject(strPre);
        if(so2 == null) return null;
        return getObject(so2, strPost);
    }
    
    public static void populateLastedModifiedSESkill(Set<Id> contactIds, Set<Id> parnerSESkillIds){
        List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSESkill = new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        if(contactIds != null && contactIds.size() >0 && parnerSESkillIds!=null && parnerSESkillIds.size()>0){
            lstPartnerSESkill = [Select Id, Latest_Modified_Skill_Rating__c From Partner_SE_Skill_Sales_Acumen_Rating__c
                                 Where Partner_SE__c in:contactIds and Latest_Modified_Skill_Rating__c = true AND id not in:parnerSESkillIds];
         }
         else{
              lstPartnerSESkill = [Select Id, Latest_Modified_Skill_Rating__c from Partner_SE_Skill_Sales_Acumen_Rating__c
                                    Where Partner_SE__c in:contactIds and Latest_Modified_Skill_Rating__c = true];
         }                                                                            
        if(lstPartnerSESkill != null && lstPartnerSESkill.size() >0){
            for(Partner_SE_Skill_Sales_Acumen_Rating__c objSkill:  lstPartnerSESkill){
                objSkill.Latest_Modified_Skill_Rating__c = false;
            }
            
            update lstPartnerSESkill;
        }                                                                                           
        
    }
}