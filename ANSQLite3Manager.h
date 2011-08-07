//
//  ANListManager.h
//  SuperLists
//
//  Created by Alex Nichol on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSQLite3Manager.h"
#import "ANListItem.h"
#include "ByteEndian.h"

#define kAutoClose NO

#define kDatabaseIdleCloseTime 10
#define kListDBKeyFlags @"flags"
#define kListDBKeyDueDate @"duedate"
#define kListDBKeyID @"id"
#define kListDBKeyParentID @"parent_id"
#define kListDBKeyTitle @"title"
#define kListDBKeyPasscode @"passcode"
#define kListDBKeyNotes @"notes"
#define kListDBKeySubItems @"sub_items"

@interface ANListManager : NSObject {
    ANSQLite3Manager * databaseManager;
	NSNumber * lastTransactionID;
}

@property (nonatomic, retain) NSNumber * lastTransactionID;

+ (ANListManager *)sharedListManager;
- (void)connectDatabase;
- (void)disconnectDatabase;
- (ANListItem *)listItemForID:(UInt64)itemID;
- (NSArray *)listItemsForParentID:(UInt64)parentID;
- (void)insertItem:(ANListItem *)listItem;

@end
