//
//  MarketStaffForm.m
//  tfmco-mip
//

#import "MarketStaffForm.h"

@implementation MarketStaffForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"name", @"textField.autocapitalizationType": @(UITextAutocapitalizationTypeWords)},
		@"phone",
		@"email",
		@{FXFormFieldKey: @"position", FXFormFieldOptions: @[@"Volunteer", @"Manager"]}
	];
}

@end
