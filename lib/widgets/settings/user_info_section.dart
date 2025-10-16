import 'package:flutter/material.dart';

class UserInfoSection extends StatefulWidget {
  final bool isEditing;
  final VoidCallback onEditToggle;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final TextEditingController nicknameController;
  final TextEditingController fullnameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final Function(BuildContext) onSelectDate;
  final List<String> genders;
  final String selectedGender;
  final Function(String?) onGenderChanged;

  const UserInfoSection({
    super.key,
    required this.isEditing,
    required this.onEditToggle,
    required this.onCancel,
    required this.onSave,
    required this.nicknameController,
    required this.fullnameController,
    required this.phoneController,
    required this.dobController,
    required this.onSelectDate,
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  State<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin người dùng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.isEditing ? Icons.close : Icons.edit,
                  color: Colors.black,
                ),
                onPressed: widget.isEditing ? widget.onCancel : widget.onEditToggle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Nickname', widget.nicknameController, null, widget.isEditing),
          _buildInfoRow(Icons.badge, 'Họ và tên', widget.fullnameController, null, widget.isEditing),
          _buildInfoRow(Icons.phone, 'Số điện thoại', widget.phoneController, null, widget.isEditing),
          _buildInfoRow(Icons.calendar_today, 'Ngày sinh', widget.dobController, widget.onSelectDate, widget.isEditing),
          _buildGenderInfoRow(Icons.people, 'Giới tính', widget.isEditing),
          if (widget.isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7FD957),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderInfoRow(IconData icon, String label, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? Row(
                        children: widget.genders.map((gender) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: gender,
                                groupValue: widget.selectedGender,
                                onChanged: widget.onGenderChanged,
                                activeColor: const Color(0xFF7FD957),
                              ),
                              Text(gender),
                              const SizedBox(width: 16),
                            ],
                          );
                        }).toList(),
                      )
                    : Text(
                        widget.selectedGender.isNotEmpty ? widget.selectedGender : 'Chưa thêm',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.selectedGender.isNotEmpty ? Colors.black87 : Colors.grey,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, TextEditingController? controller,
      Function(BuildContext)? onTap, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? TextFormField(
                        controller: controller,
                        readOnly: onTap != null, // Make read-only if onTap is provided (for date picker)
                        onTap: onTap != null ? () => onTap!(context) : null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: onTap != null ? const Icon(Icons.calendar_today, size: 20) : null,
                        ),
                      )
                    : Text(
                        controller?.text.isNotEmpty == true ? controller!.text : 'Chưa thêm',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller?.text.isNotEmpty == true ? Colors.black87 : Colors.grey,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}