//
//  VendorsListViewController.m
//  tfmco-mip
//

#import "VendorsListViewController.h"

@interface VendorsListViewController ()

@end

@implementation VendorsListViewController

static NSString *deleteConfirmationMessageTitle = @"Delete this vendor?";
static NSString *deleteConfirmationMessageDetails = @"";
static NSString *deleteFailedMessageTitle = @"Can’t delete this vendor";
static NSString *deleteFailedMessageDetails = @"There are market days or redemptions in the database that are using this vendor.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.allowsMultipleSelectionDuringEditing = false;
	[self load];
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Vendors"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"businessName" ascending:true]]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:TFMM3_APP_DELEGATE.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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

// configure table cells - display as first last -> position
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Vendors *info = [_fetchedResultsController objectAtIndexPath:indexPath];
	NSString *mdplural = ([info.marketdays count] != 1) ? @"s" : @"";
	NSString *redplural = ([info.redemptions count] != 1) ? @"s" : @"";
	[cell.textLabel setText:info.businessName];
	[cell.detailTextLabel setText:[NSString stringWithFormat:@"%tu market day%@, %tu redemption%@", [info.marketdays count], mdplural, [info.redemptions count], redplural]];
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VendorCell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

// trigger edit window segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self performSegueWithIdentifier:@"EditVendorSegue" sender:uid];
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
			self.selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
			// check that it's able to be deleted
			
			NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vendors"];
			[request setPredicate:[NSPredicate predicateWithFormat:@"(SELF == %@) and ((marketdays.@count > 0) or (redemptions.@count > 0))", self.selectedObject]];
			
			if ([[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:nil] count] > 0)
			{
				UIAlertController *cantDeleteAlert = [UIAlertController alertControllerWithTitle:deleteFailedMessageTitle message:deleteFailedMessageDetails preferredStyle:UIAlertControllerStyleAlert];
				[cantDeleteAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
				[self presentViewController:cantDeleteAlert animated:true completion:nil];
			}
			else
			{
				UIAlertController *deletePrompt = [UIAlertController alertControllerWithTitle:deleteConfirmationMessageTitle message:deleteConfirmationMessageDetails preferredStyle:UIAlertControllerStyleAlert];
				[deletePrompt addAction:[UIAlertAction actionWithTitle:@"Don’t delete" style:UIAlertActionStyleCancel handler:nil]];
				[deletePrompt addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
				{
					[TFMM3_APP_DELEGATE.managedObjectContext deleteObject:self.selectedObject];
					NSError *error;
					if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error])
						NSLog(@"error committing edit: %@", error);
				}]];
				[self presentViewController:deletePrompt animated:true completion:nil];
			}
			break;
	}
	
	NSError *error;
	if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error]) NSLog(@"error committing edit: %@", error);
	
	[self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddVendorSegue"])
	{
		//[[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTitle:@"Add Vendor"];
	}
	if ([segue.identifier isEqualToString:@"EditVendorSegue"])
	{
		VendorFormViewController *vfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[vfvc setEditObjectID:sender];
	}
}
@end
