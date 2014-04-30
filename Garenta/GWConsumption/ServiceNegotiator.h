/*
 
 File: ServiceNegotiator.h
 Abstract: Responsible for finding the best matching service for a given service name and versions.
 
 */

#import <Foundation/Foundation.h>
#import "SDMConnectivityHelper.h"

@interface ServiceNegotiator : NSObject <NSXMLParserDelegate> {
	
	NSString *catalogServiceUrl;
	
	// XML Parsing Variables
	NSString *serviceUrlString;
	BOOL startServiceUrlElement;
	
	NSString *serviceVersionString;
	BOOL startServiceVersionElement;
}


@property (nonatomic, readonly, strong) NSString *bestMatchingServiceUrl;
@property (nonatomic, readonly, strong) NSString *bestMatchingServiceVersion;
@property (nonatomic, strong) NSString *technicalServiceName;
@property (nonatomic) NSInteger technicalServiceVersionMin;
@property (nonatomic) NSInteger technicalServiceVersionMax;

/**
 Initializes the ServiceNegotiator object.
 @param url The service document URL from the app settings.
 @param catalogUrl A relative URL to the catalog service.
 @return An initialized instance of the ServiceNegotiator class.
 */
- (id)initWithServiceUrl:(NSString *)url andCatalogRelativeUrl:(NSString *)catalogUrl;

/**
 Returns the ODataQuery for the service negotiation function import.
 @return ODataQuery of the function import.
 */
- (ODataQuery *)getBestMatchingServiceQuery;

/**
 Parses the data returned from the service negotiation call.
 @return A boolean that indicates if the parsing process completed successfully.
 */
- (BOOL)parseBestMatchingServiceResultWithData:(NSData *)data;

@end