public class TestupdateUserOnInsert  {

static testMethod void testupdateUserOnInsert() {


           User user = [Select Id from User where isActive=true limit 1];

                       
        // insert a release
           Release__c objRelease =new Release__c(
                    Name='R2',Release__c=2                   
                    );

        Database.SaveResult insertRelease = Database.insert(objRelease );
        if(insertRelease.isSuccess())System.debug('r2 insert');
        update objRelease ;
        
        
        // insert a User
                   // Util objUtil= new Util();
                    Allocated_Release_Workhours__c objARWH=new Allocated_Release_Workhours__c(
                    Allocated_Build_Workhours__c=12,
                    Allocated_Design_Workhours__c=10,
                    Allocated_SIT_Workhours__c=10,
                    Design_Workhours_Completed__c=12,
                    User__c = user.Id,
                    Release__c = objRelease.Id
                    
                   
                    );

        Database.SaveResult insertUser = Database.insert(objARWH);
        
        if(insertUser.isSuccess())
        System.debug('ARWH insert');
        
        
        update objARWH;

        
        
        
        // insert a requirements
           Application_Requirement__c objReq = new Application_Requirement__c(
                    Removed_Release__c=true,
                    Request_Type__c='Configuration',
                    Functional_Description__c = 'Test',
                    Des__c = 20,
                    ROI__c = 'test',
                    BUT__c = 20,
                    Adapt__c=12,
                    //Requirement_Title__c='Test',
                    Release__c= objRelease.Id,
                    Requestor__c=user.Id                  
                    );

        Database.SaveResult insertReq = Database.insert(objReq);
         update objReq;

 // insert a APP Inventory
            Build_Inventory__c objAI = new Build_Inventory__c(
                    Requirement__c=objReq.Id,
                    Estimated_Design_LOE__c=10,
                    Estimated_Build_Unit_Test_LOE__c = 10,
                    Estimated_SIT_LOE__c = 10,
                    Build_LOE__c=5,
                    Work_Completed__c=10,
                    Build_Work_Completed__c=10,
                    SIT_Work_Completed__c=10,
                    Design_Owner__c = user.Id,
                    Build_Owner__c = user.Id,
                    SIT_Owner__c = user.Id
                                   
                    );

        Database.SaveResult insertAI = Database.insert(objAI);
        objAI.Estimated_Design_LOE__c=5;
        objAI.Estimated_Build_Unit_Test_LOE__c =10;
        objAI.Estimated_SIT_LOE__c=10;
        objAI.Build_Work_Completed__c=10;
        objAI.SIT_Work_Completed__c=10;
        objAI.Work_Completed__c=10;
        objAI.Override_Estimated_LOE__c = true;
        objAI.Design_Owner__c = user.Id;
        objAI.Build_Owner__c = user.Id;
        objAI.SIT_Owner__c = user.Id;
        
        update objAI;
        
        
        
        RemaingBalance bal = new RemaingBalance();
        
        bal.getRemainingBalance();
        bal.getTotalLOE();
        bal.getAvailableBalance();
        




        

       }}