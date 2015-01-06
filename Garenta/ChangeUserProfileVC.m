//
//  ChangeUserProfileVC.m
//  Garenta
//
//  Created by Kerem Balaban on 16.12.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ChangeUserProfileVC.h"

@interface ChangeUserProfileVC ()

@end

@implementation ChangeUserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.userList.count > 2) {
        self.tableView.scrollEnabled = YES;
    }
    else{
        self.tableView.scrollEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return self.userList.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeUser" forIndexPath:indexPath];
    
    UILabel *profileText;
    UIImageView *selectedProfile;
    
    profileText = (UILabel *)[cell viewWithTag:1];
    selectedProfile = (UIImageView *)[cell viewWithTag:2];
    selectedProfile.image = nil;
    
    if (indexPath.section == 0) {
        User *tempUser = [self.userList objectAtIndex:indexPath.row];
        
        //seçili kullanıcının yanına tik atılır
        if ([tempUser.kunnr isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"KUNNR"]])
        {
            selectedProfile.image = [UIImage imageNamed:@"onay_icon.png"];
        }

        NSString *cellTitle = @"";
        
        if ([tempUser.middleName isEqualToString:@""]) {
            cellTitle = [NSString stringWithFormat:@"%@ %@", tempUser.name, tempUser.surname];
        }
        else {
            cellTitle = [NSString stringWithFormat:@"%@ %@ %@", tempUser.name, tempUser.middleName, tempUser.surname];
            
        }
        
        if ([[tempUser partnerType] isEqualToString:@"B"]) {
            profileText.text = [NSString stringWithFormat:@"%@ (BIREYSEL)", cellTitle];
        }
        if ([[tempUser partnerType] isEqualToString:@"K"]) {
            profileText.text = [NSString stringWithFormat:@"%@ (KURUMSAL)", cellTitle];
        }
    }
    else
    {
        selectedProfile.image = nil;
        profileText.text = @"Çıkış Yap";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        User *tempUser = [self.userList objectAtIndex:indexPath.row];
        tempUser.isLoggedIn = YES;
        
        [ApplicationProperties setUser:tempUser];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileChanged" object:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Çıkış yapmak istediğinize emin misiniz?" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Çıkış", nil];
        alert.tag = 1;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:@""forKey:@"KUNNR"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PASSWORD"];
        [ApplicationProperties setUser:nil];
        [[ApplicationProperties getUser] setPassword:@""];
        [[ApplicationProperties getUser] setUsername:@""];
        [[ApplicationProperties getUser] setIsLoggedIn:NO];
        
        
//        [self performSegueWithIdentifier:@"toLoginVC" sender:self];
        [[[self navigationItem] rightBarButtonItem] setImage:[UIImage imageNamed:@"userLoginBarButton"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileChanged" object:nil];
        return;
    }
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end