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
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"business_name" ascending:true]]];
	return [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"vendor", FXFormFieldOptions: [self loadVendors]},
		@{FXFormFieldKey: @"date", FXFormFieldDefaultValue: [NSDate date]},
		@{FXFormFieldTitle: @"Check number", FXFormFieldKey: @"check_number", FXFormFieldDefaultValue: @"1000"},
		
		@{FXFormFieldTitle: @"SNAP token count", FXFormFieldKey: @"snap_count", FXFormFieldAction: @"updateTokenTotals:", FXFormFieldHeader: @"Token counts"},
		@{FXFormFieldTitle: @"Bonus token count", FXFormFieldKey: @"bonus_count", FXFormFieldAction: @"updateTokenTotals:"},
		@{FXFormFieldTitle: @"Credit token count", FXFormFieldKey: @"credit_count", FXFormFieldAction: @"updateTokenTotals:"},
		
		@{FXFormFieldTitle: @"Credit token value", FXFormFieldKey: @"credit_amount", FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Token totals"},
		@{FXFormFieldTitle: @"Total value", FXFormFieldKey: @"total", FXFormFieldType: FXFormFieldTypeLabel},
		
		@{FXFormFieldTitle: @"Mark redemption as invalid", FXFormFieldKey: @"markedInvalid", FXFormFieldType: FXFormFieldTypeOption , FXFormFieldHeader: @""}
	];
}

@end
