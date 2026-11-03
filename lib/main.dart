import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const ApexProApp());
}

class ApexProApp extends StatelessWidget {
  const ApexProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Pro Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
      ),
      home: const DownloadHomeScreen(),
    );
  }
}

class DownloadItem {
  final String url;
  String status;
  final String time;

  DownloadItem({
    required this.url,
    required this.status,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'status': status,
        'time': time,
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        url: json['url'] ?? '',
        status: json['status'] ?? '',
        time: json['time'] ?? '',
      );
}

class DownloadHomeScreen extends StatefulWidget {
  const DownloadHomeScreen({Key? key}) : super(key: key);

  @override
  State<DownloadHomeScreen> createState() => _DownloadHomeScreenState();
}

class _DownloadHomeScreenState extends State<DownloadHomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  List<DownloadItem> _downloads = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDownloads();
  }

  Future<void> _loadSavedDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_downloads');
    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      setState(() {
        _downloads = decoded.map((item) => DownloadItem.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_downloads.map((e) => e.toJson()).toList());
    await prefs.setString('saved_downloads', encoded);
  }

  Future<void> _startDownload() async {
    final String url = _urlController.text.trim();
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    final newItem = DownloadItem(
      url: url,
      status: 'Triggered Successfully',
      time: DateTime.now().toString().substring(11, 16),
    );

    setState(() {
      _downloads.insert(0, newItem);
      _urlController.clear();
    });

    await _saveDownloads();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚡ Download started & saved in queue!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apex Pro Auto Downloader'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Enter File URL or Link',
                        hintText: 'https://example.com/file.zip',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _startDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('Start Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Persistent Download Queue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                if (_downloads.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: () async {
                      setState(() {
                        _downloads.clear();
                      });
                      await _saveDownloads();
                    },
                  )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _downloads.isEmpty
                  ? const Center(
                      child: Text(
                        'No saved downloads.\nPaste a link above to start.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _downloads.length,
                      itemBuilder: (context, index) {
                        final item = _downloads[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.cloud_download, color: Colors.amber),
                            title: Text(
                              item.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${item.status} • ${item.time}'),
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
