//
//  OldReservationSearchVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationSearchVC.h"
#import "OldReservationEquipmentVC.h"
#import "AdditionalEquipment.h"
#import "ETExpiryObject.h"
#import "SDReservObject.h"

#define kCheckOutTag 0
#define kCheckInTag 1

@interface OldReservationSearchVC ()

@property (weak,nonatomic) IBOutlet UIButton  *reCalculateButton;
- (IBAction)reCalculate:(id)sender;

@end

@implementation OldReservationSearchVC
@synthesize isOk;

- (void)viewDidLoad
{
    CGRect navigationBarFrame = [[[self navigationController] navigationBar] frame];
    
    viewFrame =CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width - navigationBarFrame.size.height );
    
    [super addNotifications];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    super.reservation.checkOutTime = [_oldCheckOutTime copy];
    super.reservation.checkInTime = [_oldCheckInTime copy];
    
    isOk = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// yeniden hesapla butonu
- (IBAction)reCalculate:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // 13.02.2015 Ata Cengiz
    if (self.reservation.isContract) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self getAdditionalEquipments];
            [self getNewContractPrice];
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        });
    }
    // 13.02.2015 Ata Cengiz
    else {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self getAdditionalEquipments];
            [self getNewReservationPrice];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                if(super.reservation.changeReservationDifference.floatValue == 0 && isOk)
                    [self performSegueWithIdentifier:@"toOldReservationEquipmentSegue" sender:self];
            });
        });
    }
}

- (void)getNewReservationPrice
{
    NSString *alertString = @"";
    
    // KAYDIRMA OLUP OLMADIĞINI BELİRLİYORUZ
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:_oldCheckOutTime
                                                          toDate:_oldCheckInTime
                                                         options:0];
    
    int oldDayDiff = [components day];
    
    NSDateComponents *components2 = [gregorianCalendar components:NSDayCalendarUnit
                                                         fromDate:super.reservation.checkOutTime
                                                           toDate:super.reservation.checkInTime
                                                          options:0];
    
    int dayDiff = [components2 day];
    
    
    NSComparisonResult checkInResult = [_oldCheckInTime compare:super.reservation.checkInTime];
    NSComparisonResult checkOutResult = [_oldCheckOutTime compare:super.reservation.checkOutTime];
    
    if ((checkInResult != NSOrderedSame || checkOutResult != NSOrderedSame) && dayDiff == oldDayDiff)
        super.reservation.updateStatus = @"KAY";
    else
        super.reservation.updateStatus = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZPM_KDK_RZRVSYN_DGSKLK"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"IMPP_RSNUM" andValue:super.reservation.reservationNumber];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:super.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_BEGTIME" andValue:[timeFormatter stringFromDate:super.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:super.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_ENDTIME" andValue:[timeFormatter stringFromDate:super.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_HDFSUBE" andValue:super.reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_LANG" andValue:@"T"];
        [handler addImportParameter:@"IMPP_KDGRP" andValue:@"40"];
        [handler addImportParameter:@"IMPP_MUSTIP" andValue:[[ApplicationProperties getUser] partnerType]];
        
        [handler addTableForReturn:@"EXPT_ARACLISTE"];
        [handler addTableForReturn:@"EXPT_EXPIRY"];
        [handler addTableForReturn:@"EXPT_RESERV"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            NSString  *isCarAvailable = [export valueForKey:@"EXPP_TRUE_FALSE"];
            
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *carList = [tables objectForKey:@"ZPM_S_ARACLISTE"];
            
            if ([isCarAvailable isEqualToString:@"T"])
            {
                super.reservation.selectedCarGroup.cars = [NSMutableArray new];
                
                for (NSDictionary *tempDict in carList) {
                    Car *tempCar = [Car new];
                    tempCar.pricing = [Price new];
                    
                    [tempCar setMaterialCode:[tempDict valueForKey:@"MATNR"]];
                    [tempCar setMaterialName:[tempDict valueForKey:@"MAKTX"]];
                    [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempCar setWinterTire:[tempDict valueForKey:@"KIS_LASTIK"]];
                    [tempCar setPlateNo:@""];
                    [tempCar setChassisNo:@""];
                    [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
                    [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
                    [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
                    [tempCar setSalesOffice:[tempDict valueForKey:@"MSUBE"]];
                    [tempCar setColorCode:[tempDict valueForKey:@"RENK"]];
                    [tempCar setColorName:[tempDict valueForKey:@"RENKTX"]];
                    [tempCar setCarGroup:[tempDict valueForKey:@"GRPKOD"]];
                    
                    NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
                    
                    [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]]];
                    
                    if (tempCar.image == nil) {
                        [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
                    }
                    
                    [tempCar setDoorNumber:[tempDict valueForKey:@"KAPI_SAYISI"]];
                    [tempCar setPassangerNumber:[tempDict valueForKey:@"YOLCU_SAYISI"]];
                    [tempCar setOfficeCode:[tempDict valueForKey:@"ASUBE"]];
                    
                    // araç seçim farkının tutarını güncelliyoruz
                    NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
                    NSArray *carSelectPredicateArray = [_additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                    if (carSelectPredicateArray.count > 0) {
                        [[carSelectPredicateArray objectAtIndex:0] setPrice:[NSDecimalNumber decimalNumberWithString:[export valueForKey:@"EXPP_ASECIM_TTR"]]];
                    }
                    
                    [tempCar.pricing setCarSelectPrice:[export valueForKey:@"EXPP_ASECIM_TTR"]];
                    
                    [super.reservation.selectedCarGroup.cars addObject:tempCar];
                }
                
                // AYLIK İÇİN TAKSİT TABLOSU
                NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
                
                //                NSMutableArray *etExpiryArray = [NSMutableArray new];
                
                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                if (!super.reservation.etExpiry){
                    super.reservation.etExpiry = [NSMutableArray new];
                }
                
                for (NSDictionary *tempDict in etExpiry) {
                    ETExpiryObject *tempObject = [ETExpiryObject new];
                    
                    [tempObject setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
                    [tempObject setBeginDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_BASI"]]];
                    [tempObject setEndDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_SONU"]]];
                    [tempObject setCampaignID:[tempDict valueForKey:@"KAMPANYA_ID"]];
                    [tempObject setBrandID:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempObject setModelID:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempObject setIsPaid:[tempDict valueForKey:@"ODENDI"]];
                    [tempObject setCurrency:[tempDict valueForKey:@"PARA_BIRIMI"]];
                    [tempObject setMaterialNo:[tempDict valueForKey:@"MALZEME"]];
                    [tempObject setTotalPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                    
                    [super.reservation.etExpiry addObject:tempObject];
                }
                
                //                super.reservation.etExpiry = etExpiryArray;
                
                //ET_REZERV
                NSDictionary *sdReserv = [tables objectForKey:@"ZSD_KDK_REZERV"];
                
                NSMutableArray *sdReservArray = [NSMutableArray new];
                
                for (NSDictionary *tempDict in sdReserv) {
                    SDReservObject *tempObject = [SDReservObject new];
                    
                    [tempObject setOffice:[tempDict valueForKey:@"SUBE"]];
                    [tempObject setGroupCode:[tempDict valueForKey:@"GRUP_KODU"]];
                    [tempObject setPriceCode:[tempDict valueForKey:@"FIYAT_KODU"]];
                    [tempObject setDate:[tempDict valueForKey:@"TARIH"]];
                    [tempObject setRVbeln:[tempDict valueForKey:@"R_VBELN"]];
                    [tempObject setRPosnr:[tempDict valueForKey:@"R_POSNR"]];
                    [tempObject setRGjahr:[tempDict valueForKey:@"R_GJAHR"]];
                    [tempObject setRAuart:[tempDict valueForKey:@"R_AUART"]];
                    [tempObject setMatnr:[tempDict valueForKey:@"MATNR"]];
                    [tempObject setEqunr:[tempDict valueForKey:@"EQUNR"]];
                    [tempObject setKunnr:[tempDict valueForKey:@"KUNNR"]];
                    [tempObject setDestinationOffice:[tempDict valueForKey:@"HDFSUBE"]];
                    [tempObject setAugru:[tempDict valueForKey:@"AUGRU"]];
                    [tempObject setVkorg:[tempDict valueForKey:@"VKORG"]];
                    [tempObject setVtweg:[tempDict valueForKey:@"VTWEG"]];
                    [tempObject setSpart:[tempDict valueForKey:@"SPART"]];
                    [tempObject setPrice:[tempDict valueForKey:@"TUTAR"]];
                    [tempObject setIsGarentaTl:[tempDict valueForKey:@"GRNTTL_KAZANIR"]];
                    [tempObject setIsMiles:[tempDict valueForKey:@"MIL_KAZANIR"]];
                    [tempObject setIsBonus:[tempDict valueForKey:@"BONUS_KAZANIR"]];
                    [sdReservArray addObject:tempObject];
                }
                
                super.reservation.etReserv = sdReservArray;
                
                // FIYATLAR
                if ([super.reservation.paymentType isEqualToString:@"2"]) {
                    super.reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:[export valueForKey:@"EXPP_PRICE"]];
                    super.reservation.changeReservationDifference = [super.reservation.changeReservationDifference decimalNumberBySubtracting:super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice];
                }else{
                    super.reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:[export valueForKey:@"EXPP_PRICE"]];
                }
                
                NSString *currency = [export valueForKey:@"EXPP_CURR"];
                NSString *paymentType = [export valueForKey:@"EXPP_TYPE"]; //T-toplam rezervasyon tutarı, F-fark tutarı
                
                //                if ([paymentType isEqualToString:@"T"]) {
                //                    super.reservation.changeReservationDifference = [super.reservation.changeReservationDifference decimalNumberBySubtracting:super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice];
                //                }
                
                NSDecimalNumber *equipmentPriceDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
                for (AdditionalEquipment *temp in super.reservation.additionalEquipments)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",temp.materialNumber];
                    NSArray *filterResult = [_additionalEquipments filteredArrayUsingPredicate:predicate];
                    
                    if (filterResult.count > 0) {
                        NSDecimalNumber *difference = [[[filterResult objectAtIndex:0] price] decimalNumberBySubtracting:temp.price];
                        equipmentPriceDifference = [equipmentPriceDifference decimalNumberByAdding:difference];
                    }
                }
                
                if (super.reservation.changeReservationDifference.floatValue != 0)
                    alertString = [NSString stringWithFormat:@"Seçmiş olduğunuz tarih aralığındaki fark tutarları ağaşıdaki gibidir.\n\nAraç Fark Bedeli: %.02f %@\nEk Hizmet Fark Bedeli: %.02f %@",super.reservation.changeReservationDifference.floatValue,currency,equipmentPriceDifference.floatValue,currency];
            }
            else
            {
                alertString = @"Aracınız seçmiş olduğunuz tarihler arasında uygun değildir.";
                isOk = NO;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (![alertString isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isOk)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rezervasyon fark tutarı" message:alertString delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Tamam",nil];
                    alert.tag = 1;
                    [alert show];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
            });
        }
    }
}


-(void)getAdditionalEquipments{
    
    _additionalEquipments = [NSMutableArray new];
    _additionalEquipmentsFullList = [NSMutableArray new];
    
    NSDictionary *temp = [AdditionalEquipment getAdditionalEquipmentsFromSAP:self.reservation andIsYoungDriver:NO];
    _additionalEquipments = [temp valueForKey:@"currentList"];
    _additionalEquipmentsFullList = [temp valueForKey:@"fullList"];
    
    self.reservation.additionalFullEquipments = _additionalEquipmentsFullList;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 1)
            {
                // aylık rezervasyon ise
                if (super.reservation.etExpiry.count > 0)
                {
                    NSString *alertMessage = @"";
                    NSDecimalNumber *equipmentMonthlyPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    NSDecimalNumber *documentMonthlyTotalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    int count = 1;
                    for (ETExpiryObject *tempObject in super.reservation.etExpiry) {
                        if (![tempObject.carGroup isEqualToString:@""]) {
                            
                            for (AdditionalEquipment *temp in _additionalEquipments) {
                                if (temp.quantity > 0)
                                    equipmentMonthlyPrice = [equipmentMonthlyPrice decimalNumberByAdding:temp.monthlyPrice];
                            }
                            
                            documentMonthlyTotalPrice = [tempObject.totalPrice decimalNumberByAdding:equipmentMonthlyPrice];
                            alertMessage = [NSString stringWithFormat:@"%@\n%i. Taksit - %@ %@", alertMessage, count, documentMonthlyTotalPrice.stringValue, tempObject.currency];
                            
                            count ++;
                        }
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aylık rezervasyon ödeme planı" message:[NSString stringWithFormat:@"Aşağıdaki fiyatlar aracın aylık taksitleridir, satın alınan yada alınacak ekipmanlarınr toplam fiyatı aracın ilk taksidine eklenecektir.\n%@",alertMessage] delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Tamam", nil];
                    
                    alert.tag = 2;
                    [alert show];
                }
                else
                    [self performSegueWithIdentifier:@"toOldReservationEquipmentSegue" sender:self];
            }
            break;
        case 2:
            if (buttonIndex == 1)
                [self performSegueWithIdentifier:@"toOldReservationEquipmentSegue" sender:self];
            break;
        default:
            break;
    }
}

- (OfficeSelectionCell *)officeSelectTableViewCell:(UITableView *)tableView
{
    OfficeSelectionCell *cell = [super officeSelectTableViewCell:tableView];
    
    if (tableView.tag == kCheckOutTag)
    {
        [[cell officeLabel] setTextColor:[UIColor lightGrayColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (TimeSelectionCell *)timeSelectTableViewCell:(UITableView *)tableView {
    TimeSelectionCell *cell = [super timeSelectTableViewCell:tableView];
    
    if (tableView.tag == kCheckOutTag && super.reservation.isContract) {
        [[cell timeLabel] setTextColor:[UIColor lightGrayColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == kCheckOutTag && indexPath.row == 0)
    {
        
    }
    if (super.reservation.isContract) {
        if ([tableView tag] == kCheckOutTag && indexPath.row == 1) {
            
        }
        else {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
    else
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"toOldReservationEquipmentSegue"])
    {
        // Burda daha önce ödenmiş bi fiyat varsa onu bulup objeyi güncelliyoruz, ödenecek fiyatıda buluyoruz. Web'teki yapının aynısı.
        for (AdditionalEquipment *temp in _additionalEquipments)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",temp.materialNumber];
            NSArray *filterResult = [super.reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
            
            if (super.reservation.additionalEquipments.count == 0) {
                if (super.reservation.etExpiry.count > 0) {
                    temp.difference = [temp.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[temp quantity]]]];
                }
                else
                {
                    temp.difference = [temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[temp quantity]]]];
                }
            }
            
            if (filterResult.count > 0)
            {
                //                temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]] decimalNumberBySubtracting:[[filterResult objectAtIndex:0] price]];
                
                if (super.reservation.etExpiry.count > 0 || temp.monthlyPrice.floatValue > 0) {
                    temp.difference = [[temp.monthlyPrice decimalNumberBySubtracting:[[filterResult objectAtIndex:0] price]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]];
                }
                else
                {
                    temp.difference = [[temp.price decimalNumberBySubtracting:[[filterResult objectAtIndex:0] price]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]];
                }
                
                temp.paid = [[[filterResult objectAtIndex:0] price] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]];
            }
            else if (filterResult.count == 0 && [temp.materialNumber isEqualToString:@"HZM0020"])
            {
                if (super.reservation.etExpiry.count > 0 || temp.monthlyPrice != nil) {
                    temp.difference = temp.monthlyPrice;
                }
                else{
                    temp.difference = temp.price;
                }
                
                temp.paid = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
        }
        //
        // belgede tek yön mevcut ve güncelleme yaparken tek yön eksikse çıkartıyoruz
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0020"];
        NSArray *filterResult2 = [super.reservation.additionalEquipments filteredArrayUsingPredicate:predicate2];
        
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0020"];
        NSArray *filterResult3 = [_additionalEquipments filteredArrayUsingPredicate:predicate3];
        
        if (filterResult2.count > 0 && filterResult3.count == 0) {
            AdditionalEquipment *tempEqui = [filterResult2 objectAtIndex:0];
            tempEqui.difference = [tempEqui.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
            if ([super.reservation.paymentType isEqualToString:@"1"]) {
                tempEqui.paid = tempEqui.price;
            }
            
            tempEqui.quantity = 0;
            tempEqui.maxQuantity = 0;
            tempEqui.updateStatus = @"D";
            tempEqui.type = additionalInsurance;
            
            [_additionalEquipments insertObject:tempEqui atIndex:0];
        }
        
        if (filterResult2.count > 0 && filterResult3.count > 0) {
            AdditionalEquipment *reservationEqui = [filterResult2 objectAtIndex:0];
            AdditionalEquipment *currentEqui = [filterResult3 objectAtIndex:0];
            
            reservationEqui.difference = [currentEqui.price decimalNumberBySubtracting:reservationEqui.price];
            if ([super.reservation.paymentType isEqualToString:@"1"]) {
                reservationEqui.paid = reservationEqui.price;
            }
        }
        
        // Ata Cengiz Sözleşme süre uzatmada ekipman ekleme çıkarma yok, ondan göstermeye gerek yok
        if (super.reservation.isContract) {
            NSMutableArray *soldEquipmentList = [NSMutableArray new];
            
            for (AdditionalEquipment *tempEquip in _additionalEquipments) {
                if (tempEquip.quantity > 0) {
                    [soldEquipmentList addObject:tempEquip];
                }
                else {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber=%@", tempEquip.materialNumber];
                    
                    NSArray *predicateResult = [super.reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
                    
                    if (predicateResult.count > 0) {
                        [soldEquipmentList addObject:tempEquip];
                    }
                }
            }
            [(OldReservationEquipmentVC *)[segue destinationViewController] setAdditionalEquipments:soldEquipmentList];
        }
        else {
            [(OldReservationEquipmentVC *)[segue destinationViewController] setAdditionalEquipments:_additionalEquipments];
        }
        // Ata Cengiz Sözleşme süre uzatmada ekipman ekleme çıkarma yok, ondan göstermeye gerek yok
        
        [(OldReservationEquipmentVC *)[segue destinationViewController] setReservation:super.reservation];
    }
}

- (void)getNewContractPrice {
    
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZPM_KDK_SOZLESME_DEGISIKLIK"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"IMPP_SOZNO" andValue:super.reservation.reservationNumber];
        [handler addImportParameter:@"IMPP_MSUBE" andValue:super.reservation.checkOutOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_HSUBE" andValue:super.reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_UPG_ENDDA" andValue:[dateFormatter stringFromDate:super.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_UPG_ENDUZ" andValue:[timeFormatter stringFromDate:super.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_KDGRP" andValue:@"40"];
        [handler addImportParameter:@"I_KULLANICI_ODEMELI" andValue:@"X"];
        
        [handler addTableForReturn:@"ET_EXPIRY"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            
            NSString *result = [export valueForKey:@"EXPP_TRUE_FALSE"];
            
            if ([result isEqualToString:@"T"]) {
                
                self.isOk = YES;
                super.reservation.upgradePriceCode = [export valueForKey:@"EXPP_FKOD"];
                super.reservation.upgradeCampaignID = [export valueForKey:@"EXPP_CAMPID"];
                
                if ([super.reservation.checkInTime compare:self.oldCheckInTime] == NSOrderedAscending) {
                    super.reservation.isUpgradeTime = @"";
                }
                else {
                    super.reservation.isUpgradeTime = @"X";
                }
                
                // AYLIK İÇİN TAKSİT TABLOSU
                NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
                
                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                if (!super.reservation.etExpiry){
                    super.reservation.etExpiry = [NSMutableArray new];
                }
                
                for (NSDictionary *tempDict in etExpiry) {
                    ETExpiryObject *tempObject = [ETExpiryObject new];
                    
                    [tempObject setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
                    [tempObject setBeginDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_BASI"]]];
                    [tempObject setEndDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_SONU"]]];
                    [tempObject setCampaignID:[tempDict valueForKey:@"KAMPANYA_ID"]];
                    [tempObject setBrandID:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempObject setModelID:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempObject setIsPaid:[tempDict valueForKey:@"ODENDI"]];
                    [tempObject setCurrency:[tempDict valueForKey:@"PARA_BIRIMI"]];
                    [tempObject setMaterialNo:[tempDict valueForKey:@"MALZEME"]];
                    [tempObject setTotalPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                    
                    [super.reservation.etExpiry addObject:tempObject];
                }
                
                // FIYATLAR
                super.reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:[export valueForKey:@"EXPP_PRICE"]];
                
                NSString *currency = [export valueForKey:@"EXPP_CURR"];
                
                NSDecimalNumber *equipmentPriceDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
                for (AdditionalEquipment *temp in super.reservation.additionalEquipments)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",temp.materialNumber];
                    NSArray *filterResult = [_additionalEquipments filteredArrayUsingPredicate:predicate];
                    
                    if (filterResult.count > 0) {
                        NSDecimalNumber *difference = [[[filterResult objectAtIndex:0] price] decimalNumberBySubtracting:temp.price];
                        equipmentPriceDifference = [equipmentPriceDifference decimalNumberByAdding:difference];
                    }
                }
                
                alertString = [NSString stringWithFormat:@"Seçmiş olduğunuz tarih aralığındaki fark tutarları ağaşıdaki gibidir.\n\nAraç Fark Bedeli: %.02f %@\nEk Hizmet Fark Bedeli: %.02f %@",super.reservation.changeReservationDifference.floatValue,currency,equipmentPriceDifference.floatValue,currency];
                
            }
            else {
                alertString = @"Aracınız seçmiş olduğunuz tarihler arasında uygun değildir.";
                self.isOk = NO;
            }
        }
        else {
            alertString = @"Yeni tarih için uygun fiyat bulunamadı, lütfen tekrar deneyiniz.";
            self.isOk = NO;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
        if (![alertString isEqualToString:@""]) {
            if (isOk)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rezervasyon fark tutarı" message:alertString delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Tamam",nil];
                alert.tag = 1;
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

@end
