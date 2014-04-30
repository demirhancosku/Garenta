/*
 
 File: KeychainHelper.h
 Abstract: Helper class for using Keychain services.
 
 */

#import <Foundation/Foundation.h>
#import "CredentialsData.h"


/*
 Helper class for using Keychain services.
 */
@interface KeychainHelper : NSObject

/**
 Set the keychain access group attribute that determines if the keychain items saved by this application can be shared amongst multiple apps whose code signing entitlements contain the same keychain access group.
 @param accessGroup The keychain access group attribute value. The access group prefix must be the app ID prefix that is contained in the provisioning profile used to sign all the applications that share the keychain items.
 */
+ (void)setAccessGroup:(NSString *)accessGroup;

/**
 Get the access group attribute value to use in keychain items saved by this application.
 */
+ (NSString *)accessGroup;


#pragma mark - Username & Password

/**
 Load user credentials data (username and password) from Keychain.
 @param error a pointer to an NSError object.
 @return The CredentialsData holding the user credentials data stored in Keychain, or nil if no such credentials are stored.
 */
+ (CredentialsData *)loadCredentialsAndReturnError:(NSError * __autoreleasing *)error;

/**
 Check whether there is user credentials data (username and password) saved in Keychain.
 */
+ (BOOL)isCredentialsSaved;

/**
 Save the given user credentials data (username and password) in Keychain.
 @param credentials The CredentialsData holding the user credentials data to save.
 @param error a pointer to an NSError object.
 @return An indication if the operation has succeeded.
 */
+ (BOOL)saveCredentials:(CredentialsData *)credentials error:(NSError * __autoreleasing *)error;

/**
 Delete the user credentials data (username and password) saved in Keychain (if there are any).
 @param error a pointer to an NSError object.
 @return An indication if the operation has succeeded.
 */
+ (BOOL)deleteCredentialsAndReturnError:(NSError * __autoreleasing *)error;

#pragma mark - X.509 certificates

/**
 Extracts the SecIdentityRef object from  the X.509 client certificate that is stored in the application bundle under the name "client_certificate.pfx"
 @param aCertificate the binary data of the X.509 certificate
 @param aPassword the password for opening the X.509 client certificate
 @return A SecIdentityRef object that represents the X.509 client certificate
 */
+ (SecIdentityRef)extractIdentityFromClientCertificate:(NSData *)aCertificate WithPassword:(NSString *)aPassword;

/**
 Adds the client certificate to the keychain
 @param anIdentity the SecIdentityRef object that represents the client certificate which is added to the keychain
 @param error a pointer to an NSError object
 @return An indication whether the operation was successfull or not
 */
+ (BOOL)saveIdentityToKeychain:(SecIdentityRef)anIdentity error:(NSError * __autoreleasing *)error;

/**
 Finds and returns the client certificate in the keychain, if one exists
 @param error a pointer to an NSError object
 @return A SecIdentityRef object that represents the client certificate if found in the keychain. NULL otherwise
 */
+ (SecIdentityRef)loadClientCertificateInKeychainAndReturnError:(NSError * __autoreleasing *)error;

/**
 Delete the client certificate saved in Keychain (if there are any).
 @param error a pointer to an NSError object.
 @return An indication if the operation has succeeded.
 */
+ (BOOL)deleteCertificateAndReturnError:(NSError * __autoreleasing *)error;

/**
 Check whether the client certificate is saved in Keychain.
 */
+ (BOOL)isCertificateSaved;

/**
 Extracts the subject from the stored certificate object.
 @param error a pointer to an NSError object
 @return A string representing the certificate subject. nil otherwise
 */
+ (NSString *)extractSubjectFromStoredCertificateAndReturnError:(NSError * __autoreleasing *)error;

/**
 Extracts the subject from the input certificate object.
 @param anIdentity the SecIdentityRef object that represents the client certificate
 @return A string representing the certificate subject. nil otherwise
 */
+ (NSString *)extractSubjectFromIdentity:(SecIdentityRef)anIdentity;
@end
