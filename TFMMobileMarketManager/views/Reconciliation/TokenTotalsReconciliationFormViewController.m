//
//  TokenTotalsReconciliationFormViewController.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationFormViewController.h"

@implementation TokenTotalsReconciliationFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFMM3_APP_DELEGATE activeMarketDay], @"No active market day set!");
	
	self.formController.form = [[TokenTotalsReconciliationForm alloc] init];
	
	// grab terminal totals object from passed identifier
	if (self.editObjectID)
	{
		[self setEditObject:(TokenTotals *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		//NSLog(@"handoff to TokenTotals object %@", self.editObjectID);
	}
	
	// for whatever reason the terminal totals object id wasn't passed
	// so first try to fetch it from the active market day
	else if ([TFMM3_APP_DELEGATE.activeMarketDay terminalTotals])
	{
		[self setEditObject:(TokenTotals *)[TFMM3_APP_DELEGATE.activeMarketDay terminalTotals]];
		//NSLog(@"token totals were not passed but they were set in market day, using TokenTotals object %@", [self.editObject objectID]);
	}
	
	// and if it isn't set, just make a new one
	else
	{
		TokenTotals *tt = [NSEntityDescription insertNewObjectForEntityForName:@"TokenTotals" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		[TFMM3_APP_DELEGATE.activeMarketDay setTerminalTotals:tt];
		[self setEditObject:tt];
		//NSLog(@"token totals were not passed and were not set in market day, created new TokenTotals object %@", [tt objectID]);
	}

	// populate form
	TokenTotalsReconciliationForm *form = self.formController.form;
	
	form.marketBonusTokenCount = self.editObject.market_bonus_tokens;
	form.marketCreditTokenCount = self.editObject.market_credit_tokens;
	form.marketSnapTokenCount = self.editObject.market_snap_tokens;
	form.redeemedBonusTokenCount = self.editObject.redeemed_bonus_tokens;
	form.redeemedCreditTokenCount = self.editObject.redeemed_credit_tokens;
	form.redeemedSnapTokenCount = self.editObject.redeemed_snap_tokens;
	
	[self setTitle:@"Reconcile Token Totals"];
	
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

- (bool)submit
{
	// validate
	TokenTotalsReconciliationForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.marketCreditTokenCount != form.redeemedCreditTokenCount)
		[errors addObject:@"Market credit token count doesn’t match redeemed credit token count"];
		
	if (form.marketSnapTokenCount != form.redeemedSnapTokenCount)
		[errors addObject:@"Market SNAP token count doesn’t match redeemed SNAP token count"];
		
	if (form.marketBonusTokenCount != form.redeemedBonusTokenCount)
		[errors addObject:@"Market bonus token count doesn’t match redeemed bonus token count"];
	
	if ([errors count] > 0)
	{
		// puke
		[[[UIAlertView alloc] initWithTitle:@"More information is needed:" message:[errors componentsJoinedByString:@"\n\n"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}
	else
	{
		[self.editObject setMarket_bonus_tokens:form.marketBonusTokenCount];
		[self.editObject setMarket_credit_tokens:form.marketCreditTokenCount];
		[self.editObject setMarket_snap_tokens:form.marketSnapTokenCount];
		[self.editObject setRedeemed_bonus_tokens:form.redeemedBonusTokenCount];
		[self.editObject setRedeemed_credit_tokens:form.redeemedCreditTokenCount];
		[self.editObject setRedeemed_snap_tokens:form.redeemedSnapTokenCount];
	}
	
	// ...and save, hopefully
	NSError *error;
	if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
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
