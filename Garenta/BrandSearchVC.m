//
//  BrandSearchVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "BrandSearchVC.h"
#define kDestinationTableTag 0
#define kArrivalTableTag 1
#define kBrandTableTag 2

@interface BrandSearchVC ()

@end

@implementation BrandSearchVC

- (id)initWithFrame:(CGRect)frame;
{
    self = [super init];
    
    viewFrame = frame;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    destinationInfo = [[Destination alloc] init];
    arrivalInfo = [[Arrival alloc] init];
    
    officeWorkingSchedule = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    //    [self connectToGateway];
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
        [arrivalTableView setRowHeight:65];
        [destinationTableView setRowHeight:65];
        [brandTableView setRowHeight:65];
    }
    else
    {
        [self setIphoneLayer];
        [arrivalTableView setRowHeight:45];
        [destinationTableView setRowHeight:45];
        [brandTableView setRowHeight:45];
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
    [searchButton addTarget:self action:@selector(showCarGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchButton];
    
    // aracın alınacağı yer
    [[destinationTableView layer] setCornerRadius:5.0f];
    [[destinationTableView layer] setBorderWidth:0.3f];
    [destinationTableView setClipsToBounds:YES];
    [destinationTableView setDelegate:self];
    [destinationTableView setDataSource:self];
    [destinationTableView setScrollEnabled:NO];
    [destinationTableView setTag:kDestinationTableTag];
    
    // aracın teslim edileceği yer
    [[arrivalTableView layer] setCornerRadius:5.0f];
    [[arrivalTableView layer] setBorderWidth:0.3f];
    [arrivalTableView setClipsToBounds:YES];
    [arrivalTableView setDelegate:self];
    [arrivalTableView setDataSource:self];
    [arrivalTableView setScrollEnabled:NO];
    [arrivalTableView setTag:kArrivalTableTag];
    
    // marka bilgisi seçilecek
    [[brandTableView layer] setCornerRadius:5.0f];
    [[brandTableView layer] setBorderWidth:0.3f];
    [brandTableView setClipsToBounds:YES];
    [brandTableView setDelegate:self];
    [brandTableView setDataSource:self];
    [brandTableView setTag:kBrandTableTag];
    [brandTableView setScrollEnabled:NO];
    
    [self.view addSubview:destinationTableView];
    [self.view addSubview:arrivalTableView];
    [self.view addSubview:brandTableView];
}

- (void)setIpadLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.9,viewFrame.size.width * 0.9, 155) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,destinationTableView.frame.size.height * 1.6 ,viewFrame.size.width * 0.9, 155) style:UITableViewStyleGrouped];
    
    brandTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(destinationTableView.frame.size.height + arrivalTableView.frame.size.height) * 1.4,viewFrame.size.width * 0.9, 90) style:UITableViewStyleGrouped];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.3, (destinationTableView.frame.size.height + arrivalTableView.frame.size.height + brandTableView.frame.size.height) * 1.4, arrivalTableView.frame.size.width * 0.4, 40)];
}

- (void)setIphoneLayer
{
    
    [arrivalTableView setRowHeight:50];
    [destinationTableView setRowHeight:50];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.4,viewFrame.size.width * 0.9, 115) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:
                        CGRectMake (viewFrame.size.width * 0.05 ,
                                    destinationTableView.frame.size.height * 1.3 ,
                                    viewFrame.size.width * 0.9,
                                    115) style:UITableViewStyleGrouped];
    
    brandTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(destinationTableView.frame.size.height + arrivalTableView.frame.size.height) * 1.2,viewFrame.size.width * 0.9, 70) style:UITableViewStyleGrouped];
    
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake (viewFrame.size.width * 0.05,
                                                               (destinationTableView.frame.size.height + arrivalTableView.frame.size.height + brandTableView.frame.size.height) * 1.2, arrivalTableView.frame.size.width, 40)];
    
}

- (void)showCarGroup:(id)sender
{
    [reservation setDestination:destinationInfo];
    [reservation setArrival:arrivalInfo];
    
    FilterScreenVC *car = [[FilterScreenVC alloc] init];
    [[self navigationController] pushViewController:car animated:YES];
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
    if ([tableView tag] == kBrandTableTag)
        return 1;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if ([tableView tag] == kBrandTableTag) {
        [[cell textLabel] setText:@"Marka Seçiniz"];
    }
    else if ([tableView tag] == kDestinationTableTag)
    {
        if ([indexPath row] == 0)
        {
            if ([destinationInfo destinationOffice] == nil)
                [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
            else
                [[cell textLabel] setText:[destinationInfo destinationOffice]];
        }
        else
        {
            if ([destinationInfo destinationDate] == nil && [destinationInfo destinationTime] == nil)
                [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
            else
                [[cell textLabel] setText:[NSString stringWithFormat:@"%@%@%@",[destinationInfo destinationDate],@" - ",[destinationInfo destinationTime]]];
        }
    }
    else
    {
        if ([indexPath row] == 0)
        {
            [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
            [[cell detailTextLabel] setText:[arrivalInfo arrivalOffice]];
        }
        else
        {
            [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
        }
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView tag] == kDestinationTableTag)
    {
        if (indexPath.row == 0) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                OfficeListVC *office = [[OfficeListVC alloc] initWithOfficeList:officeWorkingSchedule andDest:destinationInfo];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:office];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidReturn:) name:@"tableViewDidReturn" object:nil];
            }
            else
            {
                OfficeListVC *office = [[OfficeListVC alloc] initWithOfficeList:officeWorkingSchedule andDest:destinationInfo];
                [[self navigationController] pushViewController:office animated:YES];
            }
        }
        else
        {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithSunday:NO];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:vc];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithSunday:NO];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }
    else if ([tableView tag] == kArrivalTableTag)
    {
        if (indexPath.row == 0) {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                OfficeListVC *office = [[OfficeListVC alloc] initWithOfficeList:officeWorkingSchedule andArr:arrivalInfo];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:office];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidReturn:) name:@"tableViewDidReturn" object:nil];
            }
            else
            {
                OfficeListVC *office = [[OfficeListVC alloc] initWithOfficeList:officeWorkingSchedule andArr:arrivalInfo];
                [[self navigationController] pushViewController:office animated:YES];
            }
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithSunday:NO];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:vc];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithSunday:NO];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }
    else //kbrandTAbleTag
    {
        
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
    
    if ([tableView tag] == kBrandTableTag) {
        sectionName = @"MARKA";
    }
    else
    {
        if (tableView == destinationTableView) {
            sectionName = @"ARAÇ TESLİM";
        }
        else
        {
            sectionName = @"ARAÇ İADE";
        }
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
    NSString *connectionString = @"http://172.17.1.149:8000/sap/opu/odata/sap/ZGARENTA_TEST_SRV/available_offices(ImppAltSube='',ImppMerkezSube='')?$expand=EXPT_SUBE_BILGILERISet,EXPT_CALISMA_ZAMANISet,EXPT_TATIL_ZAMANISet&$format=json";
    
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
