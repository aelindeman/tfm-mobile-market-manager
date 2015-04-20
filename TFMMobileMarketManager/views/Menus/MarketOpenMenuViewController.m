//
//  MarketOpenMenuViewController.m
//  tfmco-mip
//

#import "MarketOpenMenuViewController.h"

@interface MarketOpenMenuViewController ()

@end

@implementation MarketOpenMenuViewController

@synthesize delegate = _delegate;

static NSString *optionCellIdentifier = @"MenuOptionCell";

static NSString *closeMarketDayWarningTitle = @"Close market day?";
static NSString *closeMarketDayWarningMessage = @"All information will be saved. You can return to this screen later.";

static NSString *closeMarketDayUnreconciledWarningTitle = @"Can’t close market day";
static NSString *closeMarketDayUnreconciledWarningMessage = @"Terminal totals have not been reconciled yet. This must be done before closing the market day.";
static NSString *closeMarketDayUnreconciledWarningLabel = @"Terminal totals need to be reconciled before closing the market day";

static NSString *validationPassedTitle = @"Reconciliation complete";
static NSString *validationPassedMessage = @"The market day can now be closed.\n\nAdding or modifying a transaction will require another reconciliation.";

static NSString *validationFailedTitle = @"Reconciliation failed";
static NSString *validationFailedMessage = @"There is a discrepancy between the terminal’s totals and this device’s transaction totals.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFMM3_APP_DELEGATE activeMarketDay] != nil, @"No active market day set!");
	
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
			@{@"title": @"Reconcile terminal totals", @"icon": @"terminal", @"action": @"TerminalTotalsReconciliationFormSegue"}
		], @[
			@{@"title": @"Close market day", @"icon": @"exit", @"action": @"closeMarketDay"}
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return ((section == [self.menuOptions count] - 1) && !self.terminalTotalsReconciled) ? closeMarketDayUnreconciledWarningLabel : @"";
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
	
	// show reconciliation status on menu options
	if ([[option valueForKey:@"action"] isEqualToString:@"TerminalTotalsReconciliationFormSegue"])
	{
		[cell.textLabel setFont:(self.terminalTotalsReconciled ? [UIFont systemFontOfSize:[cell.textLabel.font pointSize]] : [UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]])];
		if (self.terminalTotalsReconciled) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	
	// disable close market day button if reconciliation hasn't been completed
	if ([[option valueForKey:@"action"] isEqualToString:@"closeMarketDay"])
	{
		[cell.textLabel setTextColor:(self.terminalTotalsReconciled ? [UIColor darkTextColor] : [UIColor lightGrayColor])];
		[cell setUserInteractionEnabled:self.terminalTotalsReconciled];
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
	
	else if ([action isEqualToString:@"closeMarketDay"])
		[self verifyClosure];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)updateInfoLabels
{
	// also update the prompt text
	[self.navigationItem setPrompt:[TFMM3_APP_DELEGATE.activeMarketDay description]];
	
	// TODO: this feels really lazy having only one NSError
	NSError *error;
	
	// vendors header
	NSFetchRequest *vendors = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"%@ in marketdays", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int v = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[self.vendorHeaderLabel setText:[NSString stringWithFormat:@"%i vendor%@", v, (v == 1) ? @"" : @"s"]];
	
	// vendors detail
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsSNAP = true)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int v_snap = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsIncentives = true)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	
	unsigned int v_inc = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	[self.vendorDetailLabel setText:[NSString stringWithFormat:@"%i accept SNAP\n%i accept incentives", v_snap, v_inc]];
	
	// transactions header
	NSFetchRequest *transactions = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", [TFMM3_APP_DELEGATE activeMarketDay]]];
	
	unsigned int t = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	[self.transactionHeaderLabel setText:[NSString stringWithFormat:@"%i transaction%@", t, (t == 1) ? @"" : @"s"]];
	
	// transactions detail
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (snap_used = true)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int t_snap = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (credit_used = true)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int t_credit = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int t_total = 0;
	for (Transactions *tx in [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error])
		t_total += (tx.credit_used ? tx.credit_total : tx.snap_used ? tx.snap_total : 0);
	
	[self.transactionDetailLabel setText:[NSString stringWithFormat:@"%i SNAP\n%i credit\n$%i total", t_snap, t_credit, t_total]];

	// redemptions header
	NSFetchRequest *redemptions = [NSFetchRequest fetchRequestWithEntityName:@"Redemptions"];
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int r = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];
	[self.redemptionHeaderLabel setText:[NSString stringWithFormat:@"%i redemption%@", r, (r == 1) ? @"" : @"s"]];
	
	// redemptions detail
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (check_number > 0)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	unsigned int r_paid = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];

	unsigned int r_total = 0;
	for (Redemptions *rd in [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error])
		r_total += rd.total;
	
	[self.redemptionDetailLabel setText:[NSString stringWithFormat:@"%i paid\n$%i total", r_paid, r_total]];
	
	[self.tableView reloadData];
	
	// TODO: report all label errors to the console and not just the last one
	if (error) NSLog(@"error updating info labels: %@", error);
}

- (void)updateTerminalReconcilationStatus:(bool)status
{
	[self setTerminalTotalsReconciled:status];
	[self.tableView reloadData];
}

- (void)updateTokenReconciliationStatus:(bool)status
{
	[self setTokenTotalsReconciled:status];
	[self.tableView reloadData];

}

- (void)notifyTerminalReconciliationStatus:(bool)status
{
	UIAlertController *reconciliationStatusAlert = [UIAlertController alertControllerWithTitle:status ? validationPassedTitle : validationFailedTitle message:status ? validationPassedMessage : validationFailedMessage preferredStyle:UIAlertControllerStyleAlert];
	[reconciliationStatusAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:reconciliationStatusAlert animated:true completion:nil];
}

- (void)verifyClosure
{
	if (!self.terminalTotalsReconciled)
	{
		UIAlertController *cantCloseMarketDayAlert = [UIAlertController alertControllerWithTitle:closeMarketDayUnreconciledWarningTitle message:closeMarketDayUnreconciledWarningMessage preferredStyle:UIAlertControllerStyleAlert];
		[cantCloseMarketDayAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:cantCloseMarketDayAlert animated:true completion:nil];
	}
	else
	{
		UIAlertController *closeMarketDayPrompt = [UIAlertController alertControllerWithTitle:closeMarketDayWarningTitle message:closeMarketDayWarningMessage preferredStyle:UIAlertControllerStyleAlert];
		[closeMarketDayPrompt addAction:[UIAlertAction actionWithTitle:@"Don’t close" style:UIAlertActionStyleCancel handler:nil]];
		[closeMarketDayPrompt addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self closeMarketDay];
		}]];
		[self presentViewController:closeMarketDayPrompt animated:true completion:nil];
	}
}

// closes the market day gracefully and returns to the main menu
- (void)closeMarketDay
{
	// what the fuck
	[self dismissViewControllerAnimated:true completion:^{
		NSError *error;
		[TFMM3_APP_DELEGATE setActiveMarketDay:false];
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
			NSLog(@"error committing edit: %@", error);
		NSLog(@"market day closed");
	}];
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue *)segue
{
	[self closeMarketDay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EditMarketDaySegue"])
	{
		MarketDayFormViewController *mdfvc = [[[segue destinationViewController] viewControllers] firstObject];
		[mdfvc setDelegate:self];
		[mdfvc setMarketdayID:[TFMM3_APP_DELEGATE.activeMarketDay objectID]];
	}
	
	if ([segue.identifier isEqualToString:@"TerminalTotalsReconciliationFormSegue"])
	{
		TerminalTotalsReconciliationViewController *term = [[[segue destinationViewController] viewControllers] firstObject];
		[term setDelegate:self];
		[term setEditObjectID:[[TFMM3_APP_DELEGATE.activeMarketDay terminalTotals] objectID]];
	}
	
	if ([segue.identifier isEqualToString:@"TokenTotalsReconciliationFormSegue"])
	{
		TokenTotalsReconciliationFormViewController *tok = [[[segue destinationViewController] viewControllers] firstObject];
		// [tok setDelegate:self];
		[tok setEditObjectID:[[TFMM3_APP_DELEGATE.activeMarketDay tokenTotals] objectID]];
	}
	
	if ([segue.identifier isEqualToString:@"AddRedemptionSegue"])
		[(RedemptionFormViewController *)[[[segue destinationViewController] viewControllers] firstObject] setDelegate:self];
	
	if ([segue.identifier isEqualToString:@"AddTransactionSegue"])
		[(TransactionFormViewController *)[[[segue destinationViewController] viewControllers] firstObject] setDelegate:self];
}

@end
