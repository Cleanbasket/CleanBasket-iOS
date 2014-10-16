//
//  ChooseLaundryViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "ChooseLaundryViewController.h"
#define IMAGE_WIDTH 160
#define IMAGE_HEIGHT 160
#define FieldHeight 35
#define FieldWidth 200
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 254
#define Interval 53

@interface ChooseLaundryViewController () {
    UIImageView *laundryImageView;
    NSArray *laundryImages;
    NSUInteger imageIdx;
    NSArray *laundryNames;
    UILabel *laundryLabel;
}
@end

@implementation ChooseLaundryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imageIdx = 0;
    [self.navigationItem setTitle:@"세탁품목선택"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonDidTouched)]];
    
    laundryImages = [NSArray arrayWithObjects:
                     [UIImage imageNamed:@"ic_calc_yshirt.png"],
                     [UIImage imageNamed:@"ic_calc_suit.png"],
                     [UIImage imageNamed:@"ic_calc_skirtpants.png"],
                     [UIImage imageNamed:@"ic_calc_blouse.png"],
                     [UIImage imageNamed:@"ic_calc_onepiece.png"],
                     [UIImage imageNamed:@"ic_calc_coat.png"],
                     [UIImage imageNamed:@"ic_calc_etc.png"],
                     nil];
    
    laundryNames = [NSArray arrayWithObjects:
                    @"와이셔츠",
                    @"정장(한벌)",
                    @"바지/스커트",
                    @"블라우스",
                    @"원피스",
                    @"코트",
                    @"기타",
                    nil];
    
    NSMutableArray *imageViews = [NSMutableArray array];
    for (UIImage *each in laundryImages) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:each];
        [imageView setFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageViews addObject:imageView];
    }
    
    laundryLabel = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - IMAGE_WIDTH)/2, 64, IMAGE_WIDTH, 30)];
    [laundryLabel setTextAlignment:NSTextAlignmentCenter];
    [laundryLabel setTextColor:CleanBasketMint];
    [laundryLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [laundryLabel setText:[laundryNames objectAtIndex:0]];
    
    laundryImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - IMAGE_WIDTH)/2, 94, IMAGE_WIDTH, IMAGE_HEIGHT)];
    [laundryImageView setBackgroundColor:CleanBasketMint];
    [laundryImageView setUserInteractionEnabled:YES];
    [laundryImageView setImage:[laundryImages objectAtIndex:imageIdx]];
    [laundryImageView setContentMode:UIViewContentModeScaleToFill];
    [laundryImageView.layer setCornerRadius:5.0f];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [laundryImageView addGestureRecognizer:swipeLeft];
    [laundryImageView addGestureRecognizer:swipeRight];
    
    RPVerticalStepper *stepper = [[RPVerticalStepper alloc] initWithFrame:CGRectMake(260, 265, 0, 0)];
    [stepper addTarget:self action:@selector(stepperPressed:) forControlEvents:UIControlEventValueChanged];
    
    [stepper setMinimumValue:0];
    [stepper setMaximumValue:99];
    [stepper setStepValue:1];
    
    [self.view addSubview:stepper];
    [self.view addSubview:laundryImageView];
    [self.view addSubview:laundryLabel];
}

- (void)stepperPressed:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    NSLog(@"%f", [stepper value]);
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        ++imageIdx;
        if (imageIdx > 6) {
            imageIdx = 0;
        }
        [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
        
        [UIView transitionWithView:laundryLabel
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
                        } completion:^(BOOL finished) {
                            // do something.
                        }];
        
        [UIView transitionWithView:laundryImageView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            //  Set the new image
                            //  Since its done in animation block, the change will be animated
                            laundryImageView.image = [laundryImages objectAtIndex:imageIdx];
                        } completion:^(BOOL finished) {
                            //  Do whatever when the animation is finished
                        }];
        
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        --imageIdx;
        if (imageIdx > 6) {
            imageIdx = 6;
        }
        [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
        
        [UIView transitionWithView:laundryLabel
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
                        } completion:^(BOOL finished) {
                            // do something.
                        }];
        
        [UIView transitionWithView:laundryImageView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            //  Set the new image
                            //  Since its done in animation block, the change will be animated
                            laundryImageView.image = [laundryImages objectAtIndex:imageIdx];
                        } completion:^(BOOL finished) {
                            //  Do whatever when the animation is finished
                        }];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelButtonDidTouched {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(CenterX, FirstElementY + Interval * [view tag], FieldWidth, FieldHeight);
}

@end
