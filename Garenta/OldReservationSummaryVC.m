//
//  OldReservationSummaryVC.m
//  Garenta
//
//  Created by Kerem Balaban on 27.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationSummaryVC.h"
#import "MBProgressHUD.h"
#import "OldReservationPaymentVC.h"
#import "OldReservationApprovalVC.h"

@interface OldReservationSummaryVC ()

@end

@implementation OldReservationSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)payNowPressed:(id)sender {
    [self performSegueWithIdentifier:@"toOldReservationPaymentSegue" sender:self];
}

- (IBAction)payLaterPressed:(id)sender {
    
    if ([super.reservation.paymentType isEqualToString:@"1"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Rezervasyonunuz 'Şimdi Öde' rezervasyondur, sonra ödeme yapılamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Rezervasyonunuz güncellenecektir, onaylıyor musunuz?" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Onayla", nil];
    [alert setTag:1];
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    if (!super.isTotalPressed) {
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:super.reservation.checkOutOffice.subOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:super.reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:super.reservation.checkInOffice.subOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:super.reservation.checkInTime]];
                
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"totalPaymentCell" forIndexPath:indexPath];
                totalPrice = (UILabel*)[aCell viewWithTag:1];
                [totalPrice setText:[NSString stringWithFormat:@"%.02f",_changeReservationPrice.floatValue]];
                
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:super.reservation.checkOutOffice.subOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:super.reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:super.reservation.checkInOffice.subOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:super.reservation.checkInTime]];
                
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
                
                [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue] forState:UIControlStateNormal];
                [payLaterButton setTitle:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue] forState:UIControlStateNormal];
                
                break;
            default:
                break;
        }
    }
    
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *alertMessage = @"";
    
    if (indexPath.row == 2 && _changeReservationPrice.floatValue < 0)
    {
        alertMessage = [NSString stringWithFormat:@"%.02f TL iade edilecek ve %@ numaralı rezervasyonunuz güncellenecektir, onaylıyor musunuz?",_changeReservationPrice.floatValue,super.reservation.reservationNumber];
    }
    else if (indexPath.row == 2 && _changeReservationPrice.floatValue == 0)
    {
        alertMessage = [NSString stringWithFormat:@"%@ numaralı rezervasyonunuz güncellenecektir, onaylıyor musunuz?",super.reservation.reservationNumber];
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    if (![alertMessage isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertMessage delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Onayla", nil];
        [alert setTag:1];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self updateReservation];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"toOldReservationPaymentSegue"])
    {
        [(OldReservationPaymentVC *)[segue destinationViewController] setChangeReservationPrice:_changeReservationPrice];
        [(OldReservationPaymentVC *)[segue destinationViewController] setReservation:super.reservation];
        if (![super.reservation.paymentNowCard.uniqueId isEqualToString:@""]) {
            [(OldReservationPaymentVC *)[segue destinationViewController] setCreditCard:[self prepareCreditCard]];
        }
        
    }
    
    if ([[segue identifier] isEqualToString:@"toOldReservationApprovalVCSegue"]) {
        [(OldReservationApprovalVC *)[segue destinationViewController] setReservation:super.reservation];
    }
    
}

//SADECE REZERVASYONDAKİ KARTLA İŞLEM YAPILABİLMESİ İÇİN
- (CreditCard *)prepareCreditCard
{
    NSString *firstFour = [super.reservation.paymentNowCard.uniqueId substringToIndex:4];
    NSString *nextTwo   = [[super.reservation.paymentNowCard.uniqueId substringFromIndex:4] substringToIndex:2];
    NSString *lastFour  = [[super.reservation.paymentNowCard.uniqueId substringFromIndex:16] substringToIndex:4];
    
    _creditCard = [CreditCard new];
    
    _creditCard.nameOnTheCard = [NSString stringWithFormat:@"%@ %@",[[ApplicationProperties getUser] name],[[ApplicationProperties getUser] surname]];
    _creditCard.cardNumber = [NSString stringWithFormat:@"%@ %@** **** %@",firstFour,nextTwo,lastFour];;
    _creditCard.expirationMonth = @"**";
    _creditCard.expirationYear = @"****";
    _creditCard.cvvNumber = @"***";
    _creditCard.uniqueId = super.reservation.paymentNowCard.uniqueId;
    
    return _creditCard;
}

- (void)updateReservation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        BOOL check = [Reservation changeReservationAtSAP:super.reservation andIsPayNow:NO andTotalPrice:_changeReservationPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (check) {
                [self performSegueWithIdentifier:@"toOldReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

@end
