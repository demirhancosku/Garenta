/*
 
 File: ServiceError.h
 Abstract: class to hold service error data.
 
 */

#import <Foundation/Foundation.h>

@interface ServiceError: NSObject

@property (nonatomic,strong) NSString *errorCode; // The service error code.
@property (nonatomic,strong) NSString *message; // The service error message.
@property (nonatomic,strong) NSString *innerMessage; // The service error inner messgae.

@end

@protocol ServiceErrorParsing <NSObject>

- (ServiceError *)result;
- (BOOL)parse;
- (id)initWithErrorData:(NSData *)data;

@end
