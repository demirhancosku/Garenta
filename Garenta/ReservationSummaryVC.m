//
//  ReservationSummaryVC.m

//  Garenta

//
//  Created by Alp Keser on 6/9/14.    //  Copyright (c) 2014 Kerem Balaban. All rights reserved.
#import "ReservationSummaryVC.h"
#import "PaymentTableViewController.h"
#import "ReservationApprovalVC.h"
#import "ReservationScopePopoverVC.h"
#import "MBProgressHUD.h"
#import "AgreementsVC.h"

@interface ReservationSummaryVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *brandModelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UILabel *fuelLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *acLabel;
@property (weak, nonatomic) IBOutlet UILabel *passangerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorCountLabel;

@end

@implementation ReservationSummaryVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad

{
    [super viewDidLoad];
    
    _isTotalPressed =NO;
    
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    UIColor *foregroundColor = [UIColor lightGrayColor];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName, nil];
    NSString *brandModelString;
    NSUInteger boldLenght = 0;
    if (_reservation.selectedCar) {
        brandModelString = [NSString stringWithFormat:@"%@ %@",_reservation.selectedCar.brandName,_reservation.selectedCar.modelName];
        boldLenght = brandModelString.length;
    }else{
        brandModelString = [NSString stringWithFormat:@"%@ %@",_reservation.selectedCarGroup.sampleCar.brandName, _reservation.selectedCarGroup.sampleCar.modelName];
        boldLenght = brandModelString.length;
        brandModelString = [NSString stringWithFormat:@"%@ yada benzeri",brandModelString];
    }
    
    const NSRange range = NSMakeRange(0,boldLenght);
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:brandModelString
                                           attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [_brandModelLabel setAttributedText:attributedText];
    
    [_carImageView setImage:_reservation.selectedCarGroup.sampleCar.image];
    [_fuelLabel setText:_reservation.selectedCarGroup.fuelName];
    [_transmissionLabel setText:_reservation.selectedCarGroup.transmissonName];
    [_acLabel setText:@"Klima"];
    [_passangerNumberLabel setText:_reservation.selectedCarGroup.sampleCar.passangerNumber];
    [_doorCountLabel setText:_reservation.selectedCarGroup.sampleCar.doorNumber];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning

{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rezervasyon

- (void)createReservation {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        _reservation.reservationNumber = [Reservation createReservationAtSAP:_reservation andIsPayNow:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (_reservation.reservationNumber != nil && ![_reservation.reservationNumber isEqualToString:@""]) {
                [self performSegueWithIdentifier:@"toReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isTotalPressed) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *aCell;
    UILabel *checkOutOffice;
    UILabel *checkInOffice;
    UILabel *checkOutTime;
    UILabel *checkInTime;
    UILabel *totalPrice;
    UIButton *payNowButton;
    UIButton *payLaterButton;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yyy/HH:mm"];
    if (!_isTotalPressed) {
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:_reservation.checkOutOffice.subOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:_reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:_reservation.checkInOffice.subOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:_reservation.checkInTime]];
                
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"totalPaymentCell" forIndexPath:indexPath];
                totalPrice = (UILabel*)[aCell viewWithTag:1];
                [totalPrice setText:[NSString stringWithFormat:@"%@",[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0" andIsMontlyRent:NO]]];
                
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:_reservation.checkOutOffice.subOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:_reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:_reservation.checkInOffice.subOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:_reservation.checkInTime]];
                
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"detailPayNowLaterCell" forIndexPath:indexPath];
                break;
            case 3:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"payNowLaterButtonsCell" forIndexPath:indexPath];
                payNowButton = (UIButton*)[aCell viewWithTag:1];
                payLaterButton = (UIButton*)[aCell viewWithTag:2];
                
                // Aylık
                if (_reservation.etExpiry.count > 0) {
                    [payNowButton setTitle:[NSString stringWithFormat:@"%.02fTL(1. Taksit)",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0" andIsMontlyRent:YES] floatValue]] forState:UIControlStateNormal];
                    [[payNowButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
                }
                // Günlük
                else {
                    [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0" andIsMontlyRent:NO] floatValue]] forState:UIControlStateNormal];
                }
                
                if (_reservation.etExpiry.count > 0) {
                    [payLaterButton setTitle:[NSString stringWithFormat:@"%.02fTL(1. Taksit)",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:@"0" andIsMontlyRent:YES] floatValue]] forState:UIControlStateNormal];
                    [[payLaterButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
                }
                // Günlük
                else {
                    [payLaterButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:@"0" andIsMontlyRent:NO] floatValue]] forState:UIControlStateNormal];
                }

                break;
            default:
                break;
        }
    }
    return aCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_isTotalPressed) {
        switch (indexPath.row) {
            case 0:
                return 92;
                break;
            case 1:
                return 35;
                break;
            case 2:
                return 50;
                break;
            default:
                return 60;
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                return 92;
                break;
            case 1:
                return 35;
                break;
            case 2:
                return 35;
                break;
            case 3:
                return 50;
                break;
            default:
                return 60;
                break;
        }
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:
            //popover
            [self performSegueWithIdentifier:@"toPopoverVCSegue" sender:(UITableViewCell*)[_tableView cellForRowAtIndexPath:indexPath]];
            break;
        case 2:
            [self totalButtonPressed];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toPaymentVCSegue"]) {
        [(PaymentTableViewController*)[segue destinationViewController] setReservation:_reservation];
    }
    if ([[segue identifier] isEqualToString:@"toReservationApprovalVCSegue"]) {
        [(ReservationApprovalVC*)[segue destinationViewController] setReservation:_reservation];
    }
    
    if ([segue.identifier isEqualToString:@"toPopoverVCSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 280);
        
        [(ReservationScopePopoverVC *)[segue destinationViewController] setReservation:_reservation];
        
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"toAgreementVCSegue"]) {
        [(AgreementsVC*)[segue destinationViewController] setHtmlName:@"RentingAgreement"];
        [(AgreementsVC*)[segue destinationViewController] setAgreementName:@"Kiralama Anlaşması"];
    }
}

- (void)totalButtonPressed{
    if (_isTotalPressed) {
        _isTotalPressed = NO;
    }else{
        _isTotalPressed = YES;
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)payNowPressed:(id)sender {
    [self performSegueWithIdentifier:@"toPaymentVCSegue" sender:self];
}

- (IBAction)payLaterPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kiralama anlaşmasını kabul edip, rezervasyonuzun yaratılmasını istediğinize emin misiniz ?" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Kiralama Anlaşması", @"Kabul Ediyorum", nil];
    [alert setTag:1];
    [alert show];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"toAgreementVCSegue" sender:self];
        }
        if (buttonIndex == 2) {
            [self createReservation];
        }
    }
}

@end

