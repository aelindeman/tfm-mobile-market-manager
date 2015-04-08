//
//  ImportTool.m
//  TFMMobileMarketManager
//

#import "ImportTool.h"

@implementation ImportTool

static NSUInteger parseSettings = CHCSVParserOptionsRecognizesBackslashesAsEscapes | CHCSVParserOptionsSanitizesFields | CHCSVParserOptionsTrimsWhitespace;

- (NSUInteger)importStaffFromCSV:(NSURL *)url
{
	NSError *error;
	NSUInteger importCount = 0;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];

	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (NSUInteger i = 0; i < [rows count]; i ++)
		{
			if (i == 0) continue; // skip header row
			
			NSArray *row = rows[i];
			
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

- (NSUInteger)importVendorsFromCSV:(NSURL *)url
{
	NSError *error;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];
	NSUInteger importCount = 0;
	
	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (NSUInteger i = 0; i < [rows count]; i ++)
		{
			if (i == 0) continue; // skip header row
			
			NSArray *row = rows[i];
			
			Vendors *new = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			// TODO: validate
			new.businessName = row[0];
			new.productTypes = row[1];
			
			new.name = row[2];
			new.address = row[3];
			new.phone = row[4];
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

- (NSUInteger)importLocationsFromCSV:(NSURL *)url
{
	NSError *error;
	NSArray *rows = [NSArray arrayWithContentsOfCSVURL:url options:parseSettings];
	NSUInteger importCount = 0;
	
	if (rows == nil)
	{
		NSLog(@"error importing staff: %@", error);
		return 0;
	}
	
	@try
	{
		for (NSUInteger i = 0; i < [rows count]; i ++)
		{
			if (i == 0) continue; // skip header row
			
			NSArray *row = rows[i];
			
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

#pragma mark - helper functions

- (NSString *)sanitizePhone:(NSString *)input
{
	return [[input componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

@end
