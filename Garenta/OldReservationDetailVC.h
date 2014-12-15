//
//  OldReservationDetailVC.h
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYStoryboardPopoverSegue.h"

@interface OldReservationDetailVC : UIViewController <WYPopoverControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    WYPopoverController* popoverController;
}
@property (weak,nonatomic) Reservation *reservation;
@property (weak,nonatomic) NSString *totalPrice;
@property (weak,nonatomic) CarGroup *carGroup;
@property (strong,nonatomic) NSDate *oldCheckOutTime;
@property (strong,nonatomic) NSDate *oldCheckInTime;
@end
