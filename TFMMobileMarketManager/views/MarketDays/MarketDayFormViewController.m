//
//  MarketDayFormViewController.m
//  tfmco-mip
//

#import "MarketDayFormViewController.h"

@interface MarketDayFormViewController ()

@end

@implementation MarketDayFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.formController.form = [[MarketDayForm alloc] init];
	
	self.editMode = (self.marketdayID != nil);
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setMarketday:(MarketDays *)[TFM_DELEGATE.managedObjectContext objectWithID:[self marketdayID]]];
		[self setTitle:@"Edit Market Day"];
		
		// populate form with passed data if in edit mode
		MarketDayForm *form = self.formController.form;
		MarketDays *data = self.marketday;
		
		form.location = (Locations *)data.location;
		
		form.vendors = [data.vendors allObjects];
		
		form.date = data.date;
		form.start_time = [NSDate dateWithTimeIntervalSince1970:data.start_time];
		form.end_time = [NSDate dateWithTimeIntervalSince1970:data.end_time];
		
		form.staff = [data.staff allObjects];
		form.notes = data.notes;
	}
	else [self setTitle:@"New Market Day"];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	UIBarButtonItem *openButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startMarketDayPrompt)];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submit)];
	
	self.navigationItem.leftBarButtonItem = closeButton;
	self.navigationItem.rightBarButtonItems = [self editMode] ? [TFM_DELEGATE activeMarketDay] ? @[saveButton] : @[openButton, saveButton] : @[openButton];
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
	if ([[alertView title] isEqualToString:@"Reopen this market day?"])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self startMarketDay];
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
	// validate form
	MarketDayForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.location == nil)
		[errors addObject:@"Choose a location"];
	
	if (form.vendors == nil)
		[errors addObject:@"Choose some vendors"];
	
	if (form.date == nil)
		form.date = [NSDate date]; // force today if unset
	
	if (form.start_time == nil)
		form.start_time = [NSDate date];
	
	if (form.staff == nil || !([form.staff count] > 0))
		[errors addObject:@"Choose some staff"];
	
	// Notes field is allowed to be empty
		
	if ([errors count] > 0)
	{
		// puke
		[[[UIAlertView alloc] initWithTitle:@"More information is needed:" message:[errors componentsJoinedByString:@"\n\n"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		return false;
	}
	else
	{
		if ([self editMode])
		{
			[self.marketday setLocation:form.location];
			
			[self.marketday setVendors:[NSSet setWithArray:form.vendors]];
			
			[self.marketday setDate:form.date];
			[self.marketday setStart_time:[form.start_time timeIntervalSinceReferenceDate]];
			[self.marketday setEnd_time:[form.end_time timeIntervalSinceReferenceDate]];
			
			[self.marketday setStaff:[NSSet setWithArray:form.staff]];
			[self.marketday setNotes:form.notes];
		}
		else
		{
			MarketDays *new = [NSEntityDescription insertNewObjectForEntityForName:@"MarketDays" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			
			new.location = form.location;
			
			new.vendors = [NSSet setWithArray:form.vendors];
			
			new.date = form.date;
			new.start_time = [form.start_time timeIntervalSinceReferenceDate];
			new.end_time = [form.end_time timeIntervalSinceReferenceDate];
			
			new.staff = [NSSet setWithArray:form.staff];
			new.notes = form.notes;
			
			[self setMarketday:new];
			[self setMarketdayID:[new objectID]];
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFM_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", [error localizedDescription]);
			[[[UIAlertView alloc] initWithTitle:@"Error saving:" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
		}
		
		[self dismissViewControllerAnimated:true completion:nil];
		return true;
	}
}

- (void)startMarketDayPrompt
{
	if ([self editMode] && ![TFM_DELEGATE activeMarketDay])
	{
		UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Reopen this market day?" message:@"Changes made on this form will be saved." delegate:self cancelButtonTitle:@"Don’t open" otherButtonTitles:@"Open", nil];
		[prompt show];
	}
	else
	{
		[self startMarketDay];
	}
}

- (void)startMarketDay
{
	if ([self submit])
	{
		NSAssert([self marketday] != nil, @"Don't know which market day to set as active");
		[TFM_DELEGATE setActiveMarketDay:self.marketday];
		[self performSegueWithIdentifier:@"MarketOpenMenuSegue" sender:self];
	}
}

- (void)updateVendorCountLabel:(UITableViewCell<FXFormFieldCell> *)cell
{
	MarketDayForm *form = self.formController.form;
	form.vendorsCount = [form.vendors count];
	[self.tableView reloadData];
	
	NSLog(@"%@", [self.formController class]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
