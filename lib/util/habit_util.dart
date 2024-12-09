//given a habit list of completion days 
//is the habit completed today?

import 'package:habbit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completionDays){
  //get today's date
  final today = DateTime.now();
  //check if today is in the completion days list
  return completionDays.any(
    (date) => 
      date.day == today.day && 
    date.month == today.month && 
  date.year == today.year);
}

//preparing the data for the heat map
Map<DateTime, int> prepareDataForHeatMap(List<Habit> habits){
  //create a map to store the data
  Map<DateTime, int> data = {};

  //loop through each habit
  for(var habit in habits){
    for(var completionDay in habit.completedDays){
      final normalizedDate = DateTime(completionDay.year, completionDay.month, completionDay.day);

      //if exists increment the count
      if (data.containsKey(normalizedDate)){
        data[normalizedDate] = data[normalizedDate]! + 1;
      }
      else{
        data[normalizedDate] = 1;
      }
    }
  }
  return data;
}