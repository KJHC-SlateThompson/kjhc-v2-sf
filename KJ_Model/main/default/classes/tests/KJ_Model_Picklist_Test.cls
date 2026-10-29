/*
*   File: KJ_Model_Picklist_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests KJ_Model_Picklist: every enum value survives a round trip through its
*                string, input is matched case-insensitively with blanks and unknowns falling to UNKNOWN,
*                and every string the enums write is a value the org's picklist actually accepts.
*
*   Index:
*       Helpers
*       Mapping                     round trip, input edge cases
*       Org Picklists               enum strings exist in the org picklists
*/
@isTest
public with sharing class KJ_Model_Picklist_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static Set<String> activeValues(SObjectField field){
        Set<String> values = new Set<String>();
        for(Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()){
            if(entry.isActive()){ values.add(entry.getValue()); }
        }
        return values;
    }


    //*-- Mapping ---------------------------------------------------------------------------------
    // Every known value maps to its string and back to itself; UNKNOWN maps to no string at all.
    @isTest
    static void mapTo_RoundTripsEveryValue_HappyPath(){
        for(KJ_Model_Picklist.Sector value : KJ_Model_Picklist.Sector.values()){
            if(value == KJ_Model_Picklist.Sector.UNKNOWN){
                Assert.isNull(KJ_Model_Picklist.mapToString(value), 'Sector.UNKNOWN should map to no string');
                continue;
            }
            Assert.areEqual(value, KJ_Model_Picklist.mapToSector(KJ_Model_Picklist.mapToString(value)), 'Sector.' + value + ' should round trip');
        }
        for(KJ_Model_Picklist.Territory value : KJ_Model_Picklist.Territory.values()){
            if(value == KJ_Model_Picklist.Territory.UNKNOWN){
                Assert.isNull(KJ_Model_Picklist.mapToString(value), 'Territory.UNKNOWN should map to no string');
                continue;
            }
            Assert.areEqual(value, KJ_Model_Picklist.mapToTerritory(KJ_Model_Picklist.mapToString(value)), 'Territory.' + value + ' should round trip');
        }
        for(KJ_Model_Picklist.RecordOrigin value : KJ_Model_Picklist.RecordOrigin.values()){
            if(value == KJ_Model_Picklist.RecordOrigin.UNKNOWN){
                Assert.isNull(KJ_Model_Picklist.mapToString(value), 'RecordOrigin.UNKNOWN should map to no string');
                continue;
            }
            Assert.areEqual(value, KJ_Model_Picklist.mapToRecordOrigin(KJ_Model_Picklist.mapToString(value)), 'RecordOrigin.' + value + ' should round trip');
        }
        for(KJ_Model_Picklist.AccountStatus value : KJ_Model_Picklist.AccountStatus.values()){
            if(value == KJ_Model_Picklist.AccountStatus.UNKNOWN){
                Assert.isNull(KJ_Model_Picklist.mapToString(value), 'AccountStatus.UNKNOWN should map to no string');
                continue;
            }
            Assert.areEqual(value, KJ_Model_Picklist.mapToAccountStatus(KJ_Model_Picklist.mapToString(value)), 'AccountStatus.' + value + ' should round trip');
        }
        for(KJ_Model_Picklist.ContactMethod value : KJ_Model_Picklist.ContactMethod.values()){
            if(value == KJ_Model_Picklist.ContactMethod.UNKNOWN){
                Assert.isNull(KJ_Model_Picklist.mapToString(value), 'ContactMethod.UNKNOWN should map to no string');
                continue;
            }
            Assert.areEqual(value, KJ_Model_Picklist.mapToContactMethod(KJ_Model_Picklist.mapToString(value)), 'ContactMethod.' + value + ' should round trip');
        }
    }

    // Matching ignores case; null, blank and unrecognized input all land on UNKNOWN.
    @isTest
    static void mapTo_CaseBlankAndUnknownInput_EdgePath(){
        Assert.areEqual(KJ_Model_Picklist.Sector.RESIDENTIAL,             KJ_Model_Picklist.mapToSector('residential'),               'Sector matching should ignore case');
        Assert.areEqual(KJ_Model_Picklist.Territory.TULSA,                KJ_Model_Picklist.mapToTerritory('tulsa'),                  'Territory matching should ignore case');
        Assert.areEqual(KJ_Model_Picklist.Territory.NWA,                  KJ_Model_Picklist.mapToTerritory('River Valley'),           'Legacy River Valley values should map to NWA');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.GRAVITY_FORMS,     KJ_Model_Picklist.mapToRecordOrigin('GRAVITY forms'),       'Record origin matching should ignore case');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER, KJ_Model_Picklist.mapToAccountStatus('current customer'),   'Account status matching should ignore case');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.EMAIL,            KJ_Model_Picklist.mapToContactMethod('eMaIl'),              'Contact method matching should ignore case');

        Assert.areEqual(KJ_Model_Picklist.Sector.UNKNOWN,        KJ_Model_Picklist.mapToSector(null),            'A null sector should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.Territory.UNKNOWN,     KJ_Model_Picklist.mapToTerritory('  '),         'A blank territory should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.UNKNOWN,  KJ_Model_Picklist.mapToRecordOrigin(''),        'An empty record origin should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.UNKNOWN, KJ_Model_Picklist.mapToAccountStatus(null),     'A null account status should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.UNKNOWN, KJ_Model_Picklist.mapToContactMethod(null),     'A null contact method should be UNKNOWN');

        Assert.areEqual(KJ_Model_Picklist.Sector.UNKNOWN,        KJ_Model_Picklist.mapToSector('Industrial'),             'An unrecognized sector should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.Territory.UNKNOWN,     KJ_Model_Picklist.mapToTerritory('Dallas'),              'An unrecognized territory should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.RecordOrigin.UNKNOWN,  KJ_Model_Picklist.mapToRecordOrigin('KJHC Salesforce V2'), 'An unrecognized record origin should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.AccountStatus.UNKNOWN, KJ_Model_Picklist.mapToAccountStatus('Prospect'),        'An unrecognized account status should be UNKNOWN');
        Assert.areEqual(KJ_Model_Picklist.ContactMethod.UNKNOWN, KJ_Model_Picklist.mapToContactMethod('Text'),            'An unrecognized contact method should be UNKNOWN');
    }


    //*-- Org Picklists ---------------------------------------------------------------------------
    // Every string an enum writes back to a record must be an active value in the org's picklist,
    // or toRecord() would produce a record that fails to save.
    @isTest
    static void mapToString_ValuesExistInOrgPicklists_HappyPath(){
        Set<String> sectors     = activeValues(Account.Account_Sector__c);
        Set<String> territories = activeValues(Account.Branch_Territory__c);
        Set<String> statuses    = activeValues(Account.Account_Status__c);
        Set<String> methods     = activeValues(Contact.Contact_Method_Preference__c);

        for(KJ_Model_Picklist.Sector value : KJ_Model_Picklist.Sector.values()){
            String label = KJ_Model_Picklist.mapToString(value);
            if(label != null){ Assert.isTrue(sectors.contains(label), 'Sector.' + value + ' writes "' + label + '", which is not an active Sector picklist value'); }
        }
        for(KJ_Model_Picklist.Territory value : KJ_Model_Picklist.Territory.values()){
            String label = KJ_Model_Picklist.mapToString(value);
            if(label != null){ Assert.isTrue(territories.contains(label), 'Territory.' + value + ' writes "' + label + '", which is not an active Branch Territory picklist value'); }
        }
        for(KJ_Model_Picklist.AccountStatus value : KJ_Model_Picklist.AccountStatus.values()){
            String label = KJ_Model_Picklist.mapToString(value);
            if(label != null){ Assert.isTrue(statuses.contains(label), 'AccountStatus.' + value + ' writes "' + label + '", which is not an active Account Status picklist value'); }
        }
        for(KJ_Model_Picklist.ContactMethod value : KJ_Model_Picklist.ContactMethod.values()){
            String label = KJ_Model_Picklist.mapToString(value);
            if(label != null){ Assert.isTrue(methods.contains(label), 'ContactMethod.' + value + ' writes "' + label + '", which is not an active Contact Method picklist value'); }
        }
    }
}
