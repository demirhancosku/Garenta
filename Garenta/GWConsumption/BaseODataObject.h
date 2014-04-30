/*
  
 File: BaseODataObject.h
 Abstract: The base class for all OData classes which represent OData types. 
 
*/


#import <Foundation/Foundation.h>

// SAP OData Mobile SDK Imports
#import "ODataProperty.h"
#import "ODataEntry.h"
#import "ODataServiceDocument.h"

/**
 The base class for all OData classes which represent OData types.
*/
@interface BaseODataObject : NSObject{
    NSDictionary *m_properties;
}

/**
 Creates a new instance of the OData object class.
 @param aDictionary A dictionary containing the properties of the entity type.
 In the dictionary, the key is NSString, and the value is ODataPropertyValueObject
 or one of the derived classes (e.g. ODataPropertyValueString,
 ODataPropertyValueDateTime, ODataPropertyValueDecimal, etc.).
*/
- (id)initWithSDMDictionary:(NSDictionary *)aDictionary;

/**
 Returns a dictionary of all complex type properties.
 @param aPropertyName complex type property name.
 @return dictionary of the complex type's properties (key = property name, value = property value).
 */
- (NSDictionary *)getDictionaryForComplexTypeProperty:(NSString *)aPropertyName;

/**
 Returns an ODataPropertyValueObject for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return ODataPropertyValueObject the value of the requested property.
*/
- (ODataPropertyValueObject *)getValueForProperty:(NSString *)aPropertyName;

/**
 Returns an NSString value, representing a String value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSString value of the requested property.
*/
- (NSString *)getStringValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSDate value, representing a DateTime value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSDate value of the requested property.
*/
- (NSDate *)getDateTimeValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSDecimalNumber value, representing a Decimal value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSDecimalNumber value of the requested property.
*/
- (NSDecimalNumber *)getDecimalValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSNumber value, representing an Integer value (Byte, SByte, Int16, Int32, Int64), for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSNumber value of the requested property.
*/
- (NSNumber *)getIntValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSNumber value, representing a Boolean value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSNumber value of the requested property.
*/
- (NSNumber *)getBooleanValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSNumber value, representing a Single value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSNumber value of the requested property.
*/
- (NSNumber *)getSingleValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSNumber value, representing a Double value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSNumber value of the requested property.
*/
- (NSNumber *)getDoubleValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSString value, representing a String value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSString value of the requested property.
*/
- (NSString *)getGuidValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSString value, representing a DateTimeOffset value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSString value of the requested property.
*/
- (NSString *)getDateTimeOffsetValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an NSMutableData value, representing a Binary value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSMutableData value of the requested property.
*/
- (NSMutableData *)getBinaryValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Returns an ODataDuration value, representing a Binary value, for a given property name.
 @param aPropertyName The NSString key name of the desired property.
 @return The NSMutableData value of the requested property.
*/
- (ODataDuration *)getTimeValueForSDMPropertyWithName:(NSString *)aPropertyName;

/**
 Fills the OData object properties with data from the properties dictionary.
 @remark Called from the class initializers.
*/
- (void)loadProperties;

/**
 A static method that returns the ODataPropertyInfo dictionary for an OData object.
 @param aCollectionName The name of the collection the entity type belongs to.
 @param aSDMServiceDocument The service document object.
 @return Returns NSMutableDictionary.
*/
+ (NSMutableDictionary *)getSchemaPropertiesFromCollection:(NSString *)aCollectionName andService:(ODataServiceDocument *)aSDMServiceDocument;

/**
 A static method that returns the label value for a propery.
 @param aLabelDictionary The collection of labels for the object.
 @param aPropertyName The name of the property.
 @return Returns NSString with the label for the property.
*/
+ (NSString *)getLabelFromDictionary:(NSMutableDictionary *)aLabelDictionary forProperty:(NSString *)aPropertyName;

/**
 Static method that sets a given NSString value inside a String property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSString value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setStringValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSString *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSDate value inside a DateTime property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSDate value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setDateTimeValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSDate *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSDecimalNumber value inside a Decimal property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSDecimalNumber value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setDecimalValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSDecimalNumber *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSNumber value inside an Int property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSNumber value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setIntValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSNumber *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSNumber value inside a Boolean property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSNumber value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setBooleanValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSNumber *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSNumber value inside a Single property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSNumber value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setSingleValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSNumber *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSNumber value inside a Double property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSNumber value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setDoubleValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSNumber *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSString value inside a Guid property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSString value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setGuidValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSString *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSString value inside a DateTimeOffset property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSString value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setDateTimeOffsetValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSString *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given NSMutableData value inside a Binary property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The NSMutableData value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setBinaryValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(NSMutableData *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

/**
 Static method that sets a given ODataDuration value inside a Time property for the given ODataEntry 
 @param aSDMEntry The ODataEntry object that contains the property
 @param aValue The ODataDuration value that should be set in the property.
 @param aName NSString that represents the name of the property.
 @param error A pointer to an NSError object.
 @return Returns YES if the method completed successfully.
*/
+ (BOOL)setTimeValueForSDMEntry:(ODataEntry *)aSDMEntry withValue:(ODataDuration *)aValue forSDMPropertyWithName:(NSString *)aName error:(NSError * __autoreleasing *)error;

@end
