/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 |  5/09/2012  Leonard V                  Test class for Presales Partner Case
 |  
 |  08/10/2012  Leonard V                 Updated TC to incorporate GBS reelase changes
 | 
 |  10/13/2012  John T                    Added TC for Detailed Product Trigger
 |  18April2013 Ganesh Soma WR#252927     Increased Code Coverage
 +===========================================================================*/

@isTest (SeeAllData=true)

private class PreSales_TC1 {
    public Static List<Case> caseLst = new List<Case>();
    public Static List<Contact> contLst = new List<Contact>();
    public Static List<Account> acctLst = new List<Account>();
    public Static List<Opportunity> oppLst = [Select id, Opportunity_Number__c from Opportunity limit 2];
    public Static List<User> lstUser = [Select Id,email,Country__C,UserRoleId  from user where Profile_Name__c like 'Presales%' and UserRoleId!=null and isActive = true Limit 2];
	public Static List<Presales_Account__c> preAcctLst = new List<Presales_Account__c>(); 
      
  //Method for Creation Of Account    
    public void createAccount(){
       
        System.debug('Inside Account Creation');    
        for (Integer a=0;a<=1;a++ )
        {
        Account acctObj = new Account();
        acctObj.Name = 'PreSalese Partner Testing';
        acctObj.Synergy_Account_Number__c = '123456';
      //acctObj.Theater1__c = 'APJ';
      acctObj.BillingCountry = 'India';
     
            acctLst.add(acctObj);
        }
        
        Database.insert(acctLst);
        System.debug('Account Created'); 


       acctLst = [Select ID,Synergy_Account_Number__c,IsPartner,Theater1__c,BillingCountry  from Account where Name =:acctLst[0].Name];
       system.debug('acctlst------->'+acctLst);

    }

    // Method For Contact Creation
    
     public void createContact(){

         List<RecordType> recList = [ Select Id, Name from RecordType where sObjectType ='Contact' AND Name ='Partner Contact'];
        
       
        for(Integer c=0;c<4;c++){
        Contact contObj = new Contact();
        contObj.LastName = 'Tester';
        contObj.Phone = '999999999';
        contObj.Email = 'test'+c+'@acc.com';
        contObj.RecordTypeId = recList[0].id;
        

        contObj.AccountId = acctLst[0].id;
    
        contLst.add(contObj);
        }

        
        Database.insert(contLst);
        System.debug('Contact Created'); 
        
        contLst = [Select ID,Email,Phone from Contact where id in:contLst];
        System.debug('caseLst----> ' + contLst);
  
      }

    //Method for Creation Of Case
    
    public void createCase(){
        List<Case> lstCase = new List<Case>(); 
        Map<String , Id> recid = new Map<String , Id>();
       
       List<RecordType> recList = [Select id,name from recordtype where name in ('Professional Services Inquiry' , 'vLab Demo') ];

        for(Integer i=1 ; i<=6; i++){
                
                
                Case caseObj_Insert = new Case();
                  //caseObj_Insert.Quote_Number__c = '1234567890';
                if(i<=5){
                caseObj_Insert.Description = 'TEST1';
                caseObj_Insert.Subject = 'TEST1';
                caseObj_Insert.Origin = 'Email';
                
                caseObj_Insert.Type = 'Application RFP Assistance';
                caseObj_Insert.Record_Type_Hidden__c = 'Application RFP Assistance';
                caseObj_Insert.RecordTypeId = recList[0].id;
              
                
                caseObj_Insert.ContactId = contLst[0].id;
                caseObj_Insert.contact_Email1__c   = contLst[0].email;
                }
                else if(i==6){
                        caseObj_Insert.Description = 'VLAB Test';
                        caseObj_Insert.Subject = 'VLAB Test';
                        caseObj_Insert.vLab_Contact_Email__c = contLst[0].email;
                        caseObj_Insert.RecordTypeId = recList[1].id;
                          

                }
        
      
             
                lstCase.add(caseObj_Insert);
        }
        //Case Insertion
           
        Database.insert(lstCase);
        
         
        
     
      
      caseLst =[select ID,LastModifiedDate,status,CreatedDate,Priority,Theatre__C,Country__c,Case_Resolution_Time__c,Partner_Case__c,Partner_Grouping_Name__c,Partner_Country__c,Partner_Theater__c,contact_Email1__c    from Case where id in :lstCase];
      System.debug('caseLst----> ' + caseLst);
    }

  static testMethod  void partnerCase(){
         PreSales_TC1 testObj = new PreSales_TC1();
      
        List<Id> partnerCase = new List<Id>();
         Presales_PartnerCaseOperation partCasOp = new Presales_PartnerCaseOperation();
         List<Account_Groupings__c> grpLst = new List<Account_Groupings__c>();
         
         testObj.createAccount();
         
         for(Integer acc=0 ; acc<acctLst.size() ; acc++){
            
             acctLst[acc].IsPartner = true;

         }
         update acctLst;

     for (Integer grp = 0; grp <=1 ; grp ++ )
        {
            
         Account_Groupings__c grpObj = new Account_Groupings__c();
         if(grp==0)
             grpObj.Profiled_Account__c = acctLst[0].id;
         else
             grpObj.Profiled_Account__c = acctLst[1].id;
        

         grpLst.add(grpObj);
        }

         insert grpLst;

acctLst[0].Grouping__c =grpLst[0].id ;
update acctLst[0];
        
     system.debug('acctLst-****-->'+acctLst);
          testObj.createContact();
         
         test.startTest();

            
       
       
system.debug('grpLst****>' +grpLst);             
         testObj.createCase();


         
       caseLst[0].Partner_Grouping_Name__c = grpLst[1].id;
        caseLst[0].contact_Email1__c = contLst[1].email;

        Presales_PartnerCaseOperation.partnerFlag = false;
         
         update caseLst[0];
     
     
                
                   

        test.stopTest();

 
    }
      static testMethod  void quoteChange(){

          PreSales_TC1 testObj = new PreSales_TC1();
           testObj.createAccount();
           testObj.createContact();
        
            test.StartTest();
            testObj.createCase();

        
            Quote_Custom__c quoteObj = new Quote_Custom__c();

            quoteObj.Number_of_Configurations__c = 12;
            quoteObj.Name = '1234567890';
            quoteObj.Quote_Type__c = 'New';
            quoteObj.Case_Name__c = caseLst[0].id;
          
            insert quoteObj;


            test.StopTest();
      
      
      }
    
      static testMethod  void detailedProductTrigger(){

          PreSales_TC1 testObj = new PreSales_TC1();
           testObj.createAccount();
           testObj.createContact();
        
            test.StartTest();
            testObj.createCase();
            caseLst =[select ID,LastModifiedDate,status,Record_Type_Hidden__c,contact_Email1__c  from Case where id in :caseLst];
        
        
        
    Detailed_Product_Presales__c DP_Insert = new Detailed_Product_Presales__c();
    DP_Insert.Product_Type__c = 'VNX';
    DP_Insert.Product_Bucket__c = 'UNIFIED';
   // DP_Insert.Name = 'CP-999999';
    DP_Insert.CurrencyIsoCode = 'JPY';
    DP_Insert.Case__c = caseLst[0].Id;
    insert(DP_Insert);
    delete(DP_Insert);
  
          test.StopTest();
      
      
      }
      
      
      static testMethod void caseSLA(){
         
	   try{ 
	          
			//Invoking contact creation and Case creation Methods for creating test Data
			PreSales_TC1 testObj = new PreSales_TC1();
			testObj.createAccount();
			testObj.createContact();     
           	//testObj.createAccount();                     
       		lstUser[0].Exception__c = true;
       		lstUser[0].email = contLst[0].Email;
       		lstUser[0].Country__c = 'United States';
       		lstUser[0].Theater__c = 'Global';
       		Database.update(lstUser);
       
        	//Commented by Ganesh on 23jan2013
       		//lstUser = [Select id,Country__C,email from user where id in :lstUser];
       		testObj.createCase();                
        
        	//Creating SLA object and insering a record in to it           
        
         	Test.starttest();                
        	Presales_SLA__c slaObj = new Presales_SLA__c();
        	List<Presales_SLA__c> lstSLA = new List<Presales_SLA__c>();
        	slaObj.Case_Record_Type__c = 'Application RFP Assistance';
        	slaObj.Theater__c = 'Global';
        	slaObj.Priority__c = 'Normal';
        	slaObj.Time_to_resolution__c =20;
        	slaObj.Country__c = 'United States';
        	lstSLA.add(slaObj);
        	Database.insert(lstSLA);
        	//To Check SLA Before Delete 
       		Presales_SLA_Class sla_Obj = new Presales_SLA_Class();
       		sla_Obj.chkSLABeforeDelete(lstSLA);
       		sla_Obj.populateChildData(caseLst,caseLst);    //sla_Obj.populateChildData(lst_case,lst_case);  //Commneted by Ganesh on 23jan2013
       		lstSLA[0].Priority__c = 'Medium';
       		lstSLA[0].Theater__c = 'APJ';
       		update lstSLA;
	   		sla_Obj.presalesStdCaseTime(caseLst, 'Insert'); //sla_Obj.presalesStdCaseTime(lst_case, 'Insert'); //Commneted by Ganesh on 23jan2013
       		sla_Obj.chkUniqueSLAValidation(lstSLA , 'Insert');                    
       		delete lstSLA;
         
   			Test.stoptest();
	            
	   } catch (System.DmlException e){
	           System.debug('DML exception: ' + e.getDmlMessage(0));   
	   }
      }
	   
	   static testMethod void RelatedOpportunityTriggerCoverage(){
         
	   try{ 
	          
			//Invoking contact creation and Case creation Methods for creating test Data
			PreSales_TC1 testObj = new PreSales_TC1();
			testObj.createAccount();
			testObj.createContact();     
           	testObj.createCase();                
         	Test.starttest();                
        	Related_Opportunity__c obj = new Related_Opportunity__c();
        	obj.Case__c =  caseLst[0].Id;
        	insert obj;
   			Test.stoptest();
	            
	   } catch (System.DmlException e){
	           System.debug('DML exception: ' + e.getDmlMessage(0));   
	   }
                         
     }
     
     static testMethod  void insertPresalesAccountTest(){
        PreSales_TC1 testObj = new PreSales_TC1();
        System.debug('Inside Account Creation');    

      	test.startTest();
      	testObj.createAccount();
      	Presales_Account_Operation presalesAccountOperation = new Presales_Account_Operation();
      	presalesAccountOperation.insertPresalesAccount(acctLst);
      	//preAcctLst = [SELECT Accountid__c, Account_Name__c, Name, Id, CurrencyIsoCode, SystemModstamp, IsDeleted FROM Presales_Account__c where Accountid__c =: acctLst[0].Id]; 
      	//System.assert(preAcctLst[0].Name != '123456');
      	test.stopTest();
        
        
 
     }
     static testMethod  void updatePresalesAccountTest(){
        PreSales_TC1 testObj = new PreSales_TC1();

      	test.startTest();
      	testObj.createAccount();
      	Presales_Account_Operation presalesAccountOperation = new Presales_Account_Operation();
      	presalesAccountOperation.updatePresalesAccount(acctLst);
      	//preAcctLst = [SELECT Accountid__c, Account_Name__c, Name, Id, CurrencyIsoCode, SystemModstamp, IsDeleted FROM Presales_Account__c where Accountid__c =: acctLst[0].Id]; 
      	//System.assert(preAcctLst[0].Name != '123456');
      	test.stopTest();
        
        
 
     }

    
}