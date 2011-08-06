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
	if ((self = [super init])) {
		database = NULL;
	}
	return self;
}

- (id)initWithDatabaseFile:(NSString *)filename {
	if ((self = [super init])) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
			FILE * fp = fopen([filename UTF8String], "w");
			fclose(fp);
		}
		database = NULL;
		int rc = sqlite3_open([filename UTF8String], &database);
		if (rc) {
			if (database) sqlite3_close(database);
			return nil;
		}
	}
	return self;
}

- (BOOL)openDatabaseFile:(NSString *)filename {
	if (database) {
		return NO;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		FILE * fp = fopen([filename UTF8String], "w");
		fclose(fp);
	}
	int rc = sqlite3_open([filename UTF8String], &database);
	if (rc) {
		sqlite3_close(database);
		database = NULL;
		return NO;
	}
	else return YES;
}

- (NSArray *)executeQuery:(NSString *)query {
	return [self executeQuery:query withParameters:[NSArray array]];
}

- (NSArray *)executeQuery:(NSString *)query withParameters:(NSArray *)params {
	if (!database) return nil;
	sqlite3_stmt * stmt = NULL;
	int rc = sqlite3_prepare_v2(database, [query UTF8String], [query length],
								&stmt, NULL);
	if (rc != SQLITE_OK) {
		if (stmt) {
			sqlite3_finalize(stmt);
		}
		return nil;
	}
	
	for (int i = 0; i < [params count]; i++) {
		id obj = [params objectAtIndex:i];
		if ([obj isKindOfClass:[NSString class]]) {
			const char * utfString = [(NSString *)obj UTF8String];
			sqlite3_bind_text(stmt, i+1, utfString,
							  strlen(utfString), SQLITE_TRANSIENT);
		} else if ([obj isKindOfClass:[NSData class]]) {
			sqlite3_bind_blob(stmt, i+1, [(NSData *)obj bytes], 
							  [(NSData *)obj length], SQLITE_TRANSIENT);
		} else if ([obj isKindOfClass:[NSNumber class]]) {
			if ([(NSNumber *)obj doubleValue] == (double)([(NSNumber *)obj longLongValue])) {
				sqlite3_bind_double(stmt, i+1, [(NSNumber *)obj doubleValue]);
			} else {
				sqlite3_bind_int64(stmt, i+1, [(NSNumber *)obj longLongValue]);
			}
		}
	}
	
	NSMutableArray * resultArray = [[NSMutableArray alloc] init];
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < sqlite3_column_count(stmt); i++) {
			NSString * name = [NSString stringWithUTF8String:(const char *)sqlite3_column_name(stmt, i)];
			int type = sqlite3_column_type(stmt, i);
			switch (type) {
				case SQLITE_INTEGER:
					[row setObject:[NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)] forKey:name];
					break;
				case SQLITE_TEXT:
					[row setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)] forKey:name];
					break;
				case SQLITE_BLOB:
				{
					const char * blobData = sqlite3_column_blob(stmt, i);
					int length = sqlite3_column_bytes(stmt, i);
					[row setObject:[NSData dataWithBytes:blobData length:length] forKey:name];
					break;
				}
				case SQLITE_FLOAT:
					[row setObject:[NSNumber numberWithDouble:sqlite3_column_double(stmt, i)] forKey:name];
					break;
			}
		}
		[resultArray addObject:row];
		[row release];
	}
	sqlite3_finalize(stmt);
	return resultArray;
}

- (void)closeDatabase {
	if (database) {
		sqlite3_close(database);
		database = NULL;
	}
}

- (void)dealloc {
	if (database) [self closeDatabase];
	[super dealloc];
}

@end
