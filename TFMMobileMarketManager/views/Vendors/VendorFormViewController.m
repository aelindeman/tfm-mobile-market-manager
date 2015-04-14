//
//  VendorFormViewController.m
//  tfmco-mip
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
		[self setEditObject:(Vendors *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:[NSString stringWithFormat:@"Edit “%@”", [self.editObject businessName]]];
		
		// populate form with passed data if in edit mode
		VendorForm *form = self.formController.form;
		Vendors *data = self.editObject;
		
		form.businessName = data.businessName;
		form.productTypes = data.productTypes;
		
		form.name = data.name;
		form.address = data.address;
		form.phone = data.phone;
		form.email = data.email;
		
		form.acceptsSNAP = data.acceptsSNAP;
		form.acceptsIncentives = data.acceptsIncentives;
		
		form.stateTaxID = data.stateTaxID;
		form.federalTaxID	= data.federalTaxID;
	}
	else [self setTitle:@"Add Vendor"];
	
	// create navigation buttons
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submit)];
	self.navigationItem.rightBarButtonItem = saveButton;
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

-(void)submit
{
	// validate
	VendorForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.businessName == nil || !([form.businessName length] > 0))
		[errors addObject:@"Business name must be set"];
	
	if (form.productTypes == nil || !([form.productTypes length] > 0))
		[errors addObject:@"Product types must be set"];
	
	if (form.name == nil || !([form.name length] > 0))
		[errors addObject:@"Business owner’s name must be set"];
	
	if (form.address == nil || !([form.address length] > 0))
		[errors addObject:@"Business address must be set"];
	
	// phone validation regex
	NSString *phoneRegex = @"^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}$";
	NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
	if (![phoneTest evaluateWithObject:form.phone] || !([form.phone length] > 0))
		[errors addObject:@"Phone number must be valid"];
	
	// email validation regex
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	if (![emailTest evaluateWithObject:form.email] || !([form.email length] > 0))
		[errors addObject:@"Email address must be valid"];
	
	if (form.stateTaxID == nil || !([form.stateTaxID length] > 0))
		[errors addObject:@"State tax ID must be set"];
	
	if (form.federalTaxID == nil || !([form.federalTaxID length] > 0))
		[errors addObject:@"Federal tax ID must be set"];
	
	if ([errors count] > 0)
	{
		UIAlertController *validationMessage = [UIAlertController alertControllerWithTitle:@"More information is needed" message:[errors componentsJoinedByString:@"\n\n"] preferredStyle:UIAlertControllerStyleAlert];
		[validationMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:validationMessage animated:true completion:nil];
		return;
	}
	else
	{
		// edit object in place, if in edit mode
		if ([self editMode])
		{
			[self.editObject setBusinessName:form.businessName];
			[self.editObject setProductTypes:form.productTypes];
			
			[self.editObject setName:form.name];
			[self.editObject setAddress:form.address];
			[self.editObject setPhone:form.phone];
			[self.editObject setEmail:form.email];
			
			[self.editObject setAcceptsSNAP:form.acceptsSNAP];
			[self.editObject setAcceptsIncentives:form.acceptsIncentives];
			
			[self.editObject setStateTaxID:form.stateTaxID];
			[self.editObject setFederalTaxID:form.federalTaxID];
		}
		// create a new object otherwise
		else
		{
			Vendors *new = [NSEntityDescription insertNewObjectForEntityForName:@"Vendors" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			
			new.businessName = form.businessName;
			new.productTypes = form.productTypes;
			
			new.name = form.name;
			new.address = form.address;
			new.phone = form.phone;
			new.email = form.email;
			
			new.acceptsSNAP = form.acceptsSNAP;
			new.acceptsIncentives = form.acceptsIncentives;
			
			new.stateTaxID = form.stateTaxID;
			new.federalTaxID = form.federalTaxID;
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", error);
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
