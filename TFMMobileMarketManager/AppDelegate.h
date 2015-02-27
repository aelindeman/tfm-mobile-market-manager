//
//  AppDelegate.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FMDB.h"

#import "MarketDay.h"
#import "typedefs.h"

#define TFM_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property MarketDay *activeMarketDay;

@property (strong, nonatomic) FMDatabase *storage;

- (NSURL *)applicationDocumentsDirectory;

@end

