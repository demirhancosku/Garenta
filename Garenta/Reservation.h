//
//  Reservation.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Destination.h"
#import "Arrival.h"
#import "CarGroup.h"
@interface Reservation : NSObject

@property (nonatomic, retain) CarGroup *selectedCarGroup;
@property (nonatomic,retain) Office *checkOutOffice;
@property (nonatomic,strong) NSDate *checkOutDay;
@property (nonatomic,retain) NSDate *checkOutTime;
@property (nonatomic,retain) Office *checkInOffice;
@property (nonatomic,retain) NSDate *checkInDay;
@property (nonatomic,retain) NSDate *checkInTime;
@property (nonatomic,retain) NSString *number;

@end
