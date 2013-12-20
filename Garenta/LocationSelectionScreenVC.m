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
    self = [super init];
    
    viewFrame = frame;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ekranki component'ların ayarlaması yapılıyor
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

- (void)changeDateInLabel:(id)sender
{
    
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
    
    if (indexPath.row == 1) {
//        [arrivalTableView setHidden:YES];
//        [searchButton setHidden:YES];
//        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 160, 325, 250)];
//        datePicker.datePickerMode = UIDatePickerModeDate;
//        datePicker.hidden = NO;
//        datePicker.date = [NSDate date];
//        [datePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
//        
//        [self.view addSubview:datePicker];
        
        int startHour = 9;
        int endHour = 13;
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 160, 325, 250)];
        NSDate *date1 = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date1];
        [components setHour: startHour];
        [components setMinute: 0];
        [components setSecond: 0];
        NSDate *startDate = [gregorian dateFromComponents: components];
        
        [components setHour: endHour];
        [components setMinute: 0];
        [components setSecond: 0];
        NSDate *endDate = [gregorian dateFromComponents: components];
        
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setMinimumDate:startDate];
        [datePicker setMaximumDate:endDate];
        [datePicker setDate:startDate animated:YES];
        [datePicker reloadInputViews];
        
        [arrivalTableView setHidden:YES];
        [searchButton setHidden:YES];
        
        
        [self.view addSubview:datePicker];
        
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

@end
