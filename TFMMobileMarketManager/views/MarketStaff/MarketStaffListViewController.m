//
//  MarketStaffListViewController.m
//  tfmco-mip
//

#import "MarketStaffListViewController.h"

@interface MarketStaffListViewController ()

@end

@implementation MarketStaffListViewController

static NSString *deleteConfirmationMessageTitle = @"Delete this staff member?";
static NSString *deleteConfirmationMessageDetails = @"";
static NSString *deleteFailedMessageTitle = @"Can’t delete this staff member";
static NSString *deleteFailedMessageDetails = @"There are market days in the database that are using this staff member.";

static NSDictionary *positionStrings;
static dispatch_once_t setPositionStrings; // NSDictionary can't be set here, so dispatch at compile time

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	dispatch_once(&setPositionStrings, ^{
		// TODO: this must be updated if positions are ever changed
		positionStrings = @{
			[NSNumber numberWithInt:PositionVolunteer]: @"Volunteer",
			[NSNumber numberWithInt:PositionManager]: @"Manager",
			[NSNumber numberWithInt:PositionAccountant]: @"Accountant",
			[NSNumber numberWithInt:PositionAdministrator]: @"Administrator"
		};
	});
	
	self.tableView.allowsMultipleSelectionDuringEditing = false;
	[self load];
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MarketStaff"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:false], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	
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
	id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

// configure table cells - display as first last -> position
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	MarketStaff *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:info.name];
	
	[cell.detailTextLabel setText:[positionStrings objectForKey:[NSNumber numberWithInt:info.position]]];
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MarketStaffCell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

// action to perform when a cell is tapped
// eventually this will segue to an ‘Edit’ window prepopulated with data from the tapped cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self performSegueWithIdentifier:@"EditStaffSegue" sender:uid];
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
			
			NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MarketStaff"];
			[request setPredicate:[NSPredicate predicateWithFormat:@"(SELF == %@) and (marketdays.@count > 0)", self.selectedObject]];
			
			if ([[TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:nil] count] > 0)
			{
				[[[UIAlertView alloc] initWithTitle:deleteFailedMessageTitle message:deleteFailedMessageDetails delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
			}
			else
			{
				[[[UIAlertView alloc] initWithTitle:deleteConfirmationMessageTitle message:deleteConfirmationMessageDetails delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
			}
			break;
	}
	
	NSError *error;
	if (![TFMM3_APP_DELEGATE.managedObjectContext save:&error]) NSLog(@"error committing edit: %@", error);
	
	[self.tableView endUpdates];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:deleteConfirmationMessageTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
			{
				[TFMM3_APP_DELEGATE.managedObjectContext deleteObject:self.selectedObject];
				break;
			}
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddStaffSegue"])
	{
		//[[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTitle:@"Add Vendor"];
	}
	if ([segue.identifier isEqualToString:@"EditStaffSegue"])
	{
		MarketStaffFormViewController *msfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[msfvc setEditObjectID:sender];
	}
}

@end
