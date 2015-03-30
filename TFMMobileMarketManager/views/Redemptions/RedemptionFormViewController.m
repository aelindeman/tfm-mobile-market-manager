//
//  RedemptionFormViewController.m
//  tfmco-mip
//

#import "RedemptionFormViewController.h"

@interface RedemptionFormViewController ()

@end

@implementation RedemptionFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	
	self.formController.form = [[RedemptionForm alloc] init];
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(Redemptions *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:@"Edit Redemption"];
		
		// populate form with passed data if in edit mode
		RedemptionForm *form = self.formController.form;
		Redemptions *data = self.editObject;
		
		form.vendor = (Vendors *)data.vendor;
		form.date = data.date;
		form.check_number = data.check_number;

		form.snap_count = data.snap_count;
		form.bonus_count = data.bonus_count;
		form.credit_count = data.credit_count;
		
		form.credit_amount = data.credit_amount;
		form.total = data.total;
		
		form.markedInvalid = data.markedInvalid;
	}
	else [self setTitle:@"Add Redemption"];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submit)];
	self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:@"Cancel form entry?"])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self dismissViewControllerAnimated:true completion:^{
					[self.delegate updateInfoLabels];
				}];
				break;
		}
	}
}

- (void)discard
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Cancel form entry?" message:@"Any data entered on this form will not be saved." delegate:self cancelButtonTitle:@"Don’t close" otherButtonTitles:@"Close", nil];
	[prompt show];
}

- (bool)submit
{
	// validate
	RedemptionForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.vendor == nil)
		[errors addObject:@"Choose a vendor"];
	
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
			[self.editObject setVendor:(Vendors *)form.vendor];
			[self.editObject setDate:form.date];
			[self.editObject setCheck_number:form.check_number];
			
			[self.editObject setSnap_count:form.snap_count];
			[self.editObject setBonus_count:form.bonus_count];
			[self.editObject setCredit_count:form.credit_count];
			
			[self.editObject setCredit_amount:form.credit_amount];
			[self.editObject setTotal:form.total];
			
			[self.editObject setMarkedInvalid:form.markedInvalid];
		}
		else
		{
			Redemptions *new = [NSEntityDescription insertNewObjectForEntityForName:@"Redemptions" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			new.vendor = form.vendor;
			new.date = form.date;
			new.check_number = form.check_number;
			
			new.snap_count = form.snap_count;
			new.bonus_count = form.bonus_count;
			new.credit_count = form.credit_count;
			
			new.credit_amount = form.credit_amount;
			new.total = form.total;
			
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
		[self dismissViewControllerAnimated:true completion:^{
			[self.delegate updateInfoLabels];
		}];
		
		return true;
	}
}

- (void)updateTokenTotals:(UITableViewCell<FXFormFieldCell> *)cell
{
	RedemptionForm *form = self.formController.form;
	NSUInteger credit_token_total = form.credit_count * 5;
	NSUInteger payment_total = form.snap_count + form.bonus_count + (form.credit_count * 5);
	//  @"detailTextLabel.text": [NSString stringWithFormat:@"$%i.00", self.total]
	[form setCredit_amount:credit_token_total];
	[form setTotal:payment_total];
	[self.formController.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
}

@end
