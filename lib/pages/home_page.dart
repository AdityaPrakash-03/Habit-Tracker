// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart ';
import 'package:habbit_tracker/components/my_drawer.dart';
import 'package:habbit_tracker/components/my_habit_tile.dart';
import 'package:habbit_tracker/components/my_heat_map.dart';
import 'package:habbit_tracker/habbit_database/HabitDatabase.dart';
import 'package:habbit_tracker/models/habit.dart';
import 'package:habbit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState(){
    //read existing habits from database on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }
  //text controller
final TextEditingController textController = TextEditingController();
  //create a new habit
  void createHabit(){
    showDialog(context: context,
    builder: (context) => AlertDialog( 
      content: TextField(
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Enter habit name',
        ),
      ),
      actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newhabitName = textController.text;

              //save to database
              context.read<HabitDatabase>().addHabit(newhabitName);

              //pop box
              Navigator.pop(context);
              //clear text controller
              textController.clear();
            },
            child: Text('Save'),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: Text('Cancel'),
          )
        ]
      ),
    );
  }

//check habit on off
void checkHabitOnOff(bool? value, Habit habit){
  //update habit completion status
  if(value != null){
    context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
  }
}

//delete habit
void deleteHabit( Habit habit){
  showDialog(context: context, builder: (context) => AlertDialog(
    title: const Text('Are you sure you want to delete this habit?'),
    actions: [
          MaterialButton(
            onPressed: () {
              //save to database
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //pop box
              Navigator.pop(context);
              //clear text controller
              textController.clear();
            },
            child: Text('Delete'),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: Text('Cancel'),
          )
        ]
      ),  
    );
}

//edit habit
void editHabit( Habit habit){
  //current name
  textController.text = habit.name;
  //show dialog
  showDialog(context: context, builder: (context) => AlertDialog(
    content: TextField(
      controller: textController,
      decoration: InputDecoration(hintText: 'Edit habit name'),
    ),
    actions: [
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newhabitName = textController.text;

              //save to database
              context.read<HabitDatabase>().updateHabitName(habit.id, newhabitName);

              //pop box
              Navigator.pop(context);
              //clear text controller
              textController.clear();
            },
            child: Text('Save'),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: Text('Cancel'),
          )
        ]
      ),);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'WORK',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
    ),
    body: ListView(
      children: [
        _buildHeatList(),
        _buildHabitList()
      ],
    ),
  );
  }
  //habit list widget
Widget _buildHabitList(){
  //habit database
  final habitDatabase = context.watch<HabitDatabase>();
  //current habits
  List<Habit> currentHabits = habitDatabase.currentHabits;
  //return list of habits UI
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: currentHabits.length,
    itemBuilder: (context, index){
      //get each habit
      final habit = currentHabits[index];
      //check if habit is completed
      bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

      //return habit tile UI
      return MyHabitTile(
        isCompleted: isCompletedToday,
        text: habit.name,
        onChanged: (value) => checkHabitOnOff(value, habit),
        editHabit: (context) => editHabit(habit),
        deleteHabit: (context) => deleteHabit(habit),
    );
    }
  );
}
//heat map list widget
Widget _buildHeatList(){
  //habit database
  final habitDatabase = context.watch<HabitDatabase>();
  //current habits
  List<Habit> currentHabits = habitDatabase.currentHabits;
  //return heat map UI
  return  FutureBuilder<DateTime?>(
    future: habitDatabase.getFirstLaunchDate(), 
    builder: (context, snapshot){
      if(snapshot.hasData){
        return MyHeatMap(startDate: snapshot.data!, 
        endDate: DateTime.now(),
        Datasets: prepareDataForHeatMap(currentHabits),
        );

    }
    else{
      return Container();
    }
  });
}
}

