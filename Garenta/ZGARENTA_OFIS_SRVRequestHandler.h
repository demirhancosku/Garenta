/*
 
 Auto-Generated by SAP NetWeaver Gateway Productivity Accelerator, Version 1.1.1
  
 File: ZGARENTA_OFIS_SRVRequestHandler.h
 Abstract: A singleton class responsible for sending the appropriate service requests (for retrieving and modifying service data) and parsing the responses into semantic objects, using the ZGARENTA_OFIS_SRV service proxy and the SDMConnectivityHelper class. The sent requests also consider the service URL and the SAP client defined in the application settings. The class is also responsible for sending the appropriate notifications to the application delegate and view controllers, for handling the request success, failure and authentication challenge.
 
 */

#import <Foundation/Foundation.h>
#import "RequestDelegate.h"
#import "SDMConnectivityHelper.h"
#import "ZGARENTA_OFIS_SRVServiceDeclarations.h"
#import "ServiceNegotiator.h"
#import "Authenticating.h"



#pragma mark - Notifications



extern NSString * const kLoadEXPT_CALISMA_ZAMANISetCompletedNotification; ///< Notification key for complete loading of EXPT_CALISMA_ZAMANISet items.
extern NSString * const kLoadEXPT_CALISMA_ZAMANICompletedNotification; ///< Notification key for complete loading of a specific EXPT_CALISMA_ZAMANI item.
extern NSString * const kCreateEXPT_CALISMA_ZAMANICompletedNotification; ///< Notification key for complete creating a EXPT_CALISMA_ZAMANI collection item.
extern NSString * const kUpdateEXPT_CALISMA_ZAMANICompletedNotification; ///< Notification key for complete updating a EXPT_CALISMA_ZAMANI collection item.
extern NSString * const kDeleteEXPT_CALISMA_ZAMANICompletedNotification; ///< Notification key for complete deleting a EXPT_CALISMA_ZAMANI item.

extern NSString * const kLoadEXPT_SUBE_BILGILERISetCompletedNotification; ///< Notification key for complete loading of EXPT_SUBE_BILGILERISet items.
extern NSString * const kLoadEXPT_SUBE_BILGILERICompletedNotification; ///< Notification key for complete loading of a specific EXPT_SUBE_BILGILERI item.
extern NSString * const kCreateEXPT_SUBE_BILGILERICompletedNotification; ///< Notification key for complete creating a EXPT_SUBE_BILGILERI collection item.
extern NSString * const kUpdateEXPT_SUBE_BILGILERICompletedNotification; ///< Notification key for complete updating a EXPT_SUBE_BILGILERI collection item.
extern NSString * const kDeleteEXPT_SUBE_BILGILERICompletedNotification; ///< Notification key for complete deleting a EXPT_SUBE_BILGILERI item.

extern NSString * const kLoadEXPT_TATIL_ZAMANISetCompletedNotification; ///< Notification key for complete loading of EXPT_TATIL_ZAMANISet items.
extern NSString * const kLoadEXPT_TATIL_ZAMANICompletedNotification; ///< Notification key for complete loading of a specific EXPT_TATIL_ZAMANI item.
extern NSString * const kCreateEXPT_TATIL_ZAMANICompletedNotification; ///< Notification key for complete creating a EXPT_TATIL_ZAMANI collection item.
extern NSString * const kUpdateEXPT_TATIL_ZAMANICompletedNotification; ///< Notification key for complete updating a EXPT_TATIL_ZAMANI collection item.
extern NSString * const kDeleteEXPT_TATIL_ZAMANICompletedNotification; ///< Notification key for complete deleting a EXPT_TATIL_ZAMANI item.

extern NSString * const kLoadOfficeServiceSetCompletedNotification; ///< Notification key for complete loading of OfficeServiceSet items.
extern NSString * const kLoadOfficeServiceCompletedNotification; ///< Notification key for complete loading of a specific OfficeService item.
extern NSString * const kLoadEXPT_TATIL_ZAMANISetForOfficeServiceCompletedNotification; ///< Notification key for complete loading of EXPT_TATIL_ZAMANISet navigation items for a specific OfficeService item.
extern NSString * const kLoadEXPT_SUBE_BILGILERISetForOfficeServiceCompletedNotification; ///< Notification key for complete loading of EXPT_SUBE_BILGILERISet navigation items for a specific OfficeService item.
extern NSString * const kLoadEXPT_CALISMA_ZAMANISetForOfficeServiceCompletedNotification; ///< Notification key for complete loading of EXPT_CALISMA_ZAMANISet navigation items for a specific OfficeService item.
extern NSString * const kCreateOfficeServiceCompletedNotification; ///< Notification key for complete creating a OfficeService collection item.
extern NSString * const kUpdateOfficeServiceCompletedNotification; ///< Notification key for complete updating a OfficeService collection item.
extern NSString * const kDeleteOfficeServiceCompletedNotification; ///< Notification key for complete deleting a OfficeService item.







#pragma mark -

/**
 A singleton class responsible for sending the appropriate service requests (for retrieving service data needed by the application views) and parsing the responses into semantic objects, using the ZGARENTA_OFIS_SRV service proxy and the SDMConnectivityHelper class. The sent requests also consider the service URL and the SAP client defined in the application settings. The class is also responsible for sending the appropriate notifications to the application delegate and view controllers, for handling the request success, failure and authentication challenge.
 */
@interface ZGARENTA_OFIS_SRVRequestHandler : NSObject <RequestDelegate, SDMConnectivityHelperDelegate> {
    SDMConnectivityHelper *connectivityHelper;
    ZGARENTA_OFIS_SRVService *service;
    NSString *deviceLanguage;
	ServiceNegotiator *serviceNegotiator;
	SecIdentityRef certificate;
	CSRFData *csrfData;
}

@property (strong, nonatomic, setter = setServiceDocumentURL:) NSString *serviceDocumentURL; ///< ZGARENTA_OFIS_SRV service document URL (used as base URL for service requests). 
@property (strong, nonatomic, setter = setSAPClient:) NSString *client; ///< SAP client (may be empty or nil for default client). 
@property (assign, nonatomic) BOOL useServiceNegotiation; ///< Indicates if the service negotiation process should be performed. This property is considered only when the useLocalMetadata property is set to NO.
@property (assign, nonatomic) BOOL useLocalMetadata; ///< Indicates if the service proxy is initialized using local metadata.
@property (assign, nonatomic) BOOL useJSON; ///< Indicates if the service calls are done using JSON or XML.


/**
 @return ZGARENTA_OFIS_SRVRequestHandler singleton instance.
 */
+ (ZGARENTA_OFIS_SRVRequestHandler *)uniqueInstance;

/**
 @return BOOL indicating if service is valid.
 */
- (BOOL)isServiceValid;

#pragma mark - User Login

/**
 Authenticates the given user name and password against the service, and initiate the service proxy according to the appropriate service URL, metadata and service document. If the useServiceNegotiation propery is YES, the method will also execute the service negotiation as part of the login process.  If the useLocalMetadata propery is YES, the method will use the local service metadata in order to initialize the service proxy object.
 Make sure to call this method before calling any other method of this class for executing service requests.
 If SUP connetivity is required, make sure to set the application and SUP server values in the ConnectivitySettings class, before calling this method.
 For enabling Single Sign On (SSO):
 At the first application run pass the username and password to securely store the user credentials on the device.
 At later calls, pass empty credentials to exctract the stored user credentials. 
 @param aUsername The user name used for the authentication. If domain is required, the username should be in the format: [domain]\[user]
 @param aPassword The password for the provided user name.
 @param error A pointer to an NSError object.
 @return BOOL indicating if authentication succeeded.
 */
- (BOOL)executeLoginWithUsername:(NSString *)aUsername andPassword:(NSString *)aPassword error:(NSError * __autoreleasing *)error;

/**
 Authenticates the client certificate against the service, and initiate the service proxy according to the appropriate service URL, metadata and service document. If the useServiceNegotiation propery is YES, the method will also execute the service negotiation as part of the login process. If the useLocalMetadata propery is YES, the method will use the local service metadata in order to initialize the service proxy object (without service negotiation).
 Make sure to call this method before calling any other method of this class for executing service requests.
 If SUP connetivity is required use the executeLoginWithCertificateWithPassword:andFileName:andFileExtension:error: method.
 @param error A pointer to an NSError object.
 @return BOOL indicating if authentication succeeded.
 */
- (BOOL)executeLoginWithCertificateWithError:(NSError *__autoreleasing *)error;

/**
 Authenticates the client certificate against the service, and initiate the service proxy according to the appropriate service URL, metadata and service document. If the useServiceNegotiation propery is YES, the method will also execute the service negotiation as part of the login process. If the useLocalMetadata propery is YES, the method will use the local service metadata in order to initialize the service proxy object (without service negotiation).
 Make sure to call this method before calling any other method of this class for executing service requests.
 If SUP connetivity is required, make sure to set the application and SUP server values in the ConnectivitySettings class, before calling this method.
 @param aPassword Certificate password.
 @param aFileName Certificate file name.
 @param aFileExtension Certificate file extension.
 @param error A pointer to an NSError object.
 @return BOOL indicating if authentication succeeded.
 */
- (BOOL)executeLoginWithCertificateWithPassword:(NSString *)aPassword andFileName:(NSString *)aFileName andFileExtension:(NSString *)aFileExtension error:(NSError *__autoreleasing *)error;



#pragma mark - Service Negotiation

/**
 Updates the service document URL with the result of the best matching service query of the Gateway service catalog.
 Is performed as part of the login process (in the executeLoginWithUsername:andPassword method), if the useServiceNegotiation propery is YES.
 @param authenticator The implementation of Authenticating protocol according to the required authentication method.
 @param error A pointer to an NSError object.
 @return BOOL indicating if service negotiation succeeded.
 */
- (BOOL)negotiateServiceVersionAndUpdateServiceDocumentUrlUsingAuthenticator:(id <Authenticating>)authenticator error:(NSError * __autoreleasing *)error;

#pragma mark - Batch

/**
 Start a batch request which will aggregate all service calls made through the RequestHandler.
 Call the executeBatch method to execute the aggregated calls in one batch request.
 @param aNotificationName A name to post a notification to once the batch request is completed, can be nil.
 */
- (void)startBatchWithNotificationName:(NSString *)aNotificationName;

/**
 Closes a changeSet and adds requests to new changeSet (in batch request).
 */
- (void)closeExistingChangeSet;

/**
 Executes a batch request, call the startBatchWithNotificationName: before in order to initiate a batch request object.
 */
- (void)executeBatch;




#pragma mark - EXPT_CALISMA_ZAMANISet methods

/**
 Load the service entity-set EXPT_CALISMA_ZAMANISet items, parsed into EXPT_CALISMA_ZAMANI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_CALISMA_ZAMANISetCompletedNotification for operation completion, along with the array of EXPT_CALISMA_ZAMANI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadEXPT_CALISMA_ZAMANISet;

/**
 Load a specific EXPT_CALISMA_ZAMANI item, parsed into EXPT_CALISMA_ZAMANI object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_CALISMA_ZAMANICompletedNotification for operation completion, along with the EXPT_CALISMA_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_CALISMA_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_CALISMA_ZAMANI The specific item to load.
 */
- (void)loadEXPT_CALISMA_ZAMANI:(EXPT_CALISMA_ZAMANI *)aEXPT_CALISMA_ZAMANI;

/**
 Creates a EXPT_CALISMA_ZAMANI item and add it to the EXPT_CALISMA_ZAMANISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_CALISMA_ZAMANICompletedNotification for operation completion, along with the EXPT_CALISMA_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_CALISMA_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_CALISMA_ZAMANI The specific item to create.
 */
- (void)createEXPT_CALISMA_ZAMANI:(EXPT_CALISMA_ZAMANI *)aEXPT_CALISMA_ZAMANI;

/**
 Updates a EXPT_CALISMA_ZAMANI item in the EXPT_CALISMA_ZAMANISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateEXPT_CALISMA_ZAMANICompletedNotification for operation completion, along with the EXPT_CALISMA_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_CALISMA_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_CALISMA_ZAMANI The specific item to update.
 */
- (void)updateEXPT_CALISMA_ZAMANI:(EXPT_CALISMA_ZAMANI *)aEXPT_CALISMA_ZAMANI;

/**
 Deletes a specific EXPT_CALISMA_ZAMANI item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteEXPT_CALISMA_ZAMANICompletedNotification for operation completion, along with the EXPT_CALISMA_ZAMANI item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_CALISMA_ZAMANI The specific item to delete.
 */
- (void)deleteEXPT_CALISMA_ZAMANI:(EXPT_CALISMA_ZAMANI *)aEXPT_CALISMA_ZAMANI;

#pragma mark - EXPT_SUBE_BILGILERISet methods

/**
 Load the service entity-set EXPT_SUBE_BILGILERISet items, parsed into EXPT_SUBE_BILGILERI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_SUBE_BILGILERISetCompletedNotification for operation completion, along with the array of EXPT_SUBE_BILGILERI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadEXPT_SUBE_BILGILERISet;

/**
 Load a specific EXPT_SUBE_BILGILERI item, parsed into EXPT_SUBE_BILGILERI object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_SUBE_BILGILERICompletedNotification for operation completion, along with the EXPT_SUBE_BILGILERI item given as parameter (for kResponseParentItem key), and the response EXPT_SUBE_BILGILERI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_SUBE_BILGILERI The specific item to load.
 */
- (void)loadEXPT_SUBE_BILGILERI:(EXPT_SUBE_BILGILERI *)aEXPT_SUBE_BILGILERI;

/**
 Creates a EXPT_SUBE_BILGILERI item and add it to the EXPT_SUBE_BILGILERISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_SUBE_BILGILERICompletedNotification for operation completion, along with the EXPT_SUBE_BILGILERI item given as parameter (for kResponseParentItem key), and the response EXPT_SUBE_BILGILERI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_SUBE_BILGILERI The specific item to create.
 */
- (void)createEXPT_SUBE_BILGILERI:(EXPT_SUBE_BILGILERI *)aEXPT_SUBE_BILGILERI;

/**
 Updates a EXPT_SUBE_BILGILERI item in the EXPT_SUBE_BILGILERISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateEXPT_SUBE_BILGILERICompletedNotification for operation completion, along with the EXPT_SUBE_BILGILERI item given as parameter (for kResponseParentItem key), and the response EXPT_SUBE_BILGILERI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_SUBE_BILGILERI The specific item to update.
 */
- (void)updateEXPT_SUBE_BILGILERI:(EXPT_SUBE_BILGILERI *)aEXPT_SUBE_BILGILERI;

/**
 Deletes a specific EXPT_SUBE_BILGILERI item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteEXPT_SUBE_BILGILERICompletedNotification for operation completion, along with the EXPT_SUBE_BILGILERI item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_SUBE_BILGILERI The specific item to delete.
 */
- (void)deleteEXPT_SUBE_BILGILERI:(EXPT_SUBE_BILGILERI *)aEXPT_SUBE_BILGILERI;

#pragma mark - EXPT_TATIL_ZAMANISet methods

/**
 Load the service entity-set EXPT_TATIL_ZAMANISet items, parsed into EXPT_TATIL_ZAMANI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_TATIL_ZAMANISetCompletedNotification for operation completion, along with the array of EXPT_TATIL_ZAMANI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadEXPT_TATIL_ZAMANISet;

/**
 Load a specific EXPT_TATIL_ZAMANI item, parsed into EXPT_TATIL_ZAMANI object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_TATIL_ZAMANICompletedNotification for operation completion, along with the EXPT_TATIL_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_TATIL_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_TATIL_ZAMANI The specific item to load.
 */
- (void)loadEXPT_TATIL_ZAMANI:(EXPT_TATIL_ZAMANI *)aEXPT_TATIL_ZAMANI;

/**
 Creates a EXPT_TATIL_ZAMANI item and add it to the EXPT_TATIL_ZAMANISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_TATIL_ZAMANICompletedNotification for operation completion, along with the EXPT_TATIL_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_TATIL_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_TATIL_ZAMANI The specific item to create.
 */
- (void)createEXPT_TATIL_ZAMANI:(EXPT_TATIL_ZAMANI *)aEXPT_TATIL_ZAMANI;

/**
 Updates a EXPT_TATIL_ZAMANI item in the EXPT_TATIL_ZAMANISet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateEXPT_TATIL_ZAMANICompletedNotification for operation completion, along with the EXPT_TATIL_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_TATIL_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_TATIL_ZAMANI The specific item to update.
 */
- (void)updateEXPT_TATIL_ZAMANI:(EXPT_TATIL_ZAMANI *)aEXPT_TATIL_ZAMANI;

/**
 Deletes a specific EXPT_TATIL_ZAMANI item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteEXPT_TATIL_ZAMANICompletedNotification for operation completion, along with the EXPT_TATIL_ZAMANI item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aEXPT_TATIL_ZAMANI The specific item to delete.
 */
- (void)deleteEXPT_TATIL_ZAMANI:(EXPT_TATIL_ZAMANI *)aEXPT_TATIL_ZAMANI;

#pragma mark - OfficeServiceSet methods

/**
 Load the service entity-set OfficeServiceSet items, parsed into OfficeService objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadOfficeServiceSetCompletedNotification for operation completion, along with the array of OfficeService items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadOfficeServiceSet;

/**
 Load a specific OfficeService item, parsed into OfficeService object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the response OfficeService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to load.
 */
- (void)loadOfficeService:(OfficeService *)aOfficeService;
/**
 Load a specific OfficeService item, parsed into OfficeService object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the response OfficeService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to load.
 @param expand Should load the specific item with all its related items (using $expand query parameter)
 */
- (void)loadOfficeService:(OfficeService *)aOfficeService expand:(BOOL)expand;

/**
 Load the EXPT_TATIL_ZAMANISet navigation items for a specific OfficeService item, parsed into EXPT_TATIL_ZAMANI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_TATIL_ZAMANISetForOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the array of the EXPT_TATIL_ZAMANI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to load its EXPT_TATIL_ZAMANISet navigation items.
 */
- (void)loadEXPT_TATIL_ZAMANISetForOfficeService:(OfficeService *)aOfficeService;

/**
 Load the EXPT_SUBE_BILGILERISet navigation items for a specific OfficeService item, parsed into EXPT_SUBE_BILGILERI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_SUBE_BILGILERISetForOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the array of the EXPT_SUBE_BILGILERI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to load its EXPT_SUBE_BILGILERISet navigation items.
 */
- (void)loadEXPT_SUBE_BILGILERISetForOfficeService:(OfficeService *)aOfficeService;

/**
 Load the EXPT_CALISMA_ZAMANISet navigation items for a specific OfficeService item, parsed into EXPT_CALISMA_ZAMANI objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadEXPT_CALISMA_ZAMANISetForOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the array of the EXPT_CALISMA_ZAMANI items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to load its EXPT_CALISMA_ZAMANISet navigation items.
 */
- (void)loadEXPT_CALISMA_ZAMANISetForOfficeService:(OfficeService *)aOfficeService;

/**
 Creates a OfficeService item and add it to the OfficeServiceSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the response OfficeService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to create.
 */
- (void)createOfficeService:(OfficeService *)aOfficeService;

/**
 Creates a EXPT_TATIL_ZAMANI item for a OfficeService item (using EXPT_TATIL_ZAMANISet navigation query).
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_TATIL_ZAMANICompletedNotification for operation completion, along with the EXPT_TATIL_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_TATIL_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aNewEXPT_TATIL_ZAMANI The specific item to create.
 @param aOfficeService The item which the created item will be associated to.
 */
- (void)createEXPT_TATIL_ZAMANI:(EXPT_TATIL_ZAMANI *)aNewEXPT_TATIL_ZAMANI forOfficeService:(OfficeService *)aOfficeService;

/**
 Creates a EXPT_SUBE_BILGILERI item for a OfficeService item (using EXPT_SUBE_BILGILERISet navigation query).
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_SUBE_BILGILERICompletedNotification for operation completion, along with the EXPT_SUBE_BILGILERI item given as parameter (for kResponseParentItem key), and the response EXPT_SUBE_BILGILERI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aNewEXPT_SUBE_BILGILERI The specific item to create.
 @param aOfficeService The item which the created item will be associated to.
 */
- (void)createEXPT_SUBE_BILGILERI:(EXPT_SUBE_BILGILERI *)aNewEXPT_SUBE_BILGILERI forOfficeService:(OfficeService *)aOfficeService;

/**
 Creates a EXPT_CALISMA_ZAMANI item for a OfficeService item (using EXPT_CALISMA_ZAMANISet navigation query).
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateEXPT_CALISMA_ZAMANICompletedNotification for operation completion, along with the EXPT_CALISMA_ZAMANI item given as parameter (for kResponseParentItem key), and the response EXPT_CALISMA_ZAMANI item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aNewEXPT_CALISMA_ZAMANI The specific item to create.
 @param aOfficeService The item which the created item will be associated to.
 */
- (void)createEXPT_CALISMA_ZAMANI:(EXPT_CALISMA_ZAMANI *)aNewEXPT_CALISMA_ZAMANI forOfficeService:(OfficeService *)aOfficeService;

/**
 Updates a OfficeService item in the OfficeServiceSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key), and the response OfficeService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to update.
 */
- (void)updateOfficeService:(OfficeService *)aOfficeService;

/**
 Deletes a specific OfficeService item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteOfficeServiceCompletedNotification for operation completion, along with the OfficeService item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aOfficeService The specific item to delete.
 */
- (void)deleteOfficeService:(OfficeService *)aOfficeService;

#pragma mark - Function Import methods



@end
