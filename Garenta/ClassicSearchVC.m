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
            {
                if([ApplicationProperties getMainSelection] != location_search)
                {
                    [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
                }
                else{
                    [[cell textLabel] setText:@"Size En Yakın Araçlar"];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
            {
                [[cell textLabel] setText:reservation.checkOutOffice.subOfficeName];
                [[cell textLabel] setNumberOfLines:0];
            }
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
            {
                [[cell textLabel] setText:reservation.checkInOffice.subOfficeName];
                [[cell textLabel] setNumberOfLines:0];
            }
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
                        OfficeHolidayTime *tempTime = [[OfficeHolidayTime alloc] init];
                        tempTime.startTime = [tempHolidayDict valueForKey:@"BEGTI"];
                        tempTime.endingHour = [tempHolidayDict valueForKey:@"ENDTI"];
                        tempTime.holidayDate = [tempHolidayDict valueForKey:@"BEGDA"];
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
    
    [self checkDates:^(BOOL isOK,NSString *errorMsg) {
        
        if (isOK) {
            [self getAvailableCarsFromSAP];
        }
        else {
            UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:errorMsg delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}

- (void)getAvailableCarsFromSAP {
    
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
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_GET_AVAIL_ARAC"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"hh:mm:ss"];
        
        if ([ApplicationProperties getMainSelection] != location_search) {
            if (reservation.checkOutOffice.isPseudoOffice) {
                [handler addImportParameter:@"IMPP_SEHIR" andValue:reservation.checkInOffice.cityCode];
            }
            else {
                [handler addImportParameter:@"IMPP_MSUBE" andValue:reservation.checkInOffice.subOfficeCode];
            }
        }
        else {
            Office *closestOffice = [self prepareOfficeImport];
            
            if (closestOffice != nil) {
                [handler addImportParameter:@"IMPP_MSUBE" andValue:reservation.checkInOffice.subOfficeCode];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Bulunduğunuz noktaya yakın şube bulunamadı. Lütfen lokasyon servislerinizin çalıştığından emin olup, tekrar deneyiniz" delegate:nil cancelButtonTitle:@"tamam" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        
        [handler addImportParameter:@"IMPP_HDFSUBE" andValue:reservation.checkInOffice.subOfficeCode];
        
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_LAND" andValue:@"TR"];
        [handler addImportParameter:@"IMPP_WAERS" andValue:@"TRY"];
        [handler addImportParameter:@"IMPP_KDGRP" andValue:@"40"];
        
        User *user =[ApplicationProperties getUser];
        if ([ user isLoggedIn]) {
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
                
                // TODO : buna mutlaka bakmak lazım hiç anlamadım
                //                [reservation setEtReserv:availServiceResponse.ET_RESERVSet];
                [self navigateToNextVC];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
    }
}


- (Office *) prepareOfficeImport {
    
    if ([ApplicationProperties getMainSelection] == location_search) {
        
        NSMutableArray *closestoffices = [ApplicationProperties closestFirst:1 fromOffices:[ApplicationProperties getOffices] toMyLocation:lastLocation];
        
        for (Office *tempOffice in closestoffices) {
            return tempOffice;
        }
    }
    
    return nil;
}

#pragma mark - Location Delegation Methods

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
    if ([reservation.checkOutTime compare:reservation.checkInTime] == NSOrderedDescending) {
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"dateAndTimeSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [[self myPopoverController] dismissPopoverAnimated:YES];
        [self correctCheckIndate];
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
        [calendarTime setTag:selectedTag];
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)checkDates:(void(^)(BOOL isOk, NSString *errorMsg))completion
{
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
    
    if ([checkOutDayArray count] == 0 && !reservation.checkOutOffice.isPseudoOffice)
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
            completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,checkOutWorkingTime.startTime,checkOutWorkingTime.endingHour]);
            
            return;
        }
    }
    else if (checkOutresult == NSOrderedDescending)
    {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkOutOffice.subOfficeName,checkOutWorkingTime.startTime,checkOutWorkingTime.endingHour]);
        
        return;
    }
    
    // SEÇİLEN SAAT IADE EDECEĞİ ŞUBENİN ÇALIŞMA SAATLERİ ARASINDAMI KONTROLÜ
    NSComparisonResult checkInResult = [checkInStartTime compare:reservationCheckInTime];
    if(checkInResult == NSOrderedAscending)
    {
        NSComparisonResult checkInResult2 = [checkInEndTime compare:reservationCheckInTime];
        if (checkInResult2 == NSOrderedAscending)
        {
            completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,checkInWorkingTime.startTime,checkInWorkingTime.endingHour]);
            
            return;
        }
    }
    else if (checkInResult == NSOrderedDescending)
    {
        completion(NO,[NSString stringWithFormat:@"%@ şubesinin açılış saatleri %@ - %@ arasındadır. Lütfen tekrar kontrol ediniz.",reservation.checkInOffice.subOfficeName,checkInWorkingTime.startTime,checkInWorkingTime.endingHour]);
        
        return;
    }
    
    completion(YES,@"");
}

@end
