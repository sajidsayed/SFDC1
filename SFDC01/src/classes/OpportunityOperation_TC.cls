/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                               Initial Creation.
 |  27.01.2011      Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary ISV & Infrastructure" & "Primary Outsourcer & Integrator".
 |  28.11.2011      Shipra Misra    182358      Test class failing on production validation.
 |  02.03.2011      Shipra Misra    182358      Test class failing on production validation March Release.
 +===========================================================================*/
@isTest
private class OpportunityOperation_TC{
    public static testMethod void opportunityOperation() 
    {   
         List<Account> lstaccount = new List<Account>();
        Account account1 = new Account();
        account1.name = 'Test';
        account1.Partner_Type__c='ISV';
        lstaccount.add(account1);
        
        Account account2 = new Account();
        account2.name = 'Test2 ';
        account2.Partner_Type__c='Outsourcer';
        lstaccount.add(account2);
        
        insert lstaccount;
        Opportunity Oppty = new Opportunity();
        Oppty.AccountId = account1.Id;
        Date closeDate = date.today()+15;
        Date approvalDate = date.today();
        Date expirationDate = date.today()+30;
        Oppty.Name = 'Test Oppty';
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
        Oppty.Expiration_Date__c=expirationDate ;
        // 24/5/2011 Changed for VF rules - Srinivas Nallapati
        //Oppty.Primary_Outsourcer_System_Integrator__c=account2.id;
        //Oppty.Primary_ISV_Infrastructure__c=account1.id;
        //Oppty.Outsourcer_System_Integrator_involved__c = false;
        //Oppty.ISV_Infrastructure_involved__c = false;
        /**/
        insert Oppty;
         
        Opportunity Oppty02 = new Opportunity(Id=Oppty.id);
        Date closedDate = date.today()+15;
        Date approvedDate = date.newinstance(2010, 11, 1);
        Date expirationDate1 = date.newinstance(2010, 11, 18);
        Oppty02.StageName = 'Upside';
        Oppty02.Closed_Reason__c = 'No Loss';
        Oppty02.Close_Comments__c = 'Lost';
        Oppty02.Sell_Relationship__c = 'OEM';
        Oppty02.CloseDate = closedDate;
        Oppty02.Quote_Version__c='v14';
        Oppty02.Quote_Type__c='Old';
        Oppty02.Approval_Date__c=approvedDate ;
        Oppty02.Expiration_Date__c=expirationDate1 ;
        // 24/5/2011 Changed for VF rules - Srinivas Nallapati
        //Oppty02.Outsourcer_System_Integrator_involved__c = false;
        //Oppty02.ISV_Infrastructure_involved__c = false;
        /**/
        update Oppty02;
        
        Map<Id,Opportunity> OldOppty = new Map<Id,Opportunity>();
        OldOppty.put(Oppty.id,Oppty);
        
        Map<Id,Opportunity> NewOppty = new Map<Id,Opportunity>();
        NewOppty.put(Oppty02.id,Oppty02);   
        
        PricebookEntry priceBook = [Select p.Id, p.IsActive from PricebookEntry p where p.IsActive = true and p.CurrencyIsoCode='USD' and Product2.IsActive=true limit 1];
        
        OpportunityLineItem OpptyLineItem = new OpportunityLineItem();
        OpptyLineItem.Quote_Amount__c = 2000;
        OpptyLineItem.OpportunityId = Oppty.id;
        OpptyLineItem.PricebookEntryId = priceBook.id;
        insert OpptyLineItem;
        
        OpportunityLineItem OpptyLineItem02 = new OpportunityLineItem(Id=OpptyLineItem.id);
        OpptyLineItem02.Quote_Amount__c = 4000;
        update OpptyLineItem02;
        
        Map<Id,OpportunityLineItem> OldOpptyLineItem = new Map<Id,OpportunityLineItem>();
        OldOpptyLineItem.put(OpptyLineItem.id,OpptyLineItem);
        
        Map<Id,OpportunityLineItem> NewOpptyLineItem = new Map<Id,OpportunityLineItem>();
        NewOpptyLineItem.put(OpptyLineItem02.id,OpptyLineItem02);
                 
       test.starttest();
        OpportunityOperation OpptyOperation = new OpportunityOperation();
        OpptyOperation.checkOpportunityUpdates(NewOppty ,OldOppty);
        OpptyOperation.checkOpportunityLineItemUpdates(NewOpptyLineItem,OldOpptyLineItem );
        
        OpportunityDetails opptyDetail = OpportunityOperation.getSFDCOpportunity(Oppty.id);
        List<OpportunityDetails> opptyDetailsList = new List<OpportunityDetails>();
        opptyDetailsList.add(opptyDetail);
        
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList,'Create');
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList,'Update');
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList,'Submit To Order');
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList,'Udpate Create Opportunity Status');
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList,'Udpate Create Quote Status');
               test.stoptest();
    
    }
    
    public static testMethod void opportunityOperation01() 
    {
        Opportunity Oppty01 = [Select o.AccountId, o.CloseDate, o.Id from Opportunity o  where o.CloseDate > today limit 1];
        
        OpportunityDetails opptyDetail01 = OpportunityOperation.getSFDCOpportunity(Oppty01.id);
        List<OpportunityDetails> opptyDetailsList01 = new List<OpportunityDetails>();
        opptyDetailsList01.add(opptyDetail01);
        test.starttest();
        OpportunityOperation.synchronizeOpportunity(opptyDetailsList01,'test');
        test.stoptest();
    }
}