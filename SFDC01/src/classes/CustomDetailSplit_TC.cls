/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  27.01.2011      Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary ISV & Infrastructure" & "Primary Outsourcer & Integrator".
 |  
 +===========================================================================*/

@isTest
private class CustomDetailSplit_TC{
public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp  = new List<Opportunity>();
 public Static Opportunity Oppty= new Opportunity();
//Method for Creation Of Account    
    public void createAccount(){
     for(Integer i=0;i<2;i++){
     Account acctObj = new Account();
        acctObj.Name = 'Test'+i;
        if(i==0){
        acctObj.Partner_Type__c='ISV';}
        else{
        acctObj.Partner_Type__c='Outsourcer';}
        acctLst.add(acctObj);
        }
    insert acctLst;
        System.debug('Account Created'); 
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where id in: acctLst];
     } //end of method Creation Of Account
       
//Method for Creation Of Opportunity
    public void createOpportunity(){
      
       List<User> lstUser = [Select id from user where IsActive = true limit 4];
        
    //Opportunity Oppty = new Opportunity();
        Date closeDate = date.today()+15;
        
        Date approvalDate = date.newinstance(2014, 11, 1);
        Date expirationDate = date.newinstance(2015, 11, 18);
       
        Oppty.AccountId =acctLst[0].id;
          Oppty.Opportunity_Owner__c = lstUser[1].id;
          Oppty.Name = 'TEST 1';
          Oppty.Opportunity_Number__c='767672';
                   
        Oppty.Sales_Channel__c = 'Direct';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate;
        Oppty.AccountId=acctLst[0].Id;
        Oppty.Amount=75900;
       
        insert Oppty;
       
              lstOpp =[select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id =: Oppty.Id];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }  //end of method Creation Of Opportunity
   
public void createOpportunityLineItem(){  
PricebookEntry pricebook=[Select Id from PricebookEntry where IsActive=true and CurrencyIsoCode='USD'limit 1];
    OpportunityLineItem opptyLineItem= new OpportunityLineItem();
    opptyLineItem.OpportunityId=Oppty.Id;
    opptyLineItem.Quantity=5;
    opptyLineItem.Quote_Amount__c=5000;
    opptyLineItem.PricebookEntryId=pricebook.Id;
    insert opptyLineItem;

} 
    

public static testMethod void TestCustomDetailSplits(){
CustomDetailSplit_TC testObj = new CustomDetailSplit_TC();
  Test.startTest();
testObj.createAccount();
testObj.createOpportunity();
//testObj.createOpportunityLineItem(); 
 
 User[] DirectUs=[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c='Direct' and IsActive=true  limit 5];
 User[] NonDirectUs=[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c!='Direct' and IsActive=true limit 5];
 PageReference pageRef = Page.AddTeamsAndProducts;
    Test.setCurrentPage(pageRef);  
    ApexPages.currentpage().getParameters().put('id',Oppty.id);
    ApexPages.currentpage().getParameters().put('message','Changes Saved');
    ApexPages.currentpage().getParameters().put('selectedTab','salesteam');
    ApexPages.currentPage().getParameters().put('selectedTab','Split');
    
    CustomDetailSplit controller= new CustomDetailSplit(new ApexPages.StandardController(Oppty));
   // CustomDetailSplit controller2= new CustomDetailSplit(new ApexPages.StandardController(Oppty));
  //  CustomDetailSplit controller3= new CustomDetailSplit(new ApexPages.StandardController(Oppty));
    controller.init();
    OpportunityTeamMember opptyTeamMember1= new OpportunityTeamMember();
    opptyTeamMember1.OpportunityId=Oppty.Id;
    opptyTeamMember1.TeamMemberRole='BURA-SALES REP';
    opptyTeamMember1.UserId=DirectUs[0].Id;
    insert opptyTeamMember1;
    List<SalesTeamMember> salesTeam=controller.getSalesTeam();
    controller.addSalesTeamMember();
    For(salesTeamMember stm:salesteam){
        System.debug('controller.salesTeam1'+stm);
        if(stm.detailSplit != null){
        stm.detailSplit.Split__c = 10;
        stm.detailSplit.Opportunity_Access_Level__c='All';
        stm.detailSplit.OwnerId =null;
        }
            stm.Selected = false;
            stm.ProductForecast = true;
    }
            if(salesTeam[0].detailSplit != null){
            salesTeam[0].detailSplit.Split__c = null; 
            salesTeam[0].detailSplit.Opportunity_Access_Level__c='None';
            
            
            }
            salesTeam[0].Selected = false;
            //testObj.createOpportunityLineItem();
            salesTeam[0].ProductForecast = false;
           
      delete salesTeam[0].opptyTeamMember;
    
     
    controller.initNewMember();
  //  controller.getdetailSplitTeam();
    controller.radioOwnerSelected = salesTeam[0].opptyTeamMember.UserId;
    controller.isOwnerRead = false;
    controller.getOpptyAccess();
    controller.doSave();
    controller.setRadioOwnerSelected(opptyTeamMember1.UserId);
    controller.getRadioOwnerSelected();
    controller.getRemoveNullUser();
    controller.setRemoveNullUser('test');
     
    controller.setSalesTeam(salesTeam);
    controller.cancel();
    controller.opptyDoesNotExist();
    controller.getsplitExceeding();
     testObj.createOpportunityLineItem(); 
    CustomDetailSplit controller2= new CustomDetailSplit(new ApexPages.StandardController(Oppty));
     List<SalesTeamMember> salesTeam1=controller2.getSalesTeam();
     controller2.init();
    controller2.addSalesTeamMember();
       For(salesTeamMember stm:salesTeam1){
       stm.selected = true;
       
       }
    controller2.doSave();
    
    
    
 Test.stopTest();
}}