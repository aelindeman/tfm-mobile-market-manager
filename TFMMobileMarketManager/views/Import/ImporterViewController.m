//
//  ImporterViewController.m
//  TFMMobileMarketManager
//

#import "ImporterViewController.h"

@interface ImporterViewController ()

@end

@implementation ImporterViewController

static NSString *prepopulateConfirmationTitle = @"Add sample data to the database?";
static NSString *prepopulateConfirmationMessage = @"This will add a small sample set of locations, staff, and vendors to use for testing.\n\nRecords will only be added if the database is empty.";

static NSString *noDestinationSelectedTitle = @"No destination selected";
static NSString *noDestinationSelectedMessage = @"";

static NSString *dumpImportConfirmationTitle = @"Import this database dump?";
static NSString *dumpImportConfirmationMessage = @"The current database will be destroyed permanently, and the database you opened will become the current database.";

static NSString *cantImportDumpFromInputTitle = @"Can’t import database dump from text input";
static NSString *cantImportDumpFromInputMessage = @"Database dumps can only be imported from SQLite dump files with the extension “m3db”.";

static NSString *importConfirmationTitle = @"Import data?";
static NSString *importConfirmationMessage = @"";

static NSString *importSuccessTitle = @"Data imported successfully";
static NSString *importSuccessMessage = @"%i entr%@ imported."; // first token: entry count, second token: pluralize -> (count == 1) ? @"y was" : @"ies were"

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (self.fileToImport)
	{
		// simple determine type of import based on filename
		NSDictionary *types = @{@"staff": @1, @"employee": @1, @"vendor": @0, @"business": @0, @"location": @2, @"market": @2, @"marketstaff": @1, @"dump": @3, @"database": @3};
		for (NSString *key in types)
		{
			NSRange range = [[[self.fileToImport lastPathComponent] lowercaseString] rangeOfString:[key lowercaseString]];
			if (range.length > 0)
			{
				NSLog(@"assuming import type is %i because filename “%@” contained “%@”", [[types valueForKey: key] intValue], [[self.fileToImport pathComponents] lastObject], key);
				[self.importDestination setSelectedSegmentIndex:[[types valueForKey:key] intValue]];
				break;
			}
		}
		
		NSError *error;
		if ([[[self.fileToImport pathExtension] lowercaseString] isEqualToString:@"csv"])
		{
			[self.textView setText:[NSString stringWithContentsOfFile:[self.fileToImport path] encoding:NSUTF8StringEncoding error:&error]];
		}
		else
		{
			for (unsigned int i = 0; i < self.importDestination.numberOfSegments - 1; i ++)
				[self.importDestination setEnabled:false forSegmentAtIndex:i];
			[self.importDestination setEnabled:true forSegmentAtIndex:3];
			[self.importDestination setSelectedSegmentIndex:3];
			[self.textView setText:[NSString stringWithFormat:@"Can’t display <%@> as text", [self.fileToImport lastPathComponent]]];
		}
		
		if (error) NSLog(@"error while loading url: %@", error);
		
		// prevent editing opened data
		[self.textView setEditable:false];
		[self.filenameLabel setText:[@"Ready to import " stringByAppendingString:[self.fileToImport lastPathComponent]]];
	}
	else
	{
		// TODO: enable input import, or hide import button from menu
		[self.filenameLabel setHidden:true];
		[self.importButton setEnabled:false];
	}
}

// loads file into text view
- (void)handleOpenURL:(NSURL *)url
{
	[self setFileToImport:url];
	[self.filenameLabel setText:[self.fileToImport lastPathComponent]];
	NSLog(@"importer loaded url %@", url);
}

// Fills the database with some sample data
- (void)prepopulate
{
	NSString *results = [[NSString alloc] init];

	NSError *error;
	NSFetchRequest *locations = [NSFetchRequest fetchRequestWithEntityName:@"Locations"];
	if ([[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:locations error:&error] count] == 0)
	{
		Locations *fred = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		fred.name = @"Fredericksburg";
		fred.address = @"Hurkamp Park, Prince Edward St\nFredericksburg, VA 22401";
		
		Locations *spotsy = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		spotsy.name = @"Spotsylvania";
		spotsy.address = @"4240 Plank Rd\nFredericksburg, VA 22407";
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated locations");
		results = [results stringByAppendingString:@"Added sample locations\n"];
	}
	
	NSFetchRequest *marketStaff = [NSFetchRequest fetchRequestWithEntityName:@"MarketStaff"];
	if ([[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:marketStaff error:&error] count] == 0)
	{
		MarketStaff *one = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		one.name = @"Employee 1";
		one.position = PositionManager;
		
		MarketStaff *two = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		two.name = @"Employee 2";
		two.position = PositionManager;
		
		MarketStaff *three = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		three.name = @"Volunteer 1";
		three.position = PositionVolunteer;
		
		MarketStaff *four = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		four.name = @"Volunteer 2";
		four.position = PositionVolunteer;
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated staff");
		results = [results stringByAppendingString:@"Added sample staff\n"];
	}
	
	NSFetchRequest *vendors = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	if ([[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count] == 0)
	{
		Vendors *vendor1 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		vendor1.businessName = @"Aaron’s Apples";
		
		Vendors *vendor2 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		vendor2.businessName = @"Betty’s Blueberries";
		
		Vendors *vendor3 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		vendor3.businessName = @"Carol’s Corn";
		
		Vendors *vendor4 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		vendor4.businessName = @"David’s Dirt";
		
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated vendors");
		results = [results stringByAppendingString:@"Added sample vendors\n"];
	}
	
	if (results) [self.textView setText:results];
}

- (IBAction)prepopulatePrompt:(id)sender
{
	UIAlertController *prepopulatePrompt = [UIAlertController alertControllerWithTitle:prepopulateConfirmationTitle message:prepopulateConfirmationMessage preferredStyle:UIAlertControllerStyleAlert];
	[prepopulatePrompt addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[prepopulatePrompt addAction:[UIAlertAction actionWithTitle:@"Prepopulate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self prepopulate];
	}]];
	[self presentViewController:prepopulatePrompt animated:true completion:nil];
}

// TODO: don't depend on switch on file extension on import type, use mimetype or something better
- (IBAction)confirmImportData:(id)sender
{
	if (self.importDestination.selectedSegmentIndex < 0)
	{
		// flash the picker and do nothing
		CABasicAnimation *notifyAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
		[notifyAnimation setFromValue:(id)[[UIColor colorWithRed:1 green:0.848 blue:0.452 alpha:1] CGColor]];
		[notifyAnimation setDuration:1.0f];
		[notifyAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
		[self.importDestination.layer addAnimation:notifyAnimation forKey:@"NotifyAnimation"];
		return;
	}
	
	if (!self.fileToImport && self.importDestination.selectedSegmentIndex == 3)
	{
		UIAlertController *deny = [UIAlertController alertControllerWithTitle:importConfirmationTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
		[deny setTitle:cantImportDumpFromInputTitle];
		[deny setMessage:cantImportDumpFromInputMessage];
		[deny addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:deny animated:true completion:nil];
		return;
	}
	
	UIAlertController *confirm = [UIAlertController alertControllerWithTitle:importConfirmationTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
	[confirm addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	
	if ([[[self.fileToImport pathExtension] lowercaseString] isEqualToString:@"m3db"])
	{
		[confirm setTitle:dumpImportConfirmationTitle];
		[confirm setMessage:dumpImportConfirmationMessage];
		[confirm addAction:[UIAlertAction actionWithTitle:@"Merge" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			NSLog(@"not implemented");
		}]];
		[confirm addAction:[UIAlertAction actionWithTitle:@"Replace" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			[self importData];
		}]];
	}
	else
	{
		[confirm addAction:[UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self importData];
		}]];
	}

	[self presentViewController:confirm animated:true completion:nil];
}

// heavy lifting
- (void)importData
{
	NSUInteger count = 0;
	switch (self.importDestination.selectedSegmentIndex)
	{
		case 0: // vendors
			count = [[[ImportTool alloc] initWithSkipSetting:self.firstRowSkipSwitch.on] importVendorsFromCSV:self.fileToImport];
			break;
			
		case 1: // staff
			count = [[[ImportTool alloc] initWithSkipSetting:self.firstRowSkipSwitch.on] importStaffFromCSV:self.fileToImport];
			break;
			
		case 2: // locations
			count = [[[ImportTool alloc] initWithSkipSetting:self.firstRowSkipSwitch.on] importLocationsFromCSV:self.fileToImport];
			break;
		
		case 3: // dump
			count = [[[ImportTool alloc] initWithSkipSetting:false] importDump:self.fileToImport];
			break;
	}
	
	if (count > 0)
		[[[UIAlertView alloc] initWithTitle:importSuccessTitle message:[NSString stringWithFormat:importSuccessMessage, count, (count == 1) ? @"y was" : @"ies were"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
}

@end
