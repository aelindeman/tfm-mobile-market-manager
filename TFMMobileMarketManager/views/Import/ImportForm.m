//
//  ImportForm.m
//  TFMMobileMarketManager
//

#import "ImportForm.h"

@implementation ImportForm

- (NSArray *)listAvailableFiles
{
	NSURL *importPath = TFMM3_APP_DELEGATE.applicationDocumentsDirectory;
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"self endswith '.csv' or self endswith '.m3db' or self endswith '.m3table'"];
	
	NSArray *files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[importPath path] error:nil] filteredArrayUsingPredicate:filter];
	
	NSMutableArray *fileURLs = [[NSMutableArray alloc] init];
	for (NSString *f in files)
	{
		[fileURLs addObject:[importPath URLByAppendingPathComponent:f]];
	}
	
	return fileURLs;
}

- (NSArray *)fields
{
	NSMutableArray *fields = [@[
		@{FXFormFieldKey: @"url", FXFormFieldTitle: @"File", FXFormFieldOptions: [self listAvailableFiles], FXFormFieldAction: @"updateOptions:", @"detailTextLabel.text": self.url ? [self.url lastPathComponent] : @"", FXFormFieldValueTransformer: ^(NSURL *input){ return input ? [[input path] lastPathComponent] : @""; }, FXFormFieldHeader: @""}
	] mutableCopy];
	
	if (self.url)
	{
		if (self.importType == ImportTypeDump)
		{
			[fields addObjectsFromArray:@[
				@{FXFormFieldKey: @"importType", FXFormFieldTitle: @"Import type", FXFormFieldType: FXFormFieldTypeLabel, @"detailTextLabel.text": @"Dump", FXFormFieldHeader: @"Options"},
				//@{FXFormFieldKey: @"importDumpOptions", FXFormFieldTitle: @"After import", FXFormFieldOptions: @[@"Replace existing database", @"Merge changes", @"Only add new records", @"Only update existing records"]}
			]];
		}
		else
		{
			[fields addObject:@{FXFormFieldKey: @"importType", FXFormFieldTitle: @"Import type", FXFormFieldOptions: @[@"Vendors", @"Staff", @"Locations"], FXFormFieldHeader: @"Options"}];
			
			if (self.importFormat == ImportFormatCSV)
			{
				[fields addObject:@{FXFormFieldKey: @"skipFirstRow", FXFormFieldTitle: @"Skip first row", FXFormFieldDefaultValue: @true, FXFormFieldFooter: @"Use if there is a header row in the file"}];
			}
		}
	}
	
	return fields;
}

@end
