//
//  AppDelegate.h
//  TFMMobileMarketManager
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MarketDays.h"

#define TFMM3_APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define TFMM3_ERROR_DOMAIN @"TFMM3_ERROR"

typedef NS_ENUM(NSInteger, Frequency)
{
	FrequencyFirstTime = 0,
	FrequencySeason,
	FrequencyMonthly,
	FrequencyNQWeekly,
	FrequencyWeekly
};

typedef NS_ENUM(NSInteger, Ethnicity)
{
	EthnicityWhite = 0,
	EthnicityBlack,
	EthnicityHispanic,
	EthnicityAsian,
	EthnicityOther
};

typedef NS_ENUM(NSInteger, Gender)
{
	GenderMale = 0,
	GenderFemale,
	GenderOther
};

typedef NS_ENUM(NSInteger, Position)
{
	PositionVolunteer = 0,
	PositionManager,
	PositionAccountant,
	PositionAdministrator
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property MarketDays *activeMarketDay;

- (void)handleOpenURL:(NSURL *)url;

#pragma mark - Core Data stack

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;

@end

