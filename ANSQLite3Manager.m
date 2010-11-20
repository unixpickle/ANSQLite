//
//  ANSQLite3Manager.m
//  ANSQLite
//
//  Created by Alex Nichol on 11/19/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import "ANSQLite3Manager.h"

static NSMutableArray * gReturnValue;

static int myCallback (void * notUsed, int argc, char * argv[], char * names[]) {
	NSMutableDictionary * properties = [NSMutableDictionary dictionary];
	notUsed = NULL;
	int i;
	for (i = 0; i < argc; i++) {
		char * name = names[i];
		char * contents = argv[i];
		if (!contents) contents = "(null)";
		[properties setObject:[NSData dataWithBytes:contents length:strlen(contents)]
					   forKey:[NSString stringWithFormat:@"%s", name]];
	}
	[gReturnValue addObject:properties];
	return 0;
}

@implementation ANSQLite3Manager

@synthesize database;

- (id)init {
	if (self = [super init]) {
		database = NULL;
	}
	return self;
}
- (id)initWithDatabaseFile:(NSString *)filename {
	if (self = [super init]) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
			FILE * fp = fopen([filename UTF8String], "w");
			fclose(fp);
		}
		int rc = sqlite3_open([filename UTF8String], &database);
		if (rc) {
			sqlite3_close(database);
			return nil;
		}
	}
	return self;
}
- (void)openDatabaseFile:(NSString *)filename {
	if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		FILE * fp = fopen([filename UTF8String], "w");
		fclose(fp);
	}
	int rc = sqlite3_open([filename UTF8String], &database);
	if (rc) {
		sqlite3_close(database);
		database = NULL;
	}
}
- (NSArray *)executeQuery:(NSString *)query {
	if (!database) return nil;
	gReturnValue = [[NSMutableArray alloc] init];
	char * zErrMsg = NULL;
	int rc = sqlite3_exec(database, [query UTF8String], myCallback, NULL, &zErrMsg);
	if (rc != SQLITE_OK) {
		return nil;
	}
	return [gReturnValue autorelease];
}
- (NSArray *)executeQuery:(NSString *)query withParameters:(NSArray *)params {
	sqlite3_stmt * stmt;
	int rc = sqlite3_prepare_v2(database, [query UTF8String], [query length],
								&stmt, NULL);
	for (int i = 0; i < [params count]; i++) {
		id obj = [params objectAtIndex:i];
		if ([obj isKindOfClass:[NSString class]]) {
			sqlite3_bind_text(stmt, i+1, [(NSString *)obj UTF8String],
							  [(NSString *)obj length], SQLITE_TRANSIENT);
		} else if ([obj isKindOfClass:[NSData class]]) {
			sqlite3_bind_blob(stmt, i+1, [(NSData *)obj bytes], 
							  [(NSData *)obj length], SQLITE_TRANSIENT);
		} else if ([obj isKindOfClass:[NSNumber class]]) {
			sqlite3_bind_int(stmt, i+1, [(NSNumber *)obj intValue]);
		}
	}
	NSMutableArray * resultArray = [[NSMutableArray alloc] init];
	
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < sqlite3_column_count(stmt); i++) {
			const char * name = sqlite3_column_name(stmt, i);
			char * value = (char *)sqlite3_column_blob(stmt, i);
			if (!value) {
				value = (char *)sqlite3_column_text(stmt, i);
			}
			int length = sqlite3_column_bytes(stmt, i);
			if (!value) value = "";
			// check for null termination
			BOOL isNullTermed = YES;
			for (int i = 0; i < length; i++) {
				if (value[i] == 0) isNullTermed = NO;
			}
			
			//printf("column: %s, contents: %s\n", name, value);
			
			if (isNullTermed)
				[row setObject:[NSString stringWithFormat:@"%s", value] forKey:[NSString stringWithFormat:@"%s", name]];
			else [row setObject:[NSData dataWithBytes:value length:length] forKey:[NSString stringWithFormat:@"%s", name]];
		}
		[resultArray addObject:[row autorelease]];
	}
	sqlite3_reset(stmt);
	sqlite3_finalize(stmt);
	if (rc != SQLITE_OK) {
		// there was a serious problem
		[resultArray release];
		return nil;
	}
	return [resultArray autorelease];
}
- (void)closeDatabase {
	sqlite3_close(database);
	database = NULL;
}
- (void)dealloc {
	if (database) [self closeDatabase];
	[super dealloc];
}
@end
