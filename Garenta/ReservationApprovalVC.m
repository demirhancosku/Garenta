//
//  ReservationApprovalVC.m
//  Garenta
//
//  Created by Alp Keser on 1/2/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationApprovalVC.h"

@interface ReservationApprovalVC ()

@end

@implementation ReservationApprovalVC
@synthesize reservationNumberLabel,headerLabel,reservation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithReservation:(Reservation*)aReservation{
    self = [self initWithNibName:@"ReservationApprovalVC" bundle:nil];
    reservation = aReservation;
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [headerLabel setBackgroundColor:[ApplicationProperties getGrey]];
    [reservationNumberLabel setText:reservation.number];
    [reservationNumberLabel setTextColor:[ApplicationProperties getOrange]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
