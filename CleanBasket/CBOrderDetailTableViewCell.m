//
//  CBOrderDetailTableViewCell.m
//  CleanBasket
//
//  Created by Wonhyo Yi on 2014. 10. 21..
//  Copyright (c) 2014년 WashAppKorea. All rights reserved.
//

#import "CBOrderDetailTableViewCell.h"
#import "CBConstants.h"
#define X_FIRST 10
#define X_SECOND X_FIRST + WIDTH_FIRST + X_MARGIN
#define X_CENTER_DEVICE (DEVICE_WIDTH - WIDTH_REGULAR)/2
#define Y_FIRST 10
#define X_MARGIN 10
#define WIDTH_FIRST 70
#define WIDTH_SECOND 220
#define HEIGHT_REGULAR 25
#define MARGIN_REGULAR 35
#define IMAGE_SIZE 70

@implementation CBOrderDetailTableViewCell


- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		NSLog(@"Init!");
		[self setBackgroundColor:UltraLightGray];
		
		_orderNumberLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:0]];
		[_orderNumberLabel setText:@"주문번호"];
		[_orderNumberLabel setTextColor:CleanBasketMint];
		_orderNumberValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:0]];
		[_orderNumberValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderPriceLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:1]];
		[_orderPriceLabel setText:@"주문가격"];
		[_orderPriceLabel setTextColor:CleanBasketMint];
		_orderPriceValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:1]];
		[_orderPriceValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderItemsLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:2]];
		[_orderItemsLabel setText:@"주문품목"];
		[_orderItemsLabel setTextColor:CleanBasketMint];
		_orderItemsValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:2]];
		[_orderItemsValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderStatusLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:3]];
		[_orderStatusLabel setText:@"진행상태"];
		[_orderStatusLabel setTextColor:CleanBasketMint];
		_orderStatusValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:3]];
		[_orderStatusValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderPickupLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:4]];
		[_orderPickupLabel setText:@"수거일자"];
		[_orderPickupLabel setTextColor:CleanBasketMint];
		_orderPickupValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:4]];
		[_orderPickupValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderDeliverLabel = [[UILabel alloc] initWithFrame:[self frameForFirstAt:5]];
		[_orderDeliverLabel setText:@"배달일자"];
		[_orderDeliverLabel setTextColor:CleanBasketMint];
		_orderDeliverValueLabel = [[UILabel alloc] initWithFrame:[self frameForSecondAt:5]];
		[_orderDeliverValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_managerPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(X_FIRST, Y_FIRST + 6 * MARGIN_REGULAR, IMAGE_SIZE, IMAGE_SIZE)];
        [_managerPhotoView setClipsToBounds:YES];
        [_managerPhotoView setImage:[UIImage imageNamed:@"ic_profile_no.png"]];
        [_managerPhotoView setContentMode:UIViewContentModeScaleAspectFit];
		
		_managerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_SECOND, Y_FIRST + 6.2 * MARGIN_REGULAR, 80, HEIGHT_REGULAR)];
		[_managerNameLabel setText:@"매니저 이름"];
		[_managerNameLabel setTextColor:CleanBasketMint];
		_managerNameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, Y_FIRST + 6.2 * MARGIN_REGULAR, 130, HEIGHT_REGULAR)];
		[_managerNameValueLabel setTextColor:[UIColor lightGrayColor]];
		
		_orderCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 270, 80, 40)];
		[_orderCancelButton.layer setCornerRadius:10.0f];
		[_orderCancelButton setTitle:@"주문취소" forState:UIControlStateNormal];
		[_orderCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		
//		[_orderNumberLabel setBackgroundColor:[UIColor redColor]];
//		[_orderNumberValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_orderPriceLabel setBackgroundColor:[UIColor redColor]];
//		[_orderPriceValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_orderItemsLabel setBackgroundColor:[UIColor redColor]];
//		[_orderItemsValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_orderStatusLabel setBackgroundColor:[UIColor redColor]];
//		[_orderStatusValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_orderPickupLabel setBackgroundColor:[UIColor redColor]];
//		[_orderPickupValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_orderDeliverLabel setBackgroundColor:[UIColor redColor]];
//		[_orderDeliverValueLabel setBackgroundColor:[UIColor blueColor]];
//		[_managerPhotoView setBackgroundColor:[UIColor redColor]];
//		[_managerNameLabel setBackgroundColor:[UIColor redColor]];
//		[_managerNameValueLabel setBackgroundColor:[UIColor blueColor]];
		[_orderCancelButton setBackgroundColor:CleanBasketRed];
		
		[self addSubview:_orderNumberLabel];
		[self addSubview:_orderNumberValueLabel];
		[self addSubview:_orderPriceLabel];
		[self addSubview:_orderPriceValueLabel];
		[self addSubview:_orderItemsLabel];
		[self addSubview:_orderItemsValueLabel];
		[self addSubview:_orderStatusLabel];
		[self addSubview:_orderStatusValueLabel];
		[self addSubview:_orderPickupLabel];
		[self addSubview:_orderPickupValueLabel];
		[self addSubview:_orderDeliverLabel];
		[self addSubview:_orderDeliverValueLabel];
		[self addSubview:_managerPhotoView];
		[self addSubview:_managerNameLabel];
		[self addSubview:_managerNameValueLabel];
		[self addSubview:_orderCancelButton];
	}
	return self;
}

- (CGRect) frameForFirstAt:(int)line {
	return CGRectMake(X_FIRST, Y_FIRST + line * MARGIN_REGULAR, WIDTH_FIRST, HEIGHT_REGULAR);
}

- (CGRect) frameForSecondAt:(int)line {
	return CGRectMake(X_SECOND, Y_FIRST + line * MARGIN_REGULAR, WIDTH_SECOND, HEIGHT_REGULAR);
}


@end
