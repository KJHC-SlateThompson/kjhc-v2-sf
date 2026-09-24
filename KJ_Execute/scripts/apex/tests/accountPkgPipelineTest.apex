// accountPkgPipelineTest.apex - Slate Thompson (Slate@kintyjones.com)
// Runs the Account archive pipeline against four packages: null, empty, one mock Account, several mock Accounts.
// Everything runs inside a savepoint and is rolled back at the end, so the org is left unchanged.
//
// Index:
//     Setup        savepoint, mock Accounts, models
//     Packages     null, empty, single, multi
//     Archive      each package through KJ_Dispatch_Account.archive()
//     Results      result + exception codes per package, Archived__c per mock Account
//     Cleanup      rollback

//*-- Setup ---------------------------------------------------------------------------------------
Savepoint savepoint = Database.setSavepoint();
Integer MULTI_ACCOUNT_COUNT = 3;

// Mock Accounts, inserted so archive() has real Ids to update. Rolled back in Cleanup.
List<Account> mockAccounts = new List<Account>();
for(Integer i = 0; i < MULTI_ACCOUNT_COUNT; i++){
    mockAccounts.add(KJ_Tool_TestDataFactory.createTestAccount());
}
insert mockAccounts;

// Re-queried with the model's own field list, so the models line up with the org model
List<String> fields = new List<String>();
for(SObjectField field : KJ_Model_Account.getFields()){
    fields.add(String.valueOf(field));
}
List<Account> records = Database.query('SELECT ' + String.join(fields, ', ') + ' FROM Account WHERE Id IN :mockAccounts');
List<KJ_Model_Account> models = KJ_Model_Account.buildAll(records);

//*-- Packages ------------------------------------------------------------------------------------
KJ_Tool_Package nullPkg = null;

KJ_Tool_Package emptyPkg = KJ_Tool_Package.build().withLabel('Empty Package');

KJ_Tool_Package singlePkg = KJ_Tool_Package.build(
    KJ_Tool_DataBundle.build(KJ_Tool_DataEntry.build(models[0]).withLabel('Account'))
).withLabel('Single Account Package');

KJ_Tool_DataBundle multiBundle = new KJ_Tool_DataBundle();
for(KJ_Model_Account model : models){
    multiBundle.add(KJ_Tool_DataEntry.build(model).withLabel('Account'));
}
KJ_Tool_Package multiPkg = KJ_Tool_Package.build(multiBundle).withLabel('Multi Account Package');

//*-- Archive -------------------------------------------------------------------------------------
// The null package is replaced, so its result has to be stored. The rest are modified in place.
nullPkg = KJ_Dispatch_Account.archive(nullPkg).withLabel('Null Package');
KJ_Dispatch_Account.archive(emptyPkg);
KJ_Dispatch_Account.archive(singlePkg);
KJ_Dispatch_Account.archive(multiPkg);

//*-- Results -------------------------------------------------------------------------------------
for(KJ_Tool_Package pkg : new List<KJ_Tool_Package>{ nullPkg, emptyPkg, singlePkg, multiPkg }){
    String codes = '';
    for(KJ_Tool_Exception e : pkg.result.exceptions){
        codes += KJ_Tool_Formatter.toString(e.code) + ' ';
    }
    KJ_Tool_Logger.debug(pkg.label + ' : success=' + pkg.result.isSuccess + ' exceptions=[ ' + codes + ']');
}

// Every mock Account should read Archived__c = true: the single package archives the first, the multi package all of them.
for(Account record : [SELECT Name, Archived__c FROM Account WHERE Id IN :mockAccounts]){
    KJ_Tool_Logger.debug(record.Name + ' : Archived__c=' + record.Archived__c);
}

//*-- Cleanup -------------------------------------------------------------------------------------
Database.rollback(savepoint);
