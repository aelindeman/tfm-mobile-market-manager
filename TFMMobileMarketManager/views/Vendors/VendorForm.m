//
//  VendorForm.m
//  tfmco-mip
//

#import "VendorForm.h"

@implementation VendorForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldTitle: @"Business name", FXFormFieldKey: @"businessName", FXFormFieldHeader: @"Basic information"},
		@{FXFormFieldTitle: @"Product types", FXFormFieldKey: @"productTypes", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldFooter: @"Separate product types by commas and no spaces"},
		
		@{FXFormFieldTitle: @"Operator name", FXFormFieldKey: @"name", FXFormFieldHeader: @"Contact"},
		@{FXFormFieldTitle: @"Address", FXFormFieldKey: @"address", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldPlaceholder: @"Include city, state, and zip code in address"},
		@{FXFormFieldTitle: @"Phone number", FXFormFieldKey: @"phone", FXFormFieldType: FXFormFieldTypePhone},
		@"email",
		
		@{FXFormFieldTitle: @"Accepts SNAP", FXFormFieldKey: @"acceptsSNAP", FXFormFieldHeader: @"Eligibility"},
		@{FXFormFieldTitle: @"Accepts incentives", FXFormFieldKey: @"acceptsIncentives"},
		
		@{FXFormFieldTitle: @"State Tax ID", FXFormFieldKey: @"stateTaxID", FXFormFieldHeader: @"Tax information"},
		@{FXFormFieldTitle: @"Federal Tax ID", FXFormFieldKey: @"federalTaxID"},
	];
}

@end
