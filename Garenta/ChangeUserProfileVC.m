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
//    if (self.userList.count > 2) {
//        self.tableView.scrollEnabled = YES;
//    }
//    else{
//        self.tableView.scrollEnabled = NO;
//    }
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
            profileText.text = [NSString stringWithFormat:@"%@ (Bireysel)", cellTitle];
        }
        if ([[tempUser partnerType] isEqualToString:@"K"]) {
            profileText.text = [NSString stringWithFormat:@"%@ (Kurumsal) - %@", cellTitle,tempUser.companyName];
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

@end
