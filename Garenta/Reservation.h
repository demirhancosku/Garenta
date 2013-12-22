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

@interface Reservation : NSObject

@property (nonatomic,retain) Destination *destination;
@property (nonatomic,retain) Arrival *arrival;
@property (nonatomic, retain) NSString *selectedBrand;
@end
