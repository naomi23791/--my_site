import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = false;

  Future<void> _toggleReminder(bool value) async {
    setState(() => _loading = true);
    if (value) {
      await NotificationService.instance.scheduleDailyReminder(time: _reminderTime);
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
    setState(() {
      _reminderEnabled = value;
      _loading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      if (_reminderEnabled) {
        await NotificationService.instance.scheduleDailyReminder(time: picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Rappel quotidien'),
              subtitle: const Text('Recevoir un message "Reviens apprendre !"'),
              value: _reminderEnabled,
              onChanged: _loading ? null : _toggleReminder,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Heure du rappel'),
              subtitle: Text('${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.schedule),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            const Text(
              'Astuces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Choisissez une heure où vous êtes disponible pour renforcer votre routine.'),
          ],
        ),
      ),
    );
  }
}

