//
//  CarGroupInfoVC.m
//  Garenta
//
//  Created by Kerem Balaban on 26.01.2015.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import "CarGroupInfoVC.h"

@interface CarGroupInfoVC ()

@end

@implementation CarGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _minimumInfo.text = [NSString stringWithFormat:@"- Min. sürücü Yaşı: %li / Min. genç Sürücü Yaşı: %li",(long)_carGroup.minAge,(long)_carGroup.minYoungDriverAge];
    
    _youngInfo.text = [NSString stringWithFormat:@"- Min. ehliyet yılı: %li / Min. genç sürücü ehliyet yılı: %li",(long)_carGroup.minDriverLicense,(long)_carGroup.minYoungDriverLicense];
    
    _dailyDepositInfo.text = [NSString stringWithFormat:@"- Günlük teminat tutarı: %.02f TRY",_carGroup.dailyDeposit.floatValue];
    
    _monthlyDepositInfo.text = [NSString stringWithFormat:@"- Aylık teminat tutarı: %.02f TRY",_carGroup.montlyDeposit.floatValue];
    
    if ([_carGroup.sampleCar.doubleCreditCard isEqualToString:@"X"]) {
        _creditCardInfo.text = @"- Çift kredi kartı: Evet";
    }else{
        _creditCardInfo.text = @"- Çift kredi kartı: Hayır";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
