/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE        DEVELOPER       DESCRIPTION                               
 |  ====        =========       =========== 
 |  28-OCT-09   Anand N         Initial creation
    02-Jan-10   Prasad K        Added Currency on detail  line ,forecast amount. 
    21-Jan-10   Saravanan C     Added Quote Amount and Split updation on detail line - WR 124383 & WR 124385  
    20 Apr 10   Prasad K        Defect 632 - Taken out the comment from removeSalesTeamMethod - replaced whole method from prod    
    26-May-10   Saravanan C     Hitting Governor Limits while adding multiple products on opportunity - WR 137543
    16-Sep10    Pratibh P       WR-145152 Catch added to handle DML exception so that proper error message is displayed to user.
                                Ex: DML Failure due to Custom Validation, Custom Valtion error message will get displayed to user. 
    27-Sep-10   Shipra M        Reverting Back following changes (For Defect 779), as following code did not move to Production. Taking Latest code updated into Production.
                                ***  26-May-10  Saravanan C     Hitting Governor Limits while adding multiple products on opportunity - WR 137543 ***               
    25-Nov-10   Srinivas N      Cleaned code for Developer Script exception. WR:152818
    10-Jan-11   Srinivas        Worked on WR-151992, for IIG reorg. Adding new 4 Direct SST forecast groups
    02-Mar-11   Srinivas        Changed The filterInactiveUsers function TOO MANY SOQLS in MassReassignment. Using UserHelper class
    12-Apr-11   Srinivas        made the filterInactiveUser method public for WR-162884 
| 10-Sep-2011  Shipra M         172224  Oppty OAR: Trigger OAR when Account Owner changes from any House Account to a real user.
    24-Apr-12   Avinash K       Added a statement to update the changed Access Level on Detail Split record too (in updateSplits() method). Added the following line:
                                "detail.Opportunity_Access_Level__c = slsTeamMap.get(key).detailSplit.Opportunity_Access_Level__c;"
    30-Apr-12   Avinash K       Added a couple of statements to resolve the error "CANNOT Specify ID in an INSET call" when a new user with 
                                Access Level = "None" is being inserted more than once.
    18-Jun-12   Avinash K       Rewrote a block of code containing DML/SOQL stmts inside for loopp 
    05-Jun-13   Anand Sharma    Added splittype.developername= 'Overlay' into OpportunitySplit queries
+===========================================================================*/
public class OP_SSF_CommonUtils implements OP_SSF_CommonUtilsInterface{
    public static OP_SSF_CommonUtilsInterface getInstance(){
        return new OP_SSF_CommonUtils();
    }
    //Added by Srinivas for new IIG Forecast Groups
    Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
    ////////////////////////////// 
    
    /**
    Returns all Sales Team Member associated with the opportunity along with their
    split information that is stored in the Detail_Line__c
    
    @param Id opptyId - Salesforce Id of the Opportunity to return the sales team for  
    */
    public List<SalesTeamMember> getSalesTeamMembers(Id opptyId){
        log('getSalesTeamMember(Id opptyId):opptyId='+opptyId);
        List<Id> tempIdList = new List<Id>();
        tempIdList.add(opptyId);
        Map<Id,Map<Id,SalesTeamMember>> salesTeamMbrs = getSalesTeamMembers(tempIdList);
        log('getSalesTeamMembers(Id opptyId):salesTeamMbrs='+salesTeamMbrs);
        if(!salesTeamMbrs.isEmpty()){
            return salesTeamMbrs.get(opptyId).values();
        }else{
            return new List<SalesTeamMember>();
        }
    }
    /*
    Returns the Split information specific to the forecacst group 
    
    @param Id opptyId - Id of the Opportunity
    @param String forecastGroup - Group to return the the judgments for
    */
    
    /*
    UNUSED METHOD. NEED TO DELETE AFTER FINAL CONFIRMATION
    public List<SalesTeamMember> getSSFSplitInfo(Id opptyId,String forecastGroup){
        log('getSSFSplitInfo(Id opptyId,String forecastGroup):opptyId='+opptyId+',forecastGroup:'+forecastGroup);
        List<SalesTeamMember> tempList = getSalesTeamMembers(opptyId);
        List<SalesTeamMember> splitInfoList = new List<SalesTeamMember>(); 
        for(SalesTeamMember teamMbr:tempList){
            if(teamMbr.detailSplit.Forecast_Group__c == forecastGroup){
                splitInfoList.add(teamMbr);
            }
        }
        log('getSSFSplitInfo(Id opptyId,String forecastGroup):splitInfoList='+splitInfoList);
        return splitInfoList;
    }
    */
       
    /*
    Adds 1 or more sales team members to the sales team for hte corresponding opportunity
    This method assumes all sales team members are being added to the same opportunity
    
    @param List<SalesTeamMember> salesTeamMbrs List of Sales team members to add
    */
    public OP_SSF_SaveResult addSalesTeamMembers(List<SalesTeamMember> slsTeamMbrs){
        log('addSalesTeamMembers(List<SalesTeamMember> salesTeamMbrs):slsTeamMbrs='+slsTeamMbrs);
        if(slsTeamMbrs.size()==0){
            //Throw exception
        }
        //Filter out the inactive users in this list and don't add/update their data
        List<SalesTeamMember> salesTeamMbrs = filterInactiveUsers(slsTeamMbrs);


        //Get the Opportunity Id of the first record
        SalesTeamMember tempMbr = salesTeamMbrs[0];
        if(tempMbr.detailSplit == null || tempMbr.detailSplit.Opportunity__c ==null){
            //throw exception
        }
        Id opptyId = salesTeamMbrs[0].opptyTeamMember.OpportunityId;
        log('addSalesTeamMembers:opptyId='+opptyId);
        
        //Filter out any team members that have already been added to the sales team
        List<SalesTeamMember> teamToUpdt = getExistingSalesTeamMembers(opptyId,slsTeamMbrs);
        
        
        
        log('addSalesTeamMembers:teamToUpdt='+teamToUpdt);
        if(teamToUpdt.size()>0){
            updateSplits(teamToUpdt);
        }

        //Filter out any team members that have already been added to the sales team
        salesTeamMbrs = filterExistingSalesTeamUsers(opptyId,salesTeamMbrs); 
        log('addSalesTeamMembers:active removing inactive users:salesTeamMbrs='+salesTeamMbrs);
        
        List<SalesTeamMember> teamMbrs; 
        
        //Initialize the Lists of objects that will be finally inserted
        List<Detail_Line__c> detailsToAdd = new List<Detail_Line__c>();
        List<OpportunityTeamMember> opptyTeamToAdd = new List<OpportunityTeamMember>();
        List<OpportunitySplit> splitsToAdd = new List<OpportunitySplit>();

        //Get all the sales teams and group them by forecast group
        Map<String,List<SalesTeamMember>> salesTeam = getAllSalesTeamMembers(opptyId);
        
        //Get all the products on the Opportunity 
        // Quote_Amount__c was added in query for WR 124383 by saravanan
        List<OpportunityLineItem> opptyProducts = [ select Id,OpportunityId,PricebookEntry.Product2Id,UnitPrice,Opportunity.CurrencyIsoCode,Quote_Amount__c
                                                    from OpportunityLineItem where OpportunityId=:opptyId];
        
        //Insert the data into OpportunitySalesTeam
        Map<Id,SalesTeamMember> tempOpptyTeam = new Map<Id,SalesTeamMember>();
        Set<String> fcastGroups = new Set<String>(); 
        for(SalesTeamMember teamMbr: salesTeamMbrs){
            opptyTeamToAdd.add(teamMbr.opptyTeamMember); 
            fcastGroups.add(teamMbr.detailSplit.Forecast_Group__c);   
            tempOpptyTeam.put(teamMbr.opptyTeamMember.UserId,teamMbr);
        }
        log('addSalesTeamMembers:opptyTeamToAdd='+opptyTeamToAdd);
        
//Code Added by Avinash to remove the error when trying to insert an already existing OpportunitySplit...
        List<OpportunityTeamMember> opptyTeamToInsert = new List<OpportunityTeamMember>();
                
        for(OpportunityTeamMember otm : opptyTeamToAdd)
            if(otm.id == null)
                opptyTeamToInsert.add(otm);
            
                
        if(opptyTeamToInsert.size()==0)
            opptyTeamToInsert.addAll(opptyTeamToAdd.deepClone(false,false,false));
        
        opptyTeamToAdd.clear();
        opptyTeamToAdd = opptyTeamToInsert;
        
        
//... Code added by Avinash ends here.
        
        insert opptyTeamToAdd;
        log('addSalesTeamMembers:added OpptyTeam successfuly'); 
        
        
        List<OpportunityShare> sharesToUpdt = new List<OpportunityShare>();
        //Update the OpportunityAccessLevel for the share records for
        //the OpptyTeamMember records just created
        //This is to work around the issue that OpportunityAccessLevel on 
        //OpportunityTeamMember is read-only and cannot set during insert/update
        for(OpportunityShare opptyShare:[   select Id,OpportunityAccessLevel,UserOrGroupId
                                            from OpportunityShare 
                                            where RowCause='Team'
                                            and OpportunityId=:opptyId
                                            and UserOrGroupId in :tempOpptyTeam.keySet()])
        {
            log('addSalesTeamMember:opptyShare='+opptyShare);
            if(tempOpptyTeam.containsKey(opptyShare.UserOrGroupId)){
                log('addSalesTeamMember:tempOpptyTeam='+tempOpptyTeam);
                tempMbr = tempOpptyTeam.get(opptyShare.UserOrGroupId);
                log('addSalesTeamMember:tempMbr.detailSplit'+tempMbr.detailSplit);
                
                if(tempMbr.detailSplit!=null){
                    opptyShare.OpportunityAccessLevel =tempMbr.detailSplit.Opportunity_Access_Level__c;
                    sharesToUpdt.add(opptyShare);
                } 
            }
        } 
        log('addSalesTeamMember:sharesToUpdt='+sharesToUpdt);
        if(sharesToUpdt.size()>0){
            update sharesToUpdt;
        }
        //Only create the Detail_Line__c records when there are product associated with the 
        //the opportunity      
        if(opptyProducts.size()>0){
            //Get the forecast group to Product mapping
            Map<String,Map<Id,Id>> grpProdMap = getGroupProductMapping(fcastGroups);
            Decimal splitPct;
            
            //Iterate through the Sales Team Member passed in the input parameters
            //and set their Split Pct if not already set. 
            for(SalesTeamMember teamMbr:salesTeamMbrs){
                teamMbrs = salesTeam.get(teamMbr.detailSplit.Forecast_Group__c);
                log(''+teamMbrs);
                if(teamMbrs==null){
                    //This is the first Sales Team user for this forecast group
                    //and a split is not already set
                    //Split should be 100%
                    if(teamMbr.detailSplit.Split__c==null){
                        splitPct=100.0;
                    }else{
                        splitPct=teamMbr.detailSplit.Split__c;
                    }
                    teamMbrs = new List<SalesTeamMember>();
                    teamMbrs.add(teamMbr);
                    salesTeam.put(teamMbr.detailSplit.Forecast_Group__c,teamMbrs);
                }else{
                    //Split should be 0%
                    if(teamMbr.detailSplit.Split__c==null){
                        splitPct=0.0;
                    }else{
                        splitPct=teamMbr.detailSplit.Split__c;
                    }
                }
                //Create Detail_Line__c records for all the products that 
                //are associated with this forecast group
                detailsToAdd.addAll(createDetailLines(teamMbr,opptyProducts,grpProdMap,splitPct));
                opptyTeamToAdd.add(teamMbr.opptyTeamMember);
                
                //Copy over the split Pct into the Standard OpportunitySplit object
                //only if the Forecast group is Direct
                //if(teamMbr.detailSplit.Forecast_Group__c=='Direct'){
                if(mapSpecial_Forecast_Groups.containskey(teamMbr.detailSplit.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(teamMbr.detailSplit.Forecast_Group__c).Save_Standard_Split__c )
                {
                    splitsToAdd.add(createOpptySplit(teamMbr,splitPct));
                }
            }
        }
      
        try{
            log('addSalesTeamMembers:splitsToAdd:'+splitsToAdd);
           
            
            if(splitsToAdd.size()>0){
                insert splitsToAdd;
                log('inserted splits successfuly..'); 
            }
            log('addSalesTeamMembers:detailsToAdd:'+detailsToAdd);
            insert detailsToAdd; 
        }catch(Exception ex){
            log('Exception creating Splits or Detail Lines:'+ex.getMessage());
            //throw new OP_SSF_Exception(100,ex);
            // Adding this line as the Custom Exception is not sending the proper information about the exception
            //throw ex;
        }
            
        return new OP_SSF_SaveResult(detailsToAdd);
    }

    /**
    Remove Sales Team Members (OpportunityTeamMember,OpportunitySplit,Detail_Line__c) records
    that are passed in input
    
    @param List<SalesTeamMember> salesTeamMbrs - List of sales team users that need to be removed
    @return OP_SSF_SaveResult - Result of the remove operation   
    */
     public OP_SSF_SaveResult removeSalesTeamMembers(List<SalesTeamMember> salesTeamMbrs){
        log('removeSalesTeamMembers:salesTeamMbrs='+salesTeamMbrs);
        List<Id> teamMbrIds= new List<Id>();
        Map<Id,Id> userIdMap = new Map<Id,Id>();
        List<Id> opptyIds= new List<Id>();
        List<OpportunityTeamMember> opptyTeamToDel= new List<OpportunityTeamMember>();
        List<OpportunitySplit> opptySplitToDel = new List<OpportunitySplit>();
        List<Detail_Line__c> detailsToDelete;
        //Get all the OpptyLineItem Id in the input
        for(SalesTeamMember teamMbr: salesTeamMbrs){
            teamMbrIds.add(teamMbr.opptyTeamMember.Id);
            opptyTeamToDel.add(teamMbr.opptyTeamMember);
            opptyIds.add(teamMbr.opptyTeamMember.OpportunityId);
            userIdMap.put(teamMbr.opptyTeamMember.UserId,teamMbr.opptyTeamMember.UserId);  // uncommented line Defect #632
        } 
        //Get all Detail Lines associated with those oppty Line Items. The OpportunityTeamMember__c
        //on Detail_Line__c is set when those records are inserted through addSalesTeamMembers
        detailsToDelete = [ select Id 
                            from Detail_Line__c 
                            where OpportunityTeamMember__c in :teamMbrIds];
        
                          
        
        for(OpportunitySplit split: [   select Id,SplitOwnerId,OpportunityId 
                                        from OpportunitySplit 
                                        where OpportunityId in :opptyIds and splittype.developername= 'Overlay'])
        {
            if(userIdMap.containsKey(split.SplitOwnerId)){
                opptySplitToDel.add(split);
            }
        }
        log('removeSalesTeamMembers:detailsToDelete='+detailsToDelete);
        log('removeSalesTeamMembers:opptySplitToDel='+opptySplitToDel);
        log('removeSalesTeamMembers:opptyTeamToDel='+opptyTeamToDel);
        //Delete the  records
      
        try{
            delete detailsToDelete;
            delete opptySplitToDel;
            delete opptyTeamToDel;
        }catch(Exception ex){
        
            throw new OP_SSF_Exception(100,ex);
        }
        
        return new OP_SSF_SaveResult(detailsToDelete);

    }    
    /*
    Adds 1 or more products to an opportunity. Currently this method only supports 1
    adding products associated with a single opportunity. Will be modifed to support
    multiple opportunities
    
    @param List<OpportunityLineItem> products - List of all products to be added
    */
    public OP_SSF_SaveResult addProducts(List<OpportunityLineItem> products,Boolean createLineItems){
        log('addProducts:products='+products);
        if(products.size()==0){
            throw new OP_SSF_Exception('Invalid input. Need alteast 1 product to add.');
        }
        
        //Initialize the Lists of objects that will be finally inserted
        List<Detail_Line__c> detailsToAdd = new List<Detail_Line__c>();
        List<OpportunitySplit> splitsToAdd = new List<OpportunitySplit>();
      
        Database.SaveResult[] opptyLineSaveRes;
        if(createLineItems){
            opptyLineSaveRes =Database.insert(products);    
        }
        List<Id> prdIdList = new List<Id>();
        Map<Id,Id> opptyIdMap = new Map<Id,Id>();
        Set<String> opptySplitInfo = new Set<String>();
        //Get the list of Opporunity Line Item Ids and Opportunity Ids 
        for(OpportunityLineItem item: products){
            prdIdList.add(item.id);
            if(!opptyIdMap.containsKey(item.OpportunityId)){
                opptyIdMap.put(item.OpportunityId,item.OpportunityId);
            }
        }
        //Get the list of OpportunitySplits records for the Opportunities in the input
        for(OpportunitySplit split: [select Id,OpportunityId,SplitOwnerId,SplitPercentage 
                                     from OpportunitySplit
                                     where splittype.developername= 'Overlay' AND OpportunityId in :opptyIdMap.keySet()])
        {
            opptySplitInfo.add(split.OpportunityId+'_'+split.SplitOwnerId);                  
        }
        
        List<OpportunityLineItem> opptyProducts = [ select Id,OpportunityId,PricebookEntry.Product2Id,UnitPrice,Opportunity.CurrencyIsoCode,Quote_Amount__c                                                  
                                                    from OpportunityLineItem
                                                    where Id in :prdIdList];
        
        //Get all the sales teams and group them by forecast group
        Map<Id,Map<String,List<SalesTeamMember>>> salesTeam = getSalesTeamMembersByGroup(opptyIdMap.values());
        Map<String,List<SalesTeamMember>> tempSalesTeam;
        log('salesTeam:'+salesTeam);
        Map<Id,List<String>> prdGroupMap = getProductGroupMapping(opptyProducts);
        for(OpportunityLineItem product: opptyProducts){
            //Get the current sales team for this opportunity
            tempSalesTeam = salesTeam.get(product.OpportunityId);
            if(tempSalesTeam !=null){
                List<String> forecastGrps = prdGroupMap.get(product.PricebookEntry.Product2Id);
                log('addProducts:forecastGroups:'+forecastGrps);
                //For each forecast group that has a sales team member in the Opportunity
                //Create a Detail_Line__c records
                if(forecastGrps!=null && forecastGrps.size()>0){
                    for(String grp:forecastGrps){
                        log('addProducts:salesTeam.get('+grp+'):'+tempSalesTeam.get(grp));
                        if(tempSalesTeam.get(grp)!=null)
                        {
                            detailsToAdd.addAll(createDetailLines(product,tempSalesTeam.get(grp)));
                            //if(grp=='Direct'){
                            if(mapSpecial_Forecast_Groups.containskey(grp) && mapSpecial_Forecast_Groups.get(grp).Save_Standard_Split__c )
                            {
                                splitsToAdd.addall(createOpptySplits(opptySplitInfo,product,tempSalesTeam.get(grp)));
                            }
                        }
                    }
                }else{
                    //No one on this Product's forecast group is on the sales team.
                    //Apex batch should pick up this addition and create the assignment record
                }
            }
        }
        log('addProducts:detailsToAdd='+detailsToAdd);
        log('addProducts:splitsToAdd='+splitsToAdd);
  
        try{
            //Create the OpportunityLineItems of the boolean is true
            insert detailsToAdd;
            insert splitsToAdd; 
            //Update the Split to the Detail_line__c   
          /*
           if(opptyProducts.size()>=1 ){
            list<id> oppIds = new list<id>();
            list<Detail_Line__c> detailLinesToUpdate  = new list<Detail_Line__c>();
            map<id,OpportunitySplit> opp_split  = new map<id,OpportunitySplit>();

            for( Detail_Line__c a: detailsToAdd ){
              oppIds.add(a.Opportunity__c);
            }
            list<OpportunitySplit> split = new list<OpportunitySplit>([select Id,OpportunityId,
                                                        SplitOwnerId,SplitPercentage 
                                                     from OpportunitySplit
                                                     where OpportunityId in: oppIds]);
            for(OpportunitySplit s: split){
                 opp_split.put(s.OpportunityId,s);
            }            

            for( Detail_Line__c a: detailsToAdd ){
              if(a.Forecast_Group__c == 'Direct' && a.Owner__c == opp_split.get(a.Opportunity__c).SplitOwnerId){
                a.Split__c = opp_split.get(a.Opportunity__c).SplitPercentage;
                detailLinesToUpdate.add(a);  
              }  
            }                         
            update detailLinesToUpdate ;
          }  
          */
          //*** Code Reverted back By Shipra On 27-Sep-10***//
          
          
          /***********************
Code commented by Avinash and replaced by the equivalent exception-free code after the comment block
          
          if(opptyProducts.size()>=1 ){
            for( Detail_Line__c a: detailsToAdd ){
            //if(a.Forecast_Group__c == 'Direct'){
             if(mapSpecial_Forecast_Groups.containskey(a.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(a.Forecast_Group__c).Save_Standard_Split__c )
              {
                OpportunitySplit split = [select Id,OpportunityId,SplitOwnerId,SplitPercentage 
                                         from OpportunitySplit
                                         where OpportunityId = :a.Opportunity__c and SplitOwnerId = :a.Owner__c ];
                a.Split__c = split.SplitPercentage;
                update a;
              }
            }
          }   
        }
        
        *****************************/
        
//Code rewritten below for the above commented block to eliminate any DML/SOQL within the for loop
            if(opptyProducts.size()>=1 )
            {
                List<ID> detailsToAddOppIds = new List<ID>();
                List<ID> detailsToAddOwnerIds = new List<ID>();
                Map<Id, OpportunitySplit> mapDetailLineOpportunitySplit = new Map<Id, OpportunitySplit>();
                List<Detail_Line__c> lstDetailsToUpdate = new List<Detail_Line__c>();
                
                for(Detail_Line__c d : detailsToAdd)
                {
                    detailsToAddOppIds.add(d.Opportunity__c );
                    detailsToAddOppIds.add(d.Owner__c);
                }
                            
                List<OpportunitySplit> lstSplit = [select Id,OpportunityId,SplitOwnerId,SplitPercentage 
                                             from OpportunitySplit
                                             where splittype.developername= 'Overlay' AND OpportunityId IN :detailsToAddOppIds and SplitOwnerId = :detailsToAddOwnerIds limit 50000];
                
                for(Detail_Line__c dl : detailsToAdd)
                    for(OpportunitySplit os : lstSplit)
                        if (dl.Owner__c == os.SplitOwnerId && dl.Opportunity__c == os.OpportunityId)
                        {
                            mapDetailLineOpportunitySplit.put(dl.id,os);
                            break;
                        }
                
                for( Detail_Line__c a: detailsToAdd )
                {
                    if(mapSpecial_Forecast_Groups.containskey(a.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(a.Forecast_Group__c).Save_Standard_Split__c )
                    {
                        if(mapDetailLineOpportunitySplit != null && mapDetailLineOpportunitySplit.get(a.id) != null)
                        {
                            OpportunitySplit split = mapDetailLineOpportunitySplit.get(a.id);
                             
                            a.Split__c = split.SplitPercentage;
                                
                            lstDetailsToUpdate.add(a);
                        }
                    }
                }
                
                if(lstDetailsToUpdate != null && lstDetailsToUpdate.size() > 0)
                    update lstDetailsToUpdate;
                
            }
        }
//Rewritten code ends.
        
        catch(DMLException dex){//Catch Added, Pratibh, 16-Sep-2010: Catch handle DML exception so that proper error message is displayed to user.
            System.debug('---------------'+dex.getMessage());
            throw dex;
        }
        catch(Exception ex){
        log('exception thrown ===>'+ex);
           throw new OP_SSF_Exception(100,ex);
        }
        OP_SSF_SaveResult result = new OP_SSF_SaveResult(detailsToAdd);
        result.dmlSaveResult=opptyLineSaveRes;
        return result;
    }
     
    /**
    Updates the Quote_Amount__c on Detail_Line__c for products passed in input.
    
    @param Map<Id,OpportunityLineItem> productMap - Trigger.New of the product being update
    @param Map<Id,OpportunityLineItem> oldPrdMap - Trigger.Old of the product being update
    @return OP_SSF_SaveResult - Result of the update operation   
    */
    public OP_SSF_SaveResult updateProducts(Map<Id,OpportunityLineItem> productMap,Map<Id,OpportunityLineItem> oldPrdMap){
        log('updateProducts:productMap='+productMap+',oldPrdMap='+oldPrdMap);
        List<Detail_Line__c> detail2Update = new List<Detail_Line__c>();
        Detail_Line__c tempDetail;
        //Opportunity_Product__c contains the id of hte OpportunityLineItemId that the detail_Line__c 
        //corresponds to. This is set in the addSalesTeamMember/addProduct flows.
        Map<Id,String> OpportunityCurrencyMap = new Map<Id,String>();
        for( OpportunityLineItem product:[Select id,Opportunity.CurrencyIsoCode from OpportunityLineItem where id in :productMap.keySet()]){
            OpportunityCurrencyMap.put(product.id,product.Opportunity.CurrencyIsoCode);
        }

        for(Detail_Line__c detail: [select Id,Quote_Amount__c,Opportunity_Product__c
                                    from Detail_Line__c
                                    where Opportunity_Product__c in :productMap.keySet()])
        {
            tempDetail = new Detail_Line__c(Id=detail.Id,
                                            Quote_Amount__c=productMap.get(detail.Opportunity_Product__c).Quote_Amount__c,
                                            Direct_Amount__c=productMap.get(detail.Opportunity_Product__c).UnitPrice,
                                            CurrencyIsoCode=OpportunityCurrencyMap.get(detail.Opportunity_Product__c));
                
            detail2Update.add(tempDetail);  
        }
        log('updateProducts:detail2Update='+detail2Update);
      
        try{
            Database.SaveResult[] saveRes = Database.update(detail2Update);
            OP_SSF_SaveResult result = new OP_SSF_SaveResult(detail2Update);
            result.dmlSaveResult=saveRes;
            return result;
        }catch(Exception ex){
    
          throw new OP_SSF_Exception(100,ex);
        } 
    }
    /**
    Remove products (and their corresponding Detail_Line__c records) for the product passed in as the input
    
    @param List<OpportunityLineItem> products - List of products to be deleted
    @param Boolean deleteProducts - A flag that determines if the products passed in require to be explicitly deleted
    @return OP_SSF_SaveResult - Result of the remove operation   
    */    
    public OP_SSF_SaveResult removeProducts(List<OpportunityLineItem> products,boolean deleteProducts){
        log('removeProducts:products='+products+',deleteProducts='+deleteProducts);
        List<Id> productIds = new List<Id>();
        List<Detail_Line__c> detailsToDelete;
        //Get all the OpptyLineItem Id in the input
        for(OpportunityLineItem product: products){
            productIds.add(product.Id);
        } 
        //Get all Detail Lines associated with those oppty Line Items
        //Opportunity_Product__c contains the id of hte OpportunityLineItemId that the detail_Line__c 
        //corresponds to. This is set in the addSalesTeamMember/addProduct flows.
        detailsToDelete = [select Id from Detail_Line__c where Opportunity_Product__c in :productIds];
        log('removeProducts:detailsToDelete='+detailsToDelete);
        
        //Delete those Detail_Line records
        
        try{
             System.debug('products ' + products);
             System.debug('deleteProducts  ' + deleteProducts);
             //If the products are deleted through the browser app, this method would be called from a trigger
             //and hence the "deleteProducts" will be set to false. If it's called from integration, it will be set to
             //to true.
            if(deleteProducts){
              List <Database.DeleteResult> sr = Database.delete(products,false);
              System.debug('<Database.SaveResult> sr ' + sr);
            }
            delete detailsToDelete; 
        }catch(Exception ex){
           
            throw new OP_SSF_Exception(100,ex);
        }
       
        return new OP_SSF_SaveResult(detailsToDelete);
    }

    /**
    Update the split Pct,Opportunity_Access_Level,TeamRole on Detail_Line__c
    
    @param List<SalesTeamMember> splits - List of splits to be updated
    @return OP_SSF_SaveResult - Result of the update operation   
    */      
    public OP_SSF_SaveResult updateSplits(List<SalesTeamMember> splits){
       log('updateSplits:splits='+splits);
       
       //Filter out the inactive users in the list
       splits = filterInactiveUsers(splits); 
       Map<String,SalesTeamMember> slsTeamMap = new Map<String,SalesTeamMember>();
       Map<Id,String> opptyIdMap = new Map<Id,Id>(); 
       List<Detail_Line__c> detailsToUpdt = new List<Detail_Line__c>();  
       List<OpportunitySplit> splitToUpdt = new List<OpportunitySplit>();
       List<OpportunityTeamMember> opptyTeamToUpdt = new List<OpportunityTeamMember>();
       List<OpportunityShare> shareToUpdt = new List<OpportunityShare>();
        
       //Map the input parameters by OpportunityId and User Id 
       for(SalesTeamMember teamMbr:splits){
            slsTeamMap.put(teamMbr.opptyTeamMember.OpportunityId+'_'+((String)teamMbr.opptyTeamMember.UserId).substring(0,15),
                            teamMbr);
            if(!opptyIdMap.containsKey(teamMbr.opptyTeamMember.OpportunityId)){
                opptyIdMap.put(teamMbr.opptyTeamMember.OpportunityId,teamMbr.opptyTeamMember.OpportunityId);
            }
       }
       String key;
       log('updateSplits:opptyIdMap='+opptyIdMap);
       log('updateSplits:slsTeamMap='+slsTeamMap);
       //Get all detail Lines for the opportunies in question
       for(Detail_Line__c detail: [ select Opportunity__c,Id,Split__c,OwnerId 
                                    from Detail_Line__c
                                    where Opportunity__c in :opptyIdMap.keySet()])
       {
            key =detail.Opportunity__c+'_'+((String)detail.OwnerId).substring(0,15);
           //Set the new Split values based on what's passed in
            if(slsTeamMap.containsKey(key)){
                detail.Split__c=slsTeamMap.get(key).detailSplit.Split__c;
                
                detail.Opportunity_Access_Level__c = slsTeamMap.get(key).detailSplit.Opportunity_Access_Level__c;
                
                detailsToUpdt.add(detail);
            }                               
       }
       
       //Get all OpptyTeamMembers for Opportunities and update the TeamMemberRole
       for(OpportunityTeamMember teamMbr: [ select OpportunityId,Id,UserId,TeamMemberRole
                                            from OpportunityTeamMember
                                            where OpportunityId in :opptyIdMap.keySet()])
       {
            key =teamMbr.OpportunityId+'_'+((String)teamMbr.UserId).substring(0,15);
           //Set the new Split values based on what's passed in
            if(slsTeamMap.containsKey(key)){
                teamMbr.TeamMemberRole = slsTeamMap.get(key).opptyTeamMember.TeamMemberRole;
                opptyTeamToUpdt.add(teamMbr);
            }                               
       }
    
       //Get all OpptyShares for Opportunities and update the TeamMemberRole
       
       for(OpportunityShare share: [    select OpportunityId,Id,RowCause,UserOrGroupId,OpportunityAccessLevel
                                            from OpportunityShare
                                            where OpportunityId in :opptyIdMap.keySet()
                                            and (RowCause='Team')])
       {
system.debug('#### Share :: '+share);
            
            key =share.OpportunityId+'_'+((String)share.UserOrGroupId).substring(0,15);
           //Set the new Split values based on what's passed in
            if(slsTeamMap.containsKey(key)){
                share.OpportunityAccessLevel = slsTeamMap.get(key).detailSplit.Opportunity_Access_Level__c;
                shareToUpdt.add(share);
            }                               
       }
       
system.debug('#### Share to update = '+shareToUpdt);
       //Get all OpportunitySplit for the opportunies in question
       for(OpportunitySplit splitInfo: [    select Id,OpportunityId,SplitOwnerId,SplitPercentage 
                                            from OpportunitySplit
                                            where splittype.developername = 'Overlay' AND OpportunityId in :opptyIdMap.keySet()])
       {
            key =splitInfo.OpportunityId+'_'+((String)splitInfo.SplitOwnerId).substring(0,15);
            //Set the new Split values based on what's passed in
            log('updateSplits:key='+key);
            System.debug('opptyIdMap'+opptyIdMap);
            if(slsTeamMap.containsKey(key)){
                log('updateSplits:key found in slsTeamMap !!!!');
                log('updateSplits:slsTeamMap.get(key).detailSplit.Forecast_Group__c='+slsTeamMap.get(key).detailSplit.Forecast_Group__c);
                //if(slsTeamMap.get(key).detailSplit.Forecast_Group__c=='Direct'){
                if(mapSpecial_Forecast_Groups.containskey(slsTeamMap.get(key).detailSplit.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(slsTeamMap.get(key).detailSplit.Forecast_Group__c).Save_Standard_Split__c )
                {
                    splitInfo.SplitPercentage=slsTeamMap.get(key).detailSplit.Split__c;
                    System.debug('slsTeamMap.get(key).detailSplit.Split__c--->'+slsTeamMap.get(key).detailSplit.Split__c);
                    splitInfo.SplitNote=slsTeamMap.get(key).detailSplit.Split__c+' %';
                    System.debug('slsTeamMap.get(key).detailSplit.Split__c+'+slsTeamMap.get(key).detailSplit.Split__c+' %');
                    
                    splitToUpdt.add(splitInfo);
                    
                }
            }
       }
        log('updateSplits:opptyTeamToUpdt='+opptyTeamToUpdt);
        log('updateSplits:shareToUpdt='+shareToUpdt);
        log('updateSplits:detailsToUpdt='+detailsToUpdt);
        log('updateSplits:splitToUpdt='+splitToUpdt);
        List<Database.SaveResult> saveRes;
  
        try{
            Database.update(opptyTeamToUpdt);
system.debug('#### Share to update BEFORE Update= '+shareToUpdt);
            Database.update(shareToUpdt);
            saveRes=Database.update(detailsToUpdt);
            Database.update(splitToUpdt);
            
            OpportunityOperation integLog = new OpportunityOperation();
            integLog.insertOpportunityIntgLog(opptyIdMap.values());
            
        }catch(Exception ex){
  
            throw new OP_SSF_Exception(100,ex);
        }
        OP_SSF_SaveResult result = new OP_SSF_SaveResult(detailsToUpdt);
        result.dmlSaveResult=saveRes;
        return result;
    }

    /**
    Change the owner for a give Opportunity Id 
    
    @param Id opptyId - Id of the Opportunity that the owner needs to be changed
    @param Id currentOwner - Id of the current owner
    @param Id newOwner - Id of the new Owner
    */   
    public void changeOwner(Id opptyId,Id currentOwner,Id newOwner){
        Map<Id,Id> ownerMap = new Map<Id,Id>();
        ownerMap.put(opptyId,newOwner);
        changeOwner(ownerMap,true);
        return;
    }
    
    /**
    Change the owner for a give list of Opportunites 
    
    @param Map<Id,Id> ownerMap - A list of Opportunities being updated. The Key is the new OwnerId
                                 value is the OpportunityId
    @param Boolean updateOppty - A flag that determines if the Opportunity needs to be updated. 
    */   
    public void changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty){
        log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):ownerMap='+ownerMap);
        List<Id> idList = new List<Id>();
        Map<Id,Id> acctIdMap = new Map<Id,Id>();
        Map<Id,AccountTeamMember> acctRoleMap = new Map<Id,AccountTeamMember>();
        Map<Id,User> userAttrMap = new Map<Id,User>();  
        Map<Id,Id> tempMap = new Map<Id,Id>();
        Map<Id,SalesTeamMember> opptySlsTeam;
        List<Opportunity> opptyToUpdt = new List<Opportunity>();
        //Create the List of Oppotunities to be updated, also create a list of AccountTeamMember
        //records corresponding to the owners passed in the input.
        for(Opportunity oppty: [select Id,AccountId
                                from Opportunity 
                                where Id in :ownerMap.keySet()]){
            opptyToUpdt.add(new Opportunity(Id=oppty.Id,OwnerId=ownerMap.get(oppty.Id)));
            idList.add(oppty.Id);
            if(!acctIdMap.containsKey(oppty.AccountId)){
                acctIdMap.put(oppty.AccountId,oppty.AccountId);
            }
        }
        //Get the Forecast Group of the new Opportunity Owners.
        for(User usr: [select Id,Forecast_Group__c,isActive from User where Id in :ownerMap.values()]){
            userAttrMap.put(usr.Id,usr);
        }
        log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):userAttrMap='+userAttrMap);
        //Get the Account Team Role if the user is on the Account team, so that the 
        //team role on OpportunityTeamMember can be set to the AccountTeamRole 
        for(AccountTeamMember acctTeamMbr :[    Select AccountId, TeamMemberRole, UserId 
                                                from AccountTeamMember  
                                                where AccountId in :acctIdMap.keySet()
                                                and UserId in :ownerMap.values()])
        {
            acctRoleMap.put(acctTeamMbr.UserId,acctTeamMbr);                                    
        }        
        log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):acctRoleMap='+acctRoleMap);
        //Get all Sales Teams for all opportunities in the input
        Map<Id,Map<Id,SalesTeamMember>> salesTeams = getSalesTeamMembers(idList);
        List<SalesTeamMember> slsTeamToAdd = new List<SalesTeamMember>();
        SalesTeamMember slsTeamMbr;
        OpportunityTeamMember opptyTeamMbr;
        Detail_Line__c detail;
        Id ownerId;
        String teamRole;
        for(Id opptyId: ownerMap.keySet()){
            ownerId = ownerMap.get(opptyId);
            //Get the existing sales team members for the opportunity
            opptySlsTeam = salesTeams.get(opptyId);
            log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):opptySlsTeam='+opptySlsTeam);
            //If there user is not already on the sales team, then create a new OpportunityTeamMemeber,Detail_Line__c
            //OpportunitySplit records
            if(opptySlsTeam==null || !opptySlsTeam.containsKey(ownerId)){
                log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):New Owner:'+ownerId+' not found in sales team !!!');
                teamRole = acctRoleMap.get(ownerId)!=null?acctRoleMap.get(ownerId).TeamMemberRole:'Other';
                log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):teamRole='+teamRole);
                opptyTeamMbr = new OpportunityTeamMember(OpportunityId=opptyId,UserId=ownerId,TeamMemberRole=teamRole);
                //added for bug 810 fix
                opptyTeamMbr.user = userAttrMap.get(ownerId);// added this line for Bug 810 fix
                slsTeamMbr = new SalesTeamMember(false,opptyTeamMbr);
                slsTeamMbr.detailSplit=new Detail_Line__c(Opportunity__c=opptyId,Forecast_Group__c=userAttrMap.get(ownerId).Forecast_Group__c);
                slsTeamToAdd.add(slsTeamMbr);
            }
        }
        log('changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty):slsTeamToAdd='+slsTeamToAdd);
        if(updateOppty){
       
            try{
             
                Util.isChannelVisibilityExecuted=false;
                Database.update(opptyToUpdt);
            }catch(Exception ex){
          
                throw new OP_SSF_Exception(100,ex);
            }
        }
        if(slsTeamToAdd.size()>0){
            addSalesTeamMembers(slsTeamToAdd);
        }
    }
    //////////////////////////////////////////// Private Helper Methods //////////////////////////////////////////////
    
    /**
    Get the list of Products grouped by Forecast Group passed in from the Forecast_Mapping and Forecast_Group_Product
    objects 
    */
    private Map<String,Map<Id,Id>> getGroupProductMapping(Set<String> groupsToLook){
        Map<Id,Id> prodIdMap = new Map<Id,Id>(); 
        Map<String,Map<Id,Id>> grpProdMap = new Map<String,Map<Id,Id>>();
        for(Forecast_Group_Product__c grpProduct: [ Select  f.Product__c, f.Forecast_Mapping__r.Default_Sales_Team_User__c, 
                                                            f.Forecast_Mapping__r.Forecast_Group__c, f.Forecast_Mapping__c 
                                                    From Forecast_Group_Product__c f
                                                    where Forecast_Mapping__r.Forecast_Group__c in :groupsToLook])
        {
            if(grpProdMap.containsKey(grpProduct.Forecast_Mapping__r.Forecast_Group__c)){
                prodIdMap =grpProdMap.get(grpProduct.Forecast_Mapping__r.Forecast_Group__c); 
            }else{
                prodIdMap = new Map<Id,Id>();
                grpProdMap.put(grpProduct.Forecast_Mapping__r.Forecast_Group__c,prodIdMap);
            }
            prodIdMap.put(grpProduct.Product__c,grpProduct.Product__c);
        }
        log('getGroupProductMapping:grpProdMap='+grpProdMap);
        return grpProdMap;      
    }
    
    /**
    Get the list of Products grouped by Forecast Group for products passed in the input from the 
    Forecast_Mapping and Forecast_Group_Product objects     
    */
    private Map<Id,List<String>> getProductGroupMapping(List<OpportunityLineItem> products){
        log('getProductGroupMapping:products='+products);
        List<String> forecastGroups;
        Map<Id,Id> prdToLook = new Map<Id,Id>(); 
        for(OpportunityLineItem item: products){
            if(!prdToLook.containsKey(item.PricebookEntry.Product2Id)){
                prdToLook.put(item.PricebookEntry.Product2Id,item.PricebookEntry.Product2Id);
            }
        }
        Map<Id,List<String>> prodGrpMap = new Map<Id,List<String>>();
        for(Forecast_Group_Product__c grpProduct: [ Select  f.Product__c,f.Forecast_Mapping__r.Default_Sales_Team_User__c, 
                                                            f.Forecast_Mapping__r.Forecast_Group__c, f.Forecast_Mapping__c 
                                                    From Forecast_Group_Product__c f
                                                    where Product__c in :prdToLook.values()])
        {
            if(prodGrpMap.containsKey(grpProduct.Product__c)){
                forecastGroups=prodGrpMap.get(grpProduct.Product__c); 
            }else{
                forecastGroups = new List<String>();
                prodGrpMap.put(grpProduct.Product__c,forecastGroups);
            }
            forecastGroups.add(grpProduct.Forecast_Mapping__r.Forecast_Group__c);
        }
        log('getProductGroupMapping:prodGrpMap='+prodGrpMap);
        return prodGrpMap;      
    }
    /**
    Create the Detail_Line__c records and set the attributes based on the parameter passed. If the Sales Team
    Member being passed is the first one, then the Split is set to 100% otherwise it is set to 0%.     
    */    
    private List<Detail_Line__c> createDetailLines( OpportunityLineItem opptyProduct,List<SalesTeamMember> salesTeam){
        log('createDetailLines(OpportunityLineItem opptyProduct,List<SalesTeamMember> salesTeam):opptyProduct='+opptyProduct+',salesTeam='+salesTeam);
        Detail_Line__c tempDetail;
        List<Detail_Line__c> retList = new List<Detail_Line__c>(); 
        Decimal splitPct=0.0;
        Integer tempIndex=0;
        for(SalesTeamMember teamMbr: salesTeam){
            //Changed by srinivas for 11i integration error //Changed condition fro WR 153585 
           if(teamMbr.opptyTeamMember.user.isActive)
           {
                if(teamMbr.detailSplit!=null)
                {
                    retList.add(createDetail(opptyProduct,teamMbr,teamMbr.detailSplit.Split__c));
                }else
                {
                    //If this is the first Sales team member set the Split to 100%
                    if(tempIndex==0)
                    {
                        retList.add(createDetail(opptyProduct,teamMbr,100.0));
                    }else
                    {
                        retList.add(createDetail(opptyProduct,teamMbr,0.0));
                    }
                }
                tempIndex++;
           }    
        }
        log('createDetailLines(OpportunityLineItem opptyProduct,List<SalesTeamMember> salesTeam):retList='+retList);
        return retList;
    }
    
    /**
    Create OpportunitySplit records for the input parameters passed. This set the Split Pct to 100% of 0% 
    based on whether the New sales team user is the first in that forecast group or not. If the Split Pct
    is already set, then that is retained as the final Split Pct.
    */
    private List<OpportunitySplit> createOpptySplits(Set<String> opptySplitInfo,OpportunityLineItem opptyProduct,List<SalesTeamMember> salesTeam){
        String key;
        Decimal splitPct=0.0;
        Integer tempIndex=0;
        List<OpportunitySplit> retList = new List<OpportunitySplit>(); 
        for(SalesTeamMember teamMbr: salesTeam){
            if(!opptySplitInfo.contains(opptyProduct.OpportunityId+'_'+teamMbr.opptyTeamMember.UserId)){
                if(teamMbr.detailSplit!=null){
                    retList.add(createOpptySplit(teamMbr,teamMbr.detailSplit.Split__c));
                }else{
                    //If this is the first Sales team member set the Split to 100%
                    if(tempIndex==0){
                        retList.add(createOpptySplit(teamMbr,100.0));
                    }else{
                        retList.add(createOpptySplit(teamMbr,0.0));
                    }
                }
                tempIndex++;
                opptySplitInfo.add(opptyProduct.OpportunityId+'_'+teamMbr.opptyTeamMember.UserId);
            }
        }
        log('createDetailLines(OpportunityLineItem opptyProduct,List<SalesTeamMember> salesTeam):retList='+retList);
        return retList;
    }
    /**
    Create Detail_Line__c for the products and Sales Team Members passed in the input.
    
    @param SalesTeamMember teamMbr - Sales Team Member for whom the Detail_Line__c is to be created
    @param List<OpportunityLineItem> opptyProducts - Products for which the records need to be created
    @param Map<String,Map<Id,Id>> grpProdMap - Mapping of the Forecast Group & Product that they are associated with 
    */    
    private List<Detail_Line__c> createDetailLines( SalesTeamMember teamMbr,List<OpportunityLineItem> opptyProducts,
                                                    Map<String,Map<Id,Id>> grpProdMap,Decimal splitPct){
        log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):teamMbr='+teamMbr);
        log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):opptyProducts='+opptyProducts);
        log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):grpProdMap='+grpProdMap);
        log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):splitPct='+splitPct);
        Map<Id,Id> prodMap = grpProdMap.get(teamMbr.detailSplit.Forecast_Group__c);
        List<Detail_Line__c> retList = new List<Detail_Line__c>(); 
        //Changed condition fro WR 153585 
        if(prodMap!=null && teamMbr.opptyTeamMember.user.isActive){
            for(OpportunityLineItem opptyProduct: opptyProducts){
                if(prodMap.containsKey(opptyProduct.PricebookEntry.Product2Id)){
                    retList.add(createDetail(opptyProduct,teamMbr,splitPct));
                }
            }
            log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):retList='+retList);
            return retList;
        }else{
            log('createDetailLines(teammbr,opptyProducts,grpProdMap,splitPct):retList='+retList);
            //No products require to be created for this group
            return retList;     
        }
    }
    
    private Detail_Line__c createDetail(OpportunityLineItem opptyProduct,SalesTeamMember teamMbr,Decimal splitPct){
        log('createDetail():opptyProduct:'+opptyProduct);
        log('createDetail():teamMbr:'+teamMbr);
        log('createDetail():splitPct:'+splitPct);
        String forecastGrp = teamMbr.opptyTeamMember.User.Forecast_Group__c==null?teamMbr.detailSplit.Forecast_Group__c:teamMbr.opptyTeamMember.User.Forecast_Group__c;
        log('createDetail():forecastGrp='+forecastGrp);
        return new Detail_Line__c(Opportunity__c=opptyProduct.OpportunityId,
                                  Forecast_Group__c=forecastGrp,
                                  Split__c=splitPct,
                                  Direct_Amount__c=opptyProduct.UnitPrice,
                                  Opportunity_Product__c=opptyProduct.Id,
                                  OpportunityTeamMember__c=teamMbr.opptyTeamMember.Id,
                                  OwnerId=teamMbr.opptyTeamMember.UserId,
                                  Owner__c=teamMbr.opptyTeamMember.UserId,
                                  Product__c=opptyProduct.PricebookEntry.Product2Id,
                                  Quote_Amount__c=opptyProduct.Quote_Amount__c, // This line is added for Quote Amount updation (WR 124383) By Saravanan
                                  CurrencyIsoCode=opptyProduct.opportunity.CurrencyIsoCode);
        
    }    
    private OpportunitySplit createOpptySplit(SalesTeamMember teamMbr,Decimal splitPct){
        log('createOpptySplit:teamMbr='+teamMbr+',splitPct='+splitPct);
        OpportunitySplit splitInfo = new OpportunitySplit(  OpportunityId=teamMbr.opptyTeamMember.OpportunityId,
                                                            SplitPercentage=splitPct,
                                                            SplitOwnerId=teamMbr.opptyTeamMember.UserId,
                                                            SplitNote=splitPct+' %'); 
        log('createOpptySplit:splitInfo='+splitInfo);
        return splitInfo; 
    }

    /**
    Get a list of all Sales Team Members for the Opportunity passed in the input
    
    @param Id opptyId - Id of the Opportunity
    @return Map<String,List<SalesTeamMember>> - Key is Forecast Group, value is List of existing Sales team me,bers
    */       
    private Map<String,List<SalesTeamMember>> getAllSalesTeamMembers(Id opptyId){
        log('getAllSalesTeamMembers:opptyId='+opptyId);
        Map<String,List<SalesTeamMember>> salesTeam = new Map<String,List<SalesTeamMember>>();
        List<SalesTeamMember> teamMbrs=new List<SalesTeamMember>(); 
        //Get all the sales teams and group them by forecast group
        List<SalesTeamMember> slsTeamMbrs = getSalesTeamMembers(opptyId);
        log('getAllSalesTeamMembers:slsTeamMbrs='+slsTeamMbrs);
        if(!slsTeamMbrs.isEmpty()){
            // 25-Nov-10 Change for WR: 152818  
            for(SalesTeamMember teamMbr: slsTeamMbrs)
            {   
                if(teamMbr.opptyTeamMember == null)
                   continue;
                // End of 25-Nov-10 Change for WR: 152818 
                System.debug('teamMbr-->'+teamMbr);
                System.debug('teamMbr.opptyTeamMember-->'+teamMbr.opptyTeamMember);
                System.debug('teamMbr.opptyTeamMember.User-->'+teamMbr.opptyTeamMember.User);
                if(salesTeam.containsKey(teamMbr.opptyTeamMember.User.Forecast_Group__c)){
                    System.debug('In IF--->'+salesTeam);
                    teamMbrs = salesTeam.get(teamMbr.opptyTeamMember.User.Forecast_Group__c);
                }else{
                    System.debug('123'+salesTeam);
                    teamMbrs = new List<SalesTeamMember>();
                    salesTeam.put(teamMbr.opptyTeamMember.User.Forecast_Group__c,teamMbrs);
                                    
                }
                System.debug('123'+salesTeam);
                System.debug('123'+salesTeam.size());
                teamMbrs.add(teamMbr);
                System.debug('teamMbrs---->'+teamMbrs);
            }
        }    
        log('getAllSalesTeamMembers:salesTeam='+salesTeam);
        return salesTeam;
    }
    

    /**
    Get a list of all Sales Team Members for a list of Opportunity Ids passed in the input
    
    @param List<Id> opptyIdList - List of Oppty Ids
    @return Map<String,List<SalesTeamMember>> - Key is Forecast Group, value is List of existing Sales team me,bers
    */       
    Public Map<Id,Map<Id,SalesTeamMember>> getSalesTeamMembers(List<Id> opptyIdList){
        log('getSalesTeamMembers(List<Id> opptyIdList):opptyIdList='+opptyIdList);
        
        //Get all the Detail_Line__c records for all the OpportunityIds passed in the input
        Map<Id,Map<Id,SalesTeamMember>> retMap = getDetailLines(opptyIdList);
        Map<Id,SalesTeamMember> salesTeamMap;
        SalesTeamMember tempMbr;
        //Get all Opportunity Team Members for the opportunityIds in the input, and 
        //set the detailSplit create a Sales Team Member ojbect using that record
        //and the Detail_Line__c fetched earlier if one exists.
        for(OpportunityTeamMember teamMbr: [select  Id,OpportunityId,UserId,User.IsActive,User.Name,User.Forecast_Group__c,
                                                    TeamMemberRole,OpportunityAccessLevel
                                            from OpportunityTeamMember
                                            where OpportunityId in :opptyIdList
                                            order by User.Forecast_Group__c asc])
        {
            System.debug('teamMbr-->'+teamMbr);
            salesTeamMap = retMap.get(teamMbr.OpportunityId);
            log('getSalesTeamMembers(List<Id>):teamMbr.UserId='+teamMbr.UserId);
            log('getSalesTeamMembers(List<Id>):salesTeamMap='+salesTeamMap);
            if(salesTeamMap!=null){
                //Get the Detail_Line__c record for the current OpportunityTeamMember.UserId
                tempMbr = salesTeamMap.get(teamMbr.UserId);
                if(tempMbr!=null){
                    //If one is found, set the OpportunityTeamMember__c
                    if(tempMbr.detailSplit!=null){
                        tempMbr.detailSplit.OpportunityTeamMember__c=teamMbr.Id;
                    }
                    //If one is found, set the opptyTeamMember of SalesTeamMember to the current OpportunityTeamMember
                    tempMbr.opptyTeamMember=teamMbr;
                }else{
                    tempMbr = new SalesTeamMember(false,teamMbr);
                    salesTeamMap.put(teamMbr.UserId,tempMbr);
                }
            }else{
                //If no detail Lines are found, create a new mapping of User Id to Sales Team Member
                //Add this to the retMap so that for the second OpportunityTeamMember this logic does'nt
                //get executed
                salesTeamMap = new Map<Id,SalesTeamMember>();
                tempMbr = new SalesTeamMember(false,teamMbr);
                salesTeamMap.put(teamMbr.UserId,tempMbr);
                retMap.put(teamMbr.OpportunityId,salesTeamMap);
            }
        }
        log('getSalesTeamMembers(List<Id>):retMap='+retMap);
        return retMap;
        
    }
    
    /**
    Get the list of Sales Team Member grouped by Forescast Group.
    
    @param List<Id> opptyIdList- List of Oppty Ids
    @return Map<Id,Map<String,List<SalesTeamMember>>> - Key is OpportunityId,Value is Forecast-Group to List
                                                        of sales team users 
    */       
    private Map<Id,Map<String,List<SalesTeamMember>>> getSalesTeamMembersByGroup(List<Id> opptyIdList){
        log('getSalesTeamMembersByGroup:opptyIdList='+opptyIdList);
        //Get all the Detail_Line__c for the passed in opportunity ids
        Map<Id,Map<Id,SalesTeamMember>> tempSalesTeamMap = getDetailLines(opptyIdList);
        Map<Id,Map<String,List<SalesTeamMember>>> retMap = new Map<Id,Map<String,List<SalesTeamMember>>> ();
        Map<String,List<SalesTeamMember>> salesTeamMap;
        Map<Id,SalesTeamMember> tempMap;
        SalesTeamMember tempMbr;
        List<SalesTeamMember> tempMbrList;
        //Iterate through the OpportunityTeamMember for the matching Oppty Ids
        for(OpportunityTeamMember teamMbr: [select  Id,OpportunityId,UserId,User.IsActive,User.Name,User.Forecast_Group__c,
                                                    TeamMemberRole,OpportunityAccessLevel
                                            from OpportunityTeamMember
                                            where OpportunityId in :opptyIdList])
        {
            log('getSalesTeamMembersByGroup:teamMbr='+teamMbr);
            //Get the detail lines for this opportunity
            tempMap = tempSalesTeamMap.get(teamMbr.OpportunityId);
            log('getSalesTeamMembersByGroup:tempMap='+tempMap);
            if(tempMap!=null){
                //Get the detail line for the User
                tempMbr = tempMap.get(teamMbr.UserId);
                log('getSalesTeamMembersByGroup:tempMbr='+tempMbr);
                if(tempMbr!=null){
                    tempMbr.opptyTeamMember=teamMbr;
                    tempMbr.detailSplit.OpportunityTeamMember__c=teamMbr.Id;
                }else{
                    tempMbr = new SalesTeamMember(false,teamMbr);
                }
            }else{
                log('getSalesTeamMembersByGroup:No details found for Opportunity:'+teamMbr.OpportunityId);
                tempMbr = new SalesTeamMember(false,teamMbr);
            }
            //There's no detail lines for this opportunity
            if(retMap.containsKey(teamMbr.OpportunityId)){
                salesTeamMap = retMap.get(teamMbr.OpportunityId); 
            }else{
                log('getSalesTeamMembersByGroup:OpptyId not in retMap.');
                salesTeamMap = new Map<String,List<SalesTeamMember>>();
                retMap.put(teamMbr.OpportunityId,salesTeamMap);
            }
            if(salesTeamMap.containsKey(teamMbr.User.Forecast_Group__c)){
                log('getSalesTeamMembersByGroup:Forecast Group:'+teamMbr.User.Forecast_Group__c+' found in salesTeamMap');
                tempMbrList =salesTeamMap.get(teamMbr.User.Forecast_Group__c);
            }else{
                log('getSalesTeamMembersByGroup:Forecast Group:'+teamMbr.User.Forecast_Group__c+' not found in salesTeamMap');
                tempMbrList = new List<SalesTeamMember>();
                salesTeamMap.put(teamMbr.User.Forecast_Group__c,tempMbrList);
            }
            tempMbrList.add(tempMbr);
            log('getSalesTeamMembersByGroup:Forecast Group:'+teamMbr.User.Forecast_Group__c+',tempMbrList.size()='+tempMbrList.size());
        }
        log('getSalesTeamMembersByGroup(List<Id>:retMap:'+retMap);
        return retMap;
    }    

    private Map<Id,Map<Id,SalesTeamMember>> getDetailLines(List<Id> opptyIdList){

        log('getDetailLines(List<Id> opptyIdList):opptyIdList='+opptyIdList);
        Map<Id,Map<Id,SalesTeamMember>> retMap = new Map<Id,Map<Id,SalesTeamMember>>();
        Map<Id,SalesTeamMember> salesTeamMap;
        List<SalesTeamMember> salesTeamList = new List<SalesTeamMember>();
        SalesTeamMember tempMbr;
        for(Detail_Line__c detail: [Select  Id,Split__c,Product__r.Name, Opportunity__c, 
                                            Opportunity_Access_Level__c,Quote_Amount__c,
                                            OwnerId,Forecast_Group__c
                                    From    Detail_Line__c
                                    where   Opportunity__c in :opptyIdList])
        {
            if(retMap.containsKey(detail.Opportunity__c)){
                salesTeamMap = retMap.get(detail.Opportunity__c);
            }else{
                salesTeamMap= new Map<Id,SalesTeamMember>(); 
                retMap.put(detail.Opportunity__c,salesTeamMap);
            }
            tempMbr=new SalesTeamMember(false,null);
            tempMbr.detailSplit=detail;
            salesTeamMap.put(detail.OwnerId,tempMbr);
        }
        log('getDetailLines:retMap='+retMap);
        return retMap;  
    }
    /*
    UNUSED METHOD
    private Map<Id,Map<Id,SalesTeamMember>> getOpptyTeamMembers(List<Id> opptyIdList){

        log('getOpptyTeamMembers(List<Id>:opptyIdList:'+opptyIdList);
        Map<Id,Map<Id,SalesTeamMember>> retMap = new Map<Id,Map<Id,SalesTeamMember>>();
        Map<Id,SalesTeamMember> salesTeamMap;
        List<SalesTeamMember> salesTeamList = new List<SalesTeamMember>();
        SalesTeamMember tempMbr;
        for(OpportunityTeamMember teamMbr :[select  OpportunityId,UserId,User.IsActive,User.Name,User.Forecast_Group__c,
                                                    TeamMemberRole,OpportunityAccessLevel
                                            from OpportunityTeamMember
                                            where OpportunityId in :opptyIdList
                                            order by User.Name asc])
        {
            if(retMap.containsKey(teamMbr.OpportunityId)){
                salesTeamMap = retMap.get(teamMbr.OpportunityId);
            }else{
                salesTeamMap= new Map<Id,SalesTeamMember>(); 
                retMap.put(teamMbr.OpportunityId,salesTeamMap);
            }
            tempMbr=new SalesTeamMember(false,teamMbr);
            salesTeamMap.put(teamMbr.UserId,tempMbr);
        }
        log('getOpptyTeamMembers:retMap='+retMap);
        return retMap;  
    }*/
    public List<SalesTeamMember> filterInactiveUsers(List<SalesTeamMember> teamMbrsList){
        System.debug('teamMbrsList1-->'+teamMbrsList);
        //List<Id> userIdList = new List<Id>();
        set<Id> userIdset = new set<Id>();
        List<SalesTeamMember> retList = new List<SalesTeamMember>();
        for(SalesTeamMember teamMbr:teamMbrsList){
            if(teamMbr.opptyTeamMember != null)
                userIdset.add(teamMbr.opptyTeamMember.UserId);
        }
        System.debug('userIdList1-->'+userIdset);
        //Map<Id,User> userMap = new Map<ID, User>([select Id,IsActive from User where id in :userIdList]);
        Map<Id,User> userMap = UserHelper.getUserRecords(userIdset);
        for(SalesTeamMember teamMbr:teamMbrsList){
            
            if(userMap.get(teamMbr.opptyTeamMember.UserId).IsActive){
                retList.add(teamMbr);
            }
        }
        return retList;
    } 

    private List<SalesTeamMember> filterExistingSalesTeamUsers(Id opptyId,List<SalesTeamMember> teamMbrsList){
        log('filterExistingSalesTeamUsers:opptyId='+opptyId+',teamMbrsList='+teamMbrsList);
        List<Id> opptyIdList = new List<Id>();
        opptyIdList.add(opptyId);
        Map<Id,Map<Id,SalesTeamMember>> tempMap= getSalesTeamMembers(opptyIdList);
        Map<Id,SalesTeamMember> currTeam = tempMap.get(opptyId);
        if(currTeam!=null){
            List<SalesTeamMember> retList = new List<SalesTeamMember>();
            for(SalesTeamMember teamMbr:teamMbrsList){
                if(!currTeam.containsKey(teamMbr.opptyTeamMember.UserId)){
                    retList.add(teamMbr);
                }
            }
            return retList;
        }else{
            return teamMbrsList;
        }
    } 

    private List<SalesTeamMember> getExistingSalesTeamMembers(Id opptyId,List<SalesTeamMember> teamMbrsList){
        log('getExistingSalesTeamMembers:opptyId='+opptyId+',teamMbrsList='+teamMbrsList);
        List<Id> opptyIdList = new List<Id>();
        opptyIdList.add(opptyId);
        Map<Id,Map<Id,SalesTeamMember>> tempMap= getSalesTeamMembers(opptyIdList);
        Map<Id,SalesTeamMember> currTeam = tempMap.get(opptyId);
        List<SalesTeamMember> retList = new List<SalesTeamMember>(); 
        if(currTeam!=null){
            for(SalesTeamMember teamMbr:teamMbrsList){
                if(currTeam.containsKey(teamMbr.opptyTeamMember.UserId) && teamMbr.detailSplit.Split__c!=null){
                    retList.add(teamMbr);
                }
            }
        }
        log('getExistingSalesTeamMembers:retList='+retList);
        return retList;
        
    } 

    private void log(String logMsg){
        System.debug('********************* '+logMsg);
    }
}