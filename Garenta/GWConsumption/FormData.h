/*
 
 File: FormData.h
 Abstract: holds data extracted from an HTML form.
 
 */

#import <Foundation/Foundation.h>

@interface FormData : NSObject

@property (strong,nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableDictionary *postBodyParameters;

- (NSString *)getBodyFromParameters;

@end
