/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  17/05/2011     Anil Sure     2829       This class is used to check the field 'Authorized Reseller revenue met?'
                                            based on the cluster and sum of the velocity revenue results.
 +==================================================================================================================**/
public class PRM_VelocityRevenueOperations {
/*@Method <This method takes list of updated Revenue Records and is used
 to update  related Profiled Account based on Cluster and sum of current Revenues
@param <This method takes list of list of new or updated Revenue records>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/ 

   public void updatevelocityRevenueProfiledAccount(List<Velocity_Revenue__c> ListUpdatedRevenue){
    List<Account> lstAccounttoUpdate = New List<Account>();
    Map<Id,Id> mapRevenueWithReleatedAccount = New Map<Id,Id>();
    List<Account> AccountToUpdate = New List<Account>();
    List<Account> profiledAccount = new List<Account>();
    List<Account> fprofiledAccount = new List<Account>();
    for(Velocity_Revenue__c velrev: ListUpdatedRevenue){
        if(velrev.Partner_Profiled_Account__c!=null){
            mapRevenueWithReleatedAccount.put(velrev.Id,velrev.Partner_Profiled_Account__c);
            }
            }
    Map<Id,Account> mapAccount = new Map<Id,Account>([select id,Cluster__c,Authorized_Reseller_Revenue_Met__c
                                                      from Account where id in:mapRevenueWithReleatedAccount.values()]);
     for(Velocity_Revenue__c velREv: ListUpdatedRevenue ){
     	Double TotalRevenue=0;
			//if(velREv.C_Curr_Per_Rev_HW_SW__c==null && velREv.C_Curr_Per_Rev_SVS__c==null && velREv.C_Prev_Per_Rev_HW_SW__c==null && velREv.C_Prev_Per_Rev_SVS__c==null)
			if(velREv.Total_Product_Curr_Per_Rev_HW_SW__c==null && velREv.Total_Product_Prev_Per_Rev_HW_SW__c==null && velREv.Total_Services_Curr_Per_Rev_SVS__c==null && velREv.Total_Services_Prev_Per_Rev_SVS__c==null)
			{
				TotalRevenue=0;
			}
		    else
			{
			   if(velREv.Total_Product_Curr_Per_Rev_HW_SW__c!=null)
			 {
			 TotalRevenue=TotalRevenue+velREv.Total_Product_Curr_Per_Rev_HW_SW__c;
			 }
			 if(velREv.Total_Product_Prev_Per_Rev_HW_SW__c!=null)
			 {
				TotalRevenue=TotalRevenue+velREv.Total_Product_Prev_Per_Rev_HW_SW__c;
			 }
			  if(velREv.Total_Services_Curr_Per_Rev_SVS__c!=null)
			 {
				TotalRevenue=TotalRevenue+velREv.Total_Services_Curr_Per_Rev_SVS__c;
			 }
			  if(velREv.Total_Services_Prev_Per_Rev_SVS__c!=null)
			 {
				TotalRevenue=TotalRevenue+velREv.Total_Services_Prev_Per_Rev_SVS__c;
			 }
		}
     	
        if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='NA')
        {        	
        	
			if(TotalRevenue>50000)            
            { 
                profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
             else
             {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
             }
            }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='LA2')
        {
        	
            if(TotalRevenue>25000)
            {
                profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
            }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='LA1')
        {
        	
			if(TotalRevenue>50000)
			 {
                 profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
        }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='EMEA 4')
        {
        	
			if(TotalRevenue>30000)
            {
                 profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
        }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='EMEA 2-3')
        {
        	
			if(TotalRevenue>50000)
            {
                 profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
        }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='EMEA 1B')
        {
        	
			if(TotalRevenue>70000)
           {
                 profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
        }
        else if(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)).Cluster__c=='APJ')
        {
        	
			if(TotalRevenue>25000)
           {
                profiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));
            }
            else
            {
                fprofiledAccount.add(mapAccount.get(mapRevenueWithReleatedAccount.get(velREv.id)));            
            }
        }
     	}
    
   if(profiledAccount.size()>0){
    for(Account profiledAcct: profiledAccount){
        profiledAcct.Authorized_Reseller_Revenue_Met__c = true;
        lstAccounttoUpdate.add(profiledAcct);
    }
   }
    
    if(fprofiledAccount.size()>0){
    for(Account fprofiledAcct: fprofiledAccount){
        fprofiledAcct.Authorized_Reseller_Revenue_Met__c = false;
        lstAccounttoUpdate.add(fprofiledAcct);
    }
   }
   update lstAccounttoUpdate;
}

}