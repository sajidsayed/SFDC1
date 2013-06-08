/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
  Test Class Name                                      PRM_DR_Expire_EmailNotify_Schedule_TC                                                     
| 11/18/2012     Krishna Pydavula        203853        This class is used to send Expiry email Notifications. 
| 12/17/2012     Krishna Pydavula		 215851		   Changed APJ Email address in Org wide Email Addresses. 
| 01/18/2013     Krishna Pydavula		 220545		   Removed Custom label.                                                                                                       
+=====================================================================================================*/

global class PRM_DR_Expire_EmailNotify_Batchjob implements Database.Batchable<SObject> {
   
 //This custom setting is used for change the expiry days	  
Map <string,Dealreg_Expiry_Notification_days__c>  expdays=Dealreg_Expiry_Notification_days__c.getall();

Integer tendays=Integer.valueof(expdays.get('Expiry no of days1').no_of_days__c);
Integer Fourtyfivedays=Integer.valueof(expdays.get('Expiry no of days2').no_of_days__c);
Integer thirtydays=Integer.valueof(expdays.get('Expiry no of days3').no_of_days__c);  
 
date d =system.today().addDays(tendays);
date d1=system.today().addDays(Fourtyfivedays);
date d2=system.today().addDays(thirtydays);

final static String DEFAULT_QUERY ='select id,name,DealReg_Deal_Registration_Number__c,DealReg_Theater__c,DealReg_Expected_Deal_Value__c,DealReg_Expiration_Date__c,DealReg_Additional_Contact_Email_Address__c,Linked_Opportunity_Owner__c,DealReg_Deal_Submitter_Rep_Email__c,DealReg_Deal_Description__c,DealReg_Distributor_Direct_Reseller__c,Company,City,State,Country,DealReg_Distribution_VAR_Name__c,CreatedBy.Name,CreatedBy.Email,DealReg_Registered_Products__c,CurrencyIsoCode,DealReg_Deal_Registration_Status__c,DealReg_PSC_Approval_Rejection_Date_Time__c from Lead where (DealReg_Expiration_Date__c=:d OR DealReg_Expiration_Date__c=:d1 OR DealReg_Expiration_Date__c=:d2) AND (DealReg_Deal_Registration_Status__c=\'Approved\') AND (DealReg_Expiration_Date__c!=null)';
public String query;
 
global database.querylocator start(Database.BatchableContext BC) 
   {         
        if (query == null || query.length() == 0)
            { 
                query = DEFAULT_QUERY; 
            }
                 system.debug('-------query locator-----'+query); 
        return Database.getQueryLocator(query); 
   }
   global void execute(Database.BatchableContext BC,List<SObject> scope) 
    {  
        system.debug('-------record count-------'+scope);
         try{ 
                    List<Lead> ls =(Lead[]) scope;
                    system.debug('-------record count-------'+ls.size());
                    Map<string,id> maporgid=new Map<string,id>();
                    EmailTemplate templateId = [Select id,name from EmailTemplate where name = 'DR Notification_DR04'];
                    List<OrgWideEmailAddress> orgids=[select id,displayname from OrgWideEmailAddress where Address in('oppregistration@emc.com','pscapjdealregistration@emc.com','pscemeadealregistration@emc.com')];
                    for(OrgWideEmailAddress orgid: orgids)
                    {
                       if(orgid.displayname.contains('Approver'))
                    	{
                        	maporgid.put(orgid.displayname.replace('Approver','').trim(),orgid.id);
                    	}
                    	else
                    	{
                    		maporgid.put(orgid.displayname.replace('PSC-','').trim(),orgid.id);
                    	}
                        
                    }
                        if(ls.size()>0){
                              
                            for(Lead l:ls) 
                            {   
                              if((l.DealReg_PSC_Approval_Rejection_Date_Time__c.year()>=2013 && l.DealReg_Expiration_Date__c==d1) || (l.DealReg_PSC_Approval_Rejection_Date_Time__c.year()<=2012 && l.DealReg_Expiration_Date__c==d2)||(l.DealReg_Expiration_Date__c==d))
                              {  
                                String fromadd=maporgid.get(l.DealReg_Theater__c);
                                Date d=l.DealReg_Expiration_Date__c;
                                List<String> expmonth = new String[12];
								expmonth[0] = 'Jan';
								expmonth[1] = 'Feb';
								expmonth[2] = 'Mar';
								expmonth[3] = 'Apr';
								expmonth[4] = 'May';
								expmonth[5] = 'Jun';
								expmonth[6] = 'Jul';
								expmonth[7] = 'Aug';
								expmonth[8] = 'Sep';
								expmonth[9] = 'Oct';
								expmonth[10] = 'Nov';
								expmonth[11] = 'Dec';
                                Integer expmonthvalue=d.month();
                                String monthName=expmonth[expmonthvalue-1];
                                Integer expday=d.day();
                                Integer expyear=d.year();
                                String body=''+Label.The_following_EMC+'&nbsp;'+monthName+'&nbsp;'+expday+',&nbsp;'+expyear+'.';    
                                body+='<br/><br><br/><table width=\'100%\'>'+'<tr><td width=15></td><td width=150>'+ Label.Deal_Id+':'+l.DealReg_Deal_Registration_Number__c+'</td> </tr> <tr> <td width=15></td> <td width=150>'+ Label.Deal_Value+':&nbsp'+l.DealReg_Expected_Deal_Value__c+'</td></tr>    <tr> <td width=15></td><td width=150>'+ Label.Deal_Description+':'+ l.DealReg_Deal_Description__c+'</td></tr> <tr> <td>&nbsp;</td> </tr> <tr> <td width=15></td><td width=150>'+ Label.Company+': '+l.Company+'</td> </tr> <tr><td width=15></td> <td width=150>'+ Label.City+':'+ l.City+'</td> </tr> <tr> <td width=15></td><td width=150>'+Label.State_Province+':'+ l.State+'</td> </tr> <tr> <td width=15></td> <td width=150>'+Label.Country+': '+l.Country+'</td> </tr> <tr> <td width=15></td><td width=150>'+Label.VAR+':'+ l.DealReg_Distribution_VAR_Name__c+'</td> </tr> <tr><td width=15></td>  <td width=150>'+Label.Deal_Submitter_Name+':'+ l.CreatedBy.Name+'</td> </tr> <tr> <td width=15></td><td width=150>'+Label.Deal_Submitter_Email_Address+': '+l.CreatedBy.Email+'</td> </tr> <tr> <td width=15></td> <td width=150>'+Label.Deal_Currency+':'+ l.CurrencyIsoCode+'</td> </tr> <tr> <td width=15></td><td width=150>'+Label.Registration_Products+': '+l.DealReg_Registered_Products__c+'</td></tr></table>'; 
                                body+='<br/><br/>'+Label.Upon_Expiration_of_a+'';
                                body+='<br/><br/>'+Label.If_you_have_questions+'';
                                body+='<br/><br/>'+Label.Thanks+'';
                                body+='<br/><br/>'+Label.EMC_Partner_Support_Center+'';
                                body+='<br><br/>'+Label.Americas+':'+'<a href='+'oppregistration@emc.com'+'>'+'oppregistration@emc.com'+'</a>';
                                body+='<br><br/>'+Label.EMEA+':'+'<a href='+'PSCEMEADEALREGISTRATION@EMC.COM'+'>'+'PSCEMEADEALREGISTRATION@EMC.COM'+'</a>';
                                body+='<br><br/>'+Label.Asia_Pacific+':'+'<a href='+'PSCAPJDealRegistration@emc.com'+'>'+'PSCAPJDealRegistration@emc.com'+'</a>';
                                String[] toAddresses = new String[] {};
                               if(l.DealReg_Additional_Contact_Email_Address__c!=null)
                                {
                                	toAddresses.Add(l.DealReg_Additional_Contact_Email_Address__c);	
                                }
                                if(l.Linked_Opportunity_Owner__c!=null)
                                {
                                	toAddresses.Add(l.Linked_Opportunity_Owner__c);	
                                }
                                if(l.DealReg_Deal_Submitter_Rep_Email__c!=null)
                                {
                                	toAddresses.Add(l.DealReg_Deal_Submitter_Rep_Email__c);	
                                } 
                                 
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                              
                                mail.saveAsActivity = false;
                                mail.setToAddresses(toAddresses); 
                                mail.sethtmlbody(body);
                                mail.setOrgWideEmailAddressId(fromadd); 
                                mail.setSubject('EMC Deal Registration Expiration for '+l.company+'.  '+Label.Distributor_Direct_Reseller+':'+l.DealReg_Distributor_Direct_Reseller__c+'., '+Label.VAR+': '+l.DealReg_Distribution_VAR_Name__c+',  Registration #:'+l.DealReg_Deal_Registration_Number__c+''); 
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                              }   
                  
                        }
                    }
                    
         }catch(Exception ex)
         {
         	system.debug('---Exception-----'+ex);
         }     
    }
global void finish(Database.BatchableContext BC)
          { //We don't need to do anything.
          }
}