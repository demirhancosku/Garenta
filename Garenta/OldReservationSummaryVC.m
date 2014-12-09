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
#import "AdditionalEquipment.h"

@interface OldReservationSummaryVC ()

@end

@implementation OldReservationSummaryVC

- (void)viewDidLoad {
    //UPSELL ile gelince buraya giriyor
    if (_totalPrice != nil)
    {
        NSDecimalNumber *payNowPrice;
        NSDecimalNumber *payLaterPrice;
        NSDecimalNumber *documentPrice;
        
        if (super.reservation.upsellSelectedCar) {
            
            [self changeCarSelectionPrice];
            
            payNowPrice = [[super.reservation.upsellSelectedCar.pricing.payNowPrice decimalNumberByAdding:super.reservation.upsellSelectedCar.pricing.carSelectPrice] decimalNumberBySubtracting:_carSelectionPriceDifference];
            payLaterPrice = [[super.reservation.upsellSelectedCar.pricing.payLaterPrice decimalNumberByAdding:super.reservation.upsellSelectedCar.pricing.carSelectPrice] decimalNumberBySubtracting:_carSelectionPriceDifference];
            documentPrice = super.reservation.upsellSelectedCar.pricing.documentCarPrice;
        }
        else
        {
            payNowPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payNowPrice;
            payLaterPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice;
            documentPrice = super.reservation.upsellCarGroup.sampleCar.pricing.documentCarPrice;
        }
        
        NSDecimalNumber *payNowDifference = [payNowPrice decimalNumberBySubtracting:documentPrice];
        
        NSDecimalNumber *payLaterDifference = [payLaterPrice decimalNumberBySubtracting:documentPrice];
        
        // araca rezervasyon yaratılmış ve upsell/downsell yapılarak gruba tercih edilirse
        if ([super.reservation.reservationType isEqualToString:@"10"] && super.reservation.upsellSelectedCar == nil) {
            NSDecimalNumber *price = [self deleteCarSelection];
            payNowDifference = [payNowDifference decimalNumberBySubtracting:price];
            payLaterDifference = [payLaterDifference decimalNumberBySubtracting:price];
        }
        
        if ([super.reservation.paymentType isEqualToString:@"1"])
            _changeReservationPrice = payNowDifference;
        else
            _changeReservationPrice = [[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: payLaterDifference];
        
        super.isTotalPressed = NO;
        
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
        if (super.reservation.upsellSelectedCar) {
            brandModelString = [NSString stringWithFormat:@"%@ %@",super.reservation.upsellSelectedCar.brandName,super.reservation.upsellSelectedCar.modelName];
            boldLenght = brandModelString.length;
        }
        else
        {
            brandModelString = [NSString stringWithFormat:@"%@ %@ ve benzeri",super.reservation.upsellCarGroup.sampleCar.brandName,super.reservation.upsellCarGroup.sampleCar.modelName];
            boldLenght = brandModelString.length;
        }
        
        const NSRange range = NSMakeRange(0,boldLenght);
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:brandModelString
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        [super.brandModelLabel setAttributedText:attributedText];
        
        if (super.reservation.upsellSelectedCar)
            [super.carImageView setImage:super.reservation.upsellSelectedCar.image];
        else
            [super.carImageView setImage:super.reservation.upsellCarGroup.sampleCar.image];
        
        [super.fuelLabel setText:super.reservation.upsellCarGroup.fuelName];
        [super.transmissionLabel setText:super.reservation.upsellCarGroup.transmissonName];
        [super.acLabel setText:@"Klima"];
        [super.passangerNumberLabel setText:super.reservation.upsellCarGroup.sampleCar.passangerNumber];
        [super.doorCountLabel setText:super.reservation.upsellCarGroup.sampleCar.doorNumber];
    }
    else
    {
        [super viewDidLoad];
    }
    // Do any additional setup after loading the view.
}

- (void)changeCarSelectionPrice
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0031"];
    NSArray *predicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
    _carSelectionPriceDifference = [NSDecimalNumber decimalNumberWithString:@"0"];

    if (predicateArray.count > 0) {
        AdditionalEquipment *temp = [predicateArray objectAtIndex:0];
        
        _carSelectionPriceDifference = temp.price;
        
        temp.price = super.reservation.upsellSelectedCar.pricing.carSelectPrice;
    }
}

- (NSDecimalNumber *)deleteCarSelection
{
    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
    NSArray *equipmentPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
    
    AdditionalEquipment *temp = [AdditionalEquipment new];
    
    if (equipmentPredicateArray.count > 0) {
        temp = [equipmentPredicateArray objectAtIndex:0];
        temp.updateStatus = @"D";
    }
    
    return temp.price;
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
    
    // REZERVASYON ŞİMDİ ÖDE İLE YAPILDIYSA, UPDATE YAPILIRKEN SONRA ÖDE YAPILAMAZ!
    if ([super.reservation.paymentType isEqualToString:@"1"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Rezervasyonunuz 'Şimdi Öde' rezervasyondur, sonra ödeme yapılamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    // REZERVASYONDA KAYAR İŞLEMİ VARSA ŞİMDİ ÖDE YAPILMASI ZORUNLUDUR!
    else if ([super.reservation.updateStatus isEqualToString:@"KAY"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Rezervasyonunuza kaydırma işlemi yapmak istediğiniz için 'Şimdi Öde' seçeneği seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    //HERŞEY OKEYSE KULLANICIYA SOR
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
    UILabel *totalPriceText;
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
                
                if (_totalPrice != nil) {
                    totalPriceText = (UILabel*)[aCell viewWithTag:2];
                    if (_changeReservationPrice.floatValue > 0) {
                        [totalPriceText setText:@"Tahsil edilecek tutar:"];
                    }
                    else if (_changeReservationPrice.floatValue < 0){
                        [totalPriceText setText:@"İade edilecek tutar:"];
                    }
                }
                
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
                
                if (_totalPrice != nil)
                {
                    NSDecimalNumber *payNowPrice;
                    NSDecimalNumber *payLaterPrice;
                    NSDecimalNumber *documentPrice;
                    
                    if (super.reservation.upsellSelectedCar) {
                        payNowPrice = [[super.reservation.upsellSelectedCar.pricing.payNowPrice decimalNumberByAdding:super.reservation.upsellSelectedCar.pricing.carSelectPrice] decimalNumberBySubtracting:_carSelectionPriceDifference];
                        payLaterPrice = [[super.reservation.upsellSelectedCar.pricing.payLaterPrice decimalNumberByAdding:super.reservation.upsellSelectedCar.pricing.carSelectPrice] decimalNumberBySubtracting:_carSelectionPriceDifference];
                        documentPrice = super.reservation.upsellSelectedCar.pricing.documentCarPrice;
                    }
                    else
                    {
                        payNowPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payNowPrice;
                        payLaterPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice;
                        documentPrice = super.reservation.upsellCarGroup.sampleCar.pricing.documentCarPrice;
                    }
                    
                    NSDecimalNumber *payNowDifference = [payNowPrice decimalNumberBySubtracting:documentPrice];
                    
                    NSDecimalNumber *payLaterDifference = [payLaterPrice decimalNumberBySubtracting:documentPrice];
                    
                    // araca rezervasyon yaratılmış ve upsell/downsell yapılarak gruba tercih edilirse
                    if ([super.reservation.reservationType isEqualToString:@"10"] && super.reservation.upsellSelectedCar == nil)
                    {
                        NSDecimalNumber *price = [self deleteCarSelection];
                        payNowDifference = [payNowDifference decimalNumberBySubtracting:price];
                        payLaterDifference = [payLaterDifference decimalNumberBySubtracting:price];
                    }
                    
                    if ([super.reservation.paymentType isEqualToString:@"1"])
                    {
                        [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",payNowDifference.floatValue] forState:UIControlStateNormal];
                        [payLaterButton setTitle:[NSString stringWithFormat:@"-"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: payNowDifference].floatValue] forState:UIControlStateNormal];
                        [payLaterButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: payLaterDifference].floatValue] forState:UIControlStateNormal];
                    }
                }
                else{
                    [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue] forState:UIControlStateNormal];
                    [payLaterButton setTitle:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue] forState:UIControlStateNormal];
                }
                
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
        BOOL isPayNow = NO;
        
        if (_changeReservationPrice.floatValue < 0) {
            isPayNow = YES;
        }
        
        BOOL check = [Reservation changeReservationAtSAP:super.reservation andIsPayNow:isPayNow andTotalPrice:_changeReservationPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (check) {
                [self performSegueWithIdentifier:@"toOldReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

@end
