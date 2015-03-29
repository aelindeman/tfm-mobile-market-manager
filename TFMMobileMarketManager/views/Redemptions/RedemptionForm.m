//
//  RedemptionForm.m
//  tfmco-mip
//

#import "RedemptionForm.h"

@implementation RedemptionForm

- (NSArray *)loadVendors
{
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(%@ IN marketdays)", [TFM_DELEGATE activeMarketDay]]];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"businessName" ascending:true]]];
	return [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"vendor", FXFormFieldOptions: [self loadVendors]},
		@{FXFormFieldKey: @"date", FXFormFieldDefaultValue: [NSDate date]},
		@{FXFormFieldTitle: @"Check number", FXFormFieldKey: @"check_number", FXFormFieldDefaultValue: @"1000"},
		
		@{FXFormFieldTitle: @"Credit token count", FXFormFieldKey: @"credit_count", @"imageView.image": [UIImage imageNamed:@"token-green"], FXFormFieldAction: @"updateTokenTotals:", FXFormFieldHeader: @"Token counts"},
		@{FXFormFieldTitle: @"SNAP token count", FXFormFieldKey: @"snap_count", @"imageView.image": [UIImage imageNamed:@"token-blue"], FXFormFieldAction: @"updateTokenTotals:"},
		@{FXFormFieldTitle: @"Bonus token count", FXFormFieldKey: @"bonus_count", @"imageView.image": [UIImage imageNamed:@"token-red"], FXFormFieldAction: @"updateTokenTotals:"},
		
		@{FXFormFieldTitle: @"Credit token value", FXFormFieldKey: @"credit_amount", FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Token totals"},
		@{FXFormFieldTitle: @"Total value", FXFormFieldKey: @"total", FXFormFieldType: FXFormFieldTypeLabel},
		
		@{FXFormFieldTitle: @"Mark redemption as invalid", FXFormFieldKey: @"markedInvalid", FXFormFieldType: FXFormFieldTypeOption , FXFormFieldHeader: @""}
	];
}

@end
