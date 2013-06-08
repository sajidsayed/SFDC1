/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
   ====          =========               ==         =========== 
   23-Aug-12     Ganesh                 200157      Test class for VSPEX Nomination
   18-Apr-13     Prachi                             To improve test coverage
   23-May-13	 Krishna Pydavula		214126      To improve test coverage   
+=====================================================================================================*/   
@isTest(SeeAllData=true)
private class VSPEX_Nomination_Rejection_TC
{
        
 static testmethod void VSPEXNominationRejectionTest1()
 {
        
     Account Acc = new Account();
     Acc.Name = 'ARROW ENTERPRISE COMPUTING SOLUTIONS,INC'; 
     Acc.PROFILED_ACCOUNT_FLAG__c=true;
     Acc.Lead_Oppty_Enabled__c=true;
     Acc.Partner_Type_Picklist__c='Distribution VAR';
     Acc.Non_Distributor_Direct_Reseller_Partner__c=true;  
     insert Acc;     
     
     Account Acc1 = new Account();
     Acc1.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
     insert Acc1;     
     
     //Creating Contact     
     Contact Con = new Contact();     
     Con.Salutation = 'Mr';
     Con.FirstName = 'Jayaraju';
     Con.LastName = 'Nulakachandanam';
     Con.AccountId = Acc.id;
     insert Con;
 
    
    Partner_Information__c objVSPEXNom1= new Partner_Information__c();
    objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
    objVSPEXNom1.Nominated_VAR__c=Acc.id;
    objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;          
    insert objVSPEXNom1;
    
    
 }
 
 static testmethod void VSPEXNominationRejectionCompleteAllFields()
 {
    Account Acc = new Account();
     Acc.Name = 'ARROW ENTERPRISE COMPUTING SOLUTIONS,INC'; 
     Acc.PROFILED_ACCOUNT_FLAG__c=true;
     Acc.Lead_Oppty_Enabled__c=true;
     Acc.Partner_Type_Picklist__c='Distribution VAR';
     Acc.Non_Distributor_Direct_Reseller_Partner__c=true;  
     insert Acc;     
     
     Account Acc1 = new Account();
     Acc1.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
     insert Acc1;     
     
     //Creating Contact     
     Contact Con = new Contact();     
     Con.Salutation = 'Mr';
     Con.FirstName = 'Jayaraju';
     Con.LastName = 'Nulakachandanam';
     Con.AccountId = Acc.id;
     insert Con;
 
    
    Partner_Information__c objVSPEXNom1= new Partner_Information__c();
    objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
    objVSPEXNom1.Nominated_VAR__c=Acc.id;
    objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;          
    insert objVSPEXNom1;
    objVSPEXNom1.Status__c='Submitted';    
    objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
    objVSPEXNom1.Nominated_VAR__c=Acc.id;
    objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;
    objVSPEXNom1.VSPEX_Acreditation_Achieved__c=true;
    objVSPEXNom1.Planned_VSPEX_Solultions__c='VMware SV - SMB';
    objVSPEXNom1.Sales_Coverage_Theater__c='EMEA';
    objVSPEXNom1.Partner_VSPEX_demonstration_capabilities__c='Test';
    objVSPEXNom1.Sales_Coverage_Geo__c='National';
    objVSPEXNom1.VAR_Recruitment_Enablement_Plan__c='Test';
    objVSPEXNom1.Sales_Coverage_Region__c='Canada';
    objVSPEXNom1.Preferred_Line_Card_components__c='Test';
    objVSPEXNom1.Partners_Service_Strategy__c='Full Implementation';
    objVSPEXNom1.Alliance_Partner_Relationships__c='Microsoft';
    objVSPEXNom1.Partner_Vertical_Focus_Details__c='Education';
    objVSPEXNom1.Servers__c='Dell';
    objVSPEXNom1.Network_IP__c='Cisco';
    objVSPEXNom1.Network_FC__c='HP';             
    update objVSPEXNom1;

         
    }
    
    
     static testmethod void VSPEXNominationRejectionTest3()
     {
         Account Acc = new Account();
         Acc.Name = 'ARROW ENTERPRISE COMPUTING SOLUTIONS,INC'; 
         Acc.PROFILED_ACCOUNT_FLAG__c=true;
         Acc.Lead_Oppty_Enabled__c=true;
         Acc.Partner_Type_Picklist__c='Distribution VAR';
         Acc.Non_Distributor_Direct_Reseller_Partner__c=true;  
         insert Acc;     
     
         Account Acc1 = new Account();
         Acc1.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
         Acc1.PROFILED_ACCOUNT_FLAG__c=true;
         Acc1.Lead_Oppty_Enabled__c=true;
         Acc1.Partner_Type_Picklist__c='Distributor'; 
         insert Acc1;     
         user u=[select id,name from user where profile.name='AMER Direct Reseller Super User' and isactive=true limit 1];
         //Creating Contact     
         Contact Con = new Contact();     
         Con.Salutation = 'Mr';
         Con.FirstName = 'Jayaraju';
         Con.LastName = 'Nulakachandanam';
         Con.AccountId = Acc.id;
         insert Con;
        List<Account> lstacc=new List<Account>();      
        lstacc=[select Alliance_Partner_Relationships__c,Network_FC__c,Network_IP__c,Nomination_Approval_Date__c,Other_Network_FC__c,Other_Network_IP__c,
                                   Other_Servers__c,Partners_Service_Strategy__c,Partner_Vertical_Focus_Details__c,Partner_VSPEX_demonstration_capabilities__c,Planned_VSPEX_Solultions__c,
                                   Preferred_Line_Card_components__c,Sales_Coverage_Geo__c,Sales_Coverage_Region__c,Sales_Coverage_Theater__c,Servers__c,VAR_Recruitment_Enablement_Plan__c,
                                   VSPEX_Acreditation_Achieved__c,VSPEX_Partner__c from Account where id=:Acc.id];                      
        date d = Date.today();
        Partner_Information__c objVSPEXNom1= new Partner_Information__c();
        objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
        objVSPEXNom1.Nominated_VAR__c=Acc.id;
        objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;
        objVSPEXNom1.ownerid=u.id;    
              
            insert objVSPEXNom1;    
            objVSPEXNom1.Status__c='Approved';
            objVSPEXNom1.VSPEX_Acreditation_Achieved__c=true;
            objVSPEXNom1.Planned_VSPEX_Solultions__c='VMware SV - SMB';
            objVSPEXNom1.Sales_Coverage_Theater__c='EMEA';
            objVSPEXNom1.Partner_VSPEX_demonstration_capabilities__c='Test';
            objVSPEXNom1.Sales_Coverage_Geo__c='National';
            objVSPEXNom1.VAR_Recruitment_Enablement_Plan__c='Test';
            objVSPEXNom1.Sales_Coverage_Region__c='Canada';
            objVSPEXNom1.Preferred_Line_Card_components__c='Test';
            objVSPEXNom1.Partners_Service_Strategy__c='Full Implementation';
            objVSPEXNom1.Alliance_Partner_Relationships__c='Microsoft';
            objVSPEXNom1.Partner_Vertical_Focus_Details__c='Education';
            objVSPEXNom1.Servers__c='Dell';
            objVSPEXNom1.Network_IP__c='Cisco';
            objVSPEXNom1.Network_FC__c='HP';    
            objVSPEXNom1.Nomination_Approval_Date__c=d;
            objVSPEXNom1.Other_Servers__c='';
            objVSPEXNom1.Other_Network_IP__c='';
            objVSPEXNom1.Other_Network_FC__c='';
            objVSPEXNom1.VAR_Recruitment_Enablement_Plan__c='test';
            objVSPEXNom1.VSPEX_Acreditation_Achieved__c=true;
             
        //objVSPEXNom1.Status__c='Rejected';               
           update objVSPEXNom1;
                   
           List<Account> lstUpdateAcc = new List<Account>();
           Partner_Information__c objVSPEXNom = objVSPEXNom1;
           acc.Alliance_Partner_Relationships__c=objVSPEXNom.Alliance_Partner_Relationships__c;
           acc.Network_FC__c=objVSPEXNom.Network_FC__c;
           acc.Network_IP__c=objVSPEXNom.Network_IP__c;
           acc.Nomination_Approval_Date__c=objVSPEXNom.Nomination_Approval_Date__c;
           acc.Other_Network_FC__c=objVSPEXNom.Other_Network_FC__c;
           acc.Other_Network_IP__c=objVSPEXNom.Other_Network_IP__c;
           acc.Other_Servers__c=objVSPEXNom.Other_Servers__c;
           acc.Partners_Service_Strategy__c=objVSPEXNom.Partners_Service_Strategy__c;
           acc.Partner_Vertical_Focus_Details__c=objVSPEXNom.Partner_Vertical_Focus_Details__c;
           acc.Partner_VSPEX_demonstration_capabilities__c=objVSPEXNom.Partner_VSPEX_demonstration_capabilities__c;
           acc.Planned_VSPEX_Solultions__c=objVSPEXNom.Planned_VSPEX_Solultions__c;
           acc.Preferred_Line_Card_components__c=objVSPEXNom.Preferred_Line_Card_components__c;
           acc.Sales_Coverage_Geo__c=objVSPEXNom.Sales_Coverage_Geo__c;
           acc.Sales_Coverage_Region__c=objVSPEXNom.Sales_Coverage_Region__c;
           acc.Sales_Coverage_Theater__c=objVSPEXNom.Sales_Coverage_Theater__c;
           acc.Servers__c=objVSPEXNom.Servers__c;
           acc.VAR_Recruitment_Enablement_Plan__c=objVSPEXNom.VAR_Recruitment_Enablement_Plan__c;
           acc.VSPEX_Acreditation_Achieved__c=objVSPEXNom.VSPEX_Acreditation_Achieved__c;
           lstUpdateAcc.add(acc);
           update lstUpdateAcc; 
          
           
    }
    
    static testmethod void VSPEXNominationRejectionValidationRule()
     {
         Account Acc = new Account();
         Acc.Name = 'ARROW ENTERPRISE COMPUTING SOLUTIONS,INC'; 
         Acc.PROFILED_ACCOUNT_FLAG__c=true;
         Acc.Lead_Oppty_Enabled__c=true;
         Acc.Partner_Type_Picklist__c='Distribution VAR';
         Acc.Non_Distributor_Direct_Reseller_Partner__c=true;  
         insert Acc;     
     
         Account Acc1 = new Account();
         Acc1.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
         insert Acc1;     
     
         //Creating Contact     
         Contact Con = new Contact();     
         Con.Salutation = 'Mr';
         Con.FirstName = 'Jayaraju';
         Con.LastName = 'Nulakachandanam';
         Con.AccountId = Acc.id;
         insert Con;
     
        
        Partner_Information__c objVSPEXNom1= new Partner_Information__c();
        objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
        objVSPEXNom1.Nominated_VAR__c=Acc.id;
        objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;          
        insert objVSPEXNom1;        
        objVSPEXNom1.Status__c='Rejected';
        objVSPEXNom1.Business_Justification_for_Rejection__c='Test Reason';
        ApexPages.currentpage().getParameters().put('Id',objVSPEXNom1.Id);
        objVSPEXNom1.Business_Justification_for_Rejection__c='testreason';         
        update objVSPEXNom1;
        /*objVSPEXNom1.Status__c='Rejected';
        ApexPages.currentpage().getParameters().put('Id',objVSPEXNom1.Id);
        objVSPEXNom1.Business_Justification_for_Rejection__c='testreason';        
        update objVSPEXNom1;*/
         
    }
    //Prachi: Code starts
    static testmethod void VSPEXNominationTestMethod(){
     
     Account Acc1 = new Account();
     Acc1.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
     insert Acc1;
     
     Account Acc = new Account();
     Acc.Name = 'ARROW ENTERPRISE COMPUTING SOLUTIONS,INC'; 
     Acc.PROFILED_ACCOUNT_FLAG__c=true;
     Acc.Lead_Oppty_Enabled__c=true;
     Acc.Partner_Type_Picklist__c='Distribution VAR';
     Acc.Non_Distributor_Direct_Reseller_Partner__c=true;
     Acc.Preferred_Distributor__c =Acc1.id;  
     insert Acc;     
     
     //Creating Contact     
     Contact Con = new Contact();     
     Con.Salutation = 'Mr';
     Con.FirstName = 'Jayaraju';
     Con.LastName = 'Nulakachandanam';
     Con.AccountId = Acc.id;
     insert Con;
     
     Partner_Information__c objVSPEXNom1= new Partner_Information__c();
	 objVSPEXNom1.Nominating_Distributor_Direct_Reseller__c=Acc1.id;
	 objVSPEXNom1.Nominated_VAR__c=Acc.id;
	 objVSPEXNom1.Onboarding_VAR_Contact__c=Con.id;
	 insert objVSPEXNom1;
	 
 	User PartnerUser = [Select Id,Name from User where Profile.Name like '%Direct Reseller%' and IsActive = true limit 1];
    system.runAs(PartnerUser)
    {
	    ApexPages.StandardController stdController= new ApexPages.StandardController(objVSPEXNom1);
	    VSPEX_Nomination_Rejection obj=new VSPEX_Nomination_Rejection(stdController);
	    obj.init();
	    obj.SaveRejection();
	    obj.getvspex();
    }
      
   } 
    //Prachi: Code ends  
}