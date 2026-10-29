/*
*   File: KJ_Tool_TestDataFactory_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/28/2026
*   Description: This class covers KJ_Tool_TestDataFactory. Each factory builds its record in memory
*                with the expected defaults and the sector/parent arguments it was given.
*/
@isTest
public with sharing class KJ_Tool_TestDataFactory_Test {

    @isTest
    static void createTestLead_BySector_HappyPath(){
        Lead commercial  = KJ_Tool_TestDataFactory.createTestLead();
        Lead residential = KJ_Tool_TestDataFactory.createTestLead(KJ_Model_Picklist.Sector.RESIDENTIAL);

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_COMPANY_NAME, commercial.Company);
        Assert.areEqual('[Residential]', residential.Company);
        Assert.areEqual('Residential', residential.Sector__c);
    }

    @isTest
    static void createTestAccount_BySector_HappyPath(){
        Account commercial  = KJ_Tool_TestDataFactory.createTestAccount();
        Account residential = KJ_Tool_TestDataFactory.createTestAccount(KJ_Model_Picklist.Sector.RESIDENTIAL, null, null, null);

        Assert.areEqual('Commercial', commercial.Account_Sector__c);
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_ACCOUNT_STATUS, commercial.Account_Status__c);
        Assert.isNotNull(commercial.Industry);
        Assert.areEqual('Residential', residential.Account_Sector__c);
        Assert.isNull(residential.Industry);
    }

    @isTest
    static void createTestContact_BySector_HappyPath(){
        Contact commercial  = KJ_Tool_TestDataFactory.createTestContact();
        Contact residential = KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.RESIDENTIAL, null);

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_LAST_NAME, commercial.LastName);
        Assert.isNotNull(commercial.Title);
        Assert.isNull(residential.Title);
    }

    @isTest
    static void createTestProject_Defaults_HappyPath(){
        Project__c record = KJ_Tool_TestDataFactory.createTestProject();

        Assert.areEqual('Commercial', record.Sector__c);
        Assert.areEqual(System.today(), record.Scheduled_Start_Date__c);
    }

    @isTest
    static void createTestJob_Defaults_HappyPath(){
        Job__c record = KJ_Tool_TestDataFactory.createTestJob();

        Assert.areEqual('Commercial', record.Job_Sector__c);
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATETIME, record.Scheduled_Start__c);
    }

    @isTest
    static void createTestCustomerProperty_Defaults_HappyPath(){
        Customer_Property__c record = KJ_Tool_TestDataFactory.createTestCustomerProperty();

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET, record.Property_Address__Street__s);
        Assert.areEqual('Commercial', record.Property_Sector__c);
    }

    @isTest
    static void createTest_HVAC_Unit_Defaults_HappyPath(){
        HVAC_Unit__c record = KJ_Tool_TestDataFactory.createTest_HVAC_Unit();

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_ID_NUMBER, record.Condenser_Serial_Number__c);
        Assert.isNull(record.Membership__c);
    }

    @isTest
    static void createTestMembership_Defaults_HappyPath(){
        Membership__c record = KJ_Tool_TestDataFactory.createTestMembership();

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, record.Membership_Start_Date__c);
        Assert.isNull(record.Member_Account__c);
    }
}
