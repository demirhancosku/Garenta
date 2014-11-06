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

#define kCheckOutTag 0
#define kCheckInTag 1

@interface OldReservationSearchVC ()

@property (weak,nonatomic) IBOutlet UIButton  *reCalculateButton;
- (IBAction)reCalculate:(id)sender;

@end

@implementation OldReservationSearchVC

- (void)viewDidLoad
{
    CGRect navigationBarFrame = [[[self navigationController] navigationBar] frame];
    //ysinde navigationBarFrame.size.height vardi viewwillapear super cagirilmamaisti onu cagirinca buna gerek kalmadi
    viewFrame =CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width - navigationBarFrame.size.height );
    
    [super addNotifications];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    _oldCheckOutTime = [super.reservation.checkOutTime copy];
    _oldCheckInTime = [super.reservation.checkInTime copy];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// yeniden hesapla butonu
- (IBAction)reCalculate:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getAdditionalEquipmentsFromSAP];
        [self getNewReservationPrice];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(super.reservation.changeReservationDifference.floatValue == 0)
                [self performSegueWithIdentifier:@"toOldReservationEquipmentSegue" sender:self];
        });
    });
}

- (void)getNewReservationPrice
{
    NSString *alertString = @"";
    BOOL isOk = YES;
    
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
        [handler addImportParameter:@"IMPP_KDGRP" andValue:@"10"];
        
        [handler addTableForReturn:@"EXPT_ARACLISTE"];
        
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

                super.reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:[export valueForKey:@"EXPP_PRICE"]];
                
                NSString *currency = [export valueForKey:@"EXPP_CURR"];
                NSString *paymentType = [export valueForKey:@"EXPP_TYPE"]; //T-toplam rezervasyon tutarı, F-fark tutarı
                
                if ([paymentType isEqualToString:@"T"]) {
                    super.reservation.changeReservationDifference = [super.reservation.changeReservationDifference decimalNumberBySubtracting:super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice];
                }
                
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


-(void)getAdditionalEquipmentsFromSAP {
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_EQUIPMENT_LIST"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"IMPP_REZNO" andValue:self.reservation.reservationNumber];
        [handler addImportParameter:@"IMPP_MSUBE" andValue:self.reservation.checkOutOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_DSUBE" andValue:self.reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_GRPKOD" andValue:self.reservation.selectedCarGroup.groupCode];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_KANAL" andValue:@"40"];
        
        [handler addTableForReturn:@"EXPT_EKPLIST"];
        [handler addTableForReturn:@"EXPT_SIGORTA"];
        [handler addTableForReturn:@"EXPT_EKSURUCU"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
            
            _additionalEquipments = [NSMutableArray new];
            
            NSDictionary *equipmentList = [tables objectForKey:@"ZPM_S_EKIPMAN_LISTE"];
            
            for (NSDictionary *tempDict in equipmentList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MATNR"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MUS_TANIMI"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"NETWR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_MIKTAR"]]];
                [tempEquip setQuantity:0];
                [tempEquip setType:standartEquipment];
                [_additionalEquipments addObject:tempEquip];
            }
            
            NSDictionary *additionalEquipmentList = [tables objectForKey:@"ZMOB_KDK_S_EKSURUCU"];
            
            for (NSDictionary *tempDict in additionalEquipmentList) {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_ADET"]]];
                [tempEquip setQuantity:0];
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0004"])
                    [tempEquip setType:additionalDriver];
                else
                    [tempEquip setType:additionalInsurance];
                
                // GENÇ SÜRÜCÜ full list içinde var, ekrana gösterdiğimiz array de yok
                // GENÇ SÜRÜCÜ eklenince silinmemesi için isRequired = YES
                // GENÇ SÜRÜCÜ 1'den fazla ekleyememesi için MaxQuantity = 1
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0007"])
                {
                    // eski ezervasyonlardan genç sürücü geliyomu kontrolü
                    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0007"];
                    NSArray *equipmentPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
                    
                    if (equipmentPredicateArray.count > 0)
                    {
                        [tempEquip setIsRequired:YES];
                        [tempEquip setQuantity:1];
                        [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                    }
                }
                else
                {
                    [_additionalEquipments addObject:tempEquip];
                }
            }
            
            NSDictionary *assuranceList = [tables objectForKey:@"ZMOB_KDK_S_SIGORTA"];
            
            for (NSDictionary *tempDict in assuranceList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [tempEquip setType:additionalInsurance];
                [tempEquip setQuantity:0];
                
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0020"] && tempEquip.price.floatValue > 0) //tek yön ücreti varsa hep 1 olacak
                {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                    [_additionalEquipments insertObject:tempEquip atIndex:0];
                }
                
                // ARAÇ SEÇİM FARKI full list içinde var, ekrana gösterdiğimiz array de yok
                else if ([[tempEquip materialNumber] isEqualToString:@"HZM0031"])
                {
                    //eski ezervasyonlardan araç seçim farkı geliyomu kontrolü
                    NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
                    NSArray *carSelectPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                    if (carSelectPredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
//                        [tempEquip setPrice:[[carSelectPredicateArray objectAtIndex:0] price]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                    }
                }
                // EĞER GENÇ SÜRÜCÜ VARSA MAKSİMUM GÜVENCE EN ÜSTE EKLENİYO VE ZORUNLU OLUYO
                else if ([[tempEquip materialNumber]isEqualToString:@"HZM0012"])
                {
                    // eski ezervasyonlardan Maks.güvence geliyomu kontrolü
                    NSPredicate *maxSecurePredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0012"];
                    NSArray *maxSecurePredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:maxSecurePredicate];
                    
                    NSPredicate *youngPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0007"];
                    NSArray *youngPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:youngPredicate];
                    
                    if (maxSecurePredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        
                        if (youngPredicateArray.count > 0)
                            [tempEquip setIsRequired:YES];
                        else
                            [tempEquip setIsRequired:NO];
                        
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                    }
                    else
                    {
                        [_additionalEquipments addObject:tempEquip];
                    }
                }
                else
                {
                    [_additionalEquipments addObject:tempEquip];
                }
            }
            

        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == kCheckOutTag && indexPath.row == 0)
    {
        
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
            
            if (filterResult.count > 0)
            {
//                temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]] decimalNumberBySubtracting:[[filterResult objectAtIndex:0] price]];
                
                temp.difference = [[temp.price decimalNumberBySubtracting:[[filterResult objectAtIndex:0] price]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]];
                
                temp.paid = [[[filterResult objectAtIndex:0] price] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",[[filterResult objectAtIndex:0] quantity]]]];
            }
        }
        
        [(OldReservationEquipmentVC *)[segue destinationViewController] setReservation:super.reservation];
        [(OldReservationEquipmentVC *)[segue destinationViewController] setAdditionalEquipments:_additionalEquipments];
    }
}

@end
