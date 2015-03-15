//
//  ConsoleViewController.m
//  TFMMobileMarketManager
//

#import "ConsoleViewController.h"

@interface ConsoleViewController ()

@end

@implementation ConsoleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
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
			[[[UIAlertView alloc] initWithTitle:@"Invalid request" message:@"The “Table” field is required. The “Predicate” and “Sort by” fields are optional." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
			return;
		}
			
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self.tableField text]];
		
		if ([[self.predicateField text] length] > 0)
			[request setPredicate:[NSPredicate predicateWithFormat:[self.predicateField text]]];
		
		if ([[self.sortField text] length] > 0)
			[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:[self.sortField text] ascending:([self.sortOrderPicker selectedSegmentIndex] == 0)]]];

		NSArray *result = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
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
