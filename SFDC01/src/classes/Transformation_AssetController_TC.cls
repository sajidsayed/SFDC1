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
 |  17/01/2013    Medhavi D.   217883      This Test class is used for Pricing Requests Sharing 
 +==================================================================================================================**/

 @isTest(SeeAllData=true) 
private class Transformation_AssetController_TC {

 public Static List<Account> acctLst = new List<Account>();
  public Static List<Account> acctLst1 = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<Asset__c> listAsset = new List<Asset__c>();
 public static List<Opportunity_Asset_Junction__c> listOprAsset = new List<Opportunity_Asset_Junction__c>();

 //Method for Creation Of Account    
    public void createAccount(){
     Account acctObj = new Account();
        acctObj.Name = 'Testing';
        acctObj.Synergy_Account_Number__c = '123456';
        acctObj.Customer_Profiled_Account__c=true;
        acctObj.Lead_Oppty_Enabled__c=true;
        acctObj.Model__c='Open';
        acctLst.add(acctObj);
        
        Database.insert(acctLst);
       
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where Name =:acctLst[0].Name];
        System.debug('acctLst ---1--'+acctLst );
        Account acctObj1 = new Account();
        acctObj1.Name = 'Testing 1';
        acctObj1.Synergy_Account_Number__c = '123456';
       // acctObj1.Customer_Profiled_Account_Lookup__c=acctLst[0].Id;
        acctObj1.Lead_Oppty_Enabled__c=true;
        acctObj1.Model__c='Open';
        acctLst1.add(acctObj1);
        Database.insert(acctLst1);
        acctLst1 = [Select ID,Customer_Profiled_Account_Lookup__c,Synergy_Account_Number__c  from Account where Name =:acctLst1[0].Name];
               System.debug('acctLst ---2--'+acctLst1 );
        
     } //end of method Creation Of Account
       
//Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ','EMEA')limit 4];
       for(Integer i=0;i<3;i++){ 
         Opportunity opp_Obj = new Opportunity();
        if(i==0){  
          opp_Obj.AccountId =acctLst1[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[0].id;
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'Pipeline';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          //opp_Obj.Account_Owner_Division__c='Europe South';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        if(i==1){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[0].id;
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'Booked';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          //opp_Obj.Account_Owner_Division__c='Europe South';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        if(i==2){  
          opp_Obj.AccountId =acctLst1[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[2].id;
          opp_Obj.Name = 'TEST 2';
          opp_Obj.StageName = 'Closed';
          opp_Obj.Close_Comments__c ='Closed Test';
          opp_Obj.Closed_Reason__c ='Chose Incumbent';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
          lstOpp.add(opp_Obj);
        }
        
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c ,AccountId,Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }  //end of method Creation Of Opportunity
            
//Method for creation of Assets  
    public void createAsset(){
    RecordType rectype = [Select r.Id, r.name from RecordType r where r.name =: 'EMC Install' limit 1];
    List<Asset__c> lstAsset = new List<Asset__c>();
    
    for(Integer i=0;i<3;i++){   
      Asset__c asset_Obj = new Asset__c();
      if(i==0){
      asset_Obj.Customer_Name__c = acctLst1[0].id;
      asset_Obj.Disposition_Status__c ='Installed';
      lstAsset.add(asset_Obj);
      }
      if(i==2){
      asset_Obj.Customer_Name__c = acctLst1[0].id;
      asset_Obj.Disposition_Status__c ='Installed';
      lstAsset.add(asset_Obj);
      }
      if(i==1){
      asset_Obj.customer_Name__c = acctLst[0].id;
      asset_Obj.Disposition_Status__c ='Installed';
      asset_Obj.RecordTypeId = rectype.Id;
      lstAsset.add(asset_Obj);
      }
     }
     Database.insert(lstAsset);
     
      listAsset =[Select Id ,Customer_Name__r.Customer_Profiled_Account_Lookup__c,Custom_Asset_Name__c,Serial_Number__c,Name,Disposition_Status__c ,Account_Record_Type__c ,RecordType.Name ,Product_Name_Vendor__c,Product_Family__c,Customer_Name__c,Contract_Number__c 
        from Asset__c where Disposition_Status__c='Installed' and Id in : lstAsset];
      
  } ///end of method Creation Of Pricing Requests 
  public void createOpptyAssets(){
  Opportunity_Asset_Junction__c opptyAssetObj = new Opportunity_Asset_Junction__c();
  
  opptyAssetObj.Related_Asset__c =listAsset[0].Id;
  opptyAssetObj.Related_Opportunity__c=lstOpp[0].Id;
  insert opptyAssetObj;
  
  listOprAsset =[Select Id from Opportunity_Asset_Junction__c where  Id =: opptyAssetObj.Id];
  }
 
//Method to test Asset Object
    static testMethod void linkControllerTest() { 
      Transformation_AssetController_TC testObj = new Transformation_AssetController_TC();
      Transformation_AssetMassLinkController controlObj= new Transformation_AssetMassLinkController();
      
      //Create Account and Opportunity    
      User usrData = [Select id from User where Id = :UserInfo.getUserId()];
     System.RunAs(usrData)
     {  acctLst.clear();
        acctLst1.Clear();
        lstOpp.Clear();
        listAsset.Clear();
        testObj.createAccount();
        testObj.createOpportunity();
        testObj.createAsset();
       }
        Test.startTest();
          //Setting Apex values and assinging values to the controller
           
                for(Integer i=0;i<3;i++){
                if(i==0){
                Test.setCurrentPageReference(new PageReference('flag=0'+acctLst[0].id)); 
                 Transformation_AssetMassLinkController controlOb = new Transformation_AssetMassLinkController(new ApexPages.StandardController(acctLst[0]));
                 List<Transformation_AssetMassLinkController.assWrapper> wrapObj = controlOb.getAssetsDetails();
                 wrapObj[0].Selected = true;
             //    wrapObj[1].Selected = false;
                 controlOb.getAssetsDetails();
                 controlOb.getselectedAssets();
                 controlOb.processSelected();
                 controlOb.SelectedRecord();
                 controlOb.linkAssest();

                
                }
                if(i==3){
                Test.setCurrentPageReference(new PageReference('flag=0'+acctLst1[0].id)); 
                 Transformation_AssetMassLinkController controlOb = new Transformation_AssetMassLinkController(new ApexPages.StandardController(acctLst1[0]));
                 List<Transformation_AssetMassLinkController.assWrapper> wrapObj = controlOb.getAssetsDetails();
                 wrapObj[0].Selected = true;
              //   wrapObj[1].Selected = false;
                 controlOb.getAssetsDetails();
                 controlOb.getselectedAssets();
                 controlOb.processSelected();
                 controlOb.SelectedRecord();
                 controlOb.linkAssest();

                
                }
                if(i==1){
                PageReference acctPage = new PageReference('/apex/Transformation_AssertMassLink?opportunityId='+lstOpp[1].id+'&accId='+listAsset[0].Customer_Name__c);
                 Test.setCurrentPage(acctPage);
                 System.debug('acctPage -->'+acctPage); 
                 Transformation_AssetMassLinkController controlOb = new Transformation_AssetMassLinkController(new ApexPages.StandardController(acctLst1[0]));
                 controlOb.linkAssest();
                              
                }
                if(i==2){
                PageReference acctPage = new PageReference('/apex/Transformation_AssertMassLink?opportunityId='+lstOpp[2].id+'&accId='+listAsset[1].Customer_Name__c);
                 Test.setCurrentPage(acctPage);
                 System.debug('acctPage -->'+acctPage); 
                 Transformation_AssetMassLinkController controlOb = new Transformation_AssetMassLinkController(new ApexPages.StandardController(acctLst[0]));
                 controlOb.linkAssest();
                              
                }
                
               }
               ApexPages.currentPage().getParameters().put('ObjectiveEditId',listAsset[0].Id);
               controlObj.EditRecord();
               controlObj.cancelLink();
               ApexPages.currentPage().getParameters().put('ObjectiveDeleteId',listAsset[0].Id);
               controlObj.DeleteRecord();
             
               
               
                
        Test.stopTest();
    
   } // end of method
 
 
 //Test method for Transformation_LinkAssetsController
 static testMethod void linkAssetsControllerTest() {
      Transformation_AssetController_TC testObj = new Transformation_AssetController_TC();

      //Create Account and Opportunity    
      User usrData = [Select id from User where Id = :UserInfo.getUserId()];
      System.RunAs(usrData)
      {  
        testObj.createAccount();
        testObj.createOpportunity();
        testObj.createAsset();
        testObj.createOpptyAssets();
        Transformation_AssetList__c mycs = Transformation_AssetList__c.getValues(listAsset[0].Id);
  
          if(mycs == null) {
            mycs = new  Transformation_AssetList__c();
            mycs.Name =listAsset[0].Id;
            insert mycs;
          }
       }
        Test.startTest();
        for(Integer k=0 ;K<3;k++){
        if(k==0){
        Apexpages.currentPage().getParameters().put('selOppty','Test*');
        Apexpages.currentPage().getParameters().put('selAcId','['+acctLst[0].Id+']');
        Apexpages.currentPage().getParameters().put('selAcc','');
        Transformation_LinkAssetsController lintAssertController1= new Transformation_LinkAssetsController();
        }
        if(k==1){
        Apexpages.currentPage().getParameters().put('selOppty','Test%');
        Apexpages.currentPage().getParameters().put('selAcId','['+acctLst1[0].Id+']');
        Apexpages.currentPage().getParameters().put('selAcc','['+lstOpp[0].AccountId+']');
        Transformation_LinkAssetsController lintAssertController2= new Transformation_LinkAssetsController();
        lintAssertController2.clearData();
        }
        if(k==2){
        Apexpages.currentPage().getParameters().put('selOppty','');
        Apexpages.currentPage().getParameters().put('selAcc','['+acctLst[0].Id+']');
        
        Apexpages.currentPage().getParameters().put('retURL','/?OpportunityId='+lstOpp[0].Id);    
        Transformation_LinkAssetsController lintAssertController3= new Transformation_LinkAssetsController();
      
        }
        
        }
        System.debug('listAsset--->'+ listAsset );
         List <Asset__c>listAsset2 =[Select Id from Asset__c where Disposition_Status__c='Installed' and Id =: listAsset[1].Id ];
        for(Integer i=0;i<3;i++){
        if(i==0){
       
         ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsset);
         PageReference acctPage = new PageReference('/apex/Transformation_LinkAssets?retURL=?opportunityId='+lstOpp[i].id+'&selAcId='+lstOpp[i].AccountId);
         Test.setCurrentPage(acctPage);
        
         Transformation_LinkAssetsController controlLinkAsset= new Transformation_LinkAssetsController(setCon );
         controlLinkAsset.linkAssets();
     
         }
         if(i==2){
          ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsset2);
          setCon.setSelected(listAsset2);
         PageReference acctPage = new PageReference('/apex/Transformation_LinkAssets?retURL=?opportunityId='+lstOpp[i].id+'&selAcc='+lstOpp[i].AccountId);
         Test.setCurrentPage(acctPage);
         
         Transformation_LinkAssetsController controlLinkAsset1= new Transformation_LinkAssetsController(setCon );
         controlLinkAsset1.linkAssets();
        
         }
         if(i==1){
        
         ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsset);
         setCon.setSelected(listAsset);
         PageReference acctPage = new PageReference('/apex/Transformation_LinkAssets?retURL=?opportunityId='+lstOpp[i].id);
         Test.setCurrentPage(acctPage);
         Transformation_LinkAssetsController controlLinkAsset2= new Transformation_LinkAssetsController(setCon );
         controlLinkAsset2.linkAssets();
         controlLinkAsset2.cancelLink();
              
         }
         
         
         }
         if(listOprAsset.size() >0){
         delete listOprAsset;
         }
     //   lintAssertController.clearData();
        Test.stopTest();
    }
   
  
}//end of classt