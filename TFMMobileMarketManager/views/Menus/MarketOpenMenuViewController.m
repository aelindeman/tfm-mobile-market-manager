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

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay] != nil, @"No active market day set!");
	
	// populate the menu
	self.menuOptions = @[
		@[
			@{@"title": @"MarketDayInfoCell"},
		], @[
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
	UITableViewCell *cell;
	
	if ([[option valueForKey:@"title"] isEqualToString:infoCellIdentifier])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];
		
		// TODO: replace %z% in cell labels
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:optionCellIdentifier forIndexPath:indexPath];
	
		[cell.textLabel setText:[option valueForKey:@"title"]];
		[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
		
		if ([option valueForKey:@"icon"])
			[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
		
		if ([option valueForKey:@"bold"])
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
	}
	
	return cell;
}

/* the info cell should be bigger than the other cells, which should stay at the default height
   I wish there was a way to just GET the default height, but it's 44 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	return ([[option valueForKey:@"title"] isEqualToString:infoCellIdentifier]) ? 110 : 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *selected = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	NSString *action = [selected valueForKey:@"action"];
	
	// dynamically perform segue if that's what was asked
	if ([action hasSuffix:@"Segue"])
		[self performSegueWithIdentifier:action sender:self];
	
	else if ([action isEqualToString:@"closeMarketDay"])
		[[[UIAlertView alloc] initWithTitle:@"Terminal and token totals haven’t been reconciled" message:nil delegate:self cancelButtonTitle:@"Close anyway" otherButtonTitles:@"Don’t close", nil] show];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:@"Terminal and token totals haven’t been reconciled"])
	{
		switch (buttonIndex)
		{
			case 0:
				[self closeMarketDay];
				break;
				
			case 1:
				// canceled
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
