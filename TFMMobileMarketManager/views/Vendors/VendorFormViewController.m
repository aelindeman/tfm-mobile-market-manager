//
//  VendorFormViewController.m
//  TFMMobileMarketManager
//

#import "VendorFormViewController.h"

@interface VendorFormViewController ()

@end

@implementation VendorFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.formController.form = [[VendorForm alloc] init];
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(Vendor *)[TFM_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:[NSString stringWithFormat:@"Edit “%@”", [self.editObject business_name]]];
		
		// populate form with passed data if in edit mode
		VendorForm *form = self.formController.form;
		Vendor *data = self.editObject;
		
		form.business_name = data.business_name;
		form.product_types = data.product_types;
		
		form.name = data.name;
		form.address = data.address;
		form.phone = data.phone;
		form.email = data.email;
		
		form.state_tax_id = data.state_tax_id;
		form.federal_tax_id	= data.federal_tax_id;
	}
	else [self setTitle:@"Add Vendor"];
	
	// create navigation buttons
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

-(void)submit
{
	// validate
	VendorForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.business_name == nil || !([form.business_name length] > 0))
		[errors addObject:@"Business name must be set"];
	
	if (form.product_types == nil || !([form.product_types length] > 0))
		[errors addObject:@"Product types must be set"];
	
	if (form.name == nil || !([form.name length] > 0))
		[errors addObject:@"Business owner’s name must be set"];
	
	if (form.address == nil || !([form.address length] > 0))
		[errors addObject:@"Business address must be set"];
	
	// phone validation regex
	NSString *phoneRegex = @"[0-9]{7}([0-9]{3})?";
	NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
	if (![phoneTest evaluateWithObject:form.phone] || !([form.phone length] > 0))
		[errors addObject:@"Phone number must be valid"];
	
	// email validation regex
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	if (![emailTest evaluateWithObject:form.email] || !([form.email length] > 0))
		[errors addObject:@"Email address must be valid"];
	
	if (form.state_tax_id == nil || !([form.state_tax_id length] > 0))
		[errors addObject:@"State tax ID must be set"];
	
	if (form.federal_tax_id == nil || !([form.federal_tax_id length] > 0))
		[errors addObject:@"Federal tax ID must be set"];
	
	if ([errors count] > 0)
	{
		// puke
		NSLog(@"form failed validation");
		[[[UIAlertView alloc] initWithTitle:@"More information is needed:" message:[errors componentsJoinedByString:@"\n\n"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
	}
	else
	{
		// edit object in place, if in edit mode
		if ([self editMode])
		{
			[self.editObject setBusiness_name:form.business_name];
			[self.editObject setProduct_types:form.product_types];
			
			[self.editObject setName:form.name];
			[self.editObject setAddress:form.address];
			
			[self.editObject setPhone:form.phone];
			[self.editObject setEmail:form.email];
			
			[self.editObject setState_tax_id:form.state_tax_id];
			[self.editObject setFederal_tax_id:form.federal_tax_id];
		}
		// create a new object otherwise
		else
		{
			Vendor *new = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFM_DELEGATE.managedObjectContext];
			
			new.business_name = form.business_name;
			new.product_types = form.product_types;
			
			new.name = form.name;
			new.address = form.address;
			
			new.phone = form.phone;
			new.email = form.email;
			
			new.state_tax_id = form.state_tax_id;
			new.federal_tax_id = form.federal_tax_id;
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFM_DELEGATE.managedObjectContext save:&error])
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
