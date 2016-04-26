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
    
    NSDictionary *AllSeoulDongs =  @{
                                     @"성남시" :
                                         @{@"분당구" : @[@"구미동", @"구미1동", @"궁내동", @"금곡동", @"금곡동", @"대장동", @"동원동", @"백현동", @"분당동", @"삼평동", @"서현1동", @"서현2동", @"석운동", @"수내1동", @"수내2동", @"수내3동", @"야탑1동", @"야탑2동", @"야탑3동", @"운중동", @"율동", @"이매1동", @"이매2동", @"정자1동", @"정자2동", @"판교동", @"하산운동"]},
                                     
                                     @"서울특별시" :
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
                                           @"서대문구" : @[@"연희동", @"신촌동", @"충현동",@"창천동",@"염리동", @"북아현동", @"아현동"],
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
    
    
    if (isSupportAddress) {
        
        NSString *alertMessgae = [NSString stringWithFormat:@"%@",cellString];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"input_detail_address_title", nil) message:alertMessgae delegate:self cancelButtonTitle:NSLocalizedString(@"label_cancel", nil) otherButtonTitles:NSLocalizedString(@"label_confirm", nil), nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"input_detail_address", nil)];
        
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
        
        // 나머지 주소 입력
        NSString *remainder = [alertView textFieldAtIndex:0].text;
        if([remainder isEqualToString:@""]){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"remainder_error",nil)];
        }else {
            [self updateAddress:alertView.message remainder:remainder];
            [SVProgressHUD show];
        }
        
    }
    
}

#pragma mark -
#pragma mark API
// 사용자 정보 가지고 오는 로직
// GET
- (void)getAddress{

    // AFHTTP 관련
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    
    // 주소 업데이트 URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"district"];
    [manager GET:urlString
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



// 사용자 주소 정보 업데이트 하는 로직
// POST
- (void)updateAddress:(NSString*)address remainder:(NSString*)remainder{


    // AFHTTP 관련
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];


    // 주소 업데이트 Dictionary
    NSDictionary *parameters = @{@"address":address,
                                 @"addr_building":remainder};

    // 주소 업데이트 URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",CB_SERVER_URL,@"member/address/update"];
    [manager POST:urlString
       parameters:parameters

          success:^(AFHTTPRequestOperation *operation, id responseObject) {

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
