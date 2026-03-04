// Conditional export: uses native (dart:io) on desktop, stub on web.
export 'server_manager_stub.dart'
    if (dart.library.io) 'server_manager_native.dart';
