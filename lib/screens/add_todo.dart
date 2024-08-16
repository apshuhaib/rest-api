import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodo extends StatefulWidget {
  final Map? todo;
  const AddTodo({super.key, this.todo});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  bool isEdit = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void initState() {
    final todo = widget.todo;

    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'title'),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(hintText: 'description'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Text(isEdit ? 'Update' : 'Submit'))
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('you ca ot update without dta');
      return;
    }
    final title = titleController.text;
    final description = descriptionController.text;
    final id = todo['_id'];
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final response = await http.put(
      Uri.parse(
        'https://api.nstack.in/v1/todos/$id',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      print(response.body);
      showSuccesMessage('created:${response.statusCode}');
    } else {
      showErrorMessage('failed :${response.statusCode}');
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final response = await http.post(
      Uri.parse(
        'https://api.nstack.in/v1/todos',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      titleController.clear();
      descriptionController.clear();
      print(response.body);
      showSuccesMessage('created:${response.statusCode}');
    } else {
      showErrorMessage('failed :${response.statusCode}');
    }
  }

  Future<void> showSuccesMessage(String message) async {
    final snackBar = SnackBar(
      content: Text('$message'),
      backgroundColor: Colors.green[200],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showErrorMessage(String message) async {
    final snackBar = SnackBar(
      content: Text('$message'),
      backgroundColor: Colors.red[200],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
