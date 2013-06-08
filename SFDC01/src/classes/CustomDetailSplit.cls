/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 | 
    16-Feb-10 Saravanan C    Updated groupSplits() Method - WR 123622
    
    29-Apr-10 Karthik        Updated groupSplits() Method - WR 131541 for Defect#635 Split% validation
    
    03-06-10  Prasad         Updated validateUserData() method and inserted the if condition to check showerror for defect#706 
    17-Jun-10 Shipra         Called Opp_DeleteOrphanDetailLine.cls to delete Orphan detail lines.
    17-Sep-10 Shipra         Cleaned code for Developer Script exception. WR:146082
    25-Nov-10 Srinivas       Cleaned code for Developer Script exception. WR:152818 
    25-Feb-11 Srinivas       WR-159448 , Commenting if conditions for bypassing Opportunity validation To not to show any opportunity related errors on Page
    27-Jan-12 Shipra         Fix for issue from TCOE-Account Owner functionality not working.Validation rule not firing.
    16-Feb-12  D Quinn       WR-188298 updating version settings tofix display issues caused by new UI and Spring 12 release.
    01-Aug-12 Smitha         WR-201029 Browser compliance for sales team splits and Sales split assignment page not reflecting the database information
    20-Mar-13 Hemavathi N M  WR-222852 Sales split - Opportunity access level for Account Owner
        
+===========================================================================*/


public class CustomDetailSplit{
  public String OpportunityId =ApexPages.currentPage().getParameters().get('Id');
  public Opportunity oppty {get; set;}
  public List<SalesTeamMember> salesTeam=new List<SalesTeamMember>(); 
  public Forecast_Mapping__c criteria {get; set;}
  public String Userforecastgroup{get;set;}
  public Integer UserAccountOwner{get;set;}// Added by Hema - WR-222852
  Set<String> Forecastmapping=new Set<String>();
  Set<String> ExistingTeam= new Set<String>();
  public Map<String,OpportunityTeamMember> OppTeamMem=new Map<String,OpportunityTeamMember>();
  Public String OppOwner{get;set;}
  Double Splitpercentage;
  Boolean splitExceeding;
  Boolean WrongSplit; // Added by Saravanan.C - WR 123622
  public Boolean showerrorblock{get;set;}
  Boolean OppAccessFieldValue;
  Public Boolean showerror{get;set;}
  Public Boolean isOwnerRead = false;
  public boolean NoOpptyAccess = false;
  public String RemoveNullUser;
  Public Set<String> userIdsOnPage= new Set<String>();
  boolean isError=false;
  Set<String> ExistingForecastGroup=new Set<String>();
  Public String SelectedTab{get;set;}  
  public Id radioOwnerSelected;
  
  //Added by Srinivas for new IIG Forecast Groups
  Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
  //////////////////////////////
  public void setRadioOwnerSelected(Id radown){
      this.radioOwnerSelected=radown;
  }
  Public Id getRadioOwnerSelected(){
  System.debug('radioOwnerSelected in Error'+radioOwnerSelected);
  return this.radioOwnerSelected;
  } 
  //OP_SSF_CommonUtils12 CommonUtils;
  OP_SSF_CommonUtils CommonUtils;
  
  
  public CustomdetailSplit(ApexPages.StandardController ctlr){
     oppty = (Opportunity)ctlr.getRecord();
    //Code Updated on 17-10-10 Developer Script Excetion cleanup.Added Try Catch Block//    
   try{
        if(oppty.Id!=null){
    //End of Code Updated on 17-10-10 Developer Script Excetion cleanup.//  
               showerror=false;
               // CommonUtils=(OP_SSF_CommonUtils12)OP_SSF_CommonUtils12.getInstance();
                CommonUtils=(OP_SSF_CommonUtils)OP_SSF_CommonUtils.getInstance();
                
                
                oppty = [  select owner.Forecast_Group__c,OwnerId,Id,AccountId,StageName,CloseDate,Amount 
                           from Opportunity 
                           where Id = :this.Oppty.Id];   
                radioOwnerSelected=((Id)oppty.OwnerId);

                Forecastmapping=productForcastGroup(oppty.Id);
                if(ApexPages.currentPage().getParameters().get('message')== 'Changes Saved'){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,System.Label.Changes_Saved);
                        ApexPages.addMessage(myMsg);
                        showerror=true;
                }
               if(ApexPages.currentPage().getParameters().get('selectedTab')=='Split'){
                   SelectedTab='Split';
               }     
               if(ApexPages.currentPage().getParameters().get('selectedTab')=='salesteam'){
                  SelectedTab='salesTeam';
               }
            }   
   }
   catch(Queryexception e){
    System.debug('The error is'+e);
   }
  
  }
  public List<SalesTeamMember> getSalesteam(){
     Userforecastgroup='';
     
     //Code Updated on 17-10-10 Developer Script Excetion cleanup.
     if(oppty.id!=null){
     //End of Code Updated on 17-10-10 Developer Script Excetion cleanup.
     if(salesteam.size()==0){
        salesteam=CommonUtils.getSalesTeamMembers(this.oppty.id); 
        System.debug(salesteam);
        for(SalesTeamMember mbr:salesTeam)
        {
             if(mbr.opptyTeamMember!=null)
             {
                ExistingForecastGroup.add(mbr.opptyTeamMember.User.Forecast_Group__c);
                ExistingTeam.add(mbr.opptyTeamMember.Userid);
                userIdsOnPage.add(mbr.opptyTeamMember.Userid);
                System.debug('userIdsOnPage if salesTeam size=0'+userIdsOnPage);
                //Modified for WR - 151992
                //if(mbr.opptyTeamMember.User.Forecast_Group__c!='Direct' && mbr.opptyTeamMember.User.Forecast_Group__c!='Maintenance Renewals')
                 if(! (mapSpecial_Forecast_Groups.containskey(mbr.opptyTeamMember.User.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(mbr.opptyTeamMember.User.Forecast_Group__c).Ownership_Allowed__c) )
                 {
                       Userforecastgroup+=mbr.opptyTeamMember.Userid+',';
                 }else
                       mbr.Owner_Eligible = 'Yes'; 
                 // End of changes for WR - 151992        
            }
            //To Populate in Split Tab
            if(mbr.detailSplit==null)
            {
               mbr.detailSplit=new Detail_Line__c();
               mbr.detailSplit.OwnerId=mbr.opptyTeamMember.UserId;
               mbr.detailSplit.Forecast_Group__c=mbr.opptyTeamMember.User.Forecast_Group__c;
               
               if(mbr.opptyTeamMember!=null)
               {    
                   if(mbr.opptyTeamMember.OpportunityAccessLevel!='None')
                   {
                       mbr.detailSplit.Opportunity_Access_Level__c=mbr.opptyTeamMember.OpportunityAccessLevel;
              
                   }
                   else
                   {
                       // Added by Hema - WR-222852 --- Start
                        mbr.detailSplit.Opportunity_Access_Level__c='Edit';
                        // mbr.detailSplit.Opportunity_Access_Level__c='All';
                      // Added by Hema - WR-222852 --- End
                         System.debug('in if--->'+mbr.Owner_Eligible);
                         
                         
                   }
               } 
               //mbr.detailSplit.Opportunity_Access_Level__c=mbr.opptyTeamMember.OpportunityAccessLevel;
               mbr.detailSplit.Opportunity__c=this.oppty.id;
               mbr.detailSplit.Split__c=0.0;
            }
             
             //Check For ProductForecastMapping
             if(Forecastmapping.contains(mbr.opptyTeamMember.User.Forecast_Group__c)){
                   mbr.ProductForecast=true;
             }else{
                   mbr.ProductForecast=false;
             } 
        }
     sortSalesTeam();  
     }else{
          for(SalesTeamMember stm:salesTeam){
           
             //Modified for WR - 151992
             //if(stm.opptyTeamMember.User.Forecast_Group__c!='Direct' && stm.opptyTeamMember.User.Forecast_Group__c!='Maintenance Renewals'){
             if(! (mapSpecial_Forecast_Groups.containskey(stm.opptyTeamMember.User.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(stm.opptyTeamMember.User.Forecast_Group__c).Ownership_Allowed__c) )
             {
                Userforecastgroup+=stm.opptyTeamMember.Userid+',';
                
             }else
                stm.Owner_Eligible = 'Yes';   
               /* if(stm.Owner_Eligible == 'Yes' && stm.detailSplit.Opportunity_Access_Level__c != 'Read' && stm.detailSplit.OwnerId != radioOwnerSelected)
                    {
                        stm.detailSplit.Opportunity_Access_Level__c='Edit';
                    }*/
                    
                
                System.debug('in else--->'+stm.Owner_Eligible+'<--->'+stm.detailSplit.OwnerId +'<--->'+radioOwnerSelected);
             // End of changes for WR - 151992  
          }  
     }
     
     }
  // Added by Hema - WR-222852    
  UserAccountOwner = salesteam.size();
  return this.salesteam;
 }
 
 
 

  /*Method For Finding Product exist or not for Forecast Group*/
  
 public set<String> productForcastGroup(String opptyid){
   List<String> Productids=new List<String>();
   Set<String> ForecastGroupSet=new Set<String>();
   List<OpportunityLineItem>Oppproductlist=[select id,pricebookEntry.Product2Id from OpportunityLineitem where opportunityId=:opptyid]; 
   
   for(Opportunitylineitem oppline:Oppproductlist){
      Productids.add(oppline.pricebookEntry.Product2Id);
   }
   List<Forecast_Group_Product__c> ForecastProductList=[Select Forecast_Mapping__r.Forecast_Group__c from Forecast_Group_Product__c where Product__c in:Productids];
   for(Forecast_Group_Product__c forcast:ForecastProductList){
      ForecastGroupSet.add(forcast.Forecast_Mapping__r.Forecast_Group__c);
   }
  return ForecastGroupSet;
 }

  public String getRemoveNullUser(){
     return '';
 }
 public void setRemoveNullUser(String val){
     this.RemoveNullUser=val;
 }
 public void removeSelected(){
   List<SalesTeamMember> removedlist=new List<SalesTeamMember>();
   isError=false;
   
   //Srinivas changes for new IIG forecast groups
   /* 
   for(Detail_Line__c detail: [Select  Id,Split__c,Product__r.Name, Opportunity__c, 
                                            Opportunity_Access_Level__c,Quote_Amount__c,
                                            OwnerId,Forecast_Group__c
                                    From    Detail_Line__c
                                    where   Opportunity__c = :oppty.id])
   {
        ExistingMemberForecastGroupss.add(detail.Forecast_Group__c);
   }
   */
   map<String,set<id>> mapExistingMemberForecastGroups= new map<String,set<id>>();
   for(OpportunityTeamMember topt : [Select User.Forecast_Group__c, UserId From OpportunityTeamMember where OpportunityId =:oppty.id])
    {
        if(mapExistingMemberForecastGroups.containsKey(topt.User.Forecast_Group__c))
            mapExistingMemberForecastGroups.get(topt.User.Forecast_Group__c).add(topt.UserId);
        else
            mapExistingMemberForecastGroups.put(topt.User.Forecast_Group__c, new set<id>{topt.UserId});    
    }
    
    
   ///////////
   
   for(SalesTeamMember stm:salesTeam){
      if(stm.opptyTeamMember.Userid==null ){
        
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PopulateUser);
         ApexPages.addMessage(myMsg);
         showerror=true;
          isError=true; 
      }else{
           if(radioOwnerSelected!=null){
              if(stm.selected==true && stm.opptyTeamMember.userId!=null && radioOwnerSelected==stm.opptyTeamMember.UserId){
                  System.debug('OwnerSeleted***');
                  System.debug('radioOwnerSelected**'+radioOwnerSelected);
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Reassigned_Ownership);
                  ApexPages.addMessage(myMsg);
                  showerror=true;
                  isError=true;
              }else{
                  // changes for WR - 151992
                  //if((stm.opptyTeamMember.User.Forecast_Group__c!='Direct' && stm.opptyTeamMember.User.Forecast_Group__c!='Maintenance Renewals' )&& stm.opptyTeamMember.UserId!=null && radioOwnerSelected.indexOf(stm.opptyTeamMember.UserId)!=-1){
                   if(stm.opptyTeamMember.UserId!=null && radioOwnerSelected==stm.opptyTeamMember.UserId)
                  {
                    if(! (mapSpecial_Forecast_Groups.containskey(stm.opptyTeamMember.User.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(stm.opptyTeamMember.User.Forecast_Group__c).Ownership_Allowed__c) )
                    {   
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Direct_Rep_As_Owner);
                        ApexPages.addMessage(myMsg);
                        showerror=true;
                        isError=true;
                    }
                  }
                  //Srinivas changes for new IIG forecast groups
                  //if user Forecast Group is a Special Forecast Group
                  if( mapSpecial_Forecast_Groups.containskey(stm.opptyTeamMember.User.Forecast_Group__c) )
                  {  
                    //If existing members has users forecast group and that For that FG multiple opportunity tam members are not allowed
                    if(mapExistingMemberForecastGroups.containsKey(stm.opptyTeamMember.User.Forecast_Group__c) && !mapSpecial_Forecast_Groups.get(stm.opptyTeamMember.User.Forecast_Group__c).Multiple_Oppty_Team_Members_Allowed__C )
                    {
                        // if the user is not an existing opportunity team member
                        if(!mapExistingMemberForecastGroups.get(stm.opptyTeamMember.User.Forecast_Group__c).contains(stm.opptyTeamMember.Userid) )
                        {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Only one User is allowed to be in the Opportunity Team for the Forecat Group '+ stm.opptyTeamMember.User.Forecast_Group__c);
                            ApexPages.addMessage(myMsg);
                            showerror=true;
                            isError=true;
                        }
                    }
                  }// End of changes for WR - 151992
                  ////////////////////////////
                  if(stm.opptyTeamMember.UserId!=null){
                     groupSplits();
                     System.debug('Check For Split Percentage');
                  }
                  if(stm.selected==true&&stm.opptyTeamMember.UserId==null){
                     System.debug('User Selected');
                     radioOwnerSelected=Oppty.ownerId;   
                     System.debug('radioOwnerSelected***'+radioOwnerSelected);   
                  }   
               }
           }
       }
   }
 } 
  public void groupSplits(){
    System.debug('GroupSplitcalled');
    Map<String,Double> ForecastGroupMap = new Map<String,Double>();
    Double splttotal = 0.0;
    Set<String> forecastgroupList=new Set<String>();
    //Double Splittotal=0.0;
    for(Integer i=0;i<salesTeam.size();i++){
         if(salesTeam[i].detailSplit==null)
         {
           System.debug('detailSplit is Null');
           continue;
         } // 25-Nov-10 Change for WR: 152818
         else if(salesTeam[i].detailSplit.Split__c == null)
                salesTeam[i].detailSplit.Split__c =0;   
          // End of 25-Nov-10 Change for WR: 152818       
         
         System.debug('salesTeam[i].Split.Split__c'+salesTeam[i].detailSplit.Split__c);
         System.debug('salesTeam[i].Split.Split__c'+salesTeam[i].detailSplit.Forecast_Group__c);
         System.debug('salesTeam[i].ProductForecast**'+'i'+salesTeam[i].ProductForecast);
         splttotal=ForecastGroupMap.get(salesTeam[i].detailSplit.Forecast_Group__c);
         System.debug('splttotal****'+splttotal);
         
         if(splttotal==null && salesTeam[i].selected==false && salesTeam[i].ProductForecast==true)
         {
             ForecastGroupMap.put(salesTeam[i].detailSplit.Forecast_Group__c,salesTeam[i].detailSplit.Split__c);        
             System.debug('salesTeam[i].ProductForecast**'+'i'+salesTeam[i].ProductForecast);
             System.debug('Put in Map Group'+salesTeam[i].detailSplit.Forecast_Group__c+'and'+salesTeam[i].detailSplit.Split__c);
         }else
         {
             if(salesTeam[i].selected==false && salesTeam[i].ProductForecast==true)
             {
                System.debug('salesTeam[i].ProductForecast**'+salesTeam[i].ProductForecast);
                System.debug('Fetch from Map and Add Split Percentage');
                splttotal=salesTeam[i].detailSplit.Split__c+splttotal;
                ForecastGroupMap.put(salesTeam[i].detailSplit.Forecast_Group__c,splttotal);
                System.debug('Update in Map Group'+salesTeam[i].detailSplit.Forecast_Group__c+'and'+splttotal);
             }
         }
   }
   
   
     
     System.debug('Forecast group map '+ForecastGroupMap);
     System.debug('splttotal after the loop'+splttotal);
/*    splitExceeding=false;
    WrongSplit=false; // Added by Saravanan.C - WR 123622
    for(String stn:ForecastGroupMap.keySet()){
        WrongSplit=true; // Added by Saravanan.C - WR 123622
       System.debug('ForecastGroupKey'+stn);
       Splitpercentage=ForecastGroupMap.get(stn);
       System.debug('Splitpercentage'+Splitpercentage);
       if(Splitpercentage!=100.0){
          splitExceeding = true;
          WrongSplit= false;  // Added by Saravanan.C - WR 123622
    }      
         // Update the SalesTeamMember // Added by Saravanan.C - WR 123622
*/
   /* Here in for loop, we are iterating through the sales team member list and along with that we are
      checking the split percentage count !100 using the ForecastGroupMap, which retuns the total split percentage
      if it is not equal to !100 we are marking red those fields*/
// Added by Karthik for WR - 131541

          for(SalesTeamMember stm:salesTeam){
          System.debug('Percentage '+stm.opptyTeamMember.User.Forecast_Group__c +'  '+ForecastGroupMap.get(stm.opptyTeamMember.User.Forecast_Group__c));
          System.debug('ProductForecast'+ stm.ProductForecast);
            if(ForecastGroupMap.get(stm.opptyTeamMember.User.Forecast_Group__c)!=null && ForecastGroupMap.get(stm.opptyTeamMember.User.Forecast_Group__c) != 100 && stm.ProductForecast == true){
                stm.splitExceeding = true;
                this.splitExceeding = true;
                System.debug('splitExceeding'+stm.splitExceeding);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Split_Percent_Forecast_Group);
                ApexPages.addMessage(myMsg);
                showerror=true;
             }
             else{
                 stm.splitExceeding = false;
                 this.splitExceeding = false;
                 System.debug('splitExceeding'+splitExceeding);
         }
       }
/*
       if(splitExceeding==true){
                  
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Split_Percent_Forecast_Group);
                  ApexPages.addMessage(myMsg);
                  showerror=true;
          }
*/                
 }
 
  public Boolean getsplitExceeding(){
      System.debug('splitExceeding'+splitExceeding);
      return splitExceeding;      
  }
   
  public void setSalesTeam(List<SalesTeamMember> slsteam){
  System.debug('*************SETSALESTEAM****************');
  this.salesTeam=slsteam;
  }
 
 public PageReference cancel(){
    PageReference nextpage= new PageReference('/'+OpportunityId);
    nextPage.setRedirect(true);
    return nextPage;
 }
 public boolean getOpptyAccess(){
      System.debug('In Get Oppty access is----->'+NoOpptyAccess);
      return NoOpptyAccess;
 }

  //Method for checking write access
  //Code Updated on 17-10-10 Developer Script Excetion cleanup.
  public PageReference init(){
    if(Oppty.Id !=null ){
    CheckOpportunityAccess chkaccess=new CheckOpportunityAccess();
    NoOpptyAccess=chkaccess.checkOppAcces(this.oppty.id);
    System.debug('NoOpptyAccess---'+NoOpptyAccess);
    //135993//
    Opp_DeleteOrphanDetailLine delOrpLine = new Opp_DeleteOrphanDetailLine();
    // WR141882    
    id oppid = this.Oppty.Id;
    // END OF UPDATION FOR 141882
    delOrpLine.delOrphanDetailLines(oppId);
    //135993//
    
    return null;
    }
    else{
        opptyDoesNotExist();
        System.debug('The else clause entered 1'+Oppty.Id);
        //PageReference nextpage= new PageReference('/apex/AddTeamsAndProducts');
        //nextPage.setRedirect(true);
        return null;
    }
  }
   
   
   public void  opptyDoesNotExist(){
        System.debug('The else clause entered 2'+Oppty.Id);
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Oppty_Id_DoesNot_Exist);
        ApexPages.addMessage(msg);
        showerror=true;
   }
   //End Of Code Updated on 17-10-10 Developer Script Excetion cleanup.
  private void removeNullUserfromSalesTeam(){
  List<Integer> removeFromList=new List<Integer>();
   for(Integer i=0;i<salesTeam.size();i++){
       if(salesTeam[i].opptyTeamMember.Userid==null)
       removeFromList.add(i);
       }
   System.debug('removeFromList***'+removeFromList); 
   System.debug('removeFromListSize***'+removeFromList.size());   
   for(Integer k=removeFromList.size()-1;k>=0;k--){
       System.debug('K***'+K);
         salesTeam.remove(removeFromList[k]);
   }
  }
  
  public PageReference addSalesTeamMember(){
    setAccountTeamMemberRole();
    this.salesTeam.add(new SalesTeamMember(false,new OpportunityTeamMember(OpportunityId=this.oppty.Id)));
    
    return null;
  }
  public void initNewMember(){
         setAccountTeamMemberRole(); 
         sortSalesTeam();  
  }
  public void setAccountTeamMemberRole(){
     System.debug('userIdsOnPage**************'+userIdsOnPage);   
     System.debug('Inside AccountTeamMemberRole**************');
     List<String> userIds=new List<String>();
     System.debug('salesTeam**************'+salesTeam);
     Map<String,String> userTeamMemberRole=new Map<String,String>();
    
   try{     
     for(SalesTeamMember member:salesTeam){
          
        System.debug('member-----'+member.opptyTeamMember.user.Id);   
        if(member.opptyTeamMember.userId!=null  && !userIdsOnPage.contains(member.opptyTeamMember.userId) ){
           system.debug('Condition True'+member.opptyTeamMember.userId);
           userIds.add(member.opptyTeamMember.UserId);
        }
     }
     AccountTeamMember[] AcctTeamMember = [Select AccountId, TeamMemberRole, UserId from AccountTeamMember  where UserId in :userIds and AccountId =:oppty.AccountId ];        
     for(AccountTeamMember member:AcctTeamMember){
        userTeamMemberRole.put(((String)(member.UserId)).substring(0,15),member.TeamMemberRole);
     }
     for(SalesTeamMember member:salesTeam){
        if(member.opptyTeamMember.UserId!=null && !userIdsOnPage.contains(member.opptyTeamMember.userId)){
          system.debug('Condition True*********'+member.opptyTeamMember.UserId);
          member.opptyTeamMember.TeamMemberRole=userTeamMemberRole.get(member.opptyTeamMember.UserId);
          member.opptyTeamMember.User= [select Name,Forecast_Group__c,IsActive from User where id=:member.opptyTeamMember.UserId];

         //Update the Detail Split Tab information
         System.debug('member.detailSplit****'+member.detailSplit);
         member.detailSplit=new Detail_Line__c();
         member.detailSplit.OwnerId=member.opptyTeamMember.UserId;
         member.detailSplit.Forecast_Group__c=member.opptyTeamMember.User.Forecast_Group__c;
        // member.detailSplit.Opportunity_Access_Level__c='Edit';
        System.debug('member.Owner_Eligible --->'+member.Owner_Eligible );
       
       if(member.Owner_Eligible == 'Yes')
        {
         member.detailSplit.Opportunity_Access_Level__c='All';
     
         }
         else{
         member.detailSplit.Opportunity_Access_Level__c='Edit';
     
        }
        
         if(ExistingForecastGroup.contains(member.detailSplit.Forecast_Group__c)){
             member.detailSplit.Split__c=0.0;  
             ExistingForecastGroup.add(member.detailSplit.Forecast_Group__c);
         }
         else{
             member.detailSplit.Split__c=100;
             ExistingForecastGroup.add(member.detailSplit.Forecast_Group__c);
         }
         if(Forecastmapping.contains(member.opptyTeamMember.User.Forecast_Group__c)){
            member.ProductForecast=true;
         }else{
               member.ProductForecast=false;
          }
       }       
     }
        userIdsOnPage.removeAll(userIdsOnPage);
        for(SalesTeamMember member:salesTeam){
           userIdsOnPage.add(member.opptyTeamMember.UserId);
        }
   }catch(StringException ex){
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Invalid_User);
     ApexPages.addMessage(myMsg); 
     showerror=true;
    }
  }
  
 void sortSalesTeam(){
     if(salesteam.size()==0){
         return;
     }
     Map<String,List<SalesTeamMember>> FGTeamMap =new Map<String,List<SalesTeamMember>>();      
     for(SalesTeamMember member:salesteam){
     System.debug('in sort-->'+member.Owner_Eligible);
         if(member.detailSplit!= null){
             List<SalesTeamMember> salesTeam= FGTeamMap.get(member.detailSplit.Forecast_Group__c);
               if(salesTeam==null){
                   salesTeam = new List<SalesTeamMember>();
               }
               salesTeam.add(member);
               FGTeamMap.put(member.detailSplit.Forecast_Group__c,salesTeam);          
          }
     }
     salesteam.clear();
     List<String> FGList= new  List<String>();
     FGList.addAll(FGTeamMap.keySet());
     FGList.sort();
     for(String FG :FGList){
         salesteam.addAll(FGTeamMap.get(FG));    
     }
 }
 
 public boolean validateUserData(){
   groupSplits();
   if(showError){
       return true;
   }
   boolean errorMessage=false;
  
     for(SalesTeamMember salesUsers:salesTeam){
        if((salesUsers.opptyTeamMember.UserId==null || salesUsers.opptyTeamMember.TeamMemberRole==null) && !(salesUsers.opptyTeamMember.UserId==null && salesUsers.opptyTeamMember.TeamMemberRole==null)  ){
           errorMessage=true;
           break;     
        }
     }
     if(errorMessage==true){
     System.debug('in validation===>');
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Populate_All_Fields);
        ApexPages.addMessage(myMsg);
        showerror=true; 
     }
        
  return errorMessage;
 }
 
 
 
 public void checkOppAccessFieldValue(){
 
  OppAccessFieldValue=false;
  ApexPages.Message myMsg2;
  ApexPages.Message myMsg3;
  for(SalesTeamMember stm:salesTeam){
     if(stm.detailSplit!=null){ 
      if(stm.detailSplit.Opportunity_Access_Level__c=='None'){
          System.debug('radioOwnerSelected in Error'+radioOwnerSelected);
          //radioOwnerSelected=radioOwnerSelected.substring(0,15);
          setradioOwnerSelected(radioOwnerSelected);
           myMsg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Proper_Access_For_User+stm.opptyTeamMember.User.Name);
          
          OppAccessFieldValue=True;
          showerror=true;
          System.debug('I am in line 437');
      }
     // Added by Hema - WR-222852 : Check if selected record is not Account Owner, Access level should not be "All".
     if(stm.detailSplit.Opportunity_Access_Level__c=='All' && radioOwnerSelected != stm.detailSplit.OwnerId ){
         myMsg2 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Transformation_AO_Access);
          
          showerror=true;
          isOwnerRead = true;
    }// Added by Hema - WR-222852-End
    }
  }
  if(showerror){
    ApexPages.addMessage(myMsg2);
    ApexPages.addMessage(myMsg3);
  }
 }
 public PageReference doSave()  {
    
   removeNullUserfromSalesTeam();
   setAccountTeamMemberRole();
   showerrorblock=false;
   showerror=false;
   System.debug('Do Save called');
   System.debug('validateUserData++++++++++++'+salesTeam);
   Savepoint sp = Database.setSavepoint();   
 try{
   boolean error1=validateUserData();
   removeSelected();
   checkOppAccessFieldValue(); 
   System.debug('Split Exceeding in save =>'+splitExceeding);
    if(error1 ||  isError || splitExceeding || OppAccessFieldValue){
      getradioOwnerSelected();
      return null;
    }
   System.debug('After the if loop for split exceeding');
   List<SalesTeamMember> MembersToInsert=new List<SalesTeamMember>();
   List<SalesTeamMember> MembersToDelete=new List<SalesTeamMember>();
   /* Srinivas : WR-159448. Commenting To by pass validation and not to show any opportunity related errors on VF page
   //changes for WR - 151992
  // if(oppty.owner.Forecast_Group__c!='Direct' && oppty.owner.Forecast_Group__c!='Maintenance Renewals'){
   if(! (mapSpecial_Forecast_Groups.containskey(oppty.owner.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(oppty.owner.Forecast_Group__c).Ownership_Allowed__c) )
   {*/
       oppty.bypass_validation__c=true;
       

       update oppty;
   //}
   
   for(SalesTeamMember stm:salesTeam ){
       if(stm.opptyTeamMember==null || stm.opptyTeamMember.Userid==null)
           continue;
       if(!ExistingTeam.contains(stm.opptyTeamMember.Userid) && !stm.Selected )
       MembersToInsert.add(stm);
       if(stm.Selected && ExistingTeam.contains(stm.opptyTeamMember.Userid))
        MembersToDelete.add(stm); 
        
   }

  

   if(MembersToInsert.size()>0){
       System.debug('MembersToInsert****'+MembersToInsert);
       CommonUtils.addSalesTeamMembers(MembersToInsert);    
   }

	 if(((String)Oppty.ownerid).indexof(radioOwnerSelected)==-1){
      System.debug('Oppty.ownerid'+Oppty.ownerid);
      System.debug('radioOwnerSelected'+radioOwnerSelected);
      System.debug('oppty.id'+oppty.id);
      CommonUtils.changeOwner(oppty.id,Oppty.ownerid,(ID)radioOwnerSelected);
  }
  
  // Added by Hema - WR-222852
  if(!isOwnerRead){
   CommonUtils.updateSplits(salesteam);
   }// Added by Hema - WR-222852- End
   //Moved this up from oppty update to bypass validation for delete also WR-159448
   System.debug('MembersToDelete.size()  '+MembersToDelete.size());
   if(MembersToDelete.size()>0){
       CommonUtils.removeSalesTeamMembers(MembersToDelete);
   }
   // End of moved code    
   /* Srinivas : WR-159448. Commenting To by pass validation and not to show any opportunity related errors on VF page 
   //changes for WR - 151992 
   //if(oppty.owner.Forecast_Group__c!='Direct' && oppty.owner.Forecast_Group__c!='Maintenance Renewals'){
   if(! (mapSpecial_Forecast_Groups.containskey(oppty.owner.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(oppty.owner.Forecast_Group__c).Ownership_Allowed__c) )
   {*/   
      oppty = [select bypass_validation__c,owner.Forecast_Group__c,ownerId,Id,AccountId,StageName,CloseDate,Amount 
               from Opportunity where Id = :this.Oppty.Id]; 
       oppty.bypass_validation__c=false;
      
       update oppty;
   //}// End of changes for WR - 151992
 
 } catch(OP_SSF_Exception ex){
       showerror=true;
       System.debug(String.valueOf(ex).indexOf('first error:'));     
       Integer j=String.valueOf(ex).indexOf('first error:');
       Integer k=String.valueOf(ex).lastIndexOf(']');
       if(k==-1){
          k=String.valueOf(ex).length();
       }
       String Message= String.valueOf(ex).substring(j+12,k-4);
       integer l =Message.indexOf(',');
       if(l>-1){
           Message= Message.substring(l+1);
       }
       System.debug('****'+Message+'****');
   /*    if(Message!=''){                           
            ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error, Message);
            System.debug('****#### The Validation Error is **** '+myMsg2);
            ApexPages.addMessage(myMsg2);
        }*/
        
   Database.rollback(sp);
   }
   catch(Exception ex){
      showerror=true;
      Integer i=ex.getMessage().indexof(',');
      ApexPages.Message myMsg4 = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage().substring(i+1));
     // ApexPages.addMessage(myMsg4);
      System.debug('Exception Exception '+ex.getMessage().substring(i+1));
      Database.rollback(sp);  
   } 
       if(showerror){
           System.debug('showerror  '+showerror );
           return null; 
           
        }else{
               PageReference pr= new PageReference ('/apex/AddTeamsAndProducts?message=Changes Saved&id='+this.oppty.Id+'&selectedTab='+SelectedTab);
               pr.setRedirect(true);
               return pr;
        }   
 
    
 
 }
     
 public List<SalesTeamMember> getdetailSplitTeam(){
   for(Integer i=0;i<salesTeam.size();i++){
      If(salesTeam[i].detailSplit.OwnerId==null){
         salesTeam.remove(i);
      }
   }
  return salesTeam;
 }

}