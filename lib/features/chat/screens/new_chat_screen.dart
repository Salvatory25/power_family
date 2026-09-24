import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../repositories/chat_repository.dart';
import '../../auth/auth_controller.dart';
import 'chat_room_screen.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _chatRepo = ChatRepository();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _chatRepo.getAvailableUsersToChat();
      // Remove self
      final currentUser = ref.read(authControllerProvider).value;
      if (currentUser != null) {
        users.removeWhere((u) => u.uid == currentUser.uid);
      }
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _startChat(UserModel otherUser) async {
    final currentUser = ref.read(authControllerProvider).value;
    if (currentUser == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chat = await _chatRepo.startOrGetChat(currentUser.uid, otherUser.uid);
      if (!mounted) return;
      
      Navigator.pop(context); // hide loading
      
      // Update chat with known info
      final chatWithInfo = chat.copyWith(
        otherParticipantName: otherUser.fullName,
        otherParticipantRole: otherUser.role,
        otherParticipantAvatar: otherUser.photoUrl,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatRoomScreen(chat: chatWithInfo)),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users available to chat.'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.fullName.substring(0, 1).toUpperCase(),
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.role.replaceAll('_', ' ')),
                      onTap: () => _startChat(user),
                    );
                  },
                ),
    );
  }
}
