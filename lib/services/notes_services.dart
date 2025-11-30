import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/notes_model.dart';

class NotesService {
  // Fetch all notes for current user
  Future<List<Note>> getNotes() async {
    final response = await supabase
        .from('notes')
        .select()
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  // Create new note
  Future<Note> createNote(
    String title, 
    String content, {
    String? category,
    int? colorIndex,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    
    final response = await supabase
        .from('notes')
        .insert({
          'user_id': userId,
          'title': title,
          'content': content,
          'category': category,
          'color_index': colorIndex,
        })
        .select()
        .single();
    
    return Note.fromJson(response);
  }

  // Update existing note
  Future<void> updateNote(
    String id, 
    String title, 
    String content, {
    String? category,
    int? colorIndex,
  }) async {
    await supabase
        .from('notes')
        .update({
          'title': title,
          'content': content,
          'category': category,
          'color_index': colorIndex,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  // Delete note
  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }
}