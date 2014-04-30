/*
 
 File: MediaLink.h
 Abstract: Holds the media link data (URL and content type). Used only with entities containing media links.
 
 */

#import <Foundation/Foundation.h>
#import "ODataQuery.h"

@interface MediaLink : NSObject

@property (strong, nonatomic) ODataQuery *mediaLinkQuery; ///< The media link URL query.
@property (strong, nonatomic) NSString *contentType; ///< The media link content type.
@property (strong, nonatomic) NSString *slug; ///< The slug string for the create request.

/**
 Creates a new instance of the MediaLink class.
 @param query An ODataQuery containing the URL of the media link.
 */
- (id)initWithQuery:(ODataQuery *)query;

/**
 Creates a new instance of the MediaLink class.
 @param query An ODataQuery containing the URL of the media link.
 @param aContentType The content type of the media.
 */
- (id)initWithQuery:(ODataQuery *)query andContentType:(NSString *)aContentType;

/**
 Creates a new instance of the MediaLink class.
 @param query An ODataQuery containing the URL of the media link.
 @param aContentType The content type of the media. Will be added as a header to the request.
 @param aSlug The string that will be added as the Slug header in create media requests.
 */
- (id)initWithQuery:(ODataQuery *)query andContentType:(NSString *)aContentType andSlug:(NSString *)aSlug;

@end
