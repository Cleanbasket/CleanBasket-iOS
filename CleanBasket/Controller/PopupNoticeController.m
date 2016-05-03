//
//  PopupNoticeController.m
//  CleanBasket
//
//  Created by ChaTheodore on 2016. 4. 26..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "PopupNoticeController.h"

@implementation PopupNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:@"http://1.255.56.182/images/popup.png"];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    
    [_image setImage:tmpImage];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)touchDown:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
