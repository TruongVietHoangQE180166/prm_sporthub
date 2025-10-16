import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'dart:async';

class ResendOtpSection extends StatefulWidget {
  final String? email; // Add email parameter

  const ResendOtpSection({super.key, this.email});

  @override
  State<ResendOtpSection> createState() => _ResendOtpSectionState();
}

class _ResendOtpSectionState extends State<ResendOtpSection> {
  bool _isResendEnabled = false;
  int _remainingTime = 60; // 1 minute in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _isResendEnabled = false;
    _remainingTime = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> _handleResendOtp() async {
    if (widget.email == null || widget.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không có email để gửi OTP'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.sendOTP(widget.email!);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã OTP mới đã được gửi đến email của bạn'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _startCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Gửi OTP thất bại'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _isResendEnabled 
            ? 'Bạn chưa nhận được mã?' 
            : 'Gửi lại mã sau: ${_formatTime(_remainingTime)}',
          style: TextStyle(
            fontSize: 14,
            color: _isResendEnabled 
              ? Colors.grey.shade700 
              : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return TextButton(
              onPressed: _isResendEnabled && !authViewModel.isLoading ? _handleResendOtp : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Gửi lại mã OTP',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _isResendEnabled && !authViewModel.isLoading
                    ? Colors.green.shade600 
                    : Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}