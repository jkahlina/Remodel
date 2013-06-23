//
//  TableViewDataSource.h
//  Remodel
//
//  Created by Jeff Kahlina on 12-01-01.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TableViewDataSource : NSObject < NSTableViewDataSource >
{
	NSMutableArray* _dataArray;
}

- (void)addObject:(id)anObject withIdentifier:(id)identifier row:(NSInteger)rowIndex;
- (id)objectWithIdentifier:(id)identifier row:(NSInteger)rowIndex;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
//- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end
