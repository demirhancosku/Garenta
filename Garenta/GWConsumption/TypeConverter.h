/*
 
 File: TypeConverter.h
 Abstract: OData primitive type converters.
  
 */

#import <Foundation/Foundation.h>
#import "ODataProperty.h"

/**
 Protocol for converting primitive types from native objects to string representation in URI notation (OData Literal form)
 */
@protocol URITypeConverting <NSObject>

/**
 Converts Edm.Binary value from NSMutableData object to URI representation as NSString object.
 @param value An NSMutableData representation of an Edm.Binary value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmBinaryURI:(NSMutableData *)value;

/**
 Converts Edm.Boolean value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Boolean value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmBooleanURI:(NSNumber *)value;

/**
 Converts Edm.Byte value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Byte value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmByteURI:(NSNumber *)value;

/**
 Converts Edm.SByte value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.SByte value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmSByteURI:(NSNumber *)value;

/**
 Converts Edm.Single value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Single value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmSingleURI:(NSNumber *)value;

/**
 Converts Edm.Double value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Double value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmDoubleURI:(NSNumber *)value;

/**
 Converts Edm.Int16 value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Int16 value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmInt16URI:(NSNumber *)value;

/**
 Converts Edm.Int32 value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Int32 value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmInt32URI:(NSNumber *)value;

/**
 Converts Edm.Int64 value from NSNumber object to URI representation as NSString object.
 @param value An NSNumber representation of an Edm.Int64 value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmInt64URI:(NSNumber *)value;

/**
 Converts Edm.Decimal value from NSDecimalNumber object to URI representation as NSString object.
 @param value An NSDecimalNumber representation of an Edm.Decimal value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmDecimalURI:(NSDecimalNumber *)value;

/**
 Converts Edm.String value from NSString object to URI representation as NSString object.
 @param value An NSString representation of an Edm.String value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmStringURI:(NSString *)value;

/**
 Converts Edm.DateTime value from NSDate object to URI representation as NSString object.
 @param value An NSDate representation of an Edm.DateTime value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmDateTimeURI:(NSDate *)value;

/**
 Converts Edm.DateTimeOffset value from NSString object to URI representation as NSString object.
 @param value An NSString representation of an Edm.DateTimeOffset value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmDateTimeOffsetURI:(NSString *)value;

/**
 Converts Edm.Time value from ODataDuration object to URI representation as NSString object.
 @param value An ODataDuration representation of an Edm.Time value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmTimeURI:(ODataDuration *)value;

/**
 Converts Edm.Guid value from NSString object to URI representation as NSString object.
 @param value An NSString representation of an Edm.Guid value.
 @return The URI representation of the given value as NSString object. 
 */
- (NSString *)convertToEdmGuidURI:(NSString *)value;

@end

/**
 Implementation of the URITypeConverting protocol for OData compliant services.
 Used for converting primitive types from native objects to string representation in OData URI notation (OData Literal form).
 For more information, see: http://www.odata.org/documentation/overview#AbstractTypeSystem
 */
@interface ODataURITypeConverter : NSObject <URITypeConverting> {
    NSLocale *decimalSeparatorLocale;
    NSDateFormatter *dateFormatter;
}

/**
 @return ODataURITypeConverter singleton instance.
 */
+ (ODataURITypeConverter *)uniqueInstance;


@end
