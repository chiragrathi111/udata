Any table enter inside callout name:-
@script:beanshell:Date

Serach rule window and create a new records:-

Search Key - beanshell:Date
Name - beanshell:Date
Event Type - Callout
Rule Type - JSR 223 Scripting APIs
Script -
if (A_Value != null && A_Value.toString().length() > 6) {
    return "The name exceeds 6 characters!";
} else {
    return "";
}

// Check if A_Value is not null
if (A_Value != null) {
    var name = A_Value.toString();
    if (name.indexOf("@") == -1) {
        return "The name must include '@' and '.'";
    }
    if (name.indexOf(".") == -1) {
        return "The name must include '.'";
    }
    return "";
} else {
    return "This field is required. Please enter an email ID.";
}


//Date  
if (A_Value != null) {
    // Convert A_Value to a Java Date object
    var selectedDate = new java.util.Date(A_Value.getTime());
    var today = new java.util.Date(); // Current date and time

    // Create dates without time for comparison
    var selectedDateWithoutTime = new java.util.Date(selectedDate.getYear(), selectedDate.getMonth(), selectedDate.getDate());
    var todayWithoutTime = new java.util.Date(today.getYear(), today.getMonth(), today.getDate());

    // Validate date
    if (selectedDateWithoutTime.before(todayWithoutTime)) {
        return "The selected date cannot be in the past. Please select today or a future date.";
    }

    return ""; // No error message
} else {
    return "This field is required. Please select a date.";
}


if (A_Value != null) {
    var selectedDate = new java.util.Date(A_Value.getTime());
    var today = new java.util.Date(); // Current date and time
    var selectedDateWithoutTime = new java.util.Date(selectedDate.getYear(), selectedDate.getMonth(), selectedDate.getDate());
    var todayWithoutTime = new java.util.Date(today.getYear(), today.getMonth(), today.getDate());

    if (selectedDateWithoutTime.before(todayWithoutTime)) {
        -- A_Value.setValue(todayWithoutTime);
        return "The selected date cannot be in the past. Please select today or a future date.";
    }

    return ""; // No error message
} else {
    return "This field is required. Please select a date.";
}


import java.sql.Timestamp;
import java.util.Calendar;

public class DateValidation {

    public String validateDate(Timestamp selectedDate) {
        if (selectedDate != null) {
            // Get today's date without time
            Calendar today = Calendar.getInstance();
            today.set(Calendar.HOUR_OF_DAY, 0);
            today.set(Calendar.MINUTE, 0);
            today.set(Calendar.SECOND, 0);
            today.set(Calendar.MILLISECOND, 0);

            // Get the selected date without time
            Calendar selected = Calendar.getInstance();
            selected.setTime(selectedDate);
            selected.set(Calendar.HOUR_OF_DAY, 0);
            selected.set(Calendar.MINUTE, 0);
            selected.set(Calendar.SECOND, 0);
            selected.set(Calendar.MILLISECOND, 0);

            // Compare the dates
            if (selected.before(today)) {
                // Replace the old date with today's date
                selectedDate.setTime(today.getTimeInMillis());

                // Return a message
                return "The selected date was in the past and has been replaced with today's date.";
            }

            return ""; // No error message
        } else {
            // Throw an exception if the date is null
            throw new IllegalArgumentException("This field is required. Please select a date.");
        }
    }
}


