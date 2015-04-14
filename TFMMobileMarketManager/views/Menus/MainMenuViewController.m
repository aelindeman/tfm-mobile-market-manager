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
			@{@"title": @"Create and view reports", @"icon": @"reports", @"action": @"ReportsSegue"},
			// @{@"title": @"Synchronize database with a PC", @"icon": @"sync", @"action": @"SyncSegue"},
			@{@"title": @"Import data from spreadsheet", @"icon": @"put", @"action": @"ImportSegue"},
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
		
		return [NSString stringWithFormat:@"Version info:\n\t%@\n\trev %@\n\tbuilt %@\n\nDevice identifier:\n\t%@", [[NSBundle mainBundle] bundleIdentifier], version, [df stringFromDate:builtAt], [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
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
	UIAlertController *deletePrompt = [UIAlertController alertControllerWithTitle:@"Destroy the database?" message:@"All data in the database will be permanently obilterated from existence." preferredStyle:UIAlertControllerStyleAlert];
	[deletePrompt addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[deletePrompt addAction:[UIAlertAction actionWithTitle:@"Destroy" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self resetDatabase];
	}]];
	[self presentViewController:deletePrompt animated:true completion:nil];
}

- (void)resetDatabase
{
	// reset the database
	NSPersistentStore *store = [TFMM3_APP_DELEGATE.persistentStoreCoordinator.persistentStores lastObject];
	
	NSError *error;
	[TFMM3_APP_DELEGATE.persistentStoreCoordinator removePersistentStore:store error:&error];
	[[NSFileManager defaultManager] removeItemAtURL:store.URL error:&error];
	
	if (error) NSLog(@"database couldn’t be destroyed: %@", error);
	NSLog(@"destroyed the database, starting fresh...");
	if (![TFMM3_APP_DELEGATE.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:&error])
		NSLog(@"couldn’t recreate database: %@", error);
	
	UIAlertController *postDeleteMessage = [UIAlertController alertControllerWithTitle:@"Database cleared." message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[postDeleteMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:postDeleteMessage animated:true completion:nil];}

- (IBAction)segueToMarketOpenMenu:(UIStoryboardSegue *)unwindSegue
{
	UINavigationController *menu = [[UIStoryboard storyboardWithName:@"MarketOpen" bundle:nil] instantiateInitialViewController];
	[menu setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.navigationController presentViewController:menu animated:true completion:^{
		NSLog(@"market day opened: %@", TFMM3_APP_DELEGATE.activeMarketDay);
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ImportSegue"] && [sender class] == [NSURL class])
	{
		// TODO: implement handleOpenURL in MainMenuViewController and call segue from there, instead of doing that in the app delegate
		// forward handleOpenURL
		NSLog(@"handoff handleOpenURL to importer view");
		[segue.destinationViewController handleOpenURL:sender];
	}
}

@end
