//
//  UserInfoTableViewController.m
//  Garenta
//
//  Created by Alp Keser on 6/6/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "IDController.h"
#import "ReservationSummaryVC.h"

@interface UserInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentControl;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *tcknTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nationalitySegmentControl;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)resumeButtonPressed:(id)sender;

@end

@implementation UserInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBirthdayPicker];
    [_nationalitySegmentControl setSelectedSegmentIndex:0];
    [self fillTestData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 8;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toReservationSummaryVCSegue"]) {
        [(ReservationSummaryVC*)[segue destinationViewController] setReservation:_reservation];
    }
}



#pragma mark - UI methods
- (void)setupBirthdayPicker{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setFrame:CGRectMake(0, self.view.frame.size.height - (_datePicker.frame.size.height + self.tabBarController.tabBar.frame.size.height), _datePicker.frame.size.width, _datePicker.frame.size.height)];
    [_datePicker setBackgroundColor:[ApplicationProperties getGrey]];
    [_datePicker setMaximumDate:maxDate];
    [_datePicker setMinimumDate:minDate];
    [_datePicker setDate:maxDate];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [[self view] addSubview:_datePicker];
    [_datePicker setHidden:YES];
}
- (void)dateIsChanged:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    [_birthdayTextField setText:[formatter stringFromDate:[_datePicker date]]];
}
#pragma mark - textfield delegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    activeField = textField;
    
    if ([textField tag] == 1) // doğum tarihi
    {
        [self releaseAllTextFields];
        [_datePicker setHidden:NO];
        
        
        return NO;
    }
    else
        [_datePicker setHidden:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}
- (void)releaseAllTextFields
{
    [_nameTextField resignFirstResponder];
    [_surnameTextField resignFirstResponder];
    [_mobileNumberTextField resignFirstResponder];
    [_birthdayTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_tcknTextField resignFirstResponder];
    [_datePicker setHidden:YES];
}

- (IBAction)resumeButtonPressed:(id)sender {
    NSLog(@"ok");
    if ([self checkFields]) {
        NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
        [bdayFormatter setDateFormat:@"dd/MM/yyyy"];
        [bdayFormatter setLocale:[NSLocale currentLocale]];
        [bdayFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSDate *birthdayDate = [bdayFormatter dateFromString:[_birthdayTextField text]];

        User *user= [ApplicationProperties getUser];
        [user setName:_nameTextField.text];
        [user setSurname:_surnameTextField.text];
        [user setTckno:_tcknTextField.text];
        [user setEmail:_emailTextField.text];
        [user setMobile:_mobileNumberTextField.text];
        [user setBirthday:birthdayDate];
        [user setGender:[NSString stringWithFormat:@"%ld",(long)_sexSegmentControl.selectedSegmentIndex +1]];
        //        user setCountry:<#(NSString *)#>

        [self performSegueWithIdentifier:@"toReservationSummaryVCSegue" sender:self];
    }
}

#pragma mark - custom methods

- (BOOL)checkFields{
    // ATA burda kontroller yapılıcak
    NSString *alertString = @"";
    IDController *control = [[IDController alloc] init];
    
    NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
    [bdayFormatter setDateFormat:@"dd/MM/yyyy"];
    [bdayFormatter setLocale:[NSLocale currentLocale]];
    [bdayFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *birthdayDate = [bdayFormatter dateFromString:[_birthdayTextField text]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSYearCalendarUnit fromDate:birthdayDate];
    NSString *birtdayYearString = [NSString stringWithFormat:@"%i",weekdayComponents.year];
    
    if ([_nameTextField.text isEqualToString:@""])
        alertString =  @"Ad alanının doldurulması gerekmektedir";
    else if ([_surnameTextField.text isEqualToString:@""])
        alertString =  @"Soyad alanının doldurulması gerekmektedir";
    else if ([_birthdayTextField.text isEqualToString:@""])
        alertString =  @"Doğum Tarihi alanının doldurulması gerekmektedir";
    //    else if (!( [nationSegmentedControl selectedSegmentIndex] == 0 || [nationSegmentedControl selectedSegmentIndex] == 1) )
    //        alertString = @"Uyruk alanının seçilmesi gerekmektedir";
    else if ([_tcknTextField.text isEqualToString:@""])
        alertString =  @"T.C. Kimlik No alanının doldurulması gerekmektedir";
    else if ([_tcknTextField.text length] != 11)
        alertString =  @"T.C: Kimlik No alanının 11 Karakter olması gerekmektedir";
    else if(![self checkTckn:_tcknTextField.text andName:_nameTextField.text andSurname:_surnameTextField.text andBirthday:birtdayYearString])
        alertString = @"Girdiğiniz T.C. Kimlik No Sistemde bulunamamıştır.";
    else if ([_emailTextField.text isEqualToString:@""])
        alertString =  @"E-mail alanının doldurulması gerekmektedir";
    else if ([_mobileNumberTextField.text isEqualToString:@""])
        alertString =  @"Cep Telefonu alanının doldurulması gerekmektedir";
    
    if (![alertString isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyari" message:alertString delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    return YES;
    /*
     NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"() "];
     NSString *trimmedReplacement = [[mobileTextField.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
     mail
     // Ata sonra atcaz etcez
     User *createdUser = [[User alloc] init];
     [createdUser setName:[nameTextField text]];
     [createdUser setSurname:[surnameTextField text]];
     [createdUser setBirthday:birthdayDate];
     [createdUser setTckno:[tcknNoTextField text]];
     [createdUser setCountry:[countryTextField text]]; // buna bakıcam
     [createdUser setAddress:[adressTextField text]];
     [createdUser setEmail:[emailTextField text]];
     [createdUser setMobile:trimmedReplacement];
     [createdUser setPassword:[passwordTextField text]];
     
     //tc ise tr değil ise boş
     NSString *nationality = @"";
     NSString *pasaportNo = @"";
     
     return YES;
     */
}
- (BOOL)checkTckn:(NSString*)tckn andName:(NSString*)name andSurname:(NSString*)surname andBirthday:(NSString*)birthday{
    IDController *tcknChecker = [IDController new];
    __block BOOL returnValue = NO;
    [tcknChecker idChecker:tckn andName:name andSurname:surname andBirthYear:birthday onCompletion:^(BOOL isTrue,NSError *error){
        
        if (!error) {
            returnValue = isTrue;
        }
    }];
    return returnValue;
}
-(void)fillTestData{
    [_nameTextField setText:@"Yusuf Alp"];
    [_surnameTextField setText:@"Keser"];
    [_birthdayTextField setText:@"03/10/1988"];
    [_mobileNumberTextField setText:@"5337656704"];
    [_emailTextField setText:@"alp.keser@abh.com.tr"];
    [_tcknTextField setText:@"46558353458"];
}
@end
