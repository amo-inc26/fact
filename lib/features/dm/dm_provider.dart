import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dm_provider.g.dart';

@riverpod
class DMController extends _$DMController {
  @override
  FutureOr<List<ChatPreview>> build() async {
    return _fetchChatPreviews();
  }

  Future<List<ChatPreview>> _fetchChatPreviews() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final messagesResponse = await supabase
        .from('messages')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .order('created_at', ascending: false);

    final partnerIds = <String>{};
    for (final m in messagesResponse as List) {
      if (m['sender_id'] != user.id) partnerIds.add(m['sender_id']);
      if (m['receiver_id'] != user.id) partnerIds.add(m['receiver_id']);
    }

    if (partnerIds.isEmpty) return [];

    final List<ChatPreview> previews = [];
    for (final partnerId in partnerIds) {
      final profile = await supabase.from('profiles').select().eq('id', partnerId).single();
      final lastMessage = await supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.${user.id},receiver_id.eq.$partnerId),and(sender_id.eq.$partnerId,receiver_id.eq.${user.id})')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      previews.add(ChatPreview(
        partnerId: partnerId,
        partnerName: profile['username'] ?? 'Unknown',
        partnerAvatar: profile['avatar_url'],
        lastMessage: lastMessage['content'],
        lastMessageTime: DateTime.parse(lastMessage['created_at']),
        isRead: lastMessage['receiver_id'] != user.id || lastMessage['is_read'] == true,
      ));
    }

    return previews;
  }
}

class ChatPreview {
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;

  ChatPreview({
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isRead,
  });
}

@riverpod
class ChatRoomController extends _$ChatRoomController {
  @override
  Stream<List<Map<String, dynamic>>> build(String partnerId) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((maps) {
          return maps.where((m) =>
            (m['sender_id'] == user.id && m['receiver_id'] == partnerId) ||
            (m['sender_id'] == partnerId && m['receiver_id'] == user.id)
          ).toList();
        });
  }

  Future<void> sendMessage(String partnerId, String content) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('messages').insert({
      'sender_id': user.id,
      'receiver_id': partnerId,
      'content': content,
    });
  }
}
