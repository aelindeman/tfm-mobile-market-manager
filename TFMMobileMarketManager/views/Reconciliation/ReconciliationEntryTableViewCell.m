//
//  ReconciliationEntryTableViewCell.m
//  TFMMobileMarketManager
//

#import "ReconciliationEntryTableViewCell.h"

@implementation ReconciliationEntryTableViewCell

- (void)awakeFromNib
{
	if (!self.field1Prefix) self.field1Prefix = @"";
	if (!self.field1Suffix) self.field1Suffix = @"";
	if (!self.field2Prefix) self.field2Prefix = @"";
	if (!self.field2Suffix) self.field2Suffix = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
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

- (void)appendField1Units:(UITextField *)field
{
	if ([[field text] length] > 0)
	{
		[field setText:[self.field1Prefix stringByAppendingString:[field text]]];
		[field setText:[[field text] stringByAppendingString:self.field1Suffix]];
	}
}
- (void)removeField1Units:(UITextField *)field
{
	if ([field text] && [[field text] rangeOfString:self.field1Prefix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field1Prefix withString:@""]];
	
	if ([field text] && [[field text] rangeOfString:self.field1Suffix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field1Suffix withString:@""]];
}

- (void)appendField2Units:(UITextField *)field
{
	if ([[field text] length] > 0)
	{
		[field setText:[self.field2Prefix stringByAppendingString:[field text]]];
		[field setText:[[field text] stringByAppendingString:self.field2Suffix]];
	}
}
- (void)removeField2Units:(UITextField *)field
{
	if ([field text] && [[field text] rangeOfString:self.field2Prefix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field2Prefix withString:@""]];
	
	if ([field text] && [[field text] rangeOfString:self.field2Suffix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field2Suffix withString:@""]];
}

// snapField1
- (IBAction)snapField1EditingDidBegin:(id)sender { [self removeField1Units:self.snapField1]; [self sanitizeField:self.snapField1]; }
- (IBAction)snapField1EditingDidEnd:(id)sender { [self sanitizeField:self.snapField1]; [self appendField1Units:self.snapField1]; }

// snapField2
- (IBAction)snapField2EditingDidBegin:(id)sender { [self removeField2Units:self.snapField2]; [self sanitizeField:self.snapField2]; }
- (IBAction)snapField2EditingDidEnd:(id)sender { [self sanitizeField:self.snapField2]; [self appendField2Units:self.snapField2]; }

// creditField1
- (IBAction)creditField1EditingDidBegin:(id)sender { [self removeField1Units:self.creditField1]; [self sanitizeField:self.creditField1]; }
- (IBAction)creditField1EditingDidEnd:(id)sender { [self sanitizeField:self.creditField1]; [self appendField1Units:self.creditField1]; }

// creditField2
- (IBAction)creditField2EditingDidBegin:(id)sender { [self removeField2Units:self.creditField2]; [self sanitizeField:self.creditField2]; }
- (IBAction)creditField2EditingDidEnd:(id)sender { [self sanitizeField:self.creditField2]; [self appendField2Units:self.creditField2]; }

// totalField1
- (IBAction)totalField1EditingDidBegin:(id)sender { [self removeField1Units:self.totalField1]; [self sanitizeField:self.totalField1]; }
- (IBAction)totalField1EditingDidEnd:(id)sender { [self sanitizeField:self.totalField1]; [self appendField1Units:self.totalField1]; }

// totalField2
- (IBAction)totalField2EditingDidBegin:(id)sender { [self removeField2Units:self.totalField2]; [self sanitizeField:self.totalField2]; }
- (IBAction)totalField2EditingDidEnd:(id)sender { [self sanitizeField:self.totalField2]; [self appendField2Units:self.totalField2]; }

@end
