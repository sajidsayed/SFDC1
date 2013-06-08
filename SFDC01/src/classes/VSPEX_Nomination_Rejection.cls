/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
   ====          =========               ==         =========== 
   20-Aug-12     Ganesh                 200157      TO updte the rejected comments into the Business justification for rejection field. 
   15-May-13     Vivek					214126      Populate the values for Onboarding VAR and onboarding VAR Contact 
+=====================================================================================================*/   

public class VSPEX_Nomination_Rejection {
    
ApexPages.StandardController stdController;
public Partner_Information__c vspexObj; 
public string url, accname,VARAccName,VAR_C_Name;    
public Partner_Information__c getvspex(){       
    return vspexObj;
}
    

public VSPEX_Nomination_Rejection(ApexPages.StandardController controller) {
    stdController = controller;
    if(this.vspexObj == null){
        this.vspexObj = (Partner_Information__c)controller.getRecord();
        System.debug('SFDCDEV************'+vspexObj);
    } 
 }

public PageReference  init()
{
     String VSPEXId = ApexPages.currentPage().getParameters().get('Id');
     System.debug('SFDCDEV************'+ApexPages.currentPage().getParameters().get('Id'));
      Map<String,CustomSettingDataValueMap__c> dataValueMap = CustomSettingDataValueMap__c.getAll();
       CustomSettingDataValueMap__c VSPEXURL1= DataValueMap.get('VSPEX_URL1');
            	  CustomSettingDataValueMap__c VSPEXURL2= DataValueMap.get('VSPEX_URL2');
            	  CustomSettingDataValueMap__c VSPEXURL3= DataValueMap.get('VSPEX_URL3');
            	  CustomSettingDataValueMap__c VSPEXURL4= DataValueMap.get('VSPEX_URL4');
            	  CustomSettingDataValueMap__c VSPEXOBVAR1= DataValueMap.get('VSPEX_OBVAR1');
            	  CustomSettingDataValueMap__c VSPEXOBVAR2= DataValueMap.get('VSPEX_OBVAR2');
            	  CustomSettingDataValueMap__c VSPEX_OBVAR_C1= DataValueMap.get('VSPEX_OBVAR_C1');
            	  CustomSettingDataValueMap__c VSPEX_OBVAR_C2= DataValueMap.get('VSPEX_OBVAR_C2');
            	  
      
      system.debug('UserInfo.getUserType()'+UserInfo.getUserType());      	 
     
     if(VSPEXId==null && UserInfo.getUserType()== 'PowerPartner')
     {
     	system.debug('powerpartnere11111');
        String userID = UserInfo.getUserId();
        String profileid = Userinfo.getprofileId();        
        //Profile objVARPf = [select id,name from profile where id =:profileid];
        Map<id,Profile> mapProfile = new Map<id,Profile>([select id,name from profile where id =:profileid and name like '%VAR%']);
        system.debug('profileidprofileid'+profileid +'objProfileMap'+mapProfile);        
        User obj = [select id,Contact.Account_Name_Local__c,Contact.AccountId,Contact.Name,Contact.id from user where id=:userID]; 
        if(obj.Contact!=null)
        {
            Account Acc = [select Name,Preferred_Distributor__c from Account where id=:obj.Contact.AccountId];
             if(mapProfile.containsKey(profileid) && Acc.Preferred_Distributor__c !=null){ 
                  Account prferedAcc = [select Name,Preferred_Distributor__c from Account where id=:Acc.Preferred_Distributor__c];
        	       accname=EncodingUtil.urlEncode(prferedAcc.name, 'UTF-8');
        	       VARAccName =EncodingUtil.urlEncode(Acc.name, 'UTF-8');
        	       VAR_C_Name =EncodingUtil.urlEncode(obj.Contact.Name, 'UTF-8');
                   url = VSPEXURL1.DataValue__c+'='+accname+VSPEXURL2.DataValue__c+'='+prferedAcc.Id+VSPEXOBVAR1.DataValue__c+'='+VARAccName+VSPEXOBVAR2.DataValue__c+'='+Acc.Id
                   		 +VSPEX_OBVAR_C1.DataValue__c+'='+VAR_C_Name+VSPEX_OBVAR_C2.DataValue__c+'='+obj.Contact.id+VSPEXURL3.DataValue__c;
                   
                   String varContact = VSPEX_OBVAR_C2.DataValue__c;
                    //url = EncodingUtil.urlEncode(url, 'UTF-8');
                   return new PageReference (url);
             }
             else
             {
                accname=EncodingUtil.urlEncode(Acc.name, 'UTF-8');
                url = VSPEXURL1.DataValue__c+'='+accname+VSPEXURL2.DataValue__c+'='+Acc.Id+VSPEXURL3.DataValue__c;
                //url = EncodingUtil.urlEncode(url, 'UTF-8');
                return new PageReference (url);
             }
        }
     }
     else if(VSPEXId==null && UserInfo.getUserType()!= 'PowerPartner')
     {
        return new PageReference (VSPEXURL4.DataValue__c);
     }
     
     return null;
}
 
          
public PageReference SaveRejection(){ 
        
         try{
            
            vspexObj.Status__c='Rejected';
            update vspexObj;
           // Partner_Information__c rejectVSPEX = [Select id,Business_Justification_for_Rejection__c  from Partner_Information__c where id=: vspexObj.id];
            ProcessInstanceWorkitem objPIWI = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.Status, 
                                                p.ProcessInstance.TargetObjectId,OriginalActorId,ActorId 
                                                from ProcessInstanceWorkitem p
                                                where p.ProcessInstance.TargetObjectId =:vspexObj.Id 
                                                and ProcessInstance.Status='Pending'];                                                
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(vspexObj.Business_Justification_for_Rejection__c);             
            req2.setAction('Reject');
            req2.setWorkitemId(objPIWI.id);
            Approval.ProcessResult result2 = Approval.process(req2);       
            System.debug('SFDCDEV************'+new PageReference ('/'+ vspexObj.Id));     
            url = EncodingUtil.urlEncode('/'+ vspexObj.Id, 'UTF-8');
            return new PageReference (url);
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }  
   
    return null;    
}

}