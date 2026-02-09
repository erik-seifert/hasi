import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/discovery_service.dart';
import '../services/auth_service.dart';
import '../models/ha_instance.dart';
import 'qr_scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenFormKey = GlobalKey<FormState>();
  final _credentialsFormKey = GlobalKey<FormState>();
  final _tokenUrlController = TextEditingController(
    text: 'http://homeassistant.local:8123',
  );
  final _credUrlController = TextEditingController(
    text: 'http://homeassistant.local:8123',
  );
  final _tokenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start discovery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discoveryService = context.read<DiscoveryService>();
      discoveryService.startScan();
    });
  }

  @override
  void dispose() {
    _tokenUrlController.dispose();
    _credUrlController.dispose();
    _tokenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithToken() async {
    if (_tokenFormKey.currentState!.validate()) {
      _stopDiscovery();
      setState(() => _isLoading = true);
      final success = await context.read<AuthService>().login(
        _tokenUrlController.text,
        _tokenController.text,
      );
      _handleLoginResult(success);
    }
  }

  Future<void> _loginWithCredentials() async {
    if (_credentialsFormKey.currentState!.validate()) {
      _stopDiscovery();
      setState(() => _isLoading = true);
      final success = await context.read<AuthService>().loginWithCredentials(
        _credUrlController.text,
        _usernameController.text,
        _passwordController.text,
      );
      _handleLoginResult(success);
    }
  }

  void _stopDiscovery() {
    context.read<DiscoveryService>().stopScan();
  }

  void _handleLoginResult(bool success) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      final error = context.read<AuthService>().error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
      context.read<DiscoveryService>().startScan();
    }
  }

  void _onInstanceSelected(HAInstance instance) {
    setState(() {
      _tokenUrlController.text = instance.url;
      _credUrlController.text = instance.url;
    });
  }

  Future<void> _scanQR() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );

      if (result != null && result is String) {
        setState(() {
          // If it's a URL-like structure, set URL, else set token
          // Simple heuristic: if it contains "http", assume it's URL or JSON with URL
          // But user said "scan QR for long life token". This implies just the token string potentially.
          if (result.startsWith('http')) {
            _tokenUrlController.text = result;
            _credUrlController.text = result;
          } else {
            _tokenController.text = result;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discoveryService = context.watch<DiscoveryService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Home Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Discovery Section
              Text('Discovery', style: Theme.of(context).textTheme.titleLarge),
              if (discoveryService.isScanning) const LinearProgressIndicator(),
              const SizedBox(height: 10),
              if (discoveryService.instances.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Searching for Home Assistant instances...'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: discoveryService.instances.length,
                  itemBuilder: (context, index) {
                    final instance = discoveryService.instances[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(instance.name),
                        subtitle: Text(instance.url),
                        onTap: () => _onInstanceSelected(instance),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Token'),
                        Tab(text: 'Credentials'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      // Using a constrained height or letting it grow?
                      // TabBarView requires bounded height.
                      // Since we are in SingleChildScrollView, we can't just use Expanded.
                      // We'll wrap TabBarView in a SizedBox with a reasonable height or use a custom solution.
                      // Alternatively, avoid TabBarView and use a state variable to switch content.
                      // Switching content is safer inside SingleChildScrollView.
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildTokenTab(context),
                          _buildCredentialsTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenTab(BuildContext context) {
    return Form(
      key: _tokenFormKey,
      child: Column(
        children: [
          _buildUrlField(_tokenUrlController),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Long-Lived Access Token',
                    hintText: 'Paste token',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                  obscureText: true,
                  maxLines: 1,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter token'
                      : null,
                ),
              ),
              if (Platform.isAndroid || Platform.isIOS) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _scanQR,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan QR Code',
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _loginWithToken,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: const Text('Connect with Token'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsTab(BuildContext context) {
    return Form(
      key: _credentialsFormKey,
      child: Column(
        children: [
          _buildUrlField(_credUrlController),
          const SizedBox(height: 15),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter username' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter password' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _loginWithCredentials,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: const Text('Connect with Credentials'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Home Assistant URL',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter URL' : null,
    );
  }
}
