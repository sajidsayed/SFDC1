//Updated by: Shipra Misra On 22.03.11 for WR 158373.
//Updated for WR-163783.September Release. By Shipra Misra --Update Lead wrapper for new DB fields from Aprimo.
//Updated for WR-174616.November Release. By Shipra Misra --Update Lead wrapper for new Department Local fields from Aprimo.
//Updated for eBiz integration by Kaustav Debnath

global class LeadHeader{

Webservice  string  orig_sys_reference  {get; set;}
Webservice  string  owner_email {get; set;}
Webservice  string  sfdc_routing_queue {get; set;}
Webservice  string  party_id    {get; set;}
Webservice  string  unicode_flag_companyname {get; set;}
Webservice  string  unicode_flag_lastname{get; set;}
Webservice  string  unicode_flag_firstname {get; set;}
Webservice  string  unicode_flag_address {get; set;}
Webservice  string  company_orig    {get; set;}
Webservice  string  address1_orig   {get; set;}
Webservice  string  city_orig   {get; set;}
Webservice  string  state_orig  {get; set;}
Webservice  string  postalcode_orig {get; set;}
Webservice  string  country_orig    {get; set;}
Webservice  string  company_phone_orig  {get; set;}
Webservice  string  company_cleansed    {get; set;}
Webservice  string  address1_cleansed   {get; set;}
Webservice  string  address2_cleansed   {get; set;}
Webservice  string  address3_cleansed   {get; set;}
Webservice  string  address4_cleansed   {get; set;}
Webservice  string  city_cleansed   {get; set;}
Webservice  string  state_cleansed  {get; set;}
Webservice  string  postalcode_cleansed {get; set;}
Webservice  string  country_cleansed    {get; set;}
Webservice  string  company_phone_cleansed  {get; set;}
Webservice  string  global_url  {get; set;}
Webservice  string  global_url_domain  {get; set;}
Webservice  string  salutation   {get; set;}
Webservice  string  firstname   {get; set;}
Webservice  string  lastname    {get; set;}
Webservice  string  email   {get; set;}
Webservice  string  contact_phone   {get; set;}
Webservice  string  contact_mobile_phone   {get; set;}
Webservice  string  title   {get; set;}
Webservice  string  description {get; set;}
Webservice  string  sales_force {get; set;}
Webservice  string  business_unit   {get; set;}
Webservice  string  segment {get; set;}
Webservice  string  originator_details  {get; set;}
Webservice  string  original_synergy_status {get; set;}
Webservice  string  campaign_event_name {get; set;}
Webservice  string  channel {get; set;}
Webservice  date    contract_end_date   {get; set;}
Webservice  string  gmdb_activity_id    {get; set;}
Webservice  string  gmdb_customer_id    {get; set;}
Webservice  string  industry    {get; set;}
Webservice  string  lead_originator {get; set;}
Webservice  string  lead_rank   {get; set;}
Webservice  string  leadsource  {get; set;}
Webservice  string  audit_data  {get; set;}
Webservice  string  matchservice_standardization_status  {get; set;}
Webservice  string  matchservice_cleanse_status  {get; set;}
Webservice  string  matchservice_postal_status  {get; set;}
Webservice  string  objective   {get; set;}
Webservice  string  project {get; set;}
Webservice  string  asset_dialog_stage  {get; set;}
Webservice  string  asset_url   {get; set;}
Webservice  string  source_code {get; set;}
Webservice  string  alignment   {get; set;}
Webservice  string  marketing_campaign  {get; set;}
Webservice  string  marketing_sub_campaign  {get; set;}
Webservice  string  partner {get; set;}
Webservice  string  marketing_contact   {get; set;}
Webservice  string  field_marketing_region  {get; set;}
Webservice  string  field_marketing_sub_region  {get; set;}
Webservice  string  solution_interest   {get; set;}
Webservice  string  product_interest    {get; set;}
Webservice  Double  number_field01  {get; set;}
Webservice  Double  number_field02  {get; set;}
Webservice  Double  number_field03  {get; set;}
Webservice  Double  number_field04  {get; set;}
Webservice  Double  number_field05  {get; set;}
Webservice  Double  number_field06  {get; set;}
Webservice  Double  number_field07  {get; set;}
Webservice  Double  number_field08  {get; set;}
Webservice  Double  number_field09  {get; set;}
Webservice  Double  number_field10  {get; set;}
Webservice  date    date_field01    {get; set;}
Webservice  date    date_field02    {get; set;}
Webservice  date    date_field03    {get; set;}
Webservice  date    date_field04    {get; set;}
Webservice  date    date_field05    {get; set;}
Webservice  date    date_field06    {get; set;}
Webservice  date    date_field07    {get; set;}
Webservice  date    date_field08    {get; set;}
Webservice  date    date_field09    {get; set;}
Webservice  date    date_field10    {get; set;}
Webservice  string  text_field01    {get; set;}//This field will Mapp Aprimo AudMem ID on Lead.
Webservice  string  text_field02    {get; set;}//This field will Mapp Aprimo Lead ID on Lead.
Webservice  string  text_field03    {get; set;}//This field will Map Unicode Title flag on lead.
Webservice  string  text_field04    {get; set;}
Webservice  string  text_field05    {get; set;}//This field will Map Department Local on lead.
Webservice  string  text_field06    {get; set;}//This Field will Map Question on Marketing Q and A
Webservice  string  text_field07    {get; set;}//This Field will Map Answer on Marketing Q and A
Webservice  string  text_field08    {get; set;}//This field will map eBus_RFQ_ID_c on lead for eBiz Integration
Webservice  string  text_field09    {get; set;}//This field will map eBus_Items_Quote__c on lead for eBiz Integration 
Webservice  string  text_field10    {get; set;}//This field will map eBus_RFQRFI_URL__c on lead for eBiz Integration
Webservice  string  text_field11    {get; set;}//This field will map eBus_Requested_Partner__c on lead for eBiz Integration
Webservice  string  text_field12    {get; set;}//This field will map eBus_Partner_LeadAdmin__c on lead for eBiz Integration
Webservice  string  text_field13    {get; set;}//This field will map eBus_User_sessionTransaction__c on lead for eBiz Integration
Webservice  string  text_field14    {get; set;}//This field will map eBus_NGOE_HybrisUserID__c on lead for eBiz Integration
Webservice  string  text_field15    {get; set;}//This field will map eBus_Integration_Source_ref__c on lead for eBiz Integration
Webservice  string  text_field16    {get; set;}//This field will map eBus_SourceID on lead for eBiz Integration
Webservice  string  text_field17    {get; set;}//This field will map eBus_Requested_Partner_Write_In__c on lead for eBiz Integration
Webservice  string  text_field18    {get; set;}
Webservice  string  text_field19    {get; set;}
Webservice  string  text_field20    {get; set;}


}