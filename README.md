# Flutter and a SQLite Database
##### A Flutter Example
[![Build Status](https://travis-ci.org/AndriousSolutions/dbutils.svg?branch=master)](https://travis-ci.org/AndriousSolutions/dbutils)

I’ve taken Raja Jawahar’s sample app from his article, [SQFlite Database in flutter](https://medium.com/@mohamedraja_77/sqflite-database-in-flutter-c0b7be83bcd2), to help introduce a class library I’ve written to make it easier to work a SQLite database. Like Raja Jawahar, I’m using the SQFlite plugin for Flutter, **sqflite**. To follow along, you can get copies of the Dart files that make up the sample app at the gist, [SQFlite Database in Flutter Example](https://gist.github.com/Andrious/feb05d140fbed5f98945ea706edab137). You then copy the last three lines listed below and place them in your own *pubspec.yaml* file. You’re then on your way to working with SQFlite in your Flutter app.
![dbutilsgit](https://user-images.githubusercontent.com/32497443/48977106-fce28e00-f061-11e8-8551-a270ab54f39f.png)

Better still, download the Dart file, [dbutils.dart](https://github.com/AndriousSolutions/dbutils/blob/master/lib/sqllitedb.dart), as there's no guarantee that this repo., [dbutils.git](https://github.com/AndriousSolutions/dbutils), will last forever.

![apache](https://user-images.githubusercontent.com/32497443/48979991-06cfb580-f091-11e8-8bb6-cd723155fb50.png)
![sqlitedbutils](https://user-images.githubusercontent.com/32497443/48977150-cfe2ab00-f062-11e8-9e84-483ca902df98.png)
### What's on the Table?
In the sample app the table, _Employee_, extends the class library I have written called _DBInterface_. It implements the three required properties: Two getters called name and version and one function called **onCreate().** The 'name' is the name of the database to contain the table you'll then define in the function, **onCreate().** The 'version' is the version number of the database. Pretty straightforward so far. The function, **onCreate()**, of course, creates the table. Looking at the **onCreate()** function in the sample code below, it is required you're comfortable with SQL as it is SQL that creates the table. So, in the Dart file, _Employee.dart_, all that's required of you is to 'define' the database table in the **onCreate()** function ('Employee' in this example) and then possibly further define any functions to save and or query that data table.
![01employee](https://user-images.githubusercontent.com/32497443/48977155-1cc68180-f063-11e8-9a49-bc5f38623e6d.png)
### Keep It Single
Note, I've chosen to use a factory constructor for this Employee class. Doing so enforces the singleton pattern described in Item 1 of Joshua Bloch's now famous 2001 book, Effective Java. Therefore, with each subsequent instantiation of this class, only 'one instance' of Employee is utilized. We don't want more than one instance of the 'Employee' table running in this app.
For example, once you've entered an employee in this sample app, if you then 'list' all the employees entered in so far, you're not creating a new instance of the 'Employee' class with the following command used to list them:   
![02fetchemployee](https://user-images.githubusercontent.com/32497443/48977208-42a05600-f064-11e8-9262-950cc457d231.png)
### It's Opened and Closed
When you look at the sample app, you'll see where the Employee table is first instantiated. As many of my class library, I call an **init()** and **dispose()** functions respectively in the State object. In this case, the **init()** function opens the database, and the **dispose()** function closes the database.
![03myhomepagestate](https://user-images.githubusercontent.com/32497443/48977216-79766c00-f064-11e8-94a7-ee3781d590f6.png)
You'd literally see that that's the case, if you take a peek in the class library:
![04init](https://user-images.githubusercontent.com/32497443/48977231-a9be0a80-f064-11e8-8ae3-f97f9902cddb.png)
### Map It Out
The SQFlite plugin for Flutter, **sqflite**, deals with Map objects. This class library continues that approach and allows you to assign values to your table using Map objects. Below you see that you specify which table you're to assign the value ('Employee' in this case) and then to which field in that table.
![05build](https://user-images.githubusercontent.com/32497443/48977247-f1449680-f064-11e8-9cad-82c5e1c76fb2.png) 
### Make the Save
In the sample app, you click in a button labelled, Login, to save the employee information. Looking at the code below, you see the save() function you saw defined in the Employee class. As you've guessed by now, most operations involving the database are asynchronous and hence we're working with Future objects. In this case, the **save()** function returns a Future object of type Boolean, Future<bool>, and we use the callback function, **then()**, to then notify the user if the save was successful or not. 
![06submit](https://user-images.githubusercontent.com/32497443/48977258-2224cb80-f065-11e8-94de-48f83e018bb6.png) 
### Let's See Your Saves
The sample app has a 'hamburger button' in the upper right-hand corner of its screen. Clicking on that button will, as I've mentioned earlier, produce the list of employees you've entered so far. Below, is the code responsible to displaying that list. A query of the 'Employee' data table is performed, and when there's data, the first name and last name of each employee is listed out. 

![07saveemployees](https://user-images.githubusercontent.com/32497443/48977271-484a6b80-f065-11e8-9b46-8edf5bf0cd5b.png)
![08myemployeelist](https://user-images.githubusercontent.com/32497443/48977281-67e19400-f065-11e8-941e-709a15054762.png)
```sh
``` 
### Let's See the Interface:
Again, you see the employee class in the Dart file, _employee.dart_, extends the class, _DBInterface_. This is the class library I've written to, in turn, work with the SQFlite plugin, **sqflite**. In review, typically this is how to use this class library: Create a class that extends the class, _DBInterface_, defines the table it represents and the name of the database (and database version number) that will contain it. There you have it! The rest of this article will take a walk through this class library.
### On Five Occasions
At most, you have five functions that you can override when using this class library. Each to handle five different events: _onCreate, onConfigure, onOpen, onUpgrade, onDowngrade_

The function, **onCreate()**, is an abstract function and has to be implemented. The others need only be overridden when you need them. Below, in the code, you can see in the comments when and why you would implement these functions.
![09dbinterface](https://user-images.githubusercontent.com/32497443/48979409-7b522680-f088-11e8-940e-c2f0d619da88.png)
### Initially Initialized
You'll see in the code above, in the 'initializer' list, two final 'library-private' variables are assigned 'helper' classes. The first one deals with any errors that may occur, but it is the second one that we're most interested. Admittedly, it's that class called *_DBInterface* that does the heavy lifting and works directly with the SQFlite plugin, **sqflite**. It's found later on in the very same Dart file that makes up this class library.
![10dberror](https://user-images.githubusercontent.com/32497443/48979447-e56acb80-f088-11e8-855a-908aaabcf696.png)
### It's an Open and Closed Code
The next section in the class library involves the opening and closing of the database. You can see I wasn't lying when I said the **init()** function and **dispose()** function do the opening and closing of the database. You'll also see the 'helper' class, *_dbInt*, actually makes the attempt to open the database. If it fails to open the database, the other 'helper' class comes in and records the resulting exception if any.
![11open](https://user-images.githubusercontent.com/32497443/48979473-3da1cd80-f089-11e8-8a1d-751355c05e0e.png)
### All You CanGet
Next, are all the _getters_ offered by the class library. Most are concerned with determining the error, if any, that may have occurred at any point. The first two, however, are Map objects that allow you to access the fields names of each table found in the database, and the value of each field of each table found in the database. In fact, you already saw the Map object, _values_, being used in the sample app above where the inputted employee information is being assigned to the appropriate data table field.
![12getfields](https://user-images.githubusercontent.com/32497443/48979487-878ab380-f089-11e8-9a2c-3a1c999b60ca.png)
### Another Save or Update
Next bit of code is responsible for the saving of data to the database. The first function, **saveRec()**, calls the second function, **updateRec()**, and so let's review the second function first. The second function will either 'insert' a new record because the primary key field is null or will update an existing record because the primary key is a number (i.e. already assigned by the database). You'll see all that when you review the 'helper' later on. The primary field and all the other fields are supplied by the second parameter, _fields_, which is a Map object. The first function, **saveRec()**, is supplied this Map object from the 'helper' class: _dbInt._fldValues.

Note how the second function, **updateRec()**, returns an 'empty' Map object if an error occurs. With an error, the exception is recorded in the other 'helper' class, *_dbError*. If the update was successful, any previous exception that may have been recorded before is then cleared.
![13saverec](https://user-images.githubusercontent.com/32497443/48979511-0d0e6380-f08a-11e8-8eaa-f25bab90426d.png)
### Get the Rec or Delete it
Next, is the section code used to retrieve a record or delete one. The first function, **getRecord()**, returns one record, if any, with a primary key field value of the one found in the integer variable, *id*. You can see it merely calls the second function, **getRow()**, but supplies the Map object, fields, from the "Helper" class, *_DBInterface*. This Map object lists all the fields of all the tables found in the current database. In the second function, you can see the name of the table is specified to retrieve all the fields values for that particular record, *fields[table]*. If there is an error, an empty Map object is returned in a List. The third function in this code below appears to be pretty straight forward. It's the 'delete' function and returns the number of rows (i.e. records) that are deleted. If you've a normalized data table, of course, that number should always be one as it searches by the primary key field.

Again, when dealing with this SQFlite plugin, **sqflite**, you'll be dealing with Future objects, and so, this class library deals with Future objects as well. All the functions are returning Future objects.
![14getrecord](https://user-images.githubusercontent.com/32497443/48979541-8d34c900-f08a-11e8-8d14-87045180b75d.png)
### A Query Here
The next two functions call on the plugin's query capabilities. The first function, **rawQuery()**, works with a 'raw' SQL statement while the next two functions, **getTable()** and query(), work with a specific list of parameters recognized as the options traditionally found in an SQL Select statement. The second function, **getTable()**, requires only the name of the table to perform the query. The list of field names are supplied by the Map object, _dbInt._fields. The remaining 'named parameters' make up the options, again, traditionally found in an SQL Select statement and so, by design, are optional. You can see the second function, **getTable()**, merely calls the third function, **query()** supplying the list of fields associated with the named table. The third function, query(), will further ensure a list of field names is provided by using the operator,**??**.
![15rawquery](https://user-images.githubusercontent.com/32497443/48979562-e43a9e00-f08a-11e8-9aae-41e0959009eb.png)
### What's in a Name or Column
The last two functions in the class, *DBInterface*, are used to directly query the 'system tables' found in the database and, in this case, list the table names found in the database, and the field names of a specific table respectively.
![16tablenames](https://user-images.githubusercontent.com/32497443/48979578-29f76680-f08b-11e8-9dac-6c63b8485b82.png)
### To Err is…Excepted
The 'helper' class, *_DBError*, is next listed in the Dart file, *DBInterface.dart*. It's used to record any and all errors that might occur when dealing with databases. The function, **set()**, is found in multiple locations in the class library where errors may occur. Errors are recorded in the instance variables: *_message* and *_e*. Note, the **set()** function returns the String, *_message*, describing the recorded error. The function, **clear()**, is also called throughout the class library. With every successful database operation, those two instance variables are 'cleared' - so not to mistakenly indicate the last successful database operation did, in fact, fail.

Note: This implies, that with every database operation, you could check the getters, **inError** or **noError**, to help determine if the last database operation you preformed with this class library was successful or not.  
![17dberror](https://user-images.githubusercontent.com/32497443/48979626-eea96780-f08b-11e8-85c8-3839bd5c008c.png)
The *getters* and *functions* that follow further help you determine if the last database operation caused an error or not, and, if so, the type of error that may have occurred.
![18isdatabaseexception](https://user-images.githubusercontent.com/32497443/48979654-2e704f00-f08c-11e8-8380-55fdf189cbcd.png)
### The Helper
The 'library-private' class, _DBInterface, indeed does the heavy lifting and actually performs all the database operations. You'll recognize the parameters in its constructor as those in the class library's constructor. Note, since the class itself is a 'library-private' class, I didn't bother to start its variables with underscores as well.
![19dbinterface](https://user-images.githubusercontent.com/32497443/48979666-5e1f5700-f08c-11e8-8d61-022fc49537fe.png)
### There's an Open and There's a Close
The first two functions are to open and to close the database. Of course, Future objects are involved here. In the first function, **_open()**, there is a Boolean value returned to indicate if the database was opened or not. There's another class library I've written called, Files, that retrieves the "app's directory" using the function, **getApplicationDocumentsDirectory()**. It's here where you see the function call, **_tableFields()**. You'll see later in the code how that function fills up the two Map objects, *_fields* and *_fldValues*, with the table's field names.
![20open](https://user-images.githubusercontent.com/32497443/48979691-b191a500-f08c-11e8-999f-65d83b15384d.png)
### Let's Get An Update
Next is the code responsible for 'updating' an existing record or creating a new record. If there is an error, the instance variable, *rowsUpdated*, will contain a value of zero. Otherwise, likely a value of one since we're either creating one new record or updating one record using its primary key. And so, it's here where it'll do an 'insert' or an 'update' depending on if the primary key field is null or already assigned a number.
![21updaterec](https://user-images.githubusercontent.com/32497443/48979715-e271da00-f08c-11e8-8543-953ff31d9471.png)
### Get On Record
Next, is the function used to retrieve a record from the table by looking up its primary key. Notice, this function opens the database if the instance variable, db, is null. It's not likely to be null if the class library was 'initialized' properly, but, if not, this class library will make the attempt to get the record by first trying to open the database. If that fails, an 'empty' List of an 'empty' Map is returned.
![22getrec](https://user-images.githubusercontent.com/32497443/48979747-3aa8dc00-f08d-11e8-844d-b47a44799029.png)

### Delete the Record
The next function deletes a record. It returns the number of records deleted. Being that we're dealing with the record's primary key field, a successful delete will return an integer of one. It will return a value of zero, if the record is not found or, for some reason, an 'unopened' database fails to do so.
![23delete](https://user-images.githubusercontent.com/32497443/48979764-5ca25e80-f08d-11e8-878d-b5a3146c7e51.png)
### The Two Queries
The next two function, **rawQuery()** and **query()** are called by the class library, *DBInterface* inside 'try..catch' statements. However, it is here, where the database is opened if not opened already and where the SQFlite plugin, db, actually performs the queries. The second function passes on the to the SQFlite plugin the many options traditionally available to an SQL Select statement.
![24rawquery](https://user-images.githubusercontent.com/32497443/48979786-a4c18100-f08d-11e8-951a-779802cae204.png)
These next two functions are primarily used by the function, **_tableList()**. It is these two that directly query the 'system tables' found in the database and, in this case, list the table names found in the database, and the field names of a specific table respectively.
![25tablenames](https://user-images.githubusercontent.com/32497443/48979798-ccb0e480-f08d-11e8-9146-91f88847e3fc.png)
### Make the List
Finally, at the end of the class library is the function, **_tableList()**. It is called when the database is opened in the function, **_open()**. It is this function that fills the two Map objects, *_fields* and *_fldValues*, with the names of all the fields of all the tables contained in the database.
![26list](https://user-images.githubusercontent.com/32497443/48979812-17326100-f08e-11e8-8ed5-74df1be693d6.png)

[→ Other Articles by Greg Perry](https://medium.com/@greg.perry)