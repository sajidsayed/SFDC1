/** 
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 18/10/2012    Hemavathi N M   205207  This Test class is used for OpportunityLineItem Operations. When a new product is added to oppty, fields 
                                         on opptylineitem should be updated.      
                      
 +==================================================================================================================**/
@isTest(SeeAllData=true) 
private class Transformation_OpptyProductOperations_TC{
	
 public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<PricebookEntry> pbeLst= new List<PricebookEntry>();
 public Static List<Product2> productLst = new List <Product2>();
 public Static List<OpportunityLineItem> opptyLineItemLst = new List<OpportunityLineItem>();
 
 //Method for Creation Of Account    
    public void createAccount(){
        Account acctObj = new Account();
        acctObj.Name = 'Account Test';
        acctObj.Synergy_Account_Number__c = '123456';
        acctLst.add(acctObj);
        Database.insert(acctLst);
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where Name =:acctLst[0].Name];
     } //end of method Creation Of Account
       
//Method for Creation Of Opportunity
    public void createOpportunity(){
      
       for(Integer i=0;i<3;i++){ 
        Opportunity opp_Obj = new Opportunity();
        if(i==0){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'TEST';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        if(i==1){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Name = 'TEST 1';
          opp_Obj.StageName = 'TEST 1';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        if(i==2){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Name = 'TEST 2';
          opp_Obj.StageName = 'TEST 2';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       //System.debug('lstOpp--->' + lstOpp.size() + '<--->' + lstOpp);
    }  //end of method Creation Of Opportunity
	
	//Method : Create Product
	 public void createProduct(){
	 for(Integer i=0;i<2;i++){ 
	 	Product2 productObj = new Product2();
	 		if(i==0){
	 		productObj.Name = 'PS CONSULTING';
	 		productObj.CurrencyIsoCode = 'USD';
	 		productObj.isActive = true ;
	  		}
	 		if(i==1){
	 		productObj.Name = 'Test Product';
	 		productObj.CurrencyIsoCode = 'USD';
	 		productObj.isActive = true ;
	  		}
	 		productLst.add(productObj);
	 		
	   }// End : For loop
	  Database.insert(productLst);
	  productLst = [select ID,Name from Product2 where Id in:productLst];
	  //System.debug('productLst--->' +productLst.size()+'<--->'+ productLst);	
    } //End : Method - createProduct
    
    public void createPricebookEntry(){
    	List<Pricebook2> pricebook2Obj = [Select id from pricebook2];
    	//System.debug('pricebook2Obj--->' +pricebook2Obj.size()+'<--->'+ pricebook2Obj);
    	for(Integer i=0;i<productLst.size();i++){ 
    	PricebookEntry pricebookObj = new PricebookEntry();
    	pricebookObj.Product2Id =productLst[i].Id;
    	pricebookObj.IsActive =true;
    	pricebookObj.UnitPrice = 0.0;
    	pricebookObj.Pricebook2Id = pricebook2Obj[0].Id;
    	//System.debug('pricebookObj--->' + pricebookObj);
    	pbeLst.add(pricebookObj);
    	} //End : For Loop
      
    	
    	Database.insert(pbeLst);
    	// pbeLst = [select ID,Name from PricebookEntry where Id in:pbeLst];
    	 pbeLst = [Select Id, IsActive , Name from PricebookEntry where Product2Id in : productLst];
	    System.debug('pbeLst--->' + pbeLst.size() + '<---->'+ pbeLst);
    	
    	
    }
    public void createOpptyLineItem(){
    	for(Integer i=0;i<2;i++){ 
    		OpportunityLineItem opptyLinItemObj = new OpportunityLineItem();
    			if(i==0){
    			opptyLinItemObj.OpportunityId = lstOpp[i].id;
    			opptyLinItemObj.PricebookEntryId = pbeLst[i].id;
    			opptyLinItemObj.UnitPrice = 222.00;
    			}
    			if(i==1){
    			opptyLinItemObj.OpportunityId = lstOpp[i].id;
    			opptyLinItemObj.PricebookEntryId = pbeLst[i].id;
    			opptyLinItemObj.UnitPrice = 222.00;
    			}
    			opptyLineItemLst.add(opptyLinItemObj);
    			
    	}//End : For Loop
      Database.insert(opptyLineItemLst);
	  opptyLineItemLst = [SELECT Id,OpportunityId,PricebookEntryId,PricebookEntry.Name,PricebookEntry.Product2Id FROM OpportunityLineItem where Id in:opptyLineItemLst];
	//  System.debug('opptyLineItemLst--->' + opptyLineItemLst.size() + '<--->' + opptyLineItemLst);
	 	for(OpportunityLineItem obj : opptyLineItemLst){ 
    			obj.UnitPrice = 1000.00;
    	}//End : For Loop
		update opptyLineItemLst;
	//  System.debug('opptyLineItemLst1--->' + opptyLineItemLst.size() + '<--->' + opptyLineItemLst);
    
    }// End : Method - createOpptyLineItem
    
//Method to test entry in opptylineitem
    static testMethod void opptyLineItemOperations() { 
      Transformation_OpptyProductOperations_TC testObj = new Transformation_OpptyProductOperations_TC();
      
      //Create Account and Opportunity      
        testObj.createAccount();
        testObj.createOpportunity();
        testObj.createProduct();
        testObj.createPricebookEntry();
        testObj.createOpptyLineItem();
     /*   
      //Update product-----
       List<Product2> product2Lst = new List <Product2>();
       Integer i=0;
       for(Product2 prodObj : productLst)
       {
       	if(i == 0){
       		prodObj.Name = 'PS1'; 
       	}
       	else{
       		 prodObj.Name = 'PS MICROSOFT'; 
       	}
       	i++;
       	/*for(Integer i=0 ;i<2 ; i++){
           if(i==0)
           prodObj.Name = 'PS1'; 
           if(i==1)      
       	   prodObj.Name = 'PS MICROSOFT'; 
         
        }*/
        /*
          product2Lst.add(prodObj);
       }
       update product2Lst;
   
      */  
    }//End : Method opptyLineItemOperations
    
}//End : Class