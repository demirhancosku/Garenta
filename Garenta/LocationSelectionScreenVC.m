//
//  MainVC.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LocationSelectionScreenVC.h"

@interface LocationSelectionScreenVC ()

@end

@implementation LocationSelectionScreenVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
//    self = [super init];
    
    viewFrame = frame;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ekranki component'ların ayarlaması yapılıyor
    officeWorkingSchedule = [[NSMutableArray alloc] init];
    [self connectToGateway];
//    [self prepareScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareScreen
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self setIpadLayer];
    }
    else
    {
        [self setIphoneLayer];
    }
    
    
    //    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //    NSDate * testDate = [NSDate date];
    //
    //    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:testDate];
    //
    //    NSInteger weekday = [weekdayComponents weekday];
    //    // weekday 1 = Sunday for Gregorian calendar
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    
    [searchButton setTitle:@"Teklifleri Göster" forState:UIControlStateNormal];
    [[searchButton layer] setCornerRadius:5.0f];
    [searchButton setBackgroundColor:[ApplicationProperties getOrange]];
    [searchButton setTintColor:[ApplicationProperties getWhite]];
    
    [self.view addSubview:searchButton];
    
    // aracın alınacağı yer
    [[destinationTableView layer] setCornerRadius:5.0f];
    [[destinationTableView layer] setBorderWidth:0.3f];
    [destinationTableView setClipsToBounds:YES];
    [destinationTableView setRowHeight:45];
    [destinationTableView setDelegate:self];
    [destinationTableView setDataSource:self];
    
    
    // aracın teslim edileceği yer
    [[arrivalTableView layer] setCornerRadius:5.0f];
    [[arrivalTableView layer] setBorderWidth:0.3f];
    [arrivalTableView setClipsToBounds:YES];
    [arrivalTableView setRowHeight:45];
    [arrivalTableView setDelegate:self];
    [arrivalTableView setDataSource:self];
    
    [self.view addSubview:destinationTableView];
    [self.view addSubview:arrivalTableView];
}

- (void)setIpadLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.1,viewFrame.size.width * 0.9,viewFrame.size.height * 0.6) style:UITableViewStyleGrouped];
}

- (void)setIphoneLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.4,viewFrame.size.width * 0.9, 150) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,destinationTableView.frame.size.height * 1.3 ,viewFrame.size.width * 0.9, 150) style:UITableViewStyleGrouped];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05, (destinationTableView.frame.size.height + arrivalTableView.frame.size.height) * 1.2, arrivalTableView.frame.size.width, 40)];

}

- (void)login:(id)sender
{
    LoginVC *login = [[LoginVC alloc] initWithFrame:viewFrame];
    [[self navigationController] pushViewController:login animated:YES];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if ([indexPath row] == 0) {
        [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
    }
    else
    {
        [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {

        
    }
    else
    {
//        UIViewController *vc;
//        vc = [[CalendarMonthViewController alloc] initWithSunday:NO];
//        [self.navigationController pushViewController:vc animated:YES];
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
    return 30;
}


- (void)connectToGateway
{
    NSString *connectionString = @"https://172.17.1.149:8000/sap/opu/odata/sap/ZGARENTA_TEST_SRV/available_offices(ImppAltSube='',ImppMerkezSube='')?$expand=EXPT_SUBE_BILGILERISet,EXPT_CALISMA_ZAMANISet,EXPT_TATIL_ZAMANISet&$format=json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"gw_admin"
                                                                    password:@"1qa2ws3ed"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
    return YES;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
        
        tempOffice.region = [temp objectForKey:@"Bolge"];
        tempOffice.regionText = [temp objectForKey:@"Bolgetx"];
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
                OfficeWorkingHour *tempSchedule = [[OfficeWorkingHour alloc] init];
                tempSchedule.startingHour = [timeTemp objectForKey:@"Begti"];
                tempSchedule.endingHour   = [timeTemp objectForKey:@"Endti"];
                tempSchedule.mainOffice   = [timeTemp objectForKey:@"MerkezSube"];
                tempSchedule.subOffice    = [timeTemp objectForKey:@"AltSube"];
                tempSchedule.weekDay      = [timeTemp objectForKey:@"Caday"];
                [[tempOffice workingHours] addObject:tempSchedule];
            }
        }
        
        tempOffice.holidayDates = [[NSMutableArray alloc] init];
        
        for (NSDictionary *timeTemp in holidayListResult)
        {
            if ([[timeTemp objectForKey:@"MerkezSube"] isEqualToString:tempOffice.mainOfficeCode])
            {
                OfficeWorkingHour *tempSchedule = [[OfficeWorkingHour alloc] init];
                tempSchedule.startingHour = [timeTemp objectForKey:@"Begti"];
                tempSchedule.endingHour   = [timeTemp objectForKey:@"Endti"];
                tempSchedule.mainOffice   = [timeTemp objectForKey:@"MerkezSube"];
                tempSchedule.subOffice    = [timeTemp objectForKey:@"AltSube"];
                tempSchedule.weekDay      = [timeTemp objectForKey:@"Caday"];
                [[tempOffice holidayDates] addObject:tempSchedule];
            }
        }
        
        [officeWorkingSchedule addObject:tempOffice];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"1");
}

@end
