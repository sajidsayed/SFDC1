/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  16.12.2011      Anand Sharma                Test class for the unit test of Controller PRM_PartnerSESearchController
 												for the Partner SE Search page.
 +=========================================================================================================================*/
@isTest
private class PRM_PartnerSESearchController_TC {
	Static List<Account> acctLst = new List<Account>();
	Static List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSE = new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    Static List<Contact> contLst = new  List<Contact>();   
    Static List<District__c> lstDistrict = new List<District__c>();
    public static void createAccount(){
       
		for(Integer acc=0 ; acc<3 ; acc++){
	        System.debug('Inside Account Creation');     
	        Account acctObj = new Account();
	        acctObj.Name = 'Partener Account';
	        acctObj.Partner_Type__c='Direct Reseller';
	        acctObj.rating_eligible__c = true;
	        
	        acctObj.Lead_Oppty_Enabled__c=true;
	        acctObj.type='Partner';
	        //acctObj.Ispartner=true;
	        acctLst.add(acctObj);

       	}
        Database.insert(acctLst);
        
        /*acctLst[0].Lead_Oppty_Enabled__c=true;
        acctLst[0].type='Partner';*/
        acctLst[0].PROFILED_ACCOUNT_FLAG__c=true;
        acctLst[1].PROFILED_ACCOUNT_FLAG__c=true;
        Account_Groupings__c gr=new Account_Groupings__c();
        gr.name='testing Grouping';
        gr.Account__c='test';
        insert gr;
        acctLst[0].grouping__c=gr.id;
        acctLst[2].grouping__c=gr.id;
        acctLst[0].Ispartner=true;
        acctLst[1].Ispartner=true;
        Database.update(acctLst);
        
        System.debug('Account Created');       
    }
    
    public static List<Contact> createContact(){

        Contact contObj = new Contact();
        contObj.LastName = 'Tester';
        contObj.Phone = '999999999';
        contObj.Email = 'xxxx@acc.com';
        contObj.Partner_SE__c = true;
        contObj.emc_pre_sales__c='70%';
        contLst.add(contObj);
        
        Contact contObj1 = new Contact();
        contObj1.LastName = 'Tester1';
        contObj1.account=acctLst[0];
        contObj1.Phone = '99999999';
        contObj1.Email = 'xxx@acc.com';
        contObj1.Partner_SE__c = true;
        contObj1.emc_pre_sales__c='150%';
        contLst.add(contObj1);
        Database.insert(contLst);
        contLst = [Select ID,Email,Phone,Partner_SE__c from Contact where id in:contLst];
        return contLst;
    }
    public static List<Partner_SE_Skill_Sales_Acumen_Rating__c> createPartnerSESkillrecords(List<Contact> lstContacts){
    	List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSkill = new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    	if(lstContacts != null && lstContacts.size() >0){
    		for(Contact objContact : lstContacts){
    			Partner_SE_Skill_Sales_Acumen_Rating__c objAcumen = new Partner_SE_Skill_Sales_Acumen_Rating__c();
				objAcumen.partner_se__c= objContact.Id;
				objAcumen.VCE_Skill__c   = '3';
				objAcumen.Unified_Skill__c = '3';   
				objAcumen.Symmetrix_Sales__c = '3';             
				objAcumen.Symmetrix_Skill__c = '3'; 
				objAcumen.RSA_Security_Skill__c = '3';
				objAcumen.Replication_Skill__c = '3';   
				objAcumen.BRS_Avamar_Skill__c = '3';
				objAcumen.BRS_Data_Domain_Skill__c = '3';
				objAcumen.BRS_Networker_Skill__c = '3';
				objAcumen.IP_Networking_Skill__c = '3';
				objAcumen.Isilon_Skill__c = '3';
				objAcumen.VMware_Skill__c = '3';
			
				objAcumen.VMware_Sales__c= '3';
				objAcumen.Unified_Sales__c = '3';
				objAcumen.RSA_Security_Sales__c = '3';               
				objAcumen.BRS_Avamar_Sales__c = '3';    
				objAcumen.BRS_Data_Domain_Sales__c = '3';
				objAcumen.BRS_Networker_Sales__c = '3';
				objAcumen.IP_Networking_Sales__c = '3';         
				objAcumen.Isilon_Sales__c = '3';
				objAcumen.Replication_Sales__c = '3';   
				objAcumen.VCE_Sales__c = '3';   
			
				objAcumen.Dell__c = '3';                    
				objAcumen.HDS__c = '3';                 
				objAcumen.HP__c= '3';                   
				objAcumen.IBM__c= '3';                  
				objAcumen.NTAP__c= '3'; 
			
				objAcumen.Oracle_App_Competence__c='Yes';
				objAcumen.SAP_App_Competence__c='Yes';
				objAcumen.SQL_App_Competence__c='Yes';
				objAcumen.VCE_App_Competence__c='Yes';
				objAcumen.VMware_App_Competence__c='Yes';
				lstSkill.add(objAcumen);
    		}
    	}
    	
    	if(lstSkill.size() >0){
    		insert lstSkill;
    	}
    	return lstSkill;
		    	
    }
    
    public static void createDistrictMappingRecord(List<Contact> lstContacts){
    	
    	List<District_to_Partner_SE_Mapping__c> lstDistrictPartnerSEMapping = new List<District_to_Partner_SE_Mapping__c>();
    	District__c objDistrict = new District__c();
    	objDistrict.Name ='Test District';
    	objDistrict.Theater__c ='APJ';
    	objDistrict.Country__c ='TestCountry1';
    	
    	District__c objDistrict1 = new District__c();
    	objDistrict1.Name ='Test District';
    	objDistrict1.Theater__c ='APJ';
    	objDistrict1.Country__c ='TestCountry2';
    	lstDistrict.add(objDistrict);
    	
    	insert lstDistrict;

    	if(lstContacts != null && lstContacts.size() >0){
    		for(Integer i=0; i< lstContacts.size() ; i++){
    			District_to_Partner_SE_Mapping__c objDistrictPartnerSEMapping = new District_to_Partner_SE_Mapping__c();
    			if(lstDistrict != null && i< lstDistrict.size() ){
    				objDistrictPartnerSEMapping.District__c = lstDistrict.get(i).Id;
	    			objDistrictPartnerSEMapping.Partner_SE__c =lstContacts.get(i).Id;
	    			lstDistrictPartnerSEMapping.add(objDistrictPartnerSEMapping);
    			}
	    		
    		}
	    		
    	}
    	if(lstDistrictPartnerSEMapping.size() >0){
    		 insert lstDistrictPartnerSEMapping;
    	} 
    	
    }
    
    public static void createCustomSettingRecords(){
    	List<CustomSettingPartnerSESeach__c> lstCustSettPatnerSESearch = new List<CustomSettingPartnerSESeach__c>();
        CustomSettingPartnerSESeach__c objCustSettPartnerSESeach = new CustomSettingPartnerSESeach__c();
        objCustSettPartnerSESeach.Name ='BRS_Avamar_Skill__c';
        objCustSettPartnerSESeach.Competency__c ='Offerings Required (Check all that apply)';
        objCustSettPartnerSESeach.DisplayName__c ='BRS Avamar';
        objCustSettPartnerSESeach.FilterValue__c ='>= \'3\'';
        objCustSettPartnerSESeach.Order__c=1;
        objCustSettPartnerSESeach.Type__c ='Text';
        lstCustSettPatnerSESearch.add(objCustSettPartnerSESeach);
        
        CustomSettingPartnerSESeach__c objCustSettPartnerSESeach1 = new CustomSettingPartnerSESeach__c();
        objCustSettPartnerSESeach1.Name ='BRS_Data_Domain_Skill__c';
        objCustSettPartnerSESeach1.Competency__c ='Offerings Required (Check all that apply)';
        objCustSettPartnerSESeach1.DisplayName__c ='BRS Data Domain';
        objCustSettPartnerSESeach1.FilterValue__c ='>= \'3\'';
        objCustSettPartnerSESeach1.Order__c=2;
        objCustSettPartnerSESeach1.Type__c ='Text';
        lstCustSettPatnerSESearch.add(objCustSettPartnerSESeach1);        
        Database.insert (lstCustSettPatnerSESearch, false);      
    }
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
         System.runAs(insertUser)
        {  
          	PRM_VPP_JobDataHelper.createVPPCustomSettingData();  
        }        
        PRM_PartnerSESearchController objPartnerSECController = new PRM_PartnerSESearchController();
        createAccount();
        contLst = createContact();
        lstSE = createPartnerSESkillrecords(contLst);
        createDistrictMappingRecord(contLst);
        objPartnerSECController.objDistrict.Theater__c ='APJ';
        objPartnerSECController.strCountryValue = '[TestCountry1, TestCountry2]';
        
        for(PRM_PartnerSESearchController.PartnerSearchContainer objPartnerSearchContainer : objPartnerSECController.lstPartnerSearchContainer){
        	for(PRM_PartnerSESearchController.DataContainer objDataContainer : objPartnerSearchContainer.lstDataContainer){
        		objDataContainer.isSelected = true;
        		break;
        	}
        }
        objPartnerSECController.seachPartnerSE();
        objPartnerSECController.DisplayExportResults();
        objPartnerSECController.DisplayPrintableResults(); 
        objPartnerSECController.displayFilter();
        objPartnerSECController.clearFilter();
  		objPartnerSECController.checkDuplicate('Test1,test2', 'Test1');
        
        for(PRM_PartnerSESearchController.PartnerSearchContainer objPartnerSearchContainer : objPartnerSECController.lstPartnerSearchContainer){
        	for(PRM_PartnerSESearchController.DataContainer objDataContainer : objPartnerSearchContainer.lstDataContainer){
        		objDataContainer.isSelected = false;
        		break;
        	}
        }
        objPartnerSECController.objDistrict.Theater__c ='APJ';
        objPartnerSECController.strCountryValue = '[TestCountry1, TestCountry2]';
        objPartnerSECController.strAreaValue = '[TestArea1, TestArea2]';
        objPartnerSECController.objDistrictPartner.District__c = lstDistrict.get(0).Id;
        objPartnerSECController.seachPartnerSE();
        
        PRM_PartnerSESearchController.PartnerWithAccountWrapper obAcct = new PRM_PartnerSESearchController.PartnerWithAccountWrapper();
		obAcct.AccountName ='Account1';
		obAcct.Size ='2';
        
    }
}