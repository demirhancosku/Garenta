/*
 
 File: SUPHelper.h
 Abstract: Helper class for SUP Server connectivity support.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CredentialsData.h"

/**
 Helper class for SUP Server connectivity support.
 */
@interface SUPHelper : NSObject

#pragma  mark - Methods for SUP Server connectivity

/**
 Set the SUP server connection profile for the application.
 This process should be performed once in the application first run.
 You must call this method to initialize the ClientConnection before using an other method of this class.
 @param aSUPHost a SUP Server host as configured by the Administrator of Sybase Control Center.
 @param aSUPPort a SUP Server port as configured by the Administrator of Sybase Control Center.
 @param aDomain a SUP server domain.
 @param aAppId an Application Id as configured by the Administrator of Sybase Control Center.
 @param aSecurityConfigName as configured by the Administrator of Sybase Control Center.
 @return BOOL indicating if the operation is successful or not.
 */
+ (BOOL)setSUPConnectionProfileWithHost:(NSString *)aSUPHost andSUPPort:(NSInteger)aSUPPort andDomain:(NSString *)aDomain andAppId:(NSString *)aAppId andSecurityConfigName:(NSString *)aSecurityConfigName;


/**
 Registers a new user for your application.
 Refer to SMPUserManager class documentation.
 @param aCredentials a credentials object containing username and password.
 @param error a pointer to an NSError object.
 @return BOOL indicating if the operation is successful or not.
 */
+ (BOOL)registerSUPUserWithCredentials:(CredentialsData *)aCredential error:(NSError * __autoreleasing *)error;

/**
 Unregisters the registered user for your application.
 @param aCredentials a credentials object containing username and password.
 @param error a pointer to an NSError object.
 @return BOOL indicating if the operation is successful or not.
 */
+ (BOOL)unregisterSUPUserWithCredentials:(CredentialsData *)aCredential error:(NSError * __autoreleasing *)error;

/**
 Checks if there is a registered user for your application.
 @return YES if there is a registered user or NO otherwise.
 */
+ (BOOL)isSUPUserRegistered;


/**
 Get the application end point URL from SUP server.
 Refer to SMPAppSettings class documentation.
 @param aCredentials a credentials object containing username and password.
 @param error a pointer to an NSError object.
 @return The end point URL as NSString object.
 */
+ (NSString *)getSUPApplicationEndPointWithCredentials:(CredentialsData *)aCredential error:(NSError * __autoreleasing *)error;


/**
 Get the certificate credentials from the certificate file.
 @param aCertPath the path to the certificate file.
 @param aCertPassword the certificate password.
 @param error a pointer to an NSError object.
 @return The certificate credentials.
 */
+ (CredentialsData *)getCredentialsFromCertificateFile:(NSString *)aCertPath withCertificatePassword:(NSString *)aCertPassword error:(NSError * __autoreleasing *)error;

#pragma  mark - Methods for Push notifications

/**
 Sends the device token received to the SUP server.
 The device token must be sent to the SUP server for it to send notification through APNS. This is to be put in the applicationDidRegisterForRemoteNotifications delegate.
 @param aCredentials a credentials object containing username and password.
 @param aDeviceToken The device token that is received from the delegate.
 @param aApplication Instance of the application class.
 @param error a pointer to an NSError object.
 */
+ (void)sendDeviceTokenForPushWithCredentials:(CredentialsData *)aCredentials andDeviceToken:(NSData *)aDeviceToken andApplication:(UIApplication *)aApplication error:(NSError * __autoreleasing *)error;

/**
 Get the application push end point URL from SUP server.
 Refer to SMPAppSettings class documentation.
 @param aCredentials a credentials object containing username and password.
 @param error a pointer to an NSError object.
 @return The push end point URL as NSString object.
 */
+ (NSString *)getSUPApplicationPushEndPointWithCredentials:(CredentialsData *)aCredentials error:(NSError * __autoreleasing *)error;

@end
