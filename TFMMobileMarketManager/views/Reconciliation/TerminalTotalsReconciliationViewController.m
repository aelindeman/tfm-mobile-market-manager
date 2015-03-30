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

static NSString *skipMessageTitle = @"Skip terminal total reconciliation?";
static NSString *skipMessageDetails = @"Reconciliation must be completed before synchronization or generating a report for this market day.";

static NSString *validationFailedTitle = @"Reconciliation failed";
static NSString *validationFailedMessage = @"There is a discrepancy between the terminal’s totals and this device’s transaction totals.";

unsigned int deviceCreditAmount, deviceCreditTransactionCount,
deviceSnapAmount, deviceSnapTransactionCount,
deviceTotalAmount, deviceTotalTransactionCount;

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	
	// grab terminal totals object from passed identifier
	if (self.editObjectID)
	{
		[self setEditObject:(TerminalTotals *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		//NSLog(@"handoff to TerminalTotals object %@", self.editObjectID);
	}
	
	// for whatever reason the terminal totals object id wasn't passed
	// so first try to fetch it from the active market day
	else if ([TFM_DELEGATE.activeMarketDay terminalTotals])
	{
		[self setEditObject:(TerminalTotals *)[TFM_DELEGATE.activeMarketDay terminalTotals]];
		//NSLog(@"terminal totals were not passed but they were set in market day, using TerminalTotals object %@", [self.editObject objectID]);
	}
	
	// and if it isn't set, just make a new one
	else
	{
		TerminalTotals *tt = [NSEntityDescription insertNewObjectForEntityForName:@"TerminalTotals" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
		[TFM_DELEGATE.activeMarketDay setTerminalTotals:tt];
		[self setEditObject:tt];
		//NSLog(@"terminal totals were not passed and were not set in market day, created new TerminalTotals object %@", [tt objectID]);
	}
	
	// populate the menu
	self.menuSectionHeaders = @[@"On terminal", @"On this device", @""];
	self.menuOptions = @[
		@[
			@{@"title": terminalTotalsCellIdentifier}
		], @[
			@{@"title": calculatedTotalsCellIdentifier}
		], @[
			@{@"title": @"Verify", @"icon": @"check", @"action": @"verify"}
		]];
	
	// calculate totals from transactions
	NSError *error;
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [TFM_DELEGATE activeMarketDay]]];
	NSArray *tx = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	
	if (error)
	{
		[[[UIAlertView alloc] initWithTitle:@"Database error" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		[self discard];
	}
	
	deviceCreditAmount = 0, deviceCreditTransactionCount = 0,
	deviceSnapAmount = 0, deviceSnapTransactionCount = 0,
	deviceTotalAmount = 0, deviceTotalTransactionCount = [tx count];
	
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
	
	// make totals prettier
	[self.tableView registerNib:[UINib nibWithNibName:@"ReconciliationEntryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:terminalTotalsCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"ReconciliationEntryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:calculatedTotalsCellIdentifier];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	// TODO: fix reconcilation able to be skipped - only available for debug
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
		default: return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *option = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	
	if ([[option valueForKey:@"title"] isEqualToString:terminalTotalsCellIdentifier])
	{
		ReconciliationEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:terminalTotalsCellIdentifier forIndexPath:indexPath];
		[self setInputCell:cell];
		
		[cell removePlaceholders];
		
		[cell setField1Prefix:@"Value ($)"];
		[cell setField2Prefix:@"Transactions"];
		
		// populate the data
		if ([self.editObject snap_amount]) [cell.snapField1 setText:[NSString stringWithFormat:@"%i", [self.editObject snap_amount]]];
		if ([self.editObject snap_transactions]) [cell.snapField2 setText:[NSString stringWithFormat:@"%i", [self.editObject snap_transactions]]];
		if ([self.editObject credit_amount]) [cell.creditField1 setText:[NSString stringWithFormat:@"%i", [self.editObject credit_amount]]];
		if ([self.editObject credit_transactions]) [cell.creditField2 setText:[NSString stringWithFormat:@"%i", [self.editObject credit_transactions]]];
		if ([self.editObject total_amount]) [cell.totalField1 setText:[NSString stringWithFormat:@"%i", [self.editObject total_amount]]];
		if ([self.editObject total_transactions]) [cell.totalField2 setText:[NSString stringWithFormat:@"%i", [self.editObject total_transactions]]];
		
		return cell;
	}
	else if ([[option valueForKey:@"title"] isEqualToString:calculatedTotalsCellIdentifier])
	{
		ReconciliationEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:calculatedTotalsCellIdentifier forIndexPath:indexPath];
		[self setDeviceCell:cell];
		
		[cell setField1Prefix:@"Value ($)"];
		[cell setField2Prefix:@"Transactions"];
		
		[cell setUserInteractionEnabled:false];
		
		// distinction between the two cells, two with blue things on the right might be confusing
		[cell.rightView setBackgroundColor:[UIColor colorWithRed:0.329 green:0.329 blue:0.329 alpha:1.000]];
		
		[cell.snapField1 setText:[NSString stringWithFormat:@"%i", deviceSnapAmount]];
		[cell.snapField2 setText:[NSString stringWithFormat:@"%i", deviceSnapTransactionCount]];
		
		[cell.creditField1 setText:[NSString stringWithFormat:@"%i", deviceCreditAmount]];
		[cell.creditField2 setText:[NSString stringWithFormat:@"%i", deviceCreditTransactionCount]];
		
		[cell.totalField1 setText:[NSString stringWithFormat:@"%i", deviceTotalAmount]];
		[cell.totalField2 setText:[NSString stringWithFormat:@"%i", deviceTotalTransactionCount]];
		
		return cell;
	}
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuOptionCellIdentifier forIndexPath:indexPath];
		[cell.textLabel setText:[option valueForKey:@"title"]];
		[cell setAccessoryType:[[option valueForKey:@"action"] hasSuffix:@"Segue"] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
		
		if ([option valueForKey:@"icon"])
			[cell.imageView setImage:[UIImage imageNamed:[option valueForKey:@"icon"]]];
		
		if ([option valueForKey:@"bold"])
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]]];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *selected = [[self.menuOptions objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	NSString *action = [selected valueForKey:@"action"];
	
	// dynamically perform segue if that's what was asked
	if ([action hasSuffix:@"Segue"])
		[self performSegueWithIdentifier:action sender:self];
	
	// or do functions
	else if ([action isEqualToString:@"verify"])
		[self submit];
	
	else NSLog(@"nothing to do for “%@”", [selected valueForKey:@"title"]);
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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
				[self dismissViewControllerAnimated:false completion:nil];
				[self performSegueWithIdentifier:@"MainMenuSegue" sender:self];
				break;
		}
	}
	if ([[alertView title] isEqualToString:@"Cancel form entry?"])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self dismissViewControllerAnimated:true completion:nil];
				break;
		}
	}
}

- (void)discard
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Cancel form entry?" message:@"Any data entered on this form will not be saved." delegate:self cancelButtonTitle:@"Don’t close" otherButtonTitles:@"Close", nil];
	[prompt show];
}

- (void)skip
{
	[[[UIAlertView alloc] initWithTitle:skipMessageTitle message:skipMessageDetails delegate:self cancelButtonTitle:@"Don’t skip" otherButtonTitles:@"Skip", nil] show];
}

- (bool)submit
{
	// validate
	if ([self.inputCell reconcileWith:[self.deviceCell getData]])
	{
		// set terminal totals in db
		[self.editObject setSnap_amount:[self.inputCell.snapField1.text intValue]];
		[self.editObject setSnap_transactions:[self.inputCell.snapField2.text intValue]];
		[self.editObject setCredit_amount:[self.inputCell.creditField1.text intValue]];
		[self.editObject setCredit_transactions:[self.inputCell.creditField2.text intValue]];
		[self.editObject setTotal_amount:[self.inputCell.totalField1.text intValue]];
		[self.editObject setTotal_transactions:[self.inputCell.totalField2.text intValue]];
		
		NSError *error;
		if (![TFM_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", [error localizedDescription]);
			[[[UIAlertView alloc] initWithTitle:@"Error saving:" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
			return false;
		}
		
		// dismiss
		[self.delegate updateTerminalReconcilationStatus:true];
		[self dismissViewControllerAnimated:true completion:^{
			[self.delegate updateInfoLabels];
		}];
		return true;
	}
	else
	{
		[[[UIAlertView alloc] initWithTitle:validationFailedTitle message:validationFailedMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}
}

@end
