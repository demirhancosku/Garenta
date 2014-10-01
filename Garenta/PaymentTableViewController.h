//
//  PaymentTableViewController.h
//  Garenta
//
//  Created by Alp Keser on 6/19/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
@interface PaymentTableViewController : UITableViewController<UIAlertViewDelegate, UITextViewDelegate>

@property (strong,nonatomic) UIButton *hideButton;
@property (strong,nonatomic) Reservation *reservation;
@end
