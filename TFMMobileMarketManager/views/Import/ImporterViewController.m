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

- (void)viewDidLoad
{
	[super viewDidLoad];	
}

- (void)handleOpenURL:(NSURL *)url
{
	[self setFileToImport:url];
	[self.navigationItem setPrompt:[@"Importing " stringByAppendingString:[[self.fileToImport pathComponents] lastObject]]];
	NSLog(@"importer loaded url %@", url);
}

// Fills the database with some sample data
- (void)prepopulate
{
	NSError *error;
	NSFetchRequest *locations = [NSFetchRequest fetchRequestWithEntityName:@"Locations"];
	if ([[TFM_DELEGATE.managedObjectContext executeFetchRequest:locations error:&error] count] == 0)
	{
		Locations *fred = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		fred.name = @"Fredericksburg";
		fred.address = @"Hurkamp Park, Prince Edward St\nFredericksburg, VA 22401";
		
		Locations *spotsy = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		spotsy.name = @"Spotsylvania";
		spotsy.address = @"4240 Plank Rd\nFredericksburg, VA 22407";
		
		if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated locations");
	}
	
	NSFetchRequest *marketStaff = [NSFetchRequest fetchRequestWithEntityName:@"MarketStaff"];
	if ([[TFM_DELEGATE.managedObjectContext executeFetchRequest:marketStaff error:&error] count] == 0)
	{
		MarketStaff *one = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		one.name = @"Employee 1";
		one.position = PositionManager;
		
		MarketStaff *two = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		two.name = @"Employee 2";
		two.position = PositionManager;
		
		MarketStaff *three = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		three.name = @"Volunteer 1";
		three.position = PositionVolunteer;
		
		MarketStaff *four = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		four.name = @"Volunteer 2";
		four.position = PositionVolunteer;
		
		if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated staff");
	}
	
	NSFetchRequest *vendors = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	if ([[TFM_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count] == 0)
	{
		Vendors *vendor1 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		vendor1.businessName = @"Aaron’s Apples";
		
		Vendors *vendor2 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		vendor2.businessName = @"Betty’s Blueberries";
		
		Vendors *vendor3 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		vendor3.businessName = @"Carol’s Corn";
		
		Vendors *vendor4 = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		vendor4.businessName = @"David’s Dirt";
		
		if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"couldn't save: %@", error);
		NSLog(@"prepopulated vendors");
	}
}

- (IBAction)prepopulatePrompt:(id)sender
{
	[[[UIAlertView alloc] initWithTitle:prepopulateConfirmationTitle message:prepopulateConfirmationMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (IBAction)importData:(UIButton *)sender {
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

@end
