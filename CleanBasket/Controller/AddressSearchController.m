//
//  AddressSearchController.m
//  CleanBasket
//
//  Created by 이상진 on 2016. 1. 5..
//  Copyright © 2016년 WashappKorea. All rights reserved.
//

#import "AddressSearchController.h"
#import "CBConstants.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AddressSearchController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL isFiltered;

@end

@implementation AddressSearchController


NSMutableArray *searchResult, *allAddress, *supportAddress, *supportAllDongsAddress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchResult = [NSMutableArray new];
    allAddress = [NSMutableArray new];
    supportAddress = [NSMutableArray new];
    supportAllDongsAddress = [NSMutableArray new];
    _isFiltered = NO;


    [self getAddress];
    
    NSDictionary *AllSeoulDongs = @{
            @"서울특별시" :
            @{@"강남구" : @[@"개포1동", @"개포2동", @"개포4동", @"개포동", @"논현1동", @"논현2동", @"논현동", @"대치1동", @"대치2동", @"대치4동", @"대치동", @"도곡1동", @"도곡2동", @"도곡동", @"삼성1동",
                    @"삼성2동", @"삼성동", @"세곡동", @"수서동", @"신사동", @"압구정동", @"역삼1동", @"역삼2동",
                    @"역삼동", @"율현동", @"일원1동", @"일원2동", @"일원동", @"일원본동", @"자곡동", @"청담동"],
                    @"강동구" : @[@"강일동", @"고덕1동", @"고덕2동", @"길동", @"둔촌1동", @"둔촌2동", @"둔촌동", @"명일1동",
                    @"명일2동", @"명일동", @"상일동", @"성내1동", @"성내2동", @"성내3동", @"성내동",
                    @"암사1동", @"암사2동", @"암사3동", @"암사동", @"천호1동", @"천호2동", @"천호3동",
                    @"천호동"],
                    @"강북구" : @[@"미아동", @"번1동", @"번2동", @"번3동", @"번동", @"삼각산동", @"상암동", @"송중동", @"송천동",
                    @"수유1동", @"수유2동", @"수유3동", @"수유동", @"우이동", @"인수동"],
                    @"강서구" : @[@"가양1동", @"가양2동", @"가양3동", @"가양동", @"개화동", @"공항동", @"과해동", @"내발산동",
                    @"등촌1동", @"등촌2동", @"등촌3동", @"등촌동", @"마곡동", @"방화1동", @"방화2동",
                    @"방화3동", @"방화동", @"염창동", @"오곡동", @"오쇠동", @"외발산동", @"우장사동", @"화곡1동",
                    @"화곡2동", @"화곡3동", @"화곡4동", @"화곡6동", @"화곡8동", @"화곡동", @"화곡본동"],
                    @"관악구" : @[@"낙성대동", @"난곡동", @"난향동", @"남현동", @"대학동", @"미성동", @"보라매동", @"봉천동", @"삼성동",
                    @"서림동", @"서원동", @"성현동", @"신림동", @"신사동", @"신원동", @"은천동", @"인헌동",
                    @"조원동", @"중앙동", @"청룡동", @"청림동", @"행운동"],
                    @"광진구" : @[@"광장동", @"구의1동", @"구의2동", @"구의3동", @"구의동", @"군자동", @"능동", @"자양1동",
                    @"자양2동", @"자양3동", @"자양4동", @"자양동", @"중곡1동", @"중곡2동", @"중곡3동",
                    @"중곡4동", @"중곡동", @"화양"],
                    @"구로구" : @[@"가리봉동", @"개봉1동", @"개봉2동", @"개봉3동", @"개봉동", @"고척1동", @"고척2동", @"고척동",
                    @"구로1동", @"구로2동", @"구로3동", @"구로4동", @"구로5동", @"구로동", @"궁동",
                    @"신도림동", @"오류1동", @"오류2동", @"오류동", @"온수동", @"천왕동", @"항동"],
                    @"금천구" : @[@"가산동", @"독산1동", @"독산2동", @"독산3동", @"독산4동", @"독산동", @"시흥1동", @"시흥2동",
                    @"시흥3동", @"시흥4동", @"시흥5동", @"시흥"],
                    @"노원구" : @[@"공릉1동", @"공릉2동", @"공릉동", @"상계10동", @"상계1동", @"상계2동", @"상게3.4동", @"상계5동",
                    @"상계6.7동", @"상계8동", @"상계9동", @"상계동", @"월계1동", @"월계2동", @"월계3동",
                    @"월계동", @"중계1동", @"중계2.3동", @"중계4동", @"중계동", @"중계본동", @"하계1동",
                    @"하계2동", @"하계동"],
                    @"도봉구" : @[@"도봉1동", @"도봉2동", @"도봉동", @"방학1동", @"방학2동", @"방학3동", @"방학동", @"쌍문1동",
                    @"쌍문2동", @"쌍문3동", @"쌍문4동", @"쌍문동", @"창1동", @"창2동", @"창3동", @"창4동",
                    @"창5동", @"창동"],
                    @"동대문구" : @[@"답십리1동", @"답십리2동", @"답십리동", @"신설동", @"용두동", @"이문1동", @"이문2동", @"이문동",
                    @"장안1동", @"장안2동", @"장안동", @"전농1동", @"전농2동", @"전농동", @"제기동",
                    @"청량리동", @"회기동", @"휘경1동", @"휘경2동", @"휘경"],
                    @"동작구" : @[@"노량진1동", @"노량진2동", @"노량진동", @"대방동", @"동작동", @"본동", @"사당1동", @"사당2동",
                    @"사당3동", @"사당4동", @"사당5동", @"사당동", @"상도1동", @"상도2동", @"상도3동",
                    @"상도4동", @"상도동", @"신대방1동", @"신대방2동", @"신대방동", @"흑석"],
                    @"마포구" : @[@"공덕동", @"구수동", @"노고산동", @"당인동", @"대흥동", @"도화동", @"동교동", @"마포동", @"망원1동",
                    @"망원2동", @"망원동", @"상수동", @"상암동", @"서교동", @"성산1동", @"성산2동", @"성산동",
                    @"신공덕동", @"신수동", @"신정동", @"아현동", @"연남동", @"염리동", @"용강동", @"중동",
                    @"창전동", @"토정동", @"하중동", @"합정동", @"현석동"],
                    @"서대문구" : @[@"남가좌1동", @"남가좌2동", @"남가좌동", @"냉천동", @"대신동", @"대현동", @"미근동", @"봉원동",
                    @"북가좌1동", @"북가좌2동", @"북가좌동", @"북아현동", @"신촌동", @"연희동", @"영천동",
                    @"옥천동", @"창천동", @"천연동", @"충정로2가", @"충정로3가", @"합동", @"현저동", @"홍은1동",
                    @"홍은2동", @"홍은동", @"홍제1동", @"홍제2동", @"홍제3동", @"홍제동"],
                    @"서초구" : @[@"내곡동", @"반포1동", @"반포2동", @"반포4동", @"반포동", @"반포본동", @"방배1동", @"방배2동",
                    @"방배3동", @"방배4동", @"방배동", @"방배본동", @"서초1동", @"서초2동", @"서초3동",
                    @"서초4동", @"서초동", @"신원동", @"양재1동", @"양재2동", @"양재동", @"염곡동", @"우면동",
                    @"원지동", @"잠원동"],
                    @"성동구" : @[@"금호동1가", @"금호동2가", @"금호동3가", @"금호동4가", @"도선동", @"마장동", @"사근동", @"상왕십리동",
                    @"성수1가1동", @"성수1가2동", @"성수2가1동", @"성수2가3동", @"성수동1가", @"성수동2가",
                    @"송정동", @"옥수동", @"왕십리2동", @"용답동", @"응봉동", @"하왕십리동", @"행당1동",
                    @"행당2동", @"행당동", @"홍익"],
                    @"성북구" : @[@"길음1동", @"길음2동", @"길음동", @"돈암1동", @"돈암2동", @"돈암동", @"동선동1가", @"동선동2가",
                    @"동선동3가", @"동선동4가", @"동선동5가", @"동소문동1가", @"동소문동2가", @"동소문동3가",
                    @"동소문동4가", @"동소문동5가", @"동소문동6가", @"동소문동7가", @"보문동1가", @"보문동2가",
                    @"보문동3가", @"보문동4가", @"보문동5가", @"보문동6가", @"보문동7가", @"삼선동1가",
                    @"삼선동2가", @"삼선동3가", @"삼선동4가", @"삼선동5가", @"상월곡동", @"석관동", @"성북동",
                    @"성북동1가", @"안암동1가", @"안암동2가", @"안암동3가", @"안암동4가", @"안암동5가",
                    @"월곡1동", @"월곡2동", @"장위1동", @"장위2동", @"장위3동", @"장위동", @"정릉1동",
                    @"정릉2동", @"정릉3동", @"정릉4동", @"정릉동", @"종암동", @"하월곡동"],
                    @"송파구" : @[@"가락1동", @"가락2동", @"가락동", @"가락본동", @"거여1동", @"거여2동", @"거여동", @"마천1동",
                    @"마천2동", @"마천동", @"문정1동", @"문정2동", @"문정동", @"방이1동", @"방이2동",
                    @"방이동", @"삼전동", @"석촌동", @"송파1동", @"송파2동", @"송파동", @"신천동", @"오금동",
                    @"오륜동", @"잠실2동", @"잠실3동", @"잠실4동", @"잠실6동", @"잠실7동", @"잠실동",
                    @"잠실본동", @"장지동", @"풍납1동", @"푼납2동", @"풍납동"],
                    @"양천구" : @[@"목1동", @"목2동", @"목3동", @"목4동", @"목5동", @"목동", @"신월1동", @"신월2동", @"신월3동",
                    @"신월4동", @"신월5동", @"신월6동", @"신월7동", @"신월동", @"신정1동", @"신정2동",
                    @"신정3동", @"신정4동", @"신정6동", @"신정7동", @"신정"],
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
                    @"은평구" : @[@"갈현1동", @"갈현2동", @"갈현동", @"구산동", @"녹번동", @"대조동", @"불광1동", @"불광2동",
                    @"불광동", @"수색동", @"신사1동", @"신사2동", @"신사동", @"역촌동", @"응암1동", @"응암2동",
                    @"응암3동", @"응암동", @"증산동", @"진관동"],
                    @"종로구" : @[@"가회동", @"견지동", @"경운동", @"계동", @"공평동", @"관수동", @"관철동", @"관훈동", @"교남동",
                    @"교북동", @"구기동", @"궁정동", @"권농동", @"낙원동", @"내수동", @"내자동", @"누상동",
                    @"누하동", @"당주동", @"도렴동", @"돈의동", @"동승동", @"명륜1가", @"명륜2가", @"명륜3가",
                    @"명륜4가", @"묘동", @"무악동", @"봉익동", @"부암동", @"사간동", @"사직동", @"삼청동",
                    @"서린동", @"세종로", @"소격동", @"송월동", @"송현동", @"수송동", @"숭인1동", @"숭인2동",
                    @"숭인동", @"신교동", @"신문로1가", @"신문로2가", @"신영동", @"안국동", @"연건동", @"연지동",
                    @"예지동", @"옥인동", @"와룡동", @"운니동", @"원남동", @"원서동", @"이화동", @"익선동",
                    @"인사동", @"인의동", @"장사동", @"재동", @"적선동", @"종로1가", @"종로2가", @"종로3가",
                    @"종로4가", @"종로5가", @"종로6가", @"중학동", @"창성동", @"창신1동", @"창신2동",
                    @"창신3동", @"창신동", @"청운동", @"청진동", @"체부동", @"충신동", @"통의동", @"통인동",
                    @"팔판동", @"평동", @"평창동", @"필운동", @"행촌동", @"혜화동", @"홍지동", @"홍파동",
                    @"화동", @"효자동", @"효제동", @"훈정동"],
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
                    @"회현동2가", @"회현동3가", @"흥인동"],
                    @"중랑구" : @[@"망우3동", @"망우동", @"망우본동", @"면목2동", @"면목3.8동", @"면목4동", @"면목5동", @"면목7동",
                    @"면목동", @"면목본동", @"묵1동", @"묵2동", @"묵동", @"상봉1동", @"상봉2동", @"상봉동",
                    @"신내1동", @"신내2동", @"신내동", @"중화1동", @"중화2동", @"중화동"]}
    };



    for (id city in AllSeoulDongs){
        for (id district in AllSeoulDongs[city]){
            for (id dong in AllSeoulDongs[city][district]){
                
                NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@",city,district,dong];
                [allAddress addObject:addressString];
            }
        }

    }

}

- (IBAction)dismissThisVC:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (_isFiltered){
        return searchResult.count;
    }

    return allAddress.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    NSString *address;


    if (_isFiltered){
        address = searchResult[indexPath.row];
    } else {
        address = allAddress[indexPath.row];
    }

    
    [cell.textLabel setText:address];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *cellString = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    BOOL isSupportAddress = NO;
    
    @try {
        for (NSDictionary *data in supportAddress) {
            
            NSRange addressRange = [cellString rangeOfString:data[@"dong"]];
            if (addressRange.location != NSNotFound) {
                isSupportAddress = YES;
                break;
            }
            else {
                
                for (NSDictionary *allDongData in supportAllDongsAddress) {
                    
                    NSRange addressRange2 = [cellString rangeOfString:allDongData[@"district"]];
                    
                    if (addressRange2.location != NSNotFound) {
                        isSupportAddress = YES;
                        @throw [NSException exceptionWithName:@"Support Addres" reason:@"This address is support address." userInfo:nil];
                    }
                    
                }
                
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    
    
    NSLog(@"%@",isSupportAddress?@"Y":@"N");
    
    if (isSupportAddress) {
        
        NSString *alertMessgae = [NSString stringWithFormat:@"%@",cellString];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"나머지 상세 주소를 입력해주세요" message:alertMessgae delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setPlaceholder:@"상세 주소 입력"];
        
        [alert show];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"area_unavailable_error",nil)];
    }
    
    
}

#pragma mark -
#pragma mark SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {


    [searchBar resignFirstResponder];


    
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if (searchText.length){
        _isFiltered = YES;
        
        [searchResult removeAllObjects];
        
        for (NSString *address in allAddress){
            
            NSRange addressRange = [address rangeOfString:searchText];
            
            if (addressRange.location != NSNotFound) {
                [searchResult addObject:address];
                
            }
            
        }

    } else{
        _isFiltered = NO;

    }
    
    [self.tableView reloadData];

}


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSString *remainder = [alertView textFieldAtIndex:0].text;
        [self updateAddress:alertView.message remainder:remainder];
        [SVProgressHUD show];
        
    }
    
}

#pragma mark -
#pragma mark API
- (void)getAddress{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    [manager GET:@"http://52.79.39.100:8080/district"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSError *jsonError;
             NSData *objectData = [responseObject[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *datas = [NSJSONSerialization JSONObjectWithData:objectData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&jsonError];

             for (NSDictionary *data in datas){
                 
                 if ([data[@"dong"] isEqualToString:@""]) {
                     
                     [supportAllDongsAddress addObject:data];
                 }
                 else {
                     
                     [supportAddress addObject:data];
                 }
             }


             [_tableView reloadData];


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}

- (void)updateAddress:(NSString*)address remainder:(NSString*)remainder{


    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];


    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];



    NSDictionary *parameters = @{@"address":address,
                                 @"addr_remainder":remainder
    };
    NSLog(@"remainder : %@",remainder);


    [manager POST:@"http://52.79.39.100:8080/member/address/update"
       parameters:parameters

          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              NSLog(@"%@",responseObject);

              NSLog(@"결과: %@", [NSString stringWithUTF8String:[responseObject[@"message"] UTF8String]]);

              if ([responseObject[@"constant"] integerValue] == CBServerConstantSuccess) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishEditAddress" object:nil];

                  [self dismissThisVC:nil];
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"action_done",nil)];
              }


          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];

}


@end
