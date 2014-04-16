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
    static int secondsInDay = 60 * 60 * 24;
- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (id)initWithReservation:(Reservation*)aReservation andTag:(int) aTag
{
    self = [super initWithSunday:NO];
    reservation = aReservation;
    tag = aTag;
    
    return self;
}


#pragma mark View Lifecycle
- (void) viewDidLoad{
    
	[super viewDidLoad];
    
	[self.monthView selectDate:selectedDay];
    ;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Tarih Seç" style:UIBarButtonItemStyleBordered target:self action:@selector(selectDateAndTime:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareUI];
    
    
}

- (void)selectDateAndTime:(id)sender
{
    selectedDay = [self.monthView dateSelected];
    
    if (selectedDay == nil) {
        selectedDay = [NSDate date];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate * testDate = selectedDay;
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:testDate];
    NSInteger weekday = [weekdayComponents weekday];
    switch (tag) {
        case 0://checkout
            [reservation setCheckOutDay:selectedDay];
            [reservation setCheckOutTime:selectedTime];
            break;
        case 1: //checkin
            [reservation setCheckInDay:selectedDay];
            [reservation setCheckInTime:selectedTime];
            break;
        default:
            break;
    }

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setSliderDefaultValue{
    NSDate *defaultDate;
    
    //Optionally for time zone converstions
    //lets find slider position
    switch (tag) {
        case 0: //checkout
            defaultDate = reservation.checkOutTime;
            break;
            case 1:
            defaultDate = reservation.checkInTime;
            break;
        default:
            break;
    }
    NSCalendar *myCalnedar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [myCalnedar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:defaultDate];
    int defaultDateBySeconds = dateComps.hour * 60 * 60 + dateComps.minute*60;
    float ratio =(float)defaultDateBySeconds / (float)secondsInDay;
    [mySlider setValue:defaultDateBySeconds];
    
    sliderText.text = [NSString stringWithFormat:@"%i:%i",dateComps.hour,dateComps.minute];

    
}

- (void)setCalendarDefaultValue{
    switch (tag) {
        case 0:
            [monthView selectDate:reservation.checkOutDay];
            break;
        case 1:
            [monthView selectDate:reservation.checkInDay];
            break;
        default:
            break;
    }
}

- (void)sliderValueChanged:(id)sender
{
    //TODO: burasi yalnis
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSNumber *number = [NSNumber numberWithFloat:[mySlider value]];
    
    int selectedSeconds = [number intValue];
    NSDateComponents *dateComps = [calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:[NSDate date]];
    [dateComps setHour:00];
    [dateComps setMinute:00];

    NSDate *myTime = [calendar dateFromComponents:dateComps];
    myTime = [myTime dateByAddingTimeInterval:selectedSeconds];
    dateComps = [calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:myTime];
    int minute = dateComps.minute;
    if (0<minute && minute<15){
        dateComps.minute = 15;
    }
    if (15<minute && minute<30){
        dateComps.minute = 30;
    }
    if (30<minute && minute<45){
        dateComps.minute = 45;
    }
    if (45<minute) {
        dateComps.minute = 0;
        dateComps.hour++;
    }

    myTime = [calendar dateFromComponents:dateComps];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    selectedTime = myTime;
    [sliderText setText:[dateFormatter stringFromDate:myTime]];
    
}

- (void)prepareUI{
    
    //burasi biraz karisti center mi verdik framede mi ayarladik. neyse
    
    //configure calendar
    [self setCalendarDefaultValue];
    //adding label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.05, self.monthView.frame.size.height * 0.95, self.monthView.frame.size.width * 0.6, 50)];
    [label setText:@"Saat Seçiniz :"];
    [label sizeToFit];
    [label setTextColor:[ApplicationProperties getOrange]];
    [[self view] addSubview:label];
    
    //adding time text
    sliderText = [[UITextField alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.05, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.20, 50)];
    [sliderText setCenter:CGPointMake(self.view.frame.size.width * 0.5, label.center.y)];
    
    //adding slider
    mySlider = [[UISlider alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.25, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.6, 50)];
    [mySlider addTarget:self action:@selector(sliderValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    [mySlider setThumbImage:[UIImage imageNamed: @"SliderHandle.png"]  forState:UIControlStateNormal];
    //biraz yukari alalim ikonu
//    CGRect sliderIconFrame = mySl
    [mySlider setTintColor:[ApplicationProperties getOrange]];
    [mySlider setMinimumValue:0];
    [mySlider setMaximumValue:secondsInDay];
    [self setSliderDefaultValue];
    [[self view] addSubview:sliderText];
    [[self view] addSubview:mySlider];
    
    //adding clock icon
    UIImageView *myClockIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [myClockIcon setCenter:CGPointMake(self.view.frame.size.width * 0.2 ,mySlider.center.y)];
    [myClockIcon setImage:[UIImage imageNamed:@"clock_icon.png"]];
    [[self view] addSubview:myClockIcon];
    
}

//- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)selectedDate
//{
//    if([selectedDate compare:[NSDate date]] == NSOrderedAscending)
//    {
//        NSString *today=[NSString stringWithFormat:@"%@",[NSDate date]];
//        NSString *chooseday=[NSString stringWithFormat:@"%@",selectedDate];
//        NSArray *date1=[today componentsSeparatedByString:@" "];
//        NSArray *date2=[chooseday componentsSeparatedByString:@" "];
//        
//        if([[date1 objectAtIndex:0] isEqualToString:[date2 objectAtIndex:0]])
//        {
//            NSLog(@"Today date clicked");
//        }
//        else
//        {
//            
//            NSLog(@"Past date clicked");
//        }
//    }
//}
@end

