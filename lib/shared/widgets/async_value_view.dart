import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

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
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const AppLoading(),
      error: (_, __) => AppErrorState(onRetry: onRetry),
      data: (d) {
        if (empty != null && (isEmpty?.call(d) ?? false)) return empty!;
        return data(d);
      },
    );
  }
}
