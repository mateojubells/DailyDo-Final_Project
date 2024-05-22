enum Month {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December
}

String getMonthName(int month) {
  switch (month) {
    case 1:
      return Month.January.toString().split('.').last;
    case 2:
      return Month.February.toString().split('.').last;
    case 3:
      return Month.March.toString().split('.').last;
    case 4:
      return Month.April.toString().split('.').last;
    case 5:
      return Month.May.toString().split('.').last;
    case 6:
      return Month.June.toString().split('.').last;
    case 7:
      return Month.July.toString().split('.').last;
    case 8:
      return Month.August.toString().split('.').last;
    case 9:
      return Month.September.toString().split('.').last;
    case 10:
      return Month.October.toString().split('.').last;
    case 11:
      return Month.November.toString().split('.').last;
    case 12:
      return Month.December.toString().split('.').last;
    default:
      return '';
  }
}