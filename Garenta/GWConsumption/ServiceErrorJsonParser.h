/*
 
 File: ServiceErrorJsonParser.h
 Abstract: Parsing server error json.
 
 */

#import <Foundation/Foundation.h>
#import "ServiceError.h"

@interface ServiceErrorJsonParser : NSObject<ServiceErrorParsing> {
    ServiceError *error;
    NSMutableString *currentString;
    NSData *errorData;
}


@end
