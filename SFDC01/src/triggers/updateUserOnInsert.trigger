trigger updateUserOnInsert on Build_Inventory__c (after insert) {

    for(integer i=0; i<Trigger.new.size(); i++){
        List<Application_Requirement__c> Requirment = [select Release__c from Application_Requirement__c where Id = :Trigger.new[i].Requirement__c];
        String Release = ((Application_Requirement__c)Requirment.get(0)).Release__c;
        
        String DesignUser = Trigger.new[i].Design_Owner__c;
        String BuildUser = Trigger.new[i].Build_Owner__c;
        String SITUser = Trigger.new[i].SIT_Owner__c;
        
        System.debug('Release:'+Release);


        //Design Owner
        
        List<Allocated_Release_Workhours__c> newAllocation = [select Design_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :DesignUser and Release__c = :Release];
        if(newAllocation != null && newAllocation.size()>0){
            Allocated_Release_Workhours__c newAlloc = ((Allocated_Release_Workhours__c)newAllocation.get(0));
            newAlloc.Design_Workhours_Completed__c = newAlloc.Design_Workhours_Completed__c + Trigger.new[i].Work_Completed__c;
            update newAlloc;
        }  
        
        //Build Owner
        
        List<Allocated_Release_Workhours__c> buildNewAllocation = [select Build_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :BuildUser and Release__c = :Release];
        if(buildNewAllocation!= null && buildNewAllocation.size()>0){
            Allocated_Release_Workhours__c buildNewAlloc = ((Allocated_Release_Workhours__c)buildNewAllocation.get(0));
            buildNewAlloc.Build_Workhours_Completed__c = buildNewAlloc.Build_Workhours_Completed__c + Trigger.new[i].Build_Work_Completed__c;
            update buildNewAlloc;
        }    
        
        //SIT Owner
        
        List<Allocated_Release_Workhours__c> sitNewAllocation = [select SIT_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :SITUser and Release__c = :Release];
        if(sitNewAllocation!= null && sitNewAllocation.size()>0){
            Allocated_Release_Workhours__c sitNewAlloc = ((Allocated_Release_Workhours__c)sitNewAllocation.get(0));
            sitNewAlloc.SIT_Workhours_Completed__c = sitNewAlloc.SIT_Workhours_Completed__c + Trigger.new[i].SIT_Work_Completed__c;
            update sitNewAlloc;
        }    
        
          
        
    }



}