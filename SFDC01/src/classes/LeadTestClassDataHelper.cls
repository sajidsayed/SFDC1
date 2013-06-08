public class LeadTestClassDataHelper {

    public static List<Lead> createDealReg(Account objAccount,User objUser,Account objPartnerAccount,Account objT2partnerAccount){
        List<Lead> lstLead = new List<Lead>();
        
        /*User standardUser  = [Select Id, BU_Attribute__c, Contact.Account.Owner.Email, Contact.Account.Name
                                From user where isActive = true and (BU_Attribute__c like '%core%' )   AND ProfileId ='00e70000000wBza' limit 1];                       
        
        Profile profile2 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
        User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1] ; 
      
        Profile profile3 = [SELECT Id FROM profile WHERE name='AMER PSC User'];
        User usr3   = [SELECT Id from User where ProfileId=:profile3.id and IsActive=True limit 1] ;
      
        Profile profile4 = [SELECT Id FROM profile WHERE name='APJ PSC User'];
        User usr4   = [SELECT Id from User where ProfileId=:profile4.id and IsActive=True limit 1] ;*/
 
        //Creation of Deal Reg Records  
        Lead objLead = new Lead();         
        objLead.Company ='TestDealreg1';
        objLead.DealReg_Deal_Description__c ='Deal Reg description';
        objLead.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead.CurrencyIsoCode ='USD'; 
        objLead.DealReg_Expected_Deal_Value__c =100;
        objLead.DealReg_Expected_Close_Date__c = System.today().addMonths(1);       
        objLead.LastName ='DealregLastName2';
        objLead.Email ='Dealreg1@dealreg.com';
        objLead.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead.DealReg_Partner_Phone_Number__c = '98888888';
        objLead.Status = 'Submitted';
        //objLead.DealReg_PSC_Owner__c = objUser.id;
        objLead.DealReg_Deal_Registration__c = true;
        objLead.Related_Account__c =objAccount.Id;
        objLead.DealReg_Theater__c ='Americas';
        objLead.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead.DealReg_Of_Registration_Products__c = 5; 
        //objLead.DealReg_Deal_Registration__c = true;
        objLead.DealReg_Create_New_Opportunity__c =true;
        objLead.Partner__c = objPartnerAccount.Id;
        objLead.Channel__c = 'INDIRECT';   
        objLead.City = 'Bangalore';
        objLead.Country__c = 'India';
        objLead.Street = 'Bangalore';
        objLead.Sales_Force__c = 'EMC';
        objLead.phone = '3455939';  
        objLead.DealReg_Theater__c = 'APJ';
        lstLead.add(objLead); 
        
        Lead objLead1 = new Lead();
        objLead1.Company ='TestDealreg2';
        objLead1.DealReg_Deal_Description__c ='Deal Reg description';
        objLead1.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead1.CurrencyIsoCode ='USD';
        objLead1.DealReg_Expected_Deal_Value__c =100;
        objLead1.DealReg_Expected_Close_Date__c = System.today().addMonths(2);
        objLead1.LastName ='DealregLastName1';
        objLead1.Email ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead1.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead1.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Phone_Number__c = '98888888';
        objLead1.Status = 'Submitted';
        objLead1.DealReg_Theater__c ='EMEA';
        //objLead1.DealReg_PSC_Owner__c = objUser.id;        
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.Related_Account__c =objAccount.Id;
        objLead1.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead1.DealReg_Of_Registration_Products__c = 5;
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.DealReg_Create_New_Opportunity__c =true;
        objLead1.Tier_2_Partner__c = null;
        objLead1.Partner__c = objPartnerAccount.Id;
        objLead1.Channel__c = 'INDIRECT'; 
        objLead1.City = 'Bangalore';
        objLead1.Country__c = 'India';
        objLead1.Street = 'Bangalore';
        objLead1.Sales_Force__c = 'EMC';  
        objLead1.phone = '7623778';  
        lstLead.add(objLead1);
        
        Lead objLead2 = new Lead();
        objLead2.Company ='TestDealreg3';
        objLead2.DealReg_Deal_Description__c ='Deal Reg description';
        objLead2.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead2.CurrencyIsoCode ='USD';
        objLead2.DealReg_Expected_Deal_Value__c =100;
        objLead2.DealReg_Expected_Close_Date__c = System.today().addMonths(3);
        objLead2.LastName ='DealregLastName3';
        objLead2.Email ='Dealreg1@dealreg.com';
        objLead2.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead2.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead2.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead2.DealReg_Partner_Phone_Number__c = '98888888';
        objLead2.Status = 'Submitted';
        objLead2.DealReg_Theater__c ='APJ';
        //objLead2.DealReg_PSC_Owner__c = objUser.id;        
        objLead2.DealReg_Deal_Registration__c = true;
        objLead2.Related_Account__c =objAccount.Id;
        objLead2.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead2.DealReg_Of_Registration_Products__c = 5;
        objLead2.DealReg_Deal_Registration__c = true;
        objLead2.DealReg_Create_New_Opportunity__c =true;
        objLead2.Partner__c = objPartnerAccount.Id;
        objLead2.Channel__c = 'INDIRECT';
        objLead2.City = 'Bangalore';
        objLead2.Country__c = 'India';
        objLead2.Street = 'Bangalore'; 
        objLead2.Sales_Force__c = 'EMC';
        objLead2.phone = '8234636';
        lstLead.add(objLead2);
        
        Lead objLead3 = new Lead();
        objLead3.Company ='TestDealreg4';
        objLead3.DealReg_Deal_Description__c ='Deal Reg description';
        objLead3.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead3.CurrencyIsoCode ='USD';
        objLead3.DealReg_Expected_Deal_Value__c =100;
        objLead3.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead3.LastName ='DealregLastName';
        objLead3.Email ='Dealreg1@dealreg.com';
        objLead3.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead3.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead3.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead3.DealReg_Partner_Phone_Number__c = '98888888';
        objLead3.Status = 'Submitted';
        objLead3.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead3.DealReg_Theater__c ='APJ';
        //objLead3.DealReg_PSC_Owner__c = objUser.id;        
        objLead3.DealReg_Deal_Registration__c = true;
        objLead3.Related_Account__c =objAccount.Id;
        objLead3.DealReg_Of_Registration_Products__c = 5;
        objLead3.DealReg_Deal_Registration__c = true;
        objLead3.DealReg_Create_New_Opportunity__c =true;
        objLead3.Partner__c = objPartnerAccount.Id;
        objLead3.Channel__c = 'INDIRECT'; 
        objLead3.City = 'Bangalore';
        objLead3.Country__c = 'India';
        objLead3.Street = 'Bangalore';
        objLead3.Sales_Force__c = 'EMC'; 
        objLead3.phone = '2234555';
        lstLead.add(objLead3);
        
        Lead objLead4 = new Lead();
        objLead4.Company ='TestDealreg';
        objLead4.DealReg_Deal_Description__c ='Deal Reg description';
        objLead4.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead4.CurrencyIsoCode ='USD';
        objLead4.DealReg_Expected_Deal_Value__c =100;
        objLead4.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead4.LastName ='DealregLastName';
        objLead4.Email ='Dealreg1@dealreg.com';
        objLead4.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead4.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead4.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead4.DealReg_Partner_Phone_Number__c = '98888888';
        objLead4.Status = 'Submitted';
        objLead4.DealReg_Theater__c ='APJ';
        //objLead2.DealReg_PSC_Owner__c = objUser.id;        
        objLead4.DealReg_Deal_Registration__c = true;
        objLead4.Related_Account__c =null;
        objLead4.DealReg_Deal_Registration_Status__c ='--None--';
        objLead4.Tier_2_Partner__c=null;
        objLead4.DealReg_Related_Account_lookup__c=null;
        objLead4.DealReg_Deal_Submitter_Contact__c=null;
        objLead4.DealReg_Of_Registration_Products__c = 5;
        objLead4.DealReg_Deal_Registration__c = true;
        objLead4.DealReg_Create_New_Opportunity__c =true;
        objLead4.Partner__c = null;
        objLead4.Channel__c = 'INDIRECT';
        objLead4.City = 'Bangalore';
        objLead4.Country__c = '--None--';
        objLead4.Street = 'Bangalore'; 
        objLead4.Sales_Force__c = 'EMC';
        objLead4.phone = '2312456';
        lstLead.add(objLead4);
        
        Lead objLeadAmericas = new Lead();
        objLeadAmericas.Company ='TestDealreg';
        objLeadAmericas.DealReg_Deal_Description__c ='Deal Reg description';
        objLeadAmericas.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLeadAmericas.CurrencyIsoCode ='USD';
        objLeadAmericas.DealReg_Expected_Deal_Value__c =100;
        objLeadAmericas.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLeadAmericas.LastName ='DealregLastName';
        objLeadAmericas.Email ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLeadAmericas.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLeadAmericas.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLeadAmericas.DealReg_Partner_Phone_Number__c = '98888888';
        objLeadAmericas.Status = 'Submitted';
        //objLeadAmericas.DealReg_PSC_Owner__c = objUser.id;        
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.Related_Account__c =objAccount.Id;
        objLeadAmericas.DealReg_Theater__c ='Americas';
        objLeadAmericas.DealReg_Deal_Registration_Status__c ='Submitted';
        objLeadAmericas.DealReg_Of_Registration_Products__c = 5;
        objLeadAmericas.DealReg_Deal_Registration__c = true;
        objLeadAmericas.DealReg_Create_New_Opportunity__c =true;
        objLeadAmericas.Partner__c = objPartnerAccount.Id;
        objLeadAmericas.Channel__c = 'INDIRECT'; 
        objLeadAmericas.City = 'Bangalore';
        objLeadAmericas.Country__c = 'India';
        objLeadAmericas.Street = 'Bangalore'; 
        objLeadAmericas.Sales_Force__c = 'EMC';
        objLeadAmericas.phone = '7376838';
        
        lstLead.add(objLeadAmericas);
        
        return lstLead;
    
    }

}