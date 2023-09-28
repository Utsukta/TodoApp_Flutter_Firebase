import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.brown,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController taskcontroller = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   List todo = [];
//   var title;
//   var description;

//   createtodo() {
//     DocumentReference documentReference =
//         FirebaseFirestore.instance.collection("Todos").doc(title);
//     Map<String, String> todolist = {"todotitle": title, "todoDes": description};
//     documentReference
//         .set(todolist)
//         .whenComplete(() => print("Data Stored Succesfully"));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Todo App"),
//       ),
//       body: ListView.builder(
//           itemCount: todo.length,
//           itemBuilder: (BuildContext context, int index) {
//             Task taskitem = todo[index];
//             return Card(
//                 child: ListTile(
//               trailing: GestureDetector(
//                 child: const Icon(Icons.delete),
//                 onTap: () {
//                   setState(() {
//                     todo.removeAt(index);
//                   });
//                 },
//               ),
//               title: Text(taskitem.title),
//               subtitle: Text(taskitem.description),
//             ));
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Center(child: Text("Add Task")),
//                   content: SizedBox(
//                     height: MediaQuery.of(context).size.height / 6,
//                     width: MediaQuery.of(context).size.width,
//                     child: Form(
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: taskcontroller,
//                             decoration: const InputDecoration(
//                                 icon: Icon(
//                                   Icons.task,
//                                   size: 30,
//                                 ),
//                                 border: OutlineInputBorder()),
//                           ),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           TextFormField(
//                             controller: descriptionController,
//                             decoration: const InputDecoration(
//                                 icon: Icon(
//                                   Icons.description,
//                                   size: 30,
//                                 ),
//                                 border: OutlineInputBorder()),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   actions: [
//                     OutlinedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text("Cancel")),
//                     OutlinedButton(
//                         onPressed: () {
//                           setState(() {
//                             title = taskcontroller.text.toString();
//                             description = descriptionController.text.toString();
//                             if (taskcontroller.text.isEmpty &&
//                                 descriptionController.text.isEmpty) {
//                               return;
//                             } else {
//                               Task newTask = Task(title, description);
//                               // todo.add(newTask);
//                               createtodo();
//                             }
//                           });
//                           Navigator.pop(context);
//                           taskcontroller.clear();
//                           descriptionController.clear();
//                         },
//                         child: const Text("Add")),
//                   ],
//                 );
//               });
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// class Task {
//   final String title;
//   final String description;

//   Task(this.title, this.description);
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List todos = List.empty();
  String title = "";
  String description = "";
  @override
  void initState() {
    super.initState();
    todos = [];
  }

  final addsnackBar = const SnackBar(
    content: Text('Task Added '),
  );
  final deletesnackBar = const SnackBar(
    content: Text('Task Deleted'),
  );

  createToDo() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(title);

    Map<String, String> todoList = {
      "todoTitle": title,
      "todoDesc": description
    };

    documentReference.set(todoList).whenComplete(
        () => ScaffoldMessenger.of(context).showSnackBar(addsnackBar));
  }

  deleteTodo(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);

    documentReference.delete().whenComplete(
        () => ScaffoldMessenger.of(context).showSnackBar(deletesnackBar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot<Object?>? documentSnapshot =
                      snapshot.data?.docs[index];
                  return Dismissible(
                      key: Key(index.toString()),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text((documentSnapshot != null)
                              ? (documentSnapshot["todoTitle"])
                              : ""),
                          subtitle: Text((documentSnapshot != null)
                              ? ((documentSnapshot["todoDesc"] != null)
                                  ? documentSnapshot["todoDesc"]
                                  : "")
                              : ""),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: const Color.fromARGB(255, 190, 111, 105),
                            onPressed: () {
                              setState(() {
                                //todos.removeAt(index);
                                deleteTodo((documentSnapshot != null)
                                    ? (documentSnapshot["todoTitle"])
                                    : "");
                              });
                            },
                          ),
                        ),
                      ));
                });
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Center(
                    child: Text(
                      "Add Task",
                      style: TextStyle(
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4,
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              hintText: "Task",
                              icon: Icon(Icons.task_outlined),
                              border: OutlineInputBorder()),
                          onChanged: (String value) {
                            title = value;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              hintText: "Description",
                              icon: Icon(Icons.description_outlined),
                              border: OutlineInputBorder()),
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            createToDo();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add")),
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
