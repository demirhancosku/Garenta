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
#import "LoginVC.h"

@interface OldReservationListVC ()

@property (weak, nonatomic) IBOutlet UITableView *oldReservationTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSString *totalPrice;

- (IBAction)segmentValueChanged:(id)sender;

@end

@implementation OldReservationListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"reservationUpdated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self getUserReservationList];
    }];
    
    if ([[ApplicationProperties getUser] isLoggedIn] && _reservationList == nil)
    {
        [self getUserReservationList];
    }
    
    if (![[ApplicationProperties getUser] isLoggedIn])
    {
        [self performSegueWithIdentifier:@"ToLoginVCSegue" sender:self];
    }
}

- (void)getUserReservationList
{
    _reservation = [Reservation new];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self getOldReservation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_activeReservationList.count == 0) {
                [_segmentedControl setEnabled:NO forSegmentAtIndex:0];
            }
            if (_completedReservationList.count == 0) {
                [_segmentedControl setEnabled:NO forSegmentAtIndex:1];
            }
            if (_cancelledReservationList.count == 0) {
                [_segmentedControl setEnabled:NO forSegmentAtIndex:2];
            }
            
            if (_activeReservationList.count == 0 && _completedReservationList.count > 0 ) {
                [_segmentedControl setSelectedSegmentIndex:1];
            }
            
            if (_activeReservationList.count == 0 && _completedReservationList.count == 0) {
                [_segmentedControl setSelectedSegmentIndex:2];
            }
            
            [self getActiveContractsFromSAP];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_oldReservationTableView reloadData];
        });
    });
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    [_oldReservationTableView addSubview:refreshControl];
    [self setRefreshControl:refreshControl];
}

- (IBAction)segmentValueChanged:(id)sender {
    [_oldReservationTableView reloadData];
}

- (void)refreshTableView {
    [self getOldReservation];
    [[self refreshControl] endRefreshing];
    [_oldReservationTableView reloadData];
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
                _reservationList = [NSMutableArray new];
                _cancelledReservationList = [NSMutableArray new];
                _activeReservationList = [NSMutableArray new];
                _completedReservationList = [NSMutableArray new];
                
                for (NSDictionary *tempDict in responseList)
                {
                    Reservation *temp = [Reservation new];
                    temp.checkInOffice = [Office new];
                    temp.checkOutOffice = [Office new];
                    temp.paymentNowCard = [CreditCard new];
                    
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
                    temp.reservationStatuId = [tempDict valueForKey:@"REZ_DURUM"];
                    temp.reservationStatu = [tempDict valueForKey:@"REZ_DURUM_TXT"];
                    temp.reservationType = [tempDict valueForKey:@"ARACREZTIPI"];
                    temp.paymentNowCard.uniqueId = [tempDict valueForKey:@"KK_UNIQUE_ID"];
                    
                    if ([temp.reservationStatuId isEqualToString:@"E0009"])
                        [_cancelledReservationList addObject:temp];
                    else if ([temp.reservationStatuId isEqualToString:@"E0010"])
                        [_completedReservationList addObject:temp];
                    else
                        [_activeReservationList addObject:temp];
                        
                    [_reservationList addObject:temp];
                }
                
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checkOutTime"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//                NSArray *sortedArray;
                [_cancelledReservationList sortUsingDescriptors:sortDescriptors];
                [_completedReservationList sortUsingDescriptors:sortDescriptors];
                [_activeReservationList sortUsingDescriptors:sortDescriptors];
                [_reservationList sortUsingDescriptors:sortDescriptors];
                
                [[ApplicationProperties getUser] setReservationList:_reservationList];
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
    if ([_segmentedControl selectedSegmentIndex] == 0) {
        _reservationList = [_activeReservationList copy];
    }
    else if ([_segmentedControl selectedSegmentIndex] == 1) {
        _reservationList = [_completedReservationList copy];
    }
    else if ([_segmentedControl selectedSegmentIndex] == 2) {
        _reservationList = [_cancelledReservationList copy];
    }
    
    return [_reservationList count];
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
    temp = [_reservationList objectAtIndex:indexPath.row];
//    temp = [[[ApplicationProperties getUser] reservationList] objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy / HH:mm"];
    
    cell.reservationNo.text = temp.reservationNumber;
    cell.checkOutOfficeName.text = temp.checkOutOffice.subOfficeName;
    cell.checkInOfficeName.text = temp.checkInOffice.subOfficeName;
    cell.checkOutTime.text = [formatter stringFromDate:temp.checkOutTime];
    cell.checkInTime.text = [formatter stringFromDate:temp.checkInTime];
    cell.statu.text = temp.reservationStatu;
    
    // 13.02.2015 Ata Cengiz
    if (temp.isContract) {
        cell.reservationTitle.text = @"Sözleşme No:";
    }
    // 13.02.2015 Ata Cengiz
    else{
        cell.reservationTitle.text = @"Rezervasyon No:";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _reservation = [_reservationList objectAtIndex:indexPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // 13.02.2015 Ata Cengiz
        if (_reservation.isContract) {
            [self getDetailedVehicleInformationFromSAP];
        }
        else {
            [self getOldReservationDetail];
        }
        // 13.02.2015 Ata Cengiz

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if (_reservation.selectedCarGroup != nil)
                [self performSegueWithIdentifier:@"toReservationDetail" sender:self];
        });
    });
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([[segue identifier] isEqualToString:@"toReservationDetail"]) {
        [(OldReservationDetailVC*)[segue destinationViewController] setOldCheckInTime:_reservation.checkInTime];
        [(OldReservationDetailVC*)[segue destinationViewController] setOldCheckOutTime:_reservation.checkOutTime];
        [(OldReservationDetailVC*)[segue destinationViewController] setOldCheckInOffice:_reservation.checkInOffice];
        [(OldReservationDetailVC*)[segue destinationViewController] setOldCheckOutOffice:_reservation.checkOutOffice];
        [(OldReservationDetailVC*)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationDetailVC*)[segue destinationViewController] setTotalPrice:_totalPrice];
    }
    
    if ([[segue identifier] isEqualToString:@"ToLoginVCSegue"]) {
        LoginVC *loginVC = (LoginVC *)[segue destinationViewController];
        loginVC.shouldNotPop = YES;
        loginVC.leftButton = [[self navigationItem] leftBarButtonItem];
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
        
        if (response != nil) {
            _reservation.additionalEquipments = [NSMutableArray new];
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            _reservation.documentTotalPrice = [NSDecimalNumber decimalNumberWithString:[[export valueForKey:@"ES_DETAIL"] valueForKey:@"TOPLAM_TUTAR"]];
            
            _reservation.paymentType = [[export valueForKey:@"ES_DETAIL"] valueForKey:@"ODEME_TURU"];
            
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
                NSString *fikod = @"";
                
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
                        [_reservation.additionalEquipments addObject:equiObj];
                    else
                    {
                        plateNo = [tempEqui valueForKey:@"PLAKA_NO"];
                        chassisNo = [tempEqui valueForKey:@"SASE_NO"];
                        fikod = [tempEqui valueForKey:@"FIYAT_KODU"];
                    }
                    
                    // Ata Cengiz 09.02.2015
                    if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *paymentType = [tempEqui valueForKey:@"KURUM_BIREYSEL"];
                        equiObj.paymentType = paymentType;
                    }
                    // Ata Cengiz 09.02.2015
                }
                
                //araç seçimi yapılmışmı diye bakılıyor
                NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0031"];
                NSArray *filterResult = [_reservation.additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                
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
                    [tempCar setPriceCode:fikod];
                    [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempCar setWinterTire:[tempDict valueForKey:@"KIS_LASTIK"]];
                    [tempCar setColorCode:[tempDict valueForKey:@"RENK"]];
                    [tempCar setColorName:[tempDict valueForKey:@"RENKTX"]];
                    [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
                    [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
                    [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
                    [tempCar setSalesOffice:[tempDict valueForKey:@"MSUBE"]];
                    
                    NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
                    imagePath = [imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSURL *imageUrl = [NSURL URLWithString:imagePath];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                    UIImage *carImage = [UIImage imageWithData:imageData];
                    tempCar.image = carImage;
                    
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
                    
                    if ([_reservation.reservationType isEqualToString:@"10"])
                    {
                        _reservation.selectedCar = [Car new];
                        _reservation.selectedCar = tempCar;
                    }
                    
                    [_reservation setSelectedCarGroup:tempCarGroup];
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

// Ata Cengiz 12.02.2015 Açık Sözleşme
- (void)getActiveContractsFromSAP {
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZCRM_GET_SOZLESME_DETAIL"];
        
        [handler addImportParameter:@"IV_MUSTERI" andValue:[[ApplicationProperties getUser] kunnr]];
        [handler addImportParameter:@"IV_SUREUZATMA" andValue:@"X"];
        
        [handler addTableForReturn:@"ET_SOZLESME"];
        [handler addTableForReturn:@"ET_ITEMS"];
        [handler addTableForReturn:@"ET_MESSAGE"];

        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            
            NSDictionary *contracts = [tables objectForKey:@"ZSOZLESME_DETAIL"];
            
            if (contracts.count > 0) {
                NSDictionary *items = [tables objectForKey:@"ZSOZLESME_DETAIL_ITEM"];
                
                for (NSDictionary *tempDict in contracts) {
                    Reservation *tempReservation = [[Reservation alloc] init];
                    tempReservation.checkInOffice = [Office new];
                    tempReservation.checkOutOffice = [Office new];
                    tempReservation.paymentNowCard = [CreditCard new];
                    tempReservation.additionalEquipments = [NSMutableArray new];
                    
                    tempReservation.documentTotalPrice = [NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TOPLAM_TUTAR"]];
                    tempReservation.checkOutOffice.subOfficeCode = [tempDict valueForKey:@"CIKIS_SUBE"];
                    tempReservation.checkOutOffice.subOfficeName = [tempDict valueForKey:@"CIKIS_SUBE_TXT"];
                    tempReservation.checkInOffice.subOfficeCode = [tempDict valueForKey:@"DONUS_SUBE"];
                    tempReservation.checkInOffice.subOfficeName = [tempDict valueForKey:@"DONUS_SUBE_TXT"];

                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *checkOutDate = [formatter dateFromString:[tempDict valueForKey:@"SOZ_BAS_TAR"]];
                    NSDate *checkInDate = [formatter dateFromString:[tempDict valueForKey:@"SOZ_BIT_TAR"]];
                    
                    [formatter setDateFormat:@"HH:mm:ss"];
                    NSDate *checkOutTime = [formatter dateFromString:[tempDict valueForKey:@"SOZ_BAS_SAAT"]];
                    NSDate *checkInTime = [formatter dateFromString:[tempDict valueForKey:@"SOZ_BIT_SAAT"]];
                   
                    tempReservation.checkOutTime = [self setDates:checkOutDate andTime:checkOutTime];
                    tempReservation.checkInTime = [self setDates:checkInDate andTime:checkInTime];
                    
                    NSString *status = [tempDict valueForKey:@"SOZ_DURUM"];
                    
                    if (![status isEqualToString:@"E0003"]) {
                        continue;
                    }
                    
                    tempReservation.reservationNumber = [tempDict valueForKey:@"SOZ_NO"];
                    tempReservation.reservationStatuId = status;
                    tempReservation.reservationStatu = [tempDict valueForKey:@"SOZ_DURUM_TXT"];
                    tempReservation.reservationType = [tempDict valueForKey:@"ARACREZTIPI"];
                    tempReservation.paymentNowCard.uniqueId = [tempDict valueForKey:@"MER_KEY"];
                    tempReservation.isContract = YES;
                    
                    for (NSDictionary *tempItem in items) {
                        NSString *contractNumber = [tempItem valueForKey:@"SOZ_NO"];
                        
                        if ([tempReservation.reservationNumber isEqualToString:contractNumber]) {
                            
                            NSString *isVehicle = [tempItem valueForKey:@"IS_ARAC"];
                            
                            // Araç satırı
                            if ([isVehicle isEqualToString:@"X"]) {
                                
                                Car *tempCar = [Car new];
                                tempCar.pricing = [Price new];
                                
                                [[tempCar pricing] setPayNowPrice:[NSDecimalNumber decimalNumberWithString:[tempItem valueForKey:@"TUTAR"]]];
                                
                                
                                [tempCar setMaterialCode:[tempItem valueForKey:@"MALZEME"]];
                                [tempCar setMaterialName:[tempItem valueForKey:@"MALZEME_TANIM"]];
                                [tempCar setPlateNo:[tempItem valueForKey:@"PLAKA_NO"]];
                                [tempCar setChassisNo:[tempItem valueForKey:@"SASE_NO"]];
                                [tempCar setContractItemNumber:[tempItem valueForKey:@"KALEM_NO"]];

                                CarGroup *tempCarGroup = [CarGroup new];
                                
                                [tempCarGroup setGroupCode:[tempDict valueForKey:@"ZZARACGRUBU"]];
                                
                                [tempCarGroup setSampleCar:tempCar];
                                [tempCarGroup.cars addObject:tempCar];
                                                                
                                [tempReservation setSelectedCarGroup:tempCarGroup];
                                [tempReservation setSelectedCar:tempCar];
                            }
                            // Ekipman satırı
                            else {
                                
                                AdditionalEquipment *equiObj = [AdditionalEquipment new];
                                
                                equiObj.materialNumber = [tempItem valueForKey:@"MALZEME"];
                                equiObj.materialDescription = [tempItem valueForKey:@"MALZEME_TANIM"];
                                equiObj.quantity = [[tempItem valueForKey:@"MIKTAR"] intValue];
                                equiObj.price = [NSDecimalNumber decimalNumberWithString:[tempItem valueForKey:@"TUTAR"]];
                                equiObj.price = [equiObj.price decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",equiObj.quantity]]];
                                equiObj.contractItemNumber = [tempItem valueForKey:@"KALEM_NO"];
                                
                                [tempReservation.additionalEquipments addObject:equiObj];
                            }
                        }
                    }
                    
                    [_activeReservationList insertObject:tempReservation atIndex:0];
                    [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
                    [_segmentedControl setSelectedSegmentIndex:0];
                }
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
// Ata Cengiz 12.02.2015 Açık Sözleşme

// Ata Cengiz 13.02.2015 Araç bilgisi
- (void)getDetailedVehicleInformationFromSAP {
    
    NSString *alertString = @"";
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZPM_KDK_ARAC_BILGI_DETAY"];
        
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        
        [handler addTableForImport:@"IMPT_PLAKALIST" andColumns:@[@"LICENSE_NUM"] andValues:@[@[_reservation.selectedCar.plateNo]]];
        [handler addTableForReturn:@"EXPT_ARACDETAY"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *carDetail = [tables objectForKey:@"ZPM_S_ARAC_BILGI_DETAY"];
            
            for (NSDictionary *tempDict in carDetail) {
                Car *tempCar = _reservation.selectedCar;
    
                [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
                [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
                [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
                [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
                [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
                
                NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
                imagePath = [imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                NSURL *imageUrl = [NSURL URLWithString:imagePath];
                
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *carImage = [UIImage imageWithData:imageData];
                tempCar.image = carImage;
                
                if (tempCar.image == nil) {
                    [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
                }
                
                [tempCar setDoorNumber:[tempDict valueForKey:@"KAPI_SAYISI"]];
                [tempCar setPassangerNumber:[tempDict valueForKey:@"YOLCU_SAYISI"]];

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
                
                [[tempCarGroup cars] addObject:tempCar];
                [tempCarGroup setSampleCar:tempCar];
                
                [_reservation setSelectedCar:tempCar];
                [_reservation setSelectedCarGroup:tempCarGroup];
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
// Ata Cengiz 13.02.2015 Araç bilgisi

@end
