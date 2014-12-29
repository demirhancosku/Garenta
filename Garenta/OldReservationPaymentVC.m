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
#import "AdditionalEquipment.h"

@interface OldReservationPaymentVC ()

@end

@implementation OldReservationPaymentVC

- (void)viewDidLoad {
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        NSString *name = @"";
        if (![[[ApplicationProperties getUser] middleName] isEqualToString:@""] && [[ApplicationProperties getUser] middleName] != nil) {
            name = [NSString stringWithFormat:@"%@ %@", [[ApplicationProperties getUser] name], [[ApplicationProperties getUser] middleName]];
        }
        else {
            name = [[ApplicationProperties getUser] name];
        }
        
        super.nameOnCardTextField.text = [NSString stringWithFormat:@"%@ %@", name, [[ApplicationProperties getUser] surname]];
        
    }
    else {
        
        NSString *name = @"";
        if (![[[super.reservation temporaryUser] middleName] isEqualToString:@""] && [[super.reservation temporaryUser] middleName] != nil) {
            name = [NSString stringWithFormat:@"%@ %@", [[super.reservation temporaryUser] name], [[super.reservation temporaryUser] middleName]];
        }
        else {
            name = [[super.reservation temporaryUser] name];
        }
        
        super.nameOnCardTextField.text = [NSString stringWithFormat:@"%@ %@", name, super.reservation.temporaryUser.surname];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"oldCardSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        [[super myPopoverController] dismissPopoverAnimated:YES];
        [self prepareTextFields:note];
        [self.tableView reloadData];
    }];
    

    if (self.reservationNumber != nil && ![self.reservationNumber isEqualToString:@""]) {
        [self getReservationDetailFromSAP];
    }
    else {
        [super.totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",_changeReservationPrice.floatValue]];
        // Do any additional setup after loading the view.
        [self prepareTextFields];
    }
}

- (void)getReservationDetailFromSAP {
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZCRM_GET_REZ_DETAIL"];
        
        [handler addImportParameter:@"IV_REZERVASYON" andValue:self.reservationNumber];
        
        [handler addTableForReturn:@"ET_ARAC_LISTE"];
        [handler addTableForReturn:@"ET_REZARVASYON"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            
            Reservation *reservation = [Reservation new];
            
            reservation.additionalEquipments = [NSMutableArray new];
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            self.changeReservationPrice = [NSDecimalNumber decimalNumberWithString:[[export valueForKey:@"ES_DETAIL"] valueForKey:@"TOPLAM_TUTAR"]];
            
            reservation.paymentType = [[export valueForKey:@"ES_DETAIL"] valueForKey:@"ODEME_TURU"];
            
            // araç bilgilerini dönen tablo
            NSDictionary *carTable = [response objectForKey:@"TABLES"];
            NSDictionary *responseList = [carTable objectForKey:@"ZKDK_ARAC_LISTE"];
            
            // belgedeki kalemleri dönen tablo
            NSDictionary *equipmentTable = [response objectForKey:@"TABLES"];
            NSDictionary *equipmentResponseList = [equipmentTable objectForKey:@"ZREZARVASYON_DETAIL"];
            
            if (responseList.count > 0)
            {
                NSString *plateNo = @"";
                NSString *chassisNo = @"";
                
                // REZERVASYONA EKLENEN KALEMLER
                for (NSDictionary *tempEqui in equipmentResponseList)
                {
                    AdditionalEquipment *equiObj = [AdditionalEquipment new];
                    
                    equiObj.materialNumber = [tempEqui valueForKey:@"MALZEME"];
                    equiObj.materialDescription = [tempEqui valueForKey:@"TANIM"];
                    equiObj.quantity = [[tempEqui valueForKey:@"MIKTAR"] intValue];
                    equiObj.price = [NSDecimalNumber decimalNumberWithString:[tempEqui valueForKey:@"TOPLAM_TUTAR"]];
                    equiObj.price = [equiObj.price decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",equiObj.quantity]]];
                    equiObj.updateStatus = @"U";
                    
                    if ([[tempEqui valueForKey:@"ZZARACGRUBU"] isEqualToString:@""])
                        [reservation.additionalEquipments addObject:equiObj];
                    else
                    {
                        plateNo = [tempEqui valueForKey:@"PLAKA_NO"];
                        chassisNo = [tempEqui valueForKey:@"SASE_NO"];
                    }
                }
                
                //araç seçimi yapılmışmı diye bakılıyor
                NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0031"];
                NSArray *filterResult = [reservation.additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                
                for (NSDictionary *tempDict in responseList)
                {
                    Car *tempCar = [Car new];
                    tempCar.pricing = [Price new];
                    
                    // ARABANIN FIYATI ELIMIZDE
                    [[tempCar pricing] setPayLaterPrice:[NSDecimalNumber decimalNumberWithString:[[export valueForKey:@"ES_DETAIL"] valueForKey:@"ARAC_TUTARI"]]];
                    [[tempCar pricing] setPayNowPrice:[NSDecimalNumber decimalNumberWithString:[[export valueForKey:@"ES_DETAIL"] valueForKey:@"ARAC_TUTARI"]]];
                    
                    [[tempCar pricing] setPriceWithKDV:tempCar.pricing.payLaterPrice];
                    
                    if (filterResult.count > 0)
                    {
                        [tempCar.pricing setCarSelectPrice:[[filterResult objectAtIndex:0] price]];
                    }
                    
                    [tempCar setMaterialCode:[tempDict valueForKey:@"MATNR"]];
                    [tempCar setMaterialName:[tempDict valueForKey:@"MAKTX"]];
                    [tempCar setPlateNo:plateNo];
                    [tempCar setChassisNo:chassisNo];
                    [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
                    [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
                    [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
                    [tempCar setSalesOffice:[tempDict valueForKey:@"MSUBE"]];
                    
                    NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
                    
                    [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]]];
                    
                    if (tempCar.image == nil) {
                        [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
                    }
                    
                    [tempCar setDoorNumber:[tempDict valueForKey:@"KAPI_SAYISI"]];
                    [tempCar setPassangerNumber:[tempDict valueForKey:@"YOLCU_SAYISI"]];
                    [tempCar setOfficeCode:[tempDict valueForKey:@"ASUBE"]];
                    
                    CarGroup *tempCarGroup = [CarGroup new];
                    
                    tempCarGroup = [CarGroup new];
                    
                    [tempCarGroup setGroupCode:[tempDict valueForKey:@"GRPKOD"]];
                    [tempCarGroup setGroupName:[tempDict valueForKey:@"GRPKODTX"]];
                    [tempCarGroup setTransmissonId:[tempDict valueForKey:@"SANZIMAN_TIPI_ID"]];
                    [tempCarGroup setTransmissonName:[tempDict valueForKey:@"SANZIMAN_TIPI"]];
                    [tempCarGroup setFuelId:[tempDict valueForKey:@"YAKIT_TIPI_ID"]];
                    [tempCarGroup setFuelName:[tempDict valueForKey:@"YAKIT_TIPI"]];
                    [tempCarGroup setBodyId:[tempDict valueForKey:@"KASA_TIPI_ID"]];
                    [tempCarGroup setBodyName:[tempDict valueForKey:@"KASA_TIPI"]];
                    [tempCarGroup setSegment:[tempDict valueForKey:@"SEGMENT"]];
                    [tempCarGroup setSegmentName:[tempDict valueForKey:@"SEGMENTTX"]];
                    
                    [tempCarGroup setMinAge:[[tempDict valueForKey:@"MIN_YAS"] integerValue]];
                    [tempCarGroup setMinDriverLicense:[[tempDict valueForKey:@"MIN_EHLIYET"] integerValue]];
                    [tempCarGroup setMinYoungDriverAge:[[tempDict valueForKey:@"GENC_SRC_YAS"] integerValue]];
                    [tempCarGroup setMinYoungDriverLicense:[[tempDict valueForKey:@"GENC_SRC_EHL"] integerValue]];
                    
                    [tempCarGroup setSampleCar:tempCar];
                    
                    if ([reservation.reservationType isEqualToString:@"10"])
                    {
                        reservation.selectedCar = [Car new];
                        reservation.selectedCar = tempCar;
                    }
                    
                    [reservation setSelectedCarGroup:tempCarGroup];
                }
            }
            else
            {
                alertString = @"Rezervazyon detayı bulunamamıştır.";
            }
        }
        else
        {
            alertString = @"Rezervazyon detayı bulunamamıştır.";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (![alertString isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            });
        }
    }
}

- (void)prepareTextFields
{
    if (super.creditCard.cardNumber == nil)
        [self setTextFieldsEnable:YES];
    else
        [self setTextFieldsEnable:NO];
    
    //    super.nameOnCardTextField.text = super.creditCard.nameOnTheCard;
    super.creditCardNumberTextField.text = super.creditCard.cardNumber;
    super.expirationMonthTextField.text = super.creditCard.expirationMonth;
    super.expirationYearTextField.text = super.creditCard.expirationYear;
    super.cvvTextField.text = super.creditCard.cvvNumber;
}

- (void)prepareTextFields:(NSNotification *)note
{
    super.creditCard = [CreditCard new];
    super.creditCard = note.object;

    if (super.creditCard.cardNumber == nil)
        [self setTextFieldsEnable:YES];
    else
        [self setTextFieldsEnable:NO];
        
//    super.nameOnCardTextField.text = super.creditCard.nameOnTheCard;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) //kart no
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c]) {
                return NO;
            }
        }
        
        if (range.location == 19) {
            return NO;
        }
        
        if ([string length] == 0)
        {
            return YES;
        }
        
        if ((range.location == 4) || (range.location == 9) || (range.location == 14)) {
            NSString *str = [NSString stringWithFormat:@"%@ ",super.creditCardNumberTextField.text];
            super.creditCardNumberTextField.text = str;
        }
        
        return YES;
    }
    
    if (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) // tarih ay-yıl alanı
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c]) {
                return NO;
            }
        }
        
        switch (textField.tag)
        {
            case 2:
                if (range.location == 2)
                    return NO;
                break;
            case 3:
                if (range.location == 4)
                    return NO;
                break;
            case 4:
                if (range.location == 3)
                    return NO;
                break;
            default:
                break;
        }
    }
    
    if (textField.tag == 5)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSLog(@"New string is: %@", newString);
        
        if ([newString isEqualToString:@""]) {
            newString = @"0";
        }
        
        if ([[_changeReservationPrice decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:newString]] floatValue] < 0) {
            return NO;
        }
        
        NSDecimalNumber *temp = [_changeReservationPrice decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:newString]];
        
        [super.totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",temp.floatValue]];
    }
    
    return YES;
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
        
        BOOL check = [Reservation changeReservationAtSAP:super.reservation andIsPayNow:YES andTotalPrice:_changeReservationPrice andGarentaTl:self.garentaTlTextField.text];
        
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

@end
