//
//  SelectExistingReportViewController.m
//  TFMMobileMarketManager
//

#import "SelectExistingReportViewController.h"

@implementation SelectExistingReportViewController

static NSString *deleteConfirmationMessageTitle = @"Delete this report?";
static NSString *deleteConfirmationMessageDetails = @"The report will be deleted permanently.";

static NSString *deleteAllConfirmationMessageTitle = @"Delete all reports?";
static NSString *deleteAllConfirmationMessageDetails = @"All reports on this device will be deleted permanently.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (!self.basePath) [self setBasePath:[NSString pathWithComponents:@[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path], @"Reports"]]];
	[self load];
	
	// init preview window
	self.previewer = [[QLPreviewController alloc] init];
	[self.previewer setDataSource:self];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	self.navigationItem.leftBarButtonItem = closeButton;
	
	UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(confirmDeleteAll)];
	self.navigationItem.rightBarButtonItem = deleteAllButton;
}

- (void)load
{
	NSAssert(self.basePath, @"self.basePath must be set");

	// walk report directories on disk and list CSVs
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *subs = [fm contentsOfDirectoryAtPath:self.basePath error:&error];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for (NSString *subfolder in subs)
	{
		NSArray *contents = [[fm contentsOfDirectoryAtPath:[NSString pathWithComponents:@[self.basePath, subfolder]] error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self endswith '.csv'"]];
		if ([contents count] > 0)
			[items addObject:@{ @"name": subfolder, @"items": contents }];
	}
	
	[self setItems:items];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[(NSDictionary *)[self.items objectAtIndex:section] objectForKey:@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.items objectAtIndex:section] valueForKey:@"name"];
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
	// make the report type stand out, the rest of the filename is not as important while on the device
	NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:[[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row]];
	
	for (NSString *i in TFMM3_REPORT_TYPES_ALL)
		[name setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:[cell.textLabel.font pointSize]], NSForegroundColorAttributeName: [UIColor purpleColor]} range:[[name string] rangeOfString:i]];
	[cell.textLabel setAttributedText:name];
	
	// TODO: fix so detail label is not dependent on label text - may have to change inner items NSArray to NSDictionary
	// set detail label to report creation date
	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString pathWithComponents:@[self.basePath, [[self.items objectAtIndex:indexPath.section] objectForKey:@"name"], [name string]]] error:nil];
	NSDateFormatter *reportTimeFormat = [[NSDateFormatter alloc] init];
	[reportTimeFormat setDateFormat:@"'Created' yyyy-MM-dd HH:mm:ss"];
	NSString *gentime = [reportTimeFormat stringFromDate:[fileAttribs objectForKey:NSFileCreationDate]];
	[cell.detailTextLabel setText:gentime];
	
	return cell;
}

// enable swipe-to-delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return true;
}

// handle edit commits (delete only for this table view)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView beginUpdates];

	switch (editingStyle)
	{
		case UITableViewCellEditingStyleDelete:
		{
			NSString *marketday = [[self.items objectAtIndex:indexPath.section] valueForKey:@"name"];
			NSString *name = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
			NSString *resolvedPath = [NSString pathWithComponents:@[self.basePath, marketday, name]];
			
			NSError *error;
			[[NSFileManager defaultManager] removeItemAtPath:resolvedPath error:&error];
			if (error) [[[UIAlertView alloc] initWithTitle:@"Error deleting report:" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
			else
			{
				// delete the item
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
				
				// delete the section too if it was the last item
				if ([[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] count] == 1)
					[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
				
				// reload the table
				[self load];
			}
			
			break;
		}
		
		case UITableViewCellEditingStyleInsert:
		case UITableViewCellEditingStyleNone:
			break;
	}
	
	[self.tableView endUpdates];
}

// trigger segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *marketday = [[self.items objectAtIndex:indexPath.section] valueForKey:@"name"];
	NSString *name = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
	
	NSString *resolvedPath = [NSString pathWithComponents:@[self.basePath, marketday, name]];
	[self setSelectedObject:resolvedPath];
	[self.previewer reloadData];
	
	[self presentViewController:self.previewer animated:true completion:nil];
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

// set data path for previewer
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return self.selectedObject ? [NSURL fileURLWithPath:self.selectedObject] : nil;
}

// set number of objects in previewer - should only be 1
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return !!self.selectedObject;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// TODO: implement delete confirmation
	if ([[alertView title] isEqualToString:deleteConfirmationMessageTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				// delete
				break;
		}
	}
	if ([[alertView title] isEqualToString:deleteAllConfirmationMessageTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self deleteAll];
				[self load];
				[self.tableView reloadData];
				break;
		}
	}
}

- (void)confirmDeleteAll
{
	[[[UIAlertView alloc] initWithTitle:deleteAllConfirmationMessageTitle message:deleteAllConfirmationMessageDetails delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)deleteAll
{
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *subs = [fm contentsOfDirectoryAtPath:self.basePath error:&error];
	if (error) NSLog(@"error traversing directory: %@", error);
	
	for (NSString *subfolder in subs)
	{
		NSArray *contents = [[fm contentsOfDirectoryAtPath:[NSString pathWithComponents:@[self.basePath, subfolder]] error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self endswith '.csv'"]];
		for (NSString *r in contents)
		{
			[[NSFileManager defaultManager] removeItemAtPath:[NSString pathWithComponents:@[self.basePath, subfolder, r]] error:&error];
			if (error) NSLog(@"error deleting report: %@", error);
		}
		
		// delete folders too if empty
		if ([contents count] < 1)
		{
			[[NSFileManager defaultManager] removeItemAtPath:[NSString pathWithComponents:@[self.basePath, subfolder]] error:&error];
		}
	}
}

- (void)discard
{
	[self dismissViewControllerAnimated:true completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
