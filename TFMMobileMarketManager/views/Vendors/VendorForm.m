//
//  VendorForm.m
//  tfmco-mip
//

#import "VendorForm.h"

@implementation VendorForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldTitle: @"Business name", FXFormFieldKey: @"business_name", FXFormFieldHeader: @"Basic information"},
		@{FXFormFieldTitle: @"Product types", FXFormFieldKey: @"product_types", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldFooter: @"Separate product types by commas and no spaces"},
		
		@{FXFormFieldTitle: @"Operator name", FXFormFieldKey: @"name", FXFormFieldHeader: @"Contact"},
		@{FXFormFieldTitle: @"Address", FXFormFieldKey: @"address", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldPlaceholder: @"Include city, state, and zip code in address"},
		@{FXFormFieldTitle: @"Phone number", FXFormFieldKey: @"phone", FXFormFieldType: FXFormFieldTypePhone},
		@"email",
		
		@{FXFormFieldTitle: @"State Tax ID", FXFormFieldKey: @"state_tax_id", FXFormFieldHeader: @"Tax information"},
		@{FXFormFieldTitle: @"Federal Tax ID", FXFormFieldKey: @"federal_tax_id"},
	];
}

@end
