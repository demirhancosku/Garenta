//
//  User.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "User.h"
#import "Coordinate.h"

@implementation User
@synthesize name, password, surname, userLocation, username,mobile,email,company,companyName,companyName2,tckno,middleName,garentaTl,accountType,isLoggedIn,gender,birthday, kunnr, country, address, reservationList;

- (id)init{
    self = [super init];
    reservationList = [NSArray new];
    kunnr =@"";
    username = @"";
    password = @"";
    return self;
}

+ (NSArray *)loginToSap:(NSString *)username andPassword:(NSString *)password
{
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_REZ_LOGIN"];
        
        [handler addImportParameter:@"IV_PASSWORD" andValue:password];
        [handler addImportParameter:@"IV_FREETEXT" andValue:username];
        [handler addImportParameter:@"IV_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_PARTNERS"];
        [handler addTableForReturn:@"ET_CARDTYPES"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *sysubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([sysubrc isEqualToString:@"0"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *allPartners = [tables objectForKey:@"ZNET_LOGIN_ALL_PARTNERS"];
                
                if (allPartners.count > 0)
                {
                    NSMutableArray *tempUserList = [NSMutableArray new];
                    
                    for (NSDictionary *tempDict in allPartners) {
                        User *user = [User new];
                        
                        NSDateFormatter *formatter = [NSDateFormatter new];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        
                        [user setName:[tempDict valueForKey:@"MC_NAME2"]];
                        [user setMiddleName:[tempDict valueForKey:@"NAMEMIDDLE"]];
                        [user setSurname:[tempDict valueForKey:@"MC_NAME1"]];
                        [user setKunnr:[tempDict valueForKey:@"PARTNER"]];
                        [user setUsername:username];
                        [user setPassword:password];
                        [user setPartnerType:[tempDict valueForKey:@"MUSTERI_TIPI"]];
                        [user setCompany:[tempDict valueForKey:@"FIRMA_KODU"]];
                        [user setCompanyName:[tempDict valueForKey:@"FIRMA_NAME1"]];
                        [user setCompanyName2:[tempDict valueForKey:@"FIRMA_NAME2"]];
                        [user setMobileCountry:[tempDict valueForKey:@"MOBILE_ULKE"]];
                        [user setMobile:[tempDict valueForKey:@"MOBILE"]];
                        [user setEmail:[tempDict valueForKey:@"EMAIL"]];
                        [user setTckno:[tempDict valueForKey:@"TCKNO"]];
                        [user setGarentaTl:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"GARENTATL"]]];
                        [user setPriceCode:[tempDict valueForKey:@"FIYAT_KODU"]];
                        [user setPriceType:[tempDict valueForKey:@"FIYAT_TIPI"]];
                        
                        if ([[user priceType] isEqualToString:@"I"]) {
                            // demek ki ikame
                            continue;
                        }
                        
                        [user setBirthday:[formatter dateFromString:[tempDict valueForKey:@"BIRTHDAY"]]];
                        [user setDriversLicenseDate:[formatter dateFromString:[tempDict valueForKey:@"EHLIYET_TARIHI"]]];
                        
                        if ([[tempDict valueForKey:@"C_PRIORITY"] isEqualToString:@"X"]) {
                            [user setIsPriority:YES];
                        }
                        
                        if ([[tempDict valueForKey:@"CARI_ISLEM"] isEqualToString:@"X"]) {
                            [user setIsCorporateVehiclePayment:YES];
                        }
                        
                        [tempUserList addObject:user];
                    }
                    
                    return tempUserList;
                }
                else {
                    alertString = @"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz.";
                }
            }
            else {
                alertString = @"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz.";
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (![alertString isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            });
        }
    }
    
    return nil;
}

+ (void)showUserListToSelect {
    
}

@end
