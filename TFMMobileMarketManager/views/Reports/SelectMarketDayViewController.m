//
//  SelectMarketDayViewController.m
//  TFMMobileMarketManager
//

#import "SelectMarketDayViewController.h"

@implementation SelectMarketDayViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self load];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
	UIBarButtonItem *deselectButton = [[UIBarButtonItem alloc] initWithTitle:@"Deselect" style:UIBarButtonItemStylePlain target:self action:@selector(deselect)];
	
	self.navigationItem.leftBarButtonItem = closeButton;
	self.navigationItem.rightBarButtonItem = deselectButton;
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MarketDays"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:false],[NSSortDescriptor sortDescriptorWithKey:@"location.name" ascending:true]]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:TFM_DELEGATE.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	[self.fetchedResultsController setDelegate:self];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"error populating table: %@", error);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MarketDayCell"];
	MarketDays *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:[info fieldDescription]];
	return cell;
}

// trigger segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self.delegate setMarketDayFromID:uid];
	[self dismissViewControllerAnimated:true completion:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)discard
{
	[self dismissViewControllerAnimated:true completion:nil];
}

- (void)deselect
{
	[self.delegate setMarketDayFromID:nil];
	[self dismissViewControllerAnimated:true completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
