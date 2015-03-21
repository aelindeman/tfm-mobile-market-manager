//
//  MarketOpenMenuViewController.m
//  tfmco-mip
//

#import "MarketOpenMenuViewController.h"

@interface MarketOpenMenuViewController ()

@end

@implementation MarketOpenMenuViewController

static NSString *infoCellIdentifier = @"MarketDayInfoCell";
static NSString *optionCellIdentifier = @"MenuOptionCell";

// strings shown when reconciliation isn't yet complete
static NSString *terminalTotalsNotDoneWarningTitle = @"Terminal reconcilation has not been completed";
static NSString *terminalTotalsNotDoneWarningMessage = @"There may be a discrepancy between values of the transactions recorded on this device and the card reader.";
static NSString *tokenTotalsNotDoneWarningTitle = @"";
static NSString *tokenTotalsNotDoneWarningMessage = @"";

// strings shown when reconciliation is complete, but isn't correct
static NSString *reconciliationFailureTitle = @"";
static NSString *reconciliationFailureMessage = @"";

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay] != nil, @"No active market day set!");
	
	// populate the menu
	self.menuOptions = @[
		@[
			@{@"title": @"Add a transaction", @"bold": @true, @"icon": @"outbox", @"action": @"AddTransactionSegue"},
			@{@"title": @"Edit transactions", @"icon": @"list", @"action": @"TransactionsSegue"},
		], @[
			@{@"title": @"Add a redemption", @"bold": @true, @"icon": @"inbox", @"action": @"AddRedemptionSegue"},
			@{@"title": @"Edit redemptions", @"icon": @"list", @"action": @"RedemptionsSegue"},
		], @[
			@{@"title": @"Edit market day", @"icon": @"marketday", @"action": @"EditMarketDaySegue"},
			//@{@"title": @"Reconcile token totals", @"icon": @"tokens", @"action": @"TokenTotalsReconciliationFormSegue"},
			@{@"title": @"Reconcile and close market day", @"icon": @"reconcile", @"action": @"TerminalTotalsReconciliationFormSegue"},
		]];

	[self.navigationItem setPrompt:[TFM_DELEGATE.activeMarketDay fieldDescription]];
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
	NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:optionCellIdentifier forIndexPath:indexPath];
	
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
	
	else if ([action isEqualToString:@"closeMarketDay"])
		[[[UIAlertView alloc] initWithTitle:terminalTotalsNotDoneWarningTitle message:terminalTotalsNotDoneWarningMessage delegate:self cancelButtonTitle:@"Return" otherButtonTitles:@"Force close", nil] show];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue *)unwindSegue
{
	[self closeMarketDay];
}

- (void)closeMarketDay
{
	// what the fuck
	[self dismissViewControllerAnimated:true completion:^{
		[TFM_DELEGATE setActiveMarketDay:false];
		[TFM_DELEGATE.managedObjectContext processPendingChanges];
		NSLog(@"market day closed");
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EditMarketDaySegue"])
	{
		MarketDayFormViewController *mdfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[mdfvc setMarketdayID:[TFM_DELEGATE.activeMarketDay objectID]];
	}
	if ([segue.identifier isEqualToString:@"TerminalTotalsReconciliationFormSegue"])
	{
		TerminalTotalsReconciliationFormViewController *term = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[term setEditObjectID:[[TFM_DELEGATE.activeMarketDay terminalTotals] objectID]];
	}
	/* if ([segue.identifier isEqualToString:@"TokenTotalsReconciliationFormSegue"])
	{
		TokenTotalsReconciliationFormViewController *tok = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[tok setEditObjectID:[[TFM_DELEGATE.activeMarketDay tokenTotals] objectID]];
	} */
}

@end
