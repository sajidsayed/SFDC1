@istest
/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  14/12/2011      Anil                        Used Custom setting Data Helper
 +=========================================================================================================================*/
class PRM_SP_Search_TC {
  static testmethod void init() {
  User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        } Test.startTest();    
   
   list<CustomSettingDataValueMap__c>  CSlist = new list<CustomSettingDataValueMap__c> ();
   
   CustomSettingDataValueMap__c CSValue = new CustomSettingDataValueMap__c ();
                CSValue.Name ='PRM_SP_Select_Count_Validn';
                CSValue.DataValue__c='5';
        CSlist.add(CSValue);
    
    try {
    
    Database.insert(CSlist, false);
    
    }catch(Exception e){
    
    System.debug('Check Obj Access'+e);
    
    }

    QueueSobject QueueObj =  [ Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q limit 1 ];
                 
    Account a = new Account( Name = 'Test', PROFILED_ACCOUNT_FLAG__c=true , Partner_Type__c  = 'Service Provider',
      Queue_Name__c = QueueObj.Queue.Name ); 
    insert a;
   
    Service_Offering__c SOInvrec = new Service_Offering__c ( Account__c = a.id, Country__c =  'United States',
      EMC_Products__c = 'ATMOS', Service_Offering__c = 'Storage as a Service',SLA__c = 'Best Effort',
      State__c = 'ALL', Theater__c = 'Americas'  );
      
      insert SOInvrec;
      
      Service_Provider_Mapping__c SOMaprec = new Service_Provider_Mapping__c ( Account__c = a.id, 
      Service_Offering__c =  SOInvrec.id );
      
      insert SOMaprec ;
         
      
     PRM_SP_Search sp = new PRM_SP_Search(); 
     list<string> tmp = new list<string> (); 
     
       sp.getServiceOfferingList();
       sp.getProductsList();
       sp.getTheaterList();
       sp.getCountryList();
       sp.getStateList();
       sp.getSLAList();
       sp.ServiceOffering = 'Storage as a Service';
       sp.getProducts();
         tmp.add('ATMOS');
       sp.setProducts(tmp); 
       sp.getTheater();
     //    tmp.clear(); 
     //    tmp.add('--None--');
       sp.setTheater(tmp);
       sp.getCountry();
       sp.setCountry(tmp);
       sp.getSLA();
       sp.setSLA(tmp);
       sp.getState();
     //    tmp.clear(); 
      //   tmp.add('ALL');
       sp.setState(tmp);
       sp.searchClicked();
       sp.LeadGen();
      
     
   
     
       
         for (PRM_SP_Wrapper wrap:  sp.SearchHitList){ 
          wrap.selectx = True;
         }
        
        sp.Company = 'Test 01'; 
        sp.FirstName = 'FirstName Test'; 
        sp.LastName = 'LastName Test'; 
        sp.Phone = '1234567890'; 
        sp.Email = 'abc@abc.com'; 
        sp.Street = 'Street one'; 
        sp.City = 'New York'; 
        sp.LeadState = 'NY'; 
        sp.Zip = '12345'; 
        sp.LeadCountry = 'US'; 
        
        sp.CreateLead();
        
    Test.stopTest();  
  }
}