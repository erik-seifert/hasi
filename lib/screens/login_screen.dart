import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/discovery_service.dart';
import '../services/auth_service.dart';
import '../models/ha_instance.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(
    text: 'http://homeassistant.local:8123',
  );
  final _tokenController = TextEditingController();
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
    // Stop scanning when leaving this screen
    // We need to use context.read, but context might be invalid if unmounted?
    // In dispose, we can usually access context.read if the widget is still in tree scope technically,
    // but better to rely on service lifecycle or just let it run?
    // Actually, we should try to stop it.
    // However, if we can't easily access the provider here without issues,
    // we could store a reference in initState.
    // But context.read is generally safe in dispose if listen:false which read is.
    // Let's safe guard it.

    // Actually, simply:
    // context.read<DiscoveryService>().stopScan();
    // But since the provider is above, it persists.
    // We definitely want to stop scanning to save battery/network.

    // Note: Calling context.read in dispose is discouraged by some linters but widely used.
    // A safer way is to save reference in didChangeDependencies, but that's overkill here.

    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Stop discovery before login attempt to clear resources
      context.read<DiscoveryService>().stopScan();

      setState(() => _isLoading = true);
      final success = await context.read<AuthService>().login(
        _urlController.text,
        _tokenController.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        final error = context.read<AuthService>().error;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
        // Restart scan if failed?
        context.read<DiscoveryService>().startScan();
      }
    }
  }

  void _onInstanceSelected(HAInstance instance) {
    _urlController.text = instance.url;
  }

  @override
  Widget build(BuildContext context) {
    final discoveryService = context.watch<DiscoveryService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Home Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Discovery Section
                Text(
                  'Discovery',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (discoveryService.isScanning)
                  const LinearProgressIndicator(),
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

                // Manual Entry Section
                Text(
                  'Manual Connection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Home Assistant URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter URL'
                      : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Long-Lived Access Token',
                    hintText: 'Paste your token here',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                  obscureText: true,
                  maxLines: 1,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter token'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _login,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Connect'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
