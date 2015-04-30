//
//  MarketDayFormViewController.m
//  tfmco-mip
//

#import "MarketDayFormViewController.h"

@interface MarketDayFormViewController ()

@end

@implementation NSArray (WithFieldDescription)

- (NSString *)fieldDescription
{
	return [NSString stringWithFormat:@"%tu selected", [self count]];
}

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
		[self setMarketday:(MarketDays *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:self.marketdayID]];
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
	UIBarButtonItem *openButton = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(startMarketDay)];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submit:)];
	
	self.navigationItem.leftBarButtonItem = closeButton;
	self.navigationItem.rightBarButtonItems = self.editMode ? TFMM3_APP_DELEGATE.activeMarketDay ? @[saveButton] : @[openButton, saveButton] : @[openButton];
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

- (void)dismiss:(bool)thenOpenMarketDay
{
	if (thenOpenMarketDay)
	{
		[self performSegueWithIdentifier:@"MarketOpenMenuSegue" sender:self.marketday];
	}
	else
	{
		[self dismissViewControllerAnimated:true completion:^{
			if (self.delegate) [self.delegate updateInfoLabels];
		}];
	}
}

- (bool)submit:(bool)andOpenMarketDay
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
		UIAlertController *validationMessage = [UIAlertController alertControllerWithTitle:@"More information is needed" message:[errors componentsJoinedByString:@"\n\n"] preferredStyle:UIAlertControllerStyleAlert];
		[validationMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:validationMessage animated:true completion:nil];
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
			MarketDays *new = [NSEntityDescription insertNewObjectForEntityForName:@"MarketDays" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			new.location = form.location;
			
			new.vendors = [NSSet setWithArray:form.vendors];
			
			new.date = form.date;
			new.start_time = [form.start_time timeIntervalSinceReferenceDate];
			new.end_time = [form.end_time timeIntervalSinceReferenceDate];
			
			new.staff = [NSSet setWithArray:form.staff];
			new.notes = form.notes;
			
			new.terminalTotals = [NSEntityDescription insertNewObjectForEntityForName:@"TerminalTotals" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			new.tokenTotals = [NSEntityDescription insertNewObjectForEntityForName:@"TokenTotals" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			[self setMarketday:new];
			[self setMarketdayID:[new objectID]];
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", error);
		}
		
		[self dismiss:andOpenMarketDay];
		return true;
	}
}

- (void)startMarketDay
{
	[self submit:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"MarketOpenMenuSegue"])
	{
		NSAssert([self marketday] != nil, @"Don't know which market day to set as active");
		[self dismissViewControllerAnimated:false completion:^{
			[TFMM3_APP_DELEGATE setActiveMarketDay:self.marketday];
		}];
	}
}

@end
