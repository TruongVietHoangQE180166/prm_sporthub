import 'package:flutter/material.dart';

class ChangePasswordSection extends StatefulWidget {
  final bool isChangingPassword;
  final VoidCallback onTogglePasswordChange;
  final VoidCallback onCancelPasswordChanges;
  final VoidCallback onSavePasswordChanges;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isCurrentPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onToggleCurrentPasswordVisibility;
  final VoidCallback onToggleNewPasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;

  const ChangePasswordSection({
    super.key,
    required this.isChangingPassword,
    required this.onTogglePasswordChange,
    required this.onCancelPasswordChanges,
    required this.onSavePasswordChanges,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isCurrentPasswordVisible,
    required this.isNewPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onToggleCurrentPasswordVisibility,
    required this.onToggleNewPasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
  });

  @override
  State<ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Material(
              color: const Color(0xFF7FD957),
              child: InkWell(
                onTap: widget.onTogglePasswordChange,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF7FD957),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7FD957).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: widget.isChangingPassword ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.expand_more,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Current password
                    _buildPasswordRow(
                      Icons.lock,
                      'Mật khẩu hiện tại',
                      widget.currentPasswordController,
                      !widget.isCurrentPasswordVisible,
                      widget.onToggleCurrentPasswordVisibility,
                    ),
                    const SizedBox(height: 16),

                    // New password
                    _buildPasswordRow(
                      Icons.lock_outline,
                      'Mật khẩu mới',
                      widget.newPasswordController,
                      !widget.isNewPasswordVisible,
                      widget.onToggleNewPasswordVisibility,
                    ),
                    const SizedBox(height: 16),

                    // Confirm password
                    _buildPasswordRow(
                      Icons.lock_outline,
                      'Xác nhận mật khẩu mới',
                      widget.confirmPasswordController,
                      !widget.isConfirmPasswordVisible,
                      widget.onToggleConfirmPasswordVisibility,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCancelPasswordChanges,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1.5
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onSavePasswordChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7FD957),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: widget.isChangingPassword
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRow(IconData icon, String label, TextEditingController controller, bool isObscured, VoidCallback onVisibilityToggle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7FD957)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller,
                obscureText: isObscured,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: onVisibilityToggle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}