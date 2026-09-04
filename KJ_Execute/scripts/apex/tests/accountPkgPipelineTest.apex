// accountPkgPipelineTest.apex - Slate Thompson (Slate@kintyjones.com)
// Walks one Account through: query -> model -> entry -> bundle -> package. Read-only.

KJ_Tool_Origin scriptOrigin = KJ_Tool_Origin.fromApex(
    'accountPkgPipelineTest.apex', 'KJ_Execute', 'accountPkgPipeline'
);

// The model owns its field list, so the query cannot drift from what build() reads.
List<String> fieldNames = new List<String>();
for(SObjectField modelField : KJ_Model_Account.getFields()){
    fieldNames.add(String.valueOf(modelField));
}
List<Account> sourceRecords = Database.query(
    'SELECT ' + String.join(fieldNames, ', ') + ' FROM Account LIMIT 1'
);
if(sourceRecords.isEmpty()){
    KJ_Tool_Logger.warn('No Account records in this org; nothing to package.', scriptOrigin);
    return;
}

KJ_Model_Account  accountModel  = KJ_Model_Account.build(sourceRecords[0]);
KJ_Tool_DataEntry accountEntry  = KJ_Tool_DataEntry.build(accountModel).withLabel('Account');
KJ_Tool_DataBundle accountBundle = KJ_Tool_DataBundle.build(accountEntry).withLabel('Account Bundle');

KJ_Tool_Package accountPackage = KJ_Tool_Package.build(accountBundle)
                                                .withLabel('Account Package')
                                                .withOrigin(KJ_Tool_Origin.fromRecord('Account', accountModel.recordId))
                                                .withOrgContext(KJ_Tool_OrgContext.build())
                                                .withUserContext(KJ_Tool_UserContext.build());

// Round trip: pull the model back out the way a downstream engine would.
KJ_Model_Account packagedModel = (KJ_Model_Account) accountPackage.dataBundle.getByLabel('Account').value;

// One entry, one banner. Assemble the whole report before handing it to the logger.
List<String> report = new List<String>{
    'PACKAGE',
    '  Label            : ' + accountPackage.label,
    '  Origin           : ' + accountPackage.origin.objectName + ' / ' + accountPackage.origin.recordId,
    '  Org              : ' + accountPackage.orgContext.orgName,
    '  Running user     : ' + accountPackage.userContext.userName,
    '  Trigger context  : ' + accountPackage.triggerContext,
    '  Result success   : ' + accountPackage.result.isSuccess,
    '',
    'BUNDLE',
    '  Label            : ' + accountPackage.dataBundle.label,
    '  Entries          : ' + accountPackage.dataBundle.entries.size(),
    '',
    'PACKAGED ACCOUNT',
    '  Record Id        : ' + packagedModel.recordId,
    '  Name             : ' + packagedModel.name,
    '  Status           : ' + packagedModel.status,
    '  Sector           : ' + packagedModel.sector,
    '  Branch Territory : ' + packagedModel.branchTerritory,
    '  Phone            : ' + packagedModel.phone,
    '  Billing City     : ' + packagedModel.billingCity,
    '  Record Origin    : ' + packagedModel.recordOrigin
};

KJ_Tool_Logger.debug(String.join(report, '\n'), scriptOrigin);
