//
//  MainMenuViewController.m
//  tfmco-mip
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self prepopulate];
	
	// populate the menu
	self.menuSectionHeaders = @[@"Market Day", @"Edit Information", @"Data Management", @""];
	self.menuOptions = @[
		@[
			@{@"title": @"Start new market day", @"bold": @true, @"icon": @"marketday", @"action": @"NewMarketDayFromMainMenuSegue"},
			@{@"title": @"Reopen a market day", @"icon": @"marketdays", @"action": @"MarketDaysSegue"}
		], @[
			@{@"title": @"Edit vendors", @"icon": @"vendors", @"action": @"VendorsSegue"},
			@{@"title": @"Edit staff", @"icon": @"staff", @"action": @"MarketStaffSegue"},
			@{@"title": @"Edit locations", @"icon": @"locations", @"action": @"LocationsSegue"}
		], @[
			@{@"title": @"Create reports", @"icon": @"reports", @"action": @"ReportsSegue"},
			@{@"title": @"Synchronize database with a PC", @"icon": @"sync", @"action": @"SyncSegue"},
			@{@"title": @"Console", @"icon": @"console", @"action": @"ConsoleSegue"},
			@{@"title": @"Destroy database", @"icon": @"reset", @"action": @"resetDatabasePrompt"}
		], @[
			@{@"title": @"About", @"icon": @"about", @"action": @"AboutSegue"}
		]];
	
	[self setTitle:[@"TFM.co Mobile Market Manager – " stringByAppendingString:[[UIDevice currentDevice] name]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.menuOptions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.menuOptions objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	@try
	{
		return [self.menuSectionHeaders objectAtIndex:section];
	}
	@catch (NSException *e)
	{
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == [self.menuOptions count] - 1)
	{
		NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *compileTime = [NSString stringWithFormat:@"%@ %@", [NSString stringWithUTF8String:__DATE__], [NSString stringWithUTF8String:__TIME__]];
		
		NSDateFormatter *interpreter = [[NSDateFormatter alloc] init];
		[interpreter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		[interpreter setDateFormat:@"MMM d yyyy HH:mm:ss"];
		NSDate *builtAt = [interpreter dateFromString:compileTime];
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		
		return [NSString stringWithFormat:@"Version info:\n\t%@\n\trev %@\n\tbuilt %@", [[NSBundle mainBundle] bundleIdentifier], version, [df stringFromDate:builtAt]];
	}
	else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell" forIndexPath:indexPath];
	NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	
	[cell.textLabel setText:[option valueForKey:@"title"]];
	[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
	
	if ([option valueForKey:@"icon"])
		[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
	
	if ([option valueForKey:@"bold"])
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *selected = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	NSString *action = [selected valueForKey:@"action"];

	// dynamically perform segue if that's what was asked
	if ([action hasSuffix:@"Segue"])
		[self performSegueWithIdentifier:action sender:self];

	// or do functions
	else if ([action isEqualToString:@"resetDatabasePrompt"])
		[self resetDatabasePrompt];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)resetDatabasePrompt
{
	// display a prompt - actual deletion happens in alertView:
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Destroy the database?" message:@"All data in the database will be permanently obilterated from existence." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Destroy", nil];
	[prompt show];
}

- (void)resetDatabase
{
	// reset the database
	NSPersistentStore *store = [TFM_DELEGATE.persistentStoreCoordinator.persistentStores lastObject];
	
	NSError *error;
	[TFM_DELEGATE.persistentStoreCoordinator removePersistentStore:store error:&error];
	[[NSFileManager defaultManager] removeItemAtURL:store.URL error:&error];
	
	if (error) NSLog(@"database couldn’t be destroyed: %@", error);
	NSLog(@"destroyed the database, starting fresh...");
	if (![TFM_DELEGATE.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:&error])
		NSLog(@"couldn’t recreate database: %@", error);
	
	[[[UIAlertView alloc] initWithTitle:@"Database cleared." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:@"Destroy the database?"])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self resetDatabase];
				[self prepopulate];
				break;
		}
	}
}

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

- (IBAction)segueToMarketOpenMenu:(UIStoryboardSegue *)unwindSegue
{
	UINavigationController *menu = [[UIStoryboard storyboardWithName:@"MarketOpen" bundle:nil] instantiateInitialViewController];
	[menu setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.navigationController presentViewController:menu animated:true completion:^{
		NSLog(@"market day opened: %@", TFM_DELEGATE.activeMarketDay);
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
}

@end
