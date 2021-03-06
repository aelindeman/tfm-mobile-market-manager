//
//  TokenTotalsReconciliationFormViewController.m
//  TFMMobileMarketManager
//

#import "TokenTotalsReconciliationFormViewController.h"

@implementation TokenTotalsReconciliationFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert(TFMM3_APP_DELEGATE.activeMarketDay, @"No active market day set!");
	
	self.formController.form = [[TokenTotalsReconciliationForm alloc] init];
	
	// grab terminal totals object from passed identifier
	if (self.editObjectID)
	{
		[self setEditObject:(TokenTotals *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:self.editObjectID]];
	}
	
	// for whatever reason the terminal totals object id wasn't passed
	// so first try to fetch it from the active market day
	else if ([TFMM3_APP_DELEGATE.activeMarketDay terminalTotals])
	{
		[self setEditObject:(TokenTotals *)[TFMM3_APP_DELEGATE.activeMarketDay terminalTotals]];
	}
	
	// and if it isn't set, just make a new one
	else
	{
		TokenTotals *tt = [NSEntityDescription insertNewObjectForEntityForName:@"TokenTotals" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
		[TFMM3_APP_DELEGATE.activeMarketDay setTerminalTotals:tt];
		[self setEditObject:tt];
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

- (void)updateTokenDeltas:(UITableViewCell<FXFormFieldCell> *)cell
{
	TokenTotalsReconciliationForm *form = self.formController.form;
	
	form.bonusTokenDifference = form.marketBonusTokenCount - form.redeemedBonusTokenCount;
	form.creditTokenDifference = form.marketCreditTokenCount - form.redeemedCreditTokenCount;
	form.snapTokenDifference = form.marketSnapTokenCount - form.redeemedSnapTokenCount;
	
	self.formController.form = form;
	[self.tableView reloadData];
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
	TokenTotalsReconciliationForm *form = self.formController.form;
	
	[self.editObject setMarket_bonus_tokens:form.marketBonusTokenCount];
	[self.editObject setMarket_credit_tokens:form.marketCreditTokenCount];
	[self.editObject setMarket_snap_tokens:form.marketSnapTokenCount];
	[self.editObject setRedeemed_bonus_tokens:form.redeemedBonusTokenCount];
	[self.editObject setRedeemed_credit_tokens:form.redeemedCreditTokenCount];
	[self.editObject setRedeemed_snap_tokens:form.redeemedSnapTokenCount];
	
	// ...and save, hopefully
	NSError *error;
	if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
	{
		NSLog(@"couldn't save: %@", error);
		return false;
	}
	
	// unwind segue back to table view
	[self dismissViewControllerAnimated:true completion:nil];
	return true;
}

@end
