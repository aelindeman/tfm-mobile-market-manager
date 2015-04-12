//
//  UITextField+PrefixSuffix.h
//  TFMMobileMarketManager
//
// stolen (and updated for ARC) from http://stackoverflow.com/a/12267979
//

#import <UIKit/UIKit.h>

@interface UITextField (PrefixSuffix)

@property UIColor *prefixLabelColor;
@property UIColor *suffixLabelColor;

- (void)setPrefixText:(NSString *)prefix;
- (void)setSuffixText:(NSString *)suffix;

@end
