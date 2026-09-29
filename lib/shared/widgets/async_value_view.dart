import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_state.dart';
import 'app_loading.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.empty,
    this.onRetry,
    this.errorBuilder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const AppLoading(),
      error: (err, st) {
        if (errorBuilder != null) return errorBuilder!(err, st);
        final errStr = err.toString();
        if (errStr.contains('permission-denied')) {
          return AppErrorState(
            icon: Icons.lock_outline_rounded,
            title: 'Firestore Rules Update Required',
            message:
                'Your Firebase security rules do not permit access to this collection yet.\n\n'
                'Please publish the updated "firestore.rules" file to your Firebase Console, then tap Try Again.',
            onRetry: onRetry,
          );
        }
        return AppErrorState(onRetry: onRetry);
      },
      data: (d) {
        if (empty != null && (isEmpty?.call(d) ?? false)) return empty!;
        return data(d);
      },
    );
  }
}
