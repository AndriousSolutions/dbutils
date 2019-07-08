# SQLite in Flutter
##### Demonstrating the Dart package, [**dbutils**](https://pub.dev/packages/dbutils).
[![Build Status](https://travis-ci.org/AndriousSolutions/dbutils.svg?branch=master)](https://travis-ci.org/AndriousSolutions/dbutils)

The Dart package, [**dbutils**](https://pub.dev/packages/dbutils), was written to work with the SQLite plugin, [**sqflite**](https://pub.dev/packages/sqflite), which was written by [Alex Tekartik](https://github.com/tekartik/sqflite). The plugin knows how to ‘talk to’ a SQLite database, while the Dart package knows how to ‘talk to’ the plugin. The end result allows you to manipulate the SQLite database that much easier. Before continuing, I would suggest installing the Dart package now as it includes the very same example app demonstrated here in this article. Follow the three steps below, and you’re on your way to easily working with a SQLite database in your Flutter app.
![sqlitedbutils](https://user-images.githubusercontent.com/32497443/48977150-cfe2ab00-f062-11e8-9e84-483ca902df98.png)
### What's on the Table?
In the example app, we have the class, Employee, that extends the class library called, *DBInterface*. It’s found in the Dart package and implements the three required properties: To *getters* called name and version and one function called **onCreate**(). The ‘name’ is the name of the database to contain all the tables you would then define in the function, onCreate(). The ‘version’ is of course the version number of the database. Pretty straightforward so far.
![employee](https://user-images.githubusercontent.com/32497443/60780201-0c02e180-a103-11e9-9d6d-96e54ce58ddb.jpg)
So, in the screenshot above, you see what makes up the Dart file, Employee.dart. Looking inside the **onCreate**() function, you’ll realize it’s required you be comfortable with [**SQL**](https://en.wikipedia.org/wiki/SQL) as it’s used to create and manipulate the data tables. Listed at the end of the Employee class, are functions used to save any changes to an Employee record be it editing an existing record or creating an brand new one. There’s the function to delete an Employee record, as well as, a function to retrieve the Employee records from the SQLite database. The last function listed provides an ‘empty’ Employee record used typically when creating a brand new Employee record.
### Keep It Single
Note, I’ve chosen to use a factory constructor for this Employee class. Doing so enforces the singleton pattern described in [*Item 1*](http://www.informit.com/articles/article.aspx?p=1216151) of Joshua Bloch’s now famous 2001 book, [*Effective Java*](https://www.oreilly.com/library/view/effective-java-3rd/9780134686097/). Therefore, with each subsequent instantiation of this class, only ‘one instance’ of Employee is utilized. We don’t want more than one instance of the ‘Employee’ table running in this app.   

In the screenshot below, you see the keyword, *factory*, allows for a return statement in the constructor. In this case, it returns the static property, *_this*, that will contain the one and only instance of the this class.
![factory](https://user-images.githubusercontent.com/32497443/60780495-520c7500-a104-11e9-8c2a-193e680d52ba.jpg)
### Once Is Enough
For example, going to the ‘Employee details’ screen where you view an employee’s information, you have the option to delete that record. As it’s not a common operation, there’s no need to define a memory variable to take a instantiated reference of the Employee class. Merely call the constructor. We know, by time we visit this screen, the Employee class has already been instantiated and will return that one instance.
![delete](https://user-images.githubusercontent.com/32497443/60780908-eaefc000-a105-11e9-8b7c-3d4e62b7e768.jpg)
### Saved By One
Further on in that every same class there’s the function, *_submit*, called to save any changes made to the employee information. By the way, it’s also used to save brand new employee records. Note, it too calls the constructor, **Employee**(), to get that one instance to save that employee record.
![screen1](https://user-images.githubusercontent.com/32497443/60781014-4e79ed80-a106-11e9-8307-34f04d4997af.jpg)

### It's Opened and Closed
When you look at the sample app, you’ll see where the Employee table is first instantiated in the State object’s **initState**() function. In most cases, that’s the appropriate place to do that. In fact, with most Dart packages and class libraries, the common practice is to initialize and dispose of them in a State object’s **initState**() and **dispose**() functions respectively. And so, in most cases, the dbutils Dart package’s has an **init**() function that opens the database, and a **disposed**() function that closes the database. Note, however, in the screenshot below, the **init**() function call is commented out.
![screen1](https://user-images.githubusercontent.com/32497443/60781158-d52eca80-a106-11e9-8f01-4c0a24beb5fc.jpg)
It’s commented out to demonstrate the ability of the library class to open the database whenever there’s a query to be performed. This is the case with the **getEmployees**() function highlighted above. And so, in the screenshot below, deep in the class library, the **rawQuery**() function that’s eventually called will open the database if not open already.
![query](https://user-images.githubusercontent.com/32497443/60781236-2b037280-a107-11e9-94fb-e634975f2419.jpg)
### All Or Nothing
You can see in the **getEmployees**() function an SQL statement is executed to retrieve all the records that may be found in the table, Employee. It returns a List of Map objects — any and all the records found in the Employee table. The key of each Map object is, of course, a field name. Note, the class has a Map object, values, that takes in the last record in the table or an empty record if the table is also empty.
![getEmployee](https://user-images.githubusercontent.com/32497443/60781367-b3821300-a107-11e9-9803-014c4f0286b8.jpg)
### Just For Show
Of course, we could have just as well removed the comment on that line and have the **init**() called in the **initState**() function. In fact, it would be better form to do so as it adds a little consistency to the code. You can see in the screenshot of the library below, the database is opened in the **init**() function. It’s then always appropriate call the functions **disposed**() or **close**() in the State object’s **dispose**() function to ensure the database is closed properly when terminating your app.
![screen1](https://user-images.githubusercontent.com/32497443/60781437-12e02300-a108-11e9-8e02-17d155199316.jpg)

### Map It Out
The SQFlite plugin for Flutter, [**sqflite**](https://pub.dev/packages/sqflite), deals with Map objects. This class library continues that approach and allows you to assign values to your table using Map objects. Below is a screenshot of the ‘Employee’ screen that displays an individual employee’s details. Note, a Map object, employee, is utilized to pass on the employee’s information to the **TextFormField** Widgets displayed and to take on any new values entered by the user. You can see where the Map object is used to also delete the Employee record it you wish. While, at the other end, the Map object is further used to save any new information to the data table.
![MyEmployee](https://user-images.githubusercontent.com/32497443/60781572-9a2d9680-a108-11e9-9ab8-8d80a9c67605.jpg)
### Make the Save
In the sample app, you click in a button labelled, *Save*, to save the employee information. Looking at the code below, you see the **save**() function defined in the Employee class is called to perform the operation. As you’ve likely guessed by now, most operations involving the database are asynchronous and hence we’re working with Future objects. In this case, the **save**() function returns a Future object of type Boolean, *Future<bool>*, and we use the callback function, **then**(), to then notify the user if the save was successful as well as return to the previous screen.
![then](https://user-images.githubusercontent.com/32497443/60781803-7585ee80-a109-11e9-9f31-ed2c2b73b606.jpg)
### A Record Save
Inside the Employee class, the **save**() function, in turn, calls the **saveRec**() function. It passes the Map object containing the employee information as well as the name of the data table to be updated.
![save](https://user-images.githubusercontent.com/32497443/60781854-b8e05d00-a109-11e9-8e1a-6219efe39a61.jpg)
![saveRec](https://user-images.githubusercontent.com/32497443/60781876-d9a8b280-a109-11e9-8dd8-c7cbf25e1231.jpg)
You can see the function, **updateRec**(), is called in turn to take the data deeper into the Dart package’s class library. We’re working with Future objects now. You can see below, we’re getting closer to the plugin itself calling an internal ‘helper’ class with its own **updateRec**() function. As you see, it’s enclosed in a **try..catch** statement. If there’s an error, another ‘helper’ class called *_dbError* will record the error and not crash the whole app.
![updateRec](https://user-images.githubusercontent.com/32497443/60781968-3b691c80-a10a-11e9-8e92-f54d35522a7b.jpg)
Finally, the internal class, *_dbInt*, has its **updateRec**() function perform the actual database operation. Notice, if the key field value is null, that implies this is a new Employee record and so the plugin, db, will call its **insert**() function to add this new record to the data table inside the database. Otherwise, it’s an existing record, and using the key field value to update the data table record.
![keyfield](https://user-images.githubusercontent.com/32497443/60782032-79fed700-a10a-11e9-97d8-38251387c17b.jpg)
### Let's See Your Saves
When this example app starts up it’ll produce a list of employees entered so far. Below, is the code responsible to displaying that list. A query of the ‘Employee’ data table is performed with the use of a **FutureBuilder** widget, and when there’s data, the first and last name of each employee is listed out.
![EmployeeList](https://user-images.githubusercontent.com/32497443/60782108-e4177c00-a10a-11e9-9b22-a4e28552a85e.jpg)
![displaying](https://user-images.githubusercontent.com/32497443/60782140-1cb75580-a10b-11e9-8a38-5146bf779dc5.jpg)
### Add Anew
Note the last little red arrow in the screenshot above. It reveals how an ‘empty’ Employee Map object is produced and passed to the ‘Employee’ screen so the user can enter a brand new employee.
### To A Delete
As a counter, let’s walk through the process involved when deleting an Employee record. Let’s return to the ‘Employee’ screen that displays an individual employee, and note there is the ‘trash’ icon on the AppBar. You press that icon; you’ll call the Employee class’ **deleteRec**() function. Note, it passes that Map object containing the employee’s info. In particular, the key field id for that Employee record.
![screen1](https://user-images.githubusercontent.com/32497443/60782232-715ad080-a10b-11e9-8e64-a38ca925f890.jpg)
In the **deleteRec**() function, the **delete**() function is called passing in the name of the data table as well as the key field value specified by the field name, id. Note, if no Map object was passed to the function, the class turns to its internal Map object, values, in the hope to provide the id value.
![deleteRec](https://user-images.githubusercontent.com/32497443/60782274-9c452480-a10b-11e9-97f4-c4dfd113809b.jpg)
Further, in the dbutils class library, again the **try..catch** statement prevents the app from crashing all together if there’s an exception. Again, an internal helper class comes into play calling its own **delete**() function to perform the actual deletion.
![delete](https://user-images.githubusercontent.com/32497443/60782324-d44c6780-a10b-11e9-9974-1fd0e4228dcd.jpg)
The final function returns a Future object of type int (the number of records deleted) upon a successful operation. It too requires the key field value to find the appropriate Employee record. Note, if the database is not open yet, it’s opened before the deletion is performed.
![delete](https://user-images.githubusercontent.com/32497443/60782366-ff36bb80-a10b-11e9-90f0-665587501c63.jpg)

### Let's See the Interface:
Let’s use the rest of this article to walk through this class library, *DBInterface.dart*, from top to bottom. It’ll show you where and how Alex Tekartik’s plugin is utilized to work with SQLite databases and how to take advantage of that fact in your own Flutter apps.
### On Five Occasions
At most, you have five functions that you can override when using this class library. Each handles five different events: *onCreate*, *onConfigure*, *onOpen*, *onUpgrade*, and *onDowngrade*.

The function, onCreate(), is an abstract function and has to be implemented. The others need only be overridden when you need them. Below, in the code, you can read in the comments when and why you would implement them.
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

##### The Medium Article:
[![sqlite](https://user-images.githubusercontent.com/32497443/49753883-ac367c00-fc82-11e8-8c04-3e2f56e8855c.png)](https://medium.com/@greg.perry/sqlite-database-in-flutter-2ef1ef87e5af)