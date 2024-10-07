// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;
  final String language;

  const CodeWrapperWidget(this.child, this.text, this.language, {super.key});

  @override
  State<CodeWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<CodeWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget =
        Icon(Icons.copy_rounded, key: UniqueKey(), color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty)
                  SelectionContainer.disabled(
                    child: Container(
                      child: Text(widget.language),
                      margin: EdgeInsets.only(right: 2),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 0.5, color: Colors.white),
                      ),
                    ),
                  ),
                InkWell(
                  child: AnimatedSwitcher(
                    child: _switchWidget,
                    duration: Duration(milliseconds: 200),
                  ),
                  onTap: () async {
                    if (hasCopied) return;
                    await Clipboard.setData(ClipboardData(text: widget.text));
                    _switchWidget = Icon(Icons.check,
                        key: UniqueKey(), color: Colors.white);
                    refresh();
                    Future.delayed(Duration(seconds: 2), () {
                      hasCopied = false;
                      _switchWidget = Icon(Icons.copy_rounded,
                          key: UniqueKey(), color: Colors.white);
                      refresh();
                    });
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
