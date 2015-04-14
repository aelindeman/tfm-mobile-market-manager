//
//  ReportsMenuViewController.m
//  tfmco-mip
//

#import "ReportsMenuViewController.h"

@implementation ReportsMenuViewController

static NSString *noSelectedMarketDayWarningTitle = @"No market day selected";
static NSString *noSelectedMarketDayWarningMessage = @"To create a report, you need to select a market day first.";

static NSString *reportCreatedTitle = @"Report created";
static NSString *reportCreatedMessage = @"The %@ report was created successfully. Do you want to view it?";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.previewer = [[QLPreviewController alloc] init];
	[self.previewer setDataSource:self];
	
	// populate the menu
	self.menuSectionHeaders = @[@"", @"Reports", @"Raw Data", @"Database"];
	self.menuOptions = @[
		@[
			@{@"title": @"Open an existing report", @"icon": @"report", @"action": @"SelectExistingReportSegue"},
			@{@"title": @"Select market day", @"icon": @"marketday", @"action": @"SelectMarketDaySegue"}
		], @[
			@{@"title": @"Create sales report", @"icon": @"totals", @"action": TFMM3_REPORT_TYPE_SALES},
			@{@"title": @"Create redemptions report", @"icon": @"inbox", @"action": TFMM3_REPORT_TYPE_REDEMPTIONS},
			@{@"title": @"Create demographics report", @"icon": @"demographics", @"action": TFMM3_REPORT_TYPE_DEMOGRAPHICS}
		], @[
			@{@"title": @"Export vendors", @"icon": @"vendors", @"action": TFMM3_REPORT_TYPE_VENDORS},
			@{@"title": @"Export staff", @"icon": @"staff", @"action": TFMM3_REPORT_TYPE_STAFF},
			@{@"title": @"Export locations", @"icon": @"locations", @"action": TFMM3_REPORT_TYPE_LOCATIONS},
		], @[
			@{@"title": @"Dump entire database", @"icon": @"database", @"action": TFMM3_REPORT_TYPE_DUMP}
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
	if (indexPath.section == [self.menuSectionHeaders indexOfObject:@"Reports"] && ![[option valueForKey:@"action"] isEqualToString:@"SelectMarketDaySegue"])
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
			[self.previewer reloadData];
			
			NSString *promptMessage = ([action isEqualToString:TFMM3_REPORT_TYPE_DUMP]) ? @"The dump was created successfully." : [NSString stringWithFormat:reportCreatedMessage, [action lowercaseString]];
			
			UIAlertController *openReportPrompt = [UIAlertController alertControllerWithTitle:reportCreatedTitle message:promptMessage preferredStyle:UIAlertControllerStyleAlert];
			
			if ([action isEqualToString:TFMM3_REPORT_TYPE_DUMP])
			{
				[openReportPrompt addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
			}
			else
			{
				[openReportPrompt addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
				[openReportPrompt addAction:[UIAlertAction actionWithTitle:@"Open report" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
					[self presentViewController:self.previewer animated:true completion:nil];
				}]];
			}
			
			[self presentViewController:openReportPrompt animated:true completion:nil];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// set data path for previewer
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return self.mostRecentReportPath ? [NSURL fileURLWithPath:self.mostRecentReportPath] : nil;
}

// set number of objects in previewer - should only be 1
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return !!self.mostRecentReportPath;
}

- (void)setMarketDayFromID:(NSManagedObjectID *)objectID
{
	if (objectID == nil) [self setSelectedMarketDay:false];
	else [self setSelectedMarketDay:(MarketDays *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:objectID]];
	[self updatePrompt];
	NSLog(@"reports using market day %@", self.selectedMarketDay);
}

// creates a report and returns where it is located
- (NSString *)createReport:(NSString *)type
{
	if ([TFMM3_REPORT_TYPES_MARKETDAY containsObject:type] && !self.selectedMarketDay)
	{
		UIAlertController *message = [UIAlertController alertControllerWithTitle:noSelectedMarketDayWarningTitle message:noSelectedMarketDayWarningMessage preferredStyle:UIAlertControllerStyleAlert];
		[message addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:message animated:true completion:nil];
		return false;
	}

	ReportGenerator *rg = [[ReportGenerator alloc] initWithMarketDay:self.selectedMarketDay];
	NSString *path;
	
	if ([type isEqualToString:TFMM3_REPORT_TYPE_SALES]) path = [rg generateSalesReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_REDEMPTIONS]) path = [rg generateRedemptionsReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_DEMOGRAPHICS]) path = [rg generateDemographicsReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_VENDORS]) path = [rg generateVendorsReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_STAFF]) path = [rg generateStaffReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_LOCATIONS]) path = [rg generateLocationsReport];
	else if ([type isEqualToString:TFMM3_REPORT_TYPE_DUMP]) path = [rg dump];
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
	{
		SelectMarketDayViewController *smdvc = [[segue.destinationViewController viewControllers] firstObject];
		[smdvc setDelegate:self];
		if (self.selectedMarketDay) [smdvc setSelectedObjectID:[self.selectedMarketDay objectID]];
	}
}

@end
