<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Update</fullName>
        <field>External_ID__c</field>
        <formula>Account_ID__r.Id</formula>
        <name>External ID Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unique_ID_Update</fullName>
        <field>Unique_ID__c</field>
        <formula>Account_ID__r.Id</formula>
        <name>Unique ID Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>salesPRISM_Details_Unique_Rule</fullName>
        <actions>
            <name>Unique_ID_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Account_ID__r.Id &lt;&gt; null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
