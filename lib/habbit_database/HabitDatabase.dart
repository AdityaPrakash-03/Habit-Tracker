import 'package:habbit_tracker/models/app_settings.dart';
import 'package:habbit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;



//database initialization
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path);
  }

//save first launch date  
  Future<void> saveFirstLaunchDate() async{
    final existingAppSettings = await isar.appSettings.where().findFirst();
    if (existingAppSettings == null) {
      final appSettings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }
  
//get first launch date
  Future<DateTime?> getFirstLaunchDate() async{
    final existingAppSettings = await isar.appSettings.where().findFirst();
    return existingAppSettings?.firstLaunchDate;
  }







//list of habits
final List<Habit> currentHabits = [];

//add a new habit
Future<void> addHabit(String habitName) async{
  //create a new habit
  final newHabit = Habit()..name = habitName;
  //add the habit to the list
  currentHabits.add(newHabit);
  //save the habit to the database
  await isar.writeTxn(() => isar.habits.put(newHabit));
  //reread the habits from the database
  readHabits();
}

//read the habits from the database
Future<void> readHabits() async{
  //get all habits from the database
  List<Habit> habits = await isar.habits.where().findAll();
  //update the list of habits
  currentHabits.clear();
  currentHabits.addAll(habits);
  //notify listeners
  notifyListeners();
}
//update a habit(on and off)
Future<void> updateHabitCompletion(int id, bool isCompleted) async{
  //find specific habit
  final habit = await isar.habits.get(id);

  //update completion status
  if (habit != null) {
    await isar.writeTxn(()async{
      if(isCompleted && !habit.completedDays.contains(DateTime.now())){
        final today = DateTime.now();
        habit.completedDays.add(
          DateTime(today.year, today.month, today.day)
        );
      }else{
        habit.completedDays.removeWhere(
          (date) =>
          date.year == DateTime.now().year && 
          date.month == DateTime.now().month && 
          date.day == DateTime.now().day);
      }
      //save the habit to the database
      await isar.habits.put(habit);
    });
  }
//reread the habits from the database
    readHabits();
}
// update - edit habit name
Future<void> updateHabitName(int id, String newName) async{
  //find specific habit
  final habit = await isar.habits.get(id);
  //update the habit name
  if (habit != null) {
    await isar.writeTxn(() async{
      habit.name = newName;
      await isar.habits.put(habit);
    });
  }
  //reread the habits from the database
  readHabits();
} 
//delete a habit
Future<void> deleteHabit(int id) async{
  await isar.writeTxn(() async{
    await isar.habits.delete(id);
  });
  //reread the habits from the database
  readHabits();
}
}