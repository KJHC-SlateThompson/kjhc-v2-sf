/*
*   File: KJ_Model_Account_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests KJ_Model_Account: building models from records, the bulk factories,
*                the field list, setters, and converting back to a record that saves.
*
*   Index:
*       Factories                   build(), buildAll(), buildAllById()
*       Conversion                  toRecord() null skipping, full setter round trip through the database
*/
@isTest
public with sharing class KJ_Model_Account_Test {

    //*-- Factories -------------------------------------------------------------------------------
    // A record queried with getFields() maps onto the model, picklists becoming enums; build() with
    // no record returns the defaults.
    @isTest
    static void build_FromRecordAndDefaults_HappyPath(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        record.Account_Status__c = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER);
        insert record;

        List<String> fieldNames = new List<String>();
        for(SObjectField field : KJ_Model_Account.getFields()){
            fieldNames.add(String.valueOf(field));
        }
        Id recordId = record.Id;
        Account queried = Database.query('SELECT ' + String.join(fieldNames, ', ') + ' FROM Account WHERE Id = :recordId');

        Test.startTest();
        KJ_Model_Account model    = KJ_Model_Account.build(queried);
        KJ_Model_Account defaults = KJ_Model_Account.build();
        Test.stopTest();

        Assert.areEqual(record.Id,   model.recordId, 'Id should map to recordId');
        Assert.areEqual(record.Name, model.name,     'Name should map to name');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER, model.status, 'Account Status should map to the AccountStatus enum');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, model.sector, 'Account Sector should map to the Sector enum');
        Assert.areEqual(KJ_Model_Picklist.Territory.NWA, model.branchTerritory, 'Branch Territory should map to the Territory enum');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET, model.billingStreet, 'Billing Street should map to billingStreet');
        Assert.areEqual(System.today(), model.customerSince, 'Customer Since should map to customerSince');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.UNKNOWN, model.recordOrigin, 'An unrecognized Record Origin should map to UNKNOWN');
        Assert.isFalse(model.archived, 'Archived should map to archived');
        Assert.isNotNull(model.ownerId, 'OwnerId should map to ownerId');
        Assert.isNotNull(model.createdById, 'CreatedById should map to createdById');

        Assert.isNull(defaults.recordId, 'A default model should have no recordId');
        Assert.isNull(defaults.name, 'A default model should have no name');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.UNKNOWN, defaults.status, 'A default model should have an UNKNOWN status');
        Assert.isFalse(defaults.archived, 'A default model should not be archived');
    }

    // buildAll() keeps every record; buildAllById() drops records with no Id. Both return empty for null.
    @isTest
    static void buildAll_AndById_HappyPath(){
        Account saved   = KJ_Tool_TestDataFactory.createTestAccount();
        insert saved;
        Account unsaved = KJ_Tool_TestDataFactory.createTestAccount();
        List<Account> records = new List<Account>{ saved, unsaved };

        Test.startTest();
        List<KJ_Model_Account> all        = KJ_Model_Account.buildAll(records);
        Map<Id, KJ_Model_Account> byId    = KJ_Model_Account.buildAllById(records);
        List<KJ_Model_Account> nullAll    = KJ_Model_Account.buildAll(null);
        Map<Id, KJ_Model_Account> nullMap = KJ_Model_Account.buildAllById(null);
        Test.stopTest();

        Assert.areEqual(2, all.size(), 'buildAll should model every record');
        Assert.areEqual(1, byId.size(), 'buildAllById should skip records with no Id');
        Assert.areEqual(saved.Name, byId.get(saved.Id).name, 'buildAllById should key each model by its record Id');
        Assert.isTrue(nullAll.isEmpty(), 'buildAll(null) should return an empty list');
        Assert.isTrue(nullMap.isEmpty(), 'buildAllById(null) should return an empty map');
    }


    //*-- Conversion ------------------------------------------------------------------------------
    // toRecord() only writes values that are set, so a partial model can't blank out real data on update.
    @isTest
    static void toRecord_SkipsUnsetValues_HappyPath(){
        Account saved = KJ_Tool_TestDataFactory.createTestAccount();
        insert saved;

        Test.startTest();
        Account record   = KJ_Model_Account.build().toRecord();
        Account idRecord = KJ_Model_Account.build().setRecordId(saved.Id).toRecord();
        Test.stopTest();

        Map<String, Object> populated = record.getPopulatedFieldsAsMap();
        Assert.areEqual(1, populated.size(), 'A default model should only write its one non-null default');
        Assert.areEqual(false, populated.get('Archived__c'), 'The one default written should be Archived = false');
        Assert.areEqual(saved.Id, idRecord.Id, 'setRecordId should carry through to the record Id');
        Assert.areEqual(2, idRecord.getPopulatedFieldsAsMap().size(), 'A model with only an Id should write just the Id and Archived');
    }

    // Every setter feeds toRecord(); the record saves, and reading it back gives the same values.
    // Setters also ignore null, keeping the value they already had.
    @isTest
    static void setters_RoundTripThroughDatabase_HappyPath(){
        Account parent = KJ_Tool_TestDataFactory.createTestAccount();
        insert parent;
        Contact primary = KJ_Tool_TestDataFactory.createTestContact(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, parent.Id);
        insert primary;

        KJ_Model_Account model = KJ_Model_Account.build()
            .setParentId(parent.Id)
            .setName('Round Trip Account')
            .setStatus(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER)
            .setSector(KJ_Model_Picklist.Sector.RESIDENTIAL)
            .setBranchTerritory(KJ_Model_Picklist.Territory.NWA)
            .setOfficeNotes('Office notes')
            .setFieldNotes('Field notes')
            .setPhone(KJ_Tool_TestDataFactory.DEFAULT_PHONE)
            .setPrimaryContactId(primary.Id)
            .setBillingStreet(KJ_Tool_TestDataFactory.DEFAULT_STREET)
            .setBillingCity(KJ_Tool_TestDataFactory.DEFAULT_CITY)
            .setBillingState(KJ_Tool_TestDataFactory.DEFAULT_STATE)
            .setBillingPostalCode(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE)
            .setInvoicedRevenue(1250.50)
            .setCustomerSince(KJ_Tool_TestDataFactory.DEFAULT_DATE)
            .setLastServiceDate(KJ_Tool_TestDataFactory.DEFAULT_DATE)
            .setLeadSource('Existing Customer')
            .setReferredBy(KJ_Tool_TestDataFactory.DEFAULT_REFERRED_BY_NAME)
            .setReferredByEmail(KJ_Tool_TestDataFactory.DEFAULT_EMAIL)
            .setReferredByPhone(4795550100L)
            .setGclid('gclid-value')
            .setUtmSource('google')
            .setUtmMedium('cpc')
            .setUtmCampaign('fall-tuneup')
            .setUtmTerm('hvac repair')
            .setUtmContent('ad-a')
            .setArchived(true)
            .setRecordOrigin(KJ_Model_Picklist.RecordOrigin.FIELDPULSE)
            .setOriginRecordId('FP-1001')
            .setOriginCreatedDate(KJ_Tool_TestDataFactory.DEFAULT_DATE)
            .setFieldPulseAccountId('FP-ACCT-1001')
            .setQboAccountId('QBO-1001');

        // Null is ignored by every setter, so these leave the values above in place
        model.setName(null).setStatus(null).setArchived(null);

        Test.startTest();
        Account record = model.toRecord();
        insert record;
        Test.stopTest();

        List<String> fieldNames = new List<String>();
        for(SObjectField field : KJ_Model_Account.getFields()){
            fieldNames.add(String.valueOf(field));
        }
        Id recordId = record.Id;
        KJ_Model_Account found = KJ_Model_Account.build(
            Database.query('SELECT ' + String.join(fieldNames, ', ') + ' FROM Account WHERE Id = :recordId')
        );

        Assert.areEqual(parent.Id,             found.parentId,          'Parent should round trip');
        Assert.areEqual('Round Trip Account',  found.name,              'A null setName should keep the earlier name');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER, found.status, 'A null setStatus should keep the earlier status');
        Assert.areEqual(KJ_Model_Picklist.Sector.RESIDENTIAL, found.sector, 'Sector should round trip');
        Assert.areEqual(KJ_Model_Picklist.Territory.NWA, found.branchTerritory, 'Territory should round trip');
        Assert.areEqual('Office notes',        found.officeNotes,       'Office notes should round trip');
        Assert.areEqual('Field notes',         found.fieldNotes,        'Field notes should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_PHONE, found.phone, 'Phone should round trip');
        Assert.areEqual(primary.Id,            found.primaryContactId,  'Primary contact should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET, found.billingStreet, 'Billing street should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_CITY,   found.billingCity,   'Billing city should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE, found.billingPostalCode, 'Billing postal code should round trip');
        Assert.areEqual(1250.50,               found.invoicedRevenue,   'Invoiced revenue should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.customerSince,   'A provided Customer Since should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.lastServiceDate, 'Last service date should round trip');
        Assert.areEqual('Existing Customer',   found.leadSource,        'Lead source should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_REFERRED_BY_NAME, found.referredBy, 'Referred by should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_EMAIL.toLowerCase(), found.referredByEmail.toLowerCase(), 'Referred by email should round trip');
        Assert.areEqual(4795550100L,           found.referredByPhone,   'Referred by phone should round trip');
        Assert.areEqual('gclid-value',         found.gclid,             'GCLID should round trip');
        Assert.areEqual('google',              found.utmSource,         'UTM source should round trip');
        Assert.areEqual('cpc',                 found.utmMedium,         'UTM medium should round trip');
        Assert.areEqual('fall-tuneup',         found.utmCampaign,       'UTM campaign should round trip');
        Assert.areEqual('hvac repair',         found.utmTerm,           'UTM term should round trip');
        Assert.areEqual('ad-a',                found.utmContent,        'UTM content should round trip');
        Assert.isTrue(found.archived,                                   'A null setArchived should keep the earlier value');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.FIELDPULSE, found.recordOrigin, 'Record origin should round trip');
        Assert.areEqual('FP-1001',             found.originRecordId,    'Origin record Id should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.originCreatedDate, 'Origin created date should round trip');
        Assert.areEqual('FP-ACCT-1001',        found.fieldPulseAccountId, 'FieldPulse Id should round trip');
        Assert.areEqual('QBO-1001',            found.qboAccountId,      'QBO Id should round trip');
    }
}
