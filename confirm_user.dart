import 'package:supabase/supabase.dart';

void main() async {
  final url = 'https://lwrfjgnlepgsmsqzntvj.supabase.co';
  final key = 'YOUR_SUPABASE_SECRET_KEY'; // Load this from .env in production
  
  try {
    final client = SupabaseClient(url, key);
    final res = await client.auth.admin.listUsers();
    for (var u in res) {
      print('User: ${u.email} - Confirmed: ${u.emailConfirmedAt != null}');
      if (u.emailConfirmedAt == null) {
        await client.auth.admin.updateUserById(u.id, attributes: AdminUserAttributes(emailConfirm: true));
        print('Confirmed ${u.email}!');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
