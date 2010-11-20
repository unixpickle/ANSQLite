//
//  ANSQLite3Manager.h
//  ANSQLite
//
//  Created by Alex Nichol on 11/19/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>



@interface ANSQLite3Manager : NSObject {
	sqlite3 * database;
}
- (id)initWithDatabaseFile:(NSString *)filename;
- (void)openDatabaseFile:(NSString *)filename;
- (NSArray *)executeQuery:(NSString *)query;
- (NSArray *)executeQuery:(NSString *)query withParameters:(NSArray *)params;
- (void)closeDatabase;
@property (readonly) sqlite3 * database;
@end
