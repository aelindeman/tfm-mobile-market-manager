//
//  TransactionForm.m
//  tfmco-mip
//

#import "TransactionForm.h"

@implementation TransactionForm

- (NSArray *)fields
{
	return @[
		// Demographics
		@{FXFormFieldTitle: @"ZIP Code", FXFormFieldKey: @"cust_zipcode", FXFormFieldHeader: @"Demographics"},
		@{FXFormFieldTitle: @"ID", FXFormFieldKey: @"cust_id", FXFormFieldFooter: @"Use the last 4 digits on driver’s license"},
		@{FXFormFieldTitle: @"Visit Frequency", FXFormFieldKey: @"cust_frequency", FXFormFieldOptions: @[@"Unspecified", @"First time", @"Few times a season", @"Monthly", @"A few times a month", @"Weekly"]},
		@{FXFormFieldTitle: @"Referral", FXFormFieldKey: @"cust_referral", FXFormFieldPlaceholder: @"How did you hear about us?"},
		@{FXFormFieldTitle: @"Gender   ", FXFormFieldKey: @"cust_gender", FXFormFieldOptions: @[@"Male", @"Female"], FXFormFieldCell: [FXFormOptionSegmentsCell class]},
		@{FXFormFieldTitle: @"Senior citizen", FXFormFieldKey: @"cust_senior"},
		@{FXFormFieldTitle: @"Ethnicity", FXFormFieldKey: @"cust_ethnicity", FXFormFieldOptions: @[@"Unspecified", @"White", @"Black", @"Hispanic", @"Asian", @"Other"]},
		
		// Credit
		@{FXFormFieldTitle: @"Used credit", FXFormFieldKey: @"credit_used", FXFormFieldHeader: @"Credit", FXFormFieldAction: @"toggleSnapOrCredit:"},
		@{FXFormFieldTitle: @"Credit amount", FXFormFieldKey: @"credit_amount", FXFormFieldAction: @"updateCreditTotal:"},
		@{FXFormFieldTitle: @"Credit fee", FXFormFieldKey: @"credit_fee", FXFormFieldAction: @"updateCreditTotal:"},
		@{FXFormFieldTitle: @"Total", FXFormFieldKey: @"credit_total", FXFormFieldType: FXFormFieldTypeLabel},
		
		// SNAP
		@{FXFormFieldTitle: @"Used SNAP", FXFormFieldKey: @"snap_used", FXFormFieldHeader: @"SNAP", FXFormFieldAction: @"toggleSnapOrCredit:"},
		@{FXFormFieldTitle: @"SNAP amount", FXFormFieldKey: @"snap_amount", FXFormFieldAction: @"updateSnapTotal:"},
		@{FXFormFieldTitle: @"SNAP bonus", FXFormFieldKey: @"snap_bonus", FXFormFieldAction: @"updateSnapTotal:"},
		@{FXFormFieldTitle: @"Total", FXFormFieldKey: @"snap_total", FXFormFieldType: FXFormFieldTypeLabel},
		
		// Management
		@{FXFormFieldTitle: @"Mark transaction as invalid", FXFormFieldKey: @"markedInvalid", FXFormFieldType: FXFormFieldTypeOption, FXFormFieldHeader: @""}
	];
}

@end
