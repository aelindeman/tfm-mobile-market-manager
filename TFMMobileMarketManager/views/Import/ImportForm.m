//
//  ImportForm.m
//  TFMMobileMarketManager
//

#import "ImportForm.h"

@implementation ImportForm

- (NSArray *)listAvailableFiles
{
	NSURL *docsPath = TFMM3_APP_DELEGATE.applicationDocumentsDirectory;
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"self endswith '.csv' or self endswith '.m3db' or self endswith '.m3table'"];
	
	// include both root documents dir and inbox dir
	NSArray *docsFiles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[docsPath path] error:nil] filteredArrayUsingPredicate:filter];
	NSArray *inboxFiles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString pathWithComponents:@[[docsPath path], @"Inbox"]] error:nil] filteredArrayUsingPredicate:filter];
	
	NSMutableArray *fileURLs = [[NSMutableArray alloc] init];
	for (NSString *f in docsFiles)
	{
		[fileURLs addObject:[NSURL fileURLWithPath:[NSString pathWithComponents:@[[docsPath path], f]]]];
	}
	
	for (NSString *f in inboxFiles)
	{
		//[fileURLs addObject:[NSURL fileURLWithPathComponents:@[docsPath, @"Inbox", f]]];
		[fileURLs addObject:[NSURL fileURLWithPath:[NSString pathWithComponents:@[[docsPath path], @"Inbox", f]]]];
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
