/*
 
 File: CredentialsData.h
 Abstract: Holds credential data (username and password) saved or loaded from Keychain.
 
 */

#import <Foundation/Foundation.h>

/*
 Holds credential data (username and password) saved or loaded from Keychain.
 */
@interface CredentialsData : NSObject

@property (strong, nonatomic) NSString *username; ///< The user name value in the format: [user] or [domain]\[user]
@property (strong, nonatomic) NSString *password; ///< The password value for the provided user name

/**
 Creates an instance of the CredentialsData class with the given credentials.
 @param aUsername The user name used for the authentication. If domain is required, the username should be in the format: [domain]\[user]
 @param aPassword The password for the provided user name.
 */
- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;

@end
