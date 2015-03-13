//
//  TokenTotalsReconciliationFormViewController.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationFormViewController.h"

@implementation TokenTotalsReconciliationFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	
	self.formController.form = [[TokenTotalsReconciliationForm alloc] init];
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(TokenTotals *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		
		// populate form with passed data if in edit mode
		TokenTotalsReconciliationForm *form = self.formController.form;
		TokenTotals *data = self.editObject;
		
		form.marketBonusTokenCount = data.market_bonus_tokens;
		form.marketCreditTokenCount = data.market_credit_tokens;
		form.marketSnapTokenCount = data.market_snap_tokens;
		form.redeemedBonusTokenCount = data.redeemed_bonus_tokens;
		form.redeemedCreditTokenCount = data.redeemed_credit_tokens;
		form.redeemedSnapTokenCount = data.redeemed_snap_tokens;
	}
	
	[self setTitle:@"Reconcile Token Totals"];
	
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
	TokenTotalsReconciliationForm *form = self.formController.form;
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
			[self.editObject setMarket_bonus_tokens:form.marketBonusTokenCount];
			[self.editObject setMarket_credit_tokens:form.marketCreditTokenCount];
			[self.editObject setMarket_snap_tokens:form.marketSnapTokenCount];
			[self.editObject setRedeemed_bonus_tokens:form.redeemedBonusTokenCount];
			[self.editObject setRedeemed_credit_tokens:form.redeemedCreditTokenCount];
			[self.editObject setRedeemed_snap_tokens:form.redeemedSnapTokenCount];
		}
		else
		{
			TokenTotals *new = [NSEntityDescription insertNewObjectForEntityForName:@"TokenTotals" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			new.market_bonus_tokens = form.marketBonusTokenCount;
			new.market_credit_tokens = form.marketCreditTokenCount;
			new.market_snap_tokens = form.marketSnapTokenCount;
			new.redeemed_bonus_tokens = form.redeemedBonusTokenCount;
			new.redeemed_credit_tokens = form.redeemedCreditTokenCount;
			new.redeemed_snap_tokens = form.redeemedSnapTokenCount;
			
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

@end
