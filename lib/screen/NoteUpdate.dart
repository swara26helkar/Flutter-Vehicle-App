import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteUpdate extends StatefulWidget {
  const NoteUpdate({super.key});

  @override
  State<NoteUpdate> createState() => _NoteUpdateState();
}

class _NoteUpdateState extends State<NoteUpdate> {
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, String>> notes = [];

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      setState(() {
        notes.insert(0, {"note": _noteController.text, "date": formattedDate});
        _noteController.clear();
      });
    }
  }

  void _editNote(int index) {
    _noteController.text = notes[index]["note"]!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Note",
            style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 100, // Set height for the TextField
            child: TextField(
              controller: _noteController,
              maxLines: null, // Allows multi-line input
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _noteController.clear();
              },
              child: const Text("Cancel",style: TextStyle(color: Colors.blue, fontSize: 18,fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  notes[index]["note"] = _noteController.text;
                });
                Navigator.pop(context);
                _noteController.clear();
              },
              child: const Text("Save",style: TextStyle(color: Colors.blue, fontSize: 18,fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text(
              "Notepad",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bookmark_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Enter Note",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 100, // Increased height
                        child: TextField(
                          controller: _noteController,
                          maxLines: null, // Allows text to wrap
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.note_add),
                            hintText: "Type your note here...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addNote,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Note",style: TextStyle(color: Colors.white,fontSize: 14),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.sticky_note_2, color: Colors.blue),
                    title: Text(
                      notes[index]["note"]!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey,),
                        const SizedBox(width: 5),
                        Text(
                          notes[index]["date"]!,
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editNote(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
