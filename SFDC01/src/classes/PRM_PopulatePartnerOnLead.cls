/*===========================================================================+
 |  HISTORY      
 |  FD009: Lead Distribution: Default Distributor as Partner 
 |  (Tier1 Partner/Distributor, Tier 2 Partner)                                                            
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 |  25-Jun-10  Saravanan C   Initial creation
 |  18-Jul-10  Prasad kothawade Added the CAM_Email field to get the value. at line 83
 |  20-Jul-10  Saravanan C   Updated for removing soql queries from for loop 
 |  04-Aug-10  Saravanan C   Validation is added for user Cannot Accept and Reject a Lead simultaneously
 |  02-Sep-10  Suman B       Modified populatePartneronLead method to set the value for LastInsideSalesOwner field for Req#777.
 |  02-Sep-10  Anirudh       Req#987 Added Channel field update for Partner Users. 
 |  23-Sep-10  Suman B       Req# 1117  Changed the Account Field PartnerType value. Accordingly modifying the condition 
 |                           check using Custom settings value. 
 |  08-Oct-10 Ashwini Gowda  Removed the functionality check in case when a Lead
 |                           is assigned to Queue.Commented Line 35,43 to 45,84 to 87,162 to 169.
 |  12-Oct-10  Suman B       Req#1184 Modified populatePartneronLead method to set the value for LastEMCOwner field.
 |  10-Oct-10  Ashwini Gowda Req#1318 Uncommented Lines 35,43 to 45,84 to 87,162 to 169.
 |                                    As the issue is fixed in PRM_CommonUtils class.
 |  25-Oct-10  Ashwini Gowda Commented Hardcoded error message and updated to custom label. 
 |  15-Dec-10  Suman B       Req#1742 Modified the populatePartneronLead method  to set LastInsideSalesOwner 
 |                           field based on profile - AMER Inside Sales/SMB User.
 |  
 |  11-Dec-11  Prasad K      Defect #163 - bypasing populate partner for Lead routing 
 |  30-05-2011 Anand Sharma  Deal Reg : If the partner type contains both the Direct Reseller and Distribution VAR as the value, 
 |                           then you should NOT auto-update either the Distributor/Direct Reseller or Distribution VAR fields.
 |  05-08-2011 Srinivas N    WR-171819 Add APJ & EMEA Inside Sales profiles to 'Last Inside Sales Owner' logic  
 |  19-08-2011 Aniurdh S     WR-3676  UpdatePartnerAccount Method to populate Disti Var Account if Partner Type Contains Distribution VAR
 |  08-10-2011 Anand Sharma  Req#2849 updated createLastEMCOwnerLeadShare and populatePartneronLead method to create share record to give edit access
 |  21-02-2012 Kaustav D     Added a null check to check for isPartner.get(l.OwnerId)
 |  02-01-2013 vivek         code added for the emc Lead pull back
 |  15May2013  Vivek         WR# 225313 Passtopatner set to false for partner users using few criteria.   
 +==========================================================================================*/


public Class PRM_PopulatePartnerOnLead{	

    /*** Variables ***/
    PRM_CommonUtils utils = new PRM_CommonUtils();
    Map<Id,User> isPartner = new Map<Id,User>();
    Map<Id,Contact> usrDtls = new Map<Id,Contact> ();
    Map<Id,Account> grpDtls = new Map<Id,Account>();
    Map<Id,Account> accDtls = new Map<Id,Account>();
    Public Static boolean LeadRoutingExecution=false;

    /**
    *populatePartneronLead(List <Lead> Leads) records that are passed in input
    *@param List<Lead> Leads - List of leads that need to be Populate Partner.
    */

    public void populatePartneronLead(List <Lead> Leads){
        list<Id> usrId = new list<Id>();
        list<Id> grpId = new list<Id>();
        list<Id> isPartnerId = new list<Id>();        
        
        if(LeadRoutingExecution){
            return;
        }

        for(lead l: Leads ){    
            if(((string)l.OwnerId).startswith('005')){
                usrId.add(l.ownerId);
                isPartnerId.add(l.ownerId);
            }else if(((string)l.OwnerId).startswith('00G')){
                grpId.add(l.ownerId);
            }     
        } 
        isPartnerId.add(UserInfo.getUserId());
        // Invoking PRM_CommonUtils.userDetails class
        isPartner = utils.userDetails(isPartnerId);
        system.debug('==>'+isPartner+UserInfo.getUserId()+' isPartnerId ==>'+isPartnerId );
            
        if(usrId.size() >=1){
            // Invoking PRM_CommonUtils.fromUser class
            usrDtls = utils.fromUser(usrId);
            list<Id> accId = new list<Id>();
            system.debug('usrDtls  ===>'+usrId+usrDtls  );
            if(Leads.size()>0){
                for(lead l: Leads){
                    if(((string)l.OwnerId).startswith('005')){
                        //Added null check on 21st Feb 2012 because owner may not be present in the isPartner map
                        if(isPartner.containsKey(l.OwnerId))
                        {
                            if(isPartner.get(l.OwnerId).UserType == 'PowerPartner'){
                                // Added on 3-Sep-2010 for Req#987
                                l.Channel__c='Indirect'; 
                                if(usrDtls.get(l.ownerid)!=null){
                                    if(usrDtls.get(l.ownerid).account.Profiled_Account__c == null){
                                    }else{
                                        accId.add(usrDtls.get(l.ownerid).account.Profiled_Account__c);
                                    }
                                }  
                            }
                        }
                        
                        /** Modified as per Req#1742. **/         
                        // Added on 2-Sep-2010 for Req#777.
                        Profiles__c profiles = Profiles__c.getInstance();
                        //Change for WR-171819
                        if(isPartner.get(l.OwnerId).ProfileId == profiles.AMER_Inside_Sales_SMB_User__c || isPartner.get(l.OwnerId).ProfileId == profiles.APJ_Inside_Sales_SMB_User__c
                           ||isPartner.get(l.OwnerId).ProfileId == profiles.APJ_Inside_Sales_SMB_User_Double_Byte__c || isPartner.get(l.OwnerId).ProfileId == profiles.EMEA_Inside_Sales_SMB_User__c
                           ||isPartner.get(l.OwnerId).ProfileId == profiles.Sales_Associate_User__c
                           ){
                                 l.Last_Inside_Sales_Owner__c = l.OwnerId ;
                        }
                        //End on Change for WR-171819
                        // changes End -Req#777.
                       
                        /** Added for Req#1184. 
                        If UserType is not a 'PowerPartner' assuming User to be Internal User **/
                        if (isPartner.get(l.OwnerId).UserType != 'PowerPartner' ) {
                            l.Last_EMC_Owner__c = l.OwnerId ;
                            
                            /* Change Start Req#2849 Anand Sharma */
                            if(l.LastEMCOwnerIds__c != null && l.LastEMCOwnerIds__c != ''){
                                String strOwnerId = l.OwnerId;
                                if( ! l.LastEMCOwnerIds__c.contains(strOwnerId)){
                                    l.LastEMCOwnerIds__c = l.LastEMCOwnerIds__c + ',' + l.OwnerId;
                                }                               
                            }else{
                                l.LastEMCOwnerIds__c = l.OwnerId;
                            }
                            
                            /* Req#2849 Anand Sharma */ 
                        }
                        /** Changes End -1184  **/   
                    }
                }
            }
            if(accId.size() > 0){
                Account[] accs = [select Partner_Type__c from account where id in: accId ];
                for(Account a: accs){
                    accDtls.put(a.id,a);
                }          
            }
        }
        log( 'grpId.size()===> '+ grpId.size());
        if(grpId.size() >=1){
            // Invoking PRM_CommonUtils.fromGroup class
            grpDtls = utils.fromGroup(grpId); 
            log( 'grpDtls ===> '+ grpDtls );
        }
    
        for(lead l: Leads ){
            updatePartnerAccount(l,leadAssignedDistiorEMCuser());
        }
        
    }
  
  
  /**
    * updatePartnerInfo lead record and string value whether the user is Disti or Partner are passed.
    * This method will populate partner info on lead record that is passed.
    * @param lead lead record
    * @param string distributor or EMC user
    */
    public void updatePartnerAccount(lead l,string distiorEMCuser){    
        string partnerType;
    
        /** Added as per Req#1117. **/
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String distributionVAR = data.get('Tier2 Partner Type').DataValue__c ;
        String DirectReseller = data.get('Direct Reseller Partner Type').DataValue__c;
        String Distributor = data.get('Distributor Partner Type').DataValue__c;
        /** Changes End.  **/
        
        //Added by anand on 30/05/2011 for Deal reg 
        String DealregRecordType = data.get('DealRegistration').DataValue__c ;
        String DealregDistributorType = data.get('DealregDistributorType').DataValue__c ;
        String DealregDistributionVarType = data.get('DealregDistributionVarType').DataValue__c ;
        String DealregDistributorResellerType = data.get('DealregDistributorResellerType').DataValue__c ;
        String strDealregRecordType = l.RecordTypeId;
        if(strDealregRecordType!= null && strDealregRecordType!= '' && strDealregRecordType.length() > 15){
            strDealregRecordType = strDealregRecordType.substring(0, 15);
        }
        //End        
            
        /*** Lead Owner is partner ? ****/
        log( 'Lead Owner is partner ?' );

        /*** Is Lead Owner is from User object or Queue ? ****/
        log( 'Is Lead Owner is from User object or Queue ?' );
            
        // Validation is added User Cannot Accept and Reject a Lead simultaneously
        if(l.Reject_Lead__c == True && l.Accept_Lead__c == True ){
            //Commented Hardcoded error message and updated to custom label
            //l.addError('You Cannot Accept and Reject a Lead simultaneously');           
            l.addError(System.Label.Cannot_Accept_And_Reject_Lead_Same_Time);
        }else{  
            if(((string)l.OwnerId).startswith('005') && isPartner.get(l.OwnerId) != null ){
                if(isPartner.get(l.OwnerId).UserType == 'PowerPartner'){
                    //  For user id starts with '005' is from user object 
                    //EMC user assigns a Lead to a Partner User
                    /*** Yes Lead Owner is from User Object****/
                    log( 'Yes Lead Owner is from User Object' );
                    try{
                        if(usrDtls.get(l.ownerid).account.Partner_Type__c == null){
                            if(usrDtls.get(l.ownerid).account.Profiled_Account__c != null){
                                partnerType = accDtls.get(usrDtls.get(l.ownerid).account.Profiled_Account__c).Partner_Type__c;
                            }else{
                                partnerType = 'update tier 1/ distributor';
                            }
                        }else{
                            partnerType = usrDtls.get(l.ownerid).account.Partner_Type__c;
                        }
                        
                        
                        //Added by anand on 30/05/2011 for Deal reg                                                            
                        if(DealregRecordType.contains(strDealregRecordType)){
                            if( (checkDistributorPartnerForDealReg(partnerType, DealregDistributorType) || checkDistributorPartnerForDealReg(partnerType, DealregDistributorResellerType) ||checkDistributionVarPartnerForDealReg(partnerType,DealregDistributionVarType))){
                                /*** Is Account Tier 2 Partner Account ****/
                                log( 'Is Account Tier 2 Partner Account'+ partnerType );                         
                                if(partnerType.contains(distributionVAR) && !(partnerType.contains(DirectReseller))&& !(partnerType.contains(Distributor)) && usrDtls.get(l.ownerid).account.Lead_Oppty_Enabled__c == True){
                                    /*** Yes ****/
                                    log( 'Yes---byAnirudh' );                    
                                    l.Tier_2_Partner__c = usrDtls.get(l.ownerid).account.id;
                                    if(usrDtls.get(l.ownerid).account.Preferred_Distributor__c!=null){
                                       l.Partner__c=usrDtls.get(l.ownerid).account.Preferred_Distributor__c;
                                    }
                                    else if(usrDtls.get(l.ownerid).account.Profiled_Account__r.Preferred_Distributor__c!=null){
                                       l.Partner__c= usrDtls.get(l.ownerid).account.Profiled_Account__r.Preferred_Distributor__c;   
                                    }
                                    System.debug('PreferredDisty-->' +usrDtls.get(l.ownerid).account.Profiled_Account__r.Preferred_Distributor__c);
                                }else if (partnerType.contains(DirectReseller)|| partnerType.contains(Distributor)){
                                    /*** No ****/
                                    log( 'No' );                            
                                    //    if(distiorEMCuser == 'EMCuser'){
                                    l.Partner__c = usrDtls.get(l.ownerid).account.id;
                                    log( '===> '+ l.Partner__c);
                                    log( '===> '+ userinfo.getprofileid());
                                    //   }
                                }
                            }
                        }else{                      
                            /*** Is Account Tier 2 Partner Account ****/
                            log( 'Is Account Tier 2 Partner Account'+ partnerType );                         
                            if(partnerType.contains(distributionVAR)&& !(partnerType.contains(DirectReseller))&& !(partnerType.contains(Distributor)) && usrDtls.get(l.ownerid).account.Lead_Oppty_Enabled__c == True){
                                /*** Yes ****/
                                log( 'Yes' );                    
                                l.Tier_2_Partner__c = usrDtls.get(l.ownerid).account.id;
                            }else if (partnerType.contains(DirectReseller)|| partnerType.contains(Distributor)){
                                /*** No ****/
                                log( 'No' );                            
                                //    if(distiorEMCuser == 'EMCuser'){
                                l.Partner__c = usrDtls.get(l.ownerid).account.id;
                                log( '===> '+ l.Partner__c);
                                log( '===> '+ userinfo.getprofileid());
                                //   }
                            }
                        }
                        // Added by prasad to update CAM Email.
                        l.Previous_CAM_Email__c=l.CAM_Email__c;
                        l.CAM_Email__c=usrDtls.get(l.ownerid).account.owner.Email;
                    }catch (exception e ){
                    }
                }
            }/***   For user id starts with '00G' is from Queue 
                  No Load Owner is from Group ****/
            else if(((string)l.OwnerId).startswith('00G')){            
                log( 'No Load Owner is from Group' );                  
                try{
                    if(grpDtls.get(l.ownerid).Partner_Type__c == null ){
                        if(grpDtls.get(l.ownerid).Profiled_Account__c != null ){
                            partnerType = grpDtls.get(l.ownerid).Profiled_Account__r.Partner_Type__c;
                        }else{
                            partnerType = 'update tier 1/ distributor';
                        }
                    }else{
                        partnerType = grpDtls.get(l.ownerid).Partner_Type__c;
                    }
                    
                    //Added by anand on 30/05/2011 for Deal reg   
                    System.debug('DealregRecordType.contains(strDealregRecordType)Anirudh-->' +DealregRecordType.contains(strDealregRecordType)) ;                                     
                    if(DealregRecordType.contains(strDealregRecordType)){
                        if( (checkDistributorPartnerForDealReg(partnerType, DealregDistributorType) || checkDistributorPartnerForDealReg(partnerType, DealregDistributorResellerType)||checkDistributionVarPartnerForDealReg(partnerType,DealregDistributionVarType))){
                            //Is Account Tier 2 Partner Account 
                            log( 'Is Account Tier 2 Partner Account' );
                             
                            if(partnerType.contains(distributionVAR) && !(partnerType.contains(DirectReseller))&& !(partnerType.contains(Distributor)) && grpDtls.get(l.ownerid).Lead_Oppty_Enabled__c == True){
                                //Yes 
                                log( 'Yes' );                        
                                l.Tier_2_Partner__c = grpDtls.get(l.ownerid).id;
                            }                   
                            else if (partnerType.contains(DirectReseller)|| partnerType.contains(Distributor)){
                                // No 
                                log( 'No' ); 
                                l.Partner__c = grpDtls.get(l.ownerid).id;
                            }
                        } 
                    }else{
                        //Is Account Tier 2 Partner Account 
                        log( 'Is Account Tier 2 Partner Account' );
                         
                        if(partnerType.contains(distributionVAR)&& !(partnerType.contains(DirectReseller))&& !(partnerType.contains(Distributor))  && grpDtls.get(l.ownerid).Lead_Oppty_Enabled__c == True){
                            //Yes 
                            log( 'Yes' );                        
                            l.Tier_2_Partner__c = grpDtls.get(l.ownerid).id;
                        }                   
                        else if (partnerType.contains(DirectReseller)|| partnerType.contains(Distributor)){
                            // No 
                            log( 'No' ); 
                            l.Partner__c = grpDtls.get(l.ownerid).id;
                        }
                    }
                }
                catch (exception e ){                    
                }
            }        
        }
    }
   
    /**
    *leadAssignedDistiorEMCuser() : this method will validate wether the current user is Disti or Partner user.
    *@return string Distributor or EMCuser or null.
    */  
    public String leadAssignedDistiorEMCuser(){
        string distiorEMCuser; // local variable
        /*** Distrubuter User ? ****/
        log( 'Distrubuter User ?' );
        //Added by Ashwini Gowda to include custom setting for Distributor user
        // User profile is Distributor Partner User
        //if(UserInfo.getprofileId() == '00eS0000000E3vl' ){
        Profiles__c profileId = Profiles__c.getInstance();
        if(UserInfo.getprofileId() == profileId.Distributor_Partner_User__c){
            /*** Yes Distributor User  ****/
            log( 'Yes Distributor User' );
            distiorEMCuser = 'Distributor';
        }else if(isPartner.get(UserInfo.getUserId()).UserType != 'PowerPartner'){
            // For all users who is not Partner User and user profile is not Distributor Partner User
            // is assumed as EMC User.
            /*** No EMC User  ****/
            log( ' EMC User' );
            distiorEMCuser = 'EMCuser';
        }
        return distiorEMCuser;
    }
   
    private void log(String logMsg){
        System.debug('********* '+logMsg+' *********');
    }
    
    public static void logFailedRecords(Database.Saveresult[]resultrecords){
        List <EMCException> errors = new List <EMCException>();
        for( Database.Saveresult sr : resultrecords) {
            String dataErrs = '';
            if (!sr.isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + sr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, System.label.Populate_Partner_on_Lead_Batch, new String [] {sr.getId()}));
            }
        }  
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        } 
    }
    public static Boolean checkDistributorPartnerForDealReg(String partnerType, String DealregDistributorType){
        Boolean DistributorCheck = false;
        Set<String> setDistributor = new Set<String>();
        System.Debug('partnerType-->' +partnerType);
        System.Debug('DealregDistributorType-->' +DealregDistributorType);
        if(partnerType != null && partnerType !=''){
            String[] arrPartnerType = partnerType.split(';');           
            if(arrPartnerType.size() >0){               
                for(String strPartnerType :arrPartnerType){
                    setDistributor.add(strPartnerType.toLowerCase());                   
                }               
            }                           
        }
        
        String[] arrDistrubutorType = DealregDistributorType.split(',');        
        if(arrDistrubutorType.size() >0){
            for(String strDistrubutorType: arrDistrubutorType){
                if(setDistributor.contains(strDistrubutorType.toLowerCase())){
                    DistributorCheck = true;
                }else{
                    DistributorCheck = false;
                    break;
                }
            }
        }
        if(partnerType=='Distributor' || partnerType=='Direct Reseller'){
           DistributorCheck = true;
        }
       
        return DistributorCheck;
    }
    
    public static Boolean checkDistributionVarPartnerForDealReg(String partnerType, String DealregDistributionVarType){
        Boolean DistributionVarCheck = false;
        Set<String> setDistributionVar = new Set<String>();
        String Distributor = 'Distributor';
        String DirectReseller = 'Direct Reseller';
        System.Debug('partnerType-->' +partnerType);
        System.Debug('DealregDistributionVarType-->' +DealregDistributionVarType);
        System.Debug('IfconditionCheck-->' + partnerType != null && partnerType !='' && (partnerType.indexOf(';')!=-1));
        if(partnerType != null && partnerType !='' && (partnerType.indexOf(';')!=-1) ){
            String[] arrPartnerType = partnerType.split(';');           
            if(arrPartnerType.size() >0){               
                for(String strPartnerType :arrPartnerType){
                    setDistributionVar.add(strPartnerType);                   
                }               
            }                           
        }else{
              setDistributionVar.add(partnerType);
        }
        System.Debug('setDistributionVar--->' +setDistributionVar);
                
        String arrDistrubutionVarType = DealregDistributionVarType;        
        if(setDistributionVar.contains(arrDistrubutionVarType) && !setDistributionVar.contains(Distributor )&& !setDistributionVar.contains(DirectReseller)){
           DistributionVarCheck = true;
        }
         System.Debug('DistributionVarCheck--->' +DistributionVarCheck );
        return DistributionVarCheck ;
    }
    
    public void  setPassToPartnerFlagOnLead(List<Lead> lstLeads){
            String strLeadOwnerId ='';
            List<String> leadOwneridsList = new List<String>();
            Set<String> partnerUseridsSet = new Set<String>();
            Map<Id,Id> MapLeadOwnerQueueIds = New Map<Id,Id>();
            Map<String, CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
            Id SiteUserId = DataValueMap.get('SiteUserId').DataValue__c;
            Set<Id> SetPartnerQueueIds = New Set<Id>();
            for(lead leadobj:lstLeads){
                if(leadobj.ownerId!=null){
                    strLeadOwnerId=leadobj.ownerId;
                    if(strLeadOwnerId.substring(0,3) !='00G'){
                            leadOwneridsList.add(leadObj.OwnerId);   
                    } 
                    if(strLeadOwnerId.substring(0,3) =='00G'){
                       MapLeadOwnerQueueIds.put(leadObj.OwnerId,leadObj.Id);    
                    }
                }
                
            }
            Map<Id,QueueSobject> MapPartnerQueue = New Map<Id,QueueSobject>([Select Id, SobjectType, QueueId, Queue.Name from QueueSobject where Queue.Name like'Partner%' and QueueId in :MapLeadOwnerQueueIds.keyset()]);
            for(QueueSobject queueObj :MapPartnerQueue.values()){
                SetPartnerQueueIds.add(queueObj.QueueId);
            }
            PRM_CommonUtils prmCommUtilObj = new PRM_CommonUtils();    
            partnerUseridsSet = prmCommUtilObj.userType(leadOwneridsList); 
            //Adding Site User also to PartnerUserIdsSet
            partnerUseridsSet.add(SiteUserId);            
            for(lead leadobj:lstLeads){
            	if((leadobj.Partner__c !=null || leadobj.Tier_2_Partner__c !=null) && ((partnerUseridsSet.contains(leadobj.OwnerId)) || SetPartnerQueueIds.contains(leadobj.OwnerId))){            		
                    leadobj.Passed_to_Partner__c=true;
                }
                else{
                    leadobj.Passed_to_Partner__c=false;
                }
                
            }
            
        }
        
        public static void setPassToPartnerFlagOnLeadwithpartner(List<Lead> newLeads){            
             //WR #225313
			   Map <id,User> objPartneruser = new Map<id,User>([Select u.id,u.name, u.UserType From User u where u.IsActive=true and u.usertype like '%partner%']);
			   system.debug('testing logging'+Userinfo.getuserid() +'newLeads'+newLeads);
	           system.debug('objPartneruser'+objPartneruser); 
	           for(Lead leadobj :newLeads){
	                if(objPartneruser.containsKey(Userinfo.getuserid())&& objPartneruser.containsKey(leadobj.ownerId) && leadobj.Lead_Originator__c == 'Partner' && leadobj.Originator_Details__c == 'Partner Created' && leadobj.Last_EMC_Owner__c == null){
	                	system.debug('testing loggingtesting sucessss');
	                     leadobj.Passed_to_Partner__c=false;
	                     leadobj.Passed_to_Partner_Date_Time__c = null;
	                }
	            } 
               //End WR #225313
        }  
    
    public static void createLastEMCOwnerLeadShare(List<Lead> lstLead){
            //System.Debug('setLead--->' +setLead);
            //List<Lead> lstLead = [Select id, LastEMCOwnerIds__c from Lead where id in : setLead];
            System.Debug('lstLead--->' +lstLead);
            List<LeadShare> leadShareList = new List<LeadShare>();
            //try{ 
                for(Lead leadObj :lstLead){
                    if(leadObj.LastEMCOwnerIds__c != null && leadObj.LastEMCOwnerIds__c != ''){
                        System.Debug('leadObj.LastEMCOwnerIds__c--->' + leadObj.LastEMCOwnerIds__c);
                        String[] arrLastEMCOwnerIds = leadObj.LastEMCOwnerIds__c.split(',');
                        for(String strLastEMCOwnerIds : arrLastEMCOwnerIds){
                            try{
                                Id idLastEMCOwner = strLastEMCOwnerIds;
                                leadShareList.add(new LeadShare(UserOrGroupId= idLastEMCOwner,LeadAccessLevel='Edit',LeadId=leadObj.Id));   
                            }Catch(Exception ex){
                                
                            }
                            
                        }                       
                    }                            
                }                          
                if(leadShareList.size() > 0){
                    Database.Saveresult[] result = Database.insert (leadShareList, false);
                    System.Debug('result--->' +result);
                }
                
           /*}
           Catch(DmlException ex){
                   System.Debug('ExceptionInsertFailed-->' +ex);
    
           }*/
        } 
        
     //WR #206404
     public void  UpdateOwnerforLeadPullback(List<Lead> Newrecs){
        Set<id> LastEMCId = new Set<id>();
        for(Lead LastEmc:Newrecs){
            LastEMCId.add(LastEmc.OwnerId);
        }       
        Map<id,User> CheckLastEMCOwner = new Map<id,User>([Select u.id, u.name, u.UserType From User u where u.IsActive=false and u.id in:LastEMCId and  u.usertype like '%Standard%' ]);
        System.debug('NewrecsNewrecs'+Newrecs);
        for(Lead objOwner:Newrecs){               
              if((objOwner.LeadOwnerchek__c == true)  && objOwner.Last_EMC_Owner__c !=null){
                  objOwner.Previous_Owner__c = objOwner.OwnerId;                
                  objOwner.OwnerId = objOwner.Last_EMC_Owner__c;
                  //reset
                  objOwner.Accept_Lead__c = true;
                  objOwner.SLA_For_Passed_to_Partner_date_time__c = null;
                  objOwner.Final_SLA_For_Passed_to_Partnerdate_time__c = null;
                  objOwner.SLA_For_Passed_to_Partner_Change_Owner__c = null;
                  objOwner.EvaluateFlag__c = false;
                  objOwner.LeadOwnerchek__c = false;
                  
              }
              if(CheckLastEMCOwner.containsKey(objOwner.Last_EMC_Owner__c) && objOwner.LeadOwnerchek__c == true &&objOwner.Previous_Owner__c !=null){
                  objOwner.Last_EMC_Owner__c = objOwner.Previous_Owner__c;
                  objOwner.OwnerId = objOwner.Previous_Owner__c;
                  objOwner.Accept_Lead__c = true;
                  objOwner.SLA_For_Passed_to_Partner_date_time__c = null;
                  objOwner.Final_SLA_For_Passed_to_Partnerdate_time__c = null;
                  objOwner.SLA_For_Passed_to_Partner_Change_Owner__c = null;
                  objOwner.EvaluateFlag__c = false;                  
                  objOwner.LeadOwnerchek__c = false;
              }
        }
     }  
     //WR #207171
     public void UpdateOwnerforDealReg(List<Lead> Newrcs){
        for(Lead objOwner:Newrcs){
            System.debug('NewrcsNewrcsNewrcs'+Newrcs);
            if(objOwner.DealRegOwner__c == true && objOwner.Last_EMC_Owner__c !=null){
                 objOwner.Previous_Owner__c = objOwner.OwnerId;   
                 objOwner.OwnerId = objOwner.Last_EMC_Owner__c;
                 //reset lead
                 objOwner.Accept_Lead__c = true;
                 objOwner.SLA_For_Accepted_Change_Owner_date_time__c = null;
                 objOwner.SLA_For_Accepted_date_time__c = null;
                 objOwner.Final_SLA_For_Accepted_date_time__c = null;
                 objOwner.Evaluate__c = false;
                 objOwner.DealRegOwner__c = false;
            }
        }
     }       
}// Class END