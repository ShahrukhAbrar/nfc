import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _nfcTagData = 'No NFC tag detected.';
  String _hceStatus = 'Inactive';
  bool _nfcAvail = true;
  bool _running = false;
  final _flutterNfcHcePlugin = FlutterNfcHce();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startNFCReading,
              child: const Text('Start NFC Reading'),
            ),
            const SizedBox(height: 20),
            Text(_nfcTagData),
            ElevatedButton(
              onPressed: _startHCEMode,
              child: const Text('HCE Mode'),
            ),
            const SizedBox(height: 20),
            Text(_hceStatus),
          ],
        ),
      ),
    );
  }

  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Update the UI with the detected tag data.
            setState(() {
              _nfcTagData = 'NFC Tag Detected: ${tag.toString()}';
            });
          },
        );
      } else {
        setState(() {
          _nfcTagData = 'NFC not available.';
          _nfcAvail = false;
        });
      }
    } catch (e) {
      setState(() {
        _nfcTagData = 'Error reading NFC: $e';
      });
    }
  }

  void _startHCEMode() async {
    var content = 'If you can read this, It Works!';
    var result;

    if (!_nfcAvail) {
      return;
    }
    if (!_running) {
      try {
        result = await _flutterNfcHcePlugin.startNfcHce(content);
      } catch (e) {
        setState(() {
          _hceStatus = 'Error!';
        });
      }
      setState(() {
        _hceStatus = 'Running';
        _running = true;
      });
    } else {
      await _flutterNfcHcePlugin.stopNfcHce();
      setState(() {
        _hceStatus = 'Inactive!';
        _running = false;
      });
    }
  }
}
