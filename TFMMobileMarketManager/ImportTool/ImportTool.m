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
			
			new.acceptsSNAP = ([row[6] integerValue] == 1) || ([[row[6] lowercaseString] hasPrefix:@"y"]) || ([[row[6] lowercaseString] hasPrefix:@"t"]);
			new.acceptsIncentives = ([row[7] integerValue] == 1) || ([[row[7] lowercaseString] hasPrefix:@"y"]) || ([[row[7] lowercaseString] hasPrefix:@"t"]);
			
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

// !!!: replaces entire database
// TODO: implement option for merging rather than a drop-in replacement db - http://stackoverflow.com/a/10038331
- (bool)importDump:(NSURL *)url
{
	NSPersistentStore *store = [[TFMM3_APP_DELEGATE.persistentStoreCoordinator persistentStores] lastObject];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	
	// delete existing database
	if (![TFMM3_APP_DELEGATE.persistentStoreCoordinator removePersistentStore:store error:&error])
		NSLog(@"failed to remove old store: %@", error);
	
	// copy over new database
	if (![fm removeItemAtURL:store.URL error:&error])
		NSLog(@"failed to delete old store: %@", error);
	
	if (![fm copyItemAtURL:url toURL:store.URL error:&error])
		NSLog(@"failed to copy store to location: %@", error);
		
	// restart persistent store coordinator using new database
	if (![TFMM3_APP_DELEGATE.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:&error])
		NSLog(@"failed to add new store: %@", error);
	
	return !error;
}

#pragma mark - helper functions

- (NSString *)sanitizePhone:(NSString *)input
{
	return [[input componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

@end
