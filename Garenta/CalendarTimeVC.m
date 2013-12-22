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
    self = [super init];
    
    officeList = [[NSMutableArray alloc] init];
    destination = [[Destination alloc] init];
    
    destination = dest;
    officeList = office;
    
    return self;
}

- (id)initWithOfficeList:(NSMutableArray *)office andArr:(Arrival *)arr
{
    self = [super init];
    
    officeList = [[NSMutableArray alloc] init];
    arrival = [[Arrival alloc] init];
    
    arrival = arr;
    officeList = office;
    
    return self;
}

#pragma mark View Lifecycle
- (void) viewDidLoad{
	[super viewDidLoad];
//	self.title = NSLocalizedString(@"Month Grid", @"");
	[self.monthView selectDate:[NSDate date]];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(selectDateAndTime:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];

}

- (void)viewWillAppear:(BOOL)animated
{
    sliderText = [[UITextField alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.05, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.15, 50)];
    
    mySlider = [[UISlider alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.2, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.6, 50)];
    [mySlider addTarget:self action:@selector(sliderValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    
    [mySlider setMinimumValue:0.0];
    [mySlider setMaximumValue:24.0];
    [mySlider setUserInteractionEnabled:YES];
    
    [[self view] addSubview:mySlider];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	
    selectedDate = date;

}

- (void)selectDateAndTime:(id)sender
{
//    selectedDate = [super dateSelected];
    
    if (arrival == nil) {
        [destination setDestinationDate:selectedDate];
//        destination setDestinationTime:];
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender
{
    NSDate *localDate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *dateString = [timeFormatter stringFromDate: localDate];
    
    sliderText.text = dateString;
    [[self view] addSubview:sliderText];
    
    [mySlider setValue:[[sliderText text] floatValue]];
}

@end

