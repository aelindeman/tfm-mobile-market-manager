//
//  ReportsMenuViewController.m
//  tfmco-mip
//

#import "ReportsMenuViewController.h"

@implementation ReportsMenuViewController

static NSString *noSelectedMarketDayWarningTitle = @"No market day selected";
static NSString *noSelectedMarketDayWarningMessage = @"To create a report, you need to select a market day first.";
static NSString *noSelectedMarketDayWarningLabel = @"Sales, redemptions, and demographics reports need a market day selected before they can be created";

static NSString *reportCreatedTitle = @"%@ created";
static NSString *reportCreatedMessage = @"The %@ was created successfully.";

static NSString *reportFailedTitle = @"Couldn’t create report";
static NSString *reportFailedMessage = @"An error occured while making the report: %@";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.previewer = [[QLPreviewController alloc] init];
	[self.previewer setDataSource:self];
	
	// populate the menu
	self.menuSectionHeaders = @[@"", @"Market Day Reports", @"Raw Data", @"Database"];
	self.menuOptions = @[
		@[
			@{@"title": @"Open an existing report", @"icon": @"report", @"action": @"SelectExistingReportSegue"}
		], @[
			@{@"title": @"Select market day", @"icon": @"marketday", @"action": @"SelectMarketDaySegue"}, // @"bold" key is ignored
			@{@"title": @"Create sales report", @"icon": @"totals", @"action": TFMM3_REPORT_TYPE_SALES},
			@{@"title": @"Create redemptions report", @"icon": @"inbox", @"action": TFMM3_REPORT_TYPE_REDEMPTIONS},
			@{@"title": @"Create demographics report", @"icon": @"demographics", @"action": TFMM3_REPORT_TYPE_DEMOGRAPHICS}
		], @[
			@{@"title": @"Export vendors", @"icon": @"vendors", @"action": TFMM3_REPORT_TYPE_VENDORS},
			@{@"title": @"Export staff", @"icon": @"staff", @"action": TFMM3_REPORT_TYPE_STAFF},
			@{@"title": @"Export locations", @"icon": @"locations", @"action": TFMM3_REPORT_TYPE_LOCATIONS},
		], @[
			@{@"title": @"Dump database", @"icon": @"database", @"action": TFMM3_REPORT_TYPE_DUMP}
		]];
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
	return (section == 1 && !self.selectedMarketDay) ? noSelectedMarketDayWarningLabel : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell" forIndexPath:indexPath];
	NSDictionary *option = [[self.menuOptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	[cell.textLabel setText:[option valueForKey:@"title"]];
	[cell.detailTextLabel setHidden:true];
	[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
	
	if ([option valueForKey:@"icon"])
		[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
	
	if ([option valueForKey:@"bold"])
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
	
	// show market day name in market day selection menu item
	if ([[option valueForKey:@"action"] isEqualToString:@"SelectMarketDaySegue"])
	{
		[cell.detailTextLabel setHidden:!self.selectedMarketDay];
		[cell.detailTextLabel setText:self.selectedMarketDay ? [self.selectedMarketDay fieldDescription] : @""];
		[cell.textLabel setFont:self.selectedMarketDay ? [UIFont systemFontOfSize:[cell.textLabel.font pointSize]] : [UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
	}
	
	// disable report creation buttons if there's no market day
	if (indexPath.section == [self.menuSectionHeaders indexOfObject:@"Market Day Reports"] && ![[option valueForKey:@"action"] isEqualToString:@"SelectMarketDaySegue"])
	{
		[cell setUserInteractionEnabled:!!self.selectedMarketDay];
		[cell.textLabel setTextColor:(self.selectedMarketDay) ? [UIColor darkTextColor] : [UIColor lightGrayColor]];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *selected = [[self.menuOptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
			
			NSString *reportType = ([action isEqualToString:TFMM3_REPORT_TYPE_DUMP]) ? @"dump" : @"report";
			NSString *message = [NSString stringWithFormat:reportCreatedMessage, ([action isEqualToString:TFMM3_REPORT_TYPE_DUMP]) ? reportType : [@[[action lowercaseString], reportType] componentsJoinedByString:@" "]];
			
			UIAlertController *openReportPrompt = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:reportCreatedTitle, [reportType capitalizedString]] message:message preferredStyle:UIAlertControllerStyleAlert];
			[openReportPrompt addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
			[openReportPrompt addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"View %@", reportType] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self presentViewController:self.previewer animated:true completion:nil];
			}]];
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
	
	[CATransaction setDisableActions:YES];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationNone];
	[CATransaction setDisableActions:NO];
	
	NSLog(@"reports using market day %@", self.selectedMarketDay);
}

// creates a report and returns where it is located
- (NSString *)createReport:(NSString *)type
{
	// make sure this is an actual report type
	if (![TFMM3_REPORT_TYPES_ALL containsObject:type])
	{
		NSLog (@"unknown report type “%@”", type);
		return false;
	}
	
	// require market days for certain reports; don't rely on greyed-out menu options
	if ([TFMM3_REPORT_TYPES_MARKETDAY containsObject:type] && !self.selectedMarketDay)
	{
		UIAlertController *message = [UIAlertController alertControllerWithTitle:noSelectedMarketDayWarningTitle message:noSelectedMarketDayWarningMessage preferredStyle:UIAlertControllerStyleAlert];
		[message addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:message animated:true completion:nil];
		return false;
	}

	// create the report
	ReportTool *rg = [[ReportTool alloc] initWithMarketDay:self.selectedMarketDay];
	NSString *path =
		[type isEqualToString:TFMM3_REPORT_TYPE_SALES] ? [rg generateSalesReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_REDEMPTIONS] ? [rg generateRedemptionsReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_DEMOGRAPHICS] ? [rg generateDemographicsReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_VENDORS] ? [rg generateVendorsReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_STAFF] ? [rg generateStaffReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_LOCATIONS] ? [rg generateLocationsReport] :
		[type isEqualToString:TFMM3_REPORT_TYPE_DUMP] ? [rg dump]:
		false;
	
	// alert if report generation failed
	if (!path)
	{
		NSString *error = rg.failureReason;
		UIAlertController *reportFailedAlert = [UIAlertController alertControllerWithTitle:reportFailedTitle message:[NSString stringWithFormat:reportFailedMessage, error] preferredStyle:UIAlertControllerStyleAlert];
		[reportFailedAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:reportFailedAlert animated:true completion:nil];
	}
	
	// return path to report
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
