import 'package:flutter/material.dart';

/// Owns only the text field controller; search behavior belongs to the ViewModel.
class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.onVoice,
  });
  final String value, hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onVoice;
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  @override
  void didUpdateWidget(SearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: const Icon(Icons.search, size: 20),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.value.isNotEmpty)
            IconButton(
              onPressed: () => widget.onChanged(''),
              icon: const Icon(Icons.close, size: 18),
            ),
          IconButton(
            onPressed: widget.onVoice,
            icon: Icon(
              Icons.mic_none,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
