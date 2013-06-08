/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER         WR          DESCRIPTION                               
 |  ====            =========         ==          =========== 
 |  03.10.2012      Shipra Misra     205804      Initial Creation.  MOJO Link/Unlink Functionality.
 |  17 Dec 2012     Krishna Pydavula 212171      Added Feed post code.  
 +========================================================================================================================*/
public class SFA_MOJO_OptyLinkDelinkController 
{
    //Hold the Asset records.
    public List<Asset__c> oppz;
    //Hold the Asset wrapper.
    public List<assetwrapper> astWrapper{ get; set;}
    //Hold the Asset wrapper.
    public List<assetwrapper> astlinkWrapper{ get; set;}
    //Hold the Selected Asset.
    List<Asset__c> selectedAssets = new List<Asset__c>(); 
    //Holds Opportunity Record.
    public Opportunity oppty;
    //Holds Boolean true if opportunity is closed.
    public Boolean OpportunityClosed;
    //Holds Boolean true if Cancel to be selected.
    public Boolean Cancel;
    //Holds list of Opportunity Junction Object.
    List<Opportunity_Asset_Junction__c> lstOptAstJunction= new List<Opportunity_Asset_Junction__c> ();
    //Holds Map of Opportunity Asset Junction object with Key as Opportunity and Asset Id.
    map<String,Opportunity_Asset_Junction__c> mapOptAstJunction=new map <String,Opportunity_Asset_Junction__c>();
    //Holds set of asset record Id where the associated opportunity is still not closed.
    Set<Id> setOptComptAstJunction=new Set<id>();
    //Hold Custom setting for record type ids for Competitive Install/ EMC Install.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    //Hold set of opportunity Id to be updated for Registration Id/Swap value nullification as part of GFS TradeIn/Swaps update.
    Set<Id> setOpportunityId= new Set<Id>();
    //Holds Asset Record type Id.
    Id AssetRecordType;
    //Holds Page Reference.
    public PageReference pagerefs;
    //Holds Page Reference.
    public PageReference pagerefs1;
    //Holds PageManager for Paginator Component.
    public PageManager objPageManager {get;set;}
    //Database.Saveresult.
    Database.SaveResult[] linkAsset=null;
     //Hold the Count of records errored out on update.
    public Integer intCountError;
    //Hold the Count of records saved successfully on update.
    public Integer intCountSaved;     
    
    public SFA_MOJO_OptyLinkDelinkController(){
    System.debug('Constructor');
    }
     
    public SFA_MOJO_OptyLinkDelinkController(ApexPages.StandardController controller) 
    {
        //Holds current Opportunity Record.
        this.oppty= (Opportunity)controller.getRecord();
        if(this.oppty==null || oppty.Id==null)return;
        //Instance of Asset Wrapper.
        astWrapper = new List<assetwrapper>();
        //Instance of Asset Wrapper.
        astlinkWrapper= new List<assetwrapper>();
        //Instance of Page Manager in Paginator.
        objPageManager = new PageManager(5); 
        //Instance of Competitive install.
        Boolean CompetitiveInstall=false;
        //Holds string value of Record Type Id.
        String recordId='';
        //Query to find out Related Account.
        Opportunity opp=[Select name,id,accountId,RecordTypeId ,stagename from opportunity where id =:oppty.id limit 1];
        //If Opportunity is closed put boolean as true.So that this opportunity cannot link to any Asset being closed.
        if(opp.StageName=='Closed')
        {
            //Stages that Opportunity is closed
            OpportunityClosed=true;
        }
        recordId=String.ValueOf(opp.RecordTypeId).substring(0,15);
        //Track if Opportunity is competitive install type then make competitive install as true.
        if(DataValueMap.get('Competitive Install').DataValue__c.contains(recordId))
        {
            AssetRecordType=DataValueMap.get('Asset Competitive Record Type Id').DataValue__c;
            CompetitiveInstall=true;
        }
        else
        {
            // else get Asset record type Id for EMC Install.
            AssetRecordType=DataValueMap.get('Asset EMC Install Record Type Id').DataValue__c;
        }
        //Query to pick Asset for Link/Unlink.
        oppz = [Select a.Serial_Number__c, a.Product_Family__c, a.Product_Name_Vendor__c, a.RecordTypeId, a.Name, 
                a.Monthly_Lease_Rate__c, a.Install_Date__c, a.Id, a.Customer_Name__c, 
                a.Contract_Number__c, a.Asset_Expiry_Date__c, 
                (Select Id, Name, Related_Opportunity__c, Related_Asset__c, Related_Account__c, 
                Asset_Record_Type_ID__c, Opportunity_Number__c, Opportunity_Forecast_Status__c, 
                Opportunity_Forecast_Amount__c, Opportunity_Close_Date__c,Isactive__c, Related_Opportunity_Customer_Number__c, 
                Related_Opportunity_SO_Number__c From Opportunity_Asset_Junction__r where Related_Account__c= :opp.accountId  ) 
                From Asset__c a where a.Customer_Name__r.id = :opp.accountId  and a.RecordTypeId = :AssetRecordType];
        
        if(oppz!=null && oppz.size()>0)
        
        //Make List of Opportunity Asset Junction for Link/Unlink.
        for(Asset__c asset: oppz)
        {
            if(asset.Opportunity_Asset_Junction__r!=null)
            {
                lstOptAstJunction.addall(asset.Opportunity_Asset_Junction__r);
            }
        }
        
        //Put Opportunity Asset Junction in Map with Related Opportunity and Related Asset as key.
        for(Opportunity_Asset_Junction__c objOppAstJun:lstOptAstJunction)
        {
            if((objOppAstJun.Related_Opportunity__c!=null )&&(!mapOptAstJunction.containsKey(objOppAstJun.Related_Opportunity__c+'|'+objOppAstJun.Related_Asset__c)))
            {
                mapOptAstJunction.put(objOppAstJun.Related_Opportunity__c+'|'+objOppAstJun.Related_Asset__c,objOppAstJun);
            }
            //if Opportunity is Competitive Installs track if there is any active Opportunity present on Asset.
            if(objOppAstJun.Related_Opportunity__c!=this.oppty.id && CompetitiveInstall==true )
            {
                if(objOppAstJun.Isactive__c==true)
                {
                    setOptComptAstJunction.add(objOppAstJun.Related_Asset__c);
                }
            }
        }
        
        //Make list of Asset Wrapper with records to be Linked/Unlinked.
        for(Asset__c assetWC: oppz)
        {
           if(mapOptAstJunction!=null && mapOptAstJunction.size()>0 && mapOptAstJunction.get(this.oppty.id+'|'+assetWC.Id)!=null && mapOptAstJunction.get(this.oppty.id+'|'+assetWC.Id).Related_Asset__c==assetWC.Id)
           {
             assetwrapper linkUnlinkWrap = new assetwrapper(assetWC,'');
             astWrapper.add(linkUnlinkWrap);
           }
           else 
           {
               if(!setOptComptAstJunction.contains(assetWC.id))
               {
                 assetwrapper linkUnlinkWrap = new assetwrapper(assetWC,'');
                 astlinkWrapper.add(linkUnlinkWrap);
               }
           }
        }
        objPageManager.numberOfRows = astWrapper.size();
    }
    //Method to Update Trade Ins/Swaps if any asset is linked/uninked.
    public void updateTradeInsAndSwaps(set<Id> setOpportunityId)
    {
        Trade_Ins_Competitive_Swap__c[] lstTradeInAndSwap;
        if(setOpportunityId!=null && setOpportunityId.size()>0)
        {
            lstTradeInAndSwap=[Select Swap_Value__c, Related_Opportunity__c,Registration_ID__c, Name, Id From Trade_Ins_Competitive_Swap__c where Related_Opportunity__c in: setOpportunityId];
            if(lstTradeInAndSwap.size()!=0)
            {
                lstTradeInAndSwap[0].Swap_Value__c=null;
                lstTradeInAndSwap[0].Registration_ID__c='';
            }
            if(lstTradeInAndSwap.size()!=0)
            {
                Database.SaveResult[] unlinkTradeInSwaps = Database.update(lstTradeInAndSwap,false);
            }
        }
    }
    
    /* @Method <delinkAsset(): Method to Unlink Asset based on selected records.> 
       @param - <void>
       @return <Page Reference> 
       @throws exception - <Handeled through Page Message>
    */
    public PageReference delinkAsset()
    {
           selectedAssets.clear();intCountError=0;
           list<Opportunity_Asset_Junction__c> lstUnlinkAsset= new List<Opportunity_Asset_Junction__c>();
           for(assetwrapper asstwrapper : astWrapper)
           {
                if(asstwrapper.selected == true)
                selectedAssets.add(asstwrapper.asset); 
           }
           if(selectedAssets.size()>0)
           {
            //find matching Opportunity Asset Junction records to be deleted.
            for(Asset__c ast:selectedAssets)
            {
                if(mapOptAstJunction!=null && mapOptAstJunction.size()>0 && mapOptAstJunction.get(this.oppty.id+'|'+ast.Id)!=null && mapOptAstJunction.get(this.oppty.id+'|'+ast.Id).Related_Asset__c==ast.Id)
                {
                    Opportunity_Asset_Junction__c opASJuncDel= new Opportunity_Asset_Junction__c();
                    opASJuncDel=mapOptAstJunction.get(this.oppty.id+'|'+ast.Id);
                    lstUnlinkAsset.add(mapOptAstJunction.get(this.oppty.id+'|'+ast.Id));
                    setOpportunityId.add(this.oppty.id);
                }
            }
            //If size >0 proceed with deletion.
            if(lstUnlinkAsset.size()>0)
            {       
              Database.DeleteResult[] delResults = Database.delete(lstUnlinkAsset,false);
              system.debug('delResults.size()***'+delResults.size());
              if (delResults != null && delResults.size() > 0)
              {
                String dataErrs ;astWrapper.clear();
                for (integer i = 0; i < delResults.size(); i++) 
                {
                 Database.DeleteResult sr = delResults[i];
                  dataErrs = '';
                  if (!sr.isSuccess()) 
                  {
                      for (Database.Error err : sr.getErrors()) 
                      {
                          dataErrs += err.getMessage()+System.Label.Contact_System_Administrator;
                          intCountError = intCountError+1;
                      }
                      Asset__c opptySuccess = oppz.get(i);
                      system.debug('opptySuccess***delink'+opptySuccess);
                      
                       astWrapper.add(new assetwrapper(opptySuccess,dataErrs));
                  }
                }
                if(dataErrs.length()> 0)
                {
                    Cancel=true;
                    intCountSaved=lstUnlinkAsset.size()-intCountError;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,intCountSaved+' '+System.label.Inline_Edit_of+' '+oppz.size()+' '+System.Label.Inline_Edit_Result);
                    ApexPages.addMessage(msg);
                    //return null;
                }
                else
                {
                    updateTradeInsAndSwaps(setOpportunityId);
                    pagerefs = new PageReference('/apex/SFA_MOJO_Assets_Link?id='+this.oppty.id);
                    pagerefs.setRedirect(true);
                }
              }
            }       
           }
           //selectedAssets.clear();
             
           return pagerefs;
     }
     
     /* @Method <linkToOpportunity(): Method to link Asset Related Account and Record Type.> 
       @param - <void>
       @return <Page Reference> 
       @throws exception - <Handeled through Page Message>
     */
     public PageReference linkToOpportunity()
     {
        objPageManager.numberOfRows = astlinkWrapper.size();
        pagerefs = new PageReference('/apex/SFA_MOJO_Asset_LinkToAccount?id='+this.oppty.id);
        return pagerefs;
     }
     
     // Added by Krishna for WR 212171
     /* @Method <Feedpost(): Method to post the Feeditems> 
       @param - <void>
       @throws exception - <Handeled exceptions>
     */
     public static void Feedpost(string opptyid)
     {
               FeedItem fItem = new FeedItem();
               fItem.Type = 'LinkPost';
               fItem.ParentId =opptyid;
               fItem.Title='Sales Promotions'; 
               fItem.LinkUrl='http://one.emc.com/clearspace/community/active/operation_mojo?view=overview';
               fItem.Body = 'There are competitive assets linked to this opportunity - Check out the Sales Promotions that you may qualify for!';
               try{
                 insert fItem;
               }
               catch(Exception ex){
                    System.debug('---Exception---'+ex); 
               }
        
     }
     
     /* @Method <doSave(): Method to Save related Assets on Opportunity.> 
       @param - <void>
       @return <Page Reference> 
       @throws exception - <Handeled through Page Message>
     */
     public PageReference doSave()
     {
       
       String retPage =ApexPages.currentPage().getUrl();
       list<Opportunity_Asset_Junction__c> lstlinkAsset= new List<Opportunity_Asset_Junction__c>();
       for(assetwrapper asstwrapper : astlinkWrapper)
       {
            if(asstwrapper.selected == true)
            selectedAssets.add(asstwrapper.asset);
       }
       if(selectedAssets.size()>0)
       {
        for(Asset__c ast:selectedAssets)
        {
            Opportunity_Asset_Junction__c opAsJuntRec= new Opportunity_Asset_Junction__c();
            opAsJuntRec.Related_Opportunity__c=this.oppty.id;
            opAsJuntRec.Related_Asset__c=ast.id;
            opAsJuntRec.Related_Account__c=ast.Customer_Name__c;
            setOpportunityId.add(this.oppty.id);
            lstlinkAsset.add(opAsJuntRec);
        }
        // Added by Krishna for WR 212171
        List<Opportunity_Asset_Junction__c> objlist=new List<Opportunity_Asset_Junction__c>();
        objlist=[select id,name,Related_Opportunity__c from Opportunity_Asset_Junction__c where Related_Opportunity__c=:this.oppty.id];
        
        if(lstlinkAsset.size()>0)
        {
           linkAsset = Database.insert(lstlinkAsset,false);
           System.debug('linkAsset###'+linkAsset);
           // Added by Krishna for WR 212171
           if(objlist.size()==0)
           {
               Feedpost(this.oppty.id);
           }
           intCountSaved=0;
          // intCountError=0;
           getData(linkAsset);
           //Calculate the successfully saved records. 
           system.debug('lstlinkAsset.size()###'+lstlinkAsset.size()+'###intCountError'+intCountError);
            intCountSaved=lstlinkAsset.size()-intCountError;
            //Check if there is no errored records set page reference to list view of oppty.
            if(intCountError<=0)
            {   
                updateTradeInsAndSwaps(setOpportunityId);
                pagerefs = new PageReference('/apex/SFA_MOJO_Assets_Link?id='+this.oppty.id); 
                pagerefs.setRedirect(true);
            }
            else
            {
                //if there exist some errored records send Message to VF apge that some records have errored out.
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,intCountSaved+' '+System.label.Inline_Edit_of+' '+oppz.size()+' '+System.Label.Inline_Edit_Result);
                //Add the message to VF page.
                ApexPages.addMessage(msg); 
            }
        }
         
        }
        return pagerefs;
     }
       // selectedAssets.clear();
     
     
     
    /* @Method <getOpportunityClosed(): This property is used to add product available for selection in the UI.> 
       @param - <void>
       @return <Boolean OpportunityClosed>> 
       @throws exception - <No Exception>
    */
    public Boolean getOpportunityClosed()
    {
        return OpportunityClosed;
    }
     /* @Method <getOpportunityClosed(): This property is used to add product available for selection in the UI.> 
       @param - <void>
       @return <Boolean OpportunityClosed>> 
       @throws exception - <No Exception>
    */
    public Boolean getCancel()
    {
        return Cancel;
    }
    
    /* @Method <getAssetsDetails(): Paginator Component for SFA_MOJO_Asset_Link > 
       @param - <void>
       @return <List<assetwrapper>> 
       @throws exception - <Handeled through Page Message>
    */
    public List<assetwrapper> getAssetsDetails()
    {
    
        List<assetwrapper> data = new List<assetwrapper>();
        System.debug('objPageManager ***'+objPageManager+'***objPageManager.numberOfRows***'+objPageManager.numberOfRows );
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<astWrapper.size();i++)
        {
            data.add(astWrapper.get(i));
            System.debug('***data***'+data);
            
        }
        return data;
    }
    
    /* @Method <getAssetstoBeLinkedDetails(): Paginator Component for SFA_MOJO_Asset_LinkToAccount > 
       @param - <void>
       @return <List<assetwrapper>> 
       @throws exception - <Handeled through Page Message>
    */
    public List<assetwrapper> getAssetstoBeLinkedDetails()
    {
    
        List<assetwrapper> data = new List<assetwrapper>();
        if(astlinkWrapper==null || astlinkWrapper.size()==0)return null;
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<astlinkWrapper.size();i++){
            data.add(astlinkWrapper.get(i));
        }
        return data;
    }
    
    /* @Method <docancel(): cancel any selection and return to Asset Link Page.> 
       @param - <void>
       @return <Page reference>> 
       @throws exception - <Handeled through Page Message>
    */
    public PageReference docancel()
    {
        PageReference  nextpage = new PageReference('/apex/SFA_MOJO_Assets_Link?id='+this.oppty.id); 
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    /* @Method <createorUpdateRecords(): This method is used to error handle the asset records and display proper message on likn/unlink page.> 
       @param - <Database.SaveResult[]>
       @return <String> 
       @throws exception - <Handeled through Page Message>
    */
    //*** Method called for tracking the result and adding it on the list wrapper.***//
    public void getData(Database.SaveResult[] inlineEdit)
    {   
        //Clearing out list wrapper.
        astlinkWrapper.clear();
        //Initializing intCountError.
        intCountError=0;
        //Hold String for return Page url.
        pagerefs=null;
        //Holds Value of error occured.
        String dataErrs = '';
        //Holds Value of Success Save.
        String dataSaves ='';
        //Check if Database.Saveresult has some records.
        if(inlineEdit !=null)
        {
            //Loop on Saveresult records.
            for (integer i = 0; i < inlineEdit.size(); i++) 
            {
                //Initializing dataErrs as blank for each result record.
                dataErrs ='';
                //Initializing dataSaves as blank for each result record.   
                dataSaves ='';
                //if the record has not saved successfully.
                if (!inlineEdit[i].isSuccess()) 
                {
                    //Looping on Database error for ith record.
                    for (Database.Error err : inlineEdit[i].getErrors()) 
                    {
                        //Adding error message in dataErrs.
                        dataErrs += err.getMessage()+System.Label.Contact_System_Administrator;
                        //incrementing the error count.
                        intCountError = intCountError+1;
                    }
                    // Getting the opportunty record which has errored out.
                    Asset__c opptySuccess = oppz.get(i);
                    //Check if record is not null.
                    if(opptySuccess != null)
                    {   
                      //Add opportunity Name along with error message.
                      //dataErrs +=  ' For Opportunity : ' + opptySuccess.Name;
                    }
                    //Add error message along with Opportunity record to list wrapper.
                    astlinkWrapper.add(new assetwrapper(opptySuccess,dataErrs));
                          
                }else
                {               
                    //if the record has saved successfully, get the saved opportunity record.
                    Asset__c opptySuccess = oppz.get(i);
                    System.debug('opptySuccess'+opptySuccess);
                    //Check if record saved is not null.
                  //  if(opptySuccess!=null )
                  //  {
                        //Add Success message on dataSaves for successfully saved record.
                        dataSaves +=System.Label.Inline_Edit_Result_Success;
                  //  }
                    //Add Success message along with Opportunity record to list wrapper.
                    astlinkWrapper.add(new assetwrapper(opptySuccess,dataSaves));
                }        
            }
        }
    }
  //Wrapper Class.
     public class assetwrapper
     {
        public Asset__c asset{get; set;}
        public Boolean selected {get; set;}
        public boolean OpportunityClosed {get;set;}
        //Holds Error String. Defining get,set property.
        public String dmlError {get;set;}
        
        public assetwrapper(Asset__c lstast, String dmlError)
        {
             //asset=lstast;
             this.asset = lstast;
             selected = false;
             this.dmlError = dmlError;
        }
     }
}