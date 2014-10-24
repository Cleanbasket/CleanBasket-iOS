//
//  ServiceInfoViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "ServiceInfoViewController.h"
#import "CBConstants.h"
#import "UILabel+FormattedText.h"
#import "DTOManager.h"
#import "User.h"

static const float ARC4RANDOM_MAX = 0x100000000;
static const CGFloat kLeftMargin = 10;
static const float kTitleFontSize = 17.0f;
static const CGFloat kLabelWidth = 300.0f;
static const CGFloat kButtonWidth = 80.0f;

@interface ServiceInfoViewController () {
    UIScrollView *mainScrollView;
    UILabel *accountInfoLabel;
}

@end

@implementation ServiceInfoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *tabBarImage = [UIImage imageNamed:@"tab_service.png"];
        UIImage *tabBarImage2 = [UIImage imageNamed:@"tab_service_after.png"];
        self.tabBarItem = [self.tabBarItem initWithTitle:@"서비스 정보" image:tabBarImage selectedImage:tabBarImage2];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    accountInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, 40)];
    [accountInfoLabel setTextColor:[UIColor whiteColor]];
    [accountInfoLabel setBackgroundColor:[CleanBasketMint colorWithAlphaComponent:0.8]];
    [accountInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [accountInfoLabel setAdjustsFontSizeToFitWidth:YES];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 104, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    [mainScrollView setContentSize:CGSizeMake(DEVICE_WIDTH, 1230)];
    
    UILabel *firstInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 10, kLabelWidth, 55)];
    [firstInfoLabel setText:@"CLEAN BASKET은 앱과 홈페이지를 통해 집에서 세탁물을 맡기고 찾을 수 있는 신개념 온라인 세탁 수거배달 서비스입니다."];
    [self setLabelForService:firstInfoLabel];
    [firstInfoLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 12)];
    [firstInfoLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 12)];
    
    UILabel *easyWashLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 85, kLabelWidth, 90)];
    [self setLabelForService:easyWashLabel];
    [easyWashLabel setText:@"언제 어디서나 쉽고 편하게 세탁하자!\n\n오전10시부터 밤 12시 반까지, 세탁이 필요하다면 CLEAN BASKET이 방문합니다. 더 이상 세탁소를 찾아가지 마세요!"];
    [easyWashLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 20)];
    [easyWashLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 20)];
    [easyWashLabel setTextColor:CleanBasketMint afterOccurenceOfString:@"면"];
    [easyWashLabel setTextColor:[UIColor grayColor] afterOccurenceOfString:@"T"];
    
    UILabel *cheapHighLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 195, kLabelWidth, 80)];
    [self setLabelForService:cheapHighLabel];
    [cheapHighLabel setText:@"저렴한 세탁 요금과 뛰어난 세탁 품질!\n\n정찰제라서 더욱 확실한 세탁요금과 호텔 세탁 서비스 수준의 세탁 품질을 느껴보세요!"];
    [cheapHighLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 21)];
    [cheapHighLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 21)];
    
    UILabel *reliableLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 290, kLabelWidth, 91)];
    [self setLabelForService:reliableLabel];
    [reliableLabel setText:@"확실한 서비스,\n믿을 수 있는 CLEAN BASKET!\n\n고객님의 소중한 세탁물 보호를 위해 CLEAN BASKET은 세탁업 표준약관을 준수합니다."];
    [reliableLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 30)];
    [reliableLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 29)];
    [reliableLabel setTextColor:CleanBasketMint range:NSMakeRange(52, 12)];
    
    UILabel *howToUseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, DEVICE_WIDTH, 50)];
    [howToUseLabel setBackgroundColor:UltraLightGray];
    [howToUseLabel setTextColor:CleanBasketMint];
    [howToUseLabel setText:@"이용방법"];
    [howToUseLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [howToUseLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *useOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 460, kLabelWidth, 110)];
    [self setLabelForService:useOrderLabel];
    [useOrderLabel setText:@"주문하기\n  1. '주문하기'에 주문서 작성\n  2. '품목선택'을 통해 세탁품목들 선택\n  3. 주문확정!\n  4. 설정한 시간에 CLEAN BASKET이 방문, 세탁물 수거 및 배달"];
    [useOrderLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 4)];
    [useOrderLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 4)];
    [useOrderLabel setTextColor:CleanBasketMint range:NSMakeRange(74, 12)];
    
    UILabel *cancelOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 590, kLabelWidth, 90)];
    [self setLabelForService:cancelOrderLabel];
    [cancelOrderLabel setText:@"주문취소/변경하기\n  1.세탁물 수거 이전\n      - '진행상태 - 주문내역' 화면에서 주문 취소\n  2. 세탁물 수거 이후\n      - 'E-mail 또는 전화를 통해 주문 취소 및 변경" ];
    [cancelOrderLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 9)];
    [cancelOrderLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 9)];
    
    UILabel *payOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 700, kLabelWidth, 110)];
    [self setLabelForService:payOrderLabel];
    [payOrderLabel setText:@"결제하기\n  1. 세탁물 수거를 위해 방문하는 매니저를 통해 세탁 요금 결제 (카드 결제만 가능)\n  2. 추가 세탁으로 인해 발생하는 비용은 세탁 전 협의 후 결정"];
    [payOrderLabel setTextColor:CleanBasketMint range:NSMakeRange(0, 4)];
    [payOrderLabel setFont:[UIFont systemFontOfSize:kTitleFontSize] range:NSMakeRange(0, 4)];
    [self getFitSize:payOrderLabel];
    
    UILabel *qnaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 830, DEVICE_WIDTH, 50)];
    [qnaLabel setBackgroundColor:UltraLightGray];
    [qnaLabel setTextColor:CleanBasketMint];
    [qnaLabel setText:@"이용문의"];
    [qnaLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [qnaLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIButton *contactButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 240)/4, 910, kButtonWidth, 40)];
    [contactButton addTarget:self action:@selector(makeCallCleanbasket) forControlEvents:UIControlEventTouchUpInside];
    [contactButton setTitle:@"전화하기" forState:UIControlStateNormal];
    [contactButton setBackgroundColor:CleanBasketMint];
    [contactButton.layer setCornerRadius:10.0f];
//    [contactButton setBackgroundColor:[UIColor blackColor]];
    
    UIButton *emailButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 240)/4*2 + kButtonWidth, 910, kButtonWidth, 40)];
    [emailButton setTitle:@"이메일" forState:UIControlStateNormal];
    [emailButton setBackgroundColor:CleanBasketMint];
    [emailButton.layer setCornerRadius:10.0f];
    [emailButton addTarget:self action:@selector(makeEmailCleanbasket) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *homepageButton = [[UIButton alloc] initWithFrame:CGRectMake(kButtonWidth*2 + (DEVICE_WIDTH-240)/4*3, 910, kButtonWidth, 40)];
    [homepageButton setTitle:@"홈페이지" forState:UIControlStateNormal];
    [homepageButton setBackgroundColor:CleanBasketMint];
    [homepageButton.layer setCornerRadius:10.0f];
    [homepageButton addTarget:self action:@selector(makeHomepageCleanbasket) forControlEvents:UIControlEventTouchUpInside];
    
//    UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 900, kLabelWidth, 60)];
//    [self setLabelForService:contactLabel];
//    [contactLabel setText:@"E-mail: help@cleanbasket.co.kr\nTel: 070-7552-1385\nHomepage: http://www.cleanbasket.co.kr"];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_launcher.png"]];
    [logoImageView setFrame:CGRectMake(40, 1000, 80, 80)];
    [logoImageView setContentMode:UIViewContentModeScaleToFill];
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *versionString = @"현재 버전: ";
    versionString = [versionString stringByAppendingString:appVersionString];
    versionString = [versionString stringByAppendingString:@"\n\n최신 버전: 1.0"];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 1000, 120, 80)];
    [versionLabel setTextAlignment:NSTextAlignmentLeft];
    [versionLabel setTextColor:[UIColor grayColor]];
    [versionLabel setText:versionString];
    [versionLabel setNumberOfLines:0];
    
    [mainScrollView addSubview:versionLabel];
    [mainScrollView addSubview:logoImageView];
    [mainScrollView addSubview:howToUseLabel];
    [mainScrollView addSubview:qnaLabel];
    [mainScrollView addSubview:contactButton];
    [mainScrollView addSubview:emailButton];
    [mainScrollView addSubview:homepageButton];
    [self.view addSubview:mainScrollView];
    [self.view addSubview:accountInfoLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    DTOManager *dtoManager = [DTOManager defaultManager];
    User *currentUser = [dtoManager currentUser];
    NSString *accountString = @"안녕하세요, ";
    accountString = [accountString stringByAppendingString:[currentUser email]];
    accountString = [accountString stringByAppendingString:@" 님:)"];
    [accountInfoLabel setText:accountString];
}

- (void)makeCallCleanbasket {
    NSString *phoneNumber = @"tel://070-7552-1385";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void) makeEmailCleanbasket {
    NSString *emailAddress = @"mailto://help@cleanbasket.co.kr";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddress]];
}

- (void) makeHomepageCleanbasket {
    NSString *homepageAddress = @"http://cleanbasket.co.kr/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:homepageAddress]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setBorderVisible:(UIView*)view {
    [view.layer setBorderWidth:1.0f];
    [view.layer setBorderColor:[UIColor colorWithRed:((double)arc4random() / ARC4RANDOM_MAX) green:((double)arc4random() / ARC4RANDOM_MAX) blue:((double)arc4random() / ARC4RANDOM_MAX) alpha:1].CGColor];
}

- (void)getFitSize:(UILabel*)label {
    CGSize maxSize = CGSizeMake(kLabelWidth, FLT_MAX);
    CGSize fitSize = [label sizeThatFits:maxSize];
    NSLog(@"%f %f", fitSize.width, fitSize.height);
}

- (void) setLabelForService:(UILabel*)label {
    [label setTextColor:[UIColor grayColor]];
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [mainScrollView addSubview:label];
//    [self setBorderVisible:label];
}



@end
