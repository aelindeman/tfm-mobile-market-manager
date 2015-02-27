//
//  LocationsListViewController.m
//  tfmco-mip
//

#import "LocationsListViewController.h"

@interface LocationsListViewController ()

@end

@implementation LocationsListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.allowsMultipleSelectionDuringEditing = false;
	[self load];
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Locations"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:TFM_DELEGATE.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	[self.fetchedResultsController setDelegate:self];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"error populating table: %@", error);
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

// essentially boilerplate strait from Apple documentation
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type)
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

// configure table cells
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Locations *info = [_fetchedResultsController objectAtIndexPath:indexPath];
	NSString *plural = ([info.marketdays count] != 1) ? @"s" : @"";
	[cell.textLabel setText:info.name];
	[cell.detailTextLabel setText:[NSString stringWithFormat:@"%i market day%@", [info.marketdays count], plural]];
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

// action to perform when a cell is tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self performSegueWithIdentifier:@"EditLocationSegue" sender:uid];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// allow swipes for deleting rows
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView beginUpdates];
	
	switch (editingStyle)
	{
		case UITableViewCellEditingStyleNone:
			break;
			
		case UITableViewCellEditingStyleInsert:
			// insertion has already been handled by the form view
			break;
			
		case UITableViewCellEditingStyleDelete:
			//TODO: confirm deletion
			[TFM_DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
			break;
	}
	
	NSError *error;
	if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"error committing edit: %@", error);
	
	[self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddLocationSegue"])
	{

	}
	if ([segue.identifier isEqualToString:@"EditLocationSegue"])
	{
		LocationsFormViewController *lfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[lfvc setEditObjectID:sender];
	}
}

@end
