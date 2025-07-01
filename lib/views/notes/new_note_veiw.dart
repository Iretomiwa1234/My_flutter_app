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
    _textController.addListener(_textControllerListener);
    _setupTextController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    if (text.isEmpty) {
      _notesService.deleteNote(noteId: note.id);
    } else {
      _notesService.updateNote(note: note, text: text);
    }
  }

  void _setupTextController() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser;
      final email = currentUser?.email;
      if (email == null) {
        throw Exception('User email is null');
      }
      final owner = await _notesService.getUser(email: email);
      return await _notesService.createNote(owner: owner);
    }
  }

  void _deleteIfTextIsEmpty() {
    if (_textController.text.isEmpty && _note != null) {
      _notesService.deleteNote(noteId: _note!.id);
    }
  }

  void _saveNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null && _textController.text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: _textController.text);
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
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
