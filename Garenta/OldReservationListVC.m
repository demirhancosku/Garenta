//
//  OldReservationListVC.m
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationListVC.h"
#import "MBProgressHUD.h"
#import "OldReservationTableViewCell.h"
#import "OldReservationDetailVC.h"
#import "AdditionalEquipment.h"

@interface OldReservationListVC ()

@property (weak, nonatomic) IBOutlet UITableView *oldReservationTableView;
@property (strong, nonatomic) NSString *totalPrice;
@end

@implementation OldReservationListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    reservationList = [NSMutableArray new];
    _reservation = [Reservation new];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getOldReservation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_oldReservationTableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getOldReservation
{
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZCRM_GET_CUSTOMER_PROFIL_ALL"];
        
        [handler addImportParameter:@"IV_PARTNER" andValue:[[ApplicationProperties getUser] kunnr]];
        
        [handler addTableForReturn:@"ET_REZARVASYONLAR"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *responseList = [tables objectForKey:@"ZREZARVASYON_DETAIL"];
            
            if (responseList.count > 0)
            {
                [reservationList removeAllObjects];
                
                for (NSDictionary *tempDict in responseList)
                {
                    Reservation *temp = [Reservation new];
                    temp.checkInOffice = [Office new];
                    temp.checkOutOffice = [Office new];
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *checkOutDate = [formatter dateFromString:[tempDict valueForKey:@"REZ_BAS_TAR"]];
                    NSDate *checkInDate = [formatter dateFromString:[tempDict valueForKey:@"REZ_BIT_TAR"]];
                    
                    [formatter setDateFormat:@"HH:mm:ss"];
                    NSDate *checkOutTime = [formatter dateFromString:[tempDict valueForKey:@"REZ_BAS_SAAT"]];
                    NSDate *checkInTime = [formatter dateFromString:[tempDict valueForKey:@"REZ_BIT_SAAT"]];
                    
                    temp.reservationNumber = [tempDict valueForKey:@"REZ_NO"];
                    temp.checkOutOffice.subOfficeCode = [tempDict valueForKey:@"CIKIS_SUBE"];
                    temp.checkOutOffice.subOfficeName = [tempDict valueForKey:@"CIKIS_SUBE_TXT"];
                    temp.checkInOffice.subOfficeCode = [tempDict valueForKey:@"DONUS_SUBE"];
                    temp.checkInOffice.subOfficeName = [tempDict valueForKey:@"DONUS_SUBE_TXT"];
                    temp.checkOutTime = [self setDates:checkOutDate andTime:checkOutTime];
                    temp.checkInTime = [self setDates:checkInDate andTime:checkInTime];
                    temp.reservationStatu = [tempDict valueForKey:@"REZ_DURUM_TXT"];
                    
                    [reservationList addObject:temp];
                }
                
                [[ApplicationProperties getUser] setReservationList:reservationList];
            }
            else
            {
                alertString = @"Rezervazyon bulunamamıştır.";
            }
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

- (NSDate *)setDates:(NSDate *)date andTime:(NSDate *)time
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *reservationDateComp = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    
    NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:time];
    
    comps.day = reservationDateComp.day;
    comps.month = reservationDateComp.month;
    comps.year = reservationDateComp.year;
    
    return [calendar dateFromComponents:comps];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reservationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self oldReservationCell:tableView andIndexPath:indexPath];

}

- (OldReservationTableViewCell *)oldReservationCell:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    OldReservationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"oldReservationCell"];
    if (!cell) {
        cell = [OldReservationTableViewCell new];
    }
    
    Reservation *temp = [Reservation new];
    temp = [[[ApplicationProperties getUser] reservationList] objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy / HH:mm"];
    
    cell.reservationNo.text = temp.reservationNumber;
    cell.checkOutOfficeName.text = temp.checkOutOffice.subOfficeName;
    cell.checkInOfficeName.text = temp.checkInOffice.subOfficeName;
    cell.checkOutTime.text = [formatter stringFromDate:temp.checkOutTime];
    cell.checkInTime.text = [formatter stringFromDate:temp.checkInTime];
    cell.statu.text = temp.reservationStatu;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _reservation = [reservationList objectAtIndex:indexPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getOldReservationDetail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self performSegueWithIdentifier:@"toReservationDetail" sender:self];
        });
    });
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([[segue identifier] isEqualToString:@"toReservationDetail"]) {
        [(OldReservationDetailVC*)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationDetailVC*)[segue destinationViewController] setTotalPrice:_totalPrice];
    }
}

- (void)getOldReservationDetail
{
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZCRM_GET_REZ_DETAIL"];
        
        [handler addImportParameter:@"IV_REZERVASYON" andValue:_reservation.reservationNumber];
        
        [handler addTableForReturn:@"ET_ARAC_LISTE"];
        [handler addTableForReturn:@"ET_REZARVASYON"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            _reservation.additionalEquipments = [NSMutableArray new];
            
            NSDictionary *totalValue = [response objectForKey:@"EXPORT"];
            _totalPrice = [[totalValue valueForKey:@"ES_DETAIL"] valueForKey:@"TOPLAM_TUTAR"];
            
            // araç bilgilerini dönen tablo
            NSDictionary *carTable = [response objectForKey:@"TABLES"];
            NSDictionary *responseList = [carTable objectForKey:@"ZKDK_ARAC_LISTE"];
            
            // belgedeki kalemleri dönen tablo
            NSDictionary *equipmentTable = [response objectForKey:@"TABLES"];
            NSDictionary *equipmentResponseList = [equipmentTable objectForKey:@"ZREZARVASYON_DETAIL"];
            
            if (responseList.count > 0)
            {
                for (NSDictionary *tempDict in responseList)
                {
                    Car *tempCar = [Car new];
                    
                    [tempCar setMaterialCode:[tempDict valueForKey:@"MATNR"]];
                    [tempCar setMaterialName:[tempDict valueForKey:@"MAKTX"]];
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
                    tempCarGroup.cars = [NSMutableArray new];
                    
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
                    [tempCarGroup.cars addObject:tempCar];
                    
                    [_reservation setSelectedCarGroup:tempCarGroup];
                }
                
                for (NSDictionary *tempEqui in equipmentResponseList)
                {
                    AdditionalEquipment *equiObj = [AdditionalEquipment new];
                    
                    equiObj.materialNumber = [tempEqui valueForKey:@"MALZEME"];
                    equiObj.materialDescription = [tempEqui valueForKey:@"TANIM"];
                    equiObj.price = [NSDecimalNumber decimalNumberWithString:[tempEqui valueForKey:@"TOPLAM_TUTAR"]];
                    equiObj.quantity = [[tempEqui valueForKey:@"MIKTAR"] intValue];
                    
                    [_reservation.additionalEquipments addObject:equiObj];
                }
            }
            else
            {
                alertString = @"Rezervazyon bulunamamıştır.";
            }
        }
        else
        {
            alertString = @"Rezervazyon bulunamamıştır.";
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



@end