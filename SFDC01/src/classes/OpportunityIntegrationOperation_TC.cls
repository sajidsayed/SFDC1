/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  27.01.2011      Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary ISV & Infrastructure" & "Primary Outsourcer & Integrator".
 |  09.01.2013      Medhavi D.      222446      Updated test class to cover 90% and Feb release changes
 |  09.04.2013		Uday            246616      Fixed test class error.
 +===========================================================================*/
@isTest
private class OpportunityIntegrationOperation_TC{ 
 public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public static Integer loopLimit= 5;
 public static List<OpportunityDetails> OppDetails=new List<OpportunityDetails>();
 
//Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ','EMEA')and Division__c not in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A')limit :loopLimit];
       for(Integer k=0;k<loopLimit;k++){
        Opportunity opp_Obj = new Opportunity();
          opp_Obj.AccountId =acctLst[k].id;
          opp_Obj.Opportunity_Owner__c = lstUser[k].id;
          opp_Obj.Deal_Lead__c=lstUser[k].id;
          opp_Obj.ownerId=lstUser[k].id;
          opp_Obj.Name = 'TEST'+ k;
          opp_Obj.StageName = 'Test';
          opp_Obj.Quote_Created_by__c = 'Test';
          opp_Obj.HW_TLA_Start_Date__c = Date.today();
          if(k==0){
             opp_Obj.StageName = 'Pipeline';
          }
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c ,StageName, Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
    }  //end of method Creation Of Opportunity
    
    //Method for Creation Of Account    
    public void createAccount(){
    List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ','EMEA')limit :loopLimit];  
     for(Integer k=0;k<loopLimit;k++){
        Account accObj1 = new Account();
        accObj1.name = 'TestAccount'+ k;
        accObj1.ownerId=lstUser[k].id;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        acctLst.add(accObj1);
        }
        Database.insert(acctLst);
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where id in:acctLst];
     } //end of method Creation Of Account
    
    
    //Method for creation of Oppty Line Item
public void createOpptyLineItem(){
        
        PricebookEntry pricebook=[Select Id from PricebookEntry where IsActive=true and CurrencyIsoCode='USD'limit 1];

        List<OpportunityLineItem> opptyLineItem= new List<OpportunityLineItem>();
    
          for(Integer k=0;k<5;k++){
            OpportunityLineItem opptyLineItem1= new OpportunityLineItem();
           
                opptyLineItem1.OpportunityId=lstOpp[k].id;
                opptyLineItem1.Quantity=5;
                opptyLineItem1.Quote_Amount__c=5000;
                opptyLineItem1.PricebookEntryId=pricebook.Id;
                opptyLineItem.add(opptyLineItem1);
           
             }
           Database.insert (opptyLineItem,false);
  }
    
    //Method for cretaion of teammemebr
    public void createOpptyTeamMember(){
         User DirectUs=[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c='Direct' limit 1];
         List<OpportunityTeamMember> listOpptyTeamMember= new List<OpportunityTeamMember>();
         for(Integer k=0;k<2;k++){
                OpportunityTeamMember opptyTeamMember= new OpportunityTeamMember();
                opptyTeamMember.OpportunityId=lstOpp[k].id;
                opptyTeamMember.TeamMemberRole='BURA-SALES REP';
                opptyTeamMember.UserId=DirectUs.id;
                listOpptyTeamMember.add(opptyTeamMember);
           }
        insert listOpptyTeamMember;
    }
    
    
    //Method to create OpptyDetails
    public void createOpptyDetails(){
        
        for(Integer k=0;k<1;k++){
            OpportunityDetails createOpportunity=new OpportunityDetails(lstOpp[k].id);
            createOpportunity.POpptyHeaderBo.OracleOppId='9896148285';
            createOpportunity.POpptyHeaderBo.SFDCOPPTYID=lstOpp[k].id;
            createOpportunity.POpptyHeaderBo.QuoteNumber='123';
            createOpportunity.POpptyHeaderBo.Status='Submitted';
             OppDetails.add(createOpportunity);
          }
    
            OpportunityDetails createOpportunity3=new OpportunityDetails(lstOpp[0].id);
            createOpportunity3.POpptyHeaderBo.OracleOppId='';
            createOpportunity3.POpptyHeaderBo.SFDCOPPTYID='';
            createOpportunity3.POpptyHeaderBo.QuoteNumber='133';
            createOpportunity3.POpptyHeaderBo.Status='Commit';
            OppDetails.add(createOpportunity3);
            
            OpportunityDetails createOpportunity4=new OpportunityDetails(lstOpp[0].id);
            createOpportunity4.POpptyHeaderBo.OracleOppId='89562';
            createOpportunity4.POpptyHeaderBo.SFDCOPPTYID='';
            createOpportunity4.POpptyHeaderBo.QuoteNumber='';
            createOpportunity4.POpptyHeaderBo.Status='Eval';
            OppDetails.add(createOpportunity4);
            
        }
    

static testMethod void runcreateOpportunities() {
        OpportunityIntegrationOperation_TC testObj = new OpportunityIntegrationOperation_TC();
        List<Opportunity> testClassOpp=new List<Opportunity>();
        List<Id> opptyId = new List<Id>();
         //Feb release start
            testObj.createAccount();
            testObj.createOpportunity();
            testObj.createOpptyLineItem();
            testObj.createOpptyTeamMember();
            testObj.createOpptyDetails();
            System.debug('OppDetails--->'+OppDetails);
         //Feb release end
        
        OpportunityIntegrationOperation OppIntOperation =new OpportunityIntegrationOperation();
 
        OppIntOperation.createOpportunities(OppDetails);
        OppIntOperation.udpateCreateOpportunityStatus(OppDetails[0]);
        OppIntOperation.udpateCreateQuoteStatus(OppDetails[0]);
        
    }//End of method
    
    
    static testMethod void runUpdateeOpportunities() {
        OpportunityIntegrationOperation_TC testObj = new OpportunityIntegrationOperation_TC();
        List<Opportunity> testClassOpp=new List<Opportunity>();
        List<Id> opptyId = new List<Id>();
         //Feb release start
            testObj.createAccount();
            testObj.createOpportunity();
            testObj.createOpptyLineItem();
            testObj.createOpptyTeamMember();
            testObj.createOpptyDetails();
         //Feb release end
        
        OpportunityIntegrationOperation OppIntOperationUpdate =new OpportunityIntegrationOperation();
        OppIntOperationUpdate.updateOpportunities(OppDetails);
        
    }//End of method
    
}//End of class