//
//  OldReservationUpsellDownsellVCViewController.m
//  Garenta
//
//  Created by Kerem Balaban on 6.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationUpsellDownsellVC.h"
#import "OldReservationSummaryVC.h"
#import "UpsellDownsellCarSelectionVC.h"
#import "AdditionalEquipment.h"
#import "MBProgressHUD.h"
#import "ETExpiryObject.h"

@interface OldReservationUpsellDownsellVC ()

@property (strong,nonatomic) IBOutlet UISegmentedControl *upsellDownsellSegment;
@property (strong,nonatomic) IBOutlet UITableView *tableVC;


- (IBAction)changeSegmentValue:(id)sender;
@end

@implementation OldReservationUpsellDownsellVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _downsellList = [NSMutableArray new];
    _upsellList = [NSMutableArray new];
    _tempEquipmentList = [NSMutableArray new];
    
    // adam işlemden vazgeçip geri döndüğü takdirde burdaki listeyi tekrar eşitliycez.
    //    _tempEquipmentList = [[NSMutableArray alloc] initWithArray:_reservation.additionalEquipments copyItems:YES];
    
    for (CarGroup *tempGroup in _reservation.upsellList) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupCode==%@",tempGroup.groupCode];
        NSArray *arr = [_upsellList filteredArrayUsingPredicate:predicate];
        
        if (arr.count == 0 && tempGroup.sampleCar.isForShown) {
            [_upsellList addObject:tempGroup];
        }
    }
    
    for (CarGroup *tempGroup in _reservation.downsellList)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupCode==%@",tempGroup.groupCode];
        NSArray *arr = [_downsellList filteredArrayUsingPredicate:predicate];
        
        if (arr.count == 0 && tempGroup.sampleCar.isForShown) {
            [_downsellList addObject:tempGroup];
        }
    }
    
    if (_reservation.downsellList.count == 0)
        [_upsellDownsellSegment setEnabled:NO forSegmentAtIndex:1];
    else if (_upsellList.count == 0)
    {
        [_upsellDownsellSegment setEnabled:NO forSegmentAtIndex:0];
        [_upsellDownsellSegment setSelectedSegmentIndex:1];
    }
}

- (IBAction)changeSegmentValue:(id)sender
{
    [_tableVC reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0)
        return _upsellList.count;
    else
        return _downsellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImageView *carImage;
    UILabel *segmentLabel;
    UILabel *modelNameLabel;
    UILabel *payNowLabel;
    UILabel *payLaterLabel;
    UILabel *fuelLabel;
    UILabel *transmissionLabel;
    UILabel *passangerLabel;
    UILabel *doorNumberLabel;
    UILabel *minInfoLabel;
    
    NSMutableArray *copyArray = [NSMutableArray new];
    NSDecimalNumber *payNowDifference;
    NSDecimalNumber *payLaterDifference;
    
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0)
        copyArray = [_upsellList copy];
    else
        copyArray = [_downsellList copy];
    
    CarGroup *temp = [copyArray objectAtIndex:indexPath.row];
    if (_reservation.etExpiry.count > 0) {
        
        for (ETExpiryObject *tempExpiry in _reservation.etExpiry) {
            if ([tempExpiry.carGroup isEqualToString:temp.groupCode] && [tempExpiry.modelID isEqualToString:temp.sampleCar.modelId] && [tempExpiry.brandID isEqualToString:temp.sampleCar.brandId]) {
                
                payNowDifference = [tempExpiry.totalPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
                
                payLaterDifference = [tempExpiry.totalPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
                
                break;
            }
        }
    }
    else{
        payNowDifference = [temp.sampleCar.pricing.payNowPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
    
        payLaterDifference = [temp.sampleCar.pricing.payLaterPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upsellDownsellCell"];
    
    carImage = (UIImageView*)[cell viewWithTag:1];
    [carImage setImage:temp.sampleCar.image];
    
    modelNameLabel = (UILabel*)[cell viewWithTag:2];
    [modelNameLabel setText:[NSString stringWithFormat:@"%@ ve benzeri",temp.sampleCar.materialName]];
    
    payNowLabel = (UILabel*)[cell viewWithTag:3];
    [payNowLabel setText:[NSString stringWithFormat:@"%.02f",payNowDifference.floatValue]];
    
    if ([_reservation.paymentType isEqualToString:@"2"] || [_reservation.paymentType isEqualToString:@"6"])
    {
        payLaterLabel = (UILabel*)[cell viewWithTag:4];
        [payLaterLabel setText:[NSString stringWithFormat:@"%.02f",payLaterDifference.floatValue]];
    }
    else
    {
        payLaterLabel = (UILabel*)[cell viewWithTag:4];
        [payLaterLabel setText:@"-"];
    }
    
    fuelLabel = (UILabel*)[cell viewWithTag:5];
    [fuelLabel setText:temp.fuelName];
    
    transmissionLabel = (UILabel*)[cell viewWithTag:6];
    [transmissionLabel setText:temp.transmissonName];
    
    passangerLabel = (UILabel*)[cell viewWithTag:7];
    [passangerLabel setText:temp.sampleCar.passangerNumber];
    
    doorNumberLabel = (UILabel*)[cell viewWithTag:8];
    [doorNumberLabel setText:temp.sampleCar.doorNumber];
    
    segmentLabel = (UILabel*)[cell viewWithTag:9];
    [segmentLabel setText:temp.segmentName];
    
    minInfoLabel = (UILabel*)[cell viewWithTag:10];
    [minInfoLabel setText:[NSString stringWithFormat:@"Min.Genç sürücü yaşı:%li - Min.Ehliyet:%li",(long)temp.minAge,(long)temp.minDriverLicense]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarGroup *tempCarGroup = [CarGroup new];
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0){
        tempCarGroup = [_upsellList objectAtIndex:indexPath.row];
    }
    else{
        tempCarGroup = [_downsellList objectAtIndex:indexPath.row];
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getAdditionalEquipmentsFromSAP:tempCarGroup];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            User *tempUser = [ApplicationProperties getUser];
            
            if ([self checkIsCarGroupAvailable:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate andCarGroup:tempCarGroup])
            {
                _isYoungDriver = [CarGroup checkYoungDriverAddition:tempCarGroup andBirthday:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate];
                
                _reservation.upsellCarGroup = tempCarGroup;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // genç sürücü varsa önce mesajı verip sonra aracınızı seçmek istermisini diye soruyoruz
                    if (_isYoungDriver) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:[NSString stringWithFormat:@"Seçmiş olduğunuz araç grubuna değişiklik yapabilmeniz için 'Genç Sürücü' ve 'Maksimum Güvence' hizmeti satın alınacaktır. Devam etmek istiyor musunuz?"] delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Evet", nil];
                        
                        alert.tag = 1;
                        [alert show];
                    }
                    else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:[NSString stringWithFormat:@"Sadece %.02f TL ödeyerek aracınızı seçmek ister misiniz?",[[[[_reservation.upsellCarGroup.cars objectAtIndex:0] pricing ] carSelectPrice] floatValue]] delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Aracımı Seç",@"Gruba Rezervasyon", nil];
                        
                        alert.tag = 2;
                        [alert show];
                    }
                });
            }
        });
    });
}

- (BOOL)checkIsCarGroupAvailable:(NSDate *)birthday andLicenseDate:(NSDate *)licenseDate andCarGroup:(CarGroup *)activeCarGroup;
{
    if (![CarGroup isCarGroupAvailableByAge:activeCarGroup andBirthday:birthday andLicenseDate:licenseDate])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:[NSString stringWithFormat:@"Seçilen araç grubuna rezervasyon yapılamaz. (Min.Genç Sürücü yaşı: %li - Min.Genç Sürücü Ehliyet Yılı: %li)",(long)activeCarGroup.minYoungDriverAge,(long)activeCarGroup.minYoungDriverLicense] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
            });
        
        return NO;
    }
    
    return YES;
}

-(void)getAdditionalEquipmentsFromSAP:(CarGroup *)upsellCarGroup {
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
        [handler addImportParameter:@"IMPP_GRPKOD" andValue:upsellCarGroup.groupCode];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_KANAL" andValue:@"40"];
        
        NSString *fikod = @"";
        NSString *kunnr = @"";
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            fikod = [[ApplicationProperties getUser] priceCode];
            kunnr = [[ApplicationProperties getUser] kunnr];
        }

        if ([fikod isEqualToString:@""] || fikod == nil) {
            fikod = self.reservation.selectedCarGroup.sampleCar.priceCode;
        }
        
        [handler addImportParameter:@"IMPP_MUSNO" andValue:kunnr];
        [handler addImportParameter:@"IMPP_FIKOD" andValue:fikod];
        
        [handler addTableForReturn:@"EXPT_EKPLIST"];
        [handler addTableForReturn:@"EXPT_SIGORTA"];
        [handler addTableForReturn:@"EXPT_EKSURUCU"];
        [handler addTableForReturn:@"EXPT_EXPIRY"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
            
            _additionalEquipments = [NSMutableArray new];

            NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
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
                
                [_reservation.etExpiry addObject:tempObject];
            }
            
            NSDictionary *equipmentList = [tables objectForKey:@"ZPM_S_EKIPMAN_LISTE"];
            
            for (NSDictionary *tempDict in equipmentList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MATNR"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MUS_TANIMI"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"NETWR"]]];
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
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
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_ADET"]]];
                [tempEquip setQuantity:0];
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0004"])
                    [tempEquip setType:additionalDriver];
                else
                    [tempEquip setType:additionalInsurance];
                
                [_additionalEquipments addObject:tempEquip];
            }
            
            NSDictionary *assuranceList = [tables objectForKey:@"ZMOB_KDK_S_SIGORTA"];
            
            for (NSDictionary *tempDict in assuranceList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [tempEquip setType:additionalInsurance];
                [tempEquip setQuantity:0];
                
                [_additionalEquipments addObject:tempEquip];
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
    if (alertView.tag == 1 && buttonIndex == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:[NSString stringWithFormat:@"Sadece %.02f TL ödeyerek aracınızı seçmek ister misiniz?",[[[[_reservation.upsellCarGroup.cars objectAtIndex:0] pricing ] carSelectPrice] floatValue]] delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Aracımı Seç",@"Gruba Rezervasyon", nil];
            
            alert.tag = 2;
            [alert show];
        });
    }
    
    if (alertView.tag == 2)
    {
        switch (buttonIndex) {
            case 0:
                //NO
                break;
            case 1:
                [_reservation setUpsellSelectedCar:nil];
                [self performSegueWithIdentifier:@"toCarSelectionVCSegue" sender:self];
                break;
            case 2:
                [_reservation setUpsellSelectedCar:nil];
                [self performSegueWithIdentifier:@"toOldReservationSummarySegue" sender:self];
            default:
                break;
        }
    }
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toOldReservationSummarySegue"])
    {
        if([_upsellDownsellSegment selectedSegmentIndex] == 0)
            [_reservation setUpdateStatus:@"UPS"];
        else
            [_reservation setUpdateStatus:@"DWS"];
        
        
        [(OldReservationSummaryVC *)[segue destinationViewController] setAdditionalEquipments:_additionalEquipments];
        [(OldReservationSummaryVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationSummaryVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
        [(OldReservationSummaryVC *)[segue destinationViewController] setIsYoungDriver:_isYoungDriver];
    }
    
    if ([segue.identifier isEqualToString:@"toCarSelectionVCSegue"])
    {
        if([_upsellDownsellSegment selectedSegmentIndex] == 0){
            [_reservation setUpdateStatus:@"UPS"];
            [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setCars:_reservation.upsellList];
        }
        else{
            [_reservation setUpdateStatus:@"DWS"];
            [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setCars:_reservation.downsellList];
        }
        
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setAdditionalEquipments:_additionalEquipments];
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setReservation:_reservation];
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setIsYoungDriver:_isYoungDriver];
    }
}

// araca rezervasyon upsell yada downsell yapılarak gruba çevrilmişse araç seçim farkı silinir ve tutarı toplam tutardan çıkartılır.
- (void)deleteCarSelection
{
    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
    NSArray *equipmentPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
    
    if (equipmentPredicateArray.count > 0) {
        AdditionalEquipment *temp = [equipmentPredicateArray objectAtIndex:0];
        temp.updateStatus = @"D";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
