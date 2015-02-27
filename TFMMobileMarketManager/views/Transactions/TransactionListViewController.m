//
//  TransactionListViewController.m
//  tfmco-mip
//

#import "TransactionListViewController.h"

@interface TransactionListViewController ()

@end

@implementation TransactionListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	self.tableView.allowsMultipleSelectionDuringEditing = false;
	[self load];
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Transactions"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(marketday == %@)", [TFM_DELEGATE activeMarketDay]]];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:true]]];
	
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
	id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

// configure table cells - display as first last -> position
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Transactions *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:[NSString stringWithFormat:@"[%f] %04d", info.time, info.cust_id]];
	
	if (info.credit_used)
		[cell.detailTextLabel setText:[NSString stringWithFormat:@"Credit, $%i", info.credit_total]];
	else if (info.snap_used)
		[cell.detailTextLabel setText:[NSString stringWithFormat:@"SNAP, $%i", info.snap_total]];
	else
		[cell.detailTextLabel setText:@"No payment information!"];
	
	if (info.markedInvalid)
	{
		NSDictionary *strike = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
		[cell.textLabel setAttributedText:[[NSAttributedString alloc] initWithString:[cell.textLabel text] attributes:strike]];
		[cell.textLabel setTextColor:[UIColor lightGrayColor]];
		[cell.detailTextLabel setText:[NSString stringWithFormat:@"(Invalid) %@", cell.detailTextLabel.text]];
	}
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionCell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

// trigger edit window segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self performSegueWithIdentifier:@"EditTransactionSegue" sender:uid];
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
		{
			// DON'T DELETE THE OBJECT. Just load it and [obj setDeleted:true]
			Transactions *toDelete = [_fetchedResultsController objectAtIndexPath:indexPath];
			[toDelete setMarkedInvalid:true];
			[[self.tableView cellForRowAtIndexPath:indexPath] setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
			break;
		}
	}
	
	NSError *error;
	if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"error committing edit: %@", error);
	
	[self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddTransactionSegue"])
	{

	}
	if ([segue.identifier isEqualToString:@"EditTransactionSegue"])
	{
		TransactionFormViewController *tfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[tfvc setEditObjectID:sender];
	}
}

@end
