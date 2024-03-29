//
//  OldReservationSearchVC.h
//  Garenta
//
//  Created by Kerem Balaban on 21.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ClassicSearchVC.h"

@interface OldReservationSearchVC : ClassicSearchVC <UIAlertViewDelegate,NSCopying>

@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSMutableArray *additionalEquipmentsFullList;
@property (strong,nonatomic) NSDate *oldCheckOutTime;
@property (strong,nonatomic) NSDate *oldCheckInTime;
@property (nonatomic,retain) Office *oldCheckOutOffice;
@property (nonatomic,retain) Office *oldCheckInOffice;

@property BOOL isOk;

-(id) copyWithZone:(NSZone *)zone;
@end
