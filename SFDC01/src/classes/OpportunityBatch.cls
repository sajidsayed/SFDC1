/***

Updated On: 15-Apr-2011
Updated by: Srinivas Nallapati
Update for: Clean up UA records creation, not to cerate records for 'Channel' forecast group and create records only when Oppty is open and closedate is in future.

15-Sep-2011 Srinivas Nallapati WR173215  User Assignment records should always be created where the current opportunity owner is 'House Account' regardless of Close Date.

Updated On: 18-Nov-2011
Updated by: Shipra Misra
Update for: Commented some code which was to check condition if deletion of old records should happen or not, now deletion of old records will happen whenever this job runs. This also helps us in removing one scheduler class 'scheduleOpp_WeeklyUserAssignmentDelete'

*/
global class OpportunityBatch implements Database.Batchable<SObject>
{
    Public String Query;
    
    global OpportunityBatch(String query)
    {
       this.query = Query;
       System.debug('Query in Batch is----> '+query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope)
    {   
        List<Opportunity> Opportunities = new List<Opportunity>();
        List<User_Assignment__c> userAssignmentList = new List<User_Assignment__c>();
        Set<Id> opportunityIds = new Set<Id>();//Code Added: 12-Aug-10, Pratibh
        /***************Change for WR173215********/
        List<Opportunity> HouseOpportunityList = new List<Opportunity>();
        List<OpportunityIntegration__c> houseAcct = OpportunityIntegration__c.getall().Values();
        /************************/
        for(SObject sobjects:scope)
        {
            Opportunity opportunity = (Opportunity)sobjects;
            //if(opportunity.IsClosed==false){
            // below line updated for WR 159394
            if(opportunity.IsClosed==false && (opportunity.CloseDate >= System.today()-1)){
                Opportunities.add(opportunity);
            }/****************Change for WR173215*****************************/
            else if(opportunity.IsClosed==false && (opportunity.CloseDate < System.today()-1) && opportunity.ownerid == houseAcct[0].House_Account_User__c)
                    HouseOpportunityList.add(opportunity);
            /*******************************************************/
            opportunityIds.add(opportunity.Id);//Code Added: 12-Aug-10, Pratibh 
        }
        
        /*
        Code Added: 12-Aug-10, Pratibh
        Code for deletion of User Assignment records which are unassigned and 7 days or more old.
        */        
//        DeleteUserAssignments__c deletionParameters = DeleteUserAssignments__c.getValues('UserAssignmentsDeletionParameters');
        //If Custom Setting Flag is true then delete the perform deletion for User Assignment records. 
        //Flag is set true by weekly scheduler only which in turn ensures that deletion process only executes on weekend.
        Database.Deleteresult[] delResult;
        List <EMCException> errors = new List <EMCException>();
  //      if(deletionParameters.DeleteUnassigned__c){
            List<User_Assignment__c> userAssignmentForDelete = new List<User_Assignment__c>([Select Id 
                                                                                            from User_Assignment__c 
                                                                                            where 
                                                                                            Opportunity__c in: opportunityIds and 
                                                                                            Assignment_Status__c='Not Assigned' and 
                                                                                            CreatedDate<=:(Date.Today()-7)]);
            if(userAssignmentForDelete.size()>0){
                delResult = database.delete(userAssignmentForDelete);
            }
    //    }
        // look for any errors
        String dataErrs = '';
        if(delResult!=null){
            for (Database.Deleteresult dr : delResult) {
                if (!dr.isSuccess()) {
                    for (Database.Error err : dr.getErrors()) {
                        dataErrs += err.getMessage();
                    }
                    System.debug('An exception occurred while attempting an update on ' + dr.getId());
                    System.debug('ERROR: ' + dataErrs);
                    errors.add(new EMCException(dataErrs,'OpportunityBatch: User Assignment Deletion Error' , new String [] {dr.getId()}));
                }
            }
        }
        // log any errors that occurred
        if (errors.size() > 0)
        { 
            EMC_UTILITY.logErrors(errors);  
        }
        
        OpportunityVisibility opportunityVisibility=new OpportunityVisibility(Opportunities);        
        Map<String,List<Opportunity>> OpportunityForecastGroup = opportunityVisibility.getOpportunityWithNoForecastGroupMember();
        
        for(String Groups:OpportunityForecastGroup.KeySet())
        {
            System.debug('Group value is-->'+Groups);
            List<Opportunity> Opptys = OpportunityForecastGroup.get(Groups);            
            System.debug('Oppty value is-->'+Opptys );
            List<User_Assignment__c> opptyFGUserAssignment = opportunityVisibility.createUserAssigments(Groups,Opptys );
            System.debug('UserAssignment value is-->'+opptyFGUserAssignment );
            if(userAssignmentList.size()+opptyFGUserAssignment.size()>=999){
                opportunityVisibility.insertUserAssigments(userAssignmentList);
                userAssignmentList.clear();
                userAssignmentList.addAll(opptyFGUserAssignment);
            }
            else{
                userAssignmentList.addAll(opptyFGUserAssignment);
            }            
        }                       

// update for WR 159394, commented below code not to cerate UA records for 'Channel' forecast group
/*        
        List<User_Assignment__c> channelUserAssignment;
        channelUserAssignment = opportunityVisibility.createUserAssigments('Channel',opportunityVisibility.getPartnerOpportunityWithNoChannelMember());
        if(userAssignmentList.size()+channelUserAssignment.size()>=999){
            opportunityVisibility.insertUserAssigments(userAssignmentList);
            userAssignmentList.clear();
            userAssignmentList.addAll(channelUserAssignment);
        }
        else{
            userAssignmentList.addAll(channelUserAssignment);
        }
  */
            
        List<User_Assignment__c> houseAcctUserAssignment;
        houseAcctUserAssignment = opportunityVisibility.createUserAssigments('House Account',opportunityVisibility.getHouseAccountOpportunity());
        if(userAssignmentList.size()+houseAcctUserAssignment.size()>=999)
        {
            opportunityVisibility.insertUserAssigments(userAssignmentList);
            userAssignmentList.clear();
            userAssignmentList.addAll(houseAcctUserAssignment);
        }
        else
        {
            userAssignmentList.addAll(houseAcctUserAssignment);
        }       
        opportunityVisibility.insertUserAssigments(userAssignmentList);
         
        /***********************Change for WR173215**************************/
        List<User_Assignment__c> OnlyhouseAcctUserAssignment;
        houseAcctUserAssignment = opportunityVisibility.createUserAssigments('House Account',HouseOpportunityList);
        opportunityVisibility.insertUserAssigments(houseAcctUserAssignment);
        /********************************************************/
    }
    
    global void finish(Database.BatchableContext BC)
    {
        /*scheduleOpportunityVisibility p = new scheduleOpportunityVisibility();
        String sch = '0 0 13 * * ?';
        system.schedule('One Time Pro', sch, p);*/
        
        /*
        Code Added: 12-Aug-10, Pratibh
        Fetching Custom Setting and setting flag to false to ensure that deletion process does not get initiated from normal execution.
        */
       // DeleteUserAssignments__c deletionParameters = DeleteUserAssignments__c.getValues('UserAssignmentsDeletionParameters');
       // deletionParameters.DeleteUnassigned__c = false;
       // update deletionParameters;
    }
 
}