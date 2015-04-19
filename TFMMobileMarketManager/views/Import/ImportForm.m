//
//  ImportForm.m
//  TFMMobileMarketManager
//

#import "ImportForm.h"

@implementation ImportForm

- (NSArray *)listAvailableFiles
{
	NSArray *files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path] stringByAppendingPathComponent:@"Inbox"] error:nil] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self endswith '.csv' or self endswith '.m3db' or self endswith '.m3table'"]];
	
	NSMutableArray *fileURLs = [[NSMutableArray alloc] init];
	for (NSString *f in files)
	{
		[fileURLs addObject:[NSURL URLWithString:f]];
	}
	
	return files;
}

- (NSArray *)fields
{
	NSMutableArray *fields = [@[
		@{FXFormFieldKey: @"selectedFile", FXFormFieldTitle: @"File", FXFormFieldOptions: [self listAvailableFiles], FXFormFieldAction: @"updateOptions:", FXFormFieldHeader: @""}
	] mutableCopy];
	
	if (self.importType == ImportTypeDump)
	{
		[fields addObjectsFromArray:@[
			@{FXFormFieldTitle: @"Import Type", FXFormFieldDefaultValue: @"Dump", FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Options"}
		]];
	}
	else
	{
		[fields addObjectsFromArray:@[
			@{FXFormFieldKey: @"importType", FXFormFieldOptions: @[@"Vendors", @"Staff", @"Locations"], FXFormFieldHeader: @"Options"},
			@{FXFormFieldKey: @"importFormat", FXFormFieldTitle: @"Format", FXFormFieldOptions: @[@"CSV", @"JSON"]},
			@"skipFirstRow"
		]];
	}
	
	return fields;
}

@end
