//
//  ImportTool.m
//  TFMMobileMarketManager
//

#import "ImportTool.h"

@implementation ImportTool

static unsigned int parseSettings = CHCSVParserOptionsRecognizesBackslashesAsEscapes | CHCSVParserOptionsSanitizesFields | CHCSVParserOptionsTrimsWhitespace;

- (id)initWithSkipSetting:(bool)skipFirstRow
{
	if (self = [super init])
	{
		_skipFirstRow = skipFirstRow;
	}
	return self;
}

- (unsigned int)importStaffFromCSV:(NSURL *)url
{
	NSError *error;
	unsigned int importCount = 0;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];

	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (unsigned int i = 0; i < [rows count]; i ++)
		{
			NSArray *row = rows[i];
			if (self.skipFirstRow && i == 0) continue; // skip header row
			if ([rows count] != 4) continue; // skip if not the right length
			
			// absolutely need name
			if ([row[0] length] == 0) continue;
			
			MarketStaff *new = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		
			// TODO: validate
			new.name = row[0];
			new.phone = row[1];
			new.email = row[2];
			new.position = [row[3] integerValue];
			
			importCount ++;
		}
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
			NSLog(@"couldn't save: %@", [error localizedDescription]);
	}
	@catch (NSException *exception)
	{
		NSLog(@"exception at item %i: %@", importCount, [exception reason]);
		return importCount;
	}

		NSLog(@"import finished, added %i staff", importCount);
		return importCount;
	}

- (unsigned int)importVendorsFromCSV:(NSURL *)url
{
	NSError *error;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];
	unsigned int importCount = 0;
	
	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (unsigned int i = 0; i < [rows count]; i ++)
		{
			NSArray *row = rows[i];
			if (self.skipFirstRow && i == 0) continue; // skip header row
			if ([row count] != 10) continue; // skip if not the right length
			
			// absolutely need business name and operator name, skip if they are not set
			if ([row[0] length] == 0 || [row[2] length] == 0) continue;
			
			Vendors *new = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			// TODO: validate
			new.businessName = row[0];
			new.productTypes = row[1];
			
			new.name = row[2];
			new.address = row[3];
			new.phone = [self sanitizePhone:row[4]];
			new.email = row[5];
			
			new.acceptsSNAP = [row[6] integerValue] == 1;
			new.acceptsIncentives = [row[7] integerValue] == 1;
			
			new.stateTaxID = row[8];
			new.federalTaxID = row[9];
			
			importCount ++;
		}
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
			NSLog(@"couldn't save: %@", [error localizedDescription]);
	}
	@catch (NSException *exception)
	{
		NSLog(@"exception at item %i: %@", importCount, [exception reason]);
		return importCount;
	}
	
	NSLog(@"import finished, added %i vendors", importCount);
	return importCount;
}

- (unsigned int)importLocationsFromCSV:(NSURL *)url
{
	NSError *error;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];
	unsigned int importCount = 0;
	
	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (unsigned int i = 0; i < [rows count]; i ++)
		{
			NSArray *row = rows[i];
			if (self.skipFirstRow && i == 0) continue; // skip header row
			if ([row count] != 2) continue; // skip if not the right length
			
			// require both fields
			if ([row[0] length] == 0 || [row[1] length] == 0) continue;
			
			Locations *new = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			// TODO: validate
			new.name = row[0];
			new.address = row[1];
			
			importCount ++;
		}
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
			NSLog(@"couldn't save: %@", [error localizedDescription]);
	}
	@catch (NSException *exception)
	{
		NSLog(@"exception at item %i: %@", importCount, [exception reason]);
		return importCount;
	}
	
	NSLog(@"import finished, added %i locations", importCount);
	return importCount;
}

- (bool)importDump:(NSURL *)url
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *dbAt = [[TFMM3_APP_DELEGATE applicationDocumentsDirectory] URLByAppendingPathComponent:@"tfm-m3.m3db"];
	NSError *error;
	if ([fm removeItemAtURL:dbAt error:&error])
		if (!error && [fm copyItemAtURL:url toURL:dbAt error:&error])
			return true;
	
	NSLog(@"couldn't import database dump: %@", error);
	return false;
}

#pragma mark - helper functions

- (NSString *)sanitizePhone:(NSString *)input
{
	return [[input componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

@end
