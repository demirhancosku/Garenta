/*
 
 Auto-Generated by SAP NetWeaver Gateway Productivity Accelerator, Version 1.1.1
 
 File: ZGARENTA_LOGIN_SRV_01ServiceV0.h
 Abstract: The generated proxy classes for the ZGARENTA_LOGIN_SRV_01 Service.
 */

#import "ZGARENTA_LOGIN_SRV_01ServiceV0.h"
#import "BaseODataObject.h"
#import "Logger.h"
#import "ODataEntitySchema.h"
#import "ODataCollection.h"
#import "ODataFunctionImport.h"
#import "TypeConverter.h"
#import <objc/runtime.h>
#define ZGARENTA_LOGIN_SRV_01_SERVICE_DOCUMENTV0 @"ZGARENTA_LOGIN_SRV_01ServiceDocumentV0"
#define ZGARENTA_LOGIN_SRV_01_SERVICE_METADATAV0 @"ZGARENTA_LOGIN_SRV_01ServiceMetadataV0"

#pragma mark - Complex Types



#pragma mark - Entity Types


#pragma mark - ET_CARDTYPESV0
@implementation ET_CARDTYPESV0

static NSMutableDictionary *eT_CARDTYPESLabels = nil;
static ODataEntitySchema *eT_CARDTYPESEntitySchema = nil;

- (id)init
{
    self = [super init];
    if (self) {
        m_SDMEntry = [BaseEntityType createEmptyODataEntryWithSchema:eT_CARDTYPESEntitySchema error:nil];
        if (!m_SDMEntry) {
            return nil;
        }
        m_properties = nil;
        self.baseUrl = nil;
    }
    return self;
}



- (ODataEntry *)buildSDMEntryFromPropertiesAndReturnError:(NSError **)error
{
    if (m_SDMEntry) {
        NSError *innerError = nil;
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Partner forSDMPropertyWithName:@"Partner" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Cardtype forSDMPropertyWithName:@"Cardtype" error:&innerError];
        if (innerError) {
            if (error) {
                *error = innerError;
            }
            return nil;
        }
	}
    return m_SDMEntry;
}

+ (void)loadEntitySchema:(ODataServiceDocument *)aService
{
    ODataCollection *collectionSchema = [aService.schema getCollectionByName:@"ET_CARDTYPESSet" workspaceOfCollection:nil];
    eT_CARDTYPESEntitySchema = collectionSchema.entitySchema;
}

+ (void)loadLabels:(ODataServiceDocument *)aService
{
    NSMutableDictionary *properties = [BaseODataObject getSchemaPropertiesFromCollection:@"ET_CARDTYPESSet" andService:aService];
    if (properties) {
        eT_CARDTYPESLabels = [@{} mutableCopy];
        for (ODataPropertyInfo *property in [properties allValues]) {
            eT_CARDTYPESLabels[property.name] = property.label;;
        }
    }
    else {
        LOGERROR(@"Failed to load SAP labels from service metadata");
    }
}


+ (NSString *)getLabelForProperty:(NSString *)aPropertyName
{
    return [BaseODataObject getLabelFromDictionary:eT_CARDTYPESLabels forProperty:aPropertyName];
}

- (void)loadProperties
{
    [super loadProperties];
	self.Partner = [self getStringValueForSDMPropertyWithName:@"Partner"];
	self.Cardtype = [self getStringValueForSDMPropertyWithName:@"Cardtype"];
}

+ (NSMutableArray *)createET_CARDTYPESEntriesForSDMEntries:(NSMutableArray *)sdmEntries
{
    NSMutableArray *entries = [@[] mutableCopy];
    for (ODataEntry *entry in sdmEntries) {
        ET_CARDTYPESV0 *eT_CARDTYPESObject = [[ET_CARDTYPESV0 alloc] initWithSDMEntry:entry];
        [entries addObject:eT_CARDTYPESObject];
    }
    return entries;
}


+ (NSMutableArray *)parseET_CARDTYPESEntriesWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getSDMEntriesForEntitySchema:eT_CARDTYPESEntitySchema andData:aData error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_CARDTYPESV0 createET_CARDTYPESEntriesForSDMEntries:sdmEntries];
}

+ (NSMutableArray *)parseExpandedET_CARDTYPESEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_CARDTYPESEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_CARDTYPESV0 createET_CARDTYPESEntriesForSDMEntries:sdmEntries];
}

+ (ET_CARDTYPESV0 *)parseET_CARDTYPESEntryWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *eT_CARDTYPESEntries = [ET_CARDTYPESV0 parseET_CARDTYPESEntriesWithData:aData error:error];
    if (!eT_CARDTYPESEntries) {
    	return nil;
    }
    return (ET_CARDTYPESV0 *)[ET_CARDTYPESV0 getFirstObjectFromArray:eT_CARDTYPESEntries];
}

+ (ET_CARDTYPESV0 *)parseExpandedET_CARDTYPESEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
	NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_CARDTYPESEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    NSMutableArray *eT_CARDTYPESEntries = [ET_CARDTYPESV0 createET_CARDTYPESEntriesForSDMEntries:sdmEntries];
	return (ET_CARDTYPESV0 *)[ET_CARDTYPESV0 getFirstObjectFromArray:eT_CARDTYPESEntries];
}



@end

#pragma mark - ET_PARTNERSV0
@implementation ET_PARTNERSV0

static NSMutableDictionary *eT_PARTNERSLabels = nil;
static ODataEntitySchema *eT_PARTNERSEntitySchema = nil;

- (id)init
{
    self = [super init];
    if (self) {
        m_SDMEntry = [BaseEntityType createEmptyODataEntryWithSchema:eT_PARTNERSEntitySchema error:nil];
        if (!m_SDMEntry) {
            return nil;
        }
        m_properties = nil;
        self.baseUrl = nil;
    }
    return self;
}



- (ODataEntry *)buildSDMEntryFromPropertiesAndReturnError:(NSError **)error
{
    if (m_SDMEntry) {
        NSError *innerError = nil;
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.McName1 forSDMPropertyWithName:@"McName1" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.McName2 forSDMPropertyWithName:@"McName2" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Namemiddle forSDMPropertyWithName:@"Namemiddle" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Partner forSDMPropertyWithName:@"Partner" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Partnertype forSDMPropertyWithName:@"Partnertype" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Firma forSDMPropertyWithName:@"Firma" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.FirmaName1 forSDMPropertyWithName:@"FirmaName1" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.FirmaName2 forSDMPropertyWithName:@"FirmaName2" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IsMaster forSDMPropertyWithName:@"IsMaster" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Mobile forSDMPropertyWithName:@"Mobile" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Email forSDMPropertyWithName:@"Email" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Tckno forSDMPropertyWithName:@"Tckno" error:&innerError];
    	[BaseODataObject setDecimalValueForSDMEntry:m_SDMEntry withValue:self.Garentatl forSDMPropertyWithName:@"Garentatl" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Smsflag forSDMPropertyWithName:@"Smsflag" error:&innerError];
        if (innerError) {
            if (error) {
                *error = innerError;
            }
            return nil;
        }
	}
    return m_SDMEntry;
}

+ (void)loadEntitySchema:(ODataServiceDocument *)aService
{
    ODataCollection *collectionSchema = [aService.schema getCollectionByName:@"ET_PARTNERSSet" workspaceOfCollection:nil];
    eT_PARTNERSEntitySchema = collectionSchema.entitySchema;
}

+ (void)loadLabels:(ODataServiceDocument *)aService
{
    NSMutableDictionary *properties = [BaseODataObject getSchemaPropertiesFromCollection:@"ET_PARTNERSSet" andService:aService];
    if (properties) {
        eT_PARTNERSLabels = [@{} mutableCopy];
        for (ODataPropertyInfo *property in [properties allValues]) {
            eT_PARTNERSLabels[property.name] = property.label;;
        }
    }
    else {
        LOGERROR(@"Failed to load SAP labels from service metadata");
    }
}


+ (NSString *)getLabelForProperty:(NSString *)aPropertyName
{
    return [BaseODataObject getLabelFromDictionary:eT_PARTNERSLabels forProperty:aPropertyName];
}

- (void)loadProperties
{
    [super loadProperties];
	self.McName1 = [self getStringValueForSDMPropertyWithName:@"McName1"];
	self.McName2 = [self getStringValueForSDMPropertyWithName:@"McName2"];
	self.Namemiddle = [self getStringValueForSDMPropertyWithName:@"Namemiddle"];
	self.Partner = [self getStringValueForSDMPropertyWithName:@"Partner"];
	self.Partnertype = [self getStringValueForSDMPropertyWithName:@"Partnertype"];
	self.Firma = [self getStringValueForSDMPropertyWithName:@"Firma"];
	self.FirmaName1 = [self getStringValueForSDMPropertyWithName:@"FirmaName1"];
	self.FirmaName2 = [self getStringValueForSDMPropertyWithName:@"FirmaName2"];
	self.IsMaster = [self getStringValueForSDMPropertyWithName:@"IsMaster"];
	self.Mobile = [self getStringValueForSDMPropertyWithName:@"Mobile"];
	self.Email = [self getStringValueForSDMPropertyWithName:@"Email"];
	self.Tckno = [self getStringValueForSDMPropertyWithName:@"Tckno"];
	self.Garentatl = [self getDecimalValueForSDMPropertyWithName:@"Garentatl"];
	self.Smsflag = [self getStringValueForSDMPropertyWithName:@"Smsflag"];
}

+ (NSMutableArray *)createET_PARTNERSEntriesForSDMEntries:(NSMutableArray *)sdmEntries
{
    NSMutableArray *entries = [@[] mutableCopy];
    for (ODataEntry *entry in sdmEntries) {
        ET_PARTNERSV0 *eT_PARTNERSObject = [[ET_PARTNERSV0 alloc] initWithSDMEntry:entry];
        [entries addObject:eT_PARTNERSObject];
    }
    return entries;
}


+ (NSMutableArray *)parseET_PARTNERSEntriesWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getSDMEntriesForEntitySchema:eT_PARTNERSEntitySchema andData:aData error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_PARTNERSV0 createET_PARTNERSEntriesForSDMEntries:sdmEntries];
}

+ (NSMutableArray *)parseExpandedET_PARTNERSEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_PARTNERSEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_PARTNERSV0 createET_PARTNERSEntriesForSDMEntries:sdmEntries];
}

+ (ET_PARTNERSV0 *)parseET_PARTNERSEntryWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *eT_PARTNERSEntries = [ET_PARTNERSV0 parseET_PARTNERSEntriesWithData:aData error:error];
    if (!eT_PARTNERSEntries) {
    	return nil;
    }
    return (ET_PARTNERSV0 *)[ET_PARTNERSV0 getFirstObjectFromArray:eT_PARTNERSEntries];
}

+ (ET_PARTNERSV0 *)parseExpandedET_PARTNERSEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
	NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_PARTNERSEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    NSMutableArray *eT_PARTNERSEntries = [ET_PARTNERSV0 createET_PARTNERSEntriesForSDMEntries:sdmEntries];
	return (ET_PARTNERSV0 *)[ET_PARTNERSV0 getFirstObjectFromArray:eT_PARTNERSEntries];
}



@end

#pragma mark - ET_LOGRETURNV0
@implementation ET_LOGRETURNV0

static NSMutableDictionary *eT_LOGRETURNLabels = nil;
static ODataEntitySchema *eT_LOGRETURNEntitySchema = nil;

- (id)init
{
    self = [super init];
    if (self) {
        m_SDMEntry = [BaseEntityType createEmptyODataEntryWithSchema:eT_LOGRETURNEntitySchema error:nil];
        if (!m_SDMEntry) {
            return nil;
        }
        m_properties = nil;
        self.baseUrl = nil;
    }
    return self;
}



- (ODataEntry *)buildSDMEntryFromPropertiesAndReturnError:(NSError **)error
{
    if (m_SDMEntry) {
        NSError *innerError = nil;
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Type forSDMPropertyWithName:@"Type" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Id forSDMPropertyWithName:@"Id" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Number forSDMPropertyWithName:@"Number" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Message forSDMPropertyWithName:@"Message" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.LogNo forSDMPropertyWithName:@"LogNo" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.LogMsgNo forSDMPropertyWithName:@"LogMsgNo" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.MessageV1 forSDMPropertyWithName:@"MessageV1" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.MessageV2 forSDMPropertyWithName:@"MessageV2" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.MessageV3 forSDMPropertyWithName:@"MessageV3" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.MessageV4 forSDMPropertyWithName:@"MessageV4" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Parameter forSDMPropertyWithName:@"Parameter" error:&innerError];
    	[BaseODataObject setIntValueForSDMEntry:m_SDMEntry withValue:self.Row forSDMPropertyWithName:@"Row" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.Field forSDMPropertyWithName:@"Field" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.System forSDMPropertyWithName:@"System" error:&innerError];
        if (innerError) {
            if (error) {
                *error = innerError;
            }
            return nil;
        }
	}
    return m_SDMEntry;
}

+ (void)loadEntitySchema:(ODataServiceDocument *)aService
{
    ODataCollection *collectionSchema = [aService.schema getCollectionByName:@"ET_RETURNSet" workspaceOfCollection:nil];
    eT_LOGRETURNEntitySchema = collectionSchema.entitySchema;
}

+ (void)loadLabels:(ODataServiceDocument *)aService
{
    NSMutableDictionary *properties = [BaseODataObject getSchemaPropertiesFromCollection:@"ET_RETURNSet" andService:aService];
    if (properties) {
        eT_LOGRETURNLabels = [@{} mutableCopy];
        for (ODataPropertyInfo *property in [properties allValues]) {
            eT_LOGRETURNLabels[property.name] = property.label;;
        }
    }
    else {
        LOGERROR(@"Failed to load SAP labels from service metadata");
    }
}


+ (NSString *)getLabelForProperty:(NSString *)aPropertyName
{
    return [BaseODataObject getLabelFromDictionary:eT_LOGRETURNLabels forProperty:aPropertyName];
}

- (void)loadProperties
{
    [super loadProperties];
	self.Type = [self getStringValueForSDMPropertyWithName:@"Type"];
	self.Id = [self getStringValueForSDMPropertyWithName:@"Id"];
	self.Number = [self getStringValueForSDMPropertyWithName:@"Number"];
	self.Message = [self getStringValueForSDMPropertyWithName:@"Message"];
	self.LogNo = [self getStringValueForSDMPropertyWithName:@"LogNo"];
	self.LogMsgNo = [self getStringValueForSDMPropertyWithName:@"LogMsgNo"];
	self.MessageV1 = [self getStringValueForSDMPropertyWithName:@"MessageV1"];
	self.MessageV2 = [self getStringValueForSDMPropertyWithName:@"MessageV2"];
	self.MessageV3 = [self getStringValueForSDMPropertyWithName:@"MessageV3"];
	self.MessageV4 = [self getStringValueForSDMPropertyWithName:@"MessageV4"];
	self.Parameter = [self getStringValueForSDMPropertyWithName:@"Parameter"];
	self.Row = [self getIntValueForSDMPropertyWithName:@"Row"];
	self.Field = [self getStringValueForSDMPropertyWithName:@"Field"];
	self.System = [self getStringValueForSDMPropertyWithName:@"System"];
}

+ (NSMutableArray *)createET_LOGRETURNEntriesForSDMEntries:(NSMutableArray *)sdmEntries
{
    NSMutableArray *entries = [@[] mutableCopy];
    for (ODataEntry *entry in sdmEntries) {
        ET_LOGRETURNV0 *eT_LOGRETURNObject = [[ET_LOGRETURNV0 alloc] initWithSDMEntry:entry];
        [entries addObject:eT_LOGRETURNObject];
    }
    return entries;
}


+ (NSMutableArray *)parseET_LOGRETURNEntriesWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getSDMEntriesForEntitySchema:eT_LOGRETURNEntitySchema andData:aData error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_LOGRETURNV0 createET_LOGRETURNEntriesForSDMEntries:sdmEntries];
}

+ (NSMutableArray *)parseExpandedET_LOGRETURNEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_LOGRETURNEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [ET_LOGRETURNV0 createET_LOGRETURNEntriesForSDMEntries:sdmEntries];
}

+ (ET_LOGRETURNV0 *)parseET_LOGRETURNEntryWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *eT_LOGRETURNEntries = [ET_LOGRETURNV0 parseET_LOGRETURNEntriesWithData:aData error:error];
    if (!eT_LOGRETURNEntries) {
    	return nil;
    }
    return (ET_LOGRETURNV0 *)[ET_LOGRETURNV0 getFirstObjectFromArray:eT_LOGRETURNEntries];
}

+ (ET_LOGRETURNV0 *)parseExpandedET_LOGRETURNEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
	NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:eT_LOGRETURNEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    NSMutableArray *eT_LOGRETURNEntries = [ET_LOGRETURNV0 createET_LOGRETURNEntriesForSDMEntries:sdmEntries];
	return (ET_LOGRETURNV0 *)[ET_LOGRETURNV0 getFirstObjectFromArray:eT_LOGRETURNEntries];
}



@end

#pragma mark - LoginServiceV0
@implementation LoginServiceV0

static NSMutableDictionary *loginServiceLabels = nil;
static ODataEntitySchema *loginServiceEntitySchema = nil;

- (id)init
{
    self = [super init];
    if (self) {
        m_SDMEntry = [BaseEntityType createEmptyODataEntryWithSchema:loginServiceEntitySchema error:nil];
        if (!m_SDMEntry) {
            return nil;
        }
        m_properties = nil;
        self.baseUrl = nil;
    }
    return self;
}

- (NSMutableDictionary *)getSDMEntriesForNavigationProperties
{
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    if ([self.ET_CARDTYPESSet count] > 0) {
    	dictionary[@"ET_CARDTYPESSet"] = [self createSDMEntriesForNavigationPropertyEntries:self.ET_CARDTYPESSet];
    }
    if ([self.ET_PARTNERSSet count] > 0) {
    	dictionary[@"ET_PARTNERSSet"] = [self createSDMEntriesForNavigationPropertyEntries:self.ET_PARTNERSSet];
    }
    if ([self.ET_RETURNSet count] > 0) {
    	dictionary[@"ET_RETURNSet"] = [self createSDMEntriesForNavigationPropertyEntries:self.ET_RETURNSet];
    }
    return dictionary;
}


- (ODataEntry *)buildSDMEntryFromPropertiesAndReturnError:(NSError **)error
{
    if (m_SDMEntry) {
        NSError *innerError = nil;
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvEmail forSDMPropertyWithName:@"IvEmail" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvFreetext forSDMPropertyWithName:@"IvFreetext" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvLangu forSDMPropertyWithName:@"IvLangu" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvMobile forSDMPropertyWithName:@"IvMobile" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvNickname forSDMPropertyWithName:@"IvNickname" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvPartner forSDMPropertyWithName:@"IvPartner" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvPassword forSDMPropertyWithName:@"IvPassword" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvSadakat forSDMPropertyWithName:@"IvSadakat" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvSyuname forSDMPropertyWithName:@"IvSyuname" error:&innerError];
    	[BaseODataObject setStringValueForSDMEntry:m_SDMEntry withValue:self.IvTckno forSDMPropertyWithName:@"IvTckno" error:&innerError];
    	[BaseODataObject setIntValueForSDMEntry:m_SDMEntry withValue:self.EvSubrc forSDMPropertyWithName:@"EvSubrc" error:&innerError];
        [self addRelativeLinksToSDMEntryFromDictionary:[self getSDMEntriesForNavigationProperties]];
        if (innerError) {
            if (error) {
                *error = innerError;
            }
            return nil;
        }
	}
    return m_SDMEntry;
}

+ (void)loadEntitySchema:(ODataServiceDocument *)aService
{
    ODataCollection *collectionSchema = [aService.schema getCollectionByName:@"LoginServiceSet" workspaceOfCollection:nil];
    loginServiceEntitySchema = collectionSchema.entitySchema;
}

+ (void)loadLabels:(ODataServiceDocument *)aService
{
    NSMutableDictionary *properties = [BaseODataObject getSchemaPropertiesFromCollection:@"LoginServiceSet" andService:aService];
    if (properties) {
        loginServiceLabels = [@{} mutableCopy];
        for (ODataPropertyInfo *property in [properties allValues]) {
            loginServiceLabels[property.name] = property.label;;
        }
    }
    else {
        LOGERROR(@"Failed to load SAP labels from service metadata");
    }
}


+ (NSString *)getLabelForProperty:(NSString *)aPropertyName
{
    return [BaseODataObject getLabelFromDictionary:loginServiceLabels forProperty:aPropertyName];
}

- (void)loadProperties
{
    [super loadProperties];
	self.IvEmail = [self getStringValueForSDMPropertyWithName:@"IvEmail"];
	self.IvFreetext = [self getStringValueForSDMPropertyWithName:@"IvFreetext"];
	self.IvLangu = [self getStringValueForSDMPropertyWithName:@"IvLangu"];
	self.IvMobile = [self getStringValueForSDMPropertyWithName:@"IvMobile"];
	self.IvNickname = [self getStringValueForSDMPropertyWithName:@"IvNickname"];
	self.IvPartner = [self getStringValueForSDMPropertyWithName:@"IvPartner"];
	self.IvPassword = [self getStringValueForSDMPropertyWithName:@"IvPassword"];
	self.IvSadakat = [self getStringValueForSDMPropertyWithName:@"IvSadakat"];
	self.IvSyuname = [self getStringValueForSDMPropertyWithName:@"IvSyuname"];
	self.IvTckno = [self getStringValueForSDMPropertyWithName:@"IvTckno"];
	self.EvSubrc = [self getIntValueForSDMPropertyWithName:@"EvSubrc"];
}

- (void)loadNavigationPropertyQueries
{
    [super loadNavigationPropertyQueries];
    self.ET_CARDTYPESSetQuery = [self getRelatedLinkForNavigationName:@"ET_CARDTYPESSet"];
    self.ET_PARTNERSSetQuery = [self getRelatedLinkForNavigationName:@"ET_PARTNERSSet"];
    self.ET_RETURNSetQuery = [self getRelatedLinkForNavigationName:@"ET_RETURNSet"];
}

- (void)loadNavigationPropertyData
{
    [super loadNavigationPropertyData];
    
    NSMutableArray *entries = nil;
    
    entries = [self getInlinedRelatedEntriesForNavigationName:@"ET_CARDTYPESSet"];
    self.ET_CARDTYPESSet = [ET_CARDTYPESV0 createET_CARDTYPESEntriesForSDMEntries:entries];
    
    entries = [self getInlinedRelatedEntriesForNavigationName:@"ET_PARTNERSSet"];
    self.ET_PARTNERSSet = [ET_PARTNERSV0 createET_PARTNERSEntriesForSDMEntries:entries];
    
    entries = [self getInlinedRelatedEntriesForNavigationName:@"ET_RETURNSet"];
    self.ET_RETURNSet = [ET_LOGRETURNV0 createET_LOGRETURNEntriesForSDMEntries:entries];
    
}

+ (NSMutableArray *)createLoginServiceEntriesForSDMEntries:(NSMutableArray *)sdmEntries
{
    NSMutableArray *entries = [@[] mutableCopy];
    for (ODataEntry *entry in sdmEntries) {
        LoginServiceV0 *loginServiceObject = [[LoginServiceV0 alloc] initWithSDMEntry:entry];
        [entries addObject:loginServiceObject];
    }
    return entries;
}


+ (NSMutableArray *)parseLoginServiceEntriesWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getSDMEntriesForEntitySchema:loginServiceEntitySchema andData:aData error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [LoginServiceV0 createLoginServiceEntriesForSDMEntries:sdmEntries];
}

+ (NSMutableArray *)parseExpandedLoginServiceEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
    NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:loginServiceEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    if (!sdmEntries) {
    	return nil;
    }
	return [LoginServiceV0 createLoginServiceEntriesForSDMEntries:sdmEntries];
}

+ (LoginServiceV0 *)parseLoginServiceEntryWithData:(NSData *)aData error:(NSError **)error
{
    NSMutableArray *loginServiceEntries = [LoginServiceV0 parseLoginServiceEntriesWithData:aData error:error];
    if (!loginServiceEntries) {
    	return nil;
    }
    return (LoginServiceV0 *)[LoginServiceV0 getFirstObjectFromArray:loginServiceEntries];
}

+ (LoginServiceV0 *)parseExpandedLoginServiceEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError **)error
{
	NSMutableArray *sdmEntries = [BaseEntityType getExpandedSDMEntriesForEntitySchema:loginServiceEntitySchema andData:aData andServiceDocument:aServiceDocument error:error];
    NSMutableArray *loginServiceEntries = [LoginServiceV0 createLoginServiceEntriesForSDMEntries:sdmEntries];
	return (LoginServiceV0 *)[LoginServiceV0 getFirstObjectFromArray:loginServiceEntries];
}



#pragma mark Entity Navigation Property loading methods
    - (BOOL)loadET_CARDTYPESSetWithData:(NSData *)aData error:(NSError **)error
    {
        self.ET_CARDTYPESSet = [ET_CARDTYPESV0 parseET_CARDTYPESEntriesWithData:aData error:error];
        if (!self.ET_CARDTYPESSet) {
            return NO;
        }
        return YES;
    }
    
    - (BOOL)loadET_PARTNERSSetWithData:(NSData *)aData error:(NSError **)error
    {
        self.ET_PARTNERSSet = [ET_PARTNERSV0 parseET_PARTNERSEntriesWithData:aData error:error];
        if (!self.ET_PARTNERSSet) {
            return NO;
        }
        return YES;
    }
    
    - (BOOL)loadET_RETURNSetWithData:(NSData *)aData error:(NSError **)error
    {
        self.ET_RETURNSet = [ET_LOGRETURNV0 parseET_LOGRETURNEntriesWithData:aData error:error];
        if (!self.ET_RETURNSet) {
            return NO;
        }
        return YES;
    }
    
    
    @end
    
    
#pragma mark - ZGARENTA_LOGIN_SRV_01V0 Service Proxy
    
    
    @implementation ZGARENTA_LOGIN_SRV_01ServiceV0
    
    - (NSString *)getServiceDocumentFilename
    {
        return ZGARENTA_LOGIN_SRV_01_SERVICE_DOCUMENTV0;
    }
    
    - (NSString *)getServiceMetadataFilename
    {
        return ZGARENTA_LOGIN_SRV_01_SERVICE_METADATAV0;
    }
    
    - (void)loadEntitySetQueries
    {
        [super loadEntitySetQueries];
        self.ET_CARDTYPESSetQuery = [self getQueryForRelativePath:@"ET_CARDTYPESSet"];
        self.ET_PARTNERSSetQuery = [self getQueryForRelativePath:@"ET_PARTNERSSet"];
        self.ET_RETURNSetQuery = [self getQueryForRelativePath:@"ET_RETURNSet"];
        self.LoginServiceSetQuery = [self getQueryForRelativePath:@"LoginServiceSet"];
    }
    
    - (void)loadEntitySchemaForAllEntityTypes
    {
        [super loadEntitySchemaForAllEntityTypes];
        [ET_CARDTYPESV0 loadEntitySchema:self.sdmServiceDocument];
        [ET_PARTNERSV0 loadEntitySchema:self.sdmServiceDocument];
        [ET_LOGRETURNV0 loadEntitySchema:self.sdmServiceDocument];
        [LoginServiceV0 loadEntitySchema:self.sdmServiceDocument];
    }
    
    - (void)loadLabels
    {
        [super loadLabels];
        [ET_CARDTYPESV0 loadLabels:self.sdmServiceDocument];
        [ET_PARTNERSV0 loadLabels:self.sdmServiceDocument];
        [ET_LOGRETURNV0 loadLabels:self.sdmServiceDocument];
        [LoginServiceV0 loadLabels:self.sdmServiceDocument];
    }
    
    
#pragma mark Service Entity Set methods
    - (NSMutableArray *)getET_CARDTYPESSetWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_CARDTYPESV0 parseExpandedET_CARDTYPESEntriesWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (ODataQuery *)getET_CARDTYPESSetEntryQueryWithPartner:(NSString *)Partner
    {
        Partner = [ODataQuery encodeURLParameter:Partner];
        NSString *relativePath = [NSString stringWithFormat:@"ET_CARDTYPESSet(Partner=%@)", Partner];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ODataQuery *)getET_CARDTYPESSetEntryQueryTypedWithPartner:(NSString *)Partner
    {
        id <URITypeConverting> converter = [ODataURITypeConverter uniqueInstance];
        NSString *PartnerUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Partner]];
        NSString *relativePath = [NSString stringWithFormat:@"ET_CARDTYPESSet(Partner=%@)", PartnerUri];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ET_CARDTYPESV0 *)getET_CARDTYPESSetEntryWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_CARDTYPESV0 parseExpandedET_CARDTYPESEntryWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (NSMutableArray *)getET_PARTNERSSetWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_PARTNERSV0 parseExpandedET_PARTNERSEntriesWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (ODataQuery *)getET_PARTNERSSetEntryQueryWithPartner:(NSString *)Partner andPartnertype:(NSString *)Partnertype andTckno:(NSString *)Tckno
    {
        Partner = [ODataQuery encodeURLParameter:Partner];
        Partnertype = [ODataQuery encodeURLParameter:Partnertype];
        Tckno = [ODataQuery encodeURLParameter:Tckno];
        NSString *relativePath = [NSString stringWithFormat:@"ET_PARTNERSSet(Partner=%@,Partnertype=%@,Tckno=%@)", Partner, Partnertype, Tckno];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ODataQuery *)getET_PARTNERSSetEntryQueryTypedWithPartner:(NSString *)Partner andPartnertype:(NSString *)Partnertype andTckno:(NSString *)Tckno
    {
        id <URITypeConverting> converter = [ODataURITypeConverter uniqueInstance];
        NSString *PartnerUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Partner]];
        NSString *PartnertypeUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Partnertype]];
        NSString *TcknoUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Tckno]];
        NSString *relativePath = [NSString stringWithFormat:@"ET_PARTNERSSet(Partner=%@,Partnertype=%@,Tckno=%@)", PartnerUri, PartnertypeUri, TcknoUri];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ET_PARTNERSV0 *)getET_PARTNERSSetEntryWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_PARTNERSV0 parseExpandedET_PARTNERSEntryWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (NSMutableArray *)getET_RETURNSetWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_LOGRETURNV0 parseExpandedET_LOGRETURNEntriesWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (ODataQuery *)getET_RETURNSetEntryQueryWithType:(NSString *)Type andId:(NSString *)Id andNumber:(NSString *)Number
    {
        Type = [ODataQuery encodeURLParameter:Type];
        Id = [ODataQuery encodeURLParameter:Id];
        Number = [ODataQuery encodeURLParameter:Number];
        NSString *relativePath = [NSString stringWithFormat:@"ET_RETURNSet(Type=%@,Id=%@,Number=%@)", Type, Id, Number];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ODataQuery *)getET_RETURNSetEntryQueryTypedWithType:(NSString *)Type andId:(NSString *)Id andNumber:(NSString *)Number
    {
        id <URITypeConverting> converter = [ODataURITypeConverter uniqueInstance];
        NSString *TypeUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Type]];
        NSString *IdUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Id]];
        NSString *NumberUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:Number]];
        NSString *relativePath = [NSString stringWithFormat:@"ET_RETURNSet(Type=%@,Id=%@,Number=%@)", TypeUri, IdUri, NumberUri];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ET_LOGRETURNV0 *)getET_RETURNSetEntryWithData:(NSData *)aData error:(NSError **)error
    {
        return [ET_LOGRETURNV0 parseExpandedET_LOGRETURNEntryWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (NSMutableArray *)getLoginServiceSetWithData:(NSData *)aData error:(NSError **)error
    {
        return [LoginServiceV0 parseExpandedLoginServiceEntriesWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    - (ODataQuery *)getLoginServiceSetEntryQueryWithIvFreetext:(NSString *)IvFreetext andIvPassword:(NSString *)IvPassword
    {
        IvFreetext = [ODataQuery encodeURLParameter:IvFreetext];
        IvPassword = [ODataQuery encodeURLParameter:IvPassword];
        NSString *relativePath = [NSString stringWithFormat:@"LoginServiceSet(IvFreetext=%@,IvPassword=%@)", IvFreetext, IvPassword];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (ODataQuery *)getLoginServiceSetEntryQueryTypedWithIvFreetext:(NSString *)IvFreetext andIvPassword:(NSString *)IvPassword
    {
        id <URITypeConverting> converter = [ODataURITypeConverter uniqueInstance];
        NSString *IvFreetextUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:IvFreetext]];
        NSString *IvPasswordUri = [ODataQuery encodeURLParameter:[converter convertToEdmStringURI:IvPassword]];
        NSString *relativePath = [NSString stringWithFormat:@"LoginServiceSet(IvFreetext=%@,IvPassword=%@)", IvFreetextUri, IvPasswordUri];
        ODataQuery *query = [self getQueryForRelativePath:relativePath];
        return query;
    }
    
    - (LoginServiceV0 *)getLoginServiceSetEntryWithData:(NSData *)aData error:(NSError **)error
    {
        return [LoginServiceV0 parseExpandedLoginServiceEntryWithData:aData andServiceDocument:self.sdmServiceDocument error:error];
    }
    
    
    
#pragma mark Service Function Import methods 
    
    @end
