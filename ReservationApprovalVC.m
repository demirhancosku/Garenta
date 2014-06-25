//
//  ReservationApprovalVC.m
//  Garenta
//
//  Created by Alp Keser on 6/24/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationApprovalVC.h"
@interface ReservationApprovalVC ()
@property (weak, nonatomic) IBOutlet UILabel *reservationNumberLabel;

@end
@implementation ReservationApprovalVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];
    [_reservationNumberLabel setText:_reservation.reservationNumber];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
