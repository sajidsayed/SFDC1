/*===================================================================================================================================
| Developer          DATE                     WR       Description  
| Ganesh Soma       Created on 16/08/2012    200157    This trigger will populate the VSPEX Nomination record values on the  Account.
| Krishna Pydavula  Created on 10/09/2012    208998    Added Validation for All fields.  
| Vivek             18/04/2013               243638    Added Vspex partenr field in approved condition (commented submission condition)
| Vivek				15/05/2013               214126    set empty EMC_PDM fields for VAR user 
 ===================================================================================================================================*/
trigger AfterUpdateVSPEXNomination on Partner_Information__c (after update,before update,before insert) {
   
    Map<Id,Partner_Information__c> mapAccountIdNominations = new Map<Id,Partner_Information__c>();
    List<Partner_Information__c> lstVSPEXNominationRecs = trigger.new;
    
    Set<Id> contactids=new set<Id>();
    Map<Id,Id> mapsubownconids=new Map<Id,Id>();
    Map<Id,Contact> mapsubowncondet=new Map<Id,Contact>();
    
    Set<Id> distaccid=new Set<Id>();
    Map<Id,User> mapdistaccOwnerdets= new Map<Id,User>(); 
    Map<Id,Id> mapaccOwnerids=new Map<Id,Id>();
    
    Map<id,string> mapOwnerProdileids = new Map<id,string>();
    Set<ID> ownerids = new Set<ID>();
    for(Partner_Information__c VSPEXNomination : trigger.new)
    {
      ownerids.add(VSPEXNomination.Ownerid);
      
      
      if(VSPEXNomination.Nominating_Distributor_Direct_Reseller__c!=null)
      {
        
        distaccid.add(VSPEXNomination.Nominating_Distributor_Direct_Reseller__c);
      }
    }
      List<Account> distaccownerids= [select id,ownerid from Account where id in:distaccid];
      for(Account a:distaccownerids)
      {
        ownerids.add(a.ownerid);
        if(distaccownerids.size()>0){
        mapaccOwnerids.put(a.id, a.OwnerId);
        }
      } 
    
    for(user obj : [select id,Profile_Name__c,name,email,phone,ContactId from user where id in: ownerids])
    {
      mapOwnerProdileids.put(obj.Id,obj.Profile_Name__c);
      mapdistaccOwnerdets.put(obj.Id,obj);
      contactids.add(obj.ContactId);
     
      if(obj.ContactId!=null)
      {
        mapsubownconids.put(obj.id,obj.ContactId);
      }
      
    } 
    
    List<Contact> contactinfo=[select id,name,email,phone from Contact where id in:contactids];
    for(Contact con:contactinfo)
    {
        
        if(contactinfo.size()>0)
        {
         mapsubowncondet.put(con.id,con);
        }
    }
         

    for(Partner_Information__c VSPEXNomination : trigger.new)
    {  
         
       if(VSPEXNomination.Status__c == 'Approved' || VSPEXNomination.Status__c == 'Submitted')
       {
                    
        if(VSPEXNomination.Nominating_Distributor_Direct_Reseller__c!=null)
        {
                if(mapOwnerProdileids.size()>0)
               {            
                string strProfileName = mapOwnerProdileids.get(VSPEXNomination.Ownerid);
                if(strProfileName.contains('Direct Reseller'))   
                {           
                 mapAccountIdNominations.put(VSPEXNomination.Nominating_Distributor_Direct_Reseller__c,VSPEXNomination);
                
                }
                else if(strProfileName.contains('Distributor'))
                {
                    //if the Nominating_Distributor_Direct_Reseller__c Account partner type is Distributor then consider Onboarding VAR to populate VSPEX Nomination fields
                    if(VSPEXNomination.Nominated_VAR__c!=null)
                    {
                        mapAccountIdNominations.put(VSPEXNomination.Nominated_VAR__c,VSPEXNomination);
                         
                    }
                }
            }    
                
        }
       }     
       else if(VSPEXNomination.Status__c == 'Rejected' && VSPEXNomination.Business_Justification_for_Rejection__c==null)
       {     
           VSPEXNomination.Business_Justification_for_Rejection__c.adderror('Please enter Rejection reason.');
       }     
    
        
       
    }


    //Later we need to move it to a generalized class for VSPEX Nomination
   init();

   public void init()
    {
        
        List<Account> lstAcc = [select Alliance_Partner_Relationships__c,Network_FC__c,Network_IP__c,Nomination_Approval_Date__c,Other_Network_FC__c,Other_Network_IP__c,
                                   Other_Servers__c,Partners_Service_Strategy__c,Partner_Vertical_Focus_Details__c,Partner_VSPEX_demonstration_capabilities__c,Planned_VSPEX_Solultions__c,
                                   Preferred_Line_Card_components__c,Sales_Coverage_Geo__c,Sales_Coverage_Region__c,Sales_Coverage_Theater__c,Servers__c,VAR_Recruitment_Enablement_Plan__c,
                                   VSPEX_Acreditation_Achieved__c,VSPEX_Partner__c from Account where id in:mapAccountIdNominations.keyset()];
        
        //Later we need to move it to a generalized class for VSPEX Nomination
        PopulateNominationValuesOnAccount(lstAcc);  
    }




    public void  PopulateNominationValuesOnAccount(List<Account> lstAcc)
    {
                               
             if(lstAcc.size()>0)
             {
                List<Account> lstUpdateAcc = new List<Account>();
                 for(Account acc:lstAcc)
                 {
                     Partner_Information__c objVSPEXNom =  mapAccountIdNominations.get(acc.Id);
                     if(objVSPEXNom!=null && objVSPEXNom.Status__c=='Approved')
                     {
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
                         acc.VSPEX_Partner__c=true;
                        lstUpdateAcc.add(acc);
                     }
                    /* else if(objVSPEXNom!=null && objVSPEXNom.Status__c=='Submitted')
                     {
                        acc.VSPEX_Partner__c=true;
                        lstUpdateAcc.add(acc);
                     }*/               
                     
                 }
                 
                 try{
                     update lstUpdateAcc;
                 }
                 catch(Exception e){}
             }  
        }
        
      
       //Assigning 'VSPEX Owner' once 'Accept Form' is checked
      
       string UserId=UserInfo.getUserID();
       List<User> user=[select id,name from User where id=:UserId];
       
       if(Trigger.isBefore)
       {
           for(Partner_Information__c vspex:Trigger.new)
           {
               if(vspex.Accept_Form__c == true)
               {        
                    vspex.VSPEX_Owner__c = user[0].id;              
               }
           }  
        
       }
       
       
       //Assigning Nomination Var Account owner's Details to "EMC PDM" fields.  
       if(Trigger.isBefore)
       {
	       	 if(Trigger.isInsert)
	       	 {
	       	 	String profileid = Userinfo.getprofileId();
	       	    Map<id,Profile> mapProfile = new Map<id,Profile>([select id,name from profile where id =:profileid and name like '%VAR%']);
	       	 	       	 	
	       	 	for(Partner_Information__c vspexins:Trigger.new)
	       	 	{
	       	 		 String str=mapaccOwnerids.get(vspexins.Nominating_Distributor_Direct_Reseller__c);
	       	 		 system.debug('str++++++++++'+str);
	       	 		  
	       	 		 User userobj=mapdistaccOwnerdets.get(str);
	       	 		 if(userobj!=null)
	       	 		 {
	       	 		 	//Added by vivek for WR 214126
	       	 		 	if(mapProfile.containsKey(profileid) && userobj.name == 'EMC Admin')
	       	 		 	{
	       	 		 		vspexins.EMC_PDM_Name1__c='';
	       	 		 		vspexins.EMC_PDM_Email1__c='';
	       	 		 		vspexins.EMC_PDM_Phone1__c='';
	       	 		 	}else{
	       	 		 	    vspexins.EMC_PDM_Name1__c=userobj.name;
	       	 		 		vspexins.EMC_PDM_Email1__c=userobj.email;
	       	 		 		vspexins.EMC_PDM_Phone1__c=userobj.phone;
	       	 		 	}
	       	 		 
	       	 		 }
	       	 		 
	       	 		    String str1= mapsubownconids.get(vspexins.Ownerid);
	       	 			Contact con=mapsubowncondet.get(str1);
	       	 			if(con!=null)
	       	 			{
	       	 				vspexins.Distributor_Contact_Name__c=con.Name;
	       	 				vspexins.Distributor_Contact_Email__c=con.Email;
	       	 				vspexins.Distributor_Contact_Phone__c=con.Phone;
	       	 			}
	       	 	}
	       	 	
	       	 }
       	
       
       }
       
       
}