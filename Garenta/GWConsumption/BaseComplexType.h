/*
 
 File: BaseComplexType.h
 Abstract: The base class for all OData complex types. Inherits from BaseODataObject.
  
 */


#import <Foundation/Foundation.h>
#import "BaseODataObject.h"

/**
 The base class for all OData complex types.
 */
@interface BaseComplexType : BaseODataObject

/**
 Method that populates all Complex properties in a given ODataEntry.
 The method knows how to find the path to each property inside the Complex Type 
 by receiving the name of the complex type property in the object that called
 this method.
 @param aSDMEntry the ODataEntry that contains this complex type.
 @param aComplexPropertyName the name of the Complex Type Property in the calling class.
 @param error A pointer to an NSError object that will hold the error info if one occurs.
 @return Returns YES if the method completed successfully.
 */
- (BOOL)setComplexTypePropertiesToSDMEntry:(ODataEntry *)aSDMEntry complexTypePropertyName:(NSString *)aComplexPropertyName error:(NSError * __autoreleasing *)error;


@end
