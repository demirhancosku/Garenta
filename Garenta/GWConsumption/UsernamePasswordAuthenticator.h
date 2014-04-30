/*
 
 File: UsernamePasswordAuthenticator.h
 Abstract: Implements the Authenticating protocol for performing synchronous GET requests with user Basic / NTLM authentication: with username, password and domain (optional). See the Authenticating protocol for more information. Note: Domain is not supported when connecting to SUP. The class also supports Single Sign On (SSO), by securely storing the user credentials on the device.
 
 */

#import <Foundation/Foundation.h>
#import "Authenticating.h"
#import "SDMConnectivityHelperDelegate.h"
#import "SDMConnectivityHelper.h"

/**
 A class implements the Authenticating protocol for performing synchronous GET requests with user Basic / NTLM authentication: with username, password and domain (optional). See the Authenticating protocol for more information. The class also supports Single Sign On (SSO), by securely storing the user credentials on the device.
 */
@interface UsernamePasswordAuthenticator : NSObject <Authenticating, SDMConnectivityHelperDelegate> {
    SDMConnectivityHelper *connectivityHelper;
    NSString *username;
    NSString *password;
    NSString *domain;
}

#pragma mark - Initialize

/**
 Creates an instance of the UsernamePasswordAuthenticator class.
 The method tries to extract the credentials from the Keychain.
 If you would like to enable connectivity with SUP server, make sure you have called the initWithUsername:andPassword: once before, for registering the user in the SUP server.
 
 For enabling Single Sign On (SSO):
 At the first application run use the initWithUsername:andPassword: method to pass the username and password to securely store the user credentials on the device.
 At later calls, use this method to exctract the stored user credentials.
 */
- (id)init;


/**
 Creates an instance of the UsernamePasswordAuthenticator class.
 The method stores the given credentials in the Keychain.
 If the given username and password are nil or empty, the method tries to extract the credentials from the Keychain.
 If the SUP Mode is set to YES in the Connectivity Settings, pass the username and password for connecting the SAP NetWeaver Gateway server to register the user on the SUP server. You must also set the following SUP connectivity settings: SUPHost, SUPPort, SUPFarmId, SUPSecurityConfiguration and SUPAppID.
 @param aUsername The user name used for the authentication. If domain is required, the username should be in the format: [domain]\[user]
 @param aPassword The password for the provided user name.
 */
- (id)initWithUsername:(NSString *)aUsername andPassword:(NSString *)aPassword;


@end
