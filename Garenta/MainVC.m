//
//  MainVC.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{    
    self = [super init];
    viewFrame = frame;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self connectToGateway];
    
    
    [[self navigationItem] setTitle:@"Kerem"];
    
    tableViewController = [[MainTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    tableViewController.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 0, viewFrame.size.width, 350))];
    
    [self.view addSubview:tableViewController.tableView];
    
    officeWorkingSchedule = [[NSMutableArray alloc] init];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
