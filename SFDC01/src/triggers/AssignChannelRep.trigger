trigger AssignChannelRep on User_Assignment__c (before update) {
     OpportunityIntegration__c lcs= OpportunityIntegration__c.getvalues('Admin Conversion');
     System.debug(lcs.Admin_Conversion__c);
    
    if(Userinfo.getUserId()!=lcs.Admin_Conversion__c) return;
     List<String> OppIds = new List<String>();
     List<String> ChannelUserIds= new List<String>();
     List<Integer> percentage= new List<Integer>();
     List<String> ForecastGroup= new List<String>();
     
       for(User_Assignment__c rec: Trigger.new ){
           String[] strAssignment=(''+rec.Assignment_Status__c).split('_');
           
           OppIds.add(rec.Opportunity__c);
           ChannelUserIds.add(rec.User__c);
           System.debug(strAssignment[0]);
           percentage.add(Integer.valueOf(strAssignment[0]));
           
           System.debug(strAssignment[1]);
           ForecastGroup.add(strAssignment[1]);
           rec.Assignment_Status__c=strAssignment[2];

           System.debug(strAssignment[2]);
       } 
    
       new ChannelVisibility().insertChannelUser(OppIds ,ChannelUserIds,percentage,ForecastGroup);          
}