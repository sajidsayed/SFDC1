trigger updateUser on Build_Inventory__c (after update) {
    for(integer i=0; i<Trigger.new.size(); i++){
        List<Application_Requirement__c> Requirment = [select Release__c from Application_Requirement__c where Id = :Trigger.new[i].Requirement__c];
        String Release = ((Application_Requirement__c)Requirment.get(0)).Release__c;
        
        String OldDesignUser = Trigger.old[i].Design_Owner__c;
        String OldBuildUser = Trigger.old[i].Build_Owner__c;
        String OldSITUser = Trigger.old[i].SIT_Owner__c;

        String DesignUser = Trigger.new[i].Design_Owner__c;
        String BuildUser = Trigger.new[i].Build_Owner__c;
        String SITUser = Trigger.new[i].SIT_Owner__c;
        
        System.debug('Design Owner:'+OldDesignUser);
        System.debug('Release:'+Release);


        //Design Owner
        List<Allocated_Release_Workhours__c> allocation = [select Id,Design_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :OldDesignUser and Release__c = :Release];
        if(allocation != null && allocation .size()>0){
            Allocated_Release_Workhours__c alloc = ((Allocated_Release_Workhours__c)allocation.get(0));
            System.debug('Completed:'+alloc.Design_Workhours_Completed__c);
            
            if(Trigger.old[i].Work_Completed__c>0){
                alloc.Design_Workhours_Completed__c = alloc.Design_Workhours_Completed__c - Trigger.old[i].Work_Completed__c;
                update Alloc;
            }
        }
        
        List<Allocated_Release_Workhours__c> newAllocation = [select Design_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :DesignUser and Release__c = :Release];
        if(newAllocation != null && newAllocation.size()>0){
            Allocated_Release_Workhours__c newAlloc = ((Allocated_Release_Workhours__c)newAllocation.get(0));
            newAlloc.Design_Workhours_Completed__c = newAlloc.Design_Workhours_Completed__c + Trigger.new[i].Work_Completed__c;
            update newAlloc;
        }  
        
        //Build Owner
        List<Allocated_Release_Workhours__c> buildAllocation = [select Id,Build_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :OldBuildUser and Release__c = :Release];
        if(buildAllocation != null && buildAllocation .size()>0){
            Allocated_Release_Workhours__c buildAlloc = ((Allocated_Release_Workhours__c)buildAllocation .get(0));
            System.debug('Completed:'+buildAlloc .Build_Workhours_Completed__c);
            
            if(Trigger.old[i].Build_Work_Completed__c>0){
                buildAlloc.Build_Workhours_Completed__c = buildAlloc.Build_Workhours_Completed__c - Trigger.old[i].Build_Work_Completed__c;
                update buildAlloc;
            }
        }
        
        List<Allocated_Release_Workhours__c> buildNewAllocation = [select Build_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :BuildUser and Release__c = :Release];
        if(buildNewAllocation!= null && buildNewAllocation.size()>0){
            Allocated_Release_Workhours__c buildNewAlloc = ((Allocated_Release_Workhours__c)buildNewAllocation.get(0));
            buildNewAlloc.Build_Workhours_Completed__c = buildNewAlloc.Build_Workhours_Completed__c + Trigger.new[i].Build_Work_Completed__c;
            update buildNewAlloc;
        }    
        
        //SIT Owner
        List<Allocated_Release_Workhours__c> sitAllocation = [select Id,SIT_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :OldSITUser and Release__c = :Release];
        if(sitAllocation!= null && sitAllocation.size()>0){
            Allocated_Release_Workhours__c sitAlloc = ((Allocated_Release_Workhours__c)sitAllocation.get(0));
            System.debug('Completed:'+sitAlloc.SIT_Workhours_Completed__c);
            
            if(Trigger.old[i].SIT_Work_Completed__c>0){
                sitAlloc.SIT_Workhours_Completed__c = sitAlloc.SIT_Workhours_Completed__c - Trigger.old[i].SIT_Work_Completed__c;
                update sitAlloc;
            }
        }
        
        List<Allocated_Release_Workhours__c> sitNewAllocation = [select SIT_Workhours_Completed__c from Allocated_Release_Workhours__c where User__c = :SITUser and Release__c = :Release];
        if(sitNewAllocation!= null && sitNewAllocation.size()>0){
            Allocated_Release_Workhours__c sitNewAlloc = ((Allocated_Release_Workhours__c)sitNewAllocation.get(0));
            sitNewAlloc.SIT_Workhours_Completed__c = sitNewAlloc.SIT_Workhours_Completed__c + Trigger.new[i].SIT_Work_Completed__c;
            update sitNewAlloc;
        }    
        
          
        
    }

}