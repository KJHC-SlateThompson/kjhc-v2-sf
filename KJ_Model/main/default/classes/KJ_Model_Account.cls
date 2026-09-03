/* 
*   File: KJ_Model_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 8/15/2026
*   Description: This class is built to act as a code interface for the Account object
*/

public with sharing class KJ_Model_Account {

    //*-- 1. Constants -----------------------------------------------------------------------------

    //*--    1.1 Field Groupings -------------------------------------------------------------------
    public static final List<SObjectField> VITAL_DATA = new List<SObjectField>{
        Account.Id,
        Account.Name,
        Account.ParentId,
        Account.Account_Status__c,
        Account.Account_Sector__c,
        Account.Branch_Territory__c
    };
    public static final List<SObjectField> NOTES_DATA = new List<SObjectField>{
        Account.Office_Notes__c,
        Account.Field_Notes__c
    };
    public static final List<SObjectField> CONTACT_DATA = new List<SObjectField>{
        Account.Phone,
        Account.Account_Primary_Contact__c
    };
    public static final List<SObjectField> LOCATION_DATA = new List<SObjectField>{
        Account.BillingStreet,
        Account.BillingCity,
        Account.BillingState,
        Account.BillingPostalCode
    };
    public static final List<SObjectField> FINANCIAL_DATA = new List<SObjectField>{
        Account.Invoiced_Revenue__c,
        Account.Customer_Since__c,
        Account.Last_Service_Date__c
    };
    public static final List<SObjectField> REFERRAL_DATA = new List<SObjectField>{
        Account.Account_Lead_Source__c,
        Account.Referred_By__c,
        Account.Referred_By_Email__c,
        Account.Referred_By_Phone__c
    };
    public static final List<SObjectField> ATTRIBUTION_DATA = new List<SObjectField>{
        Account.GCLID__c,
        Account.UTM_Source__c,
        Account.UTM_Medium__c,
        Account.UTM_Campaign__c,
        Account.UTM_Term__c,
        Account.UTM_Content__c
    };
    public static final List<SObjectField> METADATA_DATA = new List<SObjectField>{
        Account.OwnerId,
        Account.CreatedById,
        Account.LastModifiedById,
        Account.Record_Origin__c,
        Account.Origin_Record_Id__c,
        Account.Origin_Created_Date__c,
        Account.FieldPulse_Account_Id__c,
        Account.QBO_Account_Id__c
    };

    //*--    1.2 Type Defaults ---------------------------------------------------------------------
    private static final String                          DEFAULT_TEXT      = null;
    private static final Decimal                         DEFAULT_NUMBER    = null;
    private static final Date                            DEFAULT_DATE      = null;
    private static final Datetime                        DEFAULT_DATETIME  = null;
    private static final KJ_Model_Picklist.AccountStatus DEFAULT_STATUS    = KJ_Model_Picklist.AccountStatus.UNKNOWN;
    private static final KJ_Model_Picklist.Sector        DEFAULT_SECTOR    = KJ_Model_Picklist.Sector.UNKNOWN;
    private static final KJ_Model_Picklist.Territory     DEFAULT_TERRITORY = KJ_Model_Picklist.Territory.UNKNOWN;
    private static final KJ_Model_Picklist.RecordOrigin  DEFAULT_ORIGIN    = KJ_Model_Picklist.RecordOrigin.UNKNOWN;

    //*--    1.3 Object Reference ------------------------------------------------------------------
    // Statically records the SObject type of the object modeled by the class
    public static final SObjectType SOBJECT_TYPE = Account.SObjectType;


    //*-- 2. Member Variables ----------------------------------------------------------------------

    // Vital
    public Id                              recordId            { get; private set; }
    public Id                              parentId            { get; private set; }
    public String                          name                { get; private set; }
    public KJ_Model_Picklist.AccountStatus status              { get; private set; }
    public KJ_Model_Picklist.Sector        sector              { get; private set; }
    public KJ_Model_Picklist.Territory     branchTerritory     { get; private set; }

    // Notes
    public String                          officeNotes         { get; private set; }
    public String                          fieldNotes          { get; private set; }

    // Contact
    public String                          phone               { get; private set; }
    public Id                              primaryContactId    { get; private set; }

    // Location
    public String                          billingStreet       { get; private set; }
    public String                          billingCity         { get; private set; }
    public String                          billingState        { get; private set; }
    public String                          billingPostalCode   { get; private set; }

    // Financial
    public Decimal                         invoicedRevenue     { get; private set; }
    public Date                            customerSince       { get; private set; }
    public Date                            lastServiceDate     { get; private set; }

    // Referral
    public String                          leadSource          { get; private set; }
    public String                          referredBy          { get; private set; }
    public String                          referredByEmail     { get; private set; }
    public String                          referredByPhone     { get; private set; }

    // Attribution
    public String                          gclid               { get; private set; }
    public String                          utmSource           { get; private set; }
    public String                          utmMedium           { get; private set; }
    public String                          utmCampaign         { get; private set; }
    public String                          utmTerm             { get; private set; }
    public String                          utmContent          { get; private set; }

    // Metadata
    public Id                              ownerId             { get; private set; }
    public Id                              createdById         { get; private set; }
    public Id                              lastModifiedById    { get; private set; }
    public KJ_Model_Picklist.RecordOrigin  recordOrigin        { get; private set; }
    public String                          originRecordId      { get; private set; }
    public Datetime                        originCreatedDate   { get; private set; }
    public String                          fieldPulseAccountId { get; private set; }
    public String                          qboAccountId        { get; private set; }


    //*-- 3. Static Methods ------------------------------------------------------------------------

    //*--    3.1 Factories -------------------------------------------------------------------------
    public static KJ_Model_Account build(Account initRecord){
        KJ_Model_Account newModel = new KJ_Model_Account();
        if(initRecord == null) { return newModel; }

        Map<String, Object> source = initRecord.getPopulatedFieldsAsMap();

        // Vital
        newModel.recordId            = (Id)      read(source, Account.Id)                          ?? newModel.recordId;
        newModel.parentId            = (Id)      read(source, Account.ParentId)                    ?? newModel.parentId;
        newModel.name                = (String)  read(source, Account.Name)                        ?? newModel.name;
        newModel.status              = KJ_Model_Picklist.mapToAccountStatus((String) read(source, Account.Account_Status__c));
        newModel.sector              = KJ_Model_Picklist.mapToSector((String) read(source, Account.Account_Sector__c));
        newModel.branchTerritory     = KJ_Model_Picklist.mapToTerritory((String) read(source, Account.Branch_Territory__c));

        // Notes
        newModel.officeNotes         = (String)  read(source, Account.Office_Notes__c)             ?? newModel.officeNotes;
        newModel.fieldNotes          = (String)  read(source, Account.Field_Notes__c)              ?? newModel.fieldNotes;

        // Contact
        newModel.phone               = (String)  read(source, Account.Phone)                       ?? newModel.phone;
        newModel.primaryContactId    = (Id)      read(source, Account.Account_Primary_Contact__c)  ?? newModel.primaryContactId;

        // Location
        newModel.billingStreet       = (String)  read(source, Account.BillingStreet)               ?? newModel.billingStreet;
        newModel.billingCity         = (String)  read(source, Account.BillingCity)                 ?? newModel.billingCity;
        newModel.billingState        = (String)  read(source, Account.BillingState)                ?? newModel.billingState;
        newModel.billingPostalCode   = (String)  read(source, Account.BillingPostalCode)           ?? newModel.billingPostalCode;

        // Financial
        newModel.invoicedRevenue     = (Decimal) read(source, Account.Invoiced_Revenue__c)         ?? newModel.invoicedRevenue;
        newModel.customerSince       = (Date)    read(source, Account.Customer_Since__c)           ?? newModel.customerSince;
        newModel.lastServiceDate     = (Date)    read(source, Account.Last_Service_Date__c)        ?? newModel.lastServiceDate;

        // Referral
        newModel.leadSource          = (String)  read(source, Account.Account_Lead_Source__c)      ?? newModel.leadSource;
        newModel.referredBy          = (String)  read(source, Account.Referred_By__c)              ?? newModel.referredBy;
        newModel.referredByEmail     = (String)  read(source, Account.Referred_By_Email__c)        ?? newModel.referredByEmail;
        newModel.referredByPhone     = readText(source, Account.Referred_By_Phone__c)              ?? newModel.referredByPhone;

        // Attribution
        newModel.gclid               = (String)  read(source, Account.GCLID__c)                    ?? newModel.gclid;
        newModel.utmSource           = (String)  read(source, Account.UTM_Source__c)               ?? newModel.utmSource;
        newModel.utmMedium           = (String)  read(source, Account.UTM_Medium__c)               ?? newModel.utmMedium;
        newModel.utmCampaign         = (String)  read(source, Account.UTM_Campaign__c)             ?? newModel.utmCampaign;
        newModel.utmTerm             = (String)  read(source, Account.UTM_Term__c)                 ?? newModel.utmTerm;
        newModel.utmContent          = (String)  read(source, Account.UTM_Content__c)              ?? newModel.utmContent;

        // Metadata
        newModel.ownerId             = (Id)      read(source, Account.OwnerId)                     ?? newModel.ownerId;
        newModel.createdById         = (Id)      read(source, Account.CreatedById)                 ?? newModel.createdById;
        newModel.lastModifiedById    = (Id)      read(source, Account.LastModifiedById)            ?? newModel.lastModifiedById;
        newModel.recordOrigin        = KJ_Model_Picklist.mapToRecordOrigin((String) read(source, Account.Record_Origin__c));
        newModel.originRecordId      = (String)  read(source, Account.Origin_Record_Id__c)         ?? newModel.originRecordId;
        newModel.originCreatedDate   = (Datetime) read(source, Account.Origin_Created_Date__c)     ?? newModel.originCreatedDate;
        newModel.fieldPulseAccountId = (String)  read(source, Account.FieldPulse_Account_Id__c)    ?? newModel.fieldPulseAccountId;
        newModel.qboAccountId        = (String)  read(source, Account.QBO_Account_Id__c)           ?? newModel.qboAccountId;

        return newModel;
    }
    public static KJ_Model_Account build(){
        return build(null);
    }

    public static List<KJ_Model_Account> buildAll(List<Account> initRecords){
        List<KJ_Model_Account> newModels = new List<KJ_Model_Account>();
        if(initRecords == null) { return newModels; }

        for(Account record : initRecords){
            newModels.add(build(record));
        }

        return newModels;
    }

    public static Map<Id, KJ_Model_Account> buildAllById(List<Account> initRecords){
        Map<Id, KJ_Model_Account> newModels = new Map<Id, KJ_Model_Account>();
        if(initRecords == null) { return newModels; }

        for(Account record : initRecords){
            if(record.Id == null) { continue; }
            newModels.put(record.Id, build(record));
        }

        return newModels;
    }

    //*--    3.2 Static Field Ops  --------------------------------------------------------------------
    public static List<SObjectField> getFields(){
        List<SObjectField> allFields = new List<SObjectField>();
        allFields.addAll(VITAL_DATA);
        allFields.addAll(NOTES_DATA);
        allFields.addAll(CONTACT_DATA);
        allFields.addAll(LOCATION_DATA);
        allFields.addAll(FINANCIAL_DATA);
        allFields.addAll(REFERRAL_DATA);
        allFields.addAll(ATTRIBUTION_DATA);
        allFields.addAll(METADATA_DATA);
        return allFields;
    }

    //*--    3.3 Internal --------------------------------------------------------------------------
    private static void put(Account targetRecord, SObjectField targetField, Object targetValue){
        if(targetValue != null) { targetRecord.put(targetField, targetValue); }
    }

    // Reading a field the caller never queried throws an SObjectException, so build() works off the
    // populated-field map rather than the record. An absent field reads as null and falls through to
    // whatever the constructor already set.
    private static Object read(Map<String, Object> sourceFields, SObjectField targetField){
        return sourceFields.get(String.valueOf(targetField));
    }

    // Referred_By_Phone__c is a Number field in the org, so it reads back as a Decimal while the model
    // keeps phone numbers as text. Normalizing here avoids a TypeException on a straight (String) cast.
    private static String readText(Map<String, Object> sourceFields, SObjectField targetField){
        Object fieldValue = read(sourceFields, targetField);
        return fieldValue == null ? null : String.valueOf(fieldValue);
    }


    //*-- 4. Instance Methods ----------------------------------------------------------------------

    //*--    4.1 Constructor -----------------------------------------------------------------------
    public KJ_Model_Account() {
        // Vital
        this.recordId            = null;
        this.parentId            = null;
        this.name                = DEFAULT_TEXT;
        this.status              = DEFAULT_STATUS;
        this.sector              = DEFAULT_SECTOR;
        this.branchTerritory     = DEFAULT_TERRITORY;

        // Notes
        this.officeNotes         = DEFAULT_TEXT;
        this.fieldNotes          = DEFAULT_TEXT;

        // Contact
        this.phone               = DEFAULT_TEXT;
        this.primaryContactId    = null;

        // Location
        this.billingStreet       = DEFAULT_TEXT;
        this.billingCity         = DEFAULT_TEXT;
        this.billingState        = DEFAULT_TEXT;
        this.billingPostalCode   = DEFAULT_TEXT;

        // Financial
        this.invoicedRevenue     = DEFAULT_NUMBER;
        this.customerSince       = DEFAULT_DATE;
        this.lastServiceDate     = DEFAULT_DATE;

        // Referral
        this.leadSource          = DEFAULT_TEXT;
        this.referredBy          = DEFAULT_TEXT;
        this.referredByEmail     = DEFAULT_TEXT;
        this.referredByPhone     = DEFAULT_TEXT;

        // Attribution
        this.gclid               = DEFAULT_TEXT;
        this.utmSource           = DEFAULT_TEXT;
        this.utmMedium           = DEFAULT_TEXT;
        this.utmCampaign         = DEFAULT_TEXT;
        this.utmTerm             = DEFAULT_TEXT;
        this.utmContent          = DEFAULT_TEXT;

        // Metadata
        this.ownerId             = null;
        this.createdById         = null;
        this.lastModifiedById    = null;
        this.recordOrigin        = DEFAULT_ORIGIN;
        this.originRecordId      = null;
        this.originCreatedDate   = DEFAULT_DATETIME;
        this.fieldPulseAccountId = null;
        this.qboAccountId        = null;
    }

    //*--    4.2 Conversion ------------------------------------------------------------------------
    public Account toRecord(){
        Account newRecord = new Account();

        // Vital
        put(newRecord, Account.Id,                          this.recordId);
        put(newRecord, Account.ParentId,                    this.parentId);
        put(newRecord, Account.Name,                        this.name);
        put(newRecord, Account.Account_Status__c,           KJ_Model_Picklist.mapToString(this.status));
        put(newRecord, Account.Account_Sector__c,           KJ_Model_Picklist.mapToString(this.sector));
        put(newRecord, Account.Branch_Territory__c,         KJ_Model_Picklist.mapToString(this.branchTerritory));

        // Notes
        put(newRecord, Account.Office_Notes__c,             this.officeNotes);
        put(newRecord, Account.Field_Notes__c,              this.fieldNotes);

        // Contact
        put(newRecord, Account.Phone,                       this.phone);
        put(newRecord, Account.Account_Primary_Contact__c,  this.primaryContactId);

        // Location
        put(newRecord, Account.BillingStreet,               this.billingStreet);
        put(newRecord, Account.BillingCity,                 this.billingCity);
        put(newRecord, Account.BillingState,                this.billingState);
        put(newRecord, Account.BillingPostalCode,           this.billingPostalCode);

        // Financial
        put(newRecord, Account.Invoiced_Revenue__c,         this.invoicedRevenue);
        put(newRecord, Account.Customer_Since__c,           this.customerSince);
        put(newRecord, Account.Last_Service_Date__c,        this.lastServiceDate);

        // Referral
        put(newRecord, Account.Account_Lead_Source__c,      this.leadSource);
        put(newRecord, Account.Referred_By__c,              this.referredBy);
        put(newRecord, Account.Referred_By_Email__c,        this.referredByEmail);
        put(newRecord, Account.Referred_By_Phone__c,        this.referredByPhone);

        // Attribution
        put(newRecord, Account.GCLID__c,                    this.gclid);
        put(newRecord, Account.UTM_Source__c,               this.utmSource);
        put(newRecord, Account.UTM_Medium__c,               this.utmMedium);
        put(newRecord, Account.UTM_Campaign__c,             this.utmCampaign);
        put(newRecord, Account.UTM_Term__c,                 this.utmTerm);
        put(newRecord, Account.UTM_Content__c,              this.utmContent);

        // Metadata — CreatedById and LastModifiedById omitted, not writeable
        put(newRecord, Account.OwnerId,                     this.ownerId);
        put(newRecord, Account.Record_Origin__c,            KJ_Model_Picklist.mapToString(this.recordOrigin));
        put(newRecord, Account.Origin_Record_Id__c,         this.originRecordId);
        put(newRecord, Account.Origin_Created_Date__c,      this.originCreatedDate);
        put(newRecord, Account.FieldPulse_Account_Id__c,    this.fieldPulseAccountId);
        put(newRecord, Account.QBO_Account_Id__c,           this.qboAccountId);

        return newRecord;
    }

    //*--    4.3 Setters ---------------------------------------------------------------------------
    // Vital
    public KJ_Model_Account setRecordId(Id initRecordId){
        this.recordId = initRecordId ?? this.recordId;
        return this;
    }
    public KJ_Model_Account setParentId(Id initParentId){
        this.parentId = initParentId ?? this.parentId;
        return this;
    }
    public KJ_Model_Account setName(String initName){
        this.name = initName ?? this.name;
        return this;
    }
    public KJ_Model_Account setStatus(KJ_Model_Picklist.AccountStatus initStatus){
        this.status = initStatus ?? this.status;
        return this;
    }
    public KJ_Model_Account setSector(KJ_Model_Picklist.Sector initSector){
        this.sector = initSector ?? this.sector;
        return this;
    }
    public KJ_Model_Account setBranchTerritory(KJ_Model_Picklist.Territory initBranchTerritory){
        this.branchTerritory = initBranchTerritory ?? this.branchTerritory;
        return this;
    }

    // Notes
    public KJ_Model_Account setOfficeNotes(String initOfficeNotes){
        this.officeNotes = initOfficeNotes ?? this.officeNotes;
        return this;
    }
    public KJ_Model_Account setFieldNotes(String initFieldNotes){
        this.fieldNotes = initFieldNotes ?? this.fieldNotes;
        return this;
    }

    // Contact
    public KJ_Model_Account setPhone(String initPhone){
        this.phone = initPhone ?? this.phone;
        return this;
    }
    public KJ_Model_Account setPrimaryContactId(Id initPrimaryContactId){
        this.primaryContactId = initPrimaryContactId ?? this.primaryContactId;
        return this;
    }

    // Location
    public KJ_Model_Account setBillingStreet(String initBillingStreet){
        this.billingStreet = initBillingStreet ?? this.billingStreet;
        return this;
    }
    public KJ_Model_Account setBillingCity(String initBillingCity){
        this.billingCity = initBillingCity ?? this.billingCity;
        return this;
    }
    public KJ_Model_Account setBillingState(String initBillingState){
        this.billingState = initBillingState ?? this.billingState;
        return this;
    }
    public KJ_Model_Account setBillingPostalCode(String initBillingPostalCode){
        this.billingPostalCode = initBillingPostalCode ?? this.billingPostalCode;
        return this;
    }

    // Financial
    public KJ_Model_Account setInvoicedRevenue(Decimal initInvoicedRevenue){
        this.invoicedRevenue = initInvoicedRevenue ?? this.invoicedRevenue;
        return this;
    }
    public KJ_Model_Account setCustomerSince(Date initCustomerSince){
        this.customerSince = initCustomerSince ?? this.customerSince;
        return this;
    }
    public KJ_Model_Account setLastServiceDate(Date initLastServiceDate){
        this.lastServiceDate = initLastServiceDate ?? this.lastServiceDate;
        return this;
    }

    // Referral
    public KJ_Model_Account setLeadSource(String initLeadSource){
        this.leadSource = initLeadSource ?? this.leadSource;
        return this;
    }
    public KJ_Model_Account setReferredBy(String initReferredBy){
        this.referredBy = initReferredBy ?? this.referredBy;
        return this;
    }
    public KJ_Model_Account setReferredByEmail(String initReferredByEmail){
        this.referredByEmail = initReferredByEmail ?? this.referredByEmail;
        return this;
    }
    public KJ_Model_Account setReferredByPhone(String initReferredByPhone){
        this.referredByPhone = initReferredByPhone ?? this.referredByPhone;
        return this;
    }

    // Attribution
    public KJ_Model_Account setGclid(String initGclid){
        this.gclid = initGclid ?? this.gclid;
        return this;
    }
    public KJ_Model_Account setUtmSource(String initUtmSource){
        this.utmSource = initUtmSource ?? this.utmSource;
        return this;
    }
    public KJ_Model_Account setUtmMedium(String initUtmMedium){
        this.utmMedium = initUtmMedium ?? this.utmMedium;
        return this;
    }
    public KJ_Model_Account setUtmCampaign(String initUtmCampaign){
        this.utmCampaign = initUtmCampaign ?? this.utmCampaign;
        return this;
    }
    public KJ_Model_Account setUtmTerm(String initUtmTerm){
        this.utmTerm = initUtmTerm ?? this.utmTerm;
        return this;
    }
    public KJ_Model_Account setUtmContent(String initUtmContent){
        this.utmContent = initUtmContent ?? this.utmContent;
        return this;
    }

    // Metadata
    public KJ_Model_Account setRecordOrigin(KJ_Model_Picklist.RecordOrigin initRecordOrigin){
        this.recordOrigin = initRecordOrigin ?? this.recordOrigin;
        return this;
    }
    public KJ_Model_Account setOriginRecordId(String initOriginRecordId){
        this.originRecordId = initOriginRecordId ?? this.originRecordId;
        return this;
    }
    public KJ_Model_Account setOriginCreatedDate(Datetime initOriginCreatedDate){
        this.originCreatedDate = initOriginCreatedDate ?? this.originCreatedDate;
        return this;
    }
    public KJ_Model_Account setFieldPulseAccountId(String initFieldPulseAccountId){
        this.fieldPulseAccountId = initFieldPulseAccountId ?? this.fieldPulseAccountId;
        return this;
    }
    public KJ_Model_Account setQboAccountId(String initQboAccountId){
        this.qboAccountId = initQboAccountId ?? this.qboAccountId;
        return this;
    }

}
