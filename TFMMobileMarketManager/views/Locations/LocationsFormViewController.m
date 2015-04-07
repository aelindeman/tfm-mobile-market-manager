//
//  LocationsFormViewController.m
//  tfmco-mip
//

#import "LocationsFormViewController.h"

@interface LocationsFormViewController ()

@end

@implementation LocationsFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.formController.form = [[LocationsForm alloc] init];
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(Locations *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:[NSString stringWithFormat:@"Edit “%@”", [self.editObject name]]];
		
		// populate form with passed data if in edit mode
		LocationsForm *form = self.formController.form;
		Locations *data = self.editObject;
		
		form.name = data.name;
		form.address = data.address;
	}
	else [self setTitle:@"Add Location"];
	
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

- (void)discard
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Cancel form entry?" message:@"Any data entered on this form will not be saved." delegate:self cancelButtonTitle:@"Don’t close" otherButtonTitles:@"Close", nil];
	[prompt show];
}

- (void)submit
{
	// validate
	LocationsForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.name == nil || !([form.name length] > 0))
		[errors addObject:@"Name cannot be blank"];
	
	if (form.address == nil || !([form.address length] > 0))
		[errors addObject:@"Address cannot be blank"];
	
	if ([errors count] > 0)
	{
		// puke
		NSLog(@"form failed validation");
		[[[UIAlertView alloc] initWithTitle:@"More information is needed:" message:[errors componentsJoinedByString:@"\n\n"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
	}
	else
	{
		if ([self editMode])
		{
			[self.editObject setName:form.name];
			[self.editObject setAddress:form.address];
		}
		else
		{
			Locations *new = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			new.name = form.name;
			new.address = form.address;
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", [error localizedDescription]);
			[[[UIAlertView alloc] initWithTitle:@"Error saving:" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
			return;
		}
		
		// unwind segue back to table view
		[self dismissViewControllerAnimated:true completion:nil];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
