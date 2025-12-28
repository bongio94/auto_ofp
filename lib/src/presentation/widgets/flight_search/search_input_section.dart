import 'package:flutter/material.dart';
import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'loading_animation.dart';

class SearchInputSection extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final ValueChanged<String>? onChanged;

  const SearchInputSection({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    this.onChanged,
  });

  @override
  State<SearchInputSection> createState() => _SearchInputSectionState();
}

class _SearchInputSectionState extends State<SearchInputSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "ENTER FLIGHT INFO",
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.controller,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please paste a FlightAware link';
              }
              final urlResult = FlightImporter().parseFlightAwareUrl(
                value.trim(),
              );
              if (urlResult == null) {
                return 'Invalid link. Must be a specific FlightAware history URL\n(e.g .../flight/AAL1/history/20251221/...)';
              }
              return null;
            },
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorMaxLines: 3,
              hintText: "Paste FlightAware Link",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          // Action Button
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSearch();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: theme.colorScheme.surface.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? const LoadingTextAnimation()
                  : const Text(
                      "GENERATE PLAN",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
          if (!widget.isLoading && widget.controller.text.isNotEmpty)
            // Note: The logic for "No candidates found" was in parent.
            // But we don't have access to candidates list here to show "No candidates...".
            // That text should remain in parent or be passed down.
            // I will exclude "No candidates found" text from here.
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
