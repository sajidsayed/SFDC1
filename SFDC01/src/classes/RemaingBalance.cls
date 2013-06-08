public class RemaingBalance {
    
    private double availableBalance = 0.00;
    private double TotalLOE = 0.00;
    private double RemainingBalance = 0.00;
    
    public RemaingBalance(){
        getData();
    }
    
    private void getData(){
        double buildCompleted = 0.00;
        double totalAllocated = 0.00;
        
        Release__c release = [select id from Release__c where Release__c = 2 limit 1];
        List<Application_Requirement__c> req = [select id from Application_Requirement__c where Release__c = :release.Id and Removed_Release__c=false];

        List<Build_Inventory__c> inventory = [select Estimated_Design_LOE__c,Estimated_Build_Unit_Test_LOE__c,Estimated_SIT_LOE__c,Work_Completed__c,Build_Work_Completed__c,SIT_Work_Completed__c from Build_Inventory__c where Requirement__c in :req];
        if(inventory != null && inventory.size()>0){
            for(Build_Inventory__c inv : inventory){
                if(inv.Estimated_Design_LOE__c==null){
                    inv.Estimated_Design_LOE__c = 0.00;
                }
                if(inv.Estimated_Build_Unit_Test_LOE__c==null){
                    inv.Estimated_Build_Unit_Test_LOE__c = 0.00;
                }
                if(inv.Estimated_SIT_LOE__c==null){
                    inv.Estimated_SIT_LOE__c = 0.00;
                }
                TotalLOE = TotalLOE + inv.Estimated_Design_LOE__c + inv.Estimated_Build_Unit_Test_LOE__c + inv.Estimated_SIT_LOE__c;
                if(inv.Work_Completed__c==null){
                    inv.Work_Completed__c=0.00;
                }
                if(inv.Build_Work_Completed__c==null){
                    inv.Build_Work_Completed__c=0.00;
                }
                if(inv.SIT_Work_Completed__c==null){
                    inv.SIT_Work_Completed__c=0.00;
                }
                buildCompleted = buildCompleted + inv.Work_Completed__c + inv.Build_Work_Completed__c + inv.SIT_Work_Completed__c;
            }
        }
        
        /*Adding Release object starts*/
         
        List<Allocated_Release_Workhours__c> allocated = [select Allocated_Design_Workhours__c,Allocated_Build_Workhours__c,Allocated_SIT_Workhours__c from Allocated_Release_Workhours__c where Release__c = :release.Id ];

        /*Adding Release object starts*/
        //List<Allocated_Release_Workhours__c> allocated = [select Allocated_Design_Workhours__c,Allocated_Build_Workhours__c,Allocated_SIT_Workhours__c from Allocated_Release_Workhours__c where Release__c = 'a0IQ00000000C2w'];
        if(allocated != null && allocated.size()>0){
            
            for(Allocated_Release_Workhours__c all : allocated){
                if(all.Allocated_Design_Workhours__c==null){
                    all.Allocated_Design_Workhours__c=0.00;
                }
                if(all.Allocated_Build_Workhours__c==null){
                    all.Allocated_Build_Workhours__c=0.00;
                }
                if(all.Allocated_SIT_Workhours__c==null){
                    all.Allocated_SIT_Workhours__c=0.00;
                }
                
                totalAllocated = totalAllocated + all.Allocated_Design_Workhours__c + all.Allocated_Build_Workhours__c + all.Allocated_SIT_Workhours__c;
                
            }
        }
        
        availableBalance = totalAllocated - buildCompleted;
        
        RemainingBalance = TotalLOE - availableBalance;
        
    
    }
    
    public double getRemainingBalance() {
        return remainingBalance;
    }


    public double getTotalLOE() {
        return totalLOE;
    }


    public double getAvailableBalance() {
        return availableBalance;
    }


}