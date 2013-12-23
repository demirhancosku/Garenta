//
//  CalendarTimeVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CalendarTimeVC.h"

#pragma mark - CalendarMonthViewController
@implementation CalendarTimeVC

- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (id)initWithOfficeList:(NSMutableArray *)office andDest:(Destination *)dest
{
    self = [super initWithSunday:NO];
    
    officeList = [[NSMutableArray alloc] init];
    destination = [[Destination alloc] init];
    
    destination = dest;
    officeList = office;
    
    return self;
}

- (id)initWithOfficeList:(NSMutableArray *)office andArr:(Arrival *)arr
{
    self = [super initWithSunday:NO];
    
    officeList = [[NSMutableArray alloc] init];
    arrival = [[Arrival alloc] init];
    
    arrival = arr;
    officeList = office;
    
    return self;
}

#pragma mark View Lifecycle
- (void) viewDidLoad{
    
	[super viewDidLoad];
    
	[self.monthView selectDate:[NSDate date]];
    selectedDate = [[NSDate alloc] init];
    selectedTime = [[NSDate alloc] init];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Tarih Seç" style:UIBarButtonItemStyleBordered target:self action:@selector(selectDateAndTime:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];

}

- (void)viewWillAppear:(BOOL)animated
{
    sliderText = [[UITextField alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.05, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.20, 50)];
    
    mySlider = [[UISlider alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.25, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.6, 50)];
    [mySlider addTarget:self action:@selector(sliderValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    
    [mySlider setMinimumValue:0];
    [mySlider setMaximumValue:47];
    
    [[self view] addSubview:mySlider];
}

- (void)selectDateAndTime:(id)sender
{
    
    selectedDate = [self.monthView dateSelected];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate * testDate = selectedDate;
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:testDate];
    NSInteger weekday = [weekdayComponents weekday];
    
    // weekday 1 = Sunday for Gregorian calendar

    if (arrival == nil)
    {
        [destination setDestinationDate:selectedDate];
        [destination setDestinationTime:selectedTime];
    }
    else
    {
        [arrival setArrivalDate:selectedDate];
        [arrival setArrivalTime:selectedTime];
    }
    
    
//    if ([destination destinationOfficeCode] != nil) {
//        for (int i = 0; i < [officeList count]; i++) {
//            Office *temp = [officeList objectAtIndex:i];
//            
//            if ([[temp mainOfficeCode] isEqualToString:[destination destinationOfficeCode]])
//            {
//                for (int j = 0; j < [[temp workingHours]count]; j++) {
//                    NSString *weekday2 = [NSString stringWithFormat:@"%@",[[[temp workingHours] objectAtIndex:j] weekDay]];
//                    
//                    if (![weekday2 isEqualToString:[NSString stringWithFormat:@"%li",(long)weekday]]) {
//                        
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"uyarı" message:@"uyarı" delegate:nil cancelButtonTitle:@"tamam" otherButtonTitles:nil, nil];
//                        
//                        [alert show];
//                    }
//                
//                }
//            }
//        }
//    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender
{
    NSNumber *number = [NSNumber numberWithFloat:[mySlider value]];
    int i = [number intValue];
    NSString *hour;
    NSString *min;
    
    if (i % 2) {
        min = [NSString stringWithFormat:@"%@",@"30"];
        
        if (i < 20)
            hour = [NSString stringWithFormat:@"%@%i",@"0",(i / 2)];
        else
            hour = [NSString stringWithFormat:@"%i",(i / 2)];
        
        sliderText.text = [NSString stringWithFormat:@"%@%@%@",hour,@":",min];
    }
    else
    {
        
        if (i < 20)
            hour = [NSString stringWithFormat:@"%@%i",@"0",(i / 2)];
        else
            hour = [NSString stringWithFormat:@"%i",(i / 2)];
    
        sliderText.text = [NSString stringWithFormat:@"%@%@%@",hour,@":",@"00"];
        
    }
    
    NSDateFormatter *datFormatter = [[NSDateFormatter alloc] init];
    [datFormatter setDateFormat:@"HH:mm"];
    selectedTime = [datFormatter dateFromString:sliderText.text];
    
    [[self view] addSubview:sliderText];
    
}
@end

