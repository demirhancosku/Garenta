//
//  ReservationApprovalVC.m
//  Garenta
//
//  Created by Alp Keser on 6/24/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationApprovalVC.h"
#import <EventKit/EventKit.h>
#import "SMSSoapHandler.h"
#import "MBProgressHUD.h"

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
    
    // minimum bilgilerden geldiyse önce login şifresi üretip, daha sonra bunu CRM'e yazıyoruz
    if (![[ApplicationProperties getUser] isLoggedIn]) {
        [self createUserPassword];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUserPassword {
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self sendPasswordToCrm:generatedCode];
    }
}

- (void)sendPasswordToCrm:(NSString *)newPassword
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *alertString = @"";
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_USER_PASSWORD"];
            
            NSData *newPasswordData = [newPassword dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *newPasswordEncoded = [newPasswordData base64EncodedStringWithOptions:0];
            
            [handler addImportParameter:@"IV_PARTNER" andValue:_reservation.temporaryUser.kunnr];
            [handler addImportParameter:@"IV_NEWPASSWORD" andValue:newPasswordEncoded];
            [handler addTableForReturn:@"ET_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *result = [export valueForKey:@"EV_SUBRC"];
                
                if (![result isEqualToString:@"0"]) {
//                    NSDictionary *tables = [response objectForKey:@"TABLES"];
//                    NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
//                    
//                    for (NSDictionary *temp in etReturn) {
//                        if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
//                            alertString = [temp valueForKey:@"MESSAGE"];
//                        }
//                    }
//                    
//                    if ([alertString isEqualToString:@""]) {
//                        alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
//                    }
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:newPasswordEncoded forKey:@"PASSWORD"];
                    NSString *phoneNumber = self.reservation.temporaryUser.mobile;
                    
                    BOOL success = [SMSSoapHandler sendSMSMessage:newPassword toNumber:phoneNumber];
                    
                    if (success) {
                        alertString = @"Şifreniz SMS ile gönderilmiştir. Mail adresiniz ve şifrenizi kullanarak giriş yapabilirsiniz.";
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if (![alertString isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
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
