//
//  ChooseLaundryViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 16..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "ChooseLaundryViewController.h"
#import <Realm/Realm.h>
#import "CBConstants.h"
#import "ALScrollViewPaging.h"
#import "ALScrollViewPaging.h"
#import "RPVerticalStepper.h"
#import "Order.h"
#import "Item_code.h"
#import "ChooseOtherLaundryViewController.h"
#import "NSString+CBString.h"
#import "MBProgressHUD.h"
#import "DTOManager.h"
#import "AFNetworking.h"
#import "CouponListViewController.h"
#import "Address.h"

static const CGFloat kImageWidth = 200;
static const CGFloat kImageHeight = 200;

#define X_FIRST 0
#define X_SECOND 60
#define X_THIRD 260
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 250
#define WIDTH_REGULAR 200
#define WIDTH_SMALL 60
#define WIDTH_LARGE 230
#define WIDTH_FULL 300
#define HEIGHT_REGULAR 35
#define MARGIN_REGULAR 50
#define NUM_MAIN_ITEM 6

@interface ChooseLaundryViewController () <UITextFieldDelegate, CouponListViewControllerDelegate>{
    UIImageView *laundryImageView;
    NSArray *laundryImages;
    NSUInteger imageIdx;
    NSArray *laundryNames;
    UILabel *laundryLabel;
    UILabel *quantityLabel;
    RPVerticalStepper *stepper;
    RLMArray *itemArray;
    Item *currentItem;
    UILabel *priceLabel;
    UILabel *priceValueLabel;
    UILabel *sumLabel;
    UILabel *sumValueLabel;
    UILabel *totalLabel;
    UILabel *totalValueLabel;
    UITextField *memoTextField;
    UIButton *confirmButton;
    UIScrollView *scrollView;
    UIButton *couponButton;
    int totalPrice;
    UILabel *touchLabel;
}
@end

@implementation ChooseLaundryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"세탁품목선택"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonDidTouched)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    itemArray = [Item_code allObjects];
    imageIdx = 0;
    currentItem = [itemArray objectAtIndex:imageIdx];
    
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
        [imageView setFrame:CGRectMake(0, 0, kImageWidth, kImageHeight)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageViews addObject:imageView];
    }
    
    UITapGestureRecognizer *scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidTap)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [scrollView setContentSize:CGSizeMake(DEVICE_WIDTH, (iPhone5 ? DEVICE_HEIGHT-64:  DEVICE_HEIGHT + 40))];
    [scrollView addGestureRecognizer:scrollViewTapGesture];
    
    laundryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    [laundryLabel setTextAlignment:NSTextAlignmentCenter];
    [laundryLabel setTextColor:CleanBasketMint];
    [laundryLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [laundryLabel setText:[laundryNames objectAtIndex:0]];
    
    
    UITapGestureRecognizer *laundryTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(laundryImageViewDidTap)];
    
    laundryImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - kImageWidth)/2, 30, kImageWidth, kImageHeight)];
    [laundryImageView setBackgroundColor:CleanBasketMint];
    [laundryImageView setUserInteractionEnabled:YES];
    [laundryImageView setImage:[laundryImages objectAtIndex:imageIdx]];
    [laundryImageView setContentMode:UIViewContentModeScaleToFill];
    [laundryImageView.layer setCornerRadius:10.0f];
    [laundryImageView addGestureRecognizer:laundryTapGesture];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [laundryImageView addGestureRecognizer:swipeLeft];
    [laundryImageView addGestureRecognizer:swipeRight];
    
    stepper = [[RPVerticalStepper alloc] initWithFrame:CGRectMake(275, 167, 0, 0)];
    [stepper setMinimumValue:0];
    [stepper setMaximumValue:99];
    [stepper setStepValue:1];
    [stepper setValue:[currentItem count]];
    [stepper addTarget:self action:@selector(stepperPressed) forControlEvents:UIControlEventValueChanged];
    
    quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 190, 40, 40)];
    [quantityLabel setFont:[UIFont systemFontOfSize:24.0f]];
    [quantityLabel setAdjustsFontSizeToFitWidth:YES];
    [quantityLabel setTextAlignment:NSTextAlignmentCenter];
    [quantityLabel setText:[NSString stringWithFormat:@"%.0f", [stepper value]]];
    [quantityLabel setTextColor:[UIColor whiteColor]];
    [quantityLabel setBackgroundColor:[UIColor clearColor]];
    [quantityLabel setClipsToBounds:YES];
    
    priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_FIRST, Y_FIRST, WIDTH_SMALL, HEIGHT_REGULAR)];
    [priceLabel setText:@"가격"];
    [priceLabel setTextColor:CleanBasketMint];
    [priceLabel setTextAlignment:NSTextAlignmentCenter];
    [priceLabel.layer setCornerRadius:10.0f];
    
    priceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_SECOND, Y_FIRST, WIDTH_REGULAR, HEIGHT_REGULAR)];
    [priceValueLabel setBackgroundColor:UltraLightGray];
    [priceValueLabel setTextColor:[UIColor lightGrayColor]];
    [priceValueLabel setText:[NSString stringWithCurrencyFormat:[currentItem price]]];
    [priceValueLabel setTextAlignment:NSTextAlignmentCenter];
    [priceValueLabel.layer setCornerRadius:10.0f];
    [priceValueLabel setClipsToBounds:YES];
    
    
    sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR, WIDTH_SMALL, HEIGHT_REGULAR)];
    [sumLabel setText:@"합계"];
    [sumLabel setTextColor:CleanBasketMint];
    [sumLabel setTextAlignment:NSTextAlignmentCenter];
    
    sumValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_SECOND, Y_FIRST + MARGIN_REGULAR, WIDTH_REGULAR, HEIGHT_REGULAR)];
    [sumValueLabel setBackgroundColor:UltraLightGray];
    [sumValueLabel setTextColor:[UIColor lightGrayColor]];
    [sumValueLabel setText:@"-"];
    [sumValueLabel setTextAlignment:NSTextAlignmentCenter];
    [sumValueLabel setAdjustsFontSizeToFitWidth:YES];
    [sumValueLabel.layer setCornerRadius:10.0f];
    [sumValueLabel setClipsToBounds:YES];
    
    couponButton = [[UIButton alloc] initWithFrame:CGRectMake(X_THIRD + 10, Y_FIRST + MARGIN_REGULAR, 40, 35)];
    [couponButton setBackgroundColor:CleanBasketMint];
    [couponButton setTitle:@"쿠폰" forState:UIControlStateNormal];
    [couponButton setTitle:@"취소" forState:UIControlStateSelected];
    [couponButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [couponButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [couponButton addTarget:self action:@selector(couponButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    [couponButton.layer setCornerRadius:10.0f];
    [couponButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [couponButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    
    // UI - 3번째줄에 있는 요소들
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_FIRST, Y_FIRST + MARGIN_REGULAR * 2, WIDTH_SMALL, HEIGHT_REGULAR)];
    [totalLabel setText:@"총계"];
    [totalLabel setTextColor:CleanBasketMint];
    [totalLabel setTextAlignment:NSTextAlignmentCenter];
    [totalLabel.layer setCornerRadius:10.0f];
    
    totalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_SECOND, Y_FIRST + MARGIN_REGULAR*2, WIDTH_REGULAR, HEIGHT_REGULAR)];
    [totalValueLabel setBackgroundColor:UltraLightGray];
    [totalValueLabel setTextColor:[UIColor lightGrayColor]];
    [totalValueLabel setText:@"-"];
    [totalValueLabel setTextAlignment:NSTextAlignmentCenter];
    [totalValueLabel.layer setCornerRadius:10.0f];
    [totalValueLabel setClipsToBounds:YES];
    
    memoTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, Y_FIRST + MARGIN_REGULAR*3, 300, HEIGHT_REGULAR)];
    [memoTextField.layer setCornerRadius:10.0f];
    [memoTextField setPlaceholder:@"추가요청사항"];
    [memoTextField setBackgroundColor:UltraLightGray];
    [memoTextField addTarget:self action:@selector(memoTextFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    [memoTextField addTarget:self action:@selector(memoTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
    [memoTextField setTextColor:[UIColor grayColor]];
    UIView *memoPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [memoTextField setLeftView:memoPaddingView];
    [memoTextField setLeftViewMode:UITextFieldViewModeAlways];
    [memoTextField setReturnKeyType:UIReturnKeyDone];
    [memoTextField setDelegate:self];
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - WIDTH_REGULAR)/2, Y_FIRST + MARGIN_REGULAR * 4, WIDTH_REGULAR, HEIGHT_REGULAR)];
    [confirmButton setTitle:@"주문확정" forState:UIControlStateNormal];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    
    touchLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 202, kImageWidth, 30)];
    [touchLabel setText:@"Touch Me!"];
    [touchLabel setTextAlignment:NSTextAlignmentCenter];
    [touchLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [touchLabel setTextColor:[UIColor whiteColor]];
    [touchLabel setHidden:YES];
    
    [self.view addSubview:scrollView];
    [scrollView addSubview:memoTextField];
    [scrollView addSubview:totalValueLabel];
    [scrollView addSubview:totalLabel];
    [scrollView addSubview:sumValueLabel];
    [scrollView addSubview:sumLabel];
    [scrollView addSubview:priceValueLabel];
    [scrollView addSubview:priceLabel];
    [scrollView addSubview:stepper];
    [scrollView addSubview:laundryImageView];
    [scrollView addSubview:laundryLabel];
    [scrollView addSubview:confirmButton];
    [scrollView addSubview:quantityLabel];
    [scrollView addSubview:couponButton];
    [scrollView addSubview:touchLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationItem setTitle:@"세탁품목선택"];
    if ( imageIdx == NUM_MAIN_ITEM ) {
        int sumOfCount = 0;
        for ( int i = NUM_MAIN_ITEM; i < [itemArray count]; ++i) {
            Item *each = [itemArray objectAtIndex:i];
            sumOfCount += [each count];
        }
        [quantityLabel setText:[NSString stringWithFormat:@"%d", sumOfCount]];
        [priceValueLabel setText:[NSString stringWithCurrencyFormat:[self calcSumOfOtherLaundryPrice]]];
    }
    [self setSumValueLabelPrice];
    [self setTotalValueLabelPrice];
    
    if (self.currentCoupon == nil) {
        [couponButton setSelected:NO];
    }
}

- (void) memoTextFieldEditingDidBegin {
    [scrollView setContentSize:CGSizeMake(DEVICE_WIDTH, (iPhone5 ? DEVICE_HEIGHT+120:DEVICE_HEIGHT+240))];
    [scrollView scrollRectToVisible:CGRectMake(0, 300, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
}

- (void) memoTextFieldEditingDidEnd {
    [scrollView setContentSize:CGSizeMake(DEVICE_WIDTH, (iPhone5?DEVICE_HEIGHT:DEVICE_HEIGHT + 60))];
    [scrollView scrollRectToVisible:CGRectMake(0, 80, DEVICE_WIDTH, DEVICE_HEIGHT) animated:YES];
}

- (void)stepperPressed {
    if (imageIdx == NUM_MAIN_ITEM) {
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [currentItem setCount:[stepper value]];
    [quantityLabel setText:[NSString stringWithFormat:@"%d", [currentItem count]]];
    [self setSumValueLabelPrice];
    [self setTotalValueLabelPrice];
    [realm commitWriteTransaction];
}

- (void) laundryImageViewDidTap {
    if ( imageIdx == NUM_MAIN_ITEM ) {
        [self.navigationItem setTitle:@""];
        ChooseOtherLaundryViewController *chooseOtherLaundryViewController = [[ChooseOtherLaundryViewController alloc] init];
        
        [chooseOtherLaundryViewController setItemArray:itemArray];
        [chooseOtherLaundryViewController setNumberOfMainItems:NUM_MAIN_ITEM];
        [self.navigationController pushViewController:chooseOtherLaundryViewController animated:YES];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        ++imageIdx;
        if (imageIdx > NUM_MAIN_ITEM) {
            imageIdx = 0;
        }
        [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
        
        // 기타품목이 화면에 나올 경우
        if ( imageIdx == NUM_MAIN_ITEM ) {
            
            [touchLabel setHidden:NO];
            [priceValueLabel setText:[NSString stringWithCurrencyFormat:[self calcSumOfOtherLaundryPrice]]];
            [quantityLabel setText:[NSString stringWithFormat:@"%d", [self calcCountOfOtherLaundry]]];
        }
        else {
            [touchLabel setHidden:YES];
            currentItem = [itemArray objectAtIndex:imageIdx];
            [stepper setValue:[currentItem count]];
            [priceValueLabel setText:[NSString stringWithCurrencyFormat:[currentItem price]]];
            [quantityLabel setText:[NSString stringWithFormat:@"%d", [currentItem count]]];
        }
        
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
        if (imageIdx > NUM_MAIN_ITEM) {
            imageIdx = NUM_MAIN_ITEM;
        }
        [laundryLabel setText:[laundryNames objectAtIndex:imageIdx]];
        
        // 기타 품목이 화면에 나올 경우
        if ( imageIdx == NUM_MAIN_ITEM ) {
            [touchLabel setHidden:NO];
            [priceValueLabel setText:[NSString stringWithCurrencyFormat:[self calcSumOfOtherLaundryPrice]]];
            [quantityLabel setText:[NSString stringWithFormat:@"%d", [self calcCountOfOtherLaundry]]];
        }
        else {
            [touchLabel setHidden:YES];
            currentItem = [itemArray objectAtIndex:imageIdx];
            [stepper setValue:[currentItem count]];
            [quantityLabel setText:[NSString stringWithFormat:@"%d", [currentItem count]]];
            [priceValueLabel setText:[NSString stringWithCurrencyFormat:[currentItem price]]];
        }
        
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == memoTextField) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [self.currentOrder setMemo:[textField text]];
        [realm commitWriteTransaction];
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelButtonDidTouched {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) scrollViewDidTap {
    [self.view endEditing:YES];
}

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(X_CENTER_DEVICE, Y_FIRST + MARGIN_REGULAR * [view tag], WIDTH_REGULAR, HEIGHT_REGULAR);
}

- (int) calcSumOfOtherLaundryPrice {
    int sumOfPrice = 0;
    for ( int i = NUM_MAIN_ITEM; i < [itemArray count]; ++i) {
        Item *each = [itemArray objectAtIndex:i];
        sumOfPrice += [each count] * [each price];
    }
    NSLog(@"%d", sumOfPrice);
    return sumOfPrice;
}

- (int) calcCountOfOtherLaundry {
    int sumOfCount = 0;
    for ( int i = NUM_MAIN_ITEM; i < [itemArray count]; ++i) {
        Item *each = [itemArray objectAtIndex:i];
        sumOfCount += [each count];
    }
    NSLog(@"%d", sumOfCount);
    return sumOfCount;
}

- (int) calcSumOfLaundryPrice {
    int sumPrice = 0;
    for (Item *each in itemArray) {
        sumPrice += [each price] * [each count];
    }
    if (self.currentCoupon) {
        [sumValueLabel setTextColor:CleanBasketMint];
    } else {
        [sumValueLabel setTextColor:[UIColor lightGrayColor]];
    }
    
    return sumPrice;
}

- (void) calcTotalPrice {
    totalPrice = [self calcSumOfLaundryPrice];
    if ([self calcSumOfLaundryPrice] < 20000) {
        totalPrice = [self calcSumOfLaundryPrice] + 2000;
    }
}

- (void) setSumValueLabelPrice {
    if ([self calcSumOfLaundryPrice] == 0 ) {
        [sumValueLabel setText:@"-"];
    }
    else if ([self calcSumOfLaundryPrice] < 20000) {
        int price = [self calcSumOfLaundryPrice];
        if (self.currentCoupon) price -= self.currentCoupon.value;
        NSString *sumValue = [NSString stringWithCurrencyFormat:price];
        sumValue = [sumValue stringByAppendingString:@" + "];
        sumValue = [sumValue stringByAppendingString:[NSString stringWithCurrencyFormat:2000]];
        sumValue = [sumValue stringByAppendingString:@"(배송비)"];
        [sumValueLabel setText:sumValue];
    }
    else {
        int price = [self calcSumOfLaundryPrice];
        if (self.currentCoupon) price -= self.currentCoupon.value;
        [sumValueLabel setText:[NSString stringWithCurrencyFormat:price]];
    }
}

- (void) setTotalValueLabelPrice {
    [self calcTotalPrice];
    if ([self calcSumOfLaundryPrice] == 0) {
        [totalValueLabel setText:@"-"];
        return;
    }
    
    int price = totalPrice;
    if (self.currentCoupon)
        price -= self.currentCoupon.value;
    
    [totalValueLabel setText:[NSString stringWithCurrencyFormat:price]];
}


- (void) couponButtonDidTap {
    if ([self isCouponEmpty]) {
        [self showHudMessage:@"사용 가능 쿠폰이 없습니다."];
        return;
    }
    
    if ([self isPriceLessThan10K]) {
        [self showHudMessage:@"10,000 이상 주문시 사용 가능합니다."];
        return;
    };
    
    [couponButton setSelected:!couponButton.selected];
    
    // 쿠폰 적용하기!
    if (couponButton.selected) {
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[self navigationItem] setBackBarButtonItem:newBackButton];
        CouponListViewController *couponListViewController = [[CouponListViewController alloc] init];
        [couponListViewController setDelegate:self];
        [self.navigationController pushViewController:couponListViewController animated:YES];
    }
    // 기 적용 쿠폰 제거
    else {
        [couponButton setBackgroundColor:CleanBasketMint];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        self.currentCoupon = nil;
        [self.currentOrder setCoupon:nil];
        [realm commitWriteTransaction];
        [self setSumValueLabelPrice];
        [self setTotalValueLabelPrice];
    }
    
}

- (void) setViewController:(CouponListViewController *)controller currentCoupon:(Coupon *)currentCoupon {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.currentCoupon = currentCoupon;
    //    RLMArray *couponArray = [[RLMArray alloc] initWithObjectClassName:@"Coupon"];
    //    [couponArray addObject:self.currentCoupon];
    //    [self.currentOrder setCoupon:(RLMArray<Coupon>*)couponArray];
    [couponButton setBackgroundColor:CleanBasketRed];
    [realm commitWriteTransaction];
}

- (void) confirmButtonDidTap {
    if ([self isPriceLessThan10K]) {
        [self showHudMessage:@"10,000 이상의 주문만 가능합니다."];
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [self.currentOrder setPrice:totalPrice];
    [self.currentOrder setMemo:[memoTextField text]];
    if ([self calcSumOfLaundryPrice] < 20000 )
        [self.currentOrder setDropoff_price:2000];
    else
        [self.currentOrder setDropoff_price:0];
    if([self currentCoupon])
        [self.currentOrder setPrice:(totalPrice-=self.currentCoupon.value)];
    [self calcSumOfLaundryPrice];
    [realm commitWriteTransaction];
    
    NSMutableArray *itemJsonArray = [NSMutableArray array];
    for (Item *each in itemArray) {
        if ([each count]>0) {
            NSMutableDictionary *jsonItem = [NSMutableDictionary dictionary];
            [jsonItem setObject:[NSNumber numberWithInt:[each item_code]] forKey:@"item_code"];
            [jsonItem setObject:[NSNumber numberWithInt:[each count]] forKey:@"count"];
            [jsonItem setObject:@0 forKey:@"itid"];
            [jsonItem setObject:@0 forKey:@"oid"];
            [jsonItem setObject:@"" forKey:@"name"];
            [jsonItem setObject:@"" forKey:@"descr"];
            [jsonItem setObject:@0 forKey:@"price"];
            [jsonItem setObject:@"" forKey:@"img"];
            [jsonItem setObject:@"" forKey:@"rdate"];
            NSLog(@"%@", each);
            [itemJsonArray addObject:jsonItem];
        }
    }
    NSMutableArray *couponList = [NSMutableArray array];
    if (self.currentCoupon)
        [couponList addObject:[NSNumber numberWithInt:self.currentCoupon.cpid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"adrid":[NSNumber numberWithInt:[self.currentAddress adrid]],
                                                                                      @"phone":[self.currentOrder phone],
                                                                                      @"memo":[self.currentOrder memo],
                                                                                      @"price":[NSNumber numberWithInt:[self.currentOrder price]],
                                                                                      @"dropoff_price":[NSNumber numberWithInt:[self.currentOrder dropoff_price]],
                                                                                      @"pickup_date":[self.currentOrder pickup_date],
                                                                                      @"dropoff_date":[self.currentOrder dropoff_date],
                                                                                      @"item":itemJsonArray,
                                                                                      @"cpid":couponList
                                                                                      }];
    
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.cleanbasket.co.kr/member/order/add"]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"[JSON STRING]\r%@", jsonString);
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON responseObject: %@ ",responseObject);
        NSLog(@"%@", [responseObject valueForKey:@"message"]);
        int constant = [[responseObject valueForKey:@"constant"] intValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        switch (constant) {
            case CBServerConstantSuccess: {
                [self showHudMessage:@"주문이 정상적으로 접수되었습니다."];
                [self resetItemsCount];
                
                if (self.currentCoupon) {
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    NSLog(@"Order Complete and Delete Coupon %@ from Local", [Coupon objectForPrimaryKey:[NSNumber numberWithInt:self.currentCoupon.cpid]]);
                    [realm deleteObject:[Coupon objectForPrimaryKey:[NSNumber numberWithInt:self.currentCoupon.cpid]]];
                    [realm commitWriteTransaction];
                }
                
                [memoTextField setText:@""];
                
                //AppDelegate로 하여금 현재 선택된 TabBarViewController를 OrderStatusViewController로 변경
                [[NSNotificationCenter defaultCenter] postNotificationName:@"orderComplete" object:self];
                
                // 2초 후 현재 화면 pop
                [self performSelector:@selector(cancelButtonDidTouched) withObject:self afterDelay:2];
            }
                break;
            case CBServerConstantError: {
                [self showHudMessage:@"주문 정보 접수에 실패했습니다."];
            }
                break;
                
            case CBServerConstantsAreaUnavailable: {
                [self showHudMessage:@"서비스 가능 지역이 아닙니다"];
            }
                break;

            case CBServerConstantsDateUnavailable: {
                [self showHudMessage:@"죄송합니다. 해당 수거/배달일은 휴무입니다"];
            }
                break;
                
            case CBServerConstantSessionExpired: {
                [self showHudMessage:@"세션이 만료되었습니다. 로그인화면으로 돌아갑니다."];
                [self resetItemsCount];
                [memoTextField setText:@""];
                //AppDelegate에 세션이 만료됨을 알림
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
            }
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showHudMessage:@"네트워크 상태를 확인해주세요"];
            NSLog(@"Error: %@", [error localizedDescription]);
        });
        
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주문을 접수중입니다."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [op start];
    });
}

- (BOOL) isPriceLessThan10K {
    if ([self calcSumOfLaundryPrice] < 10000) {
        return YES;
    } else
        return NO;
}

- (BOOL) isCouponEmpty {
    if ([[Coupon allObjects] count] < 1) {
        return YES;
    }
    else {
        return NO;
    }
}


- (void) showHudMessage:(NSString*)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:nil];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
    return;
}

- (void) resetItemsCount {
    RLMRealm *realm = [RLMRealm defaultRealm];
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (Item *each in itemArray) {
        [each setCount:0];
    }
    [realm commitWriteTransaction];
}

@end
