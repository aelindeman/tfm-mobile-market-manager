//
//  MarketOpenMenuViewController.m
//  tfmco-mip
//

#import "MarketOpenMenuViewController.h"

@interface MarketOpenMenuViewController ()

@end

@implementation MarketOpenMenuViewController

@synthesize delegate = _delegate;

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
			@{@"title": @"Reconcile token totals", @"icon": @"tokens", @"action": @"TokenTotalsReconciliationFormSegue"},
			@{@"title": @"Reconcile terminal totals and close market day", @"icon": @"reconcile", @"action": @"TerminalTotalsReconciliationFormSegue"},
		]];
}

// update labels every time the view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateInfoLabels];
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

- (void)updateInfoLabels
{
	// also update the prompt text
	[self.navigationItem setPrompt:[TFM_DELEGATE.activeMarketDay description]];
	
	// TODO: this feels really lazy having only one NSError
	NSError *error;
	
	// vendors header
	NSFetchRequest *vendors = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"%@ in marketdays", [TFM_DELEGATE activeMarketDay]]];
	unsigned int v = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[self.vendorHeaderLabel setText:[NSString stringWithFormat:@"%i vendor%@", v, (v == 1) ? @"" : @"s"]];
	
	// vendors detail
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsSNAP = true)", [TFM_DELEGATE activeMarketDay]]];
	unsigned int v_snap = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsIncentives = true)", [TFM_DELEGATE activeMarketDay]]];
	
	unsigned int v_inc = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[self.vendorDetailLabel setText:[NSString stringWithFormat:@"%i accept SNAP\n%i accept incentives", v_snap, v_inc]];
	
	// transactions header
	NSFetchRequest *transactions = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", [TFM_DELEGATE activeMarketDay]]];
	
	unsigned int t = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	[self.transactionHeaderLabel setText:[NSString stringWithFormat:@"%i transaction%@", t, (t == 1) ? @"" : @"s"]];
	
	// transactions detail
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (snap_used = true)", [TFM_DELEGATE activeMarketDay]]];
	unsigned int t_snap = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (credit_used = true)", [TFM_DELEGATE activeMarketDay]]];
	unsigned int t_credit = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [TFM_DELEGATE activeMarketDay]]];
	unsigned int t_total = 0;
	for (Transactions *tx in [TFM_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error])
		t_total += (tx.credit_used ? tx.credit_total : tx.snap_used ? tx.snap_total : 0);
	
	[self.transactionDetailLabel setText:[NSString stringWithFormat:@"%i SNAP\n%i credit\n$%i total", t_snap, t_credit, t_total]];

	// redemptions header
	NSFetchRequest *redemptions = [NSFetchRequest fetchRequestWithEntityName:@"Redemptions"];
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", [TFM_DELEGATE activeMarketDay]]];
	unsigned int r = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];
	[self.redemptionHeaderLabel setText:[NSString stringWithFormat:@"%i redemption%@", r, (r == 1) ? @"" : @"s"]];
	
	// redemptions detail
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (check_number > 0)", [TFM_DELEGATE activeMarketDay]]];
	unsigned int r_paid = [[TFM_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];

	unsigned int r_total = 0;
	for (Redemptions *rd in [TFM_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error])
		r_total += rd.total;
	
	[self.redemptionDetailLabel setText:[NSString stringWithFormat:@"%i paid\n$%i total", r_paid, r_total]];
	
	// TODO: report all label errors to the console and not just the last one
	if (error) NSLog(@"error updating info labels: %@", error);
}

// closes the market day gracefully and returns to the main menu
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
	if ([segue.identifier isEqualToString:@"AddTransactionSegue"])
	{
		[[[[segue destinationViewController] viewControllers] objectAtIndex:0] setDelegate:self];
	}
	if ([segue.identifier isEqualToString:@"TerminalTotalsReconciliationFormSegue"])
	{
		TerminalTotalsReconciliationViewController *term = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[term setEditObjectID:[[TFM_DELEGATE.activeMarketDay terminalTotals] objectID]];
	}
	if ([segue.identifier isEqualToString:@"TokenTotalsReconciliationFormSegue"])
	{
		TokenTotalsReconciliationFormViewController *tok = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[tok setEditObjectID:[[TFM_DELEGATE.activeMarketDay tokenTotals] objectID]];
	}
}

@end
