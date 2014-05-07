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
#define kCheckOutTag 0
#define kCheckInTag 1

@interface ClassicSearchVC ()

@end

@implementation ClassicSearchVC
@synthesize popOver;

- (id)initWithFrame:(CGRect)frame;
{
    self = [super init];
    
    viewFrame = frame;
    reservation = [[Reservation alloc] init];
    [self addNotifications];
    return self;
}

#pragma mark - View lifcycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:25];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)showCarGroup:(id)sender
{
    
    //TODO: review and adjust for on nsdate
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
            UIViewController *vc;
            vc = [[CalendarTimeVC alloc] initWithReservation:reservation andTag:tableView.tag];
            [self.navigationController pushViewController:vc animated:YES];
            
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
            UIViewController *vc;
            vc = [[CalendarTimeVC alloc] initWithReservation:reservation andTag:tableView.tag];
            [self.navigationController pushViewController:vc animated:YES];
            
            
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

- (void)getOfficesFromSAP{
    [ApplicationProperties configureOfficeService];
    //prepare object
    OfficeServiceV0 *officeService = [[OfficeServiceV0 alloc] init];
    [officeService setImppBolge:@" "];
    [officeService setImppMerkezSube:@" "];
    [officeService setImppAltSube:@" "];
    //aalpk method override
    [[ZGARENTA_OFIS_SRVRequestHandler uniqueInstance] loadOfficeService:officeService expand:YES];
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
}

- (void)getAvailableCarsFromSAP{
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
        [availableCarService setImppEhdat:[user driversLicenseDate]];
        [availableCarService setImppGbdat:[user birthday]];
    }else{
        [availableCarService setImppKunnr:@" "];
        [availableCarService setImppEhdat:[NSDate date]];
        [availableCarService setImppGbdat:[NSDate date]];
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
    
    [carsImport addObject:dummyCar];
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
    [priceImport addObject:dummyFiyat];
    [availableCarService setET_FIYATSet:priceImport];
    
    
    
    
    [availableCarService setET_ARACLISTESet:carsImport];
    [[ZGARENTA_ARAC_SRVRequestHandler uniqueInstance] createAvailCarService:availableCarService];
    
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
    //trans
    //    if([ApplicationProperties getMainSelection] == location_search){
    //        // reservation.checkOutOffice = [Office getClosestOfficeFromList:offices withCoordinate:lastLocation ];
    //    }
    //    NSString *connectionString = [ApplicationProperties getAvailableCarURLWithCheckOutOffice:reservation.checkOutOffice andCheckInOffice:reservation.checkInOffice andCheckOutDay:reservation.checkOutTime andCheckOutTime:reservation.checkOutTime andCheckInDay:reservation.checkInTime andCheckInTime:reservation.checkInTime];
    //
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:150.0];
    //
    //    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    
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
    NSLog(@"newlocation %@", newLocation);
    lastLocation = newLocation;
    //    = [[Coordinate alloc] initWithCoordinate:newLocation.coordinate title:@"Ben"];
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location error");
}

#pragma mark - util methods

- (void)parseCars:(NSNotification*)notification{
    
    [[LoaderAnimationVC uniqueInstance] stopAnimation];
    if ([notification userInfo][kServerResponseError] != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Zaman aşımı" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alertView show];
        return;
        
    }
    AvailCarServiceV0 *availServiceResponse = (AvailCarServiceV0*)[[notification userInfo] objectForKey:kResponseItem];
    availableCarGroups = [CarGroup getCarGroupsFromServiceResponse:availServiceResponse withOffices:offices];
    
    
    //trans
    //    NSError *err;
    //    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    //
    //    NSDictionary *result = [jsonDict objectForKey:@"d"];
    //    //parsing
    //    NSDictionary *carList = [result objectForKey:@"ET_ARACLISTESet"];
    //    NSDictionary *pictureList = [result objectForKey:@"ET_RESIMLERSet"];
    //
    //    NSDictionary *carListResult = [carList objectForKey:@"results"];
    //    NSDictionary *pictureListResult = [pictureList objectForKey:@"results"];
    //
    //    //car segment yapisi onemli kodlar
    //    //her ofisin bir segment-grup-araba hiyerarsisi var
    //    Car *tempCar;
    
    
    
    if ([ApplicationProperties getMainSelection]== advanced_search) {
        CarGroupFilterVC *filterVC = [[CarGroupFilterVC alloc] initWithReservation:reservation andCarGroup:availableCarGroups];
        [[self navigationController] pushViewController:filterVC animated:YES];
    }else{
        CarGroupManagerViewController *carGroupManagerVC = [[CarGroupManagerViewController alloc] initWithCarGroups:availableCarGroups andReservartion:reservation];
        [[self navigationController] pushViewController:carGroupManagerVC animated:YES];
    }
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

- (void)parseOffices:(NSNotification *)notification{
    [[LoaderAnimationVC uniqueInstance] stopAnimation];
    OfficeServiceV0 *officeServiceResponse = (OfficeServiceV0*)[[notification userInfo] objectForKey:kResponseItem];
    Office *tempOffice;
    for (EXPT_SUBE_BILGILERIV0 *tempOfficeInfo in officeServiceResponse.EXPT_SUBE_BILGILERISet) {
        tempOffice = [[Office alloc] init];
        [tempOffice setMainOfficeCode:tempOfficeInfo.MerkezSube];
        [tempOffice setMainOfficeName:tempOfficeInfo.MerkezSubetx];
        [tempOffice setSubOfficeCode:tempOfficeInfo.AltSube];
        [tempOffice setSubOfficeName:tempOfficeInfo.AltSubetx];
        [tempOffice setSubOfficeType:tempOfficeInfo.AltSubetiptx];
        [tempOffice setSubOfficeTypeCode:tempOfficeInfo.AltSubetip];
        [tempOffice setCityCode:tempOfficeInfo.Sehir];
        [tempOffice setCityName:tempOfficeInfo.Sehirtx];
        [tempOffice setLongitude:tempOfficeInfo.Xkord];
        [tempOffice setLatitude:tempOfficeInfo.Ykord];
        [offices addObject:tempOffice];
    }
    //parsing data
    
}


//checks wheather the checkin date before checkout and correct accordingly
- (void)correctCheckIndate{
    
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
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.5,viewFrame.size.width * 0.9, 115) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:
                        CGRectMake (viewFrame.size.width * 0.05 ,
                                    destinationTableView.frame.size.height * 1.4 ,
                                    viewFrame.size.width * 0.9,
                                    115) style:UITableViewStyleGrouped];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake (viewFrame.size.width * 0.05,
                                                               (destinationTableView.frame.size.height + arrivalTableView.frame.size.height) * 1.3, arrivalTableView.frame.size.width, 40)];
    
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseOffices:) name:kLoadOfficeServiceCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseCars:) name:kCreateAvailCarServiceCompletedNotification object:nil];
    
}

- (void)removeNotifcations{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
