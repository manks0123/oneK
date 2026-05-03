import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await AuthService.instance.login(
      email: _emailCtrl.text.trim(),
      displayName: _isRegister ? _nameCtrl.text.trim() : null,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _quickGoogle() async {
    setState(() => _loading = true);
    await AuthService.instance.login(
      email: 'demo@google.com',
      displayName: 'คุณนิว',
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('✨', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  _isRegister ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'เข้าสู่ระบบเพื่อใช้ระบบวางแพลนทริปอัตโนมัติ',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 28),
                if (_isRegister) ...[
                  _field(
                    controller: _nameCtrl,
                    label: 'ชื่อแสดงผล',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'กรุณากรอกชื่อ'
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
                _field(
                  controller: _emailCtrl,
                  label: 'อีเมล',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _passCtrl,
                  label: 'รหัสผ่าน',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 4)
                      ? 'รหัสผ่านอย่างน้อย 4 ตัว'
                      : null,
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegister ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('หรือ',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.08)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _quickGoogle,
                  icon: const Text('G',
                      style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  label: const Text('เข้าด้วย Google (Demo)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister
                          ? 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'
                          : 'ยังไม่มีบัญชี? สมัครสมาชิก',
                      style: const TextStyle(color: AppColors.accentPink),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.accentPink, width: 1.5),
        ),
      ),
    );
  }
}
