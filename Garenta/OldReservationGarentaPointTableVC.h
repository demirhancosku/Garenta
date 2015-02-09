//
//  OldReservationGarentaPointTableVC.h
//  Garenta
//
//  Created by Ata Cengiz on 08/02/15.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import "GarentaPointTableViewController.h"

@interface OldReservationGarentaPointTableVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Reservation *reservation;
@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSString *totalPrice;
@property BOOL isYoungDriver;
@property (strong,nonatomic) NSDecimalNumber *changeReservationPrice;

@end
