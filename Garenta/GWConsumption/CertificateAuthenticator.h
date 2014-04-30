/*
 
 File: CertificateAuthenticator
 Abstract: Implements the Authenticating protocol for performing synchronous GET requests with client certificate authentication. See the Authenticating protocol for more information.
 
 */

#import <Foundation/Foundation.h>
#import "Authenticating.h"
#import "SDMConnectivityHelper.h"
#import "SDMConnectivityHelperDelegate.h"

/**
 A class Implements the Authenticating protocol for performing synchronous GET requests with client certificate authentication
 */
@interface CertificateAuthenticator : NSObject<Authenticating, SDMConnectivityHelperDelegate>{
    SDMConnectivityHelper *connectivityHelper;
}

@property(readonly, nonatomic) SecIdentityRef certificate; ///< The client certificate that is taken from the keychain or passed in the init method.

/**
 Creates an instance of the CertificateAuthenticator class.
 Using this initialization method, the certificate is taken from the keychain
 */
- (id)init;

/**
 Creates an instance of the CertificateAuthenticator class.
 Using this initialization method, the certificate is supplied by the calling method
 */
- (id)initWithCertificate:(SecIdentityRef)aCertificate;
@end
