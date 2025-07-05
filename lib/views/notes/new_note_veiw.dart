// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/notes_services.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // Future<DatabaseNote> createNewNote() async {
  //   final existingNote = _note;
  //   if (existingNote != null) {
  //     return existingNote;
  //   } else {
  //     final currentUser = AuthService.firebase().currentUser!;
  //     final email = currentUser.email!;
  //     final owner = await _notesService.getUser(email: email);
  //     return await _notesService.createNote(owner: owner);
  //   }
  // }

  // Future<DatabaseNote> createNewNote() async {
  //   final existingNote = _note;
  //   if (existingNote != null) {
  //     return existingNote;
  //   } else {
  //     final currentUser = AuthService.firebase().currentUser!;
  //     final email = currentUser.email!;
  //     final owner = await _notesService.getUser(email: email);
  //     return await _notesService.createNote(owner: owner);
  //   }
  // }
  Future<DatabaseNote?> createNewNote() async {
    if (_note != null) {
      return _note;
    }

    try {
      final currentUser = AuthService.firebase().currentUser;
      if (currentUser == null) {
        print("❌ No logged-in user");
        return null;
      }

      final email = currentUser.email;
      if (email == null) {
        print("❌ Current user has no email");
        return null;
      }

      final owner = await _notesService.getUser(email: email);
      final newNote = await _notesService.createNote(owner: owner);
      print("✅ Note created with ID: ${newNote.id}");
      return newNote;
    } catch (e, stack) {
      print("❌ Error creating note: $e");
      print(stack);
      return null;
    }
  }

  void _deleteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(noteId: note.id);
    }
  }

  void _saveNoteIfTextIsEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteIfTextIsEmpty();
    _saveNoteIfTextIsEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // case ConnectionState.done:
            //   _note = snapshot.data as DatabaseNote;
            //   _setupTextControllerListener();
            //   return TextField(
            //     controller: _textController,
            //     keyboardType: TextInputType.multiline,
            //     maxLines: null,
            //   );
            case ConnectionState.done:
              final note = snapshot.data;
              if (note == null) {
                return const Center(child: Text("❌ Could not load note"));
              }

              _note = note; // ✅ No need to cast
              _setupTextControllerListener();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing here...',
                ),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
