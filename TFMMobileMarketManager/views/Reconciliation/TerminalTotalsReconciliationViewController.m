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

static NSString *validationFailedTitle = @"Reconciliation failed";
static NSString *validationFailedMessage = @"There is a discrepancy between the terminal’s totals and this device’s transaction totals.";

unsigned int deviceCreditAmount, deviceCreditTransactionCount,
deviceSnapAmount, deviceSnapTransactionCount,
deviceTotalAmount, deviceTotalTransactionCount;

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFMM3_APP_DELEGATE activeMarketDay], @"No active market day set!");
	
	// grab terminal totals object from passed identifier
	if (self.editObjectID)
	{
		[self setEditObject:(TerminalTotals *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		//NSLog(@"handoff to TerminalTotals object %@", self.editObjectID);
	}
	
	// for whatever reason the terminal totals object id wasn't passed
	// so first try to fetch it from the active market day
	else if ([TFMM3_APP_DELEGATE.activeMarketDay terminalTotals])
	{
		[self setEditObject:(TerminalTotals *)[TFMM3_APP_DELEGATE.activeMarketDay terminalTotals]];
		//NSLog(@"terminal totals were not passed but they were set in market day, using TerminalTotals object %@", [self.editObject objectID]);
	}
	
	// and if it isn't set, just make a new one
	else
	{
		TerminalTotals *tt = [NSEntityDescription insertNewObjectForEntityForName:@"TerminalTotals" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		[TFMM3_APP_DELEGATE.activeMarketDay setTerminalTotals:tt];
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
		]];
	
	// calculate totals from transactions
	NSError *error;
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [TFMM3_APP_DELEGATE activeMarketDay]]];
	NSArray *tx = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	
	if (error)
	{
		NSLog(@"database error: %@", error);
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
	
	UIBarButtonItem *verifyButton = [[UIBarButtonItem alloc] initWithTitle:@"Verify" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
	self.navigationItem.rightBarButtonItem = verifyButton;
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

- (void)discard
{
	UIAlertController *closePrompt = [UIAlertController alertControllerWithTitle:@"Cancel form entry?" message:@"Any data entered on this form will not be saved." preferredStyle:UIAlertControllerStyleAlert];
	[closePrompt addAction:[UIAlertAction actionWithTitle:@"Don’t close" style:UIAlertActionStyleCancel handler:nil]];
	[closePrompt addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self dismissViewControllerAnimated:true completion:nil];
	}]];
	[self presentViewController:closePrompt animated:true completion:nil];
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
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", [error localizedDescription]);
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
		UIAlertController *validationFailedAlert = [UIAlertController alertControllerWithTitle:validationFailedTitle message:validationFailedMessage preferredStyle:UIAlertControllerStyleAlert];
		[validationFailedAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:validationFailedAlert animated:true completion:nil];
		return false;
	}
}

@end
