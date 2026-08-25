public with sharing class KJ_Model_Account {

    //*-- 1. Constants -----------------------------------------------------------------------------

    //*--    1.1 Picklist Proxy Enums --------------------------------------------------------------
    public enum Status              { UNKNOWN, LEAD, CURRENT_CUSTOMER, LOST }
    public enum Sector              { UNKNOWN, RESIDENTIAL, COMMERCIAL }
    public enum ServiceTerritory    { UNKNOWN, NWA, TULSA }
    public enum RecordOrigin        { UNKNOWN, FIELDPULSE, QBO, SALESFORCE, SALESFORCE_V1 }

    //*--    1.2 Field Groupings -------------------------------------------------------------------
    public static final List<SObjectField> VITAL_DATA = new List<SObjectField>{
        Account.Id,
        Account.Name,
        Account.ParentId,
        Account.RecordTypeId,
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
        Account.Email__c,
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
        Account.FieldPulse_Id__c,
        Account.QBO_Customer_Id__c
    };

    //*--    1.3 Type Defaults ---------------------------------------------------------------------
    private static final String             DEFAULT_TEXT      = null;
    private static final Decimal            DEFAULT_NUMBER    = null;
    private static final Date               DEFAULT_DATE      = null;
    private static final Datetime           DEFAULT_DATETIME  = null;
    private static final Status             DEFAULT_STATUS    = Status.UNKNOWN;
    private static final Sector             DEFAULT_SECTOR    = Sector.UNKNOWN;
    private static final ServiceTerritory   DEFAULT_TERRITORY = ServiceTerritory.UNKNOWN;
    private static final RecordOrigin       DEFAULT_ORIGIN    = RecordOrigin.UNKNOWN;

    //*--    1.4 Object Reference ------------------------------------------------------------------
    // Statically records the SObject type of the object modeled by the class
    public static final SObjectType SOBJECT_TYPE = Account.SObjectType;


    //*-- 2. Member Variables ----------------------------------------------------------------------

    // Vital
    public Id                   recordId            { get; private set; }
    public Id                   parentId            { get; private set; }
    public Id                   recordTypeId        { get; private set; }
    public String               name                { get; private set; }
    public Status               status              { get; private set; }
    public Sector               sector              { get; private set; }
    public ServiceTerritory     serviceTerritory    { get; private set; }

    // Notes
    public String               officeNotes         { get; private set; }
    public String               fieldNotes          { get; private set; }

    // Contact
    public String               phone               { get; private set; }
    public String               email               { get; private set; }
    public Id                   primaryContactId    { get; private set; }

    // Location
    public String               billingStreet       { get; private set; }
    public String               billingCity         { get; private set; }
    public String               billingState        { get; private set; }
    public String               billingPostalCode   { get; private set; }

    // Financial
    public Decimal              invoicedRevenue     { get; private set; }
    public Date                 customerSince       { get; private set; }
    public Date                 lastServiceDate     { get; private set; }

    // Referral
    public String               leadSource          { get; private set; }
    public String               referredBy          { get; private set; }
    public String               referredByEmail     { get; private set; }
    public String               referredByPhone     { get; private set; }

    // Attribution
    public String               gclid               { get; private set; }
    public String               utmSource           { get; private set; }
    public String               utmMedium           { get; private set; }
    public String               utmCampaign         { get; private set; }
    public String               utmTerm             { get; private set; }
    public String               utmContent          { get; private set; }

    // Metadata
    public Id                   ownerId             { get; private set; }
    public Id                   createdById         { get; private set; }
    public Id                   lastModifiedById    { get; private set; }
    public RecordOrigin         recordOrigin        { get; private set; }
    public String               originRecordId      { get; private set; }
    public Datetime             originCreatedDate   { get; private set; }
    public String               fieldPulseId        { get; private set; }
    public String               qboCustomerId       { get; private set; }


    //*-- 3. Static Methods ------------------------------------------------------------------------

    //*--    3.1 Picklist Mapping ------------------------------------------------------------------
    public static Status mapToStatus(String statusValue){
        if(String.isBlank(statusValue)) { return Status.UNKNOWN; }
        switch on statusValue.toUpperCase() {
            when 'LEAD'                                     { return Status.LEAD; }
            when 'CURRENT CUSTOMER', 'CURRENT_CUSTOMER'     { return Status.CURRENT_CUSTOMER; }
            when 'LOST'                                     { return Status.LOST; }
            when else                                       { return Status.UNKNOWN; }
        }
    }
    public static String mapToString(Status statusValue){
        switch on statusValue {
            when LEAD               { return 'Lead'; }
            when CURRENT_CUSTOMER   { return 'Current Customer'; }
            when LOST               { return 'Lost'; }
            when else               { return null; }
        }
    }

    public static Sector mapToSector(String sectorValue){
        if(String.isBlank(sectorValue)) { return Sector.UNKNOWN; }
        switch on sectorValue.toUpperCase() {
            when 'RESIDENTIAL'  { return Sector.RESIDENTIAL; }
            when 'COMMERCIAL'   { return Sector.COMMERCIAL; }
            when else           { return Sector.UNKNOWN; }
        }
    }
    public static String mapToString(Sector sectorValue){
        switch on sectorValue {
            when RESIDENTIAL    { return 'Residential'; }
            when COMMERCIAL     { return 'Commercial'; }
            when else           { return null; }
        }
    }

    public static ServiceTerritory mapToServiceTerritory(String serviceTerritoryValue){
        if(String.isBlank(serviceTerritoryValue)) { return ServiceTerritory.UNKNOWN; }
        switch on serviceTerritoryValue.toUpperCase() {
            when 'NWA'          { return ServiceTerritory.NWA; }
            when 'TULSA'        { return ServiceTerritory.TULSA; }
            when else           { return ServiceTerritory.UNKNOWN; }
        }
    }
    public static String mapToString(ServiceTerritory serviceTerritoryValue){
        switch on serviceTerritoryValue {
            when NWA            { return 'NWA'; }
            when TULSA          { return 'TULSA'; }
            when else           { return null; }
        }
    }

    public static RecordOrigin mapToRecordOrigin(String originValue){
        if(String.isBlank(originValue)) { return RecordOrigin.UNKNOWN; }
        switch on originValue.toUpperCase() {
            when 'FIELDPULSE'       { return RecordOrigin.FIELDPULSE; }
            when 'QBO'              { return RecordOrigin.QBO; }
            when 'SALESFORCE'       { return RecordOrigin.SALESFORCE; }
            when 'SALESFORCE_V1'    { return RecordOrigin.SALESFORCE_V1; }
            when else               { return RecordOrigin.UNKNOWN; }
        }
    }
    public static String mapToString(RecordOrigin originValue){
        switch on originValue {
            when FIELDPULSE     { return 'FieldPulse'; }
            when QBO            { return 'QBO'; }
            when SALESFORCE     { return 'SALESFORCE'; }
            when SALESFORCE_V1  { return 'SALESFORCE_V1'; }
            when else           { return null; }
        }
    }



    //*--    3.2 Factories -------------------------------------------------------------------------
    public static KJ_Model_Account build(Account initRecord){
        KJ_Model_Account newModel = new KJ_Model_Account();
        if(initRecord == null) { return newModel; }

        Account source = new Account();
        source.putAll(initRecord);

        // Vital
        newModel.recordId           = source.Id                         ?? newModel.recordId;
        newModel.parentId           = source.ParentId                   ?? newModel.parentId;
        newModel.recordTypeId       = source.RecordTypeId               ?? newModel.recordTypeId;
        newModel.name               = source.Name                       ?? newModel.name;
        newModel.status             = mapToStatus(source.Account_Status__c);
        newModel.sector             = mapToSector(source.Account_Sector__c);
        newModel.serviceTerritory   = mapToServiceTerritory(source.Branch_Territory__c);

        // Notes
        newModel.officeNotes        = source.Office_Notes__c            ?? newModel.officeNotes;
        newModel.fieldNotes         = source.Field_Notes__c             ?? newModel.fieldNotes;

        // Contact
        newModel.phone              = source.Phone                      ?? newModel.phone;
        newModel.email              = source.Email__c                   ?? newModel.email;
        newModel.primaryContactId   = source.Account_Primary_Contact__c ?? newModel.primaryContactId;

        // Location
        newModel.billingStreet      = source.BillingStreet              ?? newModel.billingStreet;
        newModel.billingCity        = source.BillingCity                ?? newModel.billingCity;
        newModel.billingState       = source.BillingState               ?? newModel.billingState;
        newModel.billingPostalCode  = source.BillingPostalCode          ?? newModel.billingPostalCode;

        // Financial
        newModel.invoicedRevenue    = source.Invoiced_Revenue__c        ?? newModel.invoicedRevenue;
        newModel.customerSince      = source.Customer_Since__c          ?? newModel.customerSince;
        newModel.lastServiceDate    = source.Last_Service_Date__c       ?? newModel.lastServiceDate;

        // Referral
        newModel.leadSource         = source.Account_Lead_Source__c     ?? newModel.leadSource;
        newModel.referredBy         = source.Referred_By__c             ?? newModel.referredBy;
        newModel.referredByEmail    = source.Referred_By_Email__c       ?? newModel.referredByEmail;
        newModel.referredByPhone    = source.Referred_By_Phone__c       ?? newModel.referredByPhone;

        // Attribution
        newModel.gclid              = source.GCLID__c                   ?? newModel.gclid;
        newModel.utmSource          = source.UTM_Source__c              ?? newModel.utmSource;
        newModel.utmMedium          = source.UTM_Medium__c              ?? newModel.utmMedium;
        newModel.utmCampaign        = source.UTM_Campaign__c            ?? newModel.utmCampaign;
        newModel.utmTerm            = source.UTM_Term__c                ?? newModel.utmTerm;
        newModel.utmContent         = source.UTM_Content__c             ?? newModel.utmContent;

        // Metadata
        newModel.ownerId            = source.OwnerId                    ?? newModel.ownerId;
        newModel.createdById        = source.CreatedById                ?? newModel.createdById;
        newModel.lastModifiedById   = source.LastModifiedById           ?? newModel.lastModifiedById;
        newModel.recordOrigin       = mapToRecordOrigin(source.Record_Origin__c);
        newModel.originRecordId     = source.Origin_Record_Id__c        ?? newModel.originRecordId;
        newModel.originCreatedDate  = source.Origin_Created_Date__c     ?? newModel.originCreatedDate;
        newModel.fieldPulseId       = source.FieldPulse_Id__c           ?? newModel.fieldPulseId;
        newModel.qboCustomerId      = source.QBO_Customer_Id__c         ?? newModel.qboCustomerId;

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

    //*--    3.3 Static Field Ops  --------------------------------------------------------------------
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

    //*--    3.4 Internal --------------------------------------------------------------------------
    private static void put(Account targetRecord, SObjectField targetField, Object targetValue){
        if(targetValue != null) { targetRecord.put(targetField, targetValue); }
    }


    //*-- 4. Instance Methods ----------------------------------------------------------------------

    //*--    4.1 Constructor -----------------------------------------------------------------------
    public KJ_Model_Account() {
        // Vital
        this.recordId           = null;
        this.parentId           = null;
        this.recordTypeId       = null;
        this.name               = DEFAULT_TEXT;
        this.status             = DEFAULT_STATUS;
        this.sector             = DEFAULT_SECTOR;
        this.serviceTerritory   = DEFAULT_TERRITORY;

        // Notes
        this.officeNotes        = DEFAULT_TEXT;
        this.fieldNotes         = DEFAULT_TEXT;

        // Contact
        this.phone              = DEFAULT_TEXT;
        this.email              = DEFAULT_TEXT;
        this.primaryContactId   = null;

        // Location
        this.billingStreet      = DEFAULT_TEXT;
        this.billingCity        = DEFAULT_TEXT;
        this.billingState       = DEFAULT_TEXT;
        this.billingPostalCode  = DEFAULT_TEXT;

        // Financial
        this.invoicedRevenue    = DEFAULT_NUMBER;
        this.customerSince      = DEFAULT_DATE;
        this.lastServiceDate    = DEFAULT_DATE;

        // Referral
        this.leadSource         = DEFAULT_TEXT;
        this.referredBy         = DEFAULT_TEXT;
        this.referredByEmail    = DEFAULT_TEXT;
        this.referredByPhone    = DEFAULT_TEXT;

        // Attribution
        this.gclid              = DEFAULT_TEXT;
        this.utmSource          = DEFAULT_TEXT;
        this.utmMedium          = DEFAULT_TEXT;
        this.utmCampaign        = DEFAULT_TEXT;
        this.utmTerm            = DEFAULT_TEXT;
        this.utmContent         = DEFAULT_TEXT;

        // Metadata
        this.ownerId            = null;
        this.createdById        = null;
        this.lastModifiedById   = null;
        this.recordOrigin       = DEFAULT_ORIGIN;
        this.originRecordId     = null;
        this.originCreatedDate  = DEFAULT_DATETIME;
        this.fieldPulseId       = null;
        this.qboCustomerId      = null;
    }

    //*--    4.2 Conversion ------------------------------------------------------------------------
    public Account toRecord(){
        Account newRecord = new Account();

        // Vital
        put(newRecord, Account.Id,                          this.recordId);
        put(newRecord, Account.ParentId,                    this.parentId);
        put(newRecord, Account.RecordTypeId,                this.recordTypeId);
        put(newRecord, Account.Name,                        this.name);
        put(newRecord, Account.Account_Status__c,           mapToString(this.status));
        put(newRecord, Account.Account_Sector__c,           mapToString(this.sector));
        put(newRecord, Account.Branch_Territory__c,         mapToString(this.serviceTerritory));

        // Notes
        put(newRecord, Account.Office_Notes__c,             this.officeNotes);
        put(newRecord, Account.Field_Notes__c,              this.fieldNotes);

        // Contact
        put(newRecord, Account.Phone,                       this.phone);
        put(newRecord, Account.Email__c,                    this.email);
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
        put(newRecord, Account.Record_Origin__c,            mapToString(this.recordOrigin));
        put(newRecord, Account.Origin_Record_Id__c,         this.originRecordId);
        put(newRecord, Account.Origin_Created_Date__c,      this.originCreatedDate);
        put(newRecord, Account.FieldPulse_Id__c,            this.fieldPulseId);
        put(newRecord, Account.QBO_Customer_Id__c,          this.qboCustomerId);

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
    public KJ_Model_Account setRecordTypeId(Id initRecordTypeId){
        this.recordTypeId = initRecordTypeId ?? this.recordTypeId;
        return this;
    }
    public KJ_Model_Account setName(String initName){
        this.name = initName ?? this.name;
        return this;
    }
    public KJ_Model_Account setStatus(Status initStatus){
        this.status = initStatus ?? this.status;
        return this;
    }
    public KJ_Model_Account setSector(Sector initSector){
        this.sector = initSector ?? this.sector;
        return this;
    }
    public KJ_Model_Account setServiceTerritory(ServiceTerritory initServiceTerritory){
        this.serviceTerritory = initServiceTerritory ?? this.serviceTerritory;
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
    public KJ_Model_Account setEmail(String initEmail){
        this.email = initEmail ?? this.email;
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
    public KJ_Model_Account setRecordOrigin(RecordOrigin initRecordOrigin){
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
    public KJ_Model_Account setFieldPulseId(String initFieldPulseId){
        this.fieldPulseId = initFieldPulseId ?? this.fieldPulseId;
        return this;
    }
    public KJ_Model_Account setQcode KJ_Model\main\default\classes\KJ_Model_Account.clsboCustomerId(String initQboCustomerId){
        this.qboCustomerId = initQboCustomerId ?? this.qboCustomerId;
        return this;
    }

}
