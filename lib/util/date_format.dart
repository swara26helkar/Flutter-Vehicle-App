class DateFormat {
  String formatDateFromTimestamp(int timestamp) {
    // Convert the timestamp (milliseconds since epoch) to a DateTime object.
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Extract the day, month, and year.
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();

    // Return the formatted date string.
    return '$day/$month/$year';
  }
}
