//
//  TerminalTotalsReconciliationFormViewController.m
//  TFMMobileMarketManager
//

#import "TerminalTotalsReconciliationFormViewController.h"

@implementation TerminalTotalsReconciliationFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	
	self.formController.form = [[TerminalTotalsReconciliationForm alloc] init];
	TerminalTotalsReconciliationForm *form = self.formController.form;
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(TerminalTotals *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		
		// populate form with passed data if in edit mode
		TerminalTotals *data = self.editObject;
		
		form.terminalCreditAmount = data.credit_amount;
		form.terminalCreditTransactionCount = data.credit_transactions;
		form.terminalSnapAmount = data.snap_amount;
		form.terminalSnapTransactionCount = data.snap_transactions;
		form.terminalTotalAmount = data.total_amount;
		form.terminalTotalTransactionCount = data.total_transactions;
	}
	
	[self setTitle:@"Reconcile Terminal Totals"];
	
	// reset these counters
	form.deviceCreditAmount = form.deviceCreditTransactionCount = form.deviceSnapAmount = form.deviceSnapTransactionCount = form.deviceTotalAmount = form.deviceTotalTransactionCount = 0;
	
	// calculate totals from transactions
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"marketday = %@ and markedInvalid = false", [TFM_DELEGATE activeMarketDay]]];
	NSArray *tx = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:nil];

	form.deviceTotalTransactionCount = [tx count];
	for (Transactions *t in tx)
	{
		if ([t credit_used])
		{
			form.deviceCreditTransactionCount ++;
			form.deviceCreditAmount += [t credit_total];
			form.deviceTotalAmount += [t credit_total];
		}
		if ([t snap_used])
		{
			form.deviceSnapTransactionCount ++;
			form.deviceSnapAmount += [t snap_total];
			form.deviceTotalAmount += [t snap_total];
		}
	}
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submit)];
	self.navigationItem.rightBarButtonItem = saveButton;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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

-(void)discard
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Cancel form entry?" message:@"Any data entered on this form will not be saved." delegate:self cancelButtonTitle:@"Don’t close" otherButtonTitles:@"Close", nil];
	[prompt show];
}

-(bool)submit
{
	// validate
	TerminalTotalsReconciliationForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	// TODO: validation
	
	if ([errors count] > 0)
	{
		// puke
		[[[UIAlertView alloc] initWithTitle:@"More information is needed:" message:[errors componentsJoinedByString:@"\n\n"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}
	else
	{
		if ([self editMode])
		{
			[self.editObject setCredit_amount:form.terminalCreditAmount];
			[self.editObject setCredit_transactions:form.terminalCreditTransactionCount];
			[self.editObject setSnap_amount:form.terminalSnapAmount];
			[self.editObject setSnap_transactions:form.terminalSnapTransactionCount];
			[self.editObject setTotal_amount:form.terminalTotalAmount];
			[self.editObject setTotal_transactions:form.terminalTotalTransactionCount];
		}
		else
		{
			TerminalTotals *new = [NSEntityDescription insertNewObjectForEntityForName:@"TerminalTotals" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			new.credit_amount = form.terminalCreditAmount;
			new.credit_transactions = form.terminalCreditTransactionCount;
			new.snap_amount = form.terminalSnapAmount;
			new.snap_transactions = form.terminalSnapTransactionCount;
			new.total_amount = form.terminalTotalAmount;
			new.total_transactions = form.terminalTotalTransactionCount;
			
			// don't directly set the market day equal to the active one, in case it is changed later. fetch it fresh from the database
			new.marketday = (MarketDays *)[TFM_DELEGATE.managedObjectContext objectWithID:[TFM_DELEGATE.activeMarketDay objectID]];
		}
	}
	
	// ...and save, hopefully
	NSError *error;
	if (![TFM_DELEGATE.managedObjectContext save:&error])
	{
		NSLog(@"couldn't save: %@", [error localizedDescription]);
		[[[UIAlertView alloc] initWithTitle:@"Error saving:" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}
	
	// unwind segue back to table view
	[self dismissViewControllerAnimated:true completion:nil];
	return true;
}

- (void)updateTerminalTotals:(UITableViewCell<FXFormFieldCell> *)cell
{
	TerminalTotalsReconciliationForm *form = self.formController.form;
	[form setTerminalTotalAmount:([form terminalCreditAmount] + [form terminalSnapAmount])];
	[form setTerminalTotalTransactionCount:([form terminalCreditTransactionCount] + [form terminalSnapTransactionCount])];
	[self.formController.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
}

@end
