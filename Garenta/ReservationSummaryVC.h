//
//  ReservationSummaryVC.h
//  Garenta
//
//  Created by Alp Keser on 6/9/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BaseVC.h"
#import "Reservation.h"
#import "WYStoryboardPopoverSegue.h"

@interface ReservationSummaryVC : UIViewController <UITableViewDelegate, UITableViewDataSource, WYPopoverControllerDelegate, UIAlertViewDelegate>{
    WYPopoverController* popoverController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *brandModelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UILabel *fuelLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *acLabel;
@property (weak, nonatomic) IBOutlet UILabel *passangerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorCountLabel;

@property (strong,nonatomic) Reservation *reservation;
@property (assign,nonatomic) BOOL isTotalPressed;

- (IBAction)payNowPressed:(id)sender;
- (IBAction)payLaterPressed:(id)sender;

@end
