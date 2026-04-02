import 'package:flutter/material.dart';

class FadeInText extends StatefulWidget {
  const FadeInText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 20),
    this.onComplete,
  });

  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final VoidCallback? onComplete;

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText> {
  String _displayed = '';
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  @override
  void didUpdateWidget(FadeInText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayed = '';
      _complete = false;
      _animate();
    }
  }

  Future<void> _animate() async {
    for (var i = 0; i < widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.charDelay);
      if (!mounted) return;
      setState(() {
        _displayed = widget.text.substring(0, i + 1);
      });
    }
    _complete = true;
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayed,
      style: widget.style,
    );
  }
}
