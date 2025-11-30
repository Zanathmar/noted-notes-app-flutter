import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import '../main.dart';
import '../models/notes_model.dart';
import '../services/notes_services.dart';
import '../widgets/sticky_notes_card.dart';
import 'auth_screen.dart';
import 'notes_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  // Updated sticky note colors based on your palette
  final List<Color> _stickyColors = [
    const Color(0xFFB5A6D9), // Purple
    const Color(0xFFA8E6A3), // Light green
    const Color(0xFF99D6EA), // Light blue
    const Color(0xFFFDD85D), // Yellow
    const Color(0xFFFDC921), // Orange
  ];

  final List<String> _categories = [
    'All',
    'Personal',
    'Work',
    'Fitness',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterNotes() {
    setState(() {
      List<Note> filtered = _notes;
      
      // Filter by category
      if (_selectedCategory != 'All') {
        filtered = filtered.where((note) => note.category == _selectedCategory).toList();
      }
      
      // Filter by search
      if (_searchController.text.isNotEmpty) {
        filtered = filtered.where((note) {
          return note.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      }
      
      _filteredNotes = filtered;
    });
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _notesService.getNotes();
      setState(() {
        _notes = notes;
        _filteredNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showCustomSnackBar(
          'Error loading notes',
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await _notesService.deleteNote(id);
      _loadNotes();
      if (mounted) {
        _showCustomSnackBar(
          'Note deleted successfully',
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(
          'Error deleting note',
          isError: true,
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
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
                color: const Color.fromARGB(255, 233, 204, 42).withOpacity(0.3),
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
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 214, 42).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 32,
                    color: Color(0xFFFDC921),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Content
                const Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
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
                          backgroundColor: const Color.fromARGB(255, 244, 203, 19),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
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

    if (confirm == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
    // Auto-focus the search field after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
  
  void _hideSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _showCustomSnackBar(String message, {IconData? icon, bool isError = false}) {
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
                  icon ?? (isError ? Icons.error_outline_rounded : Icons.info_outline_rounded),
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
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _onNavigationTap(int index) {
    // Only allow center button (Add) to be tapped
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NoteEditorScreen(),
        ),
      ).then((_) => _loadNotes());
    }
  }

  Color _getColorForIndex(int index) {
    // Use the note's color index if available
    if (index < _filteredNotes.length && _filteredNotes[index].colorIndex != null) {
      return _stickyColors[_filteredNotes[index].colorIndex! % _stickyColors.length];
    }
    return _stickyColors[index % _stickyColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      body: Stack(
        children: [
          // Decorative Background Elements - Simple shapes
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB5D5E8).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFD4E7F0).withOpacity(0.25),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Positioned(
            bottom: 250,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFB5D5E8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD4E7F0).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Search Bar
                if (_isSearching) _buildSearchBar(),
                
                // Category Pills
                _buildCategoryPills(),
                
                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8AB4D5),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : _filteredNotes.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadNotes,
                              color: const Color(0xFF8AB4D5),
                              backgroundColor: Colors.white,
                              strokeWidth: 3,
                              displacement: 60,
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, i) {
                                  return StickyNoteCard(
                                    note: _filteredNotes[i],
                                    color: _getColorForIndex(i),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NoteEditorScreen(note: _filteredNotes[i]),
                                        ),
                                      );
                                      _loadNotes();
                                    },
                                    onDelete: () => _deleteNote(_filteredNotes[i].id),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Bottom bar background
          Container(
            height: 75,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 38, 38, 38).withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: CurvedNavigationBar(
                  index: 1,
                  backgroundColor: Colors.transparent,
                  color: Colors.white.withOpacity(0.85),
                  buttonBackgroundColor: Colors.transparent,
                  height: 75,
                  animationDuration: const Duration(milliseconds: 200),
                  animationCurve: Curves.easeInOut,
                  onTap: _onNavigationTap,
                  items: [
                    CurvedNavigationBarItem(
                      child: GestureDetector(
                        onTap: _signOut,
                        child: const Icon(
                          Icons.logout,
                          size: 32,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const CurvedNavigationBarItem(
                      child: SizedBox(width: 42, height: 42),
                    ),
                    CurvedNavigationBarItem(
                      child: GestureDetector(
                        onTap: _showSearch,
                        child: const Icon(
                          Icons.search,
                          size: 36,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Elevated plus button
          Positioned(
            bottom: 45,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NoteEditorScreen(),
                  ),
                ).then((_) => _loadNotes());
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 119, 183, 233),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8AB4D5).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Notes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFF8AB4D5).withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded, 
              color: Color(0xFF8AB4D5),
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black54),
                    onPressed: _hideSearch,
                  )
                : IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black54),
                    onPressed: _hideSearch,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Container(
      height: 67,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
      ),
      child: ListView.builder(
        
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _filterNotes();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8AB4D5) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF8AB4D5) 
                        : Colors.black.withOpacity(0.9),
                    width: 2,
                  ),
                  boxShadow: [
                    // Main 3D shadow (bottom-right)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      
                    ),
                    // Depth shadow
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.tag_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      category == 'All' ? 'All Notes' : category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFD4E7F0).withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF8AB4D5).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.sticky_note_2_outlined,
              size: 80,
              color: Color(0xFF8AB4D5),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap + to create your first sticky note',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.5),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}