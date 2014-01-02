//
//  MinimumInfoVC.m
//  Garenta
//
//  Created by Alp Keser on 12/31/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MinimumInfoVC.h"
#import "ReservationSummaryViewController.h"
@interface MinimumInfoVC ()

@end

@implementation MinimumInfoVC
@synthesize headerLabel,adressTextView,birthdayTextField,cityTextField,countryTextField,genderTextField,mobileTextField,emailTextField,surnameTextField,tcknNoTextField,sameInvoiceInfoButton,scrollView,genderPickerView,okButton,nameTextField,reservation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (id)initWithReservation:(Reservation*)aReservation{
    self  = [self initWithNibName:@"MinimumInfoVC" bundle:nil];
    reservation =aReservation;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self prepareScreen];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Devam" style:UIBarButtonItemStyleBordered target:self action:@selector(resume)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 900)];
}
- (void)prepareScreen{
    

    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [scrollView setDelegate:self];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:singleFingerTap];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 900)];

    
    [genderTextField addTarget:self action:@selector(mrPressed:) forControlEvents:UIControlEventEditingDidBegin];
    [genderTextField setDelegate:self];
    [genderTextField setInputView:nil];
    [[genderTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[genderTextField layer] setBorderWidth:0.5f];
    genderTextField.layer.cornerRadius=8.0f;
    
    [[nameTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[nameTextField layer] setBorderWidth:0.5f];
    nameTextField.layer.cornerRadius=8.0f;

    [[surnameTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[surnameTextField layer] setBorderWidth:0.5f];
    surnameTextField.layer.cornerRadius=8.0f;
    
    [[mobileTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[mobileTextField layer] setBorderWidth:0.5f];
    mobileTextField.layer.cornerRadius=8.0f;
    
    [[birthdayTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[birthdayTextField layer] setBorderWidth:0.5f];
    birthdayTextField.layer.cornerRadius=8.0f;
    
    [[emailTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[emailTextField layer] setBorderWidth:0.5f];
    emailTextField.layer.cornerRadius=8.0f;
    
    [[tcknNoTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[tcknNoTextField layer] setBorderWidth:0.5f];
    tcknNoTextField.layer.cornerRadius=8.0f;
}
//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
      [[self view] endEditing:YES];
    [self genderSelected:nil];
    //Do stuff here...
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resume{
    User *user = [ApplicationProperties getUser];
    [user setName:nameTextField.text];
    [user setSurname:surnameTextField.text];
    [user setMobile:mobileTextField.text];
    [user setEmail:emailTextField.text];
    [user setTckno:tcknNoTextField.text];
    
    //aalpk bursını kodlu falan yaparız heralde
    [user setGender: genderTextField.text];
    ReservationSummaryViewController *summaryVC = [[ReservationSummaryViewController alloc] initWithNibName:@"ReservationSummaryViewController" bundle:nil];
    if (reservation != nil) {
        
        [[self navigationController] pushViewController:summaryVC animated:YES];
    }

}

# pragma mark - ibaction


- (IBAction)mrPressed:(id)sender{
   //show pickerview to picks
    [genderTextField setText:[self pickerView:genderPickerView titleForRow:0 forComponent:0]];
    genderPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(genderTextField.frame.origin.x, genderTextField.frame.origin.y, self.view.frame.size.width - (genderTextField.frame.origin.x *2), 100)];
    [genderPickerView setBackgroundColor:[ApplicationProperties getGrey]];
    [genderPickerView setDelegate:self];
    [genderPickerView setDataSource:self];
    [genderTextField setTextAlignment:NSTextAlignmentCenter];
    okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [okButton setFrame:CGRectMake(0,0,50,20)];
    [okButton setCenter:self.view.center];
    [okButton setBackgroundColor:[ApplicationProperties getOrange]];
    [okButton addTarget:self action:@selector(genderSelected:) forControlEvents:UIControlEventTouchUpInside];
    [okButton setTitle:@"Seç" forState:UIControlStateNormal];
    [[self view] addSubview:genderPickerView];
    [self.view addSubview:okButton];
    NSLog(@"%@",sender);
}


- (void)genderSelected:(id)sender{
    [genderPickerView removeFromSuperview];
    [okButton removeFromSuperview];
    
}

#pragma mark - Picker view data source

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//aalpk akllimizda bulunsun
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 37)];
//    label.text = [NSString stringWithFormat:@"something here"];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//
//    return label;
//}
// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"Bay";
            break;
        case 1:
            return @"Bayan";
            break;
        default:
            break;
    }
    return @"Seçiniz";
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return pickerView.frame.size.width;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [genderTextField setText:[self pickerView:thePickerView titleForRow:row forComponent:component]];
}


#pragma mark - textfield delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return NO;
}
@end
