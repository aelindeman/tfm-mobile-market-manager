//
//  AppDelegate.h
//  tfmco-mip
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MarketDays.h"

#define TFM_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

typedef NS_ENUM(NSInteger, Frequency)
{
	FrequencyNone = 0,
	FrequencyFirstTime,
	FrequencySeason,
	FrequencyMonthly,
	FrequencyNQWeekly,
	FrequencyWeekly
};

typedef NS_ENUM(NSInteger, Ethnicity)
{
	EthnicityNone = 0,
	EthnicityWhite,
	EthnicityBlack,
	EthnicityHispanic,
	EthnicityAsian,
	EthnicityOther
};

typedef NS_ENUM(NSInteger, Position)
{
	PositionVolunteer = 0,
	PositionManager
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property MarketDays *activeMarketDay;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

