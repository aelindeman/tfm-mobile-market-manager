//
//  MarketStaffFormViewController.m
//  tfmco-mip
//

#import "MarketStaffFormViewController.h"

@interface MarketStaffFormViewController ()

@end

@implementation MarketStaffFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.formController.form = [[MarketStaffForm alloc] init];
	
	[self setEditMode:([self editObjectID] != nil)];
	if ([self editMode])
	{
		// fetch the object we're supposed to edit
		[self setEditObject:(MarketStaff *)[TFMM3_APP_DELEGATE.managedObjectContext objectWithID:[self editObjectID]]];
		[self setTitle:[NSString stringWithFormat:@"Edit “%@”", [self.editObject name]]];
		
		// populate form with passed data if in edit mode
		MarketStaffForm *form = self.formController.form;
		MarketStaff *data = self.editObject;
		
		form.name = data.name;
		form.phone = data.phone;
		form.email = data.email;
		form.position = data.position;
	}
	else [self setTitle:@"Add Staff"];
	
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

-(bool)submit
{
	// validate
	MarketStaffForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];
	
	if (form.name == nil || !([form.name length] > 0))
		[errors addObject:@"Name cannot be blank"];
	
	NSString *phoneRegex = @"^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}$";
	NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"self matches %@", phoneRegex];
	if (![phoneTest evaluateWithObject:form.phone] || !([form.phone length] > 0))
		[errors addObject:@"Phone number must be valid"];
		
	NSString *emailRegex = @"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"self matches %@", emailRegex];
	if (![emailTest evaluateWithObject:form.email] || !([form.email length] > 0))
		[errors addObject:@"Email address must be valid"];
	
	if (form.position < 0)
		[errors addObject:@"Position cannot be blank"];
	
	if ([errors count] > 0)
	{
		UIAlertController *validationMessage = [UIAlertController alertControllerWithTitle:@"More information is needed" message:[errors componentsJoinedByString:@"\n\n"] preferredStyle:UIAlertControllerStyleAlert];
		[validationMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:validationMessage animated:true completion:nil];
		return false;
	}
	else
	{
		// edit object in place, if in edit mode
		if ([self editMode])
		{
			[self.editObject setName:[form.name capitalizedString]];
			[self.editObject setPhone:[self sanitizePhone:form.phone]];
			[self.editObject setEmail:form.email];
			[self.editObject setPosition:form.position];
		}
		// create a new object otherwise
		else
		{
			MarketStaff *new = [NSEntityDescription insertNewObjectForEntityForName:@"MarketStaff" inManagedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext];
			new.name = [form.name capitalizedString];
			new.phone = [self sanitizePhone:form.phone];
			new.email = form.email;
			new.position = form.position;
		}
		
		// ...and save, hopefully
		NSError *error;
		if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
		{
			NSLog(@"couldn't save: %@", [error localizedDescription]);
			return false;
		}
		
		// unwind segue back to table view
		[self dismissViewControllerAnimated:true completion:nil];
		return true;
	}
}

// removes junk from phone number before inserting into db
- (NSString *)sanitizePhone:(NSString *)input
{
	return [[input componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
