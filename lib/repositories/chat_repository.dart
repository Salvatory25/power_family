import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  final _supabase = Supabase.instance.client;

  // Fetch all chats for a specific user
  Future<List<ChatModel>> getUserChats(UserModel user) async {
    final isSuperAdmin = user.role == 'SUPER_ADMIN' || user.role == 'SYSTEM_ADMIN';
    final isBranchManager = user.role == 'BRANCH_MANAGER';

    var query = _supabase
        .from('chats')
        .select('''
          *,
          participant1:profiles!chats_participant1_id_fkey(first_name, last_name, primary_role, avatar_url),
          participant2:profiles!chats_participant2_id_fkey(first_name, last_name, primary_role, avatar_url)
        ''');

    if (isSuperAdmin) {
      // Super Admin can see all chats
    } else if (isBranchManager && user.branchId != null) {
      query = query.or('branch_id.eq.${user.branchId},participant1_id.eq.${user.uid},participant2_id.eq.${user.uid}');
    } else {
      query = query.or('participant1_id.eq.${user.uid},participant2_id.eq.${user.uid}');
    }

    final response = await query.order('updated_at', ascending: false);

    return (response as List).map((data) {
      // Determine the "other" participant's info
      final isPart1 = data['participant1_id'] == user.uid;
      final otherData = isPart1 ? data['participant2'] : data['participant1'];
      
      final otherName = otherData != null 
          ? "${otherData['first_name']} ${otherData['last_name']}".trim()
          : 'Unknown User';
          
      final mutableData = Map<String, dynamic>.from(data);
      mutableData['other_name'] = otherName;
      mutableData['other_role'] = otherData?['primary_role'];
      mutableData['other_avatar'] = otherData?['avatar_url'];

      return ChatModel.fromMap(mutableData, currentUserId: user.uid);
    }).toList();
  }

  Future<ChatModel> startPropertyChat(String currentUserId, String propertyId, String branchId) async {
    // Check if chat for this property and user already exists
    final existing = await _supabase
        .from('chats')
        .select('''
          *,
          participant1:profiles!chats_participant1_id_fkey(first_name, last_name, primary_role, avatar_url),
          participant2:profiles!chats_participant2_id_fkey(first_name, last_name, primary_role, avatar_url)
        ''')
        .eq('property_id', propertyId)
        .or('participant1_id.eq.$currentUserId,participant2_id.eq.$currentUserId')
        .maybeSingle();

    if (existing != null) {
      final isPart1 = existing['participant1_id'] == currentUserId;
      final otherData = isPart1 ? existing['participant2'] : existing['participant1'];
      
      final otherName = otherData != null 
          ? "${otherData['first_name']} ${otherData['last_name']}".trim()
          : 'Unknown User';
          
      final mutableData = Map<String, dynamic>.from(existing);
      mutableData['other_name'] = otherName;
      mutableData['other_role'] = otherData?['primary_role'];
      mutableData['other_avatar'] = otherData?['avatar_url'];

      return ChatModel.fromMap(mutableData, currentUserId: currentUserId);
    }

    // Try to find the branch manager
    final bmRes = await _supabase
        .from('profiles')
        .select('id')
        .eq('branch_id', branchId)
        .eq('primary_role', 'BRANCH_MANAGER')
        .limit(1);
    
    String participant2Id = currentUserId; // fallback
    if (bmRes != null && (bmRes as List).isNotEmpty) {
      participant2Id = bmRes.first['id'].toString();
    } else {
       final saRes = await _supabase.from('profiles').select('id').eq('primary_role', 'SUPER_ADMIN').limit(1);
       if (saRes != null && (saRes as List).isNotEmpty) participant2Id = saRes.first['id'].toString();
    }

    // Ensure they are not the same (if branch manager is testing their own property)
    if (participant2Id == currentUserId) {
      final saRes = await _supabase.from('profiles').select('id').neq('id', currentUserId).limit(1);
      if (saRes != null && (saRes as List).isNotEmpty) participant2Id = saRes.first['id'].toString();
    }

    final p1 = currentUserId.compareTo(participant2Id) < 0 ? currentUserId : participant2Id;
    final p2 = currentUserId.compareTo(participant2Id) < 0 ? participant2Id : currentUserId;

    final newChat = await _supabase.from('chats').insert({
      'participant1_id': p1,
      'participant2_id': p2,
      'property_id': propertyId,
      'branch_id': branchId,
    }).select().single();

    // Fetch the joined data to get the names
    final fullChat = await _supabase
        .from('chats')
        .select('''
          *,
          participant1:profiles!chats_participant1_id_fkey(first_name, last_name, primary_role, avatar_url),
          participant2:profiles!chats_participant2_id_fkey(first_name, last_name, primary_role, avatar_url)
        ''')
        .eq('id', newChat['id'])
        .single();
        
    final isPart1 = fullChat['participant1_id'] == currentUserId;
    final otherData = isPart1 ? fullChat['participant2'] : fullChat['participant1'];
    
    final otherName = otherData != null 
        ? "${otherData['first_name']} ${otherData['last_name']}".trim()
        : 'Unknown User';
        
    final mutableData = Map<String, dynamic>.from(fullChat);
    mutableData['other_name'] = otherName;
    mutableData['other_role'] = otherData?['primary_role'];
    mutableData['other_avatar'] = otherData?['avatar_url'];

    return ChatModel.fromMap(mutableData, currentUserId: currentUserId);
  }

  // Find existing chat or create a new one
  Future<ChatModel> startOrGetChat(String currentUserId, String otherUserId) async {
    // Check if chat exists
    final response = await _supabase
        .from('chats')
        .select()
        .or('and(participant1_id.eq.$currentUserId,participant2_id.eq.$otherUserId),and(participant1_id.eq.$otherUserId,participant2_id.eq.$currentUserId)')
        .maybeSingle();

    if (response != null) {
      return ChatModel.fromMap(response, currentUserId: currentUserId);
    }

    // Ensure smaller ID is always participant 1
    final p1 = currentUserId.compareTo(otherUserId) < 0 ? currentUserId : otherUserId;
    final p2 = currentUserId.compareTo(otherUserId) < 0 ? otherUserId : currentUserId;

    // Create new chat
    final newChat = await _supabase.from('chats').insert({
      'participant1_id': p1,
      'participant2_id': p2,
    }).select().single();

    return ChatModel.fromMap(newChat, currentUserId: currentUserId);
  }

  // Fetch messages for a chat
  Future<List<MessageModel>> getMessages(String chatId, String currentUserId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((data) => MessageModel.fromMap(data, currentUserId: currentUserId))
        .toList();
  }

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String content) async {
    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    });
  }

  // Subscribe to new messages for a chat
  SupabaseStreamBuilder subscribeToMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
  }
  
  // Subscribe to chats for real-time list updates
  SupabaseStreamBuilder subscribeToChats(String userId) {
     return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
        // Note: Realtime filtering by OR is limited, so we might need to filter client side or use a different approach for large scale.
  }

  // Get a list of users to start a chat with (e.g. admins/agents)
  Future<List<UserModel>> getAvailableUsersToChat() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .inFilter('primary_role', ['SUPER_ADMIN', 'ADMIN', 'BRANCH_MANAGER', 'SALES_AGENT']);
        
    return (response as List).map((data) => UserModel.fromMap(data, data['id'])).toList();
  }
}
