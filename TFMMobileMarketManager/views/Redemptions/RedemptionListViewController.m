//
//  RedemptionListViewController.m
//  tfmco-mip
//

#import "RedemptionListViewController.h"

@interface RedemptionListViewController ()

@end

@implementation RedemptionListViewController

static NSString *deleteConfirmationMessageTitle = @"Mark this redemption as invalid?";
static NSString *deleteConfirmationMessageDetails = @"It won’t be deleted, but will not be considered when adding up redemption totals.";

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set!");
	[self.navigationItem setPrompt:[TFM_DELEGATE.activeMarketDay fieldDescription]];
	self.tableView.allowsMultipleSelectionDuringEditing = false;
	[self load];
}

- (void)load
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Redemptions"];[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(marketday == %@)", [TFM_DELEGATE activeMarketDay]]];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:true], [NSSortDescriptor sortDescriptorWithKey:@"vendor.businessName" ascending:true]]];
	
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
	Redemptions *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
	UIView *c = cell.contentView;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[(UILabel *)[c viewWithTag:1] setText:[dateFormatter stringFromDate:info.date]];
	
	[(UILabel *)[c viewWithTag:2] setText:[(Vendors *)info.vendor businessName]];
	[(UILabel *)[c viewWithTag:4] setText:[NSString stringWithFormat:@"$%i", info.total]];
	
	if (info.check_number)
		[(UILabel *)[c viewWithTag:3] setText:[NSString stringWithFormat:@"%04i", info.check_number]];
	else
		[(UILabel *)[c viewWithTag:3] setText:@""];
	
	if (info.markedInvalid)
	{
		NSDictionary *strike = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
		for (int i = 1; i <= 4; i ++)
		{
			[(UILabel *)[c viewWithTag:i] setTextColor:[UIColor lightGrayColor]];
			[(UILabel *)[c viewWithTag:i] setAttributedText:[[NSAttributedString alloc] initWithString:[(UILabel *)[c viewWithTag:i] text] attributes:strike]];
		}
	}
	else
	{
		// fix for when a transaction is unmarked invalid and stays gray
		for (int i = 1; i <= 4; i ++) [(UILabel *)[c viewWithTag:i] setTextColor:[UIColor darkTextColor]];
		
		// highlight paid redemptions
		if (info.check_number)
		{
			UIColor *highlight = [UIColor colorWithRed:0.550 green:0.760 blue:0.290 alpha:1.000];
			[(UILabel *)[c viewWithTag:3] setTextColor:highlight];
			[(UILabel *)[c viewWithTag:4] setTextColor:highlight];
		}
	}
}

// populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RedemptionCell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [[[NSBundle mainBundle] loadNibNamed:@"RedemptionListHeaderView" owner:self options:nil] firstObject];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Mark invalid";
}

// trigger edit window segue on selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the object's unique ID and pass it to the editor, rather than passing the whole object
	NSManagedObjectID *uid = [[_fetchedResultsController objectAtIndexPath:indexPath] objectID];
	[self performSegueWithIdentifier:@"EditRedemptionSegue" sender:uid];
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
			self.selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
			if (![self.selectedObject markedInvalid]) [[[UIAlertView alloc] initWithTitle:deleteConfirmationMessageTitle message:deleteConfirmationMessageDetails delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
			break;
		}
	}
	
	NSError *error;
	if (![TFM_DELEGATE.managedObjectContext save:&error]) NSLog(@"error committing edit: %@", error);
	
	[self.tableView endUpdates];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:deleteConfirmationMessageTitle])
	{
		switch (buttonIndex)
		{
			case 0:
				// canceled
				break;
				
			case 1:
				[self.selectedObject setMarkedInvalid:true];
				break;
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddRedemptionSegue"])
	{
		
	}
	if ([segue.identifier isEqualToString:@"EditRedemptionSegue"])
	{
		RedemptionFormViewController *rfvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
		[rfvc setEditObjectID:sender];
	}
}

@end
