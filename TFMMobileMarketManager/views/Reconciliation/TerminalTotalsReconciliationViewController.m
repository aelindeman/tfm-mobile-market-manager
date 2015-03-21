//
//  TerminalTotalsReconciliationViewController.m
//  TFMMobileMarketManager
//

#import "TerminalTotalsReconciliationViewController.h"

@interface TerminalTotalsReconciliationViewController ()

@end

@implementation TerminalTotalsReconciliationViewController

static NSString *terminalTotalsCellIdentifier = @"TerminalTotalsCell";
static NSString *calculatedTotalsCellIdentifier = @"CalculatedTotalsCell";
static NSString *menuOptionCellIdentifier = @"MenuOptionCell";

static NSString *helpText =	@"If the totals do not match, it is usually an error involving:\n\t- the terminal not processing a transaction\n\t- a transaction incorrectly marked or not marked as invalid\n\t- a typo either on this device or the terminal";
static NSString *closureText = @"The market day will be closed upon successful reconcilation.";

static NSString *skipMessageTitle = @"Skip terminal total reconciliation?";
static NSString *skipMessageDetails = @"Reconciliation must be completed before synchronization or generating a report for this market day.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// populate the menu
	self.menuSectionHeaders = @[@"On terminal", @"On this device", @""];
	self.menuOptions = @[
		@[
			@{@"title": terminalTotalsCellIdentifier}
		], @[
			@{@"title": calculatedTotalsCellIdentifier}
		], @[
			@{@"title": @"Verify", @"icon": @"check", @"action": @"closeMarketDay"}
		]];
	
	[self.tableView registerNib:[UINib nibWithNibName:@"ReconciliationEntryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:terminalTotalsCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"ReconciliationEntryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:calculatedTotalsCellIdentifier];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skip)];
	self.navigationItem.rightBarButtonItem = skipButton;
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
	switch (section)
	{
		case 1: return helpText;
		case 2: return closureText;
		default: return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	UITableViewCell *cell;
	
	if ([[option valueForKey:@"title"] isEqualToString:terminalTotalsCellIdentifier])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:terminalTotalsCellIdentifier forIndexPath:indexPath];
		
		// TODO: lazy type casting
		[(ReconciliationEntryTableViewCell *)cell setField1Prefix:@"$"];
		[(ReconciliationEntryTableViewCell *)cell setField1Suffix:@".00"];
		[(ReconciliationEntryTableViewCell *)cell setField2Suffix:@" transactions"];
	}
	else if ([[option valueForKey:@"title"] isEqualToString:calculatedTotalsCellIdentifier])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:calculatedTotalsCellIdentifier forIndexPath:indexPath];
		
		// TODO: fix lazy type casting
		[[(ReconciliationEntryTableViewCell *)cell snapField1] setUserInteractionEnabled:false];
		[[(ReconciliationEntryTableViewCell *)cell snapField2] setUserInteractionEnabled:false];
		[[(ReconciliationEntryTableViewCell *)cell creditField1] setUserInteractionEnabled:false];
		[[(ReconciliationEntryTableViewCell *)cell creditField2] setUserInteractionEnabled:false];
		[[(ReconciliationEntryTableViewCell *)cell totalField1] setUserInteractionEnabled:false];
		[[(ReconciliationEntryTableViewCell *)cell totalField2] setUserInteractionEnabled:false];
		
		// distinction between the two cells, two with blue things on the right might be confusing
		[[(ReconciliationEntryTableViewCell *)cell rightView] setBackgroundColor:[UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.000]];

		// calculate totals from transactions
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
		[request setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@ and markedInvalid = false", [TFM_DELEGATE activeMarketDay]]];
		NSArray *tx = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];
		
		unsigned int deviceCreditAmount = 0, deviceCreditTransactionCount = 0, deviceSnapAmount = 0, deviceSnapTransactionCount = 0, deviceTotalAmount = 0;
		for (Transactions *t in tx)
		{
			if ([t credit_used])
			{
				deviceCreditTransactionCount ++;
				deviceCreditAmount += [t credit_total];
				deviceTotalAmount += [t credit_total];
			}
			if ([t snap_used])
			{
				deviceSnapTransactionCount ++;
				deviceSnapAmount += [t snap_total];
				deviceTotalAmount += [t snap_total];
			}
		}
		
		[[(ReconciliationEntryTableViewCell *)cell snapField1] setText:[NSString stringWithFormat:@"$%i.00", deviceSnapAmount]];
		[[(ReconciliationEntryTableViewCell *)cell snapField2] setText:[NSString stringWithFormat:@"%i transaction%@", deviceSnapTransactionCount, (deviceSnapTransactionCount == 1) ? @"" : @"s"]];

		[[(ReconciliationEntryTableViewCell *)cell creditField1] setText:[NSString stringWithFormat:@"$%i.00", deviceCreditAmount]];
		[[(ReconciliationEntryTableViewCell *)cell creditField2] setText:[NSString stringWithFormat:@"%i transaction%@", deviceCreditTransactionCount, (deviceCreditTransactionCount == 1) ? @"" : @"s"]];

		[[(ReconciliationEntryTableViewCell *)cell totalField1] setText:[NSString stringWithFormat:@"$%i.00", deviceTotalAmount]];
		[[(ReconciliationEntryTableViewCell *)cell totalField2] setText:[NSString stringWithFormat:@"%i transaction%@", [tx count], ([tx count] == 1) ? @"" : @"s"]];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:menuOptionCellIdentifier forIndexPath:indexPath];
		[cell.textLabel setText:[option valueForKey:@"title"]];
		[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
		
		if ([option valueForKey:@"icon"])
			[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
		
		if ([option valueForKey:@"bold"])
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
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
	else if ([action isEqualToString:@"closeMarketDay"])
		[self submit];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:skipMessageTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				NSLog(@"market day about to close with user skipping reconciliation!");
				[self dismissViewControllerAnimated:true completion:nil];
				[self performSegueWithIdentifier:@"MainMenuSegue" sender:self];
				break;
		}
	}
}

- (void)discard
{
	[self dismissViewControllerAnimated:true completion:nil];
}

- (void)skip
{
	[[[UIAlertView alloc] initWithTitle:skipMessageTitle message:skipMessageDetails delegate:self cancelButtonTitle:@"Don’t skip" otherButtonTitles:@"Skip", nil] show];
}

- (void)submit
{
	// verify totals match
	
	// then perform unwind segue
	[self dismissViewControllerAnimated:true completion:nil];
	[self performSegueWithIdentifier:@"MainMenuSegue" sender:self];
}

@end
