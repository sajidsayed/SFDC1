/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR         DESCRIPTION                               

 |  ====          =========      ==         =========== 
 |  01/25/2013    Ketan Benegal  WR 196848  Remove DealReg_EMCTA_Certified_Email__c field.
 |  19/04/2011    Ashwini Gowda  Req# 2450  Test class for non-portal registration Form.
                                  2429 
 |  14/12/2011      Anil                    Removed Query for fetching Partner and used Custom setting Data Helper
 |  11-JAN-2012     Anil                    Removed role Id                                                                                       
 |=============================================================================================================== */
 
@isTest
Private Class PRM_DEALREG_NonPortalRegistration_TC {

       
    public static Contact cont1=new Contact();
/* @Method <This method is used test non-portal registration Form>.   
    @param - <void>  
    @return <void> - <Not Returning anything   
    @throws exception - <No Exception>
*/      
    Private static testMethod void startTest(){
        User partner;
        User systemAdminUser = [Select Id,Name from User where Profile.Name ='System Administrator' and IsActive = true limit 1];
        System.RunAs(systemAdminUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        }
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert acc; 
        // Create PartnerUser            
       Contact cont = UserProfileTestClassDataHelper.createContact();
       cont.AccountId=acc[1].Id;
       insert cont;       
       
       System.RunAs(systemAdminUser){
       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
       //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
       partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
       insert partner;
        }  
        Lead dealReg = createDealReg(); 
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(dealReg); 
           
        PRM_DEALREG_NonPortalRegistrationCntrler dealRegController = new PRM_DEALREG_NonPortalRegistrationCntrler(stdController);
        dealRegController.doSearchWithoutFilters();
        dealRegController.sortList(dealregcontroller.sortField, true) ;
        if(dealRegController.lstFullProductsDetails.size()>0 ){
           Integer selectedcount = 0 ;
           for(PRM_DEALREG_NonPortalRegistrationCntrler.ProductsDataContainer selectedRegProd: dealRegController.lstFullProductsDetails){                 
                selectedRegProd.selected = true ;
                dealRegController.lstRegistrationProduct.add(selectedRegProd.selProduct);                 
                selectedcount ++ ;
               if(selectedcount > 3)
               break ;
            }
        }
         
        dealRegController.selectedrecord = acc[0].id ;
        dealRegController.populateValues();
        dealRegController.leadRecord.LastName ='TEST NAME';
        dealRegController.selectedProducts();
        dealRegController.doSearchQuery();
        dealRegController.addProducts();
        dealRegController.changeLang();
        dealRegController.getItems();
        dealRegController.selectedProducts();
        dealRegController.saveLeadAndProducts();
        dealRegController.saveProducts();
        dealRegController.updateProduct();

        dealRegController.cancelDeal();
        dealRegController.redirectToPowerlink();
        dealRegController.getProductsDetails();
        dealRegController.doSearchSubCatalog();
      
           dealRegController.addProducts() ;
        dealRegController.addProductsOnLead();
        dealRegController.sortList(dealregcontroller.sortField, true) ;
        dealRegController.runSortAction() ;
        dealRegController.deleteProducts();
        dealRegController.doSearchProduct();
       // CustomSearch
        dealRegController.clearresults();
        dealRegController.populateselectedrecord();
        dealRegController.sortListAccounts('name', TRUE);
        dealRegController.runSortAction1();
        dealRegController.search();
        dealRegController.populateAccountInfo();
        // setting address input fields.
        dealRegController.selectedAccountName = 'TestAcc';
        dealRegController.selectedCity = 'Testcity';
        dealRegController.selectedCountry = 'Test';
        dealRegController.selectedState='Test' ;
        dealRegController.selectedZipCode = 'Test' ;
        dealRegController.selectedStreet = 'Test';
        dealRegController.inputAccountName = 'TestAcc';
        dealRegController.inputCity = 'Testcity';
        dealRegController.inputCountry = 'Australia';
        dealRegController.inputState ='Test' ;
        dealRegController.inputZipCode = 'Test' ;
        dealRegController.inputStreet = 'Test';
        
        dealRegController.search() ;
        dealRegController.lang = 'en_CH' ;
        dealRegController.populateAccountInfo();
        dealRegController.getSearchCriteriaList() ;
        dealRegController.getAccountDetails();
        dealRegController.sortListAccounts('name', TRUE);
        dealRegController.sortField1 = 'name';
        dealRegController.sortAscending1 = true;
        dealRegController.runSortAction1(); 
               
        
    }

/* @Method <This method is used create lead for the test class>.   
    @param - <void>  
    @return <Lead> - <Lead record>   
    @throws exception - <No Exception>
*/    
    Static Lead createDealReg(){
        Lead newLead = new lead();
        newLead.lastname = 'Test Lead';
        newLead.company = 'EMC';
        newLead.DealReg_PSC_Owner__c = Userinfo.getUserId();
        newLead.DealReg_Deal_Registration_Status__c = 'New';
        newLead.DealReg_Of_Registration_Products__c = 3;
        newLead.DealReg_Deal_Description__c = 'test';
        newLead.DealReg_Deal_Registration_Justification__c = 'test';
        newLead.Partner__c = createAccount('Test').ID;
        newLead.DealReg_Theater__c = 'EMEA';
        newLead.Channel__c = 'Indirect';
        newLead.City ='India';
        newLead.Street ='Bangalore';
        newLead.DealReg_Deal_Registration__c = true;
        newLead.DealReg_Pre_Sales_Engineer_Name__c = 'Test1';
        newLead.DealReg_Pre_Sales_Engineer_Phone__c = '75964';
        newLead.DealReg_Pre_Sales_Engineer_Email__c = 'test@t.com';
        //Ketan Benegal - Commented the following line for WR 196848. Dt.:01/25/2013
        //newLead.DealReg_EMCTA_Certified_Email__c = 'test@tt.com';
        insert newLead;
        return newLead;
    }
    static Account createAccount(String accountName){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distributor',
            Type = 'Partner' ,
            //PROFILED_ACCOUNT_FLAG__c = true,
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;
        User systemAdminUser = [Select Id,Name from User where Profile.Name ='System Administrator' and IsActive = true limit 1];
        System.RunAs(systemAdminUser){
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.PROFILED_ACCOUNT_FLAG__c = true;
        objAccount.Status__c='A';
        update objAccount;
        }
        System.Debug('objAccount ----> ' + objAccount) ;       
        return objAccount;
    }  
    
   
}