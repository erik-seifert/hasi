import 'package:flutter/material.dart';
import '../services/ha_log_database_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await HaLogDatabaseService.getLogs(limit: 200);
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HA Communication Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await HaLogDatabaseService.clearLogs();
              _loadLogs();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('No logs found'))
          : ListView.separated(
              itemCount: _logs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isSent = log['direction'] == 'SENT';
                return ListTile(
                  leading: Icon(
                    isSent ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isSent ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    '${log['type']} (${log['direction']})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['timestamp']
                            .toString()
                            .split('T')
                            .last
                            .split('.')
                            .first,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log['payload'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showLogDetail(context, log);
                  },
                );
              },
            ),
    );
  }

  void _showLogDetail(BuildContext context, Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['type'] ?? 'Log Detail'),
        content: SingleChildScrollView(
          child: SelectableText(
            log['payload'],
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
