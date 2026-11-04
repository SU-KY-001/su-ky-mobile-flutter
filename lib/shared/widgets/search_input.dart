import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

/// Borderless auto-focused field for an app bar title. Owns only the text
/// controller; search behavior belongs to the ViewModel.
class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
  });
  final String value, hint;
  final ValueChanged<String> onChanged;
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
    autofocus: true,
    onChanged: widget.onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: widget.hint,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      filled: false,
      suffixIcon: widget.value.isEmpty
          ? null
          : IconButton(
              onPressed: () => widget.onChanged(''),
              tooltip: AppLocalizations.of(context).clearSearch,
              icon: const Icon(Icons.close),
            ),
    ),
  );
}
