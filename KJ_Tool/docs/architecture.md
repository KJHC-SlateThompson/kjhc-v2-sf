### Logging Tools Architecture:  
The logEntry class is what holds one instance of an entry made by a user to be logged. The logger class takes in input
and formats it into a logEntry. Once the logger class has the logEntry data structure back, it uses the formatter class to format
the log entry into a printable string. Once it has this string, the logger class prints it to the terminal

### Testing Tools Architecture:  
The TestDataFactory class generates objects with prefilled, generic data for testing purposes. 