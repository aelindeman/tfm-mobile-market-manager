//
//  TokenTotalsReconciliationForm.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationForm.h"

@implementation TokenTotalsReconciliationForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"marketCreditTokenCount", FXFormFieldTitle: @"Credit tokens", FXFormFieldHeader: @"Market Tokens"},
		@{FXFormFieldKey: @"marketSnapTokenCount", FXFormFieldTitle: @"SNAP tokens"},
		@{FXFormFieldKey: @"marketBonusTokenCount", FXFormFieldTitle: @"Bonus tokens"},
		
		@{FXFormFieldKey: @"redeemedCreditTokenCount", FXFormFieldTitle: @"Credit tokens", FXFormFieldHeader: @"Redeemed Tokens"},
		@{FXFormFieldKey: @"redeemedSnapTokenCount", FXFormFieldTitle: @"SNAP tokens"},
		@{FXFormFieldKey: @"redeemedBonusTokenCount", FXFormFieldTitle: @"Bonus tokens"},
	];
}

@end
