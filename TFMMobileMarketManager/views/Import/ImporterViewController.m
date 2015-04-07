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

static NSString *importConfirmationTitle = @"Import data?";
static NSString *importConfirmationMessage = @"%i entr%@ will be imported."; // first token: entry count, second token: pluralize -> (entryCount == 1) ? @"y" : @"ies"

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (self.fileToImport)
	{
		// simple determine type of import based on filename
		NSDictionary *types = @{@"staff": @0, @"employee": @0, @"vendor": @1, @"business": @1, @"location": @2, @"market": @2, @"marketstaff": @0};
		for (NSString *key in types)
		{
			NSRange range = [[[[self.fileToImport pathComponents] lastObject] lowercaseString] rangeOfString:[key lowercaseString]];
			if (range.length > 0)
			{
				NSLog(@"assuming import type is %i because filename “%@” contained “%@”", [[types valueForKey: key] intValue], [[self.fileToImport pathComponents] lastObject], key);
				[self.importDestination setSelectedSegmentIndex:[[types valueForKey:key] intValue]];
				break;
			}
		}
		
		// load file into main text view
		NSError *error;
		[self.textView setText:[NSString stringWithContentsOfFile:[self.fileToImport path] encoding:NSUTF8StringEncoding error:&error]];
		if (error) NSLog(@"error while loading url: %@", error);
		
		// prevent editing opened data
		[self.textView setEditable:false];
	}
}

// loads file into text view
- (void)handleOpenURL:(NSURL *)url
{
	[self setFileToImport:url];
	[self.navigationItem setPrompt:[@"Importing " stringByAppendingString:[[self.fileToImport pathComponents] lastObject]]];
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
	[[[UIAlertView alloc] initWithTitle:prepopulateConfirmationTitle message:prepopulateConfirmationMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:prepopulateConfirmationTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
			{
				[self prepopulate];
				break;
			}
		}
	}
}

// heavy lifting
- (IBAction)importData:(UIButton *)sender
{
	if (self.importDestination.selectedSegmentIndex < 0)
	{
		[[[UIAlertView alloc] initWithTitle:noDestinationSelectedTitle message:noDestinationSelectedMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return;
	}
	NSLog(@"attempting to import data");
}

@end
