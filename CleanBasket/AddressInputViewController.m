//
//  AddressInputViewController.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 3..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "AddressInputViewController.h"
#import <Realm/Realm.h>
#import "AFNetworking.h"
#import "CBConstants.h"
#import "UITextField+CleanBasket.h"
#import "DTOManager.h"
#import "MBProgressHUD.h"
#import "Address.h"

#define FieldHeight 35
#define FieldWidth 300
#define CenterX (DEVICE_WIDTH - FieldWidth)/2
#define FirstElementY 76
#define Interval 53
#define kOFFSET_FOR_KEYBOARD 80.0

@interface AddressInputViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    NSDictionary *viewProperty;
    NSDictionary *pickerAddressData;
    NSMutableArray *pickerCityKeys;
    NSMutableArray *pickerBoroughKeys;
    NSMutableArray *pickerDongKeys;
    UITextField *streetNumber;
    UITextField *buildingName;
    UITextField *remainder;
    NSString *fullAddress;
    UIPickerView *addrPickerView;
    DTOManager *dtoManager;
}

@end

@implementation AddressInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"주소입력"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    addrPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 162, DEVICE_WIDTH, 162)];
    [addrPickerView setDelegate:self];
    [addrPickerView setDataSource:self];
    
    streetNumber = [UITextField initWithCBTextField:self];
    [streetNumber setTag:0];
    [streetNumber setFrame:[self makeRect:streetNumber]];
    [streetNumber setPlaceholder:@"번지"];
    [streetNumber setReturnKeyType:UIReturnKeyNext];
    [streetNumber setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    buildingName = [UITextField initWithCBTextField:self];
    [buildingName setTag:1];
    [buildingName setFrame:[self makeRect:buildingName]];
    [buildingName setPlaceholder:@"건물명"];
    [buildingName setReturnKeyType:UIReturnKeyNext];
    
    remainder = [UITextField initWithCBTextField:self];
    [remainder setTag:2];
    [remainder setFrame:[self makeRect:remainder]];
    [remainder setPlaceholder:@"나머지 주소"];
    [remainder setReturnKeyType:UIReturnKeyDone];
    
    [self.view addSubview:addrPickerView];
    [self.view addSubview:streetNumber];
    [self.view addSubview:buildingName];
    [self.view addSubview:remainder];
    
    pickerAddressData = @{
                          @"성남" :
                              @{@"분당구" : @[@"구미동", @"구미1동", @"궁내동", @"금곡동", @"금곡동", @"대장동", @"동원동", @"백현동", @"분당동", @"삼평동", @"서현1동", @"서현2동", @"석운동", @"수내1동", @"수내2동", @"수내3동", @"야탑1동", @"야탑2동", @"야탑3동", @"운중동", @"율동", @"이매1동", @"이매2동", @"정자1동", @"정자2동", @"판교동", @"하산운동"]},
        
                          @"서울" :
                              @{@"강남구" : @[@"개포1동", @"개포2동", @"개포4동", @"개포동", @"논현1동", @"논현2동", @"논현동", @"대치1동", @"대치2동", @"대치4동", @"대치동", @"도곡1동", @"도곡2동", @"도곡동", @"삼성1동",
                                           @"삼성2동", @"삼성동", @"세곡동", @"수서동", @"신사동", @"압구정동", @"역삼1동", @"역삼2동",
                                           @"역삼동", @"율현동", @"일원1동", @"일원2동", @"일원동", @"일원본동", @"자곡동", @"청담동"],
                                @"관악구" : @[@"낙성대동", @"난곡동", @"난향동", @"남현동", @"대학동", @"미성동", @"보라매동", @"봉천동", @"삼성동",
                                           @"서림동", @"서원동", @"성현동", @"신림동", @"신사동", @"신원동", @"은천동", @"인헌동",
                                           @"조원동", @"중앙동", @"청룡동", @"청림동", @"행운동"],
                                @"동작구" : @[@"노량진1동", @"노량진2동", @"노량진동", @"대방동", @"동작동", @"본동", @"사당1동", @"사당2동",
                                           @"사당3동", @"사당4동", @"사당5동", @"사당동", @"상도1동", @"상도2동", @"상도3동",
                                           @"상도4동", @"상도동", @"신대방1동", @"신대방2동", @"신대방동", @"흑석"],
                                @"마포구" : @[@"공덕동", @"구수동", @"노고산동", @"당인동", @"대흥동", @"도화동", @"동교동", @"마포동", @"망원1동",
                                           @"망원2동", @"망원동", @"상수동", @"상암동", @"서교동", @"성산1동", @"성산2동", @"성산동",
                                           @"신공덕동", @"신수동", @"신정동", @"아현동", @"연남동", @"염리동", @"용강동", @"중동",
                                           @"창전동", @"토정동", @"하중동", @"합정동", @"현석동"],
                                @"서대문구" : @[@"연희동", @"신촌동", @"충현동", @"염리동", @"북아현동", @"아현동"],
                                @"서초구" : @[@"내곡동", @"반포1동", @"반포2동", @"반포4동", @"반포동", @"반포본동", @"방배1동", @"방배2동",
                                           @"방배3동", @"방배4동", @"방배동", @"방배본동", @"서초1동", @"서초2동", @"서초3동",
                                           @"서초4동", @"서초동", @"신원동", @"양재1동", @"양재2동", @"양재동", @"염곡동", @"우면동",
                                           @"원지동", @"잠원동"],
                                @"성동구" : @[@"금호동1가", @"금호동2가", @"금호동3가", @"금호동4가", @"도선동", @"마장동", @"사근동", @"상왕십리동",
                                           @"성수1가1동", @"성수1가2동", @"성수2가1동", @"성수2가3동", @"성수동1가", @"성수동2가",
                                           @"송정동", @"옥수동", @"왕십리2동", @"용답동", @"응봉동", @"하왕십리동", @"행당1동",
                                           @"행당2동", @"행당동", @"홍익"],
                                @"영등포구" : @[@"당산동", @"당산동1가", @"당산동2가", @"당산동3가", @"당산동4가", @"당산동5가", @"당산동6가",
                                            @"대림1동", @"대림2동", @"대림3동", @"대림동", @"도림동", @"문래동1가", @"문래동2가",
                                            @"문래동3가", @"문래동4가", @"문래동5가", @"문래동6가", @"신길1동", @"신길3동", @"신길4동",
                                            @"신길5동", @"신일6동", @"신길7동", @"신길동", @"양평동", @"양평동1가", @"양평동2가",
                                            @"양평동3가", @"양평동4가", @"양평동5가", @"양평동6가", @"양화동", @"여의도동", @"영등포동",
                                            @"영등포동1가", @"영등포동2가", @"영등포동3가", @"영등포동4가", @"영등포동5가", @"영등포동6가",
                                            @"영등포동7가", @"영등포동8가", @"영등포본동"],
                                @"용산구" : @[@"갈월동", @"남영동", @"도원동", @"동빙고동", @"동자동", @"문배동", @"보광동", @"산천동", @"서계동",
                                           @"서빙고동", @"신계동", @"신창동", @"용문동", @"용산동1가", @"용산동2가", @"용산동3가",
                                           @"용산동4가", @"용산동5가", @"용산동6가", @"원효로1가", @"원효로2가", @"원효로3가",
                                           @"원효로4가", @"이촌1동", @"이촌2동", @"이촌동", @"이태원1동", @"이태원2동", @"이태원동",
                                           @"주성동", @"청암동", @"청파동1가", @"청파동2가", @"청파동3가", @"한강로1가", @"한강로2가",
                                           @"한강로3가", @"한남동", @"효창동", @"후암동"],
                                @"중구" : @[@"광희동1가", @"광희동2가", @"남대문로1가", @"남대문로2가", @"남대문로3가", @"남대문로4가",
                                          @"남대문로5가", @"남산동1가", @"남산동2가", @"남산동3가", @"남창동", @"남학동", @"다동",
                                          @"만리동1가", @"만리동2가", @"명동1가", @"명동2가", @"무교동", @"무학동", @"묵정동",
                                          @"방산동", @"봉래동1가", @"봉래동2가", @"북창동", @"산림동", @"삼각동", @"서소문동",
                                          @"소공동", @"수표동", @"수하동", @"순화동", @"신당1동", @"신당2동", @"신당3동", @"신당4동",
                                          @"신당5동", @"신당6동", @"신당동", @"쌍림동", @"예관동", @"예장동", @"오장동", @"을지로1가",
                                          @"을지로2가", @"을지로3가", @"을지로4가", @"을지로5가", @"을지로6가", @"을지로7가",
                                          @"의주로1가", @"의주로2가", @"인현동1가", @"인현동2가", @"입정동", @"장교동", @"장충동1가",
                                          @"장충동2가", @"저동1가", @"저동2가", @"정동", @"주교동", @"주자동", @"중림동", @"초동",
                                          @"충무로1가", @"충무로2가", @"충무로3가", @"충무로4가", @"충무로5가", @"충정로1가",
                                          @"태평로1가", @"태평로2가", @"필동1가", @"필동2가", @"필동3가", @"황학동", @"회현동1가",
                                          @"회현동2가", @"회현동3가", @"흥인동"]}
                          };
    
    pickerCityKeys = [NSMutableArray arrayWithArray:[pickerAddressData allKeys]];
    pickerCityKeys = [NSMutableArray arrayWithArray:[pickerCityKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }]];
    
    pickerBoroughKeys = [NSMutableArray arrayWithArray:[[pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:0]] allKeys]];
    pickerBoroughKeys = [NSMutableArray arrayWithArray:[pickerBoroughKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }]];
    pickerDongKeys = [[pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:0]] valueForKey:[pickerBoroughKeys objectAtIndex:0]];
    
    [addrPickerView reloadAllComponents];
    [self makeFullAddress];
    
    UIButton* confirmButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 160)/2, DEVICE_HEIGHT - 80, 160, FieldHeight)];
    [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
    [confirmButton setTitleColor:CleanBasketRed forState:UIControlStateHighlighted];
    [confirmButton.layer setCornerRadius:15.0f];
    [confirmButton setBackgroundColor:CleanBasketMint];
    [confirmButton addTarget:self action:@selector(confirmButtonDidTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:confirmButton];
    
    NSLog(@"%@", self.currentAddress);
    if (self.currentAddress) {
        NSLog(@"CURRENT ADDRESS EXISTS!");
        [streetNumber setText:[self.currentAddress addr_number]];
        [buildingName setText:[self.currentAddress addr_building]];
        [remainder setText:[self.currentAddress addr_remainder]];
    }
}

- (void) confirmButtonDidTouched {
    if (self.updateAddress) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES labelText:@"주소 업데이트 중:)"];
        NSDictionary *data = @{@"type":[NSNumber numberWithInt:[self.currentAddress type]],
                               @"address":fullAddress,
                               @"addr_number":[streetNumber text],
                               @"addr_building":[buildingName text],
                               @"addr_remainder":[remainder text]
                               };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
            afManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [afManager POST:@"https://www.cleanbasket.co.kr/member/address/update" parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                int constant = [[responseObject valueForKey:@"constant"] intValue];
                switch (constant) {
                        // 주소 업데이트 성공
                    case CBServerConstantSuccess: {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            
                            RLMRealm *realm = [RLMRealm defaultRealm];
                            [realm beginWriteTransaction];
                            [self.currentAddress setAddress:fullAddress];
                            [self.currentAddress setAddr_number:[streetNumber text]];
                            [self.currentAddress setAddr_building:[buildingName text]];
                            [self.currentAddress setAddr_remainder:[remainder text]];
                            [realm commitWriteTransaction];
                            [self showHudMessage:@"주소 업데이트 성공!" afterDelay:1];
                            NSLog(@"[CURRENT ADDRESS] %@", self.currentAddress);
                            [self performSelector:@selector(popViewController) withObject:self afterDelay:1];
                        });
                    }
                        
                        break;
                        
                        // 오류 발생
                    case CBServerConstantError: {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self showHudMessage:@"서버 오류가 발생했습니다.\n다시 시도해주세요." afterDelay:2];
                        });
                    }
                        break;
                        
                        // 세션 만료 시, 로그인 화면으로 돌아감
                    case CBServerConstantSessionExpired: {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self showHudMessage:@"세션이 만료되어 로그인 화면으로 돌아갑니다." afterDelay:2];
                            //AppDelegate에 세션이 만료됨을 알림
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
                        });
                    }
                        break;
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showHudMessage:@"네트워크 상태를 확인해주세요." afterDelay:2];
                    NSLog(@"%@", error);
                });
            }];
            
        });
    }
    
    else {
        Address *newAddress = [[Address alloc] init];
        [newAddress setAddress:fullAddress];
        [newAddress setAddr_number:[streetNumber text]];
        [newAddress setAddr_building:[buildingName text]];
        [newAddress setAddr_remainder:[remainder text]];
        
        // EmailSignUpViewController로 사용자가 작성한 Address를 전송한다.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressCreated" object:self userInfo:[NSDictionary dictionaryWithObject:newAddress forKey:@"data"]];
        [streetNumber setText:@""];
        [buildingName setText:@""];
        [remainder setText:@""];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    switch (component) {
//        case 0:
//            return [pickerCityKeys objectAtIndex:row];
//            break;
//        case 1:
//            return [pickerBoroughKeys objectAtIndex:row];
//            break;
//        case 2:
//            return [pickerDongKeys objectAtIndex:row];
//            break;
//        default:
//            break;
//    }
//    return @"";
//    
//    //    switch (component) {
//    //        case 0:
//    //            [tView setText:[pickerCityKeys objectAtIndex:row]];
//    //            break;
//    //        case 1:
//    //            [tView setText:[pickerBoroughKeys objectAtIndex:row]];
//    //            break;
//    //        case 2:
//    //            [tView setText:[pickerDongKeys objectAtIndex:row]];
//    //            break;
//    //        default:
//    //            break;
//    //    }
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        [tView setAdjustsFontSizeToFitWidth:YES];
        [tView setTextAlignment:NSTextAlignmentCenter];
    }
    
    switch (component) {
        case 0:
            [tView setText:[pickerCityKeys objectAtIndex:row]];
            break;
        case 1:
            [tView setText:[pickerBoroughKeys objectAtIndex:row]];
            break;
        case 2:
            [tView setText:[pickerDongKeys objectAtIndex:row]];
            break;
        default:
            break;
    }
    
    return tView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [pickerCityKeys count];
//            return (pickerCityKeys ? [pickerCityKeys count] : 1);
            break;
        case 1:
            return [pickerBoroughKeys count];
//            return (pickerBoroughKeys ? 9 : 1);
            break;
        case 2:
            return [pickerDongKeys count];
            break;
    }
    return 1;
}

// - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view 로 인해 구현 필요 없음
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return (pickerCityKeys ? pickerCityKeys[row] : @"시");
            break;
        case 1:
            return (pickerBoroughKeys ? pickerBoroughKeys[row] : @"구");
            break;
        case 2:
            return (pickerDongKeys ? pickerDongKeys[row] : @"동");
            break;
    }
    return @"오류";
}
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
//    if (component == 0) {
//        pickerBoroughKeys = [pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:[pickerView selectedRowInComponent:0]]];
//        [pickerView reloadAllComponents];
//    }
//    
//
    
    switch (component) {
        case 0:
            pickerBoroughKeys = [NSMutableArray arrayWithArray:[[pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:[pickerView selectedRowInComponent:0]]] allKeys]];
            pickerBoroughKeys = [NSMutableArray arrayWithArray:[pickerBoroughKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 localizedCaseInsensitiveCompare:obj2];
            }]];
            pickerDongKeys = [[pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:[pickerView selectedRowInComponent:0]]] valueForKey:[pickerBoroughKeys objectAtIndex:0]];
            
            [pickerView reloadAllComponents];
            break;
        case 1:
            pickerDongKeys = [[pickerAddressData valueForKey:[pickerCityKeys objectAtIndex:[pickerView selectedRowInComponent:0]]] valueForKey:[pickerBoroughKeys objectAtIndex:[pickerView selectedRowInComponent:1]]];
            
            [pickerView reloadAllComponents];
            break;
    }
    [self makeFullAddress]; 
}

- (CGRect) makeRect: (UIView*)view {
    return CGRectMake(CenterX, FirstElementY + Interval * [view tag], FieldWidth, FieldHeight);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
        [streetNumber setText:@""];
        [buildingName setText:@""];
        [remainder setText:@""];
        [self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}

- (void)makeFullAddress {
    fullAddress = @"";
    if (pickerCityKeys[[addrPickerView selectedRowInComponent:0]] != nil && [pickerBoroughKeys objectAtIndex:[addrPickerView selectedRowInComponent:1]] != nil && [pickerDongKeys objectAtIndex:[addrPickerView selectedRowInComponent:2]] != nil) {
        fullAddress = [fullAddress stringByAppendingString:pickerCityKeys[[addrPickerView selectedRowInComponent:0]]];
        fullAddress = [fullAddress stringByAppendingString:@" "];
        fullAddress = [fullAddress stringByAppendingString:[pickerBoroughKeys objectAtIndex:[addrPickerView selectedRowInComponent:1]]];
        fullAddress = [fullAddress stringByAppendingString:@" "];
        fullAddress = [fullAddress stringByAppendingString:[pickerDongKeys objectAtIndex:[addrPickerView selectedRowInComponent:2]]];
        //        NSLog(@"%@", fullAddress);
    } else {
        return;
    }
}

- (void) showHudMessage:(NSString*)message afterDelay:(int)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES labelText:message    ];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    [hud setLabelFont:[UIFont systemFontOfSize:14.0f]];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:delay];
    return;
}

- (void) popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
