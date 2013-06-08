@isTest
Private Class OpportunityHeader_TC{
    Private static testMethod void startTest(){
        Date newDate =date.newinstance(1960, 2, 17);
        Opportunity Opp=[Select id from Opportunity limit 1];
        OpportunityHeader Opphead=new OpportunityHeader(Opp.id);
        Opphead.getOwnerSfdcId();
        Opphead.getOracleOppId();
        Opphead.getCloseComments();
        Opphead.getDecisionDate();
        Opphead.getClosedReason();
        Opphead.getCurrencyCode();
        Opphead.getSfdcCustomerId();
        Opphead.getDealRegApprovalDate();
        Opphead.getDealRegExpirationDate();
        Opphead.getDispositionCode();
        Opphead.getStatus();
        Opphead.getNextSteps();
        Opphead.getOpportunityName();
        Opphead.getOpptyOriginator();
        Opphead.getQuoteOu();
        Opphead.getQuoteType();
        Opphead.getQuoteVersion();
        Opphead.getQuoteNumber();
        Opphead.getSalesChannel();
        Opphead.getSalesForceOrg();
        Opphead.getSellingRelationship();
        Opphead.getSfdcOpptyId();
        Opphead.getSalesOrderNumber();
        Opphead.getSourceCode();
        Opphead.getPartnerSfdcCustId();
        Opphead.getVmwareCode();
        //RQF get
        Opphead.getSWDiscount();
        Opphead.getHWDiscount();
        Opphead.getDiscount();
        Opphead.getQuoteStartDate();
        Opphead.getQuoteEndDate();
        Opphead.getContractNumber();
        Opphead.getContractNumberModifier();
        Opphead.getBillToParty();
        Opphead.getAdditionalField01();
        Opphead.getAdditionalField02();
        Opphead.getAdditionalField03();
        Opphead.getAdditionalField04();
        Opphead.getAdditionalField05();
        Opphead.getAdditionalField06();
        Opphead.getAdditionalField07();
        Opphead.getAdditionalField08();
        Opphead.getAdditionalField09();
        Opphead.getAdditionalField10();
        opphead.getErrorMessage();
        //RQF
        //Feb Release
        Opphead.getHardwareDiscount();
        Opphead.getSoftwareDiscount();
        Opphead.getServicesDiscount();
        Opphead.getPrepaidHWMADiscount();
        Opphead.getHWWarrantyUpgradeDiscount();
        Opphead.getPrepaidSWMADiscount();
        Opphead.getTotalQuoteAmount();
        Opphead.getHWRevenue();
        Opphead.getSWRevenue();
        Opphead.getServicesRevenue();
        Opphead.getPrepaidHWMARevenue();
        Opphead.getPrepaidSWMARevenue();
        Opphead.getHWWarrantyUpgradeRevenue();
        opphead.getPriceFloor();
        //End of Feb Release
        
        
        Opphead.setOracleOppId('1234');
        Opphead.setCloseComments('Comments');
        Opphead.setDecisionDate(newDate);
        Opphead.setClosedReason('Reason');
        Opphead.setCurrencyCode('USD');
        Opphead.setSfdcCustomerId('CustId123');
        Opphead.setDealRegApprovalDate(newDate);
        Opphead.setDealRegExpirationDate(newDate);
        Opphead.setDispositionCode('Disposition');
        Opphead.setStatus('Pipeline');
        Opphead.setNextSteps('Close');
        Opphead.setOpportunityName('Opp234');
        Opphead.setOpptyOriginator('Origin');
        Opphead.setOwnerSfdcId('OwnerId12');
        Opphead.setQuoteOu('Quote');
        Opphead.setQuoteType('QuoteType');
        Opphead.setQuoteVersion('QuoteVer');
        Opphead.setQuoteNumber('QuoteNum');
        Opphead.setSalesChannel('EMC');
        Opphead.setSalesForceOrg('SalesforceOrg');
        Opphead.setSellingRelationship('EMC_Int');
        Opphead.setSfdcOpptyId('SfdcOpp123');
        Opphead.setSalesOrderNumber('Sales123');
        Opphead.setSourceCode('Sourcecode');
        Opphead.setPartnerSfdcCustId('Partner123');
        Opphead.setVmwareCode('VMWare');    
        Opphead.setErrorMessage('Test');
        Opphead.setSWDiscount();
 Opphead.setHWDiscount();
 Opphead.setDiscount();
 Opphead.setQuoteStartDate();
Opphead.setQuoteEndDate();
 Opphead.setHWTLAStartDate();
 Opphead.setContractNumber();
 Opphead.setContractNumberModifier();
 Opphead.setBillToParty();
 Opphead.setAdditionalField01();
 Opphead.setAdditionalField02();
 Opphead.setAdditionalField03();
 Opphead.setAdditionalField04();
 Opphead.setAdditionalField05();
 Opphead.setAdditionalField06();
 Opphead.setAdditionalField07();
 Opphead.setAdditionalField08();
 Opphead.setAdditionalField09();
 Opphead.setAdditionalField10();
 Opphead.getHWTLAStartDate();
 Opphead.getQuoteCreatedBy();    
 Opphead.setQuoteCreatedBy();
 
        
        //Feb Release
        Opphead.setHardwareDiscount();
        Opphead.setSoftwareDiscount();
        Opphead.setServicesDiscount();
        Opphead.setPrepaidHWMADiscount();
        Opphead.setHWWarrantyUpgradeDiscount();
        Opphead.setPrepaidSWMADiscount();
        Opphead.setTotalQuoteAmount();
        Opphead.setHWRevenue();
        Opphead.setSWRevenue();
        Opphead.setServicesRevenue();
        Opphead.setPrepaidHWMARevenue();
        Opphead.setPrepaidSWMARevenue();
        Opphead.setHWWarrantyUpgradeRevenue();
        Opphead.setPriceFloor();
          //End of Feb Release
    }
}