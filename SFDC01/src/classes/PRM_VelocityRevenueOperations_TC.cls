/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  23/05/2011     Anil Sure     2829       Unit Test for PRM_VelocityRevenueOperations class.
 +==================================================================================================================**/
@isTest
private class PRM_VelocityRevenueOperations_TC {
    
    private static testMethod void startTest1(){
        
        list<Velocity_Revenue__c>  Vrevlist = new list<Velocity_Revenue__c> ();
        PRM_VelocityRevenueOperations Vrevupdates=new PRM_VelocityRevenueOperations();   
        
		        // Crate new account Records for each cluster
		        
		        Account account1 = new Account();
		        account1.Name='Revenue Test Account1';
		        account1.Cluster__c = 'APJ';
		        account1.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account1;
		        
		       	Account account2 = new Account();
		        account2.Name='Revenue Test Account2';
		        account2.Cluster__c = 'APJ';
		        account2.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account2;
		        
		        Account account3 = new Account();
		        account3.Name='Revenue Test Account3';
		        account3.Cluster__c = 'LA1';
		        account3.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account3;
		        
		        Account account4 = new Account();
		        account4.Name='Revenue Test Account4';
		        account4.Cluster__c = 'LA1';
		        account4.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account4;
		        
		        Account account5 = new Account();
		        account5.Name='Revenue Test Account5';
		        account5.Cluster__c = 'LA2';
		        account5.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account5;
		        
		       	Account account6 = new Account();
		        account6.Name='Revenue Test Account6';
		        account6.Cluster__c = 'LA2';
		        account6.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account6;
		        
		        Account account7 = new Account();
		        account7.Name='Revenue Test Account7';
		        account7.Cluster__c = 'EMEA 1B';
		        account7.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account7;
		        
		        /*Account account8 = new Account();
		        account8.Name='Revenue Test Account8';
		        account8.Cluster__c = 'EMEA 1B';
		        account8.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account8;*/
		        
		        Account account9 = new Account();
		        account9.Name='Revenue Test Account9';
		        account9.Cluster__c = 'EMEA 4';
		        account9.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account9;
		        
		       	/*Account account10 = new Account();
		        account10.Name='Revenue Test Account10';
		        account10.Cluster__c = 'EMEA 4';
		        account10.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account10;*/
		        
		        Account account11 = new Account();
		        account11.Name='Revenue Test Account11';
		        account11.Cluster__c = 'EMEA 2-3';
		        account11.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account11;
		        
		        /*Account account12 = new Account();
		        account12.Name='Revenue Test Account12';
		        account12.Cluster__c = 'EMEA 2-3';
		        account12.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account12;*/
		        
		        Account account13 = new Account();
		        account13.Name='Revenue Test Account13';
		        account13.Cluster__c = 'NA';
		        account13.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account13;
		        
		       	/*Account account14 = new Account();
		        account14.Name='Revenue Test Account14';
		        account14.Cluster__c = 'NA';
		        account14.PROFILED_ACCOUNT_FLAG__c=true;
		        insert account14;*/
		        
		        
        

        		// Create New Velocity Revenue records for each new account record
        
				//APJ Cluster for Positive test
                Velocity_Revenue__c Vrev1= new Velocity_Revenue__c ();       
                                    
                Vrev1.Partner_Profiled_Account__c=account1.id;
                Vrev1.Total_Product_Curr_Per_Rev_HW_SW__c=40000;
                Vrev1.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev1.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev1.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev1);
                
                
                //APJ Cluster with Negative Test
                Velocity_Revenue__c Vrev2= new Velocity_Revenue__c ();       
                                    
                Vrev2.Partner_Profiled_Account__c=account2.id;
                Vrev2.Total_Product_Curr_Per_Rev_HW_SW__c=0;
                Vrev2.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev2.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev2.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev2);                 

                //LA1 Cluster for Positive Test
                Velocity_Revenue__c Vrev3= new Velocity_Revenue__c ();      
                                    
                Vrev3.Partner_Profiled_Account__c=account3.id;
                Vrev3.Total_Product_Curr_Per_Rev_HW_SW__c=35000;
                Vrev3.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev3.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev3.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev3);
                
                //LA1 Cluster for Negative Test
                Velocity_Revenue__c Vrev4= new Velocity_Revenue__c ();      
                                    
                Vrev4.Partner_Profiled_Account__c=account4.id;
                Vrev4.Total_Product_Curr_Per_Rev_HW_SW__c=0;
                Vrev4.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev4.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev4.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev4);                 
                
                //LA2 Cluster for Positive Test
                Velocity_Revenue__c Vrev5= new Velocity_Revenue__c ();
                
                Vrev5.Partner_Profiled_Account__c=account5.id;
                Vrev5.Total_Product_Curr_Per_Rev_HW_SW__c=60000;
                Vrev5.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev5.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev5.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev5);
                
                
                //LA2 Cluster for negative test
                Velocity_Revenue__c Vrev6= new Velocity_Revenue__c ();
                
                Vrev6.Partner_Profiled_Account__c=account6.id;
                Vrev6.Total_Product_Curr_Per_Rev_HW_SW__c=0;
                Vrev6.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev6.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev6.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev6);                  

				//EMEA 1B Cluster for Positive Test
                Velocity_Revenue__c Vrev7= new Velocity_Revenue__c ();
                
                Vrev7.Partner_Profiled_Account__c=account7.id;
                Vrev7.Total_Product_Curr_Per_Rev_HW_SW__c=40000;
                Vrev7.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev7.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev7.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev7);
                
                //EMEA 1B Cluster for Negative Test
                /*Velocity_Revenue__c Vrev8= new Velocity_Revenue__c ();
                
                Vrev8.Partner_Profiled_Account__c=account8.id;
                Vrev8.C_Curr_Per_Rev_HW_SW__c=0;
                Vrev8.C_Curr_Per_Rev_SVS__c=0;
                Vrev8.C_Prev_Per_Rev_HW_SW__c=0;
                Vrev8.C_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev8);*/                

				//EMEA 4 Cluster for Positive test
                Velocity_Revenue__c Vrev9= new Velocity_Revenue__c ();
                
                Vrev9.Partner_Profiled_Account__c=account9.id;
                Vrev9.Total_Product_Curr_Per_Rev_HW_SW__c=80000;
                Vrev9.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev9.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev9.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev9);
                
                //EMEA 4 Cluster for Negative Test
                /*Velocity_Revenue__c Vrev10= new Velocity_Revenue__c ();
                
                Vrev10.Partner_Profiled_Account__c=account10.id;
                Vrev10.C_Curr_Per_Rev_HW_SW__c=0;
                Vrev10.C_Curr_Per_Rev_SVS__c=0;
                Vrev10.C_Prev_Per_Rev_HW_SW__c=0;
                Vrev10.C_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev10);*/                                 

				//EMEA 2-3 Cluster for Positive test
                Velocity_Revenue__c Vrev11= new Velocity_Revenue__c ();
                
                Vrev11.Partner_Profiled_Account__c=account11.id;
                Vrev11.Total_Product_Curr_Per_Rev_HW_SW__c=60000;
                Vrev11.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev11.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev11.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev11);
                
               	//EMEA 2-3 Cluster for Negative Test
                /*Velocity_Revenue__c Vrev12= new Velocity_Revenue__c ();
                
                Vrev12.Partner_Profiled_Account__c=account12.id;
                Vrev12.C_Curr_Per_Rev_HW_SW__c=0;
                Vrev12.C_Curr_Per_Rev_SVS__c=0;
                Vrev12.C_Prev_Per_Rev_HW_SW__c=0;
                Vrev12.C_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev12);*/                 
                
                //NA Cluster for Positive Test
                Velocity_Revenue__c Vrev13= new Velocity_Revenue__c ();
                
                Vrev13.Partner_Profiled_Account__c=account13.id;
                Vrev13.Total_Product_Curr_Per_Rev_HW_SW__c=60000;
                Vrev13.Total_Product_Prev_Per_Rev_HW_SW__c=0;
                Vrev13.Total_Services_Curr_Per_Rev_SVS__c=0;
                Vrev13.Total_Services_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev13);
                
                //NA Cluster with Negative Test
                /*Velocity_Revenue__c Vrev14= new Velocity_Revenue__c ();
                
                Vrev14.Partner_Profiled_Account__c=account14.id;
                Vrev14.C_Curr_Per_Rev_HW_SW__c=0;
                Vrev14.C_Curr_Per_Rev_SVS__c=0;
                Vrev14.C_Prev_Per_Rev_HW_SW__c=0;
                Vrev14.C_Prev_Per_Rev_SVS__c=0;
                Vrevlist.add(Vrev14);*/
                
                //Insert Records                
                insert Vrevlist;                
                Vrevupdates.updatevelocityRevenueProfiledAccount(Vrevlist);
                }
                
     
    
    

}