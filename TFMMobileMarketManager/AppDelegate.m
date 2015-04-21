//
//  AppDelegate.m
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// TODO: save market day state when entering background, and reopen active market day on entering foreground

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	
	/* NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:1 forKey:@"com.apple.CoreData.SQLDebug"];
	[defaults setInteger:1 forKey:@"com.apple.CoreData.SyntaxColoredLogging"]; */
	
	NSLog(@"%@ launched on device %@", [[NSBundle mainBundle] bundleIdentifier], [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
	
	// handle opening files
	NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
	if (url != nil && [url isFileURL])
		[self handleOpenURL:url];
	
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

#pragma mark - Import/export support

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if (url != nil && [url isFileURL])
	{
		[self handleOpenURL:url];
	}
	return YES;
}

// TODO: cannot rely on ImportSegue - if the user isn't on a menu that isn't the main menu, importing won't work correctly
- (void)handleOpenURL:(NSURL *)url
{
	NSAssert1([self.window.rootViewController class] == [UINavigationController class], @"root view controller wasn't a UINavigationController, it was a %@", [self.window.rootViewController class]);
	[[[(UINavigationController *)self.window.rootViewController viewControllers] firstObject] performSegueWithIdentifier:@"ImportSegue" sender:url];
	
	NSLog(@"handleOpenURL for %@", [url lastPathComponent]);
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
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&storeCreationError])
	{
		storeCreationError = [NSError errorWithDomain:TFMM3_ERROR_DOMAIN code:4999 userInfo:@{
			NSLocalizedDescriptionKey: @"Failed to initialize the application's persistent storage",
			NSLocalizedFailureReasonErrorKey: @"There was an error creating or loading the application's persistent storage.",
			NSUnderlyingErrorKey: storeCreationError
		}];
		NSLog(@"%@", storeCreationError);
		abort();
	}
	
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
