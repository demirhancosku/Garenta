//
//  ReservationApprovalVC.m
//  Garenta
//
//  Created by Alp Keser on 6/24/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationApprovalVC.h"
#import <EventKit/EventKit.h>
@interface ReservationApprovalVC ()
@property (weak, nonatomic) IBOutlet UILabel *reservationNumberLabel;
- (IBAction)returnToMenu:(id)sender;
- (IBAction)addEventToCalendar:(id)sender;

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
    
    // rezervasyon yaratıldığında timer sıfırlanıyor! (Teklifleri göstere tıkladığında aktifleşiyor,  hesaplamaları App delegate içinde)
    [[ApplicationProperties getTimer] invalidate];
    [ApplicationProperties setTimerObject:0];
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)returnToMenu:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (IBAction)addEventToCalendar:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hatırlatma" message:@"Rezervasyonunuzu takviminize kaydet istiyor musunuz?" delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles:@"Evet", nil];
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        [self addEvent];
    }
}

- (void)addEvent{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = @"Garenta Rezervasyonunuz";
        event.startDate = _reservation.checkOutTime; //today
        event.endDate = [_reservation checkInTime];  //set 1 hour meeting
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
//        NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Başarılı" message:@"Hatırlatmanız eklenmiştir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [alert show];
        });
    }
    ];

    
}
@end
