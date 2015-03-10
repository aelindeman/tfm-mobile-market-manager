//
//  TransactionFormViewController.m
//  tfmco-mip
//

#import "TransactionFormViewController.h"

@interface TransactionFormViewController ()

@end

@implementation TransactionFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");

	self.formController.form = [[TransactionForm alloc] init];

	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(Transactions *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:@"Edit Transaction"];
		
		// populate form with passed data if in edit mode
		TransactionForm *form = self.formController.form;
		Transactions *data = self.editObject;
		
		form.cust_zipcode = data.cust_zipcode;
		form.cust_id = data.cust_id;
		
		form.cust_frequency = data.cust_frequency;
		form.cust_referral = data.cust_referral;
		form.cust_gender = data.cust_gender;
		form.cust_senior = data.cust_senior;
		form.cust_ethnicity = data.cust_ethnicity;
		
		form.credit_used = data.credit_used;
		form.credit_amount = data.credit_total - data.credit_fee;
		form.credit_fee = data.credit_fee;
		form.credit_total = data.credit_total;
		
		form.snap_used = data.snap_used;
		form.snap_amount = data.snap_total - data.snap_bonus;
		form.snap_bonus = data.snap_bonus;
		form.snap_total = data.snap_total;
		
		form.markedInvalid = data.markedInvalid;
	}
	else [self setTitle:@"Add Transaction"];
	
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
	TransactionForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];

	if (form.cust_zipcode == nil || [form.cust_zipcode length] != 5)
		[errors addObject:@"ZIP code must be 5 digits"];
		
	if (form.cust_id > 9999)
		[errors addObject:@"ID must be the last 4 digits on their driver’s license"];
		
	if (form.cust_frequency == FrequencyNone)
		[errors addObject:@"Choose a visit frequency"];
	
	// Referral information isn't required
	
	if (form.cust_ethnicity == EthnicityNone)
		[errors addObject:@"Choose an ethnicity"];
	
	if (!form.credit_used && !form.snap_used)
		[errors addObject:@"Transaction must have payment information"];
	
	// this shouldn't be possible, but refuse anyway
	if (form.credit_used && form.snap_used)
		[errors addObject:@"Transaction cannot use both snap and credit, make two seperate transactions"];

	if ((form.credit_used && !form.credit_amount) || (form.snap_used && !form.snap_amount))
		[errors addObject:[NSString stringWithFormat:@"Specify an amount for the %@ transaction", (form.credit_used ? @"credit" : (form.snap_used ? @"SNAP" : @"either credit or SNAP"))]];
	
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
			[self.editObject setCust_zipcode:form.cust_zipcode];
			[self.editObject setCust_id:form.cust_id];
			
			[self.editObject setCust_frequency:form.cust_frequency];
			[self.editObject setCust_referral:form.cust_referral];
			[self.editObject setCust_gender:form.cust_gender];
			[self.editObject setCust_senior:form.cust_senior];
			[self.editObject setCust_ethnicity:form.cust_ethnicity];
			
			[self.editObject setCredit_used:form.credit_used];
			[self.editObject setCredit_fee:form.credit_fee];
			[self.editObject setCredit_total:form.credit_total];
			
			[self.editObject setSnap_used:form.snap_used];
			[self.editObject setSnap_bonus:form.snap_bonus];
			[self.editObject setSnap_total:form.snap_total];
			
			[self.editObject setMarkedInvalid:form.markedInvalid];
		}
		else
		{
			// load it up
			Transactions *new = [NSEntityDescription insertNewObjectForEntityForName:@"Transactions" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			new.cust_zipcode = form.cust_zipcode;
			new.cust_id = form.cust_id;
			
			new.cust_frequency = form.cust_frequency;
			new.cust_referral = form.cust_referral;
			new.cust_gender = form.cust_gender;
			new.cust_senior = form.cust_senior;
			new.cust_ethnicity = form.cust_ethnicity;
			
			new.credit_used = form.credit_used;
			new.credit_fee = form.credit_fee;
			new.credit_total = form.credit_total;
			
			new.snap_used = form.snap_used;
			new.snap_bonus = form.snap_bonus;
			new.snap_total = form.snap_total;
			
			new.markedInvalid = form.markedInvalid;
		
			// don't directly set the market day equal to the active one, in case it is changed later. fetch it fresh from the database
			new.marketday = (MarketDays *)[TFM_DELEGATE.managedObjectContext objectWithID:[TFM_DELEGATE.activeMarketDay objectID]];
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
}

-(void)toggleSnapOrCredit:(UITableViewCell<FXFormFieldCell> *)cell
{
	TransactionForm *form = self.formController.form;
	if ([cell.field.key isEqualToString:@"credit_used"] && [form snap_used])
	{
		// disable snap_used and associated fields
		[form setSnap_used:false];
		[form setSnap_amount:0];
		[form setSnap_bonus:0];
		[form setSnap_total:0];
		[self.formController.tableView reloadData];
	}
	if ([cell.field.key isEqualToString:@"snap_used"] && [form credit_used])
	{
		//should disable credit_used and associated fields
		[form setCredit_used:false];
		[form setCredit_amount:0];
		[form setCredit_fee:0];
		[form setCredit_total:0];
		[self.formController.tableView reloadData];
	}
}

- (void)updateCreditTotal:(UITableViewCell<FXFormFieldCell> *)cell
{
	TransactionForm *form = self.formController.form;
	[form setCredit_total:form.credit_amount + form.credit_fee];
	[self.formController.tableView reloadData];
}

- (void)updateSnapTotal:(UITableViewCell<FXFormFieldCell> *)cell
{
	TransactionForm *form = self.formController.form;
	[form setSnap_total:form.snap_amount + form.snap_bonus];
	[self.formController.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
