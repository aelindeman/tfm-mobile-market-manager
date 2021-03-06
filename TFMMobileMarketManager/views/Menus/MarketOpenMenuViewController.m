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
static NSString *validationPassedMessage = @"The market day can now be closed.\n\nReconciliation will need to be completed again if any transactions are added or modified.";

static NSString *validationFailedTitle = @"Reconciliation failed";
static NSString *validationFailedMessage = @"There is a discrepancy between the terminal’s totals and this device’s transaction totals.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert(TFMM3_APP_DELEGATE.activeMarketDay != nil, @"No active market day set!");
	
	self.helpViewer = [[QLPreviewController alloc] init];
	[self.helpViewer setDataSource:self];
	
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
			@{@"title": @"Reconcile terminal totals", @"icon": @"terminal", @"action": @"TerminalTotalsReconciliationFormSegue"}, // @"bold" key is ignored
			@{@"title": @"Close market day", @"icon": @"exit", @"action": @"closeMarketDay"}
		], @[
			@{@"title": @"Help", @"icon": @"help", @"action": @"helpViewer"}
		]];
}

// update labels every time the view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateInfoLabels];
}

# pragma mark - UITableView methods

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
	return ((section == [self.menuOptions count] - 2) && !self.terminalTotalsReconciled) ? closeMarketDayUnreconciledWarningLabel : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *option = [[self.menuOptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
		[cell.textLabel setFont:self.terminalTotalsReconciled ? [UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]] : [UIFont systemFontOfSize:[cell.textLabel.font pointSize]]];
		[cell.textLabel setTextColor:(self.terminalTotalsReconciled ? [UIColor darkTextColor] : [UIColor lightGrayColor])];
		[cell setUserInteractionEnabled:self.terminalTotalsReconciled];
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
	
	else if ([action isEqualToString:@"closeMarketDay"])
		[self verifyClosure];
	
	else if ([action isEqualToString:@"helpViewer"])
		[self presentViewController:self.helpViewer animated:true completion:nil];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - Interface elements

- (void)updateInfoLabels
{
	// also update the prompt text
	[self.navigationItem setPrompt:[TFMM3_APP_DELEGATE.activeMarketDay fieldDescription]];
	
	NSError *error;
	NSUInteger v, v_snap, v_inc; // vendor counts
	NSUInteger t, t_snap, t_credit, t_total = 0; // transaction counts
	NSUInteger r, r_paid, r_total = 0; // redemption counts
	
	// vendors header
	NSFetchRequest *vendors = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"%@ in marketdays", TFMM3_APP_DELEGATE.activeMarketDay]];
	v = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	if (error) NSLog(@"error fetching vendors: %@", error);
	[self.vendorHeaderLabel setText:[NSString stringWithFormat:@"%tu vendor%@", v, (v == 1) ? @"" : @"s"]];
	
	// vendors detail
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsSNAP = true)", TFMM3_APP_DELEGATE.activeMarketDay]];
	v_snap = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	if (error) NSLog(@"error fetching vendors: %@", error);
	[vendors setPredicate:[NSPredicate predicateWithFormat:@"(%@ in marketdays) and (acceptsIncentives = true)", TFMM3_APP_DELEGATE.activeMarketDay]];
	
	v_inc = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:vendors error:&error] count];
	if (error) NSLog(@"error fetching vendors: %@", error);
	[self.vendorDetailLabel setText:[NSString stringWithFormat:@"%tu accept SNAP\n%tu accept incentives", v_snap, v_inc]];
	
	// transactions header
	NSFetchRequest *transactions = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", TFMM3_APP_DELEGATE.activeMarketDay]];
	
	t = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	if (error) NSLog(@"error fetching transactions: %@", error);
	[self.transactionHeaderLabel setText:[NSString stringWithFormat:@"%tu transaction%@", t, (t == 1) ? @"" : @"s"]];
	
	// transactions detail
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (snap_used = true)", TFMM3_APP_DELEGATE.activeMarketDay]];
	t_snap = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	if (error) NSLog(@"error fetching transactions: %@", error);
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (credit_used = true)", TFMM3_APP_DELEGATE.activeMarketDay]];
	t_credit = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error] count];
	if (error) NSLog(@"error fetching transactions: %@", error);
	
	[transactions setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", TFMM3_APP_DELEGATE.activeMarketDay]];
	NSArray *txlist;
	if (!(txlist = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:transactions error:&error]))
		NSLog(@"error fetching transactions: %@", error);
	for (Transactions *tx in txlist)
		t_total += (tx.snap_used ? tx.snap_total : tx.credit_used ? tx.credit_total : 0);
	[self.transactionDetailLabel setText:[NSString stringWithFormat:@"%tu SNAP\n%tu credit\n$%tu total", t_snap, t_credit, t_total]];

	// redemptions header
	NSFetchRequest *redemptions = [NSFetchRequest fetchRequestWithEntityName:@"Redemptions"];
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@", TFMM3_APP_DELEGATE.activeMarketDay]];
	r = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];
	if (error) NSLog(@"error fetching redemptions: %@", error);
	[self.redemptionHeaderLabel setText:[NSString stringWithFormat:@"%tu redemption%@", r, (r == 1) ? @"" : @"s"]];
	
	// redemptions detail
	[redemptions setPredicate:[NSPredicate predicateWithFormat:@"((marketday = %@) and (markedInvalid = false)) and (check_number > 0)", TFMM3_APP_DELEGATE.activeMarketDay]];
	r_paid = [[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error] count];
	if (error) NSLog(@"error fetching redemptions: %@", error);

	NSArray *rdlist;
	if (!(rdlist = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:redemptions error:&error]))
		NSLog(@"error fetching redemptions: %@", error);
	for (Redemptions *rd in rdlist)
		r_total += rd.total;
	[self.redemptionDetailLabel setText:[NSString stringWithFormat:@"%tu paid\n$%tu total", r_paid, r_total]];
	
	[[self.tableView tableHeaderView] setNeedsDisplay];
}

- (void)updateTerminalReconciliationStatus:(bool)status
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

#pragma mark - Help file viewer

// set data path for previewer
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return TFMM3_APP_DELEGATE.helpFile;
}

// set number of objects in previewer - should only be 1
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return !!TFMM3_APP_DELEGATE.helpFile;
}

#pragma mark - Segues

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
