import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StudyTrackerScreen(),
    );
  }
}

class StudyTrackerScreen extends StatefulWidget {
  @override
  _StudyTrackerScreenState createState() => _StudyTrackerScreenState();
}

class _StudyTrackerScreenState extends State<StudyTrackerScreen> {
  Database? _database;
  sql.Database? _windowsDatabase;
  TextEditingController _topicController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _topics = [];
  List<Map<String, dynamic>> _revisions = [];
  String _selectedFilter = "All"; // Declare the filter
  



  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    if (Platform.isAndroid) {
      await _initAndroidDatabase();
    } else if (Platform.isWindows) {
      _initWindowsDatabase();
    }
  }

  Future<void> _initAndroidDatabase() async {
    if (_database != null) return;
    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'study_tracker.db'),
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE topics(
            id INTEGER PRIMARY KEY, 
            study_topic TEXT, 
            study_date TEXT
          )
        """);
        await db.execute("""
          CREATE TABLE revisions(
            id INTEGER PRIMARY KEY, 
            topic_id INTEGER, 
            revision_date TEXT, 
            completed INTEGER DEFAULT 0,
            revision_time INTEGER,
            FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
          )
        """);
      },
      version: 1,
    );
    _loadTopics();
  }

  void _initWindowsDatabase() {
    if (_windowsDatabase != null) return;
    _windowsDatabase = sql.sqlite3.open('study_tracker.db');

    _windowsDatabase!.execute("""
      CREATE TABLE IF NOT EXISTS topics(
        id INTEGER PRIMARY KEY, 
        study_topic TEXT, 
        study_date TEXT
      )
    """);

    _windowsDatabase!.execute("""
      CREATE TABLE IF NOT EXISTS revisions(
        id INTEGER PRIMARY KEY, 
        topic_id INTEGER, 
        revision_date TEXT, 
        completed INTEGER DEFAULT 0,
        revision_time INTEGER,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    """);
    _loadTopics();
  }

  Future<void> _addTopic() async {
  if (_topicController.text.isEmpty || _selectedDate == null) return;
  String studyDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

  if (Platform.isAndroid) {
    final db = _database!;
    int topicId = await db.insert('topics', {
      'study_topic': _topicController.text,
      'study_date': studyDate,
    });

    List<int> intervals = [3, 7, 15];
    for (int i = 0; i < intervals.length; i++) {
      String revisionDate = DateFormat('yyyy-MM-dd')
          .format(_selectedDate!.add(Duration(days: intervals[i])));
      await db.insert('revisions', {
        'topic_id': topicId,
        'revision_date': revisionDate,
        'revision_time': i + 1,
        'completed': 0,
      });
    }
  } else if (Platform.isWindows) {
    final db = _windowsDatabase!;
    
    // Insert topic
    db.execute("INSERT INTO topics (study_topic, study_date) VALUES (?, ?)", 
      [_topicController.text, studyDate]);
    
    // Fetch last inserted topic ID
    final result = db.select("SELECT last_insert_rowid() AS id");
    int topicId = result.first['id'] as int;
    
    print("Inserted Topic ID: $topicId"); // Debugging

    // Insert revisions
    List<int> intervals = [3, 7, 15];
    for (int i = 0; i < intervals.length; i++) {
      String revisionDate = DateFormat('yyyy-MM-dd')
          .format(_selectedDate!.add(Duration(days: intervals[i])));
      db.execute("INSERT INTO revisions (topic_id, revision_date, revision_time, completed) VALUES (?, ?, ?, ?)", 
        [topicId, revisionDate, i + 1, 0]);
    }
    
    
  }

  _topicController.clear();
  _loadTopics();
}


  Future<void> _loadTopics() async {
    List<Map<String, dynamic>> topics = [];

    if (Platform.isAndroid) {
      final db = _database!;
      topics = await db.query('topics');
    } else if (Platform.isWindows) {
      final db = _windowsDatabase!;
      final result = db.select("SELECT * FROM topics");
      topics = result
          .map((row) => {'id': row['id'], 'study_topic': row['study_topic'], 'study_date': row['study_date']})
          .toList();
    }

    setState(() {
      _topics = topics;
    });
  }

  Future<void> _loadRevisions(DateTime? date) async {
  List<Map<String, dynamic>> revisions = [];

  if (Platform.isAndroid) {
    final db = _database!;
    if (date == null) {
      // Load all revisions
      revisions = await db.rawQuery('''
        SELECT  topics.id as t_id,revisions.id,topics.study_topic, revisions.revision_date,topics.study_date ,revisions.revision_time
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.completed = 0
        ORDER BY revisions.revision_date ASC
      ''');
    } else {
      // Load revisions for selected date
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      revisions = await db.rawQuery('''
        SELECT revisions.id,topics.id as t_id,topics.study_topic, revisions.revision_date,topics.study_date ,revisions.revision_time
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.revision_date = ? AND revisions.completed = 0
      ''', [dateString]);
    }
  } else if (Platform.isWindows) {
    final db = _windowsDatabase!;
    if (date == null) {
      // Load all revisions
      final result = db.select('''
        SELECT revisions.id,topics.id as t_id,topics.study_topic, revisions.revision_date ,topics.study_date ,revisions.revision_time
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.completed = 0
        ORDER BY revisions.revision_date ASC
      ''');
      revisions = result.map((row) => {
        't_id':row['t_id'],
        'id':row['id'],
        'study_topic': row['study_topic'],
        'revision_date': row['revision_date'],
        'revision_time':row['revision_time'],
        'study_date':row['study_date']
      }).toList();
    } else {
      // Load revisions for selected date
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      final result = db.select('''
        SELECT revisions.id, topics.study_topic, revisions.revision_date 
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.revision_date = ? AND revisions.completed = 0
      ''', [dateString]);
      revisions = result.map((row) => {
        't_id':row['t_id'],
        'id':row['id'],
        'study_topic': row['study_topic'],
        'revision_date': row['revision_date'],
        'revision_time':row['revision_time'],
        'study_date':row['study_date']
      }).toList();
    }
  }
  print(revisions);
  setState(() {
    _revisions = revisions;
  });
}


  Future<void> _viewPendingTasks() async {
    List<Map<String, dynamic>> pendingRevisions = [];

    if (Platform.isAndroid) {
      final db = _database!;
      pendingRevisions = await db.rawQuery('''
        SELECT  topics.id, topics.study_topic, topics.study_date 
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.completed = 0
      ''');
    } else if (Platform.isWindows) {
      final db = _windowsDatabase!;
      
      final result = db.select('''
        SELECT  topics.id, topics.study_topic, topics.study_date 
        FROM topics 
        INNER JOIN revisions ON topics.id = revisions.topic_id
        WHERE revisions.completed = 0
      ''');
      pendingRevisions = result
          .map((row) => {'id': row['id'], 'study_topic': row['study_topic'], 'study_date': row['study_date']})
          .toList();

           
    }
   if (pendingRevisions.isNotEmpty) {
  if (Platform.isAndroid) {
    await _database!.update(
      'revisions',
      {'completed': 1},
      where: 'id = ?',
      whereArgs: [pendingRevisions[0]['id']],  // Update specific revision
    );
  } else if (Platform.isWindows) {
    _windowsDatabase!.execute('''
      UPDATE revisions
      SET completed = 1
      WHERE id = ?
    ''', [pendingRevisions[0]['id']]);  // Use execute() in Windows
  }
}


    setState(() {
      _topics = pendingRevisions;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Showing only pending tasks")),
      );
    }
  }




Future<void> _markComplete(int revisionId, String studyTopic, String revisionDate,int topicId,int revision_time) async {
  if (revisionId == 0 || studyTopic.isEmpty || revisionDate.isEmpty) {
    print(revisionId);
    print(studyTopic);
    print(revisionDate);
    print("Error: One or more required values are null or empty");
    return;
  }

  print("Marking Revision as Completed...");
  print("Revision ID: $revisionId");
  print("Study Topic: $studyTopic");
  print("Revision Date: $revisionDate");

  // Ensure correct database instance
  if (Platform.isAndroid) {
    final db = _database!;
    
    await db.update(
      'revisions',
      {'completed': 1},
      where: 'id = ?',
      whereArgs: [revisionId],
    );
  final String today= DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  if (revision_time == 1) {
   
    
    await db.rawUpdate("""
  UPDATE revisions 
  SET revision_date = CASE 
      WHEN revision_time = 2 THEN DATE(?, '+4 days') 
      WHEN revision_time = 3 THEN DATE(?, '+12 days') 
  END
  WHERE topic_id = (SELECT id FROM topics WHERE id = ?)
  AND revision_time IN (2,3);
""", [today,today,topicId]);

   
  } else if (revision_time == 2) {
   db.rawUpdate("""
  UPDATE revisions 
  SET revision_date = CASE 
      WHEN revision_time = 2 THEN DATE(?, '+4 days') 
      WHEN revision_time = 3 THEN DATE(?, '+12 days') 
  END
  WHERE topic_id = (SELECT id FROM topics WHERE id = ?)
  AND revision_time IN (3);
""", [today,today,topicId]);
  }

  } else if (Platform.isWindows) {
    final db = _windowsDatabase!;
    
    db.execute(
      'UPDATE revisions SET completed = 1 WHERE id = ?',
      [revisionId],
    );
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());


  if (revision_time == 1) {
  
     db.execute("""
  UPDATE revisions 
  SET revision_date = CASE 
      WHEN revision_time = 2 THEN DATE(?, '+4 days') 
      WHEN revision_time = 3 THEN DATE(?, '+12 days') 
  END
  WHERE topic_id = (SELECT id FROM topics WHERE id = ?)
  AND revision_time IN (2,3);
""", [today,today,topicId]);

   
  } else if (revision_time == 2) {
   db.execute("""
  UPDATE revisions 
  SET revision_date = CASE 
      WHEN revision_time = 2 THEN DATE(?, '+4 days') 
      WHEN revision_time = 3 THEN DATE(?, '+12 days') 
  END
  WHERE topic_id = (SELECT id FROM topics WHERE id = ?)
  AND revision_time IN (3);
""", [today,today,topicId]);
  }
  }

  print("Revision marked as completed successfully!");

  setState(() {
    _loadRevisions(DateTime.now());
  });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Revision marked as completed")),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: "Enter Study Topic",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Text(_selectedDate == null
                  ? "Select Study Date"
                  : "Study Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTopic,
              child: Text("Add Topic"),
            ),
            SizedBox(height: 20),

DropdownButton<String>(
  value: _selectedFilter,
  onChanged: (newValue) {
    setState(() {
      _selectedFilter = newValue!;
      if (_selectedFilter == "All") {
        _loadRevisions(null);
      }
    });
  },
  items: ["All", "Specific Date"].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),


SizedBox(height: 10),


if (_selectedFilter == "Specific Date")
  Column(
    children: [
      ElevatedButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
              _loadRevisions(_selectedDate); // Load revisions for the selected date
            });
          }
        },
        child: Text(
          _selectedDate == null
              ? "Select Date"
              : "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
        ),
      ),
      SizedBox(height: 10),
    ],
  ),

SizedBox(height: 10),

// Button to fetch data based on selection
ElevatedButton(
  onPressed: () => _loadRevisions(_selectedFilter == "Specific Date" ? _selectedDate : null),
  child: Text("View Revisions"),
),
            SizedBox(height: 10),
            Expanded(
  child: ListView.builder(
    itemCount: _revisions.length, // Use _revisions list
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(_revisions[index]['study_topic']), 
        subtitle: Text(
          'Revision Date: ${_revisions[index]['revision_date']} \nStudy Date: ${_revisions[index]['study_date']} \nRevision Time:${_revisions[index]['revision_time']}',
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            //int revisionId = _revisions[index]['id'];
            //int topicId = _revisions[index]['topic_id'];
            //sint revisionTime = _revisions[index]['revision_time'];
            print(_revisions[index]);
            // Mark revision as completed
          await _markComplete(_revisions[index]['id'], _revisions[index]['study_topic'],_revisions[index]['revision_date'],_revisions[index]['t_id'],_revisions[index]['revision_time']);
          },
          child: Text("Mark Complete"),
        ),
      );
    },
  ),
)


          ],
        ),
      ),
    );
  }
}
