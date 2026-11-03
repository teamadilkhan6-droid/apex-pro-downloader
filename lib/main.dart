import 'package:flutter/material.dart';

void main() {
  runApp(const ApexProApp());
}

class ApexProApp extends StatelessWidget {
  const ApexProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Pro Auto Downloader',
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

class DownloadHomeScreen extends StatefulWidget {
  const DownloadHomeScreen({Key? key}) : super(key: key);

  @override
  State<DownloadHomeScreen> createState() => _DownloadHomeScreenState();
}

class _DownloadHomeScreenState extends State<DownloadHomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final List> _downloads = [];

  void _addDownload() {
    final String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _downloads.insert(0, {
          'url': url,
          'status': 'Queued / Monitoring...',
          'time': DateTime.now().toString().substring(11, 16),
        });
        _urlController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚡ Download task added to queue!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apex Pro Downloader'),
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
                        labelText: 'Enter File URL or Keyword',
                        hintText: 'https://example.com/file.zip',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('Start Auto Download'),
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
            const Text(
              'Active / Monitored Queue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _downloads.isEmpty
                  ? const Center(
                      child: Text(
                        'No active downloads.\nPaste a link above to begin.',
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
                              item['url']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${item['status']} • ${item['time']}'),
                            trailing: const Icon(Icons.hourglass_top, color: Colors.orange),
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
