/*
*   File: KJ_Model_Contact_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests KJ_Model_Contact: building models from records (including the parent
*                Account name), the bulk factories, the field list, setters, and converting back to a
*                record that saves.
*
*   Index:
*       Helpers
*       Factories                   build(), buildAll(), buildAllById()
*       Conversion                  toRecord() null skipping, full setter round trip through the database
*/
@isTest
public with sharing class KJ_Model_Contact_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    // SOQL for every field the model reads, parent paths included.
    private static Contact queryModelFields(Id recordId){
        List<String> fieldNames = new List<String>();
        for(SObjectField field : KJ_Model_Contact.getFields()){
            fieldNames.add(String.valueOf(field));
        }
        fieldNames.addAll(KJ_Model_Contact.PARENT_FIELD_PATHS);
        return Database.query('SELECT ' + String.join(fieldNames, ', ') + ' FROM Contact WHERE Id = :recordId');
    }


    //*-- Factories -------------------------------------------------------------------------------
    // A record queried with getFields() and the parent paths maps onto the model, picklists becoming
    // enums and Account.Name becoming accountName; build() with no record returns the defaults.
    @isTest
    static void build_FromRecordAndDefaults_HappyPath(){
        Account parent = KJ_Tool_TestDataFactory.createTestAccount();
        insert parent;
        Contact record = KJ_Tool_TestDataFactory.createTestContact(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, parent.Id);
        insert record;

        Test.startTest();
        KJ_Model_Contact model    = KJ_Model_Contact.build(queryModelFields(record.Id));
        KJ_Model_Contact noParent = KJ_Model_Contact.build(new Contact(LastName = 'No Parent Queried'));
        KJ_Model_Contact defaults = KJ_Model_Contact.build();
        Test.stopTest();

        Assert.areEqual(record.Id,  model.recordId,  'Id should map to recordId');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_LAST_NAME, model.lastName, 'LastName should map to lastName');
        Assert.areEqual(parent.Id,  model.accountId, 'AccountId should map to accountId');
        Assert.areEqual(parent.Name, model.accountName, 'Account.Name should map to accountName');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, model.sector, 'Contact Sector should map to the Sector enum');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.EMAIL, model.contactMethodPreference, 'Contact Method Preference should map to the ContactMethod enum');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET, model.mailingStreet, 'MailingStreet should map to mailingStreet');
        Assert.isFalse(model.doNotCall, 'DoNotCall should map to doNotCall');
        Assert.isNotNull(model.ownerId, 'OwnerId should map to ownerId');
        Assert.isNotNull(model.createdById, 'CreatedById should map to createdById');

        Assert.isNull(noParent.accountName, 'A record queried without the parent Account should leave accountName blank');

        Assert.isNull(defaults.recordId, 'A default model should have no recordId');
        Assert.areEqual(KJ_Model_Picklist.Sector.UNKNOWN, defaults.sector, 'A default model should have an UNKNOWN sector');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.UNKNOWN, defaults.contactMethodPreference, 'A default model should have an UNKNOWN contact method');
        Assert.isFalse(defaults.hasOptedOutOfEmail, 'A default model should not be opted out of email');
    }

    // buildAll() keeps every record; buildAllById() drops records with no Id. Both return empty for null.
    @isTest
    static void buildAll_AndById_HappyPath(){
        Contact saved   = KJ_Tool_TestDataFactory.createTestContact();
        insert saved;
        Contact unsaved = KJ_Tool_TestDataFactory.createTestContact();
        List<Contact> records = new List<Contact>{ saved, unsaved };

        Test.startTest();
        List<KJ_Model_Contact> all        = KJ_Model_Contact.buildAll(records);
        Map<Id, KJ_Model_Contact> byId    = KJ_Model_Contact.buildAllById(records);
        List<KJ_Model_Contact> nullAll    = KJ_Model_Contact.buildAll(null);
        Map<Id, KJ_Model_Contact> nullMap = KJ_Model_Contact.buildAllById(null);
        Test.stopTest();

        Assert.areEqual(2, all.size(), 'buildAll should model every record');
        Assert.areEqual(1, byId.size(), 'buildAllById should skip records with no Id');
        Assert.areEqual(saved.LastName, byId.get(saved.Id).lastName, 'buildAllById should key each model by its record Id');
        Assert.isTrue(nullAll.isEmpty(), 'buildAll(null) should return an empty list');
        Assert.isTrue(nullMap.isEmpty(), 'buildAllById(null) should return an empty map');
    }


    //*-- Conversion ------------------------------------------------------------------------------
    // toRecord() only writes values that are set, so a partial model can't blank out real data on update.
    @isTest
    static void toRecord_SkipsUnsetValues_HappyPath(){
        Contact saved = KJ_Tool_TestDataFactory.createTestContact();
        insert saved;

        Test.startTest();
        Contact record   = KJ_Model_Contact.build().toRecord();
        Contact idRecord = KJ_Model_Contact.build().setRecordId(saved.Id).toRecord();
        Test.stopTest();

        Map<String, Object> populated = record.getPopulatedFieldsAsMap();
        Assert.areEqual(2, populated.size(), 'A default model should only write its two non-null defaults');
        Assert.areEqual(false, populated.get('DoNotCall'), 'DoNotCall should default to false');
        Assert.areEqual(false, populated.get('HasOptedOutOfEmail'), 'HasOptedOutOfEmail should default to false');
        Assert.areEqual(saved.Id, idRecord.Id, 'setRecordId should carry through to the record Id');
        Assert.areEqual(3, idRecord.getPopulatedFieldsAsMap().size(), 'A model with only an Id should write just the Id and the two flags');
    }

    // Every setter feeds toRecord(); the record saves, and reading it back gives the same values.
    // Setters also ignore null, keeping the value they already had.
    @isTest
    static void setters_RoundTripThroughDatabase_HappyPath(){
        Account parent = KJ_Tool_TestDataFactory.createTestAccount();
        insert parent;

        KJ_Model_Contact model = KJ_Model_Contact.build()
            .setFirstName('Round')
            .setLastName('Trip')
            .setAccountId(parent.Id)
            .setAccountName(parent.Name)
            .setRole('Homeowner')
            .setSector(KJ_Model_Picklist.Sector.RESIDENTIAL)
            .setNotes('Contact notes')
            .setDepartment('Facilities')
            .setContactMethodPreference(KJ_Model_Picklist.ContactMethod.PHONE)
            .setDoNotCall(true)
            .setHasOptedOutOfEmail(true)
            .setPhone(KJ_Tool_TestDataFactory.DEFAULT_PHONE)
            .setSecondPhone('4795550101')
            .setEmail(KJ_Tool_TestDataFactory.DEFAULT_EMAIL)
            .setSecondEmail('second@example.com')
            .setMailingStreet(KJ_Tool_TestDataFactory.DEFAULT_STREET)
            .setMailingCity(KJ_Tool_TestDataFactory.DEFAULT_CITY)
            .setMailingState(KJ_Tool_TestDataFactory.DEFAULT_STATE)
            .setMailingPostalCode(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE)
            .setMailingCountry(KJ_Tool_TestDataFactory.DEFAULT_COUNTRY)
            .setOwnerId(UserInfo.getUserId())
            .setRecordOrigin(KJ_Model_Picklist.RecordOrigin.FIELDPULSE)
            .setOriginRecordId('FP-C-1001')
            .setOriginCreatedDate(KJ_Tool_TestDataFactory.DEFAULT_DATE);

        // Null is ignored by every setter, so these leave the values above in place
        model.setLastName(null).setSector(null).setDoNotCall(null);

        Test.startTest();
        Contact record = model.toRecord();
        insert record;
        Test.stopTest();

        KJ_Model_Contact found = KJ_Model_Contact.build(queryModelFields(record.Id));

        Assert.areEqual('Round',               found.firstName,         'First name should round trip');
        Assert.areEqual('Trip',                found.lastName,          'A null setLastName should keep the earlier last name');
        Assert.areEqual(parent.Id,             found.accountId,         'Account should round trip');
        Assert.areEqual(parent.Name,           found.accountName,       'Account name should read back from the parent');
        Assert.areEqual(parent.Name,           model.accountName,       'setAccountName should set accountName on the model');
        Assert.areEqual('Homeowner',           found.role,              'Role should round trip');
        Assert.areEqual(KJ_Model_Picklist.Sector.RESIDENTIAL, found.sector, 'A null setSector should keep the earlier sector');
        Assert.areEqual('Contact notes',       found.notes,             'Notes should round trip');
        Assert.areEqual('Facilities',          found.department,        'Department should round trip');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.PHONE, found.contactMethodPreference, 'Contact method preference should round trip');
        Assert.isTrue(found.doNotCall,                                  'A null setDoNotCall should keep the earlier value');
        Assert.isTrue(found.hasOptedOutOfEmail,                         'Email opt-out should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_PHONE, found.phone, 'Phone should round trip');
        Assert.areEqual('4795550101',          found.secondPhone,       'Second phone should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_EMAIL.toLowerCase(), found.email.toLowerCase(), 'Email should round trip');
        Assert.areEqual('second@example.com',  found.secondEmail,       'Second email should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET, found.mailingStreet, 'Mailing street should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_CITY,   found.mailingCity,   'Mailing city should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE, found.mailingPostalCode, 'Mailing postal code should round trip');
        Assert.isNotNull(found.mailingState,                            'Mailing state should round trip');
        Assert.isNotNull(found.mailingCountry,                          'Mailing country should round trip');
        Assert.areEqual(UserInfo.getUserId(),  found.ownerId,           'Owner should round trip');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.FIELDPULSE, found.recordOrigin, 'Record origin should round trip');
        Assert.areEqual('FP-C-1001',           found.originRecordId,    'Origin record Id should round trip');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.originCreatedDate, 'Origin created date should round trip');
    }
}
