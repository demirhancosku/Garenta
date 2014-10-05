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

@interface ReservationSummaryVC : UIViewController<UITableViewDelegate,UITableViewDataSource,WYPopoverControllerDelegate>{
    WYPopoverController* popoverController;
}

@property (strong,nonatomic)Reservation *reservation;

@end
