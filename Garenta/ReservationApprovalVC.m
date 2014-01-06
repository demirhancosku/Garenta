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
    [[self navigationItem] setHidesBackButton:YES];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Tamam" style:UIBarButtonItemStyleBordered target:self action:@selector(okPressed)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    
}

- (void)okPressed{
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
