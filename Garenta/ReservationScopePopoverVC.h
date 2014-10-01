//
//  ReservationScopePopoverVC.h
//  Garenta
//
//  Created by Alp Keser on 6/27/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WYPopoverController.h"

@interface ReservationScopePopoverVC : UIViewController

@property (nonatomic,strong) IBOutlet UITextView *textView;
@property (strong,nonatomic) Reservation *reservation;
@end

