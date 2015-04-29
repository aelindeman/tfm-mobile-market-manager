//
//  AppDelegate.m
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveContext];
}

#pragma mark - File references

@synthesize helpFile = _helpFile;

- (NSURL *)helpFile
{
	if (_helpFile != nil) {
		return _helpFile;
	}
	
	_helpFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"UserDocs" ofType:@"pdf"]];
	return _helpFile;
}

@synthesize reportsPath = _reportsPath;

- (NSURL *)reportsPath
{
	if (_reportsPath != nil) {
		return _reportsPath;
	}
	
	_reportsPath = [NSURL fileURLWithPathComponents:@[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path], @"Reports"]];
	return _reportsPath;
}

#pragma mark - Import/export support

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if (url != nil && [url isFileURL])
	{
		@try
		{
			NSAssert1([self.window.rootViewController class] == [UINavigationController class], @"root view controller wasn't a UINavigationController, it was a %@", [self.window.rootViewController class]);
			NSAssert1([[(UINavigationController *)self.window.rootViewController viewControllers] count] == 1, @"root navigation controller had more than one child view controller (had %i)", [[(UINavigationController *)self.window.rootViewController viewControllers] count]);
			
			[[[(UINavigationController *)self.window.rootViewController viewControllers] firstObject] performSegueWithIdentifier:@"ImportSegue" sender:url];
			
			NSLog(@"delegate forwarded openURL to root navigation controller's first view controller, from app: %@, filename: %@", sourceApplication, [url lastPathComponent]);
			return YES;
		}
		@catch (NSException *exception)
		{
			NSLog(@"delegate couldn't handle url, from app: %@, filename: %@, reason: %@", sourceApplication, [url lastPathComponent], [exception reason]);
			return NO;
		}
	}
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// Store documents here - reports, things to import, etc.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Store the database here
- (NSURL *)applicationLibraryDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"tfm-m3" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
    // Create store path
	NSError *storePathError;
	NSURL *storeURL = [[[self applicationLibraryDirectory] URLByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]] URLByAppendingPathComponent:@"tfm-m3.m3db"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[[storeURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:&storePathError])
		{
			storePathError = [NSError errorWithDomain:TFMM3_ERROR_DOMAIN code:4998 userInfo:@{
				NSLocalizedDescriptionKey: @"Failed to create application's library subfolder",
				NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"There was an error creating the subfolder '%@'.", [[storeURL path] stringByDeletingLastPathComponent]],
				NSUnderlyingErrorKey: storePathError
			}];
			NSLog(@"%@", storePathError);
			abort();
		}
	}
	
	// Create coordinator and store
    NSError *storeCreationError;
	NSDictionary *storeOptions = @{NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&storeCreationError])
	{
		storeCreationError = [NSError errorWithDomain:TFMM3_ERROR_DOMAIN code:4999 userInfo:@{
			NSLocalizedDescriptionKey: @"Failed to initialize the application's persistent storage",
			NSLocalizedFailureReasonErrorKey: @"There was an error creating or loading the application's persistent storage.",
			NSUnderlyingErrorKey: storeCreationError
		}];
		NSLog(@"%@", storeCreationError);
		abort();
	}
	
	NSLog(@"connected to database: %@", storeURL);
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
	// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
	if (_managedObjectContext != nil) {
		return _managedObjectContext;
	}

	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
		return nil;
	}
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil)
	{
		NSError *saveError;
		if (![managedObjectContext save:&saveError])
		{
			saveError = [NSError errorWithDomain:TFMM3_ERROR_DOMAIN code:4997 userInfo:@{
				NSLocalizedDescriptionKey: @"Failed to save the application's persistent storage",
				NSLocalizedFailureReasonErrorKey: @"There was an error saving the application's persistent storage.",
				NSUnderlyingErrorKey: saveError
			}];
			NSLog(@"%@", saveError);
			abort();
		}
	}
}

@end
