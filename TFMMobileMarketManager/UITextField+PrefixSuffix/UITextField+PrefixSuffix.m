//
//  UITextField+PrefixSuffix.m
//  TFMMobileMarketManager
//
// stolen (and updated for ARC) from http://stackoverflow.com/a/12267979
//

#import "UITextField+PrefixSuffix.h"

@implementation UITextField (PrefixSuffix)

@dynamic prefixLabelColor;
@dynamic suffixLabelColor;

- (void)setPrefixText:(NSString *)prefix
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont fontWithName:self.font.fontName size:self.font.pointSize]];
	[label setTextColor:[self prefixLabelColor] ?: [self textColor]];
	[label setText:prefix];
	
	CGSize prefixSize = [prefix sizeWithAttributes:@{NSFontAttributeName: label.font}];
	label.frame = CGRectMake(0, 0, prefixSize.width, self.frame.size.height);
	
	[self setLeftView:label];
	[self setLeftViewMode:UITextFieldViewModeAlways];
}

- (void)setSuffixText:(NSString *)suffix
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont fontWithName:self.font.fontName size:self.font.pointSize]];
	[label setTextColor:[self suffixLabelColor] ?: [self textColor]];
	[label setText:suffix];
	
	CGSize suffixSize = [suffix sizeWithAttributes:@{NSFontAttributeName: label.font}];
	label.frame = CGRectMake(0, 0, suffixSize.width, self.frame.size.height);
	
	[self setRightView:label];
	[self setRightViewMode:UITextFieldViewModeAlways];
}

@end
