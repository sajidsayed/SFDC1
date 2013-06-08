/*
*  Created By       :- Anand Sharma
*  Created Date     :- 18/08/2010
*  Last Modified By :- Anand Sharma
*  Description      :- 
            
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER        DESCRIPTION                               
 |  ====       =========        ===========             
    18-Aug-10  Anand Sharma     This trigger will be called on insert, Update, Delete and UnDelete of Event 
                                and will check userid and EditAccess field in the custom setting. 
                                If userid and respective editaccess field has true value,then allow user to operation, otherwise throw 'insufficient priviledge' message. 
                                If OAR record contains 'Copy Resource Attribute' checked, then copy user attribute on OAR attribute.
    23-Aug-10  Anand Sharma     Handled null point exception at line 67,If no opportunity assignment rule record found.                        
    22-Nov-10  Shipra Misra    	Handled 15-18 Digit id issue
    09-Jan-12  Shipra Misra		WR-172609 SFA - Add Vertical Field to OAR (MAP Contingent)
    14-Nov-12  Vivek Kodi   	WR199084	Commented The custom setting code for OAR permissions.
    
*/

trigger CheckAccessAndCopyUserAttributes on Opportunity_Assignment_Rule__c (after undelete, before delete, before insert, before update) {
    //get login user id
    ID strUserId = Userinfo.getUserId();
    //hold permission flag value
    Boolean blnCheckAccess = false;
    //hold resource user ids
    Set<Id> setUserIds = new Set<Id>();
    //hold list of Opportunity Assignment records
    List<Opportunity_Assignment_Rule__c> lstOppAssigmRule = new List<Opportunity_Assignment_Rule__c>();
    //Bolean checks if OAR is for House Account.
    Boolean IsHouseAccount;
    //fetch value from custom setting
   /* List<AccessOnUserAssignmentRule__c> lstAccUserAssgn = AccessOnUserAssignmentRule__c.getAll().values();
    System.debug('lstAccUserAssgn--->'+lstAccUserAssgn);
    for(AccessOnUserAssignmentRule__c objAccUserAssgn:lstAccUserAssgn){
        if(objAccUserAssgn.UserID__c == strUserId){
            blnCheckAccess = true;
            System.debug('objAccUserAssgn.UserID__c--->'+objAccUserAssgn.UserID__c+'strUserId'+strUserId);
            System.debug('blnCheckAccess--->'+blnCheckAccess);
            break;
        }
    }*/
        
    if(Trigger.isBefore){
        if(Trigger.isInsert ||Trigger.isUpdate){
            lstOppAssigmRule = Trigger.new;
        }else if(Trigger.isDelete){
            lstOppAssigmRule = Trigger.old;
        }
    }else if(Trigger.isAfter){
        if(Trigger.isUnDelete){
            lstOppAssigmRule = Trigger.new;
        }
    }
    if(Trigger.isInsert || Trigger.isUpdate)
    {   
        for(Opportunity_Assignment_Rule__c objOAR : Trigger.new)
        {
            String strOARExpression='^';IsHouseAccount=false;
            if(objOAR.Apply_to_House_Account__c==true)
            {
                IsHouseAccount=true;
            }
            if(objOAR.ResourceAccountTheater__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'accounttheater'+objOAR.ResourceAccountTheater__c.toLowerCase()+'accounttheater'+'\\b)';
            }
            if(objOAR.ResourceCountry__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'country'+objOAR.ResourceCountry__c.toLowerCase()+'country'+'\\b)';
            }
            if(objOAR.ResourceState__c!=''&& objOAR.ResourceState__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'state'+objOAR.ResourceState__c.toLowerCase()+'state'+'\\b)';
            }
            if(objOAR.Coverage_Model__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'coveragemodel'+objOAR.Coverage_Model__c.toLowerCase()+'coveragemodel'+'\\b)';
            }
            if(objOAR.Customer_Segment__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'customersegment'+objOAR.Customer_Segment__c.toLowerCase()+'customersegment'+'\\b)';
            }
            if(objOAR.EMC_Major_Vertical_Account__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'emcmajorvertical'+objOAR.EMC_Major_Vertical_Account__c.toLowerCase()+'emcmajorvertical'+'\\b)';
            }
            if(objOAR.EMC_Classification__c!=null)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'classification'+objOAR.EMC_Classification__c.toLowerCase()+'classification'+'\\b)';
            }
            if(objOAR.Resource_Sales_Force__c !=null) 
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'salesforce'+objOAR.Resource_Sales_Force__c.toLowerCase()+'salesforce'+'\\b)';
            }
            if(objOAR.ResourceTheatre__c!=null && IsHouseAccount==false)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'theater'+objOAR.ResourceTheatre__c.toLowerCase()+'theater'+'\\b)';
            }
            if(objOAR.ResourceArea__c!=null && IsHouseAccount==false)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'area'+objOAR.ResourceArea__c.toLowerCase()+'area'+'\\b)';
            }
            if(objOAR.ResourceDistrict__c!=null && IsHouseAccount==false)
            {
                 strOARExpression=strOARExpression+'(?=.*?\\b'+'district'+objOAR.ResourceDistrict__c.toLowerCase()+'district'+'\\b)';
            }
            if(objOAR.ResourceDivision__c!=null && IsHouseAccount==false)
            {
                 strOARExpression=strOARExpression+'(?=.*?\\b'+'division'+objOAR.ResourceDivision__c.toLowerCase()+'division'+'\\b)';
            }
            if(objOAR.ResourceRegion__c!=null && IsHouseAccount==false)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+'region'+objOAR.ResourceRegion__c.toLowerCase()+'region'+'\\b)';
            }
            if(objOAR.Name_Account_Owner__c!=null && IsHouseAccount==false)
            {
                strOARExpression=strOARExpression+'(?=.*?\\b'+objOAR.Name_Account_Owner__c+'\\b)';
            }
            strOARExpression=strOARExpression+'.*$';
            objOAR.Expression_Oar__c=   strOARExpression;
        }
    }
    if(lstOppAssigmRule.size() <=0) return;
    //if user found in custom setting with edit permission
   /* if(!blnCheckAccess)
    {
        for(Opportunity_Assignment_Rule__c objOAR : lstOppAssigmRule){
            objOAR.addError('Insufficient privilege');
    }
    }*/
        
}