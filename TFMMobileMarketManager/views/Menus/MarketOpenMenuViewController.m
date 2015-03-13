//
//  MarketOpenMenuViewController.m
//  tfmco-mip
//

#import "MarketOpenMenuViewController.h"

@interface MarketOpenMenuViewController ()

@end

@implementation MarketOpenMenuViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay] != nil, @"No active market day set!");
	
	// populate the menu
	self.menuSectionHeaders = @[@"Market Day", @"Transactions", @"Redemptions"];
	self.menuOptions = @[
		@[
			@{@"title": @"Edit market day", @"icon": @"marketday", @"action": @"EditMarketDaySegue"},
			@{@"title": @"View token and terminal totals", @"icon": @"totals", @"action": @"viewTotals"},
			@{@"title": @"Close market day", @"bold": @true, @"icon": @"x", @"action": @"CloseMarketDaySegue"}
		], @[
			@{@"title": @"Add a new transaction", @"bold": @true, @"icon": @"outbox", @"action": @"AddTransactionSegue"},
			@{@"title": @"Edit transactions", @"icon": @"list", @"action": @"TransactionsSegue"}
		], @[
			@{@"title": @"Add a redemption", @"bold": @true, @"icon": @"inbox", @"action": @"AddRedemptionSegue"},
			@{@"title": @"Edit redemptions", @"icon": @"list", @"action": @"RedemptionsSegue"}
		]];

	/* UIBarButtonItem *closeMarketButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeMarketDay)];
	[self.navigationItem setRightBarButtonItem:closeMarketButton]; */
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
	//static NSString *infoCellIdentifier = @"MarketOpenMenuInfoCell";
	static NSString *optionCellIdentifier = @"MenuOptionCell";
	
	/* if (indexPath.section == 0 && indexPath.row == 0)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];
		return cell;
	}
	else
	{ */
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:optionCellIdentifier forIndexPath:indexPath];
		NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
		
		[cell.textLabel setText:[option valueForKey:@"title"]];
		[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
		
		if ([option valueForKey:@"icon"])
			[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
		
		if ([option valueForKey:@"bold"])
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
		
		return cell;
	//}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *selected = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	NSString *action = [selected valueForKey:@"action"];
	
	//if ([[selected valueForKey:@"title"] isEqualToString:@"MarketOpenMenuInfoCell"]) return;
	
	// dynamically perform segue if that's what was asked
	if ([action hasSuffix:@"Segue"])
		[self performSegueWithIdentifier:action sender:self];
	
	// or do functions
	else if ([action isEqualToString:@"editNotes"])
	{
		NSLog(@"action set for “%@”, but nothing to be done", action);
	}
	
	else if ([action isEqualToString:@"viewTotals"])
	{
		NSLog(@"action set for “%@”, but nothing to be done", action);
	}
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EditMarketDaySegue"])
	{
		MarketDayFormViewController *mdfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[mdfvc setMarketdayID:[TFM_DELEGATE.activeMarketDay objectID]];
	}
}

@end
