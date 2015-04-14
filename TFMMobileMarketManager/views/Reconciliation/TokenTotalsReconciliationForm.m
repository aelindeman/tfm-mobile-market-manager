//
//  TokenTotalsReconciliationForm.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationForm.h"

@implementation TokenTotalsReconciliationForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"marketCreditTokenCount", FXFormFieldTitle: @"Credit tokens", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldAction: @"updateTokenDeltas:", FXFormFieldHeader: @"Disbursed Tokens"},
		@{FXFormFieldKey: @"marketSnapTokenCount", FXFormFieldTitle: @"SNAP tokens", @"imageView.image": [UIImage imageNamed:@"token-blue"], FXFormFieldAction: @"updateTokenDeltas:"},
		@{FXFormFieldKey: @"marketBonusTokenCount", FXFormFieldTitle: @"Bonus tokens", @"imageView.image": [UIImage imageNamed:@"token-red"], FXFormFieldAction: @"updateTokenDeltas:"},
		
		@{FXFormFieldKey: @"redeemedCreditTokenCount", FXFormFieldTitle: @"Credit tokens", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldAction: @"updateTokenDeltas:", FXFormFieldHeader: @"Redeemed Tokens"},
		@{FXFormFieldKey: @"redeemedSnapTokenCount", FXFormFieldTitle: @"SNAP tokens", @"imageView.image": [UIImage imageNamed:@"token-blue"], FXFormFieldAction: @"updateTokenDeltas:"},
		@{FXFormFieldKey: @"redeemedBonusTokenCount", FXFormFieldTitle: @"Bonus tokens", @"imageView.image": [UIImage imageNamed:@"token-red"], FXFormFieldAction: @"updateTokenDeltas:"},
		
		@{FXFormFieldKey: @"creditTokenDifference", FXFormFieldTitle: @"Credit tokens", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Difference"},
		@{FXFormFieldKey: @"snapTokenDifference", FXFormFieldTitle: @"SNAP tokens", @"imageView.image": [UIImage imageNamed:@"token-blue"], FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"bonusTokenDifference", FXFormFieldTitle: @"Bonus tokens", @"imageView.image": [UIImage imageNamed:@"token-red"], FXFormFieldType: FXFormFieldTypeLabel},
	];
}

@end
