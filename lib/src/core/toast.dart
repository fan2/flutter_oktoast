library oktoast;

import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'position.dart';
import 'toast_manager.dart';

part 'toast_future.dart';

part '../widget/theme.dart';

part '../widget/oktoast.dart';

part '../widget/container.dart';

LinkedHashMap<_OKToastState, BuildContext> _contextMap = LinkedHashMap();
const _defaultDuration = Duration(
  milliseconds: 2300,
);

/// show toast with [msg],
ToastFuture showToast(
  String msg, {
  BuildContext context,
  Duration duration = _defaultDuration,
  ToastPosition position,
  TextStyle textStyle,
  EdgeInsetsGeometry textPadding,
  Color backgroundColor,
  double radius,
  VoidCallback onDismiss,
  TextDirection textDirection,
  bool dismissOtherToast,
  TextAlign textAlign,
  OKToastAnimationBuilder animationBuilder,
  Duration animationDuration,
  Curve animationCurve,
}) {
  context ??= _contextMap.values.first;

  textStyle ??= _ToastTheme.of(context).textStyle ?? TextStyle(fontSize: 15.0);

  textAlign ??= _ToastTheme.of(context).textAlign;

  textPadding ??= _ToastTheme.of(context).textPadding;

  position ??= _ToastTheme.of(context).position;
  backgroundColor ??= _ToastTheme.of(context).backgroundColor;
  radius ??= _ToastTheme.of(context).radius;

  textDirection ??= _ToastTheme.of(context).textDirection ?? TextDirection.ltr;

  Widget widget = Container(
    margin: const EdgeInsets.all(50.0),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
    ),
    padding: textPadding,
    child: ClipRect(
      child: Text(
        msg,
        style: textStyle,
        textAlign: textAlign,
      ),
    ),
  );

  return showToastWidget(
    widget,
    animationBuilder: animationBuilder,
    context: context,
    duration: duration,
    onDismiss: onDismiss,
    position: position,
    dismissOtherToast: dismissOtherToast,
    textDirection: textDirection,
    animationCurve: animationCurve,
  );
}

/// show [widget] with oktoast
ToastFuture showToastWidget(
  Widget widget, {
  BuildContext context,
  Duration duration = _defaultDuration,
  ToastPosition position,
  VoidCallback onDismiss,
  bool dismissOtherToast,
  TextDirection textDirection,
  bool handleTouch,
  OKToastAnimationBuilder animationBuilder,
  Duration animationDuration,
  Curve animationCurve,
}) {
  context ??= _contextMap.values.first;
  OverlayEntry entry;
  ToastFuture future;
  final theme = _ToastTheme.of(context);

  position ??= theme.position;
  handleTouch ??= theme.handleTouch;
  animationBuilder ??= theme.animationBuilder;
  animationDuration ??=
      theme.animationDuration ?? const Duration(milliseconds: 250);
  animationCurve ??= theme.animationCurve ?? Curves.easeIn;

  final movingOnWindowChange = theme?.movingOnWindowChange ?? false;

  final direction = textDirection ?? theme.textDirection ?? TextDirection.ltr;

  GlobalKey<__ToastContainerState> key = GlobalKey();

  widget = Align(
    child: widget,
    alignment: position.align,
  );

  entry = OverlayEntry(builder: (ctx) {
    return IgnorePointer(
      ignoring: !handleTouch,
      child: Directionality(
        textDirection: direction,
        child: _ToastContainer(
          duration: duration,
          position: position,
          movingOnWindowChange: movingOnWindowChange,
          key: key,
          child: widget,
          animationBuilder: animationBuilder,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
        ),
      ),
    );
  });

  dismissOtherToast ??= theme.dismissOtherOnShow ?? false;

  if (dismissOtherToast == true) {
    ToastManager().dismissAll();
  }

  future = ToastFuture._(entry, onDismiss, key, animationDuration);

  Future.delayed(duration, () {
    future.dismiss();
  });

  Overlay.of(context).insert(entry);
  ToastManager().addFuture(future);

  return future;
}

/// use the method to dismiss all toast.
void dismissAllToast({bool showAnim = false}) {
  ToastManager().dismissAll(showAnim: showAnim);
}
