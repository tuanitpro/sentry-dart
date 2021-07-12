import 'package:meta/meta.dart';

/// Describes a runtime in more detail.
///
/// Typically this context is used multiple times if multiple runtimes
/// are involved (for instance if you have a JavaScript application running
/// on top of JVM).
@immutable
class SentryRuntime {
  static const listType = 'runtimes';
  static const type = 'runtime';

  const SentryRuntime({
    this.key,
    this.name,
    this.version,
    this.compiler,
    this.rawDescription,
  }) : assert(key == null || key.length >= 1);

  /// Key used in the JSON and which will be displayed
  /// in the Sentry UI. Defaults to lower case version of [name].
  ///
  /// Unused if only one [SentryRuntime] is provided in [Contexts].
  final String? key;

  /// The name of the runtime.
  final String? name;

  /// The version identifier of the runtime.
  final String? version;

  /// Dart has a couple different compilers.
  /// E.g: dart2js, dartdevc, AOT, VM
  final String? compiler;

  /// An unprocessed description string obtained by the runtime.
  ///
  /// For some well-known runtimes, Sentry will attempt to parse name
  /// and version from this string, if they are not explicitly given.
  final String? rawDescription;

  /// Deserializes a [SentryRuntime] from JSON [Map].
  // ignore: strict_raw_type
  factory SentryRuntime.fromJson(Map data) => SentryRuntime(
        // This class should be deserializable from Map<String, dynamic> and Map<Object?, Object?>,
        // because it comes from json.decode which is a Map<String, dynamic> and from
        // methodchannels which is a Map<Object?, Object?>.
        // Map<String, dynamic> and Map<Object?, Object?> only have
        // Map<dynamic, dynamic> as common type constraint
        name: data['name'] as String?,
        version: data['version'] as String?,
        compiler: data['compiler'] as String?,
        rawDescription: data['raw_description'] as String?,
      );

  /// Produces a [Map] that can be serialized to JSON.
  Map<String, Object> toJson() {
    return <String, Object>{
      if (name != null) 'name': name!,
      if (compiler != null) 'compiler': compiler!,
      if (version != null) 'version': version!,
      if (rawDescription != null) 'raw_description': rawDescription!,
    };
  }

  SentryRuntime clone() => SentryRuntime(
        key: key,
        name: name,
        version: version,
        compiler: compiler,
        rawDescription: rawDescription,
      );

  SentryRuntime copyWith({
    String? key,
    String? name,
    String? version,
    String? compiler,
    String? rawDescription,
  }) =>
      SentryRuntime(
        key: key ?? this.key,
        name: name ?? this.name,
        version: version ?? this.version,
        compiler: compiler ?? this.compiler,
        rawDescription: rawDescription ?? this.rawDescription,
      );
}
