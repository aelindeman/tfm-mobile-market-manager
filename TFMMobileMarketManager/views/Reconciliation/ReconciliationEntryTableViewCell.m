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
	[label setTextColor:self.textColor];
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
	[label setTextColor:self.textColor];
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

// removes anything that isn't a number, because the iPad is dumb and keyboard will always have letter keys
- (void)sanitizeField:(UITextField *)field
{
	if ([field text]) [field setText:[self sanitize:[field text]]];
}

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

// easy way to set the fields
- (void)setData:(NSDictionary *)input
{
	[self.snapField1 setText:[self sanitize:[input valueForKey:@"snapField1"]]];
	[self.snapField2 setText:[self sanitize:[input valueForKey:@"snapField2"]]];
	[self.creditField1 setText:[self sanitize:[input valueForKey:@"creditField1"]]];
	[self.creditField2 setText:[self sanitize:[input valueForKey:@"creditField2"]]];
	[self.totalField1 setText:[self sanitize:[input valueForKey:@"totalField1"]]];
	[self.totalField2 setText:[self sanitize:[input valueForKey:@"totalField2"]]];
}

// append label Suffix and suffix
- (void)appendUnitsTo:(UITextField *)field prefix:(NSString *)prefix suffix:(NSString *)suffix
{
	if ([field.text length] > 0)
	{
		[field setPrefixText:prefix];
		[field setSuffixText:suffix];
	}
}

- (void)removeUnitsFrom:(UITextField *)field
{
	[field setLeftView:nil];
	[field setRightView:nil];
}

// snapField1
- (IBAction)snapField1EditingDidBegin:(id)sender { [self removeUnitsFrom:self.snapField1]; }
- (IBAction)snapField1EditingDidEnd:(id)sender { [self sanitizeField:self.snapField1]; [self appendUnitsTo:self.snapField1 prefix:self.field1Prefix suffix:self.field1Suffix]; }

// snapField2
- (IBAction)snapField2EditingDidBegin:(id)sender { [self removeUnitsFrom:self.snapField2]; }
- (IBAction)snapField2EditingDidEnd:(id)sender { [self sanitizeField:self.snapField2]; [self appendUnitsTo:self.snapField2 prefix:self.field2Prefix suffix:self.field2Suffix]; }

// creditField1
- (IBAction)creditField1EditingDidBegin:(id)sender { [self removeUnitsFrom:self.creditField1]; }
- (IBAction)creditField1EditingDidEnd:(id)sender { [self sanitizeField:self.creditField1]; [self appendUnitsTo:self.creditField1 prefix:self.field1Prefix suffix:self.field1Suffix]; }

// creditField2
- (IBAction)creditField2EditingDidBegin:(id)sender { [self removeUnitsFrom:self.creditField2]; }
- (IBAction)creditField2EditingDidEnd:(id)sender { [self sanitizeField:self.creditField2]; [self appendUnitsTo:self.creditField2 prefix:self.field2Prefix suffix:self.field2Suffix]; }

// totalField1
- (IBAction)totalField1EditingDidBegin:(id)sender { [self removeUnitsFrom:self.totalField1]; }
- (IBAction)totalField1EditingDidEnd:(id)sender { [self sanitizeField:self.totalField1]; [self appendUnitsTo:self.totalField1 prefix:self.field1Prefix suffix:self.field1Suffix]; }

// totalField2
- (IBAction)totalField2EditingDidBegin:(id)sender { [self removeUnitsFrom:self.totalField2]; }
- (IBAction)totalField2EditingDidEnd:(id)sender { [self sanitizeField:self.totalField2]; [self appendUnitsTo:self.totalField2 prefix:self.field2Prefix suffix:self.field2Suffix]; }

@end
