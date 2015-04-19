//
//  MainMenuViewController.m
//  tfmco-mip
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

static NSString *erasePromptTitle = @"What data would you like to erase?";
static NSString *erasePromptMessage = @"Deleting data is not reversible - it will be permanently destroyed. Consult the user guide for more information on each option.";
static NSString *erasePromptMarketDaysActionText = @"All market days";
static NSString *erasePromptDatabaseActionText = @"Market days, vendors, staff, and locations";
static NSString *erasePromptAllDataText = @"All data";

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
							 @{@"title": @"Create, view, and export reports", @"icon": @"reports", @"action": @"ReportsSegue"},
							 @{@"title": @"Import data", @"icon": @"put", @"action": @"ImportSegue"},
							 // @{@"title": @"Synchronize", @"icon": @"sync", @"action": @"SyncSegue"},
							 @{@"title": @"Console", @"icon": @"console", @"action": @"ConsoleSegue"},
							 @{@"title": @"Erase data", @"icon": @"reset", @"action": @"eraseDataPrompt"}
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
	else if ([action isEqualToString:@"eraseDataPrompt"])
		[self eraseDataPrompt];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)eraseDataPrompt
{
	UIAlertController *prompt = [UIAlertController alertControllerWithTitle:erasePromptTitle message:erasePromptMessage preferredStyle:UIAlertControllerStyleAlert];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Market days" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self eraseMarketDays];
	}]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"All except reports" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self eraseDatabase];
	}]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"All data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self eraseAllData];
	}]];
	[self presentViewController:prompt animated:true completion:nil];
}

- (bool)eraseMarketDays
{
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MarketDays"];
	//[request setEntity:[NSEntityDescription entityForName:@"MarketDays" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext]];
	[request setIncludesPropertyValues:false]; // only fetch the managedObjectID
	
	NSArray *marketDays = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
	for (NSManagedObject *m in marketDays)
		[TFMM3_APP_DELEGATE.managedObjectContext deleteObject:m];
	
	if ([TFMM3_APP_DELEGATE.managedObjectContext save:nil])
	{
		[self eraseCompleteMessage];
		NSLog(@"erased all market days");
		return true;
	}
	
	NSLog(@"erased all market days");
	return false;
}

- (bool)eraseDatabase
{
	// reset the database
	NSPersistentStore *store = [TFMM3_APP_DELEGATE.persistentStoreCoordinator.persistentStores lastObject];
	
	NSError *error;
	[TFMM3_APP_DELEGATE.persistentStoreCoordinator removePersistentStore:store error:&error];
	[[NSFileManager defaultManager] removeItemAtURL:store.URL error:&error];
	
	if (error)
	{
		NSLog(@"database couldn’t be erased: %@", error);
		return false;
	}
	
	if ([TFMM3_APP_DELEGATE.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:&error])
	{
		[self eraseCompleteMessage];
		NSLog(@"created empty database");
		return true;
	}
	
	NSLog(@"couldn’t recreate database: %@", error);
	return false;
}

- (bool)eraseAllData
{
	[self eraseDatabase];
	
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if ([fm fileExistsAtPath:[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path] stringByAppendingPathComponent:@"Reports"]])
		[fm removeItemAtPath:@"Reports" error:&error];
	
	if ([fm fileExistsAtPath:[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path] stringByAppendingPathComponent:@"Inbox"]])
		[fm removeItemAtPath:@"Inbox" error:&error];
	
	if (error) return false;
	else
	{
		[self eraseCompleteMessage];
		NSLog(@"removed Reports and Inbox folder and contents");
		return true;
	}
}

- (void)eraseCompleteMessage
{
	UIAlertController *postDeleteMessage = [UIAlertController alertControllerWithTitle:@"Erase complete." message:nil preferredStyle:UIAlertControllerStyleAlert];
	[postDeleteMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:postDeleteMessage animated:true completion:nil];
}

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
		// TODO: call import action directly to importer view from app delegate, instead of going through the main menu
		NSLog(@"handoff handleOpenURL to importer view");
		[[[segue.destinationViewController viewControllers] firstObject] handleOpenURL:sender];
	}
}

@end
