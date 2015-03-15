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

static NSString *reconciliationWarningTitle = @"Terminal and token totals haven’t been reconciled";
static NSString *reconciliationWarningMessage = @"There may be a discrepancy between values of the transactions recorded on this device and the card reader.";

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
			@{@"title": @"Reconcile terminal totals", @"icon": @"terminal", @"action": @"TerminalTotalsReconciliationFormSegue"},
			@{@"title": @"Reconcile token totals", @"icon": @"tokens", @"action": @"TokenTotalsReconciliationFormSegue"},
			@{@"title": @"Edit market day", @"icon": @"marketday", @"action": @"EditMarketDaySegue"},
			@{@"title": @"Close market day", @"icon": @"x", @"action": @"closeMarketDay"}
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
		[[[UIAlertView alloc] initWithTitle:reconciliationWarningTitle message:reconciliationWarningMessage delegate:self cancelButtonTitle:@"Return" otherButtonTitles:@"Close anyway", nil] show];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:reconciliationWarningTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				break;
				
			case 1:
				[self closeMarketDay];
				break;
		}
	}
}

- (void)closeMarketDay
{
	[TFM_DELEGATE setActiveMarketDay:false];
	[self dismissViewControllerAnimated:true completion:nil];
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
	if ([segue.identifier isEqualToString:@"TokenTotalsReconciliationFormSegue"])
	{
		TokenTotalsReconciliationFormViewController *tok = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[tok setEditObjectID:[[TFM_DELEGATE.activeMarketDay tokenTotals] objectID]];
	}
}

@end
