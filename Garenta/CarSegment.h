//
//  CarSegment.h
//  Garenta
//
//  Created by Alp Keser on 12/28/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarGroup.h"
@interface CarSegment : NSObject
@property(nonatomic,retain)NSString *segment;
@property(nonatomic,retain)NSString *segmentName;
@property(nonatomic,retain)NSMutableArray *carGroups;

- (CarGroup*)getCarGroupWithCode:(NSString*)aGroupCode;
@end
