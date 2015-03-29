//
//  TokenTotalsReconciliationForm.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationForm.h"

@implementation TokenTotalsReconciliationForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"marketCreditTokenCount", FXFormFieldTitle: @"Credit tokens", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldHeader: @"Market Tokens"},
		@{FXFormFieldKey: @"marketSnapTokenCount", FXFormFieldTitle: @"SNAP tokens", @"imageView.image": [UIImage imageNamed:@"token-blue"]},
		@{FXFormFieldKey: @"marketBonusTokenCount", FXFormFieldTitle: @"Bonus tokens", @"imageView.image": [UIImage imageNamed:@"token-red"]},
		
		@{FXFormFieldKey: @"redeemedCreditTokenCount", FXFormFieldTitle: @"Credit tokens", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldHeader: @"Redeemed Tokens"},
		@{FXFormFieldKey: @"redeemedSnapTokenCount", FXFormFieldTitle: @"SNAP tokens", @"imageView.image": [UIImage imageNamed:@"token-blue"]},
		@{FXFormFieldKey: @"redeemedBonusTokenCount", FXFormFieldTitle: @"Bonus tokens", @"imageView.image": [UIImage imageNamed:@"token-red"]},
	];
}

@end
