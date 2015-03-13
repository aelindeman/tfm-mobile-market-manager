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
		@{FXFormFieldKey: @"address", FXFormFieldType: FXFormFieldTypeLongText},
	];
}

@end
