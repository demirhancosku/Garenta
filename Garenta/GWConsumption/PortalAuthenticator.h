/*
 
 File: PortalAuthenticator.h
 Abstract: Implements the Authenticating protocol for performing synchronous GET requests with Portal Basic / NTLM authentication: with username (may include donmain), password and Portal URL. Mainly used to authenticate user against the Portal and get the SSO cookie for subsequent calls to SAP NetWeaver Gateway. See the Authenticating protocol and the UsernamePasswordAuthenticator class for more information. Note: When connecting to SUP the class behaves the same as a UsernamePasswordAuthenticator (SUP security configutation should be set to use the Portal URL by Administrator). The class also supports Single Sign On (SSO), by securely storing the user credentials on the device.
 */

#import <Foundation/Foundation.h>
#import "UsernamePasswordAuthenticator.h"


/**
 A class implements the Authenticating protocol for performing synchronous GET requests with Portal Basic / NTLM authentication: with username (may include donmain), password and Portal URL. Mainly used to authenticate user against the Portal and get the SSO cookie for subsequent calls to SAP NetWeaver Gateway. See the Authenticating protocol and the UsernamePasswordAuthenticator class for more information. The class also supports Single Sign On (SSO), by securely storing the user credentials on the device.
 */
@interface PortalAuthenticator : UsernamePasswordAuthenticator

@end
