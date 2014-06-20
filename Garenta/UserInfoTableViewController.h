//
//  UserInfoTableViewController.h
//  Garenta
//
//  Created by Alp Keser on 6/6/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
@interface UserInfoTableViewController : UITableViewController
@property(strong,nonatomic)Reservation *reservation;
@end
