//
//  OldReservationPaymentVC.m
//  Garenta
//
//  Created by Kerem Balaban on 27.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationPaymentVC.h"
#import "MBProgressHUD.h"
#import "OldReservationApprovalVC.h"

@interface OldReservationPaymentVC ()

@end

@implementation OldReservationPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [super.totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue]];
    // Do any additional setup after loading the view.
    [self prepareTextFields];
}

- (void)prepareTextFields
{
    if (super.creditCard.cardNumber == nil)
        [self setTextFieldsEnable:YES];
    else
        [self setTextFieldsEnable:NO];
    
    super.nameOnCardTextField.text = super.creditCard.nameOnTheCard;
    super.creditCardNumberTextField.text = super.creditCard.cardNumber;
    super.expirationMonthTextField.text = super.creditCard.expirationMonth;
    super.expirationYearTextField.text = super.creditCard.expirationYear;
    super.cvvTextField.text = super.creditCard.cvvNumber;
}

- (void)setTextFieldsEnable:(BOOL)boolean
{
    super.nameOnCardTextField.enabled = boolean;
    super.creditCardNumberTextField.enabled = boolean;
    super.expirationMonthTextField.enabled = boolean;
    super.expirationYearTextField.enabled = boolean;
    super.cvvTextField.enabled = boolean;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)reservationCompleteButtonPressed:(id)sender {
    if ([super checkRequiredFields])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Rezervasyonunuz güncellenecektir onaylıyor musunuz?" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Onayla", nil];
        [alert setTag:1];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self changeReservation];
        }
    }
}

- (void)changeReservation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        CreditCard *tempCard = [[CreditCard alloc] init];
        
        if (self.creditCard.uniqueId != nil) {
            tempCard.uniqueId = self.creditCard.uniqueId;
        }
        else {
            tempCard.cardNumber = [self.creditCardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            tempCard.nameOnTheCard = self.nameOnCardTextField.text;
            tempCard.cvvNumber = self.cvvTextField.text;
            tempCard.expirationYear = self.expirationYearTextField.text;
            tempCard.expirationMonth = self.expirationMonthTextField.text;
        }
        
        super.reservation.paymentNowCard = tempCard;
        
        BOOL check = [Reservation changeReservationAtSAP:super.reservation andIsPayNow:YES andTotalPrice:_changeReservationPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (check) {
                [self performSegueWithIdentifier:@"toOldReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"toOldReservationApprovalVCSegue"]) {
        [(OldReservationApprovalVC *)[segue destinationViewController] setReservation:super.reservation];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
