/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 

 |  06.04.2012      Anirudh Singh   188157      This will used for unit testing of 
 |                                              PRM_GAF_VF_Controller Class.
 |  21.05.2012      Anil Sure                   Fixed for June Release
 +==========================================================================================================================*/
@isTest
public class PRM_GAF_Operations_TC {
    //Method for Creation of Account Grouping  
    public static Account_Groupings__c createAccountGrouping(Account ProfiledAccount){
        Account_Groupings__c accountGrouping = new Account_Groupings__c();
        accountGrouping.Name = 'Test Account Grouping';
        accountGrouping.Profiled_Account__c = ProfiledAccount.Id;
        accountGrouping.Active__c = true;
        accountGrouping.No_Master_Required__c = true;
        insert accountGrouping;        
        return accountGrouping;
    }
    //Method for Creation of Profiled Account
    public static List<Account> createProfiledAccount(){
        list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        lstPartnerAccount[0].name = 'ACCOUNT FOR GAF TEST';
        insert lstPartnerAccount;
        lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
        lstPartnerAccount[0].Ispartner=true;
        lstPartnerAccount[2].PROFILED_ACCOUNT_FLAG__c = true;
        lstPartnerAccount[2].Ispartner=true;
        update lstPartnerAccount;
        return lstPartnerAccount;
    }
    //Method for Creation of PartnerContact
    public static List<Contact> createPartnercontact(Account ProfiledAccount){
        List<Contact> lstContact = new List<Contact>();
        for(integer i=0;i<3;i++){
             Contact cont = new Contact();
             cont.FirstName = 'TestFName123'+i;
             cont.LastName =  'TestLName123'+Math.random();
             cont.AccountId=ProfiledAccount.Id;
             cont.email = ProfiledAccount.Id+cont.FirstName+'@emc.com';
             cont.Active__c = true;
             lstContact.add(cont);
        }
        insert lstContact;
        System.Debug('lstContact----->' +lstContact);
        return lstContact;
    }
    //Method for creation of GAF Record
    public static List<GAF__c> createGAF(Account ProfiledAccount,user partnerApprover){
        List<GAF__c> lstGAF = new List<GAF__c>();
        GAF__c GAF = new GAF__C();
        for(integer i=0;i<5;i++){
            GAF = new GAF__C();
            GAF.Partner_Name__c = ProfiledAccount.Id;
            GAF.Partner_GAF_Approver__c=partnerApprover.Id;
            if(i==0){
                GAF.Year__c=String.valueOf(System.Now().yearGmt());
                Gaf.GAF_Start_Date__c=System.Now().DateGmt().addDays(1);
                if((System.Now().DateGmt().addDays(45).year()) > Double.valueOf(GAF.Year__c) ) {
                    Gaf.GAF_End_Date__c=date.newinstance(System.today().year(), 12, 31);
                }else{
                    Gaf.GAF_End_Date__c=System.Now().DateGmt().addDays(45);
                }
                GAF.Velocty_Srvce_Providr_Tier__c='SSCP';
                GAF.Partner_Type__c='Distributor';
                GAF.Partner_Theater__c='Americas';
                GAF.GAF_Status__c='Draft';
            }
            else{
                GAF.Year__c=String.valueOf(System.Now().yearGmt()+i);
                Gaf.GAF_Start_Date__c=System.Now().DateGmt().addYears(i).addDays(1);
                if((System.Now().DateGmt().addYears(i).addDays(45).year()) > Double.valueOf(GAF.Year__c) ) {
                    Gaf.GAF_End_Date__c=date.newinstance(System.today().year() + i, 12, 31);
                }else{
                    Gaf.GAF_End_Date__c=System.Now().DateGmt().addYears(i).addDays(45);
                }
                GAF.Velocty_Srvce_Providr_Tier__c='SSCP';
                GAF.Partner_Type__c='Distributor';
                GAF.Partner_Theater__c='Americas';
                GAF.GAF_Status__c='Draft';
            }
            if(i==2){
                GAF.GAF_Status__c='Partner Approved';
            }
            lstGAF.add(GAF);
        }
        insert lstGAF;
        return lstGAF;
    }
   // Method to unit test PRM_GAF_Operations.cls
    static testMethod void prmGAFOperationUnitTest() {
    GAF__c GAF;
    list<User> lstPoratlUser=new list<User>();
    User partner1;
    User partner2;
    User partner3;
    User partner4;
    User partner5;
    User partner6;
    List<Contact> lstcontact1 = new list<Contact>();
    List<Contact> lstcontact2 = new list<Contact>();
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1]; 
    User insertUserAPIOnly = [Select id from User where isActive=true and profile.Name='System Administrator - API Only' limit 1]; 
                
    System.runAs(insertUser)
    {
    PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
    }
    List<Account> lstPartnerAccount = createProfiledAccount();
    Account_Groupings__c accountGrouping1 = createAccountGrouping(lstPartnerAccount[2]);
    Account_Groupings__c accountGrouping2 = createAccountGrouping(lstPartnerAccount[0]);
     System.runAs(insertUserAPIOnly)
        {
            lstcontact1 = createPartnercontact(lstPartnerAccount[2]); 
            lstcontact2 = createPartnercontact(lstPartnerAccount[0]);    
        }
    System.Debug('lstcontact1--->' +lstcontact1);   
    System.runAs(insertUser)
        { 
           //Changed from Super to Partner User   
           String distributorSuperUser = 'AMER Distributor Partner User';
           Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser limit 1];       
           partner1 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact1[0].Id);
           partner2 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact1[1].Id);
           partner3 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact1[2].Id);
           partner4 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact2[0].Id);
           partner5 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact2[1].Id);
           partner6= UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstcontact2[2].Id);
           lstPoratlUser.add(partner1);
           lstPoratlUser.add(partner2);
           lstPoratlUser.add(partner3);
           lstPoratlUser.add(partner4);
           lstPoratlUser.add(partner5);
           lstPoratlUser.add(partner6);
           insert lstPoratlUser;
       
        }
        Test.StartTest();
        List<GAF__c> lstGAFafterinsert = createGAF(lstPartnerAccount[2],partner1);          
            lstGAFafterinsert[1].GAF_Status__c='EMC Submitted';
            lstGAFafterinsert[2].GAF_Status__c='Draft';
            lstGAFafterinsert[2].Partner_Theater__c='EMEA';
            lstGAFafterinsert[2].Partner_Type__c='Distributor';
            lstGAFafterinsert[0].GAF_Status__c='Reapproval Required';
            lstGAFafterinsert[0].Partner_Theater__c='EMEA';
            lstGAFafterinsert[0].Partner_Type__c='Direct Reseller';
            lstGAFafterinsert[3].GAF_Status__c='Reapproval Required';
            lstGAFafterinsert[3].Partner_Theater__c='Americas';
            lstGAFafterinsert[3].Partner_Type__c='Direct Reseller';         
            update lstGAFafterinsert;
            System.runAs(insertUser)
        {
            lstGAFafterinsert[2].GAF_Status__c='EMC Submitted';
            lstGAFafterinsert[0].GAF_Status__c='EMC Submitted';
            lstGAFafterinsert[3].GAF_Status__c='EMC Submitted';
            lstGAFafterinsert[4].GAF_Status__c='EMC Submitted';
            update lstGAFafterinsert;
        }
            lstGAFafterinsert[4].GAF_Status__c='Expired';
            Update lstGAFafterinsert[4];
            APPR_MTV__RecordAssociation__c RecordAssociation1 = New APPR_MTV__RecordAssociation__c(APPR_MTV__Associated_Account__c=lstPartnerAccount[0].Id,APPR_MTV__Account__c=lstPartnerAccount[2].Id,
                               APPR_MTV__Account_Role__c='Distributor',APPR_MTV__Primary__c=true);
            Insert RecordAssociation1;
            
            System.runAs(partner1){
                PRM_GAF_Operations.ApproveGAf(lstGAFafterinsert[1].id);
                PRM_GAF_Operations.ApproveGAf(lstGAFafterinsert[2].id);
                PRM_GAF_Operations.ApproveGAf(lstGAFafterinsert[0].id);
                PRM_GAF_Operations.ApproveGAf(lstGAFafterinsert[3].id);             
                PRM_GAF_Operations.ApproveGAf(lstGAFafterinsert[4].id);
                
                
                
            }
            try{
                delete RecordAssociation1;
            }
            catch(exception e){                            
            }
            GAF = new GAF__C();
            GAF.Partner_Name__c = lstPartnerAccount[2].Id;
            GAF.Partner_GAF_Approver__c=partner1.Id;
            GAF.Year__c=String.valueOf(System.Now().yearGmt());
            Gaf.GAF_Start_Date__c=System.Now().DateGmt().addDays(1);
            if((System.Now().DateGmt().addDays(45).year()) > Double.valueOf(GAF.Year__c) ) {
                Gaf.GAF_End_Date__c=date.newinstance(System.today().year(), 12, 31);
            }else{
                Gaf.GAF_End_Date__c=System.Now().DateGmt().addDays(45);
            }
            GAF.Velocty_Srvce_Providr_Tier__c='SSCP';
            GAF.Partner_Type__c='Distributor';
            GAF.Partner_Theater__c='Americas';
            GAF.GAF_Status__c='Draft';
            try{
                insert GAF;
            }
            catch(exception e){
                
            }
            APPR_MTV__RecordAssociation__c RecordAssociation = New APPR_MTV__RecordAssociation__c(APPR_MTV__Associated_Account__c=lstPartnerAccount[0].Id,APPR_MTV__Account__c=lstPartnerAccount[2].Id,
                               APPR_MTV__Account_Role__c='Distributor',APPR_MTV__Primary__c=true);
            Insert RecordAssociation;
            try{
                delete RecordAssociation;
            }
            catch(exception e){
                
            }
        test.stopTest();
   } 

}