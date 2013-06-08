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
@isTest
private class Opp_EMEAInsideSalesAlerts_TC {
    //Opportunity Closed
    static testMethod void EmeaInsideSalesClosed() 
    {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.      
        Opp_EMEAInsideSalesAlerts Opp_EMEAIns=new Opp_EMEAInsideSalesAlerts();       
        List<Account> lstAccount= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm= new List<OpportunityTeamMember>([Select UserId,User.managerId, OpportunityId, OpportunityAccessLevel, IsDeleted, Id From OpportunityTeamMember limit 2]);
       
        List<Contact> lstCon=new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag = CustomSettingDataValueMap__c.getall().values();
        //CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        //dataValueControlFlag.Name ='EMEA Inside Sales Opportunity Closed';
        //dataValueControlFlag.DataValue__c ='00570000001epv8,00570000001enlG';
        system.debug('dataValueControlFlag ======'+dataValueControlFlag );
        try
        {
       // database.insert (dataValueControlFlag,false);
        }catch(Exception e){
           System.debug(' Check Obj Access'+e); 
        }
        //Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,Closed_Reason__c='No Competition'
                            ,chkSalesTeam__c=true
                            ,StageName ='Pipeline',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
        //insert Oppty;
        database.insert (Oppty,false);
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId=lstUser[i].id;
            otm.OpportunityId=Oppty.id;
            lstotm.add(otm);
        }
       // insert lstotm;
        database.insert (lstotm,false);
        system.debug('lstotm========='+lstotm);
        Opp_EMEAInsideSalesAlerts.calculateCloseDateInFuture(date.today(), date.today());
        Opportunity oppQuery= [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty.id ];
        test.startTest();
        oppQuery.CloseDate = Date.today();
        oppQuery.Area_Manager__c=lstCon[0].Id;
        oppQuery.District_Manager__c=lstCon[1].id;
        oppQuery.Close_Comments__c='Closed';
        oppQuery.StageName='Closed';
        //update oppQuery;
       database.upsert (oppQuery,false);
        
       test.stopTest();
    }
    //Opportunity Closed to Competition.
    static testMethod void EmeaInsideSalesClosedtoCompetition() 
    {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.
        List<Account> lstAccount1= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm1= new List<OpportunityTeamMember>();
        List<Contact> lstCon1=new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag1 = CustomSettingDataValueMap__c.getall().values();
        //CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        //dataValueControlFlag.Name ='EMEA Inside Sls Clsd to Comptetion';
        //dataValueControlFlag.DataValue__c ='00570000001Iy5o,00570000001epv8,00570000001enlG';
        try
        {
            database.insert (dataValueControlFlag1,false);
        }catch(Exception e){
            System.debug('Check Obj Access'+e); 
        }
        //Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser1 = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty1 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount1.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser1[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,Closed_Reason__c='Competition'
                            ,chkSalesTeam__c=true
                            ,StageName ='Pipeline',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
        insert Oppty1;
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId =lstUser1[i].id;
            otm.OpportunityId=Oppty1.id;
            lstotm1.add(otm);
        }
        //insert lstotm;
         database.upsert (lstotm1,false);
        Opportunity oppQuery1= [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty1.id ];
        test.startTest();
        oppQuery1.CloseDate = Date.today();
        oppQuery1.Area_Manager__c=lstCon1[0].Id;
        oppQuery1.District_Manager__c=lstCon1[1].id;
        oppQuery1.Close_Comments__c='Closed';
        oppQuery1.StageName='Closed';
        //update oppQuery;
        database.upsert (oppQuery1,false);
        test.stopTest();
    }
    //Opportunity Moved from Comit to Strong Upside.
    static testMethod void EmeaInsideSalesCommittoStrongUpside() 
    {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.
        List<Account> lstAccount2= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm2= new List<OpportunityTeamMember>();
        List<Contact> lstCon2=new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag2 = CustomSettingDataValueMap__c.getall().values();
        //CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        //dataValueControlFlag.Name ='EMEA Inside Sls Commit to Strg Upside';
        //dataValueControlFlag.DataValue__c ='00570000001epv8,00570000001enlG';
        try
        {
            database.insert (dataValueControlFlag2,false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }//Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser2 = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty2 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount2.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser2[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,chkSalesTeam__c=true
                            ,StageName ='Commit',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
        //insert Oppty;
        database.insert(Oppty2,false);
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId=lstUser2[i].id;
            otm.OpportunityId=Oppty2.id;
            lstotm2.add(otm);
        }
        database.insert(lstotm2,false);
        Opportunity oppQuery2= [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty2.id ];
        test.startTest();
        oppQuery2.CloseDate = Date.today();
        oppQuery2.Area_Manager__c=lstCon2[0].Id;
        oppQuery2.District_Manager__c=lstCon2[1].id;
        oppQuery2.StageName='Strong Upside';
        
        //update oppQuery2;
        database.update(Oppty2,false);
        
       test.stopTest();
    }
    static testMethod void EmeaInsideSalesCommittoUpside() 
    {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.
        List<Account> lstAccount3= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm3= new List<OpportunityTeamMember>();
        List<Contact> lstCon3=new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag3 = CustomSettingDataValueMap__c.getall().values();
       // CustomSettingDataValueMap__c dataValueControlFlag3 = new CustomSettingDataValueMap__c();
       // dataValueControlFlag.Name ='EMEA Inside Sls Commit to Upside';
       // dataValueControlFlag.DataValue__c ='00570000001epv8,00570000001enlG';
        try
        {
            database.insert (dataValueControlFlag3,false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }//Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser3 = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty3 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount3.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser3[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,chkSalesTeam__c=true
                            ,StageName ='Commit',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
        //insert Oppty;
        database.insert(Oppty3,false);
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId=lstUser3[i].id;
            otm.OpportunityId=Oppty3.id;
            lstotm3.add(otm);
        }
        //insert lstotm3;
        database.insert(lstotm3,false);
        Opportunity oppQuery4= [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty3.id ];
        test.startTest();
        oppQuery4.CloseDate = Date.today();
        oppQuery4.Area_Manager__c=lstCon3[0].Id;
        oppQuery4.District_Manager__c=lstCon3[1].id;
        oppQuery4.StageName='Upside';
        //update oppQuery;
        database.update(OppQuery4,false);
       test.stopTest();
    }
    //Opportunity moved from Strong upside to Upside.
    static testMethod void EmeaInsideSalesStrongUpsidetoUpside() 
    {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.
        List<Account> lstAccount5= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm5= new List<OpportunityTeamMember>();
        List<Contact> lstCon5=new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag5 = CustomSettingDataValueMap__c.getall().values();
        //CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        //dataValueControlFlag.Name ='EMEA Inside Sls Strg Upside to Upside';
        //dataValueControlFlag.DataValue__c ='00570000001epv8,00570000001enlG';
        try
        {
            database.insert (dataValueControlFlag5,false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        //Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser5 = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty5 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount5.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser5[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,chkSalesTeam__c=true
                            ,StageName ='Strong Upside',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
       // insert Oppty;
        database.insert(Oppty5,false);
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId=lstUser5[i].id;
            otm.OpportunityId=Oppty5.id;
            lstotm5.add(otm);
        }
        //insert lstotm;
        database.insert(lstotm5,false);
        Opportunity oppQuery5= [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty5.id ];
        test.startTest();
        oppQuery5.CloseDate = Date.today();
        oppQuery5.Area_Manager__c=lstCon5[0].Id;
        oppQuery5.District_Manager__c=lstCon5[1].id;
        oppQuery5.StageName='Upside';
        //update oppQuery;
        database.update (oppQuery5,false);
        test.stopTest();
    }
    //Test Method to test opportunity moved to commit status in future quarter.
     static testMethod void EmeaInsideSalestoCommitFutureQuarter() 
     {
        // TO DO: implement unit test
        //Holds list of Under pen accounts.
        List<Account> lstAccount6= new List<Account>([Select id,Account_Status__c from Account limit 2 ]);
        //Holds List of Opportunity Team Member.
        List<OpportunityTeamMember> lstotm6= new List<OpportunityTeamMember>();
        List<Contact> lstCon6 = new List<Contact>([Select id,name,email from contact limit 2]);
        List<CustomSettingDataValueMap__c> dataValueControlFlag6 = CustomSettingDataValueMap__c.getall().values();
        //CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        //dataValueControlFlag.Name ='EMEA Inside Sls Clsd dt mvd to Ftr Qtr';
        //dataValueControlFlag.DataValue__c ='00570000001epv8,00570000001enlG';
        try
        {
            database.insert (dataValueControlFlag6,false);
        
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        //Valid user to be assigned as the account owner on opportunity.
        List<User> lstUser6 = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Department='EMEA inside Sales'  and IsActive=True limit 7]);
        //Create valid opportunity with account as Underpen account type.
        Opportunity Oppty6 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount6.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            ,Opportunity_Owner__c=lstUser6[4].id
                            ,Quote_Cart_Number__c='345465443'
                            ,chkSalesTeam__c=true
                            ,StageName ='Strong Upside',CloseDate = Date.today(),VCE_Related__c='VMWare Other',Amount=5500000,Dollar_Amount__c = 550000);
        //insert Oppty;
        
        database.insert(Oppty6,false);
        for(Integer i=0;i<3;i++)
        {
            OpportunityTeamMember otm= new OpportunityTeamMember();
            otm.UserId=lstUser6[i].id;
            otm.OpportunityId=Oppty6.id;
            lstotm6.add(otm);
        }
        //insert lstotm;
        database.insert(lstotm6,false);
        Opportunity oppQuery6 = [Select id,Close_Date_Quarter__c,Current_Quarter__c,Closed_Reason__c,chkSalesTeam__c,StageName,
                            CloseDate,Dollar_Amount__c,Amount,Opportunity_Owner__c from opportunity where id=:Oppty6.id ];
        test.startTest();
        oppQuery6.CloseDate = Date.today()+90;
        oppQuery6.Area_Manager__c=lstCon6[0].Id;
        oppQuery6.District_Manager__c=lstCon6[1].id;
        oppQuery6.StageName='Upside';
        //update oppQuery;
        //insert oppQuery;
        database.insert(oppQuery6,false);        
        test.stopTest();
        
    }
}