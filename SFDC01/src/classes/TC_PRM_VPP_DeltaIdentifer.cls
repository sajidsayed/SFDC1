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
private class TC_PRM_VPP_DeltaIdentifer {
        
       
        
    static testMethod void RevenueDeltaTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        Account acc = [select id, Grouping__c from account where Grouping__c!=null limit 1];
        DateTime dateBeforeinsert = system.now();
        System.debug('dateBeforeinsert  ' + dateBeforeinsert  );
        Revenue__c  rev= new Revenue__c( Q1_Growth_Revenue__c=100, Grouping__c=acc.Grouping__c, Account__c = acc.id );    
        insert rev;
        asertGrouping(acc.Grouping__c,dateBeforeinsert );
        
        DateTime dateBeforeupdate = system.now();
        rev.Q1_Total_Revenue__c=200;
        update rev;
        asertGrouping(acc.Grouping__c,dateBeforeupdate );
        
        delete rev;
        
    }
    static testMethod void EducationDeltaTest() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        contact con = [select id, account.Grouping__c,accountId from contact where account.Grouping__c!=null limit 1];
        DateTime dateBeforeinsert = system.now();
        Education__c  educ = new Education__c( Partner_Grouping__c=con.account.Grouping__c, Education_Master__c=[select id from Education_Master__c limit 1].id, Contact__c=con.id );    
        insert educ;
        asertGrouping(con.account.Grouping__c,dateBeforeinsert );
        
        DateTime dateBeforeupdate = system.now();
        Education_Master__c master= [select id from Education_Master__c where id != :educ.Education_Master__c limit 1];
        educ.Education_Master__c=master.id;
        update educ;
        asertGrouping(con.account.Grouping__c,dateBeforeupdate );
    }
    static testMethod void AccountDeltaTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        DateTime dateBeforeupdate = system.now();
        Account acc = [select id, Velocity_Solution_Provider_Tier__c ,Deployed_Velocity_Services__c, Grouping__c from account where Grouping__c!=null and Deployed_Velocity_Services__c!='Signature' limit 1];
        acc.Deployed_Velocity_Services__c='XXXXXXXX';
        update acc;
        asertGrouping(acc.Grouping__c,dateBeforeupdate );
    }
    static testMethod void RulesDeltaTest() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        }         
        String wholeTheaterToProcess ='None';
        String wholeClusterToProcess ='None';
        String wholeTierToProcess ='None';
        String wholeSpecialityTypeToProcess ='None';
    	
    	Velocity_Rules__c  Tierrule1=new Velocity_Rules__c();	
		Tierrule1.Theater__c='APJ';
		Tierrule1.cluster__c='NA';
		Tierrule1.Tier__c='Affiliate Elite';
		Tierrule1.Specialty_Rule_Type__c='NA';
		Tierrule1.Required__c='2';
		Tierrule1.recordtypeid='01270000000Q6icAAC';
		insert  Tierrule1;
		
        Velocity_Rules__c Tierrule = [Select v.Theater__c, cluster__c,Tier__c, v.Specialty_Rule_Type__c, v.Required__c From Velocity_Rules__c v  where v.id=:Tierrule1.id];
        String EarlierTierValue= Tierrule.Tier__c;
        String EarlierClusterValue= Tierrule.cluster__c;
        Tierrule.Tier__c='XXXX';
        update  Tierrule;
    	
   		Velocity_Rules__c  SpecialtyRule1=new Velocity_Rules__c();	
		SpecialtyRule1.Theater__c='EMEA';
		SpecialtyRule1.cluster__c='NA';
		SpecialtyRule1.Tier__c='Affiliate Elite';
		SpecialtyRule1.Specialty_Rule_Type__c='EMEA';
		SpecialtyRule1.Required__c='2';
		SpecialtyRule1.recordtypeid='01270000000Q6iXAAS';
		insert  SpecialtyRule1;
		
        Velocity_Rules__c SpecialtyRule = [Select v.Theater__c, v.Specialty_Rule_Type__c, v.Required__c, v.Cluster__c From Velocity_Rules__c v  where v.id=:SpecialtyRule1.id];
        String EarlierSpecialityValue= SpecialtyRule.Specialty_Rule_Type__c; 
        SpecialtyRule.Specialty_Rule_Type__c='XXXX';
        update SpecialtyRule;
         
     	Education_Groups__c  grp =[select id from Education_Groups__c limit 1]; 
     	Velocity_Rule_Member__c objVelRuleMember = new Velocity_Rule_Member__c (Speciality_Rule__c=Tierrule.id,Group__c=grp.Id);
     	insert objVelRuleMember;
        
        update objVelRuleMember; 
            
         Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
         CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTheater =DataValueMap.get('PRM_VPP_ProcessWholeTheater');
         wholeTheaterToProcess =(PRM_VPP_ProcessWholeTheater.DataValue__c);  
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeCluster =DataValueMap.get('PRM_VPP_ProcessWholeCluster');
        wholeClusterToProcess =(PRM_VPP_ProcessWholeCluster.DataValue__c);

        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeTier =DataValueMap.get('PRM_VPP_ProcessWholeTier');
        wholeTierToProcess =(PRM_VPP_ProcessWholeTier.DataValue__c); 
        
        CustomSettingDataValueMap__c PRM_VPP_ProcessWholeSpecialityType =DataValueMap.get('PRM_VPP_ProcessWholeSpecialityType');
        wholeSpecialityTypeToProcess =(PRM_VPP_ProcessWholeSpecialityType.DataValue__c); 
        
        if(EarlierClusterValue!=null)
        {
        	System.assert(wholeClusterToProcess.indexOf(EarlierClusterValue)!=-1 );
        }
        if(EarlierTierValue!=null)
        {
        	System.assert(wholeTierToProcess.indexOf(EarlierTierValue)!=-1 );
        }
        if(wholeTierToProcess!=null)
        {
        	System.assert(wholeTierToProcess.indexOf('XXXX')!=-1 );
        }
         if(EarlierSpecialityValue!=null)
         {       
          	System.assert(wholeSpecialityTypeToProcess.indexOf(EarlierSpecialityValue)!=-1 );
         }
         if(wholeSpecialityTypeToProcess!=null)
         {
        	System.assert(wholeSpecialityTypeToProcess.indexOf('XXXX')!=-1 );
         }
       	database.delete (objVelRuleMember,false);
       	
       	database.delete (SpecialtyRule,false);
       	 
    }
    static testMethod void GroupingDeltaTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        DateTime dateBeforeupdate = system.now();
        Account_Groupings__c partnerGrouping = [select id, process_on_after__c,active__c from Account_Groupings__c  where profiled_account__c!= null and active__c=true limit 1 ];
        partnerGrouping.active__c=false;
        partnerGrouping.Inactivation_Reason__c='XXXXX'; 
        update partnerGrouping;
        asertGrouping(partnerGrouping.id,dateBeforeupdate );
    }
     static testMethod void EduMasterDeltaTest() {
     	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        DateTime dateBeforeupdate = system.now();
        Education_Master__c master= [Select e.Id, e.ESBI_ID__c,e.ESBI_Name__c,  e.ESBI_Category__c From Education_Master__c e limit 1 ];
        Education_Group_Member__c member= [Select e.Education_Master__c, e.Education_Group__c From Education_Group_Member__c e where Education_Master__c != :master.id  limit 1];
        Education_Group_Member__c newMember= new Education_Group_Member__c (Education_Master__c=master.id,Education_Group__c =member.Education_Group__c ) ;
        insert newMember;
        
        update newMember;
        
        delete newMember;
       
    }
    static testMethod void ContactDeltaTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        DateTime dateBeforeupdate = system.now();
        Contact con= [select id,AccountId from contact where account.grouping__c!=null limit 1 ];
        Account acc = [select id,grouping__c from account where grouping__c!=null and id!=:con.accountId limit 1];
        con.AccountId =acc.id;
        update con;
        asertGrouping(acc.grouping__c, dateBeforeupdate );
    }
    static void asertGrouping(String GroupinId, DateTime lastTime){
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
        	PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        string strlastTime= lastTime.format('yyyy-MM-dd HH:mm:ss');
        lastTime= DateTime.valueOf(strlastTime);
        Account_Groupings__c partnerGrouping = [select id, process_on_after__c from Account_Groupings__c where id = :GroupinId];
        System.debug('lastTime ' + lastTime.format('hh:mm:ss:SSS') );
        datetime dt1=partnerGrouping.process_on_after__c;
        
        system.assert(( partnerGrouping.process_on_after__c!=null && partnerGrouping.process_on_after__c >= lastTime),'Date on Grouping did not stamped correctly-should stamp as ' + lastTime +' but getting '+partnerGrouping.process_on_after__c );
    }
}