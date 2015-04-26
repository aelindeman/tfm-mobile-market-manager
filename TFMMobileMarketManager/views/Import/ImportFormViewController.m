//
//  ImportFormViewController.m
//  TFMMobileMarketManager
//

#import "ImportFormViewController.h"

@interface ImportFormViewController ()

@end

@implementation ImportFormViewController

static NSString *noDestinationSelectedTitle = @"No destination selected";
static NSString *noDestinationSelectedMessage = @"";

static NSString *importConfirmationTitle = @"Import this data?";
static NSString *importConfirmationMessage = nil;

static NSString *importSuccessTitle = @"Data imported successfully";
static NSString *importSuccessMessage = @"%i entr%@ imported."; // first token: entry count, second token: pluralize -> (count == 1) ? @"y was" : @"ies were"

static bool hasPendingChanges = false;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!self.formController.form)
		self.formController.form = [[ImportForm alloc] init];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(submitPrompt)];
	self.navigationItem.rightBarButtonItem = importButton;
}

// TODO: make work
- (void)loadFromURL:(NSURL *)url
{
	ImportForm *form = self.formController.form;
	[form setUrl:url];

	self.formController.form = form;
	[self.tableView reloadData];
	
	NSLog(@"importer loaded url %@", url);
}

- (void)updateOptions:(UITableViewCell<FXFormFieldCell> *)cell
{
	hasPendingChanges = true;

	ImportForm *form = self.formController.form;
	
	NSString *filename = [form.url lastPathComponent];
	NSString *filetype = [filename pathExtension];
	
	if ([filetype isEqualToString:@"m3db"])
	{
		[form setImportType:ImportTypeDump];
	}
	else if ([filetype isEqualToString:@"csv"] || [filetype isEqualToString:@"m3table"])
	{
		[form setSkipFirstRow:true];
	
		NSDictionary *types = @{
			@"staff": @(ImportTypeStaff),
			@"employee": @(ImportTypeStaff),
			@"vendor": @(ImportTypeVendors),
			@"business": @(ImportTypeVendors),
			@"location": @(ImportTypeLocations),
			@"market": @(ImportTypeLocations)
		};
		
		for (NSString *t in types)
		{
			if ([filename containsString:t])
			{
				[form setImportType:[[types valueForKey:t] intValue]];
				break;
			}
		}
	}
	NSLog(@"selected file at url %@", form.url);
	
	self.formController.form = form;
	[self.tableView reloadData];
}

- (void)submitPrompt
{
	ImportForm *form = self.formController.form;
	NSMutableArray *errors = [[NSMutableArray alloc] init];

	// validate
	if (!form.url)
		[errors addObject:@"Pick a file"];
	
	if ([errors count] > 0)
	{
		UIAlertController *validationMessage = [UIAlertController alertControllerWithTitle:@"More information is needed" message:[errors componentsJoinedByString:@"\n\n"] preferredStyle:UIAlertControllerStyleAlert];
		[validationMessage addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:validationMessage animated:true completion:nil];
	}
	else
	{
		UIAlertController *message = [UIAlertController alertControllerWithTitle:importConfirmationTitle message:importConfirmationMessage preferredStyle:UIAlertControllerStyleAlert];
		[message addAction:[UIAlertAction actionWithTitle:@"Don’t import" style:UIAlertActionStyleCancel handler:nil]];
		[message addAction:[UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self submit];
		}]];
		[self presentViewController:message animated:true completion:nil];
	}
}

- (void)submit
{
	ImportForm *form = self.formController.form;

	NSUInteger count = 0;
	switch (form.importType)
	{
		case ImportTypeVendors:
			count = [[[ImportTool alloc] initWithSkipSetting:form.skipFirstRow] importVendorsFromCSV:form.url];
			break;
			
		case ImportTypeStaff:
			count = [[[ImportTool alloc] initWithSkipSetting:form.skipFirstRow] importStaffFromCSV:form.url];
			break;
			
		case ImportTypeLocations:
			count = [[[ImportTool alloc] initWithSkipSetting:form.skipFirstRow] importLocationsFromCSV:form.url];
			break;
			
		case ImportTypeDump:
			count = [[[ImportTool alloc] initWithSkipSetting:false] importDump:form.url];
			break;
	}
	
	UIAlertController *message = [UIAlertController alertControllerWithTitle:importSuccessTitle message:[NSString stringWithFormat:importSuccessMessage, count, (count == 1) ? @"y was" : @"ies were"] preferredStyle:UIAlertControllerStyleAlert];
	[message addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:message animated:true completion:^{
		hasPendingChanges = false;
	}];
}

- (void)discard
{
	ImportForm *form = self.formController.form;
	if (form.url && hasPendingChanges)
	{
		UIAlertController *closePrompt = [UIAlertController alertControllerWithTitle:@"Cancel import?" message:@"The data will not be added to the database." preferredStyle:UIAlertControllerStyleAlert];
		[closePrompt addAction:[UIAlertAction actionWithTitle:@"Don’t close" style:UIAlertActionStyleCancel handler:nil]];
		[closePrompt addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self dismissViewControllerAnimated:true completion:nil];
		}]];
		[self presentViewController:closePrompt animated:true completion:nil];
	}
	else
	{
		[self dismissViewControllerAnimated:true completion:nil];
	}
}

@end
