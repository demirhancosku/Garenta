/*
  
 File: CSRFData.h
 Abstract: Holds the CSRF data (cookie and token).
  
 */

#import <Foundation/Foundation.h>

@interface CSRFData : NSObject

@property (strong, nonatomic) NSString *token; ///< The CSRF token value.
@property (strong, nonatomic) NSHTTPCookie *cookie; ///< The CSRF cookie.
@property (strong, nonatomic) NSString *cookies; ///< The CSRF cookie string as taken from the response header (when working with SUP server).

@end
