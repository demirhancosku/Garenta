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
#import "WYStoryboardPopoverSegue.h"
#import "SDReservObject.h"
#import "EquipmentVC.h"
#import "ETExpiryObject.h"

#define kCheckOutTag 0
#define kCheckInTag 1

@interface ClassicSearchVC () <WYPopoverControllerDelegate>

@end

@implementation ClassicSearchVC
@synthesize popOver,destinationTableView,arrivalTableView,searchButton,reservation;


#pragma mark - View lifcycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect navigationBarFrame = [[[self navigationController] navigationBar] frame];
    //ysinde navigationBarFrame.size.height vardi viewwillapear super cagirilmamaisti onu cagirinca buna gerek kalmadi
    viewFrame =CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width - navigationBarFrame.size.height );
    
    if (reservation == nil)
        reservation = [[Reservation alloc] init];
    
    [self addNotifications];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ApplicationProperties getTimer] invalidate];
    [ApplicationProperties setTimerObject:0];
    
    [self prepareScreen];
    
    offices = [ApplicationProperties getOffices];
    
    if (offices.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            offices = [Office getOfficesFromSAP];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self setOfficeForChangeDocument];
            [destinationTableView reloadData];
            [arrivalTableView reloadData];
        });
    }
    
    [self setOfficeForChangeDocument];
    [self correctCheckIndate];
}

// REZERVASYON DEĞİŞTİR İLE GELDİĞİMİZDE ALIŞ VE DÖNÜŞ OFİSLERİNİN BÜTÜN BİLGİLERİNİ REZERVASYON OBJESİNE ATIYORUZ
- (void)setOfficeForChangeDocument
{
    NSPredicate *checkOutOfficePredicate = [NSPredicate predicateWithFormat:@"subOfficeCode=%@",[NSString stringWithFormat:@"%@",reservation.checkOutOffice.subOfficeCode]];
    NSArray *checkOutOfficeArray = [offices filteredArrayUsingPredicate:checkOutOfficePredicate];
    
    NSPredicate *checkInOfficePredicate = [NSPredicate predicateWithFormat:@"subOfficeCode=%@",[NSString stringWithFormat:@"%@",reservation.checkInOffice.subOfficeCode]];
    NSArray *checkInOfficeArray = [offices filteredArrayUsingPredicate:checkInOfficePredicate];
    
    if (checkOutOfficeArray.count > 0)
        reservation.checkOutOffice = [checkOutOfficeArray objectAtIndex:0];
    
    if (checkInOfficeArray.count > 0)
        reservation.checkInOffice = [checkInOfficeArray objectAtIndex:0];
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
    switch (indexPath.row)
    {
        case 0:
            // ofis seçimi
            return [self officeSelectTableViewCell:tableView];
            break;
        case 1:
            return [self timeSelectTableViewCell:tableView];
            break;
        default:
            break;
    }
    
    return nil;
}

- (OfficeSelectionCell *)officeSelectTableViewCell:(UITableView *)tableView
{
    OfficeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"officeCell"];
    if (!cell) {
        cell = [OfficeSelectionCell new];
    }
    
    if ([tableView tag] == kCheckOutTag)
    {
        if (reservation.checkOutOffice == nil)
        {
            if([ApplicationProperties getMainSelection] != location_search)
                [[cell officeLabel] setText:@"Şehir / Havalimanı Seçiniz"];
            else
            {
                [[cell officeLabel] setText:@"Size En Yakın Araçlar"];
                [[cell officeLabel] setTextColor:[UIColor lightGrayColor]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        else
        {
            if([ApplicationProperties getMainSelection] == location_search)
            {
                [[cell officeLabel] setTextColor:[UIColor lightGrayColor]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            else
                [[cell officeLabel] setText:reservation.checkOutOffice.subOfficeName];
        }
    }
    else
    {
        if (reservation.checkInOffice == nil)
        {
            [[cell officeLabel] setText:@"Şehir / Havalimanı Seçiniz"];
        }
        else
        {
            [[cell officeLabel] setText:reservation.checkInOffice.subOfficeName];
            [[cell officeLabel] setNumberOfLines:0];
        }
    }
    
    return cell;
}

- (TimeSelectionCell *)timeSelectTableViewCell:(UITableView *)tableView
{
    TimeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
    if (!cell) {
        cell = [TimeSelectionCell new];
    }
    
    if ([tableView tag] == kCheckOutTag)
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
            [[cell timeLabel] setText:@"Tarih / Saat Seçiniz"];
        }
        else
            [[cell timeLabel] setText:[NSString stringWithFormat:@"%@%@%@",stringFromDate,@" - ",stringFromTime]];
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
        
        if (reservation.checkInTime == nil)
        {
            [[cell timeLabel] setText:@"Tarih / Saat Seçiniz"];
            [[cell timeLabel] setTextColor:[UIColor lightGrayColor]];
        }
        else
            [[cell timeLabel] setText:[NSString stringWithFormat:@"%@%@%@",stringFromDate,@" - ",stringFromTime]];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == kCheckOutTag)
    {
        if (indexPath.row == 0 && [ApplicationProperties getMainSelection] != location_search)
        {
            OfficeListVC *office = [[OfficeListVC alloc] initWithReservation:reservation andTag:tableView.tag andOfficeList:offices ];
            [[self navigationController] pushViewController:office animated:YES];
            
        }
        if(indexPath.row == 1 )
        {
            selectedTag = tableView.tag;
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
            selectedTag = tableView.tag;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"toDateTimeVCSegue" sender:cell];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (tableView == destinationTableView) {
        sectionName = @"Alış";
    }
    else
    {
        sectionName = @"Dönüş";
    }
    
    return sectionName;
}

- (void)tableViewDidReturn:(id)sender
{
    [popOver dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [arrivalTableView reloadData];
    [destinationTableView reloadData];
}

#pragma mark - gateway connection delegates

- (IBAction)showCarGroup:(id)sender
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
    
    UIAlertView *errorAlertView;
    if ([ApplicationProperties getMainSelection] != location_search && reservation.checkOutOffice == nil) {
        errorAlertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Lütfen alış şubesini seçiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [errorAlertView show];
        return;
    }
    if (reservation.checkInOffice == nil) {
        errorAlertView = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Lütfen dönüş şubesini seçiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [errorAlertView show];
        return;
    }
    
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
    
    [self checkDates:^(BOOL isOK,NSString *errorMsg) {
        
        if (isOK) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                [self getAvailableCarsFromSAP];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    if (availableCarGroups.count > 0)
                    {
                        [self startTimer];
                        [self navigateToNextVC];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Seçmiş olduğunuz şube ve saatlerde uygun araç bulunamadı" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            });
        }
        else {
            UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:errorMsg delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)startTimer
{
    [ApplicationProperties setTimerObject:0];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ApplicationProperties setTimer:[NSTimer scheduledTimerWithTimeInterval:1
                                                                     target:app
                                                                   selector:@selector(updateTimerObject:)
                                                                   userInfo:nil
                                                                    repeats:YES]];
    
    NSLog(@"timer start");
}

- (void)getAvailableCarsFromSAP {
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_GET_AVAIL_ARAC"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        if ([ApplicationProperties getMainSelection] != location_search) {
            if (reservation.checkOutOffice.isPseudoOffice) {
                [handler addImportParameter:@"IMPP_SEHIR" andValue:reservation.checkOutOffice.cityCode];
            }
            else {
                [handler addImportParameter:@"IMPP_MSUBE" andValue:reservation.checkOutOffice.subOfficeCode];
            }
        }
        else {
            Office *closestOffice = [self prepareOfficeImport];
            
            if (closestOffice != nil) {
                [handler addImportParameter:@"IMPP_MSUBE" andValue:closestOffice.subOfficeCode];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Bulunduğunuz noktaya yakın şube bulunamadı. Lütfen lokasyon servislerinizin çalıştığından emin olup, tekrar deneyiniz" delegate:nil cancelButtonTitle:@"tamam" otherButtonTitles:nil];
                    [alert show];
                    return;
                });
            }
        }
        
        [handler addImportParameter:@"IMPP_HDFSUBE" andValue:reservation.checkInOffice.subOfficeCode];
        
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_LAND" andValue:@"TR"];
        [handler addImportParameter:@"IMPP_WAERS" andValue:@"TRY"];
        [handler addImportParameter:@"IMPP_KDGRP" andValue:@"40"];
        
        // Fiyat Kodu
        NSString *priceCode = @"";
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            priceCode = [[ApplicationProperties getUser] priceCode];
        }
        
        [handler addImportParameter:@"IMPP_FIKOD" andValue:priceCode];
        
        User *user =[ApplicationProperties getUser];
        if ([user isLoggedIn]) {
            [handler addImportParameter:@"IMPP_KUNNR" andValue:[user kunnr]];
            
            if ([user driversLicenseDate] != nil) {
                [handler addImportParameter:@"IMPP_EHDAT" andValue:[dateFormatter stringFromDate:[user driversLicenseDate]]];
            }
            
            if ([user birthday] != nil) {
                [handler addImportParameter:@"IMPP_GBDAT" andValue:[dateFormatter stringFromDate:[user birthday]]];
            }
        }
        
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:reservation.checkInTime]];
        
        [handler addTableForReturn:@"ET_ARACLISTE"];
        [handler addTableForReturn:@"ET_RESERV"];
        [handler addTableForReturn:@"ET_KAMPANYA"];
        [handler addTableForReturn:@"ET_INDIRIMLIST"];
        [handler addTableForReturn:@"ET_FIYAT"];
        [handler addTableForReturn:@"ET_EXPIRY"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *export = [resultDict objectForKey:@"EXPORT"];
            
            NSString *subrc = [export valueForKey:@"EXPP_SUBRC"];
            
            if ([subrc isEqualToString:@"0"]) {
                
                NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
                
                availableCarGroups = [CarGroup getCarGroupsFromServiceResponse:tables withOffices:offices];
                
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
                
                reservation.etReserv = sdReservArray;
                
                NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
                
                NSMutableArray *etExpiryArray = [NSMutableArray new];
                
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
                    [etExpiryArray addObject:tempObject];
                }
                
                reservation.etExpiry = etExpiryArray;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


- (Office *) prepareOfficeImport {
    
    if ([ApplicationProperties getMainSelection] == location_search) {
        
        NSMutableArray *closestoffices = [Office closestFirst:3 fromOffices:[ApplicationProperties getOffices] toMyLocation:lastLocation];
        for (Office *tempOffice in closestoffices) {
            return tempOffice;
        }
    }
    
    return nil;
}

#pragma mark - Location Delegation Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (reservation.checkOutOffice == nil) {
        
        lastLocation = locations.lastObject;
        
        // en yakın ofisi bulup ekrana yazıyo
        if ([ApplicationProperties getMainSelection] == location_search)
        {
            reservation.checkOutOffice = [self prepareOfficeImport];
            
            [destinationTableView reloadData];
            [locationManager stopUpdatingLocation];
            locationManager = nil;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    lastLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
}

#pragma mark - util methods

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
    NSComparisonResult result = [reservation.checkOutTime compare:reservation.checkInTime];
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        //        reservation.checkInTime = [reservation.checkOutTime copy];
        
        NSDate *checkInDate = [reservation.checkOutTime copy];
        
        //once 15 dk ekliyoruz
        NSTimeInterval aTimeInterval =  24 * 60 * 60;
        checkInDate = [checkInDate dateByAddingTimeInterval:aTimeInterval];
        //sonra dakikaları 0lıyoruz.
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                            fromDate:checkInDate];
        NSInteger difference = components.minute % 15;
        reservation.checkInTime = [checkInDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    }
}

- (void)prepareScreen
{
    [[searchButton layer] setCornerRadius:5.0f];
    
    // aracın alınacağı yer
    [[destinationTableView layer] setCornerRadius:5.0f];
    [[destinationTableView layer] setBorderWidth:0.3f];
    [destinationTableView setClipsToBounds:YES];
    [destinationTableView setScrollEnabled:NO];
    [destinationTableView setTag:kCheckOutTag];
    
    // aracın teslim edileceği yer
    [[arrivalTableView layer] setCornerRadius:5.0f];
    [[arrivalTableView layer] setBorderWidth:0.3f];
    [arrivalTableView setClipsToBounds:YES];
    [arrivalTableView setScrollEnabled:NO];
    [arrivalTableView setTag:kCheckInTag];
    
    [arrivalTableView reloadData];
    [destinationTableView reloadData];
}

- (void)addNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"dateAndTimeSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [[self myPopoverController] dismissPopoverAnimated:YES];
        [self correctCheckIndate];
        [arrivalTableView reloadData];
        [destinationTableView reloadData];
        [self removeNotifcations];
    }];
}

- (void)removeNotifcations{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation methods
- (void)navigateToNextVC
{
    if ([availableCarGroups count] <= 0)
    {
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
        [calendarTime setTag:selectedTag];
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)checkDates:(void(^)(BOOL isOk, NSString *errorMsg))completion
{
    // Ata 02.01.2015 En yakın şubede kontrolden kaçıyor
    
    
    // TESLİM ALACAĞI ŞUBENİN KONTROLLERİ
    // teslim alacağı günün haftanın kaçıncı günü olduğunu bulur
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:2]; // Sunday == 1, Saturday == 7
    NSUInteger checkOutWeekday = [gregorian ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:reservation.checkOutTime];
    
    
    //TESLİM ALACAĞI ŞUBENİN TATİL GÜNLERİNİ KONTROL EDER
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *checkOutHolidayDate = [formatter stringFromDate:reservation.checkOutTime];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSString *checkOutTimeStr = [timeFormatter stringFromDate:reservation.checkOutTime];
    NSDate   *checkOutTime       = [timeFormatter dateFromString:checkOutTimeStr];
    
    NSPredicate *holidayPredicate = [NSPredicate predicateWithFormat:@"holidayDate=%@",[NSString stringWithFormat:@"%@",checkOutHolidayDate]];
    NSArray *checkOutHolidayArray = [reservation.checkOutOffice.holidayDates filteredArrayUsingPredicate:holidayPredicate];
    
    if ([checkOutHolidayArray count] > 0)
    {
        for (OfficeHolidayTime *temp in checkOutHolidayArray)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *holidayDate = [formatter dateFromString:temp.holidayDate];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"dd.MM.yyyy"];
            NSString *holidayDateString = [formatter2 stringFromDate:holidayDate];
            
            NSDate *holidayStartTime = [timeFormatter dateFromString:temp.startTime];
            NSDate *holidayEndTime   = [timeFormatter dateFromString:temp.endingHour];
            
            NSComparisonResult checkOutresult = [holidayStartTime compare:checkOutTime];
            if (checkOutresult == NSOrderedDescending)
            {
                NSComparisonResult checkOutresult2 = [holidayEndTime compare:checkOutTime];
                if (checkOutresult2 == NSOrderedAscending)
                {
                    completion(NO,[NSString stringWithFormat:@"%@ şubesi %@, %@ - %@ aralığında tatil sebebiyle kapalıdır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,holidayDateString,temp.startTime,temp.endingHour]);
                    
                    return;
                }
            }
            else
            {
                completion(NO,[NSString stringWithFormat:@"%@ şubesi %@, %@ - %@ aralığında tatil sebebiyle kapalıdır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,holidayDateString,temp.startTime,temp.endingHour]);
                
                return;
            }
        }
    }
    
    
    //TESLİM EDECEĞİ ŞUBENİN TATİL GÜNLERİNİ KONTROL EDER
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *checkInHolidayDate = [formatter2 stringFromDate:reservation.checkInTime];
    
    NSDateFormatter *timeFormatter2 = [[NSDateFormatter alloc] init];
    [timeFormatter2 setDateFormat:@"HH:mm:ss"];
    NSString *checkInTimeStr = [timeFormatter2 stringFromDate:reservation.checkInTime];
    NSDate   *checkInTime       = [timeFormatter2 dateFromString:checkInTimeStr];
    
    NSPredicate *holidayPredicate2 = [NSPredicate predicateWithFormat:@"holidayDate=%@",[NSString stringWithFormat:@"%@",checkInHolidayDate]];
    NSArray *checkInHolidayArray = [reservation.checkInOffice.holidayDates filteredArrayUsingPredicate:holidayPredicate2];
    
    if ([checkInHolidayArray count] > 0)
    {
        for (OfficeHolidayTime *temp in checkInHolidayArray)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *holidayDate = [formatter dateFromString:temp.holidayDate];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"dd.MM.yyyy"];
            NSString *holidayDateString = [formatter2 stringFromDate:holidayDate];
            
            NSDate *holidayStartTime = [timeFormatter dateFromString:temp.startTime];
            NSDate *holidayEndTime   = [timeFormatter dateFromString:temp.endingHour];
            
            NSComparisonResult checkOutresult = [holidayStartTime compare:checkInTime];
            if (checkOutresult == NSOrderedDescending)
            {
                NSComparisonResult checkOutresult2 = [holidayEndTime compare:checkInTime];
                if (checkOutresult2 == NSOrderedAscending)
                {
                    completion(NO,[NSString stringWithFormat:@"%@ şubesi %@, %@ - %@ aralığında tatil sebebiyle kapalıdır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,holidayDateString,temp.startTime,temp.endingHour]);
                    
                    return;
                }
            }
            else
            {
                completion(NO,[NSString stringWithFormat:@"%@ şubesi %@, %@ - %@ aralığında tatil sebebiyle kapalıdır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,holidayDateString,temp.startTime,temp.endingHour]);
                
                return;
            }
            
        }
    }
    
    // teslim alacağı şubenin çalıştığı günler seçilen teslim tarihi içersindemi değilmi kontrolü
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"weekDayCode=%@",[NSString stringWithFormat:@"%@%i",@"0",checkOutWeekday]];
    NSArray *checkOutDayArray = [reservation.checkOutOffice.workingDates filteredArrayUsingPredicate:dayPredicate];
    
    if ([checkOutDayArray count] == 0 && !reservation.checkOutOffice.isPseudoOffice && [ApplicationProperties getMainSelection] != location_search)
    {
        completion(NO,[NSString stringWithFormat:@"%@ seçmiş olduğunuz gün çalışmamaktadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName]);
        
        return;
    }
    
    // İADE EDECEĞİ ŞUBENİN KONTROLLERİ
    NSUInteger checkInWeekday = [gregorian ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:reservation.checkInTime];
    
    // teslim alacağı şubenin çalıştığı günler seçilen iade tarihi içersindemi değilmi kontrolü
    NSPredicate *dayPredicate2 = [NSPredicate predicateWithFormat:@"weekDayCode=%@",[NSString stringWithFormat:@"%@%i",@"0",checkInWeekday]];
    
    NSArray *checkInDayArray = [reservation.checkInOffice.workingDates filteredArrayUsingPredicate:dayPredicate2];
    
    if ([checkInDayArray count] == 0 && !reservation.checkInOffice.isPseudoOffice)
    {
        completion(NO,[NSString stringWithFormat:@"%@ seçmiş olduğunuz gün çalışmamaktadır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName]);
        
        return;
    }
    
    OfficeWorkingTime *checkOutWorkingTime = [checkOutDayArray objectAtIndex:0];
    OfficeWorkingTime *checkInWorkingTime  = [checkInDayArray objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    // TESLİM ALACAĞI OFİSİN AÇILIŞ SAATİ
    NSDate *checkOutStartTime = [dateFormatter dateFromString:checkOutWorkingTime.startTime];
    
    // TESLİM ALACAĞI OFİSİN KAPANIŞ SAATİ
    NSDate *checkOutEndTime = [dateFormatter dateFromString:checkOutWorkingTime.endingHour];
    
    NSString *str = [dateFormatter stringFromDate:reservation.checkOutTime];
    NSDate *reservationCheckOutTime = [dateFormatter dateFromString:str];
    
    
    // TESLİM EDECEĞİ OFİSİN AÇILIŞ SAATİ
    NSDate *checkInStartTime = [dateFormatter dateFromString:checkInWorkingTime.startTime];
    
    // TESLİM EDECEĞİ OFİSİN KAPANIŞ SAATİ
    NSDate *checkInEndTime = [dateFormatter dateFromString:checkInWorkingTime.endingHour];
    
    NSString *str2 = [dateFormatter stringFromDate:reservation.checkInTime];
    NSDate *reservationCheckInTime = [dateFormatter dateFromString:str2];
    
    
    
    NSDate *checkOutMinTime = [NSDate date];
    //once 135 dk ekliyoruz
    NSTimeInterval aTimeInterval = 135 * 60; //135 dk
    checkOutMinTime = [checkOutMinTime dateByAddingTimeInterval:aTimeInterval];
    
    //sonra dakikaları bir ger dilime
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:checkOutMinTime];
    
    NSInteger difference = components.minute % 15;
    checkOutMinTime = [checkOutMinTime dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *minTime = [dateFormatter2 stringFromDate:checkOutMinTime];
    checkOutMinTime = [dateFormatter2 dateFromString:minTime];
    
    NSComparisonResult checkOutMinTimeResult = [checkOutMinTime compare:reservation.checkOutTime];
    if (checkOutMinTimeResult == NSOrderedDescending)
    {
        completion(NO,@"Rezervasyonunuzu güncel saatten en az 2 saat sonrasına yapabilirsiniz.");
        return;
    }
    
    // SEÇİLEN SAAT TESLİM ALACAĞI ŞUBENİN ÇALIŞMA SAATLERİ ARASINDAMI KONTROLÜ
    NSComparisonResult checkOutresult = [checkOutStartTime compare:reservationCheckOutTime];
    if (checkOutresult == NSOrderedAscending)
    {
        NSComparisonResult checkOutresult2 = [checkOutEndTime compare:reservationCheckOutTime];
        if (checkOutresult2 == NSOrderedAscending)
        {
            completion(NO,[NSString stringWithFormat:@"%@ şubesinin çalışma saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,checkOutWorkingTime.startTime,checkOutWorkingTime.endingHour]);
            
            return;
        }
    }
    else if (checkOutresult == NSOrderedDescending)
    {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin çalışma saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,checkOutWorkingTime.startTime,checkOutWorkingTime.endingHour]);
        
        return;
    }
    
    // SEÇİLEN SAAT IADE EDECEĞİ ŞUBENİN ÇALIŞMA SAATLERİ ARASINDAMI KONTROLÜ
    NSComparisonResult checkInResult = [checkInStartTime compare:reservationCheckInTime];
    if(checkInResult == NSOrderedAscending)
    {
        NSComparisonResult checkInResult2 = [checkInEndTime compare:reservationCheckInTime];
        if (checkInResult2 == NSOrderedAscending)
        {
            completion(NO,[NSString stringWithFormat:@"%@ şubesinin çalışma saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,checkInWorkingTime.startTime,checkInWorkingTime.endingHour]);
            
            return;
        }
    }
    else if (checkInResult == NSOrderedDescending)
    {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin çalışma saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,checkInWorkingTime.startTime,checkInWorkingTime.endingHour]);
        
        return;
    }
    
    completion(YES,@"");
}

@end
