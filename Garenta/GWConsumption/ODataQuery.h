/*
  
 File: ODataQuery.h
 Abstract: Represents an OData query. Provides the functionality
 to create an OData query URL with parameters.
  
*/


#import <Foundation/Foundation.h>

@interface ODataQuery : NSObject
{
    NSMutableDictionary *m_additionalParameters;
    NSURL *m_baseUrl;
}

@property (strong, nonatomic, readonly, getter=getUrl) NSURL *URL; ///< The URL for the OData query.

/**
 Construct a Query object with some URL.
 The URL may already contain query parameters.
 Added query parameters by the Query object methods will be added to 
 the original query parameters given in this URL (and will not replace them).
 @param baseUrl An NSURL containing the query url.
*/
- (id)initWithURL:(NSURL *)baseUrl;

/**
 Add a parameter to the OData Query.
 @param parameterKey The key name of the parameter (e.g. orderby).
 @param parameterValue The value of the parameter (e.g. Name desc).
*/
- (void)addParameterWithKey:(NSString *)parameterKey andValue:(NSString *)parameterValue;

/**
 Add filter parameter to the OData query.
 @param filterStringValue The filter parameter value (e.g. City eq 'London').
*/
- (void)filter:(NSString *)filterStringValue;

/**
 Add orderby parameter to the OData query.
 @param orderByStringValue The orderby parameter value (e.g. Name desc).
*/
- (void)orderBy:(NSString *)orderByStringValue;

/**
 Add select parameter to the OData query.
 @param selectStringValue The select parameter value (e.g. Name,Category).
*/
- (void)select:(NSString *)selectStringValue;

/**
 Add expand parameter to the OData query.
 @param expandStringValue The expand parameter value (e.g. Names,Categories).
 */
- (void)expand:(NSString *)expandStringValue;

/**
 Returns a valid URL string by replacing certain characters with
 the equivalent percent escape sequence based on UTF8 encoding.
 @param aParameterString The url parameter to be encoded.
 @return Returns the encoded url parameter.
*/
+ (NSString *)encodeURLParameter:(NSString*)aParameterString;

/**
 Returns a valid URL string by replacing certain characters with
 the equivalent percent escape sequence based on UTF8 encoding.
 Note:
    The encoding is done loosely, since it is assumed that the
    parameters part of the url are already encoded. Hence, there will
    be no second encoding.
 @param aUrlString The url to be encoded.
 @return Returns the encoded url.
 */
+ (NSString *)encodeURLLoosely:(NSString*)aUrlString;

@end