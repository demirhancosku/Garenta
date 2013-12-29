//
//  CarSegment.m
//  Garenta
//
//  Created by Alp Keser on 12/28/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarSegment.h"

@implementation CarSegment
@synthesize segment,segmentName,carGroups;
- (CarGroup*)getCarGroupWithCode:(NSString*)aGroupCode{
    for (CarGroup *tempGroup in carGroups) {
        if ([tempGroup.groupCode isEqualToString:aGroupCode]) {
            return tempGroup;
        }
    }
    return nil;
}
@end
