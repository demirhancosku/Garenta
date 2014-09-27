//
//  CalendarTimeVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CalendarTimeVC.h"

@interface CalendarTimeVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel      *timeText;
@property (weak, nonatomic) IBOutlet UISlider     *timeSlider;

- (IBAction)selectTimeButtonPressed:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;


@end
@implementation CalendarTimeVC
@synthesize reservation,datePicker,timeSlider,timeText;
    static int secondsInDay = 60 * 60 * 24;
- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (id)initWithReservation:(Reservation*)aReservation andTag:(int) aTag
{
    reservation = aReservation;
    tag = aTag;
    
    return self;
}

#pragma mark View Lifecycle
- (void) viewDidLoad
{
	[super viewDidLoad];
    
    [self prepareDateAndtime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)prepareDateAndtime
{
    [datePicker setMinimumDate:[NSDate date]];
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:1];
    NSDate *nextYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    
    [datePicker setMaximumDate:nextYear];
    
    NSDate *defaultDate;

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

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [timeText setText:[dateFormatter stringFromDate:defaultDate]];
    
    [timeSlider setThumbImage:[UIImage imageNamed: @"SliderHandle.png"]  forState:UIControlStateNormal];
    //biraz yukari alalim ikonu
    [timeSlider setTintColor:[ApplicationProperties getOrange]];
    [timeSlider setMinimumValue:0];
    [timeSlider setMaximumValue:secondsInDay];
    [self setSliderDefaultValue];
}

- (void)setSliderDefaultValue
{
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
    [timeSlider setValue:defaultDateBySeconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [timeText setText:[dateFormatter stringFromDate:defaultDate]];
    
    selectedTime = [dateFormatter dateFromString:timeText.text];
}

- (IBAction)sliderValueChanged:(id)sender
{
    //TODO: burasi yalnis
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSNumber *number = [NSNumber numberWithFloat:[timeSlider value]];
    
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
    [timeText setText:[dateFormatter stringFromDate:myTime]];
}

- (IBAction)selectTimeButtonPressed:(id)sender
{
    //TODO burda bir hata var saat degismiyence slected date sanki nil bakmak lazım
    if (!selectedTime) {
        [[self navigationController] popViewControllerAnimated:YES];
        return;
    }
    
    //buraya zaten saat secili geliyor biz sadece yil ay gun duzenliyoruz
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *selectedDateComponents =[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:datePicker.date];
    
    NSDateComponents *selectedTimeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:selectedTime];

    selectedDateComponents.hour = selectedTimeComponents.hour;
    selectedDateComponents.minute = selectedTimeComponents.minute;
    
    selectedTime = [gregorian dateFromComponents:selectedDateComponents];
    
    switch (tag) {
        case 0://checkout
            [reservation setCheckOutTime:selectedTime];
            break;
        case 1: //checkin
            [reservation setCheckInTime:selectedTime];
            break;
        default:
            break;
    }
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"dateAndTimeSelected" object:nil];
}

@end

