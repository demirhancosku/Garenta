//
//  ClassicSearchVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "ClassicSearchVC.h"
#import "OfficeHolidayTime.h"
#import "CarGroupManagerViewController.h"
#import "GTMBase64.h"
#import "CarGroupFilterVC.h"
#import "ZGARENTA_OFIS_SRVServiceV0.h"
#import "ZGARENTA_OFIS_SRVRequestHandler.h"
#import "ZGARENTA_ARAC_SRVServiceV0.h"
#import "ZGARENTA_ARAC_SRVRequestHandler.h"
#import "ParsingConstants.h"
#import "WYStoryboardPopoverSegue.h"
#define kCheckOutTag 0
#define kCheckInTag 1

@interface ClassicSearchVC () <WYPopoverControllerDelegate>

@end

@implementation ClassicSearchVC
@synthesize popOver;


#pragma mark - View lifcycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect navigationBarFrame = [[[self navigationController] navigationBar] frame];
    //ysinde navigationBarFrame.size.height vardi viewwillapear super cagirilmamaisti onu cagirinca buna gerek kalmadi
    viewFrame =CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width - navigationBarFrame.size.height );
    reservation = [[Reservation alloc] init];
    [self addNotifications];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:25];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ekranki component'ların ayarlaması yapılıyor
    [self prepareScreen];
    
    //only once singleton koydum devam etsin burdan
    offices = [ApplicationProperties getOffices];
    
    if (offices.count ==0) {
        [self getOfficesFromSAP];
    }
    
    [self correctCheckIndate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self removeNotifcations];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    if ([tableView tag] == kCheckOutTag)
    {
        if ([indexPath row] == 0)
        {
            if (reservation.checkOutOffice == nil)
            {   if([ApplicationProperties getMainSelection] != location_search){
                [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
            }else{
                [[cell textLabel] setText:@"Size En Yakın Araçlar"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:reservation.checkOutOffice.subOfficeName];
        }
        else
        {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd.MM.yyyy"];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"HH:mm"];
            
            //Optionally for time zone converstions
            NSString *stringFromDate = [formatter stringFromDate:[reservation checkOutTime]];
            NSString *stringFromTime = [formatter2 stringFromDate:[reservation checkOutTime]];
            
            if (reservation.checkOutTime == nil && reservation.checkOutTime == nil)
            {
                [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:[NSString stringWithFormat:@"%@%@%@",stringFromDate,@" - ",stringFromTime]];
        }
    }
    else
    {
        if ([indexPath row] == 0)
        {
            if (reservation.checkInOffice == nil)
            {
                [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:reservation.checkInOffice.subOfficeName];
        }
        else
        {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd.MM.yyyy"];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"HH:mm"];
            
            //Optionally for time zone converstions
            NSString *stringFromDate = [formatter stringFromDate:[reservation checkInTime]];
            NSString *stringFromTime = [formatter2 stringFromDate:[reservation checkInTime]];
            
            if (reservation.checkOutTime == nil)
            {
                [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:[NSString stringWithFormat:@"%@%@%@",stringFromDate,@" - ",stringFromTime]];
        }
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == kCheckOutTag)
    {
        if (indexPath.row == 0 && [ApplicationProperties getMainSelection] != location_search) {
            
            OfficeListVC *office = [[OfficeListVC alloc] initWithReservation:reservation andTag:tableView.tag andOfficeList:offices ];
            [[self navigationController] pushViewController:office animated:YES];
            
        }
        if(indexPath.row == 1 )
        {
//            UIViewController *vc;
//            vc = [[CalendarTimeVC alloc] initWithReservation:reservation andTag:tableView.tag];
//            [self.navigationController pushViewController:vc animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"toDateTimeVCSegue" sender:cell];
        }
    }
    else
    {
        if (indexPath.row == 0) {
            
            OfficeListVC *office = [[OfficeListVC alloc] initWithReservation:reservation andTag:tableView.tag andOfficeList:offices ];
            [[self navigationController] pushViewController:office animated:YES];
        }
        else
        {
//            UIViewController *vc;
//            vc = [[CalendarTimeVC alloc] initWithReservation:reservation andTag:tableView.tag];
//            [self.navigationController pushViewController:vc animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"toDateTimeVCSegue" sender:cell];
        }
    }
}

- (UITableViewCell *)getMenuCell:(UITableViewCellStyle)style
{
    static NSString *cellType = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellType];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[ApplicationProperties getMenuCellBackground]];
    [cell setOpaque:YES];
    [[cell textLabel] setTextColor:[ApplicationProperties getBlack]];
    [[cell textLabel] setFont:[UIFont fontWithName:[ApplicationProperties getFont] size:24.0]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:[ApplicationProperties getFont] size:16.0]];
    
    return cell;
}

- (UITableViewCell *)refreshCell:(UITableViewCell *)cell
{
    [[cell imageView] setImage:nil];
    [[cell textLabel] setText:@""];
    [[cell detailTextLabel] setText:@""];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setAccessoryView:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (tableView == destinationTableView) {
        sectionName = @"ARAÇ TESLİM";
    }
    else
    {
        sectionName = @"ARAÇ İADE";
    }
    
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (void)tableViewDidReturn:(id)sender
{
    [popOver dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [arrivalTableView reloadData];
    [destinationTableView reloadData];
}

#pragma mark - gateway connection delegates

- (void)getOfficesFromSAP {
    
    @try {
        [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_SUBE_CALISMA_SAAT"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil) {
            NSDictionary *resultTables = [resultDict valueForKey:@"EXPORT"];
            
            NSDictionary *officeInformation = [resultTables valueForKey:@"EXPT_SUBE_BILGILERI"];
            NSDictionary *officeInformationArray = [officeInformation valueForKey:@"ZMOB_TT_SUBE_MASTER"];
            
            NSDictionary *officeWorkingHours = [resultTables valueForKey:@"EXPT_CALISMA_ZAMANI"];
            NSDictionary *officeWorkingHoursArray = [officeWorkingHours valueForKey:@"ZMOB_TT_SUBE_CALSAAT"];
            
            NSDictionary *officeHolidays = [resultTables valueForKey:@"EXPT_TATIL_ZAMANI"];
            NSDictionary *officeHolidayArray = [officeHolidays valueForKey:@"ZMOB_TT_SUBE_TATIL"];
            
            for (NSDictionary *tempDict in officeInformationArray) {
                
                // Aktif olmayan şubeleri almıyoruz
                if (![[tempDict valueForKey:@"AKTIFSUBE"] isEqualToString:@"X"]) {
                    continue;
                }
                
                Office *tempOffice = [[Office alloc] init];
                [tempOffice setMainOfficeCode:[tempDict valueForKey:@"MERKEZ_SUBE"]];
                [tempOffice setMainOfficeName:[tempDict valueForKey:@"MERKEZ_SUBETX"]];
                [tempOffice setSubOfficeCode:[tempDict valueForKey:@"ALT_SUBE"]];
                [tempOffice setSubOfficeName:[tempDict valueForKey:@"ALT_SUBETX"]];
                [tempOffice setSubOfficeType:[tempDict valueForKey:@"ALT_SUBETIPTX"]];
                [tempOffice setSubOfficeTypeCode:[tempDict valueForKey:@"ALT_SUBETIP"]];
                [tempOffice setCityCode:[tempDict valueForKey:@"SEHIR"]];
                [tempOffice setCityName:[tempDict valueForKey:@"SEHIRTX"]];
                [tempOffice setAddress:[tempDict valueForKey:@"ADRES"]];
                [tempOffice setTel:[tempDict valueForKey:@"TEL"]];
                [tempOffice setFax:[tempDict valueForKey:@"FAX"]];
                [tempOffice setLongitude:[tempDict valueForKey:@"YKORD"]];
                [tempOffice setLatitude:[tempDict valueForKey:@"XKORD"]];
                

                NSMutableArray *workingHoursArray = [NSMutableArray new];
                
                for (NSDictionary *tempWorkHourDict in officeWorkingHoursArray) {
                    if ([[tempWorkHourDict valueForKey:@"MERKEZ_SUBE"] isEqualToString:[tempOffice mainOfficeCode]]) {
                        OfficeWorkingTime *tempTime = [[OfficeWorkingTime alloc] init];
                        tempTime.startTime = [tempWorkHourDict valueForKey:@"BEGTI"];
                        tempTime.endingHour = [tempWorkHourDict valueForKey:@"ENDTI"];
                        tempTime.weekDayCode = [tempWorkHourDict valueForKey:@"CADAY"];
                        tempTime.weekDayName = [tempWorkHourDict valueForKey:@"CADAYTX"];
                        tempTime.subOffice = [tempWorkHourDict valueForKey:@"ALT_SUBE"];
                        tempTime.mainOffice = [tempWorkHourDict valueForKey:@"MERKEZ_SUBE"];
                        
                        [workingHoursArray addObject:tempTime];
                    }
                }
                
                [tempOffice setWorkingDates:[workingHoursArray copy]];
                
                NSMutableArray *holidayArray = [NSMutableArray new];
                
                for (NSDictionary *tempHolidayDict in officeHolidayArray) {
                    if ([[tempHolidayDict valueForKey:@"MERKEZ_SUBE"] isEqualToString:[tempOffice mainOfficeCode]]) {
                        OfficeWorkingTime *tempTime = [[OfficeWorkingTime alloc] init];
                        tempTime.startTime = [tempHolidayDict valueForKey:@"BEGTI"];
                        tempTime.endingHour = [tempHolidayDict valueForKey:@"ENDTI"];
                        tempTime.weekDayCode = [tempHolidayDict valueForKey:@"CADAY"];
                        tempTime.weekDayName = [tempHolidayDict valueForKey:@"CADAYTX"];
                        tempTime.subOffice = [tempHolidayDict valueForKey:@"ALT_SUBE"];
                        tempTime.mainOffice = [tempHolidayDict valueForKey:@"MERKEZ_SUBE"];
                        
                        [holidayArray addObject:tempTime];
                    }
                }
                
                [tempOffice setHolidayDates:[holidayArray copy]];
                
                [offices addObject:tempOffice];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
    }
}

- (void)showCarGroup:(id)sender
{
    
    NSDate *checkInTime;
    NSDate *checkInDate;
    NSDate *checkOutTime;
    NSDate *checkOutDate;
    NSDate *nowTime;
    NSDate *nowDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // sadece gün, ay, yıl bazında karşılaştırma yapabilmek için
    NSInteger dateComps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    
    NSDateComponents *checkInDateComp = [calendar components:dateComps
                                                    fromDate: [reservation checkInTime]];
    NSDateComponents *checkOutDateComp = [calendar components:dateComps
                                                     fromDate: [reservation checkOutTime]];
    NSDateComponents *nowDateComp = [calendar components:dateComps
                                                fromDate: [NSDate date]];
    
    checkInDate = [calendar dateFromComponents:checkInDateComp];
    checkOutDate = [calendar dateFromComponents:checkOutDateComp];
    nowDate = [calendar dateFromComponents:nowDateComp];
    
    // sadece saat ve dakika bazında karşılaştırma yapabilmek için
    NSInteger timeComps = (NSHourCalendarUnit | NSMinuteCalendarUnit);
    
    NSDateComponents *checkInTimeComp = [calendar components:timeComps
                                                    fromDate: [reservation checkInTime]];
    NSDateComponents *checkOutTimeComp = [calendar components:timeComps
                                                     fromDate: [reservation checkOutTime]];
    NSDateComponents *nowTimeComp = [calendar components:timeComps
                                                fromDate: [NSDate date]];
    
    checkInTime = [calendar dateFromComponents:checkInTimeComp];
    checkOutTime = [calendar dateFromComponents:checkOutTimeComp];
    nowTime = [calendar dateFromComponents:nowTimeComp];
    if([checkOutDate compare:nowDate] == NSOrderedAscending){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Geçmişe dönük rezervasyon yapılamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }else if ([checkOutDate compare:nowDate] == NSOrderedSame){
        if ([checkOutTime compare:nowTime] ==NSOrderedAscending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Geçmişe dönük rezervasyon yapılamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
            
            [alert show];
            return;
        }
    }
    
    
    if([checkInDate compare:checkOutDate] == NSOrderedAscending)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Aracı teslim alacağınız tarih, iade edeceğiniz tarihten ileri olamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    else if ([checkInDate compare:checkOutDate] == NSOrderedSame)
    {
        if ([checkInTime compare:checkOutTime] == NSOrderedAscending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Aracı teslim alacağınız saat, iade edeceğiniz saatten ileri olamaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
            
            [alert show];
            return;
            
        }
        
    }
    
    [self getAvailableCarsFromSAP];
}

- (void)getAvailableCarsFromSAP{
    UIAlertView *errorAlertView;
    if ([ApplicationProperties getMainSelection] != location_search && reservation.checkOutOffice == nil) {
        errorAlertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Lütfen çıkış ofisi seçiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [errorAlertView show];
        return;
    }
    if (reservation.checkInOffice == nil) {
        errorAlertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Lütfen dönüş ofisi seçiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [errorAlertView show];
        return;
    }
    //trans
    //formatter for hour and minute
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HHmm"];
    [ApplicationProperties configureCarService];
    AvailCarServiceV0 *availableCarService = [AvailCarServiceV0 new];
    [availableCarService setImppMsube:@" "];
    [availableCarService setIMPT_MSUBESet:[self prepareOfficeImport]];
    [availableCarService setImppBegda:reservation.checkOutTime];
    [availableCarService setExppSubrc:[NSNumber numberWithInt:0]];
    [availableCarService setExpKkgiris:@" "];
    [availableCarService setImppBeguz:[dateFormatter stringFromDate:reservation.checkOutTime]];
    [availableCarService setImppEnduz:[dateFormatter stringFromDate:reservation.checkInTime]];
    [availableCarService setImppEndda:reservation.checkInTime];
    [availableCarService setImppFikod:@"00"]; //???
    [availableCarService setImppUname:@" "];  //bu ne lan
    [availableCarService setImppHdfsube:reservation.checkInOffice.mainOfficeCode];
    [availableCarService setImppKdgrp:@" "]; //bu ne be
    
    
    User *user =[ApplicationProperties getUser];
    if ([ user isLoggedIn]) {
        [availableCarService setImppKunnr:[user kunnr]];
        [availableCarService setImppEhdat:[NSDate dateWithTimeIntervalSince1970:0]];//[user driversLicenseDate]
        [availableCarService setImppGbdat:[NSDate dateWithTimeIntervalSince1970:0]]; //[user birthday]
    }else{
        [availableCarService setImppKunnr:@" "];
        [availableCarService setImppEhdat:[NSDate dateWithTimeIntervalSince1970:0]];
        [availableCarService setImppGbdat:[NSDate dateWithTimeIntervalSince1970:0]];
    }
    if (availableCarService.IMPT_MSUBESet.count == 1 && [(IMPT_MSUBEV0*)[availableCarService.IMPT_MSUBESet objectAtIndex:0] Msube] == nil) {
        
        [availableCarService setImppSehir:reservation.checkOutOffice.cityCode];
    }else{
        [availableCarService setImppSehir:@"00"];
    }
    
    //    [availableCarService setImppUname:@"AALPK"]; why
    [availableCarService setImppWaers:@"TRY"]; //probably they dont check
    [availableCarService setImppLangu:@"T"];   //probably they dont check
    [availableCarService setImppLand:@"TR"];   //probably they dont check
    
    
    NSMutableArray *carsImport =[[NSMutableArray alloc] init];
    ET_ARACLISTEV0 *dummyCar = [[ET_ARACLISTEV0  alloc] init];
    [dummyCar setAracsayi:[NSNumber numberWithInt:0]];
    [dummyCar setAcilirTavan:@"of"];
    [dummyCar setAnarenktx:@" "];
    [dummyCar setAux:@" "];
    [dummyCar setBagajHacmi:@" "];
    [dummyCar setBeygirGucu:@" "];
    [dummyCar setBluetooth:@" "];
    [dummyCar setCamTavan:@" "];
    [dummyCar setCekis:@" "];
    [dummyCar setCruiseKontrol:@" "];
    [dummyCar setDeriDoseme:@" "];
    [dummyCar setDjitalKlima:@" "];
    [dummyCar setEsp:@" "];
    [dummyCar setGencSrcEhl:@" "];
    [dummyCar setGencSrcYas:@" "];
    [dummyCar setGeriGorusKam:@" "];
    [dummyCar setGrpkod:@" "];
    [dummyCar setGrpkodtx:@" "];
    [dummyCar setGrubaRez:@" "];
    [dummyCar setHandsFree:@" "];
    [dummyCar setHsube:@" "];
    [dummyCar setHsubetx:@" "];
    [dummyCar setIsitmaliKoltuk:@" "];
    [dummyCar setIsofix:@" "];
    [dummyCar setKapiSayisi:@" "];
    [dummyCar setKasaTipi:@" "];
    [dummyCar setKasaTipiId:@" "];
    [dummyCar setKisLastik:@" "];
    [dummyCar setMaktx:@" "];
    [dummyCar setMarka:@" "];
    [dummyCar setMarkaId:@" "];
    [dummyCar setMatnr:@" "];
    [dummyCar setMinEhliyet:@" "];
    [dummyCar setMinYas:@" "];
    [dummyCar setModel:@" "];
    [dummyCar setModelId:@" "];
    [dummyCar setModelYili:@" "];
    [dummyCar setMotorHacmi:@" "];
    [dummyCar setMsube:@" "];
    [dummyCar setMsubetx:@" "];
    [dummyCar setNavigasyon:@" "];
    [dummyCar setOrtYakitTuketim:@" "];
    [dummyCar setParkSensoruArka:@" "];
    [dummyCar setParkSensoruOn:@" "];
    [dummyCar setPlakayaRez:@" "];
    [dummyCar setRenk:@" "];
    [dummyCar setRenktx:@" "];
    [dummyCar setRgbkodu:@" "];
    [dummyCar setSanzimanTipi:@" "];
    [dummyCar setSanzimanTipiId:@" "];
    [dummyCar setSegment:@" "];
    [dummyCar setSegmenttx:@" "];
    [dummyCar setSehir:@" "];
    [dummyCar setSifirYuzHiz:@" "];
    [dummyCar setStartStop:@" "];
    [dummyCar setTrdonanim:@" "];
    [dummyCar setTrmodel:@" "];
    [dummyCar setTrversiyon:@" "];
    [dummyCar setVitrinres:@" "];
    [dummyCar setXenonFar:@" "];
    [dummyCar setYagmurSensoru:@" "];
    [dummyCar setYakitTipi:@" "];
    [dummyCar setYakitTipiId:@" "];
    [dummyCar setYolcuSayisi:@" "];
    [dummyCar setZresim135:@" "];
    [dummyCar setZresim180:@" "];
    [dummyCar setZresim315:@" "];
    [dummyCar setZresim45:@" "];
    [dummyCar setZresim90:@" "];
    [dummyCar setAbs:@" "];
    [dummyCar setAugru:@" "];
    
    [carsImport addObject:dummyCar];
    [availableCarService setET_ARACLISTESet:carsImport];
    NSMutableArray *priceImport = [NSMutableArray new];
    ET_FIYATV0 *dummyFiyat = [ET_FIYATV0 new];
    [dummyFiyat setSimdiOdeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setSonraOdeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracGrubu:@" "];
    [dummyFiyat setAracSecimFarkEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAylikFiyatKod:@" "]; //aylik fiyat kodu varsa liste fiyat kdvsiz
    [dummyFiyat setBuFiyataSon:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setBuKampSon:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setCikisSube:@" "];
    [dummyFiyat setFreeGun:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setGunSayisi:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setIl:@" "];
    [dummyFiyat setKampanyaId:@" "];
    [dummyFiyat setKampanyaKapsam:@" "];
    [dummyFiyat setKampanyaOran:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTanim:@" "];
    [dummyFiyat setKampanyaTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKanalTuru:@" "];
    [dummyFiyat setKasaTip:@" "];
    [dummyFiyat setKazancEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setKazancGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setKazancTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKazancUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setMarkaId:@" "];
    [dummyFiyat setModelId:@" "];
    [dummyFiyat setRezTuru:@" "];
    [dummyFiyat setSanzTip:@" "];
    [dummyFiyat setYakitTip:@" "];
    [dummyFiyat setAracSecim:@" "];
    [dummyFiyat setParoKazanir:@" "];
    [dummyFiyat setParafKazanir:@" "];
    [dummyFiyat setBonusKazanir:@" "];
    [dummyFiyat setMilKazanir:@" "];
    [dummyFiyat setGarentatlKazanir:@" "];
    [dummyFiyat setWingsKazanir:@" "];
    [priceImport addObject:dummyFiyat];
    [availableCarService setET_FIYATSet:priceImport];
    /*
     ET_KAMPANYAV0 *dummyKampanya = [ET_KAMPANYAV0 new];
     [dummyKampanya setKalanciro:@" "];
     [dummyKampanya setKalanadet:@" "];
     [dummyKampanya setZzkmphedefgun:@" "];
     [dummyKampanya setZzkmpharictutbas:[NSDate date]];
     [dummyKampanya setZzkmpharictutbit:[NSDate date]];
     [dummyKampanya setZzkmprezolusbit:[NSDate date]];
     [dummyKampanya setZzkmprezolusbas:[NSDate date]];
     [dummyKampanya setZzszlsmefreegun:@" "];
     [dummyKampanya setZzerkeniadeucrt:@" "];
     [dummyKampanya setZzsureuzatucrt:@" "];
     [dummyKampanya setZzaracdonustar:[NSDate date]];
     [dummyKampanya setZzaraccikistar:[NSDate date]];
     [dummyKampanya setZzkmprezolusma:@" "];
     [dummyKampanya setZzkmprezolusma:@" "];
     [dummyKampanya setKampanyatipi:@" "];
     [dummyKampanya setLandingPath:@" "];
     [dummyKampanya setIconPath:@" "];
     [dummyKampanya setGarentatl:@""];
     [dummyKampanya setBonusKazanir:@" "];
     [dummyKampanya setMilKazanir:@" "];
     [dummyKampanya setKampDurum:@" "];
     [dummyKampanya setPlanEndda:[NSDate date]];
     [dummyKampanya setPlanBegda:[NSDate date]];
     [dummyKampanya setDonusSube:@" "];
     [dummyKampanya setCikisSube:@" "];
     [dummyKampanya setKampTanim:@" "];
     [dummyKampanya setIsbirligi:@" "];
     [dummyKampanya setObjectType:@" "];
     [dummyKampanya setCampType:@" "];
     [dummyKampanya setKampanyaId:@" "];
     [dummyKampanya setOncelik:@" "];
     [availableCarService setET_KAMPANYASet:[NSMutableArray arrayWithObject:dummyKampanya]];
     */
    ET_EXPIRYV0 *dummyExpiry = [ET_EXPIRYV0 new];
    [dummyExpiry setAracGrubu:@" "];
    [dummyExpiry setDonemBasi:[NSDate date]];
    [dummyExpiry setDonemSonu:[NSDate date]];
    [dummyExpiry setMarkaId:@" "];
    [dummyExpiry setModelId:@" "];
    [dummyExpiry setParaBirimi:@" "];
    [dummyExpiry setTutar:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
    
    [availableCarService setET_EXPIRYSet:[NSMutableArray arrayWithObject:dummyExpiry]];
    
    ET_INDIRIMLISTV0 *dummyDiscount = [ET_INDIRIMLISTV0 new];
    [dummyDiscount setAracGrubu:@" "];
    [dummyDiscount setBeginDate:[NSDate date]];
    [dummyDiscount setEndDate:[NSDate date]];
    [dummyDiscount setErkenodemeInd:@" "];
    [dummyDiscount setFiloSegmenti:@" "];
    [dummyDiscount setFiyat:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
    [dummyDiscount setFiyatKodu:@" "];
    [dummyDiscount setGovdeTipi:@" "];
    [dummyDiscount setKampanyaId:@" "];
    [dummyDiscount setKampMiktar:@" "];
    [dummyDiscount setKampYuzde:@" "];
    [dummyDiscount setMalzemeNo:@" "];
    [dummyDiscount setMarkaId:@" "];
    [dummyDiscount setModelId:@" "];
    [dummyDiscount setParaBirimi:@" "];
    [dummyDiscount setRezvTuru:@" "];
    [dummyDiscount setSanzimanTipi:@" "];
    [dummyDiscount setSube:@" "];
    [dummyDiscount setYakitTipi:@" "];
    [availableCarService setET_INDIRIMLISTSet:[NSMutableArray arrayWithObject:dummyDiscount]];
    
    ET_RESERVV0 *dummyReserv = [ET_RESERVV0 new];
    [dummyReserv setAugru:@" "];
    [dummyReserv setBonusKazanir:@" "];
    [dummyReserv setEqunr:@" "];
    [dummyReserv setFiyatKodu:@" "];
    [dummyReserv setGrnttlKazanir:@" "];
    [dummyReserv setGrupKodu:@" "];
    [dummyReserv setHdfsube:@" "];
    [dummyReserv setKunnr:@" "];
    [dummyReserv setMandt:@" "];
    [dummyReserv setMatnr:@" "];
    [dummyReserv setMilKazanir:@" "];
    [dummyReserv setRAuart:@" "];
    [dummyReserv setRGjahr:@" "];
    [dummyReserv setRPosnr:@" "];
    [dummyReserv setRVbeln:@" "];
    [dummyReserv setSpart:@" "];
    [dummyReserv setSube:@" "];
    [dummyReserv setTarih:[NSDate date]];
    [dummyReserv setTutar:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
    [dummyReserv setVkorg:@" "];
    [dummyReserv setVtweg:@" "];
    
    [availableCarService setET_RESERVSet:[NSMutableArray arrayWithObject:dummyReserv]];
    
    [[ZGARENTA_ARAC_SRVRequestHandler uniqueInstance] createAvailCarService:availableCarService];
    
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
}

- (NSMutableArray*)prepareOfficeImport{
    IMPT_MSUBEV0 *officeImport;
    NSMutableArray *officesResult = [NSMutableArray new];
    if ([ApplicationProperties getMainSelection] == location_search) {
        //for now first 3 offices
        NSMutableArray *closestoffices = [ApplicationProperties closestFirst:3 fromOffices:[ApplicationProperties getOffices] toMyLocation:lastLocation];
        //TODO: burda sub officelerden dolayi bir sikinti var
        for (Office*tempOffice in closestoffices) {
            officeImport = [IMPT_MSUBEV0 new];
            [officeImport setMsube:tempOffice.mainOfficeCode];
            [officesResult addObject:officeImport];
        }
    }else{
        //add selected office
        if (reservation.checkOutOffice != nil) {
            officeImport = [IMPT_MSUBEV0 new];
            [officeImport setMsube:reservation.checkOutOffice.mainOfficeCode];
            [officesResult addObject:officeImport];
        }
        
    }
    return officesResult;
}
#pragma mark - Location Delegation Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    lastLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
}

#pragma mark - util methods

- (void)parseCars:(NSNotification*)notification{
    
    [[LoaderAnimationVC uniqueInstance] stopAnimation];
    if ([notification userInfo][kServerResponseError] != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Sistemlerimizde bakım çalışması yapılmaktadır. Lütfen daha sonra tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alertView show];
        return;
        
    }
    AvailCarServiceV0 *availServiceResponse = (AvailCarServiceV0*)[[notification userInfo] objectForKey:kResponseItem];
    availableCarGroups = [CarGroup getCarGroupsFromServiceResponse:availServiceResponse withOffices:offices];
    [reservation setEtReserv:availServiceResponse.ET_RESERVSet];
    [self checkDates:^(BOOL isOK,NSString *errorMsg){
        if (isOK) {
            [self navigateToNextVC];
        }else{
            UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:errorMsg delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}



- (UIImage*)getImageFromJSONResults:(NSDictionary*)pics withPath:(NSString*)aPath{
    UIImage *carImage = [[UIImage alloc] init];
    NSString *picBinaryString;
    NSData *picData;
    //aalpk burda eger resim bulunmuyorsa standart bir resim koymak lazım
    for (NSDictionary *picLine in pics) {
        if ([[picLine objectForKey:@"Path"] isEqualToString:aPath]) {
            picBinaryString = [picLine objectForKey:@"Picturedata"];
            picData =
            [NSData dataWithData:[YAJL_GTMBase64 decodeString:picBinaryString]];
            
            carImage = [UIImage imageWithData:picData];
        }
    }
    return carImage;
}


//checks wheather the checkin date before checkout and correct accordingly
- (void)correctCheckIndate {
    if ([reservation.checkOutTime compare:reservation.checkInTime] == NSOrderedDescending) {
        reservation.checkInTime = [reservation.checkOutTime copy];
    }
}

- (void)prepareScreen
{
    
    [self setIphoneLayer];
    [arrivalTableView setRowHeight:45];
    [destinationTableView setRowHeight:45];
    
    //
    //    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    //    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    
    [searchButton setTitle:@"Teklifleri Göster" forState:UIControlStateNormal];
    [[searchButton layer] setCornerRadius:5.0f];
    [searchButton setBackgroundColor:[ApplicationProperties getGreen]];
    [searchButton setTintColor:[ApplicationProperties getWhite]];
    [searchButton addTarget:self action:@selector(showCarGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchButton];
    
    // aracın alınacağı yer
    [[destinationTableView layer] setCornerRadius:5.0f];
    [[destinationTableView layer] setBorderWidth:0.3f];
    [destinationTableView setClipsToBounds:YES];
    [destinationTableView setDelegate:self];
    [destinationTableView setDataSource:self];
    [destinationTableView setScrollEnabled:NO];
    [destinationTableView setTag:kCheckOutTag];
    
    // aracın teslim edileceği yer
    [[arrivalTableView layer] setCornerRadius:5.0f];
    [[arrivalTableView layer] setBorderWidth:0.3f];
    [arrivalTableView setClipsToBounds:YES];
    [arrivalTableView setDelegate:self];
    [arrivalTableView setDataSource:self];
    [arrivalTableView setScrollEnabled:NO];
    [arrivalTableView setTag:kCheckInTag];
    
    [self.view addSubview:destinationTableView];
    [self.view addSubview:arrivalTableView];
}

- (void)setIphoneLayer
{
    
    [arrivalTableView setRowHeight:50];
    [destinationTableView setRowHeight:50];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,viewFrame.origin.y + (viewFrame.size.height * 0.05),viewFrame.size.width * 0.9, 115) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:
                        CGRectMake (viewFrame.size.width * 0.05 ,
                                    destinationTableView.frame.size.height+destinationTableView.frame.origin.y + (viewFrame.size.height *0.10) ,
                                    viewFrame.size.width * 0.9,
                                    115) style:UITableViewStyleGrouped];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake (viewFrame.size.width * 0.05,
                                                               arrivalTableView.frame.origin.y + arrivalTableView.frame.size.height + viewFrame.size.height * 0.10, arrivalTableView.frame.size.width, 40)];
    
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseOffices:) name:kLoadOfficeServiceCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseCars:) name:kCreateAvailCarServiceCompletedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"dateAndTimeSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [[self myPopoverController] dismissPopoverAnimated:YES];
        [arrivalTableView reloadData];
        [destinationTableView reloadData];
    }];
    
}

- (void)removeNotifcations{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation methods
- (void)navigateToNextVC{
    if ([availableCarGroups count] <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uzgunuz" message:@"Aradiginiz kriterlerde arac bulunamamistir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if ([ApplicationProperties getMainSelection]== advanced_search) {
        [self performSegueWithIdentifier:@"toFilterVCSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toCarGroupVCSegue" sender:self];
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toCarGroupVCSegue"]) {
        CarGroupManagerViewController *carGroupVC = (CarGroupManagerViewController*)[segue destinationViewController];
        [carGroupVC setCarGroups:availableCarGroups];
        [carGroupVC setReservation:reservation];
    }
    if ([segue.identifier isEqualToString:@"toFilterVCSegue"]) {
        CarGroupFilterVC  *filterVC = (CarGroupFilterVC*)[segue destinationViewController];
        [filterVC setCarGroups:availableCarGroups];
        [filterVC setReservation:reservation];
    }
    
    if ([[segue identifier] isEqualToString:@"toDateTimeVCSegue"]) {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(320, self.view.frame.size.width);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
        self.myPopoverController.delegate = self;
        
        CalendarTimeVC *calendarTime = (CalendarTimeVC*)[segue destinationViewController];
        [calendarTime setReservation:reservation];

    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)checkDates:(void(^)(BOOL isOk, NSString *errorMsg))completion
{
    //checkout date
    NSDateComponents *checkOutTimecomponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit|NSMinuteCalendarUnit | NSWeekdayCalendarUnit) fromDate:reservation.checkOutTime];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"Caday=%@",[NSString stringWithFormat:@"%@%i",@"0",[checkOutTimecomponents weekday]]];
    
    NSArray *dayArray = [reservation.checkOutOffice.workingDates filteredArrayUsingPredicate:dayPredicate];
    EXPT_CALISMA_ZAMANIV0 *checkOutWorkingTime = [dayArray objectAtIndex:0];
    //TODO:formatlari duzeltelim yada kaldir direk hata ver!
    if (checkOutWorkingTime.Begti.hours > checkOutTimecomponents.hour || (checkOutWorkingTime.Begti.hours == checkOutTimecomponents.hour && checkOutWorkingTime.Begti.minutes > checkOutTimecomponents.minute)) {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %i:%i - %i:%i arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.mainOfficeName,checkOutWorkingTime.Begti.hours,checkOutWorkingTime.Begti.minutes,checkOutWorkingTime.Endti.hours,checkOutWorkingTime.Endti.minutes]);
        return;
    }
    if (checkOutWorkingTime.Begti.hours > checkOutTimecomponents.hour || (checkOutWorkingTime.Begti.hours == checkOutTimecomponents.hour && checkOutWorkingTime.Begti.minutes > checkOutTimecomponents.minute)) {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %i:%i - %i:%i arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.mainOfficeName,checkOutWorkingTime.Begti.hours,checkOutWorkingTime.Begti.minutes,checkOutWorkingTime.Endti.hours,checkOutWorkingTime.Endti.minutes]);
        return;
    }
    
    completion(YES,@"");
}

@end
