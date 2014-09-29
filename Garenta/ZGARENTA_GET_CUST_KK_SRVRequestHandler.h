/*
 
 Auto-Generated by SAP NetWeaver Gateway Productivity Accelerator, Version 1.1.1
  
 File: ZGARENTA_GET_CUST_KK_SRVRequestHandler.h
 Abstract: A singleton class responsible for sending the appropriate service requests (for retrieving and modifying service data) and parsing the responses into semantic objects, using the ZGARENTA_GET_CUST_KK_SRV service proxy and the SDMConnectivityHelper class. The sent requests also consider the service URL and the SAP client defined in the application settings. The class is also responsible for sending the appropriate notifications to the application delegate and view controllers, for handling the request success, failure and authentication challenge.
 
 */

#import <Foundation/Foundation.h>
#import "RequestDelegate.h"
#import "SDMConnectivityHelper.h"
#import "ZGARENTA_GET_CUST_KK_SRVServiceDeclarations.h"
#import "ServiceNegotiator.h"
#import "Authenticating.h"



#pragma mark - Notifications

//Notification UserInfo keys:
//extern NSString * const kResponseItem; ///< Single item response
//extern NSString * const kResponseItems; ///< Multiple items response
//extern NSString * const kResponseData; ///< Raw response data
//extern NSString * const kRequestedMediaLink; ///< Media link item
//extern NSString * const kServerResponseError; ///< Server response error
//extern NSString * const kParsingError; ///< Parsing response error
//extern NSString * const kResponseParentItem; ///< Item selected in the view previous to the one triggered the request
//extern NSString * const kBatchRequest; ///< BatchRequest object containing the response
//
////Notification keys:
//extern NSString * const kAuthenticationNeededNotification; ///< Notification key for request authentication challenge.
//


extern NSString * const kLoadCustKKSetCompletedNotification; ///< Notification key for complete loading of CustKKSet items.
extern NSString * const kLoadCustKKServiceCompletedNotification; ///< Notification key for complete loading of a specific CustKKService item.
extern NSString * const kLoadET_CARDSSetForCustKKServiceCompletedNotification; ///< Notification key for complete loading of ET_CARDSSet navigation items for a specific CustKKService item.
extern NSString * const kCreateCustKKServiceCompletedNotification; ///< Notification key for complete creating a CustKKService collection item.
extern NSString * const kUpdateCustKKServiceCompletedNotification; ///< Notification key for complete updating a CustKKService collection item.
extern NSString * const kDeleteCustKKServiceCompletedNotification; ///< Notification key for complete deleting a CustKKService item.

extern NSString * const kLoadET_CARDSetCompletedNotification; ///< Notification key for complete loading of ET_CARDSet items.
extern NSString * const kLoadET_CARDSCompletedNotification; ///< Notification key for complete loading of a specific ET_CARDS item.
extern NSString * const kCreateET_CARDSCompletedNotification; ///< Notification key for complete creating a ET_CARDS collection item.
extern NSString * const kUpdateET_CARDSCompletedNotification; ///< Notification key for complete updating a ET_CARDS collection item.
extern NSString * const kDeleteET_CARDSCompletedNotification; ///< Notification key for complete deleting a ET_CARDS item.





#pragma mark -

/**
 A singleton class responsible for sending the appropriate service requests (for retrieving service data needed by the application views) and parsing the responses into semantic objects, using the ZGARENTA_GET_CUST_KK_SRV service proxy and the SDMConnectivityHelper class. The sent requests also consider the service URL and the SAP client defined in the application settings. The class is also responsible for sending the appropriate notifications to the application delegate and view controllers, for handling the request success, failure and authentication challenge.
 */
@interface ZGARENTA_GET_CUST_KK_SRVRequestHandler : NSObject <RequestDelegate, SDMConnectivityHelperDelegate> {
    SDMConnectivityHelper *connectivityHelper;
    ZGARENTA_GET_CUST_KK_SRVService *service;
    NSString *deviceLanguage;
	ServiceNegotiator *serviceNegotiator;
	SecIdentityRef certificate;
	CSRFData *csrfData;
}

@property (strong, nonatomic, setter = setServiceDocumentURL:) NSString *serviceDocumentURL; ///< ZGARENTA_GET_CUST_KK_SRV service document URL (used as base URL for service requests). 
@property (strong, nonatomic, setter = setSAPClient:) NSString *client; ///< SAP client (may be empty or nil for default client). 
@property (assign, nonatomic) BOOL useServiceNegotiation; ///< Indicates if the service negotiation process should be performed. This property is considered only when the useLocalMetadata property is set to NO.
@property (assign, nonatomic) BOOL useLocalMetadata; ///< Indicates if the service proxy is initialized using local metadata.
@property (assign, nonatomic) BOOL useJSON; ///< Indicates if the service calls are done using JSON or XML.


/**
 @return ZGARENTA_GET_CUST_KK_SRVRequestHandler singleton instance.
 */
+ (ZGARENTA_GET_CUST_KK_SRVRequestHandler *)uniqueInstance;

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




#pragma mark - CustKKSet methods

/**
 Load the service entity-set CustKKSet items, parsed into CustKKService objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadCustKKSetCompletedNotification for operation completion, along with the array of CustKKService items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadCustKKSet;

/**
 Load a specific CustKKService item, parsed into CustKKService object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key), and the response CustKKService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to load.
 */
- (void)loadCustKKService:(CustKKService *)aCustKKService;
/**
 Load a specific CustKKService item, parsed into CustKKService object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key), and the response CustKKService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to load.
 @param expand Should load the specific item with all its related items (using $expand query parameter)
 */
- (void)loadCustKKService:(CustKKService *)aCustKKService expand:(BOOL)expand;

/**
 Load the ET_CARDSSet navigation items for a specific CustKKService item, parsed into ET_CARDS objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadET_CARDSSetForCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key), and the array of the ET_CARDS items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to load its ET_CARDSSet navigation items.
 */
- (void)loadET_CARDSSetForCustKKService:(CustKKService *)aCustKKService;

/**
 Creates a CustKKService item and add it to the CustKKSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key), and the response CustKKService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to create.
 */
- (void)createCustKKService:(CustKKService *)aCustKKService;

/**
 Creates a ET_CARDS item for a CustKKService item (using ET_CARDSSet navigation query).
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateET_CARDSCompletedNotification for operation completion, along with the ET_CARDS item given as parameter (for kResponseParentItem key), and the response ET_CARDS item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aNewET_CARDS The specific item to create.
 @param aCustKKService The item which the created item will be associated to.
 */
- (void)createET_CARDS:(ET_CARDS *)aNewET_CARDS forCustKKService:(CustKKService *)aCustKKService;

/**
 Updates a CustKKService item in the CustKKSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key), and the response CustKKService item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to update.
 */
- (void)updateCustKKService:(CustKKService *)aCustKKService;

/**
 Deletes a specific CustKKService item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteCustKKServiceCompletedNotification for operation completion, along with the CustKKService item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aCustKKService The specific item to delete.
 */
- (void)deleteCustKKService:(CustKKService *)aCustKKService;

#pragma mark - ET_CARDSet methods

/**
 Load the service entity-set ET_CARDSet items, parsed into ET_CARDS objects. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadET_CARDSetCompletedNotification for operation completion, along with the array of ET_CARDS items (for kResponseItems key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 */
- (void)loadET_CARDSet;

/**
 Load a specific ET_CARDS item, parsed into ET_CARDS object. 
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kLoadET_CARDSCompletedNotification for operation completion, along with the ET_CARDS item given as parameter (for kResponseParentItem key), and the response ET_CARDS item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aET_CARDS The specific item to load.
 */
- (void)loadET_CARDS:(ET_CARDS *)aET_CARDS;

/**
 Creates a ET_CARDS item and add it to the ET_CARDSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kCreateET_CARDSCompletedNotification for operation completion, along with the ET_CARDS item given as parameter (for kResponseParentItem key), and the response ET_CARDS item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aET_CARDS The specific item to create.
 */
- (void)createET_CARDS:(ET_CARDS *)aET_CARDS;

/**
 Updates a ET_CARDS item in the ET_CARDSet.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kUpdateET_CARDSCompletedNotification for operation completion, along with the ET_CARDS item given as parameter (for kResponseParentItem key), and the response ET_CARDS item (for kResponseItem key) or parsing error (for kParsingError key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aET_CARDS The specific item to update.
 */
- (void)updateET_CARDS:(ET_CARDS *)aET_CARDS;

/**
 Deletes a specific ET_CARDS item from its collection.
 May send notifications with the following keys and associated objects (as userInfo dictionary):
 - kDeleteET_CARDSCompletedNotification for operation completion, along with the ET_CARDS item given as parameter (for kResponseParentItem key) or server response error (for kServerResponseError).
 - kAuthenticationNeededNotification for request authentication challenge.
 @param aET_CARDS The specific item to delete.
 */
- (void)deleteET_CARDS:(ET_CARDS *)aET_CARDS;

#pragma mark - Function Import methods



@end