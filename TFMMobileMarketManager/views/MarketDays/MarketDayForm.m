//
//  MarketDayForm.m
//  tfmco-mip
//

#import "MarketDayForm.h"

@implementation MarketDayForm

- (NSArray *)loadLocations
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Locations"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	return [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)loadStaff
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MarketStaff"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	return [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)loadVendors
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"business_name" ascending:true]]];
	return [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"location", FXFormFieldOptions: [self loadLocations]},
		
		@{FXFormFieldKey: @"vendors", FXFormFieldType: FXFormFieldTypeBitfield, FXFormFieldOptions: [self loadVendors], FXFormFieldHeader: @""},
		
		@{FXFormFieldKey: @"date", FXFormFieldDefaultValue: [NSDate date], FXFormFieldHeader: @""},
		@{FXFormFieldTitle: @"Start time", FXFormFieldDefaultValue: [NSDate date], FXFormFieldKey: @"start_time", FXFormFieldType: FXFormFieldTypeTime},
		@{FXFormFieldTitle: @"End time", FXFormFieldKey: @"end_time", FXFormFieldType: FXFormFieldTypeTime},
		
		@{FXFormFieldKey: @"staff", FXFormFieldType: FXFormFieldTypeBitfield, FXFormFieldOptions: [self loadStaff], FXFormFieldHeader: @""},
		@{FXFormFieldKey: @"notes", FXFormFieldType: FXFormFieldTypeLongText}
	];
}

@end
