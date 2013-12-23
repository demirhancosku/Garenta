//
//  Destination.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Destination : NSObject

@property (nonatomic, retain) NSString *destinationOfficeCode;
@property (nonatomic, retain) NSString *destinationOfficeName;
@property (nonatomic, retain) NSDate *destinationDate;
@property (nonatomic, retain) NSDate *destinationTime;
@end
