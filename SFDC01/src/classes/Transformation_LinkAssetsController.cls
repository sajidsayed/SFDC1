/*==================================================================================================================+

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER      WR        DESCRIPTION   strInputCode                            

 |  ====          =========      ==        =========== 

 |  08/01/2013    Medhavi D.               To Link the Asset with the opportunity.                      
 +==================================================================================================================**/

public class Transformation_LinkAssetsController {
    
        List<Asset__c> assets;
    String retURL='/a3S/o';  
        List<Id> opptyId = new List<Id>();

        public  Opportunity_Asset_Junction__c link {get;set;}
    public  Boolean isLinked {get;set;} 
    public  List<Asset__c> lsta {get;set;}
    public List<string> lstSelectedAccount{get;set;}
    public List<string> lstSelectedAccId{get;set;}
   
   //Properties for Lookup
    public String strInputCode { get; set; }
    public string strInputAcc { get; set; }
    public string strInputAccId{get;set;}
    public List<Opportunity> list_OpptyDataResults { get; set; }  
    public List<Opportunity> list_MasterOpptyDataResults { get; set; }  
    public String selectedOppty ;
    public String OpportunityId ;
    public Boolean showClearList{get;set;}
    Map<string,string> accId = new  Map<string,string>();
     Map<Id,Id> SelAccId = new  Map<Id,Id>();
       Map<Id,Id> mapAccount = new Map<Id,Id>();
        string str ='' ;
      string str1 ='' ;
   //End of lookup
    List<Id> aId=new List<Id>();
    public Transformation_LinkAssetsController(){
                strInputCode = Apexpages.currentPage().getParameters().get('selOppty'); 
                strInputAcc = Apexpages.currentPage().getParameters().get('selAcc'); //current oppty account's customer profile account
                strInputAccId= Apexpages.currentPage().getParameters().get('selAcId'); //current oppty account
                setAcc();            
                SearchMasterData();
                
    }
    public Transformation_LinkAssetsController(ApexPages.StandardSetController controller) {  
         isLinked = true;
         assets=Controller.getSelected(); 
         lsta =assets;
        
         link= new  Opportunity_Asset_Junction__c();      
         String strOpp = ApexPages.currentPage().getParameters().get('retURL');
         System.debug('strOpp  :'+strOpp);        
        //  String OpportunityId ='';       
          OpportunityId ='';
          if (strOpp.indexof('opportunityId')!=-1){
                 integer index =strOpp.indexof('opportunityId');
                 System.debug('index '+index);
                 OpportunityId=strOpp.substring(index +14);
                 link.Related_Opportunity__c=OpportunityId;
                 retURL='/'+OpportunityId;  
            }
               
         if(assets.size()==0 && (!(strOpp.indexof('opportunityId')!=-1))){
                                ApexPages.Message myMsg;
                                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Transformation_Go_back);
                                ApexPages.addMessage(myMsg);
                                isLinked = false;
                           
            }
         SelectedAccount();
       
   }         
   
    public pageReference linkAssets(){
          ApexPages.Message myMsg;
          List<Asset__c> lstAssets ;
          Boolean insertOppty = true;
      List<Transformation_AssetList__c> lstAssetId = new List<Transformation_AssetList__c>();
      List<String> lstAssId= new List<String>();
      Map<String,Transformation_AssetList__c> mapAssetId = Transformation_AssetList__c.getall();
  
      if(mapAssetId.size()>0){
            lstAssId.addAll(mapAssetId.KeySet());
            lstAssetId.addAll(mapAssetId.values());
           
       }
  
      
  
      List<Opportunity_Asset_Junction__c> lstOpptyAssert = new List<Opportunity_Asset_Junction__c>();
      try{
        String installedStr = System.Label.Transformation_Installed;
         if(assets.size()>0 ){
             lstOpptyAssert = [Select Id ,Related_Opportunity__c,Related_Asset__c from Opportunity_Asset_Junction__c where Related_Asset__c in:assets and Related_Asset__r.Disposition_Status__c !=: installedStr ];
            }
         else{
             lstOpptyAssert = [Select Id ,Related_Opportunity__c,Related_Asset__c from Opportunity_Asset_Junction__c where Related_Asset__c in:lstAssId and Related_Asset__r.Disposition_Status__c !=: installedStr];
             }
        }
     catch(Exception e){
        System.debug('e--->'+e);
        }
    
    
    
     if(lstOpptyAssert.size()>0){
        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Transformation_Asset_Link_Oppty);
        ApexPages.addMessage(myMsg);  
        insertOppty = false;
       }
    
  
    
     if(insertOppty){
       List<Opportunity_Asset_Junction__c> Lstoppass= new List<Opportunity_Asset_Junction__c>();
   
      //From Asset Tab Link
      if(assets.size()>0){
         for(Asset__c ass: assets){ 
            Lstoppass.add( new Opportunity_Asset_Junction__c(Related_Opportunity__c=link.Related_Opportunity__c, Related_Asset__c = ass.id));
   
          }
       }//End of Asset Tab Link
     
      //From Oppty MassLink
      if(lstAssId.size()>0){
              for(Id ids : lstAssId){
          Opportunity_Asset_Junction__c objOppAss = new Opportunity_Asset_Junction__c();
            objOppAss.Related_Opportunity__c = link.Related_Opportunity__c;
            objOppAss.Related_Asset__c = ids;
            Lstoppass.add( objOppAss);
            opptyId.add(link.Related_Opportunity__c);
      
         } //End For
        
         
       } //End Oppty MassLink
       
          //ToDelete All list from custom setting
 
       delete lstAssetId;
   
           //End Delete List from CS
           
       //To set the Disposition Status of Asset
       List<Asset__c> assetUpdate = new List<Asset__c>();
       if(assets.size()>0)
       assetUpdate =[select id,Disposition_Status__c from Asset__c where id IN:assets];
       if(lstAssId.size()>0)
       assetUpdate =[select id,Disposition_Status__c from Asset__c where id IN: lstAssId];
      
       Opportunity oppty =[select StageName ,Closed_Reason__c from Opportunity where Id =: link.Related_Opportunity__c];
    
       for(Asset__c assObj : assetUpdate){
    
       
          if(oppty.StageName == System.Label.Transformation_Pipeline || oppty.StageName == System.Label.Transformation_Upside
          || oppty.StageName == System.Label.Transformation_Strong_Upside || oppty.StageName == System.Label.Transformation_Commit
          || oppty.StageName == System.Label.Trasnformation_Submitted ||oppty.StageName == System.Label.Transformation_Eval){
              assObj.Disposition_Status__c = oppty.StageName;
          }
          else if(oppty.StageName == System.Label.Transformation_Booked){
              assObj.Disposition_Status__c = System.Label.Trasnformation_Displaced_by_EMC;
          }
          else if(oppty.StageName == System.Label.Transformation_Closed && oppty.Closed_Reason__c == System.Label.Transformation_Competition){
              assObj.Disposition_Status__c = System.Label.Transformation_Displaced_by_competitor;
          }
          else if(oppty.StageName == System.Label.Transformation_Closed && oppty.Closed_Reason__c != System.Label.Transformation_Competition){
              assObj.Disposition_Status__c = System.Label.Transformation_Installed;
          }
       }//End of for
       System.debug('assetUpdate-->'+assetUpdate );
       Update assetUpdate;
        
      updateTradeInsAndSwaps();

		List<Opportunity_Asset_Junction__c> objlist=new List<Opportunity_Asset_Junction__c>();
        objlist=[select id,name,Related_Opportunity__c from Opportunity_Asset_Junction__c where Related_Opportunity__c=:link.Related_Opportunity__c];
        
       insert Lstoppass; 
        if(objlist.size() == 0){
            Feedpost(opptyId);
         }
       //End of set the Disposition Status of Asset
       return new pagereference(retURL);
      }
      else
      return null; 
     }
         
         /* This Method is to clear the List when clear search items link is clicked*/  
   public PageReference clearData(){     
           list_OpptyDataResults.clear();   
           showClearList = false;        
           list_OpptyDataResults = list_MasterOpptyDataResults;    
           return null; 
         }    


         /* This is the search Functionlity which will fetch Opportunity based on the value entered in the input Box*/   
 public PageReference SearchMasterData() {
    
    
     
        list_OpptyDataResults = new List<Opportunity>();  
                 
           if((strInputCode != null && !strInputCode.equalsIgnoreCase('')) )     
                 {         
                         showClearList = true;    
                         if(strInputCode.endsWith('*'))     
                         {              
                         strInputCode = strInputCode.substring(0,strInputCode.length()-1);  
                         selectedOppty  = strInputCode +'%';       
                         }         
                         else     
                         {          
                         selectedOppty  = '%'+strInputCode +'%';     
                         }        
                         selectedOppty  = '%'+strInputCode +'%';  
                         if(str1 != ''){       
                                list_OpptyDataResults  = [SELECT Id, Name,stageName,Account_Name1__c,Opportunity_Closed_Date__c,BRS_Total_Forecast_Amount__c,Quote_Amount__c  FROM Opportunity where name Like: selectedOppty and AccountId in: mapAccount.keyset() and stageName != 'Closed' limit 25 ];           
                         }
                         else{
                                System.debug('selectedOppty--->'+selectedOppty);
                                list_OpptyDataResults  = [SELECT Id, Name,stageName,Account_Name1__c,Opportunity_Closed_Date__c,BRS_Total_Forecast_Amount__c,Quote_Amount__c  FROM Opportunity where name Like: selectedOppty  and stageName != 'Closed' limit 25 ];           
                         }
                 }    
                 else if(strInputCode == '' ||strInputCode == null  ){  
                         showClearList = true; 
                         list_OpptyDataResults  = [SELECT Id, Name,stageName,Account_Name1__c,Opportunity_Closed_Date__c,BRS_Total_Forecast_Amount__c,Quote_Amount__c  FROM Opportunity where stageName != 'Closed' and AccountId in: mapAccount.keyset() limit 25 ];           
                   }  
                 
                                 isLinked = true;
                                         return null;    
 }//end of method


  private void SelectedAccount(){
    List<Asset__c> lstSelectedAcc  =new List<Asset__c>();
        lstSelectedAccount=new List<Id>();
    lstSelectedAccId=new List<Id>();
    lstSelectedAcc =[select Customer_Name__c,Customer_Name__r.Customer_Profiled_Account_Lookup__c from Asset__c where id =: lsta];
       for(Asset__c objAcc: lstSelectedAcc ){
                lstSelectedAccount.add(objAcc.Customer_Name__r.Customer_Profiled_Account_Lookup__c);
                lstSelectedAccId.add(objAcc.Customer_Name__c);
                SelAccId.put(objAcc.Customer_Name__c,objAcc.Customer_Name__r.Customer_Profiled_Account_Lookup__c);
         }
     }
     
 public PageReference cancelLink() {
   
   if(OpportunityId != '' || OpportunityId.length()!=0){
     return new PageReference('/'+OpportunityId);}
   else{
    String assetObject = System.Label.Transformation_AssetObjectId;
  
     return new PageReference('/'+assetObject);
   }
}


  //Method to Update Trade Ins/Swaps if any asset is linked/uninked.
    public void updateTradeInsAndSwaps()
    {
  
        Trade_Ins_Competitive_Swap__c[] lstTradeInAndSwap;
        if(link.Related_Opportunity__c !=null )
        {
        
            lstTradeInAndSwap=[Select Swap_Value__c, Related_Opportunity__c,Registration_ID__c, Name, Id From Trade_Ins_Competitive_Swap__c where Related_Opportunity__c =: link.Related_Opportunity__c];
          
            if(lstTradeInAndSwap.size()!=0)
            {
               for(Trade_Ins_Competitive_Swap__c obj : lstTradeInAndSwap ){
        obj.Swap_Value__c=null;
                obj.Registration_ID__c='';
    }
            }
            if(lstTradeInAndSwap.size()!=0)
            {
                Database.SaveResult[] unlinkTradeInSwaps = Database.update(lstTradeInAndSwap,false);
            }
        }
    }

private void setAcc(){
 List<string> selAcc = new List<string>();
      List<string> selAccId = new List<string>();
     
     if(strInputAcc.length()>0 && str.length() == 0){
        strInputAcc=strInputAcc.deleteWhitespace();
        Integer i = strInputAcc.length()-1;
        strInputAcc=strInputAcc.substring(1,i);
        
        Integer k=0;
         str='(';
     
       for(String s: strInputAcc.Split(',')){
                        str = str+ '\'' + s +'\'' +',';
                //s='\'' + s +'\'';
                selAcc.add(s);
          }
          str =str.substring(0,str.length()-1);
          str =str + ')' ;
         
      }
      
      
      if(strInputAccId.length()>0 && str1.length() == 0){
      
      strInputAccId=strInputAccId.deleteWhitespace();
      Integer j = strInputAccId.length()-1;
         
          strInputAccId=strInputAccId.substring(1,j);
          str1='(';
                     for(String s1: strInputAccId.Split(',')){
                                 str1 = str1+ '\'' + s1 +'\'' +',';
                                 selAccId.add(s1);
                            }
                            str1 =str1.substring(0,str1.length()-1);
          str1 =str1 + ')' ;
            
      }
     
   
   
     if(str !='' || str.length() >4){
     String sq = 'select Id,Customer_Profiled_Account_Lookup__c from Account where Customer_Profiled_Account_Lookup__c IN' + str +'Limit 25';
    System.debug('sq--->'+sq);
         List<Account> lstAccount = Database.query(sq);
          if(lstAccount.size() >0){
                for(Account accObj : lstAccount){
               if(accObj.Customer_Profiled_Account_Lookup__c != null){
                        mapAccount.put(accObj.Id,accObj.Customer_Profiled_Account_Lookup__c);
                }
                   //if(!(mapAccount.containsKey(accObj.Customer_Profiled_Account_Lookup__c))){
                                mapAccount.put(accObj.Customer_Profiled_Account_Lookup__c,accObj.Customer_Profiled_Account_Lookup__c);
                       //   }
                 }
          }
     }
        else{
                // List<Account> lstAccount1 = [select Id,Customer_Profiled_Account_Lookup__c from Account where Id IN :('001V000000CxstkIAB')];
                System.debug('str1 -->'+str1);
                if(str1 != ''){
                String sq1 = 'select Id,Customer_Profiled_Account_Lookup__c from Account where Id IN' + str1 +' Limit 25';
               System.debug('sq1 -->'+sq1 );
                List<Account> lstAccount1 = Database.query(sq1);
                 if(lstAccount1.size() >0){
                 for(Account accObj : lstAccount1){
                        mapAccount.put(accObj.Id,accObj.Id);
                         }
                        }
                 }
             }
}


     /* @Method <Feedpost(): Method to post the Feeditems> 
       @param - <void>
       @throws exception - <Handeled exceptions>
     */
     // March eRFC change
     public static void Feedpost(List<Id> opptyid)
    {
        List<FeedItem> lstFeedItem = new List<FeedItem>();
       // for(Id obj : opptyid){
             FeedItem fItem = new FeedItem();
             fItem.Type = 'LinkPost';
             fItem.ParentId =opptyid[0];
             fItem.Title='Sales Promotions'; 
             fItem.LinkUrl='http://one.emc.com/clearspace/community/active/operation_mojo?view=overview';
             fItem.Body = 'There are competitive assets linked to this opportunity - Check out the Sales Promotions that you may qualify for!';
             lstFeedItem.add(fItem);
       //  }
         try{
           insert lstFeedItem;
         }
         catch(Exception ex){
             System.debug('---Exception---'+ex);  
         }
        
    }
     
}//end of class