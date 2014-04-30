/*
 
 File: Authenticating.h
 Abstract: Protocol for performing synchronous GET request with user authentication (using SDMConnectivityHelper). Note that next requests does not require user authentication process if a session cookie is returned from the server (you should configure the SAP NetWeaver Gateway to support this recommended behavior). Therefore the request with the user credentials should be performed when the user logs-in the application.
     Note that if SAML2 is used for authentication, the Authenticating protocol implementation indicates the authentication type used by the Identity Provider server.
 
*/

#import <Foundation/Foundation.h>
#import "Requesting.h"
#import "ODataQuery.h"

/**
 A protocol for performing synchronous GET requests with user authentication (using SDMConnectivityHelper). 
 Note that next requests does not require user authentication process if a session cookie is returned from the server (you should configure the SAP NetWeaver Gateway to support this recommended behavior). Therefore the request with the user credentials should be performed when the user logs-in the application.
 Note that if SAML2 is used for authentication, the Authenticating protocol implementation indicates the authentication type used by the Identity Provider server.
 */
@protocol Authenticating <NSObject>

@property (strong, nonatomic) NSString *sapClient; ///< The SAP client to connect to (use nil for default client).

/**
 Send a synchronous GET request with user authentication.
 @param query The OData query to execute with the user credentials.
 @param error A pointer to an NSError object that will hold the error info if one occurs (use this parameter to identify if the authentication was failed).
 @return NSData object with the server response body.
 */
- (NSData *)authenticateWithODataQuery:(ODataQuery *)query error:(NSError * __autoreleasing *)error;

@end
