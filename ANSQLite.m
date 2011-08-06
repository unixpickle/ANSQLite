#import <Foundation/Foundation.h>
#import "ANSQLite3Manager.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	ANSQLite3Manager * man = [[ANSQLite3Manager alloc] initWithDatabaseFile:@"/var/tmp/foo.db"];
	if (!man.database) {
		NSLog(@"Could not open database.");
		exit(-1);
	}
	[man executeQuery:@"create table if not exists sessions (id INTEGER NOT NULL, name VARCHAR(20), contents TEXT, PRIMARY KEY (id), UNIQUE (id))"];
	NSString * name = @"username";
	NSString * _contents = [NSString stringWithFormat:@"userid # %d", arc4random()];
	NSArray * b = [man executeQuery:@"INSERT INTO sessions (name, contents) VALUES (?, ?)" 
				withParameters:[NSArray arrayWithObjects:name, _contents, nil]];
	if (!b) {
		NSLog(@"Could not run query.");
		exit(-1);
	}
	NSArray * contents = [man executeQuery:@"SELECT * FROM sessions"];
	for (int i = 0; i < [contents count]; i++) {
		NSDictionary * dict = [contents objectAtIndex:i];
		int itemID = [[dict objectForKey:@"id"] intValue];
		NSString * name = [dict objectForKey:@"name"];
		NSString * contents = [dict objectForKey:@"contents"];
		NSLog(@"%d|%@|%@", itemID, name, contents);
	}
	
	[man release];
	
    [pool drain];
    return 0;
}
