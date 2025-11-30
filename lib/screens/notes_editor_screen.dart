import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/notes_model.dart';
import '../services/notes_services.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NotesService _notesService = NotesService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;
  String _selectedCategory = 'Personal';

  final List<String> _categories = ['Personal', 'Work', 'Fitness'];
  
  final List<Color> _noteColors = [
    const Color(0xFFB5A6D9), // Purple
    const Color(0xFFA8E6A3), // Light green
    const Color(0xFF99D6EA), // Light blue
    const Color(0xFFFDD85D), // Yellow
    const Color(0xFFFDC921), // Orange
  ];
  
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    // If editing, try to get the category from the note
    if (widget.note != null) {
      _selectedCategory = widget.note!.category ?? 'Personal';
      _selectedColorIndex = widget.note!.colorIndex ?? 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showCustomSnackBar('Please enter a title', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.note == null) {
        await _notesService.createNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
          category: _selectedCategory,
          colorIndex: _selectedColorIndex,
        );
      } else {
        await _notesService.updateNote(
          widget.note!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
          category: _selectedCategory,
          colorIndex: _selectedColorIndex,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar('Error saving note', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError 
            ? const Color(0xFFE57373) 
            : const Color(0xFF6798C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.trim().isNotEmpty || 
        _contentController.text.trim().isNotEmpty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFDC921).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDD85D).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 32,
                      color: Color(0xFFFDC921),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Discard Changes?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You have unsaved changes. Do you want to discard them?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(46),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Keep Editing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDC921),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(46),
                            ),
                          ),
                          child: const Text(
                            'Discard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return shouldDiscard ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFDF7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFDC921),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDC921),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFDC921).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check_rounded),
                    color: Colors.white,
                    onPressed: _saveNote,
                    tooltip: 'Save',
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Color Picker
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _noteColors.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedColorIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _noteColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Colors.black87 
                                : Colors.black.withOpacity(0.1),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _noteColors[index].withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Category Pills
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black87 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.black.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '#$category',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Note Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _noteColors[_selectedColorIndex].withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _noteColors[_selectedColorIndex].withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Note Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                    ),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: 'Start typing your note...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}