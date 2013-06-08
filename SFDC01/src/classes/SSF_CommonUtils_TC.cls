/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  27.01.2011      Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary ISV & Infrastructure" & "Primary Outsourcer & Integrator".
 |  10.10.2011      Shipra Misra    175023      Updated test class failing on Production validation. 
 +===========================================================================*/
@isTest
Private class SSF_CommonUtils_TC {
    private static List<Account> lstAcct=new List<Account>();
    
    Private static testmethod void testCustomSSFSplits(){
        //Test.startTest();
        List<User> usrList = new List<User>([Select Id,Forecast_Group__c,IsActive from User where Forecast_Group__c='Direct' and IsActive = true limit 2]);// = createDirectRepUsers();
        //Test.stopTest();
        
        User owner = usrList[0];
        User usr = usrList[1];
        Opportunity oppty = createOpportunity(owner.Id);
        
        List<OpportunityTeamMember> teamMbrList; 
        List<Detail_Line__c> detailList;
        
        teamMbrList = [select Id,UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^ '+teamMbrList);
        //System.assert(teamMbrList.size()==1);

        List<OpportunityLineItem> lineItemsOrig = createOpportunityProducts(oppty.Id);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        lineItems.add(lineItemsOrig[0]);
        insert lineItems;
        System.debug('####################################################');
        //Added on 10.10.2011 by Shipra.
        Test.startTest();
        OP_SSF_CommonUtilsInterface utils = OP_SSF_CommonUtils.getInstance();

        OpportunityTeamMember opptyTeamMbr = new OpportunityTeamMember(OpportunityId=oppty.Id,UserId=usr.Id);
        Detail_Line__c detail = new Detail_Line__c(Forecast_Group__c=usr.Forecast_Group__c,Opportunity_Access_Level__c='Edit');
        SalesTeamMember teamMbr = new SalesTeamMember(false,opptyTeamMbr);
        teamMbr.opptyTeamMember.user = usr;
        teamMbr.detailSplit = detail;
        List<SalesTeamMember> tempList = new List<SalesTeamMember>(); 
        tempList.add(teamMbr);
        utils.addSalesTeamMembers(tempList);
        detailList = [  select Id,OwnerId,Split__c,Forecast_Group__c 
                        from Detail_Line__c where Opportunity__c=:oppty.Id
                        and OwnerId=:usr.Id];
        system.debug('Created details size '+detailList.size()+'---'+detailList);                
        //System.assert(detailList.size()==1);    
        //Check if Split defaults to 0%
        //System.assert(detailList[0].Split__c!=0.0); 

        teamMbr.detailSplit.Split__c=80.0;
        utils.updateSplits(tempList);

        detailList = [  select Id,OwnerId,Split__c,Forecast_Group__c 
                        from Detail_Line__c where Opportunity__c=:oppty.Id
                        and OwnerId=:usr.Id];

        //System.assert(detailList[0].Split__c==80.0) ;

        List<OpportunityLineItem> lineItems2 = new List<OpportunityLineItem>();
        lineItems2.add(lineItemsOrig[1]);
        lineItems2.add(lineItemsOrig[2]);
        insert lineItems2;

        detailList = [  select Id,OwnerId,Split__c,Forecast_Group__c 
                        from Detail_Line__c where Opportunity__c=:oppty.Id
                        and OwnerId=:usr.Id];

        //Change owner to direct and don't update oppty
        Map<Id,Id> ownerMap = new Map<Id,Id>();
        ownerMap.put(oppty.Id,usr.Id);
        utils.changeOwner(ownerMap,false);
        oppty = [select Id,OwnerId from Opportunity where Id=:oppty.Id];
        //System.assert(oppty.OwnerId==owner.Id);
        //Change owner to direct and update oppty
        utils.changeOwner(ownerMap,true);
        //oppty = [select Id,OwnerId from Opportunity where Id=:oppty.Id];
        //System.assert(oppty.OwnerId==usr.Id);
        Test.stopTest();
        //Ensure no new detail line got added
        detailList = [  select Id,OwnerId,Split__c,Forecast_Group__c 
                        from Detail_Line__c where Opportunity__c=:oppty.Id
                        and OwnerId=:usr.Id];
        //System.assert(detailList.size()==3);

        //Set Sales Team members
        List<SalesTeamMember> slsTeam = utils.getSalesTeamMembers(oppty.Id);
        //System.assert(slsTeam.size()==2);
        

        List<OpportunityTeamMember> lstOpptyTeamMbr = new List<OpportunityTeamMember>();
        lstOpptyTeamMbr = [    select Id,OpportunityId,UserId 
                            from OpportunityTeamMember
                            where OpportunityId=:oppty.Id
                            and UserId = :owner.Id limit 1];
        
        if(lstOpptyTeamMbr != null && lstOpptyTeamMbr.size() > 0)
            opptyTeamMbr = lstOpptyTeamMbr.get(0);
        
        if(opptyTeamMbr != null)
        {
            teamMbr = new SalesTeamMember(false,opptyTeamMbr);
            tempList = new List<SalesTeamMember>(); 
            tempList.add(teamMbr);
            utils.removeSalesTeamMembers(tempList);
        } 
    }

    Private static testmethod void testCustomSSFNonDirect(){
        //List<User> usrList = createDirectRepUsers();
        List<User> usrList = new List<User>([Select Id,Forecast_Group__c from User where Forecast_Group__c='Direct' and IsActive = true limit 3]);
        User owner = usrList[0];
        User usr = usrList[1];
        //UserRole usrRole1=createRole('test111111');
        UserRole testRole=[Select id from UserRole where Name='test' limit 1];
        User consultUsr = usrList[2];//createUser('Consulting','003');
        //insert consultUsr;
        Opportunity oppty = createOpportunity(UserInfo.getUserId());
        
        List<OpportunityTeamMember> teamMbrList; 
        List<Detail_Line__c> detailList;
        Test.startTest();
        OP_SSF_CommonUtils utils = new OP_SSF_CommonUtils();
         
        //testAddSalesTeamMember
        OpportunityTeamMember opptyTeamMbr = new OpportunityTeamMember(OpportunityId=oppty.Id,UserId=owner.Id);
        Detail_Line__c detail = new Detail_Line__c(Forecast_Group__c=owner.Forecast_Group__c,Opportunity_Access_Level__c='Edit');
        SalesTeamMember teamMbr = new SalesTeamMember(false,opptyTeamMbr);
        teamMbr.detailSplit = detail;
        List<SalesTeamMember> tempList = new List<SalesTeamMember>(); 
        tempList.add(teamMbr);
        utils.addSalesTeamMembers(tempList);
        
        //teamMbrList = [select Id,UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        //System.assert(teamMbrList.size()==2);
        detailList = [select Id,Name from Detail_Line__c where Opportunity__c=:oppty.Id];
        //System.assert(detailList.size()==0);
        utils.changeOwner(oppty.Id,(Id)UserInfo.getUserId(),owner.Id);
        detailList = [select Id,Name from Detail_Line__c where Opportunity__c=:oppty.Id];
        //System.assert(detailList.size()==0);
        //teamMbrList = [select Id,UserId from OpportunityTeamMember where OpportunityId=:oppty.Id];
        //System.assert(teamMbrList.size()==2);
        Test.stopTest();
        List<OpportunityLineItem> lineItems = createOpportunityProducts(oppty.Id);
        
        insert lineItems;
        detailList = [select Id,OwnerId,Name from Detail_Line__c where Opportunity__c=:oppty.Id];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>detailList:'+detailList);
        //System.assert(detailList.size()==3);
        
        opptyTeamMbr = new OpportunityTeamMember(OpportunityId=oppty.Id,UserId=usr.Id);
        detail = new Detail_Line__c(Forecast_Group__c=usr.Forecast_Group__c,Opportunity_Access_Level__c='Edit',Split__c=0.0);
        teamMbr = new SalesTeamMember(false,opptyTeamMbr);
        teamMbr.detailSplit = detail;
        tempList = new List<SalesTeamMember>(); 
        tempList.add(teamMbr);
        utils.addSalesTeamMembers(tempList);

        opptyTeamMbr = new OpportunityTeamMember(OpportunityId=oppty.Id,UserId=consultUsr.Id);
        detail = new Detail_Line__c(Forecast_Group__c=consultUsr.Forecast_Group__c,Opportunity_Access_Level__c='Edit',Split__c=100.0);
        teamMbr = new SalesTeamMember(false,opptyTeamMbr);
        teamMbr.detailSplit = detail;
        tempList = new List<SalesTeamMember>(); 
        tempList.add(teamMbr);
        utils.addSalesTeamMembers(tempList);

        detailList = [select Id,OwnerId,Name from Detail_Line__c where Opportunity__c=:oppty.Id];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>detailList:'+detailList);
       // System.assert(detailList.size()==6);

        try{
            utils.addProducts(new List<OpportunityLineItem>(),false);
        }catch(OP_SSF_Exception ssfEx){
            
        }
    }
    //Static methods for creating test data.
    Private static List<User> createDirectRepUsers(){
        UserRole testRole=[Select id from UserRole where Name='test']; 
        List<User> usrList =new List<User>();
        usrList.add(createUser('Direct','001'));
        usrList.add(createUser('Direct','002'));
        insert usrList;
        return usrList;
    }
    
    Private static Opportunity createOpportunity(Id ownerId){
        RecordType recType = [  select Id 
                                from RecordType 
                                where SObjectType='Opportunity' 
                                and Name='New Manually Created Record Type'];
        
        List<Account> theAccount = createAccount();
        System.debug('theAccount ----->'+theAccount);
        Opportunity oppty = new Opportunity(Name='Test SSF Oppty',RecordTypeId=recType.Id,
                                            CloseDate=Date.newinstance(2099,1,1),StageName='Pipeline',
                                            Vmware_Related__c='Not VMware Related',
                                            Sales_Force__c='EMC',
                                            Sales_Channel__c='Direct',
                                            AccountId=theAccount[0].Id,
                                            //Updated for validation rule errors Srinivas Nallapati 26/5/2011
                                            //Primary_Outsourcer_System_Integrator__c=theAccount[1].id,
                                            //Primary_ISV_Infrastructure__c=theAccount[0].id,
                                            //Outsourcer_System_Integrator_involved__c = false,
                                            //ISV_Infrastructure_involved__c = false,
                                            OwnerId=ownerId);
        insert oppty;
        return oppty;
    }

    Private static List<OpportunityLineItem> createOpportunityProducts(Id opptyId){
        List<Id> fgrpProducts = new List<Id>();
        for(Forecast_Group_Product__c fgrp:[    select Product__c from Forecast_Group_Product__c 
                                                where Forecast_Mapping__r.Forecast_Group__c='Direct' and Product__r.isActive=true
                                                limit 3])
        {
            fgrpProducts.add(fgrp.Product__c);                                      
        }
        List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
        for(PriceBookEntry pbEntry :[   select Id 
                                        from PricebookEntry 
                                        where  Pricebook2.Name='Standard Price Book' 
                                        and Product2Id in :fgrpProducts
                                        and CurrencyIsoCode='USD'])
        {
            itemsToInsert.add(new OpportunityLineItem(  OpportunityId=opptyId,
                                                                PricebookEntryId=pbEntry.Id,
                                                                UnitPrice=10000.0));            
        }
        return itemsToInsert;
    }   
    private static List<Account> createAccount(){
        if(lstAcct.isEmpty()){
            RecordType recType = [  select Id 
                                    from RecordType 
                                    where SObjectType='Account' 
                                    and Name='Customer Account Record Type'];
            Account acc1 = new Account( RecordTypeId=recType.Id,
                                        Name='Test SSF Account 1',
                                        Type='Partner',
                                        Partner_Type__c='ISV'
                                       // OwnerId=UserInfo.getUserId()
                                        );
            lstAcct.add(acc1)  ;                          
            Account acc2 = new Account( RecordTypeId=recType.Id,
                                        Name='Test SSF Account 2',
                                        Type='Partner',
                                        Partner_Type__c='Outsourcer'
                                        //OwnerId=UserInfo.getUserId()
                                        );
            lstAcct.add(acc2)  ; 
            
            insert lstAcct;
        }
        return lstAcct;
    }
    private static UserRole createRole(String roleName){
        UserRole NewusrRole1=new UserRole(Name=roleName+Math.Random());
        insert NewusrRole1;
        return NewusrRole1;
    }
    private static User createUser(String fcastGrp,String usrPrefix){
        Id amerUserProf ='00e70000001FaZ6AAK'; 
        Id role ='00E70000001G6HyEAK';
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@acme.com.test',
             TimeZoneSidKey='America/New_York',
             ProfileId=amerUserProf,
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             email='john@acme.com',
             Alias='test',
             Exception__c=false,
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             UserRoleId=role,
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9663380134',
             IsActive=true 
        );
        return tempUsr;
        
    }   
}