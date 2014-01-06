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
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ekranki component'ların ayarlaması yapılıyor

    
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:25];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [locationManager startUpdatingLocation];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
    //only once singleton koydum devam etsin burdan
    officeWorkingSchedule = [ApplicationProperties getOffices];
    if (officeWorkingSchedule.count ==0) {
                [self connectToGateway];
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                                    fromDate: [reservation checkInDay]];
    NSDateComponents *checkOutDateComp = [calendar components:dateComps
                                                    fromDate: [reservation checkOutDay]];
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
    
        
        
        [self getAvailCars];
        

}
- (void)getAvailCars{
    
    if([ApplicationProperties getMainSelection] == location_search){
        reservation.checkOutOffice = [Office getClosestOfficeFromList:officeWorkingSchedule withCoordinate:lastLocation ];
    }
    NSString *connectionString = [ApplicationProperties getAvailableCarURLWithCheckOutOffice:reservation.checkOutOffice andCheckInOffice:reservation.checkInOffice andCheckOutDay:reservation.checkOutDay andCheckOutTime:reservation.checkOutTime andCheckInDay:reservation.checkInDay andCheckInTime:reservation.checkInTime];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:150.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    loaderVC = [[LoaderAnimationVC alloc] init];
    [loaderVC playAnimation:self.view];
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
            NSString *stringFromDate = [formatter stringFromDate:[reservation checkOutDay]];
            NSString *stringFromTime = [formatter2 stringFromDate:[reservation checkOutTime]];
            
            if (reservation.checkOutDay == nil && reservation.checkOutTime == nil)
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
            NSString *stringFromDate = [formatter stringFromDate:[reservation checkInDay]];
            NSString *stringFromTime = [formatter2 stringFromDate:[reservation checkInTime]];
            
            if (reservation.checkOutDay == nil && reservation.checkOutTime == nil)
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
            
            OfficeListVC *office = [[OfficeListVC alloc] initWithReservation:reservation andTag:tableView.tag andOfficeList:officeWorkingSchedule ];
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
            
            OfficeListVC *office = [[OfficeListVC alloc] initWithReservation:reservation andTag:tableView.tag andOfficeList:officeWorkingSchedule ];
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

- (void)connectToGateway
{
    NSString *connectionString = @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_TEST_SRV/available_offices(ImppAltSube='',ImppMerkezSube='')?$expand=EXPT_SUBE_BILGILERISet,EXPT_CALISMA_ZAMANISet,EXPT_TATIL_ZAMANISet&$format=json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    loaderVC = [[LoaderAnimationVC alloc] init];
    [loaderVC playAnimation:self.view];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"gw_admin" password:@"1qa2ws3ed"persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else
    {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err != nil) {
        if (bigData == nil) {
            bigData = [NSMutableData dataWithData:data];
            return;
        }else{
            [bigData appendData:data];
            err= nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:bigData options:NSJSONReadingMutableContainers error:&err];
            if (err !=nil) {
                return;
            }
            data = [NSData dataWithData:bigData];
        }
    }
    bigData =nil;//aalpk bu7rda<
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    
    NSDictionary *officeListDict = [result objectForKey:@"EXPT_SUBE_BILGILERISet"];
    NSDictionary *timeDict = [result objectForKey:@"EXPT_CALISMA_ZAMANISet"];
    
    if ([result objectForKey:@"EXPT_SUBE_BILGILERISet"] != nil) {
        [self parseOffices:data];
    }else{
        [self parseCars:data];
    }
        [loaderVC stopAnimation];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [loaderVC stopAnimation];
    NSLog(@"1");
}
#pragma mark - Location Delegation Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"newlocation %@", newLocation);
    lastLocation = [[Coordinate alloc] initWithCoordinate:newLocation.coordinate title:@"Ben"];
    
    //tempPoint kullanılarak en yakın ofis bulunacak
    //cok bilion sen-alp
    
}

- (void)parseCars:(NSData*)data{

    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    //parsing
    NSDictionary *carList = [result objectForKey:@"ET_ARACLISTESet"];
    NSDictionary *pictureList = [result objectForKey:@"ET_RESIMLERSet"];
    
    NSDictionary *carListResult = [carList objectForKey:@"results"];
    NSDictionary *pictureListResult = [pictureList objectForKey:@"results"];
    
    //car segment yapisi onemli kodlar
    //her ofisin bir segment-grup-araba hiyerarsisi var
    Car *tempCar;

    CarGroup *tempCarGroup;
    Office *tempOffice;
    availableCarGroups = [[NSMutableArray alloc] init];
    for (NSDictionary *tempCarResult in carListResult){
        
        tempCar = [[Car alloc] init];
        [tempCar setMaterialCode:[tempCarResult objectForKey:@"Matnr"]];
        [tempCar setMaterialName:[tempCarResult objectForKey:@"Maltx"]];
        [tempCar setBrandId:[tempCarResult objectForKey:@"MarkaId"]];
        [tempCar setBrandName:[tempCarResult objectForKey:@"Marka"]];
        [tempCar setModelId:[tempCarResult objectForKey:@"ModelId"]];
        [tempCar setModelName:[tempCarResult objectForKey:@"Model"]];
        [tempCar setModelYear:[tempCarResult objectForKey:@"ModelYili"]];
        [tempCar setPayNowPrice:[tempCarResult objectForKey:@"SimdiOdeFiyat"]];
        [tempCar setPayLaterPrice:[tempCarResult objectForKey:@"SonraOdeFiyat"]];
        [tempCar setEarningPrice:[tempCarResult objectForKey:@"Kazanc"]];
        [tempCar setImage:[self getImageFromJSONResults:pictureListResult withPath:[tempCarResult objectForKey:@"Zresim315"]]];
        //aalpk burasi duzelcek importu aliorz export boscunku
        [tempCar setCurrency:[tempCarResult objectForKey:@"ImppWaers"]];
        [tempCar setOffice:[Office getOfficeFrom:officeWorkingSchedule withCode:[tempCarResult objectForKey:@"Msube"]]];
        //eger o grup yoksa daha
        tempCarGroup = [CarGroup getGroupFromList:availableCarGroups WithCode:[tempCarResult objectForKey:@"Grpkod"]];
        if ( tempCarGroup== nil) {
            //grup yarat
            //TODO: aalpk devam et gruba
            tempCarGroup = [[CarGroup alloc] init];
            tempCarGroup.cars = [[NSMutableArray alloc] init];
            [tempCarGroup setGroupCode:[tempCarResult objectForKey:@"Grpkod"]];
            [tempCarGroup setGroupName:[tempCarResult objectForKey:@"Grpkodtx"]];
            [tempCarGroup setTransmissonId:[tempCarResult objectForKey:@"SanzimanTipiId"]];
            [tempCarGroup setTransmissonName:[tempCarResult objectForKey:@"SanzimanTipi"]];
            [tempCarGroup setFuelId:[tempCarResult objectForKey:@"YakitTipiId"]];
            [tempCarGroup setFuelName:[tempCarResult objectForKey:@"YakitTipi"]];
            [tempCarGroup setBodyId:[tempCarResult objectForKey:@"KasaTipiId"]];
            [tempCarGroup setBodyName:[tempCarResult objectForKey:@"KasaTipi"]];
            [tempCarGroup setSegment:[tempCarResult objectForKey:@"Segment"]];
            [tempCarGroup setSegmentName:[tempCarResult objectForKey:@"Segmenttx"]];
            [availableCarGroups addObject:tempCarGroup];
        }
        if ([[tempCarResult objectForKey:@"Vitrinres"] isEqualToString:@"X"]) {
            [tempCarGroup setSampleCar:tempCar];
        }
        [tempCarGroup.cars addObject:tempCar];
    }
    
    if(availableCarGroups.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Belirttiğiniz tarih/şube aralığında uygun aracımız bulunmamaktadır." delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
        return;
    }
    //pushing
    //aalpk: differenceee
    if ([ApplicationProperties getMainSelection]== advanced_search) {
        CarGroupFilterVC *filterVC = [[CarGroupFilterVC alloc] initWithReservation:reservation andCarGroup:availableCarGroups];
        [[self navigationController] pushViewController:filterVC animated:YES];
    }else{
    CarGroupManagerViewController *car = [[CarGroupManagerViewController alloc] initWithCarGroups:availableCarGroups andReservartion:reservation];
    [[self navigationController] pushViewController:car animated:YES];
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

- (void)parseOffices:(NSData*)data{
    //parsing data
    
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    
    NSDictionary *officeListDict = [result objectForKey:@"EXPT_SUBE_BILGILERISet"];
    NSDictionary *timeDict = [result objectForKey:@"EXPT_CALISMA_ZAMANISet"];
    NSDictionary *holidayDict = [result objectForKey:@"EXPT_TATIL_ZAMANISet"];
    
    
    
    NSDictionary *timeListResult = [timeDict objectForKey:@"results"];
    NSDictionary *officeListResult = [officeListDict objectForKey:@"results"];
    NSDictionary *holidayListResult = [holidayDict objectForKey:@"results"];
    
    for (NSDictionary *temp in officeListResult)
    {
        Office *tempOffice = [[Office alloc] init];
        tempOffice.mainOfficeName = [temp objectForKey:@"MerkezSubetx"];
        tempOffice.mainOfficeCode = [temp objectForKey:@"MerkezSube"];
        
        tempOffice.subOfficeName = [temp objectForKey:@"AltSubetx"];
        tempOffice.subOfficeCode = [temp objectForKey:@"AltSube"];
        tempOffice.subOfficeType = [temp objectForKey:@"AltSubetiptx"];
        tempOffice.subOfficeTypeCode = [temp objectForKey:@"AltSubetip"];
        
        tempOffice.cityCode = [temp objectForKey:@"Sehir"];
        tempOffice.cityName = [temp objectForKey:@"Sehirtx"];
        tempOffice.longitude = [temp objectForKey:@"Xkord"];
        tempOffice.latitude = [temp objectForKey:@"Ykord"];
        
        tempOffice.address = [temp objectForKey:@"Adres"];
        tempOffice.fax = [temp objectForKey:@"Fax"];
        tempOffice.tel = [temp objectForKey:@"Tel"];
        
        tempOffice.workingHours = [[NSMutableArray alloc] init];
        
        for (NSDictionary *timeTemp in timeListResult)
        {
            if ([[timeTemp objectForKey:@"MerkezSube"] isEqualToString:tempOffice.mainOfficeCode])
            {
                OfficeWorkingTime *tempSchedule = [[OfficeWorkingTime alloc] init];
                tempSchedule.startTime = [timeTemp objectForKey:@"Begti"];
                tempSchedule.endingHour   = [timeTemp objectForKey:@"Endti"];
                tempSchedule.mainOffice   = [timeTemp objectForKey:@"MerkezSube"];
                tempSchedule.subOffice    = [timeTemp objectForKey:@"AltSube"];
                tempSchedule.weekDayCode      = [timeTemp objectForKey:@"Caday"];
                //                tempSchedule.weekDayCode      = [timeTemp objectForKey:@"Caday"]; txti al
                [[tempOffice workingHours] addObject:tempSchedule];
            }
        }
        
        tempOffice.holidayDates = [[NSMutableArray alloc] init];
        
        for (NSDictionary *timeTemp in holidayListResult)
        {
            if ([[timeTemp objectForKey:@"MerkezSube"] isEqualToString:tempOffice.mainOfficeCode])
            {
                OfficeHolidayTime *tempHolidaySchedule = [[OfficeHolidayTime alloc] init];
                tempHolidaySchedule.startTime = [timeTemp objectForKey:@"Begti"];
                tempHolidaySchedule.endingHour   = [timeTemp objectForKey:@"Endti"];
                tempHolidaySchedule.holidayDate  = [timeTemp objectForKey:@"Begda"];
                tempHolidaySchedule.mainOffice   = [timeTemp objectForKey:@"MerkezSube"];
                tempHolidaySchedule.subOffice    = [timeTemp objectForKey:@"AltSube"];
                [[tempOffice holidayDates] addObject:tempHolidaySchedule];
            }
        }
        
        [officeWorkingSchedule addObject:tempOffice];
    }
  
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location error");
}


@end
