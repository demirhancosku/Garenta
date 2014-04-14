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
@synthesize headerLabel, birthdayTextField, mobileTextField, emailTextField, surnameTextField, tcknNoTextField, scrollView, nameTextField, reservation, sexSegmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithReservation:(Reservation*)aReservation
{
    self  = [self initWithNibName:@"MinimumInfoVC" bundle:nil];
    reservation =aReservation;
    return self;
}

#pragma mark - uiview events
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self prepareScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 400)];
    
    [sexSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setFrame:CGRectMake(0, self.view.frame.size.height - datePicker.frame.size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
    [datePicker setBackgroundColor:[ApplicationProperties getGrey]];
    [datePicker setMaximumDate:maxDate];
    [datePicker setMinimumDate:minDate];
    [datePicker setDate:maxDate];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [[self view] addSubview:datePicker];
    [datePicker setHidden:YES];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Devam" style:UIBarButtonItemStyleBordered target:self action:@selector(resume)];
    
    [[self navigationItem] setRightBarButtonItem:barButton];
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom code

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [self releaseAllTextFields];
    //Do stuff here...
}
- (void)dateIsChanged:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    [birthdayTextField setText:[formatter stringFromDate:[datePicker date]]];
}
- (void)prepareScreen
{
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:singleFingerTap];
    
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



- (void)resume
{
    
    NSString *alertString = @"";
    
    if (!( [sexSegmentedControl selectedSegmentIndex] == 0 || [sexSegmentedControl selectedSegmentIndex] == 1) )
        alertString = @"Cinsiyet Seçilmesi gerekmektedir";
    else if ([nameTextField.text isEqualToString:@""])
        alertString =  @"Ad alanının doldurulması gerekmektedir";
    else if ([surnameTextField.text isEqualToString:@""])
        alertString =  @"Soyad alanının doldurulması gerekmektedir";
    else if ([birthdayTextField.text isEqualToString:@""])
        alertString =  @"Doğum Tarihi alanının doldurulması gerekmektedir";
    else if ([mobileTextField.text isEqualToString:@""])
        alertString =  @"Cep Telefonu alanının doldurulması gerekmektedir";
    else if ([tcknNoTextField.text isEqualToString:@""])
        alertString =  @"T.C. Kimlik No alanının doldurulması gerekmektedir";
    else if ([tcknNoTextField.text length] != 11)
        alertString =  @"T.C: Kimlik No alanının 11 Karakter olması gerekmektedir";
    
    if (![alertString isEqualToString:@""])
    {
        iToastSettings *theSettings = [iToastSettings getSharedSettings];
        [theSettings setGravity:iToastGravityCenter];
        [theSettings setFontSize:16.0];
        [[iToast makeText:alertString] show];
        
        return;
    }
    
    NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"() "];
    
    NSString *trimmedReplacement = [[mobileTextField.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@"" ];
    NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
    [bdayFormatter setDateFormat:@"dd/MM/yyyy"];
    User *user = [ApplicationProperties getUser];
    [user setName:nameTextField.text];
    [user setSurname:surnameTextField.text];
    [user setMobile:trimmedReplacement];
    [user setEmail:emailTextField.text];
    [user setTckno:tcknNoTextField.text];
    [user setBirthday:[bdayFormatter dateFromString:birthdayTextField.text]];
    
    if ([sexSegmentedControl selectedSegmentIndex] == 0)
        [user setGender:@"M"];
    else
        [user setGender:@"F"];
    
    
    ReservationSummaryViewController *summaryVC = [[ReservationSummaryViewController alloc] initWithReservation:reservation];
    if (reservation != nil) {
        
        [[self navigationController] pushViewController:summaryVC animated:YES];
    }
}

- (void)releaseAllTextFields
{
    [nameTextField resignFirstResponder];
    [surnameTextField resignFirstResponder];
    [mobileTextField resignFirstResponder];
    [birthdayTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [tcknNoTextField resignFirstResponder];
    [datePicker setHidden:YES];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
//aalpk sikintili baklcak ilk field
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin))
    {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [scrollView setContentOffset:CGPointZero];
}

#pragma mark - textfield delegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    if ([textField tag] == 1) // doğum tarihi
    {
        [self releaseAllTextFields];
        [datePicker setHidden:NO];
        
        
        return NO;
    }
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField tag] == 2)
    {
        switch ([textField.text length])
        {
            case 0:
                textField.text = [NSString stringWithFormat:@"( %@", textField.text];
                break;
            case 5:
                textField.text = [NSString stringWithFormat:@"%@ ) ", textField.text];
                break;
            case 11:
                textField.text = [NSString stringWithFormat:@"%@ ", textField.text];
                break;
            case 14:
                textField.text = [NSString stringWithFormat:@"%@ ", textField.text];
                break;
            default:
                break;
        }
    }
    
    return YES;
}
@end
