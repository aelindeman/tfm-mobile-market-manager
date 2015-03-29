//
//  ReconciliationEntryTableViewCell.m
//  TFMMobileMarketManager
//

#import "ReconciliationEntryTableViewCell.h"

// stolen (and updated for ARC) from http://stackoverflow.com/questions/12267955/
@implementation UITextField (Additions)

- (void)setPrefixText:(NSString *)prefix
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont fontWithName:self.font.fontName size:self.font.pointSize]];
	[label setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33]];
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
	[label setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33]];
	[label setText:suffix];
	
	CGSize suffixSize = [suffix sizeWithAttributes:@{NSFontAttributeName: label.font}];
	label.frame = CGRectMake(0, 0, suffixSize.width, self.frame.size.height);
	
	[self setRightView:label];
	[self setRightViewMode:UITextFieldViewModeAlways];
}

@end

@implementation ReconciliationEntryTableViewCell

@synthesize field1Prefix;
- (void)setField1Prefix:(NSString *)prefix
{
	if (!prefix) field1Prefix = @"";
	else
	{
		field1Prefix = prefix;
		[self.snapField1 setPrefixText:prefix];
		[self.creditField1 setPrefixText:prefix];
		[self.totalField1 setPrefixText:prefix];
	}
}
- (NSString *)field1Prefix
{
	return field1Prefix ? field1Prefix : @"";
}

@synthesize field1Suffix;
- (void)setField1Suffix:(NSString *)suffix
{
	if (!suffix) field1Suffix = @"";
	else
	{
		field1Suffix = suffix;
		[self.snapField1 setSuffixText:suffix];
		[self.creditField1 setSuffixText:suffix];
		[self.totalField1 setSuffixText:suffix];
	}
}
- (NSString *)field1Suffix
{
	return field1Suffix ? field1Suffix : @"";
}

@synthesize field2Prefix;
- (void)setField2Prefix:(NSString *)prefix
{
	if (!prefix) field2Prefix = @"";
	else
	{
		field2Prefix = prefix;
		[self.snapField2 setPrefixText:prefix];
		[self.creditField2 setPrefixText:prefix];
		[self.totalField2 setPrefixText:prefix];
	}
}
- (NSString *)field2Prefix
{
	return field2Prefix ? field2Prefix : @"";
}

@synthesize field2Suffix;
- (void)setField2Suffix:(NSString *)suffix
{
	if (!suffix) field2Suffix = @"";
	else
	{
		field2Suffix = suffix;
		[self.snapField2 setSuffixText:suffix];
		[self.creditField2 setSuffixText:suffix];
		[self.totalField2 setSuffixText:suffix];
	}
}
- (NSString *)field2Suffix
{
	return field2Suffix ? field2Suffix : @"";
}

// strips non-numeric characters from string
- (NSString *)sanitize:(NSString *)string
{
	return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

// returns values from fields in an NSDictionary
- (NSDictionary *)getData
{
	return @{
		@"snapField1": [self sanitize:[self.snapField1 text]],
		@"snapField2": [self sanitize:[self.snapField2 text]],
		@"creditField1": [self sanitize:[self.creditField1 text]],
		@"creditField2": [self sanitize:[self.creditField2 text]],
		@"totalField1": [self sanitize:[self.totalField1 text]],
		@"totalField2": [self sanitize:[self.totalField2 text]],
	};
}

- (void)removePlaceholders
{
	[self.snapField1 setPlaceholder:@""];
	[self.snapField2 setPlaceholder:@""];
	[self.creditField1 setPlaceholder:@""];
	[self.creditField2 setPlaceholder:@""];
	[self.totalField1 setPlaceholder:@""];
	[self.totalField2 setPlaceholder:@""];
}

// quietly strip non-numeric characters from string rather than annoyingly validate
- (IBAction)sanitizeField:(id)sender
{
	if ([sender text])
		[sender setText:[self sanitize:[sender text]]];
}

- (IBAction)needsPrefixAndSuffix:(id)sender
{
	if ([[sender restorationIdentifier] hasSuffix:@"Field1"])
	{
		[sender setPrefixText:self.field1Prefix];
		//[sender setSuffixText:self.field1Suffix];
	}
	else if ([[sender restorationIdentifier] hasSuffix:@"Field2"])
	{
		[sender setPrefixText:self.field2Prefix];
		//[sender setSuffixText:self.field2Suffix];
	}
}

@end
