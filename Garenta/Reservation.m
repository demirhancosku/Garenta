//
//  Reservation.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Reservation.h"

@implementation Reservation
@synthesize  checkOutTime,checkOutDay,checkInTime,checkInDay,checkInOffice,checkOutOffice, selectedCarGroup,number;

-(id)init{
    self = [super init];
    checkInDay= [NSDate date];
    checkOutDay= [NSDate date];
    checkOutTime= [NSDate date];
    checkInTime = [NSDate date];
    return self;
}
@end
