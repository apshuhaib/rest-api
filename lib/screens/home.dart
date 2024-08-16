import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rest_api/screens/add_todo.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List items = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['_id'];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(onSelected: (value) {
                  if (value == 'edit') {
                    NavigatetoEdit(item);
                    print('edit');
                  } else if (value == 'delete') {
                    deleteById(id);
                  }
                }, itemBuilder: (ctx) {
                  return [
                    PopupMenuItem(
                      child: Text('Edit'),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: Text('delete'),
                      value: 'delete',
                    ),
                  ];
                }),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: NavigatetoAdd,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> NavigatetoAdd() async {
    final route = MaterialPageRoute(builder: (ctx) {
      return AddTodo();
    });

    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
      fetchData();
    });
  }

  Future<void> NavigatetoEdit(Map item) async {
    final route = MaterialPageRoute(builder: (ctx) {
      return AddTodo(
        todo: item,
      );
    });
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
      fetchData();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response = await http
        .get(Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=20'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
        print(items);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteById(String id) async {
    final response =
        await http.delete(Uri.parse('https://api.nstack.in/v1/todos/$id'));
    if (response.statusCode == 200) {
      showSuccesMessage('deleted');
      final filteredItems =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItems;
      });
    } else {
      showErrorMessage('deletio failed');
      print('error');
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
