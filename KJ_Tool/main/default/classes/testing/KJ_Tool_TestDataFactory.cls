/* 
*   File: KJ_Tool_TestDataFactory.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 2/10/2026
*   Description: This class is built to allow for easy production of test/sample data for Apex tests or other use

*/
public with sharing class KJ_Tool_TestDataFactory {
    // -- Constants -------------------------------------------------------------------------------
    // Pick list values
    public enum Sector {
        COMMERCIAL,
        RESIDENTIAL
    }
    private static Map<Sector, String> sectorPicklistValues = new Map<Sector, String>{
        Sector.RESIDENTIAL => 'Residential',
        Sector.COMMERCIAL  => 'Commercial'
    };

    // Names
    public static final String DEFAULT_COMPANY_NAME     = 'Test INC.';
    public static final String DEFAULT_FIRST_NAME       = 'DefaultFirstName';
    public static final String DEFAULT_LAST_NAME        = 'DefaultLastName';
    public static final String DEFAULT_REFERRED_BY_NAME = 'Referrer Name Sample';

    // Contact
    public static final String DEFAULT_PHONE            = '1234567890';
    public static final String DEFAULT_EMAIL            = 'Slate+Salesforce-TestFactoryEmail@kintyjones.com';
    public static final String DEFAULT_WEBSITE          = 'sample.com';

    // Address
    public static final String DEFAULT_BRANCH_TERRITORY = 'NWA';
    public static final String DEFAULT_STREET           = '123 Apple St';
    public static final String DEFAULT_CITY             = 'Bentonville';
    public static final String DEFAULT_STATE            = 'AR';
    public static final String DEFAULT_COUNTRY          = 'US';
    public static final String DEFAULT_POSTAL_CODE      = '12123';

    // Date & Time
    public static final Date DEFAULT_DATE               = Date.valueOf('2026-1-1');
    public static final Datetime DEFAULT_DATETIME       = Datetime.valueOf('2026-01-01 08:00:00');

    // Picklist Values
    public static final Sector DEFAULT_SECTOR           = Sector.COMMERCIAL;

    // Misc. Strings
    public static final String DEFAULT_NOTES            = 'Here is a generic note sample: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ultricies tincidunt arcu in tempor. Vivamus in volutpat magna. Vivamus non arcu rutrum, blandit est sit amet, placerat odio. Donec elementum at erat vitae pharetra. Nulla tristique ligula arcu, vitae posuere nibh lobortis nec. Curabitur at magna in turpis elementum commodo ut sit amet lectus. Fusce sit amet velit et tellus fringilla hendrerit sed eu erat. Phasellus ac elementum tellus. Nullam sit amet aliquam sem, lobortis scelerisque magna. Phasellus condimentum elementum eros, ut porta orci faucibus vel. Proin efficitur purus vel tristique ultrices. Mauris et volutpat lacus. Donec et egestas sapien. Phasellus porttitor nunc a vulputate porttitor. Aliquam tincidunt, ante id egestas pharetra, tellus lorem tincidunt ligula, et auctor nisl nisi vel turpis.';
    public static final String DEFAULT_ID_NUMBER        = 'A1B2C3D4';


    // -- Object Creation Methods ------------------------------------------------------------------
    // Leads 
    public static Lead createTestLead(Sector sectorArg){
        String newCompanyName;
        if(sectorArg == Sector.COMMERCIAL){
            newCompanyName = DEFAULT_COMPANY_NAME;
        } else {
            newCompanyName = '[Residential]';
        }
        Lead newLead = new Lead(
            Company                         = newCompanyName,
            FirstName                       = DEFAULT_FIRST_NAME, 
            LastName                        = DEFAULT_LAST_NAME, 
            Sector__c                       = sectorPicklistValues.Get(sectorArg),
            Service_Type__c                 = 'Repair',
            Lead_Notes__c                   = 'Test Lead Notes',

            Contact_Role__c                 = 'TestLead Contact Role sample here',
            Phone                           = DEFAULT_PHONE,
            Email                           = DEFAULT_EMAIL,
            Contact_Method_Preference__c    = 'Phone',

            Job_Project_Priority_Level__c   = 'Medium',
            Units_To_Service__c             = 1,
            Job_Project_Notes__c            = DEFAULT_NOTES,
            
            Branch_Territory__c             = DEFAULT_BRANCH_TERRITORY,
            Street                          = DEFAULT_STREET,
            City                            = DEFAULT_CITY,
            State                           = DEFAULT_STATE,
            PostalCode                      = DEFAULT_POSTAL_CODE,
            Country                         = DEFAULT_COUNTRY,

            Property_Square_Footage__c      = 1550,
            Units_On_Property__c            = 1,

            Lead_Source__c                  = 'Existing Customer'
        );

        return newLead;
    }
    public static Lead createTestLead(){
        return createTestLead(DEFAULT_SECTOR);
    }


    // Accounts
    public static Account createTestAccount(Sector sectorArg, Id parentIdArg, Id accountPrimaryContactIdArg, Id originatingLeadIdArg){
        String newIndustry, newWebsite; Integer newNumberOfEmployees;
        if(sectorArg == Sector.COMMERCIAL){
            newIndustry             = 'Sample of Industry';
            newWebsite              = 'SampleWebsite.com';
            newNumberOfEmployees    = 99;
        } else {
            newIndustry             = null;
            newWebsite              = null;
            newNumberOfEmployees    = null;
        }

        Account newAccount = new Account(
            Name                        = 'Test Account - ' + Math.round(Math.random() * 100000000),
            ParentId                    = parentIdArg,
            Account_Primary_Contact__c  = accountPrimaryContactIdArg,
            Account_Sector__c           = sectorPicklistValues.Get(sectorArg),
            Office_Notes__c             = DEFAULT_NOTES,
            Field_Notes__c              = DEFAULT_NOTES,

            Industry                    = newIndustry,
            Website                     = newWebsite,
            NumberOfEmployees           = newNumberOfEmployees,

            Branch_Territory__c         = DEFAULT_BRANCH_TERRITORY,
            BillingStreet               = DEFAULT_STREET,
            BillingCity                 = DEFAULT_CITY,
            BillingState                = DEFAULT_STATE,
            BillingPostalCode           = DEFAULT_POSTAL_CODE,
            BillingCountry              = DEFAULT_COUNTRY,

            Invoiced_Revenue__c         = 9.99,
            Originating_Lead__c         = originatingLeadIdArg,
            Customer_Since__c           = System.today(),
            Account_Lead_Source__c      = 'Existing Customer',
            Referred_By__c              = 'Referrer Name Sample'
        );

        return newAccount;
    }
    public static Account createTestAccount(){
        return createTestAccount(DEFAULT_SECTOR, null, null, null);
    }


    // Contacts
    public static Contact createTestContact(Sector sectorArg, Id accountIdArg){
        String newTitle, newDepartment;

        if(sectorArg == Sector.COMMERCIAL){
            newTitle        = 'Commercial Contact Title';
            newDepartment   = 'Sample Department';
        } else {
            newTitle        = null;
            newDepartment   = null;
        }


        Contact newContact = new Contact(
            FirstName                       = DEFAULT_FIRST_NAME,
            LastName                        = DEFAULT_LAST_NAME, 
            Role__c                         = 'TestContact Role',
            AccountId                       = accountIdArg,
            Contact_Sector__c               = sectorPicklistValues.Get(sectorArg),
            Contact_Notes__c                = DEFAULT_NOTES,

            Title                           = newTitle,
            Department                      = newDepartment,

            Contact_Method_Preference__c    = 'Email',
            Phone                           = DEFAULT_PHONE,
            Email                           = DEFAULT_EMAIL,

            MailingStreet                   = DEFAULT_STREET,
            MailingCity                     = DEFAULT_CITY,
            MailingState                    = DEFAULT_STATE,
            MailingCountry                  = DEFAULT_COUNTRY,
            MailingPostalCode               = DEFAULT_POSTAL_CODE
        );

        Return newContact;
    }
    public static Contact createTestContact(){
        return createTestContact(DEFAULT_SECTOR, null);
    }

    // Projects
    public static Project__c createTestProject(Sector sectorArg, Id parentAccountArg, Id primaryContactArg, Id orginatingLeadArg, Id customerPropertyArg){
        Project__c newProject = new Project__c(
            Project_Name__c             = 'TestProject Name',
            Project_Status__c           = 'New',
            Project_Priority_Level__c   = 'Medium',

            Parent_Account__c           = parentAccountArg,
            Primary_Contact__c          = primaryContactArg,

            Project_Notes__c            = DEFAULT_NOTES,
            Job_Notes__c                = DEFAULT_NOTES,

            Sector__c                   = sectorPicklistValues.get(sectorArg),
            Service_Type__c             = 'Repair',

            Originating_Lead__c         = orginatingLeadArg,

            Branch_Territory__c         = DEFAULT_BRANCH_TERRITORY,
            Units_To_Service__c         = 1,
            Customer_Property__c        = customerPropertyArg,

            Due_Date__c                 = System.today() + 1,
            Scheduled_Start_Date__c     = System.today(),
            Scheduled_End_Date__c       = System.today() +1
        );

        return newProject;
    }
    public static Project__c createTestProject(){
        return createTestProject(DEFAULT_SECTOR, null, null, null, null);
    }

    // Jobs
    public static Job__c createTestJob(Sector sectorArg, Id parentProjectArg, Id parentAccountArg, Id primaryContactArg, Id customerPropertyArg){
        Job__c newJob = new Job__c(
            Job_Status__c           = 'Needs Scheduling',
            Priority_Level__c       = 'Medium',
            Parent_Project__c       = parentProjectArg,
            Parent_Account__c       = parentAccountArg,
            Primary_Contact__c      = primaryContactArg,
            Office_Notes__c         = DEFAULT_NOTES,
            Field_Notes__c          = DEFAULT_NOTES,

            Job_Sector__c           = sectorPicklistValues.get(sectorArg),
            Service_Type__c         = 'Repair',

            Customer_Property__c    = customerPropertyArg,
            Branch_Territory__c     = DEFAULT_BRANCH_TERRITORY,

            Due_Date__c             = DEFAULT_DATETIME,
            Scheduled_Start__c      = DEFAULT_DATETIME,
            Scheduled_End__c        = DEFAULT_DATETIME,
            Actual_Start__c         = DEFAULT_DATETIME,
            Actual_End__c           = DEFAULT_DATETIME,
            Travel_Start__c         = DEFAULT_DATETIME,
            Travel_End__c           = DEFAULT_DATETIME
        );

        return newJob;
    }
    public static Job__c createTestJob(){
        return createTestJob(DEFAULT_SECTOR, null, null, null, null);
    }

    // Customer Properties
    public static Customer_Property__c createTestCustomerProperty(Sector sectorArg, Id PropertyOwnerAccountArg){
        Customer_Property__c newCustomerProperty = new Customer_Property__c(
            Name                                = 'Customer Property Sample Name',

            Property_Address__Street__s         = DEFAULT_STREET,
            Property_Address__City__s           = DEFAULT_CITY,
            Property_Address__StateCode__s      = DEFAULT_STATE,
            Property_Address__CountryCode__s    = DEFAULT_COUNTRY,
            Property_Address__PostalCode__s     = DEFAULT_POSTAL_CODE,

            Property_Owner_Account__c   = PropertyOwnerAccountArg,
            Property_Sector__c          = sectorPicklistValues.get(sectorArg),
            Property_Notes__c           = DEFAULT_NOTES,
            
            Square_Footage__c           = 1500
        );

        return newCustomerProperty;
    }
    public static Customer_Property__c createTestCustomerProperty(){
        return createTestCustomerProperty(DEFAULT_SECTOR, null);
    }

    // HVAC Units
    public static HVAC_Unit__c createTest_HVAC_Unit(Id membershipArg, Id customerPropertyArg){
        HVAC_Unit__c new_HVAC_Unit = new HVAC_Unit__c(
            Membership__c           = membershipArg,
            Customer_Property__c    = customerPropertyArg,
            Unit_Brand__c           = 'American Standard',
            Unit_Birthdate__c       = DEFAULT_DATE,
            Unit_Notes__c           = DEFAULT_NOTES,

            Unit_Type__c        = 'Split System',
            Fuel_Type__c        = 'Gas',
            SEER_Rating__c      = 15,
            AFUE_Rating__c      = 80,
            Tonnage_Rating__c   = 5,

            Condenser_Model_Number__c           = DEFAULT_ID_NUMBER,
            Condenser_Serial_Number__c          = DEFAULT_ID_NUMBER,
            Air_Handler_Model_Number__c         = DEFAULT_ID_NUMBER,
            Air_Handler_Serial_Number__c        = DEFAULT_ID_NUMBER,
            Furnace_Model_Number__c             = DEFAULT_ID_NUMBER,
            Furnace_Serial_Number__c            = DEFAULT_ID_NUMBER,
            Evaporator_Coil_Model_Number__c     = DEFAULT_ID_NUMBER,
            Evaporator_Coil_Serial_Number__c    = DEFAULT_ID_NUMBER,
            Package_Unit_Model_Number__c        = DEFAULT_ID_NUMBER,
            Package_Unit_Serial_Number__c       = DEFAULT_ID_NUMBER
        );
        
        return new_HVAC_Unit;
    }
    public static HVAC_Unit__c createTest_HVAC_Unit(){
        return createTest_HVAC_Unit(null, null);
    }

    // Memberships
    public static Membership__c createTestMembership(Id memberAccountArg){
        Membership__c newMembership = new Membership__c(
            Membership_Tier__c              = 'Basecamp',
            Member_Account__c               = memberAccountArg,
            Membership_Notes__c             = DEFAULT_NOTES, 

            Membership_Start_Date__c        = DEFAULT_DATE,
            Membership_Expiration_Date__c   = DEFAULT_DATE
        );

        return newMembership;
    }
    public static Membership__c createTestMembership(){
        return createTestMembership(null);
    }
}