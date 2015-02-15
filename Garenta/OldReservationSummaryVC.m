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
#import "ETExpiryObject.h"
#import "IDController.h"

@interface OldReservationSummaryVC ()

@end

@implementation OldReservationSummaryVC

- (void)viewDidLoad {
    //UPSELL ile gelince buraya giriyor
    if (_totalPrice != nil)
    {
        _youngDriverDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
        [self addYoungDriver];
        [self checkWinterTyre]; //kış lastiği kontrolü ekleme ayda çıkartma
        
        [self findPayNowPayLaterDifference];
        
        if ([super.reservation.paymentType isEqualToString:@"2"] || [super.reservation.paymentType isEqualToString:@"6"])
            _changeReservationPrice = [[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding:_payNowDifference];
        else
            _changeReservationPrice = _payNowDifference;
        
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
    if (_carSelectionPriceDifference == nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0031"];
        NSArray *predicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
        _carSelectionPriceDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
        
        if (predicateArray.count > 0) {
            AdditionalEquipment *temp = [predicateArray objectAtIndex:0];
            _carSelectionPriceDifference = [super.reservation.upsellSelectedCar.pricing.carSelectPrice decimalNumberBySubtracting:temp.price];
            
            temp.price = super.reservation.upsellSelectedCar.pricing.carSelectPrice;
        }
        else
        {
            _carSelectionPriceDifference = super.reservation.upsellSelectedCar.pricing.carSelectPrice;
        }
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
    
    //13.02.2015 Ata Cengiz Sözleşme Süre uzatma
    if (super.reservation.isContract) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Sözleşme süre uzatma sadece şimdi öde ile devam edilebilir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    //13.02.2015 Ata Cengiz Sözleşme Süre uzatma

    // REZERVASYON ŞİMDİ ÖDE İLE YAPILDIYSA, UPDATE YAPILIRKEN SONRA ÖDE YAPILAMAZ!
    if (![super.reservation.paymentType isEqualToString:@"2"] && ![super.reservation.paymentType isEqualToString:@"6"])
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
                    [self findPayNowPayLaterDifference];
                    
                    if ([super.reservation.paymentType isEqualToString:@"2"] || [super.reservation.paymentType isEqualToString:@"6"])
                    {
                        [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: _payNowDifference].floatValue] forState:UIControlStateNormal];
                        [payLaterButton setTitle:[NSString stringWithFormat:@"%.02f TL",[[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: _payLaterDifference].floatValue] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [payNowButton setTitle:[NSString stringWithFormat:@"%.02f TL",_payNowDifference.floatValue] forState:UIControlStateNormal];
                        [payLaterButton setTitle:[NSString stringWithFormat:@"-"] forState:UIControlStateNormal];
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
            if ([[ApplicationProperties getUser] isLoggedIn]) {
                [self checkIdentityControl];
            }
            else{
                [self updateReservation];
            }
        }
    }
}

- (void)findPayNowPayLaterDifference
{
    NSDecimalNumber *payNowPrice;
    NSDecimalNumber *payLaterPrice;
    NSDecimalNumber *documentCarPrice;
    
    _payNowDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
    _payLaterDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    if (super.reservation.upsellSelectedCar) {
        [self changeCarSelectionPrice];
        
        if (super.reservation.etExpiry.count > 0) {
            for (ETExpiryObject *temp in super.reservation.etExpiry) {
                if ([temp.carGroup isEqualToString:super.reservation.upsellCarGroup.groupCode] && [temp.modelID isEqualToString:super.reservation.upsellSelectedCar.modelId] && [temp.brandID isEqualToString:super.reservation.upsellSelectedCar.brandId]) {
                    
                    payNowPrice = [temp.totalPrice decimalNumberByAdding:_carSelectionPriceDifference];
                    payLaterPrice = [temp.totalPrice decimalNumberByAdding:_carSelectionPriceDifference];
                    documentCarPrice = super.reservation.upsellSelectedCar.pricing.documentCarPrice;
                    
                    break;
                }
            }
        }
        else{
            payNowPrice = [super.reservation.upsellSelectedCar.pricing.payNowPrice decimalNumberByAdding:_carSelectionPriceDifference];
            payLaterPrice = [super.reservation.upsellSelectedCar.pricing.payLaterPrice decimalNumberByAdding:_carSelectionPriceDifference];
            documentCarPrice = super.reservation.upsellSelectedCar.pricing.documentCarPrice;
        }
    }
    else
    {
        if (super.reservation.etExpiry.count > 0) {
            for (ETExpiryObject *temp in super.reservation.etExpiry) {
                if ([temp.carGroup isEqualToString:super.reservation.upsellCarGroup.groupCode] && [temp.modelID isEqualToString:super.reservation.upsellCarGroup.sampleCar.modelId] && [temp.brandID isEqualToString:super.reservation.upsellCarGroup.sampleCar.brandId]) {
                    
                    payNowPrice = temp.totalPrice;
                    payLaterPrice = temp.totalPrice;
                    documentCarPrice = super.reservation.upsellCarGroup.sampleCar.pricing.documentCarPrice;
                    
                    break;
                }
            }
        }
        else{
            payNowPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payNowPrice;
            payLaterPrice = super.reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice;
            documentCarPrice = super.reservation.upsellCarGroup.sampleCar.pricing.documentCarPrice;
        }
    }
    
    _payNowDifference = [payNowPrice decimalNumberBySubtracting:documentCarPrice];
    _payLaterDifference = [payLaterPrice decimalNumberBySubtracting:documentCarPrice];
    
    _payNowDifference = [_payNowDifference decimalNumberByAdding:_youngDriverDifference];
    _payLaterDifference = [_payLaterDifference decimalNumberByAdding:_youngDriverDifference];
    
    _payNowDifference = [_payNowDifference decimalNumberByAdding:_winterTyreDifference];
    _payLaterDifference = [_payLaterDifference decimalNumberByAdding:_winterTyreDifference];
    
    // araca rezervasyon yaratılmış ve upsell/downsell yapılarak gruba tercih edilirse
    if ([super.reservation.reservationType isEqualToString:@"10"] && super.reservation.upsellSelectedCar == nil)
    {
        NSDecimalNumber *price = [self deleteCarSelection];
        _payNowDifference = [_payNowDifference decimalNumberBySubtracting:price];
        _payLaterDifference = [_payLaterDifference decimalNumberBySubtracting:price];
    }
}

- (void)addYoungDriver
{
    NSDecimalNumber *youngDriverPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    NSDecimalNumber *maxSafePrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    NSDecimalNumber *currentYoungDriverPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    NSDecimalNumber *currentMaxSafePrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    // güncel Genç Sürücü ve güncel Maksimum Güvence fiyatlarını alıyoruz
    NSPredicate *currentYoungDriver = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0007"];
    NSArray *currentYoungDriverArr = [_additionalEquipments filteredArrayUsingPredicate:currentYoungDriver];
    
    NSPredicate *currentMaxSafe = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0012"];
    NSArray *currentMaxSafeArr = [_additionalEquipments filteredArrayUsingPredicate:currentMaxSafe];
    
    
    //Rezervasyonda daha önce Genç Sürücü ve güncel Maksimum Güvence eklenmişmi kontrolü yapıyoruz
    NSPredicate *youngDriver = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0007"];
    NSArray *youngDriverArr = [super.reservation.additionalEquipments filteredArrayUsingPredicate:youngDriver];
    
    NSPredicate *maxSafe = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0012"];
    NSArray *maxSafeArr = [super.reservation.additionalEquipments filteredArrayUsingPredicate:maxSafe];
    
    if (currentYoungDriverArr.count > 0) {
        currentYoungDriverPrice = [[currentYoungDriverArr objectAtIndex:0] price];
    }
    
    if (currentMaxSafeArr.count > 0) {
        currentMaxSafePrice = [[currentMaxSafeArr objectAtIndex:0] price];
    }
    
    // belgede genç sürücü daha önce eklenmişse, ve yeni seçtiği araçta genç sürücü varsa fiyat güncelliyo
    if (youngDriverArr.count > 0 && _isYoungDriver) {
        AdditionalEquipment *temp = [youngDriverArr objectAtIndex:0];
        youngDriverPrice = temp.price;
        
        temp.price = currentYoungDriverPrice;
        temp.updateStatus = @"U";
    }
    
    // belgede genç sürücü daha önce eklenmişse, ve yeni seçtiği araçta genç sürücü yoksa siliyo
    else if (youngDriverArr.count > 0 && !_isYoungDriver) {
        AdditionalEquipment *temp = [youngDriverArr objectAtIndex:0];
        youngDriverPrice = temp.price;
        temp.updateStatus = @"D";
    }
    // belgede daha önce eklenmiş genç sürücü yoksa ve yeni seçtiği araç genç sürücüyse ekliyo
    else if (youngDriverArr.count == 0 && _isYoungDriver) {
        AdditionalEquipment *temp = [currentYoungDriverArr objectAtIndex:0];
        temp.updateStatus = @"I";
        [super.reservation.additionalEquipments addObject:temp];
    }
    
    
    // belgede maksimum güvence daha önce eklenmişse, ve yeni seçtiği araçta genç sürücü varsa fiyat güncelliyo
    if (maxSafeArr.count > 0 && _isYoungDriver) {
        AdditionalEquipment *temp = [maxSafeArr objectAtIndex:0];
        maxSafePrice = temp.price;
        
        temp.price = currentMaxSafePrice;
        temp.updateStatus = @"U";
    }
    // belgede maksimum güvence daha önce eklenmişse, ve yeni seçtiği araçta genç sürücüyse değilse siliyoruz
    else if (maxSafeArr.count > 0 && !_isYoungDriver) {
        AdditionalEquipment *temp = [maxSafeArr objectAtIndex:0];
        maxSafePrice = temp.price;
        temp.updateStatus = @"D";
    }
    // belgede daha önce eklenmiş maks.Güvence yoksa ve yeni seçtiği araç genç sürücüyse ekliyo
    else if (youngDriverArr.count == 0 && _isYoungDriver)
    {
        AdditionalEquipment *temp = [currentMaxSafeArr objectAtIndex:0];
        temp.updateStatus = @"I";
        [super.reservation.additionalEquipments addObject:temp];
    }
    
    if (_isYoungDriver) {
        _youngDriverDifference = [[[[_youngDriverDifference decimalNumberByAdding:currentYoungDriverPrice] decimalNumberByAdding:currentMaxSafePrice] decimalNumberBySubtracting:youngDriverPrice] decimalNumberBySubtracting:maxSafePrice];
    }
    else
    {
        _youngDriverDifference = [[_youngDriverDifference decimalNumberBySubtracting:maxSafePrice] decimalNumberBySubtracting:youngDriverPrice];
    }
    
}

- (void)checkWinterTyre
{
    _winterTyreDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    if (super.reservation.upsellSelectedCar) {
        //kış lastiği olayı
        NSPredicate *winterTyre = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0014"];
        NSArray *winterTyreArr = [super.reservation.additionalEquipments filteredArrayUsingPredicate:winterTyre];
        
        //eğer rezervasyonda kış lastiği varsa ve seçilen araçta kış lastiği seçeneği yoksa siliyoruz.
        if (winterTyreArr.count > 0 && [super.reservation.upsellSelectedCar.winterTire isEqualToString:@""]) {
            [[winterTyreArr objectAtIndex:0] setQuantity:0];
            [[winterTyreArr objectAtIndex:0] setUpdateStatus:@"D"];
            _winterTyreDifference = [[[winterTyreArr objectAtIndex:0] price] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }
        //eğer rezervasyonda kış lastiği varsa ve seçilen araçta kış lastiği eskisinden farklıysa farkını buluyoruz
        else if (winterTyreArr.count > 0 && [super.reservation.upsellSelectedCar.winterTire isEqualToString:@"X"]) {
            NSPredicate *equi = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0014"];
            NSArray *equiArr = [self.additionalEquipments filteredArrayUsingPredicate:equi];
            
            [[winterTyreArr objectAtIndex:0] setPrice:[[equiArr objectAtIndex:0] price]];
            _winterTyreDifference = [[[equiArr objectAtIndex:0] price] decimalNumberBySubtracting:[[winterTyreArr objectAtIndex:0] price]];
        }
        // eğer rezervasyonda kış lastiği yoksa ve seçilen araçta varsa kış lastiği ücretini ekliyoruz.
        else if (winterTyreArr.count == 0 && [super.reservation.upsellSelectedCar.winterTire isEqualToString:@"X"])
        {
            NSPredicate *equi = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0014"];
            NSArray *equiArr = [self.additionalEquipments filteredArrayUsingPredicate:equi];
            
            _winterTyreDifference = [[equiArr objectAtIndex:0] price];
            [[equiArr objectAtIndex:0] setQuantity:1];
            [[equiArr objectAtIndex:0] setUpdateStatus:@"I"];
            [super.reservation.additionalEquipments addObject:[equiArr objectAtIndex:0]];
        }
    }
    else{
        //kış lastiği olayı
        NSPredicate *winterTyre = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0014"];
        NSArray *winterTyreArr = [super.reservation.additionalEquipments filteredArrayUsingPredicate:winterTyre];
        
        NSPredicate *carsWinterTyre = [NSPredicate predicateWithFormat:@"winterTire==%@",@"X"];
        NSArray *carsWinterTyreArr = [super.reservation.upsellCarGroup.cars filteredArrayUsingPredicate:carsWinterTyre];
        
        //eğer rezervasyonda kış lastiği varsa ve seçilen araçta kış lastiği seçeneği yoksa siliyoruz.
        if (winterTyreArr.count > 0 && carsWinterTyreArr.count == 0) {
            [[winterTyreArr objectAtIndex:0] setQuantity:0];
            [[winterTyreArr objectAtIndex:0] setUpdateStatus:@"D"];
            _winterTyreDifference = [[[winterTyreArr objectAtIndex:0] price] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }
        //eğer rezervasyonda kış lastiği varsa ve seçilen araç grubunda kış lastiği eskisinden farklıysa farkını buluyoruz
        else if (winterTyreArr.count > 0 && carsWinterTyreArr.count > 0) {
            
            NSPredicate *equi = [NSPredicate predicateWithFormat:@"materialNumber==%@",@"HZM0014"];
            NSArray *equiArr = [self.additionalEquipments filteredArrayUsingPredicate:equi];
            
            [[winterTyreArr objectAtIndex:0] setPrice:[[equiArr objectAtIndex:0] price]];
            _winterTyreDifference = [[[equiArr objectAtIndex:0] price] decimalNumberBySubtracting:[[winterTyreArr objectAtIndex:0] price]];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"toOldReservationPaymentSegue"])
    {
        if (_totalPrice != nil && ([super.reservation.paymentType isEqualToString:@"2"] || [super.reservation.paymentType isEqualToString:@"6"])) {
            _changeReservationPrice = [[NSDecimalNumber decimalNumberWithString:_totalPrice] decimalNumberByAdding: _payNowDifference];
        }
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
- (CreditCard *)prepareCreditCard {
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

- (void)checkIdentityControl
{
    IDController *control = [[IDController alloc] init];
    
    User *user = [ApplicationProperties getUser];
    NSString *nameString = @"";
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSYearCalendarUnit fromDate:user.birthday];
    NSString *birtdayYearString = [NSString stringWithFormat:@"%li", (long)weekdayComponents.year];
    
    if ([user.middleName isEqualToString:@""]) {
        nameString = user.name;
    }
    else {
        nameString = [NSString stringWithFormat:@"%@ %@", user.name, user.middleName];
    }
    
    BOOL checker = [control idChecker:user.tckno andName:nameString andSurname:user.surname andBirthYear:birtdayYearString];
    
    if (checker) {
        [self updateReservation];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"T.C kimlik numarası kontrolüne takıldınız, tekrar deneyin yada profil bilginizi güncelleyin." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)updateReservation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        BOOL isPayNow = NO;
        
        if (_changeReservationPrice.floatValue < 0) {
            isPayNow = YES;
        }
        
        BOOL check = [Reservation changeReservationAtSAP:super.reservation andIsPayNow:isPayNow andTotalPrice:_changeReservationPrice andGarentaTl:@""];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (check) {
                [self performSegueWithIdentifier:@"toOldReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

@end
