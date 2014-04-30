/*
 
 File: BaseServiceObject.h
 Abstract: The base class for the generated OData service class.
 
 */


#import <Foundation/Foundation.h>
#import "BaseODataObject.h"
#import "BaseEntityType.h"

/**
 The base class for the generated OData service class.
 */
@interface BaseServiceObject : NSObject

@property (nonatomic, strong, readonly) ODataServiceDocument *sdmServiceDocument; ///< The SDM service document object.
@property (nonatomic, strong, readonly, getter=getServiceDocumentQuery) ODataQuery *serviceDocumentQuery; ///< The OData query for the service document.

/**
 Creates a new instance of the service object with default parameters.
 Uses the service document and metadata files stored locally to generate the service proxy.
 */
- (id)init;

/**
 Creates a new instance of the service object with the provided parameters.
 @param aServiceDocument The NSData returned from calling the service document service.
 @param aMetadata The NSData returned from calling the $metadata of the service.
 */
- (id)initWithServiceDocument:(NSData *)aServiceDocument andMedatadata:(NSData *)aMetadata;

/**
 Used to get the service document file name for the service document
 xml file stored in the Resources folder of the project.
 @return Returns the default service document file name (ServiceDocument.xml).
 */
- (NSString *)getServiceDocumentFilename;

/**
 Used to get the service metadata file name for the metadata
 xml file stored in the Resources folder of the project.
 @return Returns the default metadata file name (ServiceMetadata.xml).
 */
- (NSString *)getServiceMetadataFilename;

/**
 Used to set the service document URL,
 used as a base URL for the proxy queries.
 @param baseUrl The URL of the service document
 */
- (void)setServiceDocumentUrl:(NSString *)baseUrl;

/**
 Used to get the service document query.
 @return Returns ODataQuery.
 */
- (ODataQuery *)getServiceDocumentQuery;

/**
 Abstract method (no implementation).
 Implemented by derived service objects.
 Loads the query object for each entity set.
 This method is called by the class initializers.
 */
- (void)loadEntitySetQueries;

/**
 Abstract method (no implementation).
 Implemented by derived service objects.
 Loads the entity schema for each entity type.
 This method is called by the class initializers.
 */
- (void)loadEntitySchemaForAllEntityTypes;

/**
 Abstract method (no implementation).
 Implemented by derived service objects.
 Loads the labels for each entity type.
 This method is called by the class initializers.
 */
- (void)loadLabels;

/**
 Used to get an OData query object.
 @param aRelativeResourcePath Relative path of the entity set (e.g. Products).
 @return Returns ODataQuery.
 */
- (ODataQuery *)getQueryForRelativePath:(NSString *)aRelativeResourcePath;

/**
 Returns the first object from a provided array of objects.
 @param array The array of objects.
 @return Returns BaseODataObject.
 @remark: Returns nil if the array contains no objects.
 */
- (BaseODataObject *)getFirstObjectFromArray:(NSArray *)array;

/**
 Returns an array of SDMEntries from a provided function import.
 @param aFunctionImportName The name of the function import.
 @param aData The NSData of the provided function import.
 @param error A pointer to an NSError object.
 @return Returns an array of SDMEntries.
 */
- (NSMutableArray *)getSDMEntriesForFunctionImportName:(NSString *)aFunctionImportName andData:(NSData *)aData error:(NSError * __autoreleasing *)error;

/**
 Returns an NSString value, representing a String value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSString value of the requested property.
 */
- (NSString *)getStringValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSDate value, representing a DateTime value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSDate value of the given entry.
 */
- (NSDate *)getDateTimeValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSDecimalNumber value, representing a Decimal value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSDecimalNumber value of the given entry.
 */
- (NSDecimalNumber *)getDecimalValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSNumber value, representing an Integer value (Byte, SByte, Int16, Int32, Int64), for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSNumber value of the given entry.
 */
- (NSNumber *)getIntValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSNumber value, representing a Boolean value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSNumber value of the given entry.
 */
- (NSNumber *)getBooleanValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSNumber value, representing a Single value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSNumber value of the given entry.
 */
- (NSNumber *)getSingleValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSNumber value, representing a Double value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSNumber value of the given entry.
 */
- (NSNumber *)getDoubleValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSString value, representing a String value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSString value of the given entry.
 */
- (NSString *)getGuidValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSString value, representing a DateTimeOffset value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSString value of the given entry.
 */
- (NSString *)getDateTimeOffsetValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an NSMutableData value, representing a Binary value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSMutableData value of the given entry.
 */
- (NSMutableData *)getBinaryValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns an ODataDuration value, representing a Binary value, for a given ODataEntry of function import response.
 @param anEntry The entry of the function import response.
 @return The NSMutableData value of the given entry.
 */
- (ODataDuration *)getTimeValueForFunctionImportSDMEntry:(ODataEntry *)anEntry;

/**
 Returns the XML representation of OData entity.
 @param anEntity The OData entity object.
 @param error a pointer to an NSError object.
 @return The XML representation of OData entity as a string.
 */
- (NSString *)getXMLForCreateRequest:(BaseEntityType *)anEntity error:(NSError * __autoreleasing *)error;

/**
 Returns the XML representation of OData entity.
 @param anEntity The OData entity object.
 @param error a pointer to an NSError object.
 @return The XML representation of OData entity as a string.
 */
- (NSString *)getXMLForUpdateRequest:(BaseEntityType *)anEntity error:(NSError * __autoreleasing *)error;


/**
 Returns the JSON representation of OData entity.
 @param anEntity The OData entity object.
 @param error a pointer to an NSError object.
 @return The JSON representation of OData entity as a string.
 */
- (NSString *)getJSONForCreateRequest:(BaseEntityType *)anEntity error:(NSError * __autoreleasing *)error;

/**
 Returns the JSON representation of OData entity.
 @param anEntity The OData entity object.
 @param error a pointer to an NSError object.
 @return The JSON representation of OData entity as a string.
 */
- (NSString *)getJSONForUpdateRequest:(BaseEntityType *)anEntity error:(NSError * __autoreleasing *)error;

@end
