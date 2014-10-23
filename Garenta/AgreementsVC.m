//
//  AgreementsVC.m
//  Garenta
//
//  Created by Ata Cengiz on 22/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AgreementsVC.h"

@interface AgreementsVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation AgreementsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.agreementName;
    NSURL *url = [[NSBundle mainBundle] URLForResource:self.htmlName withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
