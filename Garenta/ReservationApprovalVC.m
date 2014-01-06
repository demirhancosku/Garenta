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

- (void)navigateToCustomer {
    
//    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (ver >= 6.0) {
//        // Only executes on version 3 or above.
//        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//        
//        [locationManager setDelegate:self];
//        
//        [locationManager startUpdatingLocation];
//        
//        MKMapItem *currentLocationItem = [MKMapItem mapItemForCurrentLocation];
//        
//        if (myCustomer.locationCoordinate.coordinate.latitude == 0 || myCustomer.locationCoordinate.coordinate.longitude == 0)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Seçtiğiniz müşteri için navigasyon özelliği yoktur." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//        }
//        else
//        {
//            MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:reservation.checkOutOffice.locationCoordinate.coordinate addressDictionary:nil];
//            
//            MKMapItem *destinamtionLocItem = [[MKMapItem alloc] initWithPlacemark:place];
//            
//            destinamtionLocItem.name = [myCustomer name1];
//            
//            NSArray *mapItemsArray = [NSArray arrayWithObjects:currentLocationItem, destinamtionLocItem, nil];
//            
//            NSDictionary *dictForDirections = [NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
//            
//            [MKMapItem openMapsWithItems:mapItemsArray launchOptions:dictForDirections];
//        }
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Seçtiğiniz özelliği kullanabilmek için, versiyon güncellemesi yapmanız gerekmektedir." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
