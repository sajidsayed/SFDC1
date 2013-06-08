global class OpportunityHeader{
    Webservice string OracleOppId;  //IN SFDC Opportunity Number
    Webservice string CloseComments;
    Webservice Date DecisionDate;  //Close Date
    Webservice string ClosedReason;
    Webservice string Comments_Details;
    Webservice string CurrencyCode;
    Webservice string SfdcCustomerId;  //Customer;
    Webservice Date DealRegApprovalDate;
    Webservice Date DealRegExpirationDate;
    Webservice string DispositionCode;
    Webservice string Status;//ForecastStatus;
    Webservice string NextSteps;
    Webservice string OpportunityName;
    Webservice string OpptyOriginator;
    Webservice string OwnerSfdcId;  //Opportunity Owner
    Webservice string QuoteOu;
    Webservice string QuoteType;
    Webservice string QuoteVersion;
    Webservice string QuoteNumber;
    Webservice string SalesChannel;
    Webservice string SalesForceOrg;  //Salesforce
    Webservice string SellingRelationship;
    Webservice string SfdcOpptyId;
    Webservice string SalesOrderNumber; //SONumber;
    Webservice string SourceCode;  //Source;
    Webservice string PartnerSfdcCustId;//Tier_1_Partner_Distributor
    Webservice string VmwareCode;
    Webservice string ErrorMessage;
    //RQF
    Webservice Decimal  SWDiscount;
    Webservice Decimal HWDiscount;
    Webservice Decimal Discount;
    Webservice Date QuoteStartDate;
    Webservice Date QuoteEndDate;
    Webservice Date HWTLAStartDate;
    Webservice string QuoteCreatedBy;
    Webservice string ContractNumber;
    Webservice string ContractNumberModifier;
    Webservice string BillToParty;
    Webservice string AdditionalField01;
    Webservice string AdditionalField02;
    Webservice string AdditionalField03;
    Webservice string AdditionalField04;
    Webservice string AdditionalField05;
    Webservice string AdditionalField06;
    Webservice string AdditionalField07;
    Webservice string AdditionalField08;
    Webservice string AdditionalField09;
    Webservice string AdditionalField10;
    //RQF
    //Pricing fields**Shipraa
    //Percentage fields
    Webservice Decimal HardwareDiscount;
    Webservice Decimal SoftwareDiscount;
    Webservice Decimal ServicesDiscount;
    Webservice Decimal PrepaidHWMADiscount;
    Webservice Decimal HWWarrantyUpgradeDiscount;
    Webservice Decimal PrepaidSWMADiscount;
    //currency fields
    Webservice Double TotalQuoteAmount;
    Webservice Double HWRevenue;
    Webservice Double SWRevenue;
    Webservice Double ServicesRevenue;
    Webservice Double PrepaidHWMARevenue;
    Webservice Double PrepaidSWMARevenue;
    Webservice Double HWWarrantyUpgradeRevenue;
    //string field**  
    Webservice string PriceFloor;
    //RQF Get
    global Decimal getSWDiscount(){
        return this.SWDiscount;
    }
    global Decimal getHWDiscount(){
        return this.HWDiscount;
    }
    global Decimal getDiscount(){
        return this.Discount;
    }
    global Date getQuoteStartDate(){
        return this.QuoteStartDate;
    }
    global Date getQuoteEndDate(){
        return this.QuoteEndDate;
    }
    global Date getHWTLAStartDate(){
        return this.HWTLAStartDate;
    }
    global String getQuoteCreatedBy(){
        return this.QuoteCreatedBy;
    }
    global String getContractNumber(){
        return this.ContractNumber;
    }
    global String getContractNumberModifier(){
        return this.ContractNumberModifier;
    }
    global String getBillToParty(){
        return this.BillToParty;
    }
    global String getAdditionalField01(){
        return this.AdditionalField01;
    }
    global String getAdditionalField02(){
        return this.AdditionalField02;
    }
    global String getAdditionalField03(){
        return this.AdditionalField03;
    }
    global String getAdditionalField04(){
        return this.AdditionalField04;
    }
    global String getAdditionalField05(){
        return this.AdditionalField05;
    }
    global String getAdditionalField06(){
        return this.AdditionalField06;
    }
    global String getAdditionalField07(){
        return this.AdditionalField07;
    }
    global String getAdditionalField08(){
        return this.AdditionalField08;
    }
    global String getAdditionalField09(){
        return this.AdditionalField09;
    }
    global String getAdditionalField10(){
        return this.AdditionalField10;
    }
    //** RQF Get
    global string getErrorMessage(){
            return this.ErrorMessage;
        }
    
    global void setErrorMessage(String ErrorMessage){
             this.ErrorMessage=ErrorMessage;
        }
    
    global string getOwnerSfdcId(){
            return this.OwnerSfdcId;
        }
    
    global string getOracleOppId(){
            return this.OracleOppId;
        }
     global string getCloseComments(){
            return this.CloseComments;
        }
    global Date getDecisionDate(){
            return this.DecisionDate;
        }
    global string getClosedReason(){
            return this.ClosedReason;
        }
    /*global string getComments_Details(){
            return this.Comments_Details;
        }*/
    global string getCurrencyCode(){
            return this.CurrencyCode;
        }
    global string getSfdcCustomerId(){
            return this.SfdcCustomerId;
        }
    global Date getDealRegApprovalDate(){
            return this.DealRegApprovalDate;
        }
    global Date getDealRegExpirationDate(){
            return this.DealRegExpirationDate;
        }
    global string getDispositionCode(){
            return this.DispositionCode;
        }
    global string getStatus(){
            return this.Status;
        }
    global string getNextSteps(){
            return this.NextSteps;
        }
    global string getOpportunityName(){
            return this.OpportunityName;
        }
    global string getOpptyOriginator(){
            return this.OpptyOriginator;
        }
    global string getQuoteOu(){
            return this.QuoteOu;
        }
    global string getQuoteType(){
            return this.QuoteType;
        }
    global string getQuoteVersion(){
            return this.QuoteVersion;
        }
    global string getQuoteNumber(){
            return this.QuoteNumber;
        }
    global string getSalesChannel(){
            return this.SalesChannel;
        }
    global string getSalesForceOrg(){
            return this.SalesForceOrg;
        }
    global string getSellingRelationship(){
            return this.SellingRelationship;
        }
    global string getSfdcOpptyId(){
            return this.SfdcOpptyId;
        }
    global string getSalesOrderNumber(){
            return this.SalesOrderNumber;
        }
    global string getSourceCode(){
            return this.SourceCode;
        }
    global string getPartnerSfdcCustId(){
            return this.PartnerSfdcCustId;
        }
    global string getVmwareCode(){
            return this.VmwareCode;
        }
        
    //Pricing fields**Shipraa
    //Percentage fields
    global Decimal getHardwareDiscount(){
    return this.HardwareDiscount;
    }
    global Decimal getSoftwareDiscount(){
    return this.SoftwareDiscount;
    }
    global Decimal getServicesDiscount(){
    return this.ServicesDiscount;
    }
    global Decimal getPrepaidHWMADiscount(){
    return this.PrepaidHWMADiscount;
    }
    global Decimal getPrepaidSWMADiscount(){
    return this.PrepaidSWMADiscount;
    }
    global Decimal getHWWarrantyUpgradeDiscount(){
    return this.HWWarrantyUpgradeDiscount;
    } 
    //currency fields
    global Double getTotalQuoteAmount(){
    return this.TotalQuoteAmount;
    }
    global Double getHWRevenue(){
    return this.HWRevenue;
    }
    global Double getSWRevenue(){
    return this.SWRevenue;
    }
    global Double getServicesRevenue(){
    return this.ServicesRevenue;
    }
    global Double getPrepaidHWMARevenue(){
    return this.PrepaidHWMARevenue;
    }
    global Double getPrepaidSWMARevenue(){
    return this.PrepaidSWMARevenue;
    }
    global Double getHWWarrantyUpgradeRevenue(){
    return this.HWWarrantyUpgradeRevenue;
    }
    //string field**  
    global string getPriceFloor(){
    return this.PriceFloor;
    }
       
    global void setOracleOppId(String oppnum){
            this.OracleOppId=oppnum;
        }
    global void setCloseComments(String closecomm){
            this.CloseComments=closecomm;
        }
    global void setDecisionDate(Date clsdate){
            this.DecisionDate=clsdate;
        }
    global void setClosedReason(String closersn){
            this.ClosedReason=closersn;
        }
    /*global void setComments_Details(String CommDetail){
            this.Comments_Details=CommDetail;
        }*/
    global void setCurrencyCode(String CurrencyName){
            this.CurrencyCode=CurrencyName;
        }
    global void setSfdcCustomerId(String Cust){
            this.SfdcCustomerId=Cust;
        }
    global void setDealRegApprovalDate(Date DealRegAppdate){
            this.DealRegApprovalDate=DealRegAppdate;
        }
    global void setDealRegExpirationDate(Date DealRegExpDate){
            this.DealRegExpirationDate=DealRegExpDate;
        }
    global void setDispositionCode(String Dispcode){
            this.DispositionCode=Dispcode;
        }
    global void setStatus(String Forecaststat){
            this.Status=Forecaststat;
        }
    global void setNextSteps(String nxtstep){
            this.NextSteps=nxtstep;
        }
    global void setOpportunityName(String oppname){
            this.OpportunityName=oppname;
        }
    global void setOpptyOriginator(String oppOringin){
            this.OpptyOriginator=oppOringin;
        }
    global void setOwnerSfdcId(String oppown){
            this.OwnerSfdcId=oppown;
        }
    global void setQuoteOu(String quote){
            this.QuoteOu=quote;
        }
    global void setQuoteType(String Quotetyp){
            this.QuoteType=Quotetyp;
        }
    global void setQuoteVersion(String quotever){
            this.QuoteVersion=quotever;
        }
    global void setQuoteNumber(String quotecart){
            this.QuoteNumber=quotecart;
        }
    global void setSalesChannel(String Saleschn){
            this.SalesChannel=Saleschn;
        }
    global void setSalesForceOrg(String SF){
            this.SalesForceOrg=SF;
        }
    global void setSellingRelationship(String sellrel){
            this.SellingRelationship=sellrel;
        }
    global void setSfdcOpptyId(String sfdcoppid){
            this.SfdcOpptyId=sfdcoppid;
        }
    global void setSalesOrderNumber(String sonum){
            this.SalesOrderNumber=sonum;
        }
    global void setSourceCode(String sour){
            this.SourceCode=sour;
        }
    global void setPartnerSfdcCustId(String tier1){
            this.PartnerSfdcCustId=tier1;
        }
    global void setVmwareCode(String vmware){
            this.VmwareCode=vmware;
        }
     //RQF Set
    global Decimal setSWDiscount(){
    return this.SWDiscount;
    }
    global Decimal setHWDiscount(){
        return this.HWDiscount;
    }
    global Decimal setDiscount(){
        return this.Discount;
    }
    global Date setQuoteStartDate(){
        return this.QuoteStartDate;
    }
    global Date setQuoteEndDate(){
        return this.QuoteEndDate;
    }
    global Date setHWTLAStartDate(){
        return this.HWTLAStartDate;
    }
    global String setQuoteCreatedBy(){
        return this.QuoteCreatedBy;
    }   
    global String setContractNumber(){
        return this.ContractNumber;
    }
    global String setContractNumberModifier(){
        return this.ContractNumberModifier;
    }
    global String setBillToParty(){
        return this.BillToParty;
    }
    global String setAdditionalField01(){
        return this.AdditionalField01;
    }
    global String setAdditionalField02(){
        return this.AdditionalField02;
    }
    global String setAdditionalField03(){
        return this.AdditionalField03;
    }
    global String setAdditionalField04(){
        return this.AdditionalField04;
    }
    global String setAdditionalField05(){
        return this.AdditionalField05;
    }
    global String setAdditionalField06(){
        return this.AdditionalField06;
    }
    global String setAdditionalField07(){
        return this.AdditionalField07;
    }
    global String setAdditionalField08(){
        return this.AdditionalField08;
    }
    global String setAdditionalField09(){
        return this.AdditionalField09;
    }
    global String setAdditionalField10(){
        return this.AdditionalField10;
    }
        //** RQF Set
       //Pricing fields**Shipraa
    //Percentage fields
    global Decimal setHardwareDiscount(){
    return this.HardwareDiscount;
    }
    global Decimal setSoftwareDiscount(){
    return this.SoftwareDiscount;
    }
    global Decimal setServicesDiscount(){
    return this.ServicesDiscount;
    }
    global Decimal setPrepaidHWMADiscount(){
    return this.PrepaidHWMADiscount;
    }
    global Decimal setPrepaidSWMADiscount(){
    return this.PrepaidSWMADiscount;
    }
    global Decimal setHWWarrantyUpgradeDiscount(){
    return this.HWWarrantyUpgradeDiscount;
    } 
    //currency fields
    global Double setTotalQuoteAmount(){
    return this.TotalQuoteAmount;
    }
    global Double setHWRevenue(){
    return this.HWRevenue;
    }
    global Double setSWRevenue(){
    return this.SWRevenue;
    }
    global Double setServicesRevenue(){
    return this.ServicesRevenue;
    }
    global Double setPrepaidHWMARevenue(){
    return this.PrepaidHWMARevenue;
    }
    global Double setPrepaidSWMARevenue(){
    return this.PrepaidSWMARevenue;
    }
    global Double setHWWarrantyUpgradeRevenue(){
    return this.HWWarrantyUpgradeRevenue;
    }
    //string field**  
    global string setPriceFloor(){
    return this.PriceFloor;
    }
    
    
  public OpportunityHeader (String sfdcOppId){
        Opportunity o = [SELECT ID,StageName,Opportunity_Number__c,Close_Comments__c,CloseDate,Closed_Reason__c,Comments_Details__c,
                         Approval_Date__c,Expiration_Date__c,Disposition_Code__c,Next_Steps__c,Name,Originator__c,OwnerID,Quote_Type__c,
                         Quote_Version__c,Quote_Cart_Number__c,Sales_Channel__c,Sales_Force__c,Sell_Relationship__c,SO_Number__c,
                         LeadSource,Partner__c,Vmware_Related__c,CurrencyIsoCode,AccountId,Quote_Operating_Unit__c,Integration_Error_Message__c,
                         SW_Discount_percent__c,HW_TLA_Start_Date__c,Quote_Created_by__c, Quote_Start_Date__c, Quote_End_Date__c, HW_Discount_percent__c, Discount_percent__c,
                         Contract_Number__c, Contract_Modifier__c, Bill_To__c,Total_Quote_Amount__c,  Software_Discount__c,  Services_Discount__c,  
                         SW_Revenue__c,  Price_Floor__c,  Prepaid_SW_MA_Revenue__c,  Prepaid_SW_MA_Discount__c,  Prepaid_HW_MA_Revenue__c,  
                         Prepaid_HW_MA_Discount__c,  Hardware_Discount__c,  HW_Warranty_Upgrade_Revenue__c,  HW_Warranty_Upgrade_Discount__c, Services_Revenue__c, HW_Revenue__c
                         FROM opportunity WHERE Id =: sfdcOppId];
               
                OracleOppId = o.Opportunity_Number__c;
                CloseComments  = o.Close_Comments__c;
                DecisionDate  = o.CloseDate;
                ClosedReason  = o.Closed_Reason__c;
                Comments_Details  = o.Comments_Details__c;
                CurrencyCode = o.CurrencyIsoCode;
                SfdcCustomerId = o.AccountId;
                DealRegApprovalDate = o.Approval_Date__c;
                DealRegExpirationDate = o.Expiration_Date__c;
                DispositionCode = o.Disposition_Code__c;
                Status = o.StageName;
                NextSteps = o.Next_Steps__c;
                OpportunityName = o.Name;
                OpptyOriginator = o.Originator__c;
                OwnerSfdcId = o.OwnerID;
                QuoteOu = o.Quote_Operating_Unit__c;
                QuoteType = o.Quote_Type__c ;
                QuoteVersion = o.Quote_Version__c ;
                QuoteNumber = o.Quote_Cart_Number__c ;
                SalesChannel = o.Sales_Channel__c ;
                SalesForceOrg = o.Sales_Force__c ;
                SellingRelationship = o.Sell_Relationship__c ;
                SfdcOpptyId = o.ID ;
                SalesOrderNumber = o.SO_Number__c ;
                SourceCode = o.LeadSource ;
                PartnerSfdcCustId = o.Partner__c ;
                VmwareCode = o.Vmware_Related__c ;
                ErrorMessage=o.Integration_Error_Message__c;
                //24 May 12  Shipra Misra     Project- 191098.Integration of Salesforce with RQF. 
                //New fields introduced as part of RQF.
                SWDiscount=o.SW_Discount_percent__c;
                HWDiscount=o.HW_Discount_percent__c;
                Discount=o.Discount_percent__c;
                QuoteStartDate=o.Quote_Start_Date__c;
                QuoteEndDate=o.Quote_End_Date__c;
                HWTLAStartDate=o.HW_TLA_Start_Date__c;
                QuoteCreatedBy=o.Quote_Created_by__c; 
                ContractNumber=o.Contract_Number__c;
                ContractNumberModifier=o.Contract_Modifier__c;
                BillToParty=o.Bill_To__c;
                //**RQF
                //Pricing fields**shipraa
                //Percentage fields
                HardwareDiscount=o.Hardware_Discount__c;
                SoftwareDiscount=o.Software_Discount__c;
                ServicesDiscount=o.Services_Discount__c;
                PrepaidHWMADiscount=o.Prepaid_HW_MA_Discount__c;
                HWWarrantyUpgradeDiscount=o.HW_Warranty_Upgrade_Discount__c;
                PrepaidSWMADiscount=o.Prepaid_SW_MA_Discount__c;
                //currency fields
                TotalQuoteAmount=o.Total_Quote_Amount__c;
                HWRevenue=o.HW_Revenue__c;
                SWRevenue=o.SW_Revenue__c;
                ServicesRevenue=o.Services_Revenue__c;
                PrepaidHWMARevenue=o.Prepaid_HW_MA_Revenue__c;
                PrepaidSWMARevenue=o.Prepaid_SW_MA_Revenue__c;
                HWWarrantyUpgradeRevenue=o.HW_Warranty_Upgrade_Revenue__c;
                //string field**  
                PriceFloor=o.Price_Floor__c;
     }
}