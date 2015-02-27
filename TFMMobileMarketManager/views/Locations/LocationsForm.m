//
//  LocationsForm.m
//  tfmco-mip
//

#import "LocationsForm.h"

@implementation LocationsForm

- (NSArray *)fields
{
	return @[
		@"name",
		@"abbreviation",
		@{FXFormFieldKey: @"address", FXFormFieldType: FXFormFieldTypeLongText},
	];
}

@end
