class HAInstance {
  final String name;
  final String url;
  final String ip;
  final int port;

  HAInstance({
    required this.name,
    required this.url,
    required this.ip,
    required this.port,
  });

  @override
  String toString() {
    return 'HAInstance(name: $name, url: $url)';
  }
}
