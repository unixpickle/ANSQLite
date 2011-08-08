A simple, easy to use, SQLite3 wrapper
======================================

That's right, ANSQLite provides a single class, ANSQLite3Manager that allows you to query, create, and modify a SQLite3 database using a few simple class methods.  The ANQLite3Manager class represents a database file, and the executeQuery methods provide the ability to modify and query its contents.

Create a database object
==================================

To create an ANSQLite3Manager object, you can use the ```-initWithDatabaseFile:``` or ```-openDatabaseFile:``` methods.  Here is an example of creating a new database manager:

    ANSQLite3Manager * manager = [[ANSQLite3Manager alloc] initWithDatabaseFile:@"aFile.db"];
    if (!man.database) {
        NSLog(@"Could not open database.");
        exit(-1);
    }

Once you have an instance of ANSQLite3Manager, you can execute queries using the ```-executeQuery:``` or ```-executeQuery:withParameters:``` method.  Both of these methods return an ```NSArray``` object containing an array of ```NSDictionary``` objects.  Each dictionary represents a row in the database, with keys from the database columns, and values of various types.

Once you are done with the database, you can use the ```-closeDatabase``` method to finalize the database file and free memory used by the internal sqlite3 datastructure.
