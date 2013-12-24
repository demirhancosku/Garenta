//
//  FilterObject.h
//  Garenta
//
//  Created by Ata  Cengiz on 24.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterObject : NSObject

@property (nonatomic, retain) NSString *filterDescription;
@property (nonatomic, retain) NSString *filterResult;
@property (nonatomic, retain) NSString *filterCode;
@property BOOL isSelected;

@end
