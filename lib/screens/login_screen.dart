import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/discovery_service.dart';
import '../services/auth_service.dart';
import '../models/ha_instance.dart';
import '../l10n/app_localizations.dart';
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
          if (result.startsWith('http')) {
            _tokenUrlController.text = result;
            _credUrlController.text = result;
          } else {
            _tokenController.text = result;
          }
        });

        // Automatically trigger login after scan
        if (_tokenController.text.isNotEmpty &&
            _tokenUrlController.text.isNotEmpty) {
          _loginWithToken();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discoveryService = context.watch<DiscoveryService>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectToHA)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (defaultTargetPlatform != TargetPlatform.linux) ...[
                // Discovery Section
                Text(
                  l10n.discovery,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (discoveryService.isScanning)
                  const LinearProgressIndicator(),
                const SizedBox(height: 10),
                if (discoveryService.instances.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(l10n.searchingForHA),
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
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
              ],

              // Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: l10n.token),
                        Tab(text: l10n.credentials),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildTokenTab(context, l10n),
                          _buildCredentialsTab(context, l10n),
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

  Widget _buildTokenTab(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _tokenFormKey,
      child: Column(
        children: [
          _buildUrlField(_tokenUrlController, l10n),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: l10n.longLivedToken,
                    hintText: l10n.pasteToken,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.vpn_key),
                  ),
                  obscureText: true,
                  maxLines: 1,
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.pleaseEnterToken
                      : null,
                ),
              ),
              if (Platform.isAndroid || Platform.isIOS) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _scanQR,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: l10n.scanQRCode,
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
            label: Text(l10n.connectWithToken),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsTab(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _credentialsFormKey,
      child: Column(
        children: [
          _buildUrlField(_credUrlController, l10n),
          const SizedBox(height: 15),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l10n.username,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) => value == null || value.isEmpty
                ? l10n.pleaseEnterUsername
                : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.password,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) => value == null || value.isEmpty
                ? l10n.pleaseEnterPassword
                : null,
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
            label: Text(l10n.connectWithCredentials),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(
    TextEditingController controller,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.haUrl,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.link),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? l10n.pleaseEnterUrl : null,
    );
  }
}
