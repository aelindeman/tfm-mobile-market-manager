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
		@{FXFormFieldKey: @"position", @"textField.autocapitalizationType": @(UITextAutocapitalizationTypeWords)}
	];
}

@end
