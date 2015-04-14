//
//  ConsoleViewController.m
//  TFMMobileMarketManager
//

#import "ConsoleViewController.h"

// stolen from http://stackoverflow.com/a/1351090/262640 and placed into a category
// fixes field navigation
@implementation UITextField (Tabbable)

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	NSInteger nextTag = textField.tag + 1;
	// Try to find next responder
	UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
	if (nextResponder) {
		// Found next responder, so set it.
		[nextResponder becomeFirstResponder];
	} else {
		// Not found, so remove keyboard.
		[textField resignFirstResponder];
	}
	return NO; // We do not want UITextField to insert line-breaks.
}

@end

@interface ConsoleViewController ()

@end

@implementation ConsoleViewController

static NSString *invalidRequestTitle = @"Invalid request";
static NSString *invalidRequestMessage = @"The “Table” field is required. The “Predicate” and “Sort by” fields are optional.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Field order (make the "Next" button work)
	[self.tableField addTarget:self.predicateField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.predicateField addTarget:self.sortField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.sortField addTarget:self action:@selector(executeButtonPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (IBAction)clearButtonPressed:(id)sender
{
	[self.output setText:@""];
}

- (IBAction)executeButtonPressed:(id)sender
{
	NSError *error;
	
	@try
	{
		if (!([[self.tableField text] length] > 0))
		{
			UIAlertController *message = [UIAlertController alertControllerWithTitle:invalidRequestTitle message:invalidRequestMessage preferredStyle:UIAlertControllerStyleAlert];
			[message addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
			[self presentViewController:message animated:true completion:nil];
			return;
		}
			
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self.tableField text]];
		
		if ([[self.predicateField text] length] > 0)
			[request setPredicate:[NSPredicate predicateWithFormat:[self.predicateField text]]];
		
		if ([[self.sortField text] length] > 0)
			[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:[self.sortField text] ascending:([self.sortOrderPicker selectedSegmentIndex] == 0)]]];

		NSArray *result = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
		if (error) [NSException raise:@"Core Data error" format:@"%@", error];
		else [self.output setText:[NSString stringWithFormat:@"Request returned %i rows:\n\n%@", [result count], result]];
	}
	@catch (NSException *exception)
	{
		[self.output setText:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
	}
}

- (IBAction)exportButtonPressed:(id)sender
{
	// export self.output to file or something
	// maybe use the Sharing menu?
}

@end
