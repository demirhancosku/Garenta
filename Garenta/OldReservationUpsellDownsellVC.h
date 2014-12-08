//
//  OldReservationUpsellDownsellVCViewController.h
//  Garenta
//
//  Created by Kerem Balaban on 6.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplacementVehicleObject.h"

@interface OldReservationUpsellDownsellVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) Reservation *reservation;
@property (weak,nonatomic) NSString *totalPrice;
@property (strong,nonatomic) NSMutableArray *upsellList;
@property (strong,nonatomic) NSMutableArray *downsellList;
@end
