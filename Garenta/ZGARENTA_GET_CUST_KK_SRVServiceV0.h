/*
 
 Auto-Generated by SAP NetWeaver Gateway Productivity Accelerator, Version 1.1.1
 
 File: ZGARENTA_GET_CUST_KK_SRVServiceV0.h
 Abstract: The generated proxy classes for the ZGARENTA_GET_CUST_KK_SRV Service.   
*/

#import <Foundation/Foundation.h>
#import "BaseEntityType.h"
#import "BaseComplexType.h"
#import "BaseServiceObject.h"

#pragma mark - Complex Types



#pragma mark - Entity Types

/**
 Each of the following classes represents an entity-type of the ZGARENTA_GET_CUST_KK_SRVServiceV0 service.
 
 Any entity-type class should be used as following:
 
 1. The entity object may represent an existing entry of an appropriate service collection,
 if the object is initialized using data returned from an appropriate service call.
 This may be achieved by using the initWithSDMEntry: constructor,
 or using the static methods creating the entity object (parse<entity-type-name>EntriesWithData,
 parse<entity-type-name>EntryWithData, and create<entity-type-name>EntriesForSDMEntries).
 
 For retrieving the entry data, use the appropriate query properties and methods of this class 
 and of the ZGARENTA_GET_CUST_KK_SRVServiceV0 class, and then execute the request (see the SDMConnectivityHelper class).
 
 2. Another option is to use this entity object as a new entry to create in an appropriate service collection.
 In this case, use the init constructor and set the appropriate properties. 
 Note that some features (as navigation properties) are not available in this mode (since it is not yet an actual service entry).
 Use the SDMConnectivityHelper class and the getXMLForCreateRequest method of the BaseServiceObject class, to send the 'create' request.
 Then use the service response for constructing a new object, in order to represent the entry as existed in the service. 
 
 In both operation modes, setting the entity property values will not affect the service until the changes are sent to the server.
 For sending changes to the server, see the SDMConnectivityHelper class and the getXMLForRequest methods of the BaseServiceObject class.
 It is recommended to use the server response for constructing a new object, in order to represent the entry as existed in the service.
 
 Note: For proper behavior of this class, make sure to initialize the ZGARENTA_GET_CUST_KK_SRVServiceV0 class
 in your application, before initializing the entity-type class objects.
*/
 

#pragma mark - CustKKServiceV0
@interface CustKKServiceV0 : BaseEntityType 

@property (strong, nonatomic) NSString *IKunnr; ///< Customer - Edm.String
@property (strong, nonatomic) NSString *EReturn; ///< Single-Character Flag - Edm.String
#pragma mark Entity Navigation Properties
@property (strong, nonatomic) ODataQuery *ET_CARDSSetQuery;
@property (strong, nonatomic) NSMutableArray *ET_CARDSSet;

#pragma mark Static Methods
/**
 Static method that returns an array of CustKKServiceV0 entities from the provided data.
 @param aData The NSData containing an Atom Feed including the entries to be parsed to CustKKServiceV0 entities.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of CustKKServiceV0 entities. Returns nil if the data in invalid.
*/
+ (NSMutableArray *)parseCustKKServiceEntriesWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Static method that returns an array of CustKKServiceV0 entities and their related entities from the provided data.
 @param aData The NSData containing an Atom Feed including the entries to be parsed to CustKKServiceV0 entities.
 @param aServiceDocument The ODataServiceDocument that represents the service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of CustKKServiceV0 entities. Returns nil if the data in invalid.
*/
+ (NSMutableArray *)parseExpandedCustKKServiceEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError * __autoreleasing *)error;

/**
 Returns a single CustKKServiceV0 entity from the provided data.
 @param aData The NSData containing an Atom Entry including the entry to be parsed to a CustKKServiceV0 entity.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a CustKKServiceV0 entity. Returns nil if the data in invalid.
*/
+ (CustKKServiceV0 *)parseCustKKServiceEntryWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Returns a single CustKKServiceV0 entity and related entities from the provided data.
 @param aData The NSData containing an Atom Entry including the entry and its related entries to be parsed to a CustKKServiceV0 entity.
 @param aServiceDocument The ODataServiceDocument that represents the service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a CustKKServiceV0 entity. Returns nil if the data in invalid.
*/
+ (CustKKServiceV0 *)parseExpandedCustKKServiceEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError * __autoreleasing *)error;

/**
 Static method that returns an array of CustKKServiceV0 objects from a given array of ODataEntry objects.
 @param sdmEntries Array of ODataEntry objects.
 @return Array of CustKKServiceV0 objects.
*/
+ (NSMutableArray *)createCustKKServiceEntriesForSDMEntries:(NSMutableArray *)sdmEntries;

/**
 Static method that loads the entity schema of this type.
 This method is called when the ZGARENTA_GET_CUST_KK_SRVServiceV0 class is initialized.
 @param aService Service document object containing all of the entity type properties.
*/
+ (void)loadEntitySchema:(ODataServiceDocument *)aService;

/**
 Static method that loads all of the entity type property labels.
 This method is called when the ZGARENTA_GET_CUST_KK_SRVServiceV0 class is initialized.
 @param aService Service document object containing all of the entity type properties.
*/
+ (void)loadLabels:(ODataServiceDocument *)aService;

/**
 Static method that returns the label for a given property name.
 @param aPropertyName Property name.
 @return Property label.
*/
+ (NSString *)getLabelForProperty:(NSString *)aPropertyName;


#pragma mark Entity Navigation Property loading methods
/**
 Navigation property. Loads ET_CARDSSet details for this entity from the provided data.
 @param aData The NSData containing the ET_CARDSSet information to be parsed.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns YES if the method completed successfully.
*/
- (BOOL)loadET_CARDSSetWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;


@end

#pragma mark - ET_CARDSV0
@interface ET_CARDSV0 : BaseEntityType 

@property (strong, nonatomic) NSString *UniqueId; ///< c - Edm.String
@property (strong, nonatomic) NSString *Kartno; ///< Field of length 16 - Edm.String

#pragma mark Static Methods
/**
 Static method that returns an array of ET_CARDSV0 entities from the provided data.
 @param aData The NSData containing an Atom Feed including the entries to be parsed to ET_CARDSV0 entities.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of ET_CARDSV0 entities. Returns nil if the data in invalid.
*/
+ (NSMutableArray *)parseET_CARDSEntriesWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Static method that returns an array of ET_CARDSV0 entities and their related entities from the provided data.
 @param aData The NSData containing an Atom Feed including the entries to be parsed to ET_CARDSV0 entities.
 @param aServiceDocument The ODataServiceDocument that represents the service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of ET_CARDSV0 entities. Returns nil if the data in invalid.
*/
+ (NSMutableArray *)parseExpandedET_CARDSEntriesWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError * __autoreleasing *)error;

/**
 Returns a single ET_CARDSV0 entity from the provided data.
 @param aData The NSData containing an Atom Entry including the entry to be parsed to a ET_CARDSV0 entity.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a ET_CARDSV0 entity. Returns nil if the data in invalid.
*/
+ (ET_CARDSV0 *)parseET_CARDSEntryWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Returns a single ET_CARDSV0 entity and related entities from the provided data.
 @param aData The NSData containing an Atom Entry including the entry and its related entries to be parsed to a ET_CARDSV0 entity.
 @param aServiceDocument The ODataServiceDocument that represents the service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a ET_CARDSV0 entity. Returns nil if the data in invalid.
*/
+ (ET_CARDSV0 *)parseExpandedET_CARDSEntryWithData:(NSData *)aData andServiceDocument:(ODataServiceDocument *)aServiceDocument error:(NSError * __autoreleasing *)error;

/**
 Static method that returns an array of ET_CARDSV0 objects from a given array of ODataEntry objects.
 @param sdmEntries Array of ODataEntry objects.
 @return Array of ET_CARDSV0 objects.
*/
+ (NSMutableArray *)createET_CARDSEntriesForSDMEntries:(NSMutableArray *)sdmEntries;

/**
 Static method that loads the entity schema of this type.
 This method is called when the ZGARENTA_GET_CUST_KK_SRVServiceV0 class is initialized.
 @param aService Service document object containing all of the entity type properties.
*/
+ (void)loadEntitySchema:(ODataServiceDocument *)aService;

/**
 Static method that loads all of the entity type property labels.
 This method is called when the ZGARENTA_GET_CUST_KK_SRVServiceV0 class is initialized.
 @param aService Service document object containing all of the entity type properties.
*/
+ (void)loadLabels:(ODataServiceDocument *)aService;

/**
 Static method that returns the label for a given property name.
 @param aPropertyName Property name.
 @return Property label.
*/
+ (NSString *)getLabelForProperty:(NSString *)aPropertyName;



@end



#pragma mark - ZGARENTA_GET_CUST_KK_SRVV0 Service Proxy
@interface ZGARENTA_GET_CUST_KK_SRVServiceV0 : BaseServiceObject

#pragma mark Query properties for service Entity Sets
/**
The OData query for the CustKKService collection.
(Addressable true, Requires-filter false, Creatable true, Updatable true, Deletable true)
*/
@property (strong, nonatomic) ODataQuery *CustKKSetQuery;

/**
The OData query for the ET_CARDS collection.
(Addressable true, Requires-filter false, Creatable true, Updatable true, Deletable true)
*/
@property (strong, nonatomic) ODataQuery *ET_CARDSetQuery;


#pragma mark Service Entity Set methods
/**
 Returns a collection of CustKKServiceV0 entities from the data returned by the OData service.
 @param aData The NSData returned from the OData service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of CustKKServiceV0 entities.
*/
- (NSMutableArray *)getCustKKSetWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Returns the OData query for a specific CustKKServiceV0 entity.
 @param IKunnr Part of the CustKKServiceV0 unique identifier (of type Edm.String).
 Note: pass the parameter values exactly as they should appear in the query URL, 
 in the correct format according to their types 
 (for more information, see: http://www.odata.org/documentation/overview#AbstractTypeSystem).
 @return Returns an OData query object.
*/
- (ODataQuery *)getCustKKSetEntryQueryWithIKunnr:(NSString *)IKunnr;

/**
 Returns the OData query for a specific CustKKServiceV0 entity with typed parameters.
 Note: This method is relevant only for OData compliant services.
 @param IKunnr Part of the CustKKServiceV0 unique identifier (of type Edm.String).
 @return Returns an OData query object.
*/
- (ODataQuery *)getCustKKSetEntryQueryTypedWithIKunnr:(NSString *)IKunnr;

/**
 Returns a specific CustKKServiceV0 entity from the provided data.
 @param aData The NSData containing the CustKKServiceV0 information to be parsed to a CustKKServiceV0 entity.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a CustKKServiceV0 entity. Returns nil if the data in invalid.
*/
- (CustKKServiceV0 *)getCustKKSetEntryWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;
/**
 Returns a collection of ET_CARDSV0 entities from the data returned by the OData service.
 @param aData The NSData returned from the OData service.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns an array of ET_CARDSV0 entities.
*/
- (NSMutableArray *)getET_CARDSetWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Returns the OData query for a specific ET_CARDSV0 entity.
 @param UniqueId Part of the ET_CARDSV0 unique identifier (of type Edm.String).
 @param Kartno Part of the ET_CARDSV0 unique identifier (of type Edm.String).
 Note: pass the parameter values exactly as they should appear in the query URL, 
 in the correct format according to their types 
 (for more information, see: http://www.odata.org/documentation/overview#AbstractTypeSystem).
 @return Returns an OData query object.
*/
- (ODataQuery *)getET_CARDSetEntryQueryWithUniqueId:(NSString *)UniqueId andKartno:(NSString *)Kartno;

/**
 Returns the OData query for a specific ET_CARDSV0 entity with typed parameters.
 Note: This method is relevant only for OData compliant services.
 @param UniqueId Part of the ET_CARDSV0 unique identifier (of type Edm.String).
 @param Kartno Part of the ET_CARDSV0 unique identifier (of type Edm.String).
 @return Returns an OData query object.
*/
- (ODataQuery *)getET_CARDSetEntryQueryTypedWithUniqueId:(NSString *)UniqueId andKartno:(NSString *)Kartno;

/**
 Returns a specific ET_CARDSV0 entity from the provided data.
 @param aData The NSData containing the ET_CARDSV0 information to be parsed to a ET_CARDSV0 entity.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns a ET_CARDSV0 entity. Returns nil if the data in invalid.
*/
- (ET_CARDSV0 *)getET_CARDSetEntryWithData:(NSData *)aData error:(NSError * __autoreleasing *)error;


#pragma mark Service Function Import methods
@end