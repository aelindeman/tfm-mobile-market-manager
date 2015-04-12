//
//  TransactionForm.m
//  tfmco-mip
//

#import "TransactionForm.h"

@implementation TransactionForm

- (NSArray *)creditSubfields
{
	return (self.credit_used) ? @[
		@{FXFormFieldTitle: @"Credit amount", FXFormFieldKey: @"credit_amount", FXFormFieldAction: @"updateCreditTotal:"},
		@{FXFormFieldTitle: @"Credit fee", FXFormFieldKey: @"credit_fee", FXFormFieldCell: [FXFormStepperCell class], @"stepper.stepValue": [NSNumber numberWithInt:2], @"stepper.maximumValue": [NSNumber numberWithInt:2], FXFormFieldAction: @"updateCreditTotal:"},
		@{FXFormFieldTitle: @"Total", FXFormFieldKey: @"credit_total", FXFormFieldType: FXFormFieldTypeLabel},
	] : @[];
}

- (NSArray *)snapSubfields
{
	return (self.snap_used) ? @[
		@{FXFormFieldTitle: @"SNAP amount", FXFormFieldKey: @"snap_amount", FXFormFieldAction: @"updateSnapTotal:"},
		@{FXFormFieldTitle: @"SNAP bonus", FXFormFieldKey: @"snap_bonus", FXFormFieldAction: @"updateSnapTotal:"},
		@{FXFormFieldTitle: @"Total", FXFormFieldKey: @"snap_total", FXFormFieldType: FXFormFieldTypeLabel}
	] : @[];
}

- (NSArray *)fields
{
	NSMutableArray *fields = [@[
		// Demographics
		@{FXFormFieldTitle: @"ZIP Code", FXFormFieldKey: @"cust_zipcode", FXFormFieldHeader: @"Demographics"},
		@{FXFormFieldTitle: @"ID", FXFormFieldKey: @"cust_id", FXFormFieldFooter: @"Use the last 4 digits on driver’s license"},
		@{FXFormFieldTitle: @"Visit Frequency", FXFormFieldKey: @"cust_frequency", FXFormFieldOptions: @[@"First time", @"Few times a season", @"Monthly", @"A few times a month", @"Weekly"]},
		@{FXFormFieldTitle: @"Referral", FXFormFieldKey: @"cust_referral", FXFormFieldPlaceholder: @"How did you hear about us?"},
		@{FXFormFieldTitle: @"Gender   ", FXFormFieldKey: @"cust_gender", FXFormFieldOptions: @[@"Male", @"Female", @"Other"], FXFormFieldCell: [FXFormOptionSegmentsCell class]},
		@{FXFormFieldTitle: @"Senior citizen", FXFormFieldKey: @"cust_senior"},
		@{FXFormFieldTitle: @"Ethnicity", FXFormFieldKey: @"cust_ethnicity", FXFormFieldOptions: @[@"White", @"Black", @"Hispanic", @"Asian", @"Other"]}
	] mutableCopy];
	
	[fields addObject:@{FXFormFieldTitle: @"Used credit", FXFormFieldKey: @"credit_used", FXFormFieldHeader: @"Credit", FXFormFieldAction: @"toggleSnapOrCredit:"}];
	[fields addObjectsFromArray:[self creditSubfields]];
	
	[fields addObject:@{FXFormFieldTitle: @"Used SNAP", FXFormFieldKey: @"snap_used", FXFormFieldHeader: @"SNAP", FXFormFieldAction: @"toggleSnapOrCredit:"}];
	[fields addObjectsFromArray:[self snapSubfields]];
	
	[fields addObject:@{FXFormFieldTitle: @"Mark transaction as invalid", FXFormFieldKey: @"markedInvalid", FXFormFieldType: FXFormFieldTypeOption, FXFormFieldHeader: @""}];
	
	return fields;
}

@end
