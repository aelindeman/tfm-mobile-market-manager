//
//  ReportsMenuViewController.m
//  tfmco-mip
//

#import "ReportsMenuViewController.h"

@interface ReportsMenuViewController ()

@end

@implementation ReportsMenuViewController

@synthesize delegate;

static NSString *noSelectedMarketDayWarningTitle = @"No market day selected";
static NSString *noSelectedMarketDayWarningMessage = @"To create a report, you need to select a market day first.";

static NSString *reportCreatedTitle = @"Report created";
static NSString *reportCreatedMessage = @"The %@ report was created successfully. Do you want to view it?";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// populate the menu
	self.menuOptions = @[
		@[
			@{@"title": @"Open an existing report", @"icon": @"export", @"action": @"SelectExistingReportSegue"}
		], @[
			@{@"title": @"Select market day", @"icon": @"marketday", @"action": @"SelectMarketDaySegue"},
			@{@"title": @"Create sales report", @"icon": @"totals", @"action": @"sales"},
			@{@"title": @"Create redemptions report", @"icon": @"inbox", @"action": @"redemptions"},
			@{@"title": @"Create demographics report", @"icon": @"demographics", @"action": @"demographics"}
		]];
	[self updatePrompt];
}

- (void)updatePrompt
{
	[self.navigationItem setPrompt:(self.selectedMarketDay) ? [self.selectedMarketDay description] : nil];
	[self.tableView reloadData];
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
	
	// disable report creation buttons if there's no market day
	if (indexPath.section == 1 && ![[option valueForKey:@"action"] isEqualToString:@"SelectMarketDaySegue"])
	{
		[cell setUserInteractionEnabled:!!self.selectedMarketDay];
		[cell.textLabel setTextColor:(self.selectedMarketDay) ? [UIColor darkTextColor] : [UIColor lightGrayColor]];
	}
	
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
	else
	{
		NSString *path = [self createReport:action];
		if (path)
		{
			[self setMostRecentReportPath:path];
			[[[UIAlertView alloc] initWithTitle:reportCreatedTitle message:[NSString stringWithFormat:reportCreatedMessage, [action lowercaseString]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:reportCreatedTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self performSegueWithIdentifier:@"ReportViewerSegue" sender:nil];
				break;
		}
	}
}

- (void)setMarketDayFromID:(NSManagedObjectID *)objectID
{
	if (objectID == nil) [self setSelectedMarketDay:false];
	else [self setSelectedMarketDay:(MarketDays *)[TFM_DELEGATE.managedObjectContext objectWithID:objectID]];
	[self updatePrompt];
	NSLog(@"reports using market day %@", self.selectedMarketDay);
}

// creates a report and returns where it is located
- (NSString *)createReport:(NSString *)type
{
	if (!self.selectedMarketDay)
	{
		[[[UIAlertView alloc] initWithTitle:noSelectedMarketDayWarningTitle message:noSelectedMarketDayWarningMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}

	ReportGenerator *rg = [[ReportGenerator alloc] initWithMarketDay:self.selectedMarketDay];
	NSString *path;
	
	if ([type isEqualToString:@"sales"]) path = [rg generateSalesReport];
	else if ([type isEqualToString:@"redemptions"]) path = [rg generateRedemptionsReport];
	else if ([type isEqualToString:@"demographics"]) path = [rg generateDemographicsReport];
	else
	{
		NSLog (@"no action set for “%@”", type);
		return false;
	}
	
	return path;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SelectMarketDaySegue"])
		[(SelectMarketDayViewController *)[[segue.destinationViewController viewControllers] firstObject] setDelegate:self];

	if ([segue.identifier isEqualToString:@"SelectExistingReportSegue"])
		[(SelectExistingReportViewController *)[[segue.destinationViewController viewControllers] firstObject] setDelegate:self];
	
	if ([segue.identifier isEqualToString:@"ReportViewerSegue"])
		[(ReportViewerViewController *)segue.destinationViewController setFilePath:self.mostRecentReportPath];
}

@end
