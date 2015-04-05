//
//  SelectExistingReportViewController.m
//  TFMMobileMarketManager
//

#import "SelectExistingReportViewController.h"

@implementation SelectExistingReportViewController

static NSString *deleteConfirmationMessageTitle = @"";
static NSString *deleteConfirmationMessageDetails = @"";

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (!self.basePath) [self setBasePath:[NSString pathWithComponents:@[[TFM_DELEGATE.applicationDocumentsDirectory path], @"Reports"]]];
	[self load];
}

- (void)load
{
	NSAssert(self.basePath, @"self.basePath must be set");
	
	// init preview window
	self.previewer = [[QLPreviewController alloc] init];
	[self.previewer setDataSource:self];

	// walk report directories on disk and list CSVs
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *subs = [fm contentsOfDirectoryAtPath:self.basePath error:&error];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for (NSString *subfolder in subs)
	{
		NSArray *contents = [[fm contentsOfDirectoryAtPath:[NSString pathWithComponents:@[self.basePath, subfolder]] error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self endswith '.csv'"]];
		[items addObject:@{ @"name": subfolder, @"items": contents }];
	}
	
	[self setItems:items];
	[self.tableView reloadData];
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
	NSString *name = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
	[cell.textLabel setText:name];
	return cell;
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

// trigger segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *marketday = [[self.items objectAtIndex:indexPath.section] valueForKey:@"name"];
	NSString *name = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
	
	NSString *resolvedPath = [NSString pathWithComponents:@[self.basePath, marketday, name]];
	[self setSelectedObject:resolvedPath];
	[self presentViewController:self.previewer animated:true completion:nil];
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
