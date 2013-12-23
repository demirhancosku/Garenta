//
//  ClassicSearchVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "ClassicSearchVC.h"
#define kDestinationTableTag 0
#define kArrivalTableTag 1

@interface ClassicSearchVC ()

@end

@implementation ClassicSearchVC
@synthesize popOver;

- (id)initWithFrame:(CGRect)frame;
{
    self = [super init];
    
    viewFrame = frame;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ekranki component'ların ayarlaması yapılıyor
    destinationInfo = [[Destination alloc] init];
    arrivalInfo = [[Arrival alloc] init];
    
    officeWorkingSchedule = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    [self connectToGateway];
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
    }
    else
    {
        [self setIphoneLayer];
        [arrivalTableView setRowHeight:45];
        [destinationTableView setRowHeight:45];
    }
//    
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
//    [[self navigationItem] setRightBarButtonItem:barButton];
    
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
    
    [self.view addSubview:destinationTableView];
    [self.view addSubview:arrivalTableView];
}

- (void)showCarGroup:(id)sender
{
    
    if ([destinationInfo destinationDate] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı!" message:@"Aracın teslim alınacağı zaman seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    else if ([destinationInfo destinationOfficeName] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı!" message:@"Aracın teslim alınacağı ofis seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    else if ([arrivalInfo arrivalOfficeName] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı!" message:@"Aracın iade edileceği ofis seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    else if ([arrivalInfo arrivalDate] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı!" message:@"Aracın iade edileceği zaman seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    else
    {
    
        [reservation setDestination:destinationInfo];
        [reservation setArrival:arrivalInfo];
    
        FilterScreenVC *car = [[FilterScreenVC alloc] init];
        [[self navigationController] pushViewController:car animated:YES];
    }
}

- (void)setIpadLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.9,viewFrame.size.width * 0.9, 155) style:UITableViewStyleGrouped];
    
    arrivalTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,destinationTableView.frame.size.height * 1.6 ,viewFrame.size.width * 0.9, 155) style:UITableViewStyleGrouped];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.3, (destinationTableView.frame.size.height + arrivalTableView.frame.size.height) * 1.4, arrivalTableView.frame.size.width * 0.4, 40)];
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

//- (void)login:(id)sender
//{
//    LoginVC *login = [[LoginVC alloc] initWithFrame:viewFrame];
//    [[self navigationController] pushViewController:login animated:YES];
//}

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
    

    
    if ([tableView tag] == kDestinationTableTag)
    {
        if ([indexPath row] == 0)
        {
            if ([destinationInfo destinationOfficeName] == nil)
            {
                [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:[destinationInfo destinationOfficeName]];
        }
        else
        {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd.MM.yyyy"];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"HH:mm"];
            
            //Optionally for time zone converstions
            NSString *stringFromDate = [formatter stringFromDate:[destinationInfo destinationDate]];
            NSString *stringFromTime = [formatter2 stringFromDate:[destinationInfo destinationTime]];
            
            if ([destinationInfo destinationDate] == nil && [destinationInfo destinationTime] == nil)
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
            if ([arrivalInfo arrivalOfficeName] == nil)
            {
                [[cell textLabel] setText:@"Şehir / Havalimanı Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:[arrivalInfo arrivalOfficeName]];
        }
        else
        {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd.MM.yyyy"];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"HH:mm"];
            
            //Optionally for time zone converstions
            NSString *stringFromDate = [formatter stringFromDate:[arrivalInfo arrivalDate]];
            NSString *stringFromTime = [formatter2 stringFromDate:[arrivalInfo arrivalTime]];
            
            if ([arrivalInfo arrivalDate] == nil && [arrivalInfo arrivalTime] == nil)
            {
                [[cell textLabel] setText:@"Tarih / Saat Seçiniz"];
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            else
                [[cell textLabel] setText:[NSString stringWithFormat:@"%@%@%@",stringFromDate,@" - ",stringFromTime]];
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
                vc = [[CalendarTimeVC alloc] initWithOfficeList:officeWorkingSchedule andDest:destinationInfo];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:vc];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithOfficeList:officeWorkingSchedule andDest:destinationInfo];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }
    else
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
                vc = [[CalendarTimeVC alloc] initWithOfficeList:officeWorkingSchedule andArr:arrivalInfo];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                popOver = [[UIPopoverController alloc] initWithContentViewController:vc];
                popOver.popoverContentSize = CGSizeMake(320, 320);
                [popOver setDelegate:self];
                [popOver presentPopoverFromRect:[cell frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else
            {
                UIViewController *vc;
                vc = [[CalendarTimeVC alloc] initWithOfficeList:officeWorkingSchedule andArr:arrivalInfo];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
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
    NSString *connectionString = @"https://172.17.1.149:8000/sap/opu/odata/sap/ZGARENTA_TEST_SRV/available_offices(ImppAltSube='',ImppMerkezSube='')?$expand=EXPT_SUBE_BILGILERISet,EXPT_CALISMA_ZAMANISet,EXPT_TATIL_ZAMANISet&$format=json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
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
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    
    NSDictionary *officeListDict = [result objectForKey:@"EXPT_SUBE_BILGILERISet"];
    NSDictionary *timeDict = [result objectForKey:@"EXPT_CALISMA_ZAMANISet"];
    NSDictionary *holidayDict = [result objectForKey:@"EXPT_TATIL_ZAMANISet"];
//    NSDictionary *holidayDict = [result objectForKey:@"EXPT_TATIL_ZAMANI"];
    
    
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
                tempSchedule.holidayDate  = [timeTemp objectForKey:@"Begda"];
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
