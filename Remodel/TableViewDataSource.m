//
//  TableViewDataSource.m
//  Remodel
//
//  Created by Jeff Kahlina on 12-01-01.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewDataSource.h"


@implementation TableViewDataSource

- (id)init
{
	if(self = [super init])
	{
		_dataArray = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)dealloc
{
	[_dataArray release];
	_dataArray = nil;
	[super dealloc];
}

- (void)addObject:(id)anObject withIdentifier:(id)identifier row:(NSInteger)rowIndex
{
	if(rowIndex >= [_dataArray count])
	{
		NSMutableDictionary* item = [NSMutableDictionary dictionaryWithCapacity:3];
		[_dataArray addObject:item];
	}
	
    NSMutableDictionary* dict = [_dataArray objectAtIndex:rowIndex];
    [dict setObject:anObject forKey:identifier];
}

- (id)objectWithIdentifier:(id)identifier row:(NSInteger)rowIndex
{
    NSParameterAssert(rowIndex >= 0 && rowIndex < [_dataArray count]);
	
	NSDictionary* dict = [_dataArray objectAtIndex:rowIndex];
    return [dict objectForKey:identifier];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_dataArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [self objectWithIdentifier:[aTableColumn identifier] row:rowIndex];
}

@end
