import 'package:flutter/material.dart';
import 'notification_helper.dart';
import 'footer.dart'; // footer.dartをインポート
import 'graph.dart'; // graph.dartをインポート

void main() async {
  // 通知プラグインの初期化
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();

  // 日本時間の午前10時に通知をスケジュール
  await showNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ドリカムダイアリー',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = [];
  List<String> genres = ['勉強', '仕事', '運動']; // ジャンルのリスト

  String selectedGenre = '勉強'; // 選択されたジャンルの初期値

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      if(task.genre == "勉強") {
        studyData[0] += task.hours;
      } else if(task.genre == "仕事") {
        workData[0] += task.hours;
      } else if(task.genre == "運動") {
        exerciseData[0] += task.hours;
      }
    });
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _hoursController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  @override
  void initState() {
    DateTime selectedDate = DateTime.parse("2024-01-17");
    double hours = double.parse("3");
    selectedGenre = "勉強";
    Task newTask = Task("数学　青チャート", selectedDate, hours, selectedGenre);
    addTask(newTask);

    selectedDate = DateTime.parse("2024-01-17");
    hours = double.parse("2");
    selectedGenre = "運動";
    newTask = Task("サッカーのドリブル練習", selectedDate, hours, selectedGenre);
    addTask(newTask);

    selectedDate = DateTime.parse("2024-01-17");
    hours = double.parse("4");
    selectedGenre = "仕事";
    newTask = Task("レストランバイト", selectedDate, hours, selectedGenre);
    addTask(newTask);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ドリカムダイアリー'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].title),
            subtitle: Text(
              'ジャンル: ${tasks[index].genre}, 日時: ${tasks[index].formattedDate}, 時間: ${tasks[index].hours} 時間',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeTask(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Text('やったこと'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: 'タイトル'),
                        ),
                        SizedBox(height: 20),
                        DropdownButton<String>(
                          value: selectedGenre,
                          items: genres.map((String genre) {
                            return DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGenre = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _dateController,
                          decoration: InputDecoration(labelText: '日付 (yyyy-MM-dd)'),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: '時間'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('キャンセル'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('追加'),
                        onPressed: () {
                          String title = _titleController.text;
                          String dateText = _dateController.text;
                          String hoursString = _hoursController.text;

                          if (title.isNotEmpty && dateText.isNotEmpty && hoursString.isNotEmpty) {
                            DateTime selectedDate = DateTime.parse(dateText);
                            double hours = double.parse(hoursString);

                            Task newTask = Task(title, selectedDate, hours, selectedGenre);
                            addTask(newTask);
                          }
                          Navigator.of(context).pop();
                          _titleController.clear();
                          _dateController.clear();
                          _hoursController.clear();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Footer(
        onItemTapped: (index) {
          // フッターのアイテムがタップされたときの処理
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GraphScreen()), // GraphScreenは以前の回答で提供されたウィジェットです
            );
          }
        },
      ),
    );
  }
}

class Task {
  final String title;
  final DateTime date;
  final double hours;
  final String genre;

  Task(this.title, this.date, this.hours, this.genre);

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
