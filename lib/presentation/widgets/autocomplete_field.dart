import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AutocompleteField extends StatefulWidget {
  final String labelText;
  final IconData? prefixIcon;
  final List<String> suggestions;
  final Function(String) onItemAdded;
  final String? hintText;
  final String? helperText;

  const AutocompleteField({
    super.key,
    required this.labelText,
    this.prefixIcon,
    required this.suggestions,
    required this.onItemAdded,
    this.hintText,
    this.helperText,
  });

  @override
  State<AutocompleteField> createState() => _AutocompleteFieldState();
}

class _AutocompleteFieldState extends State<AutocompleteField> {
  TextEditingController? _fieldController;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        final filteredOptions = widget.suggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        }).toList();

        // Ordenar: coincidencias exactas primero, luego alfabéticamente
        filteredOptions.sort((a, b) {
          final aLower = a.toLowerCase();
          final bLower = b.toLowerCase();
          final queryLower = textEditingValue.text.toLowerCase();

          // Si uno empieza con la query y el otro no
          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          } else if (!aLower.startsWith(queryLower) && bLower.startsWith(queryLower)) {
            return 1;
          }

          // Si ambos empiezan con la query o ninguno, ordenar alfabéticamente
          return a.compareTo(b);
        });

        return filteredOptions.take(10); // Limitar a 10 sugerencias
      },
      onSelected: (String selection) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          widget.onItemAdded(selection);
          if (_fieldController != null) {
            _fieldController!.clear();
          }
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        _fieldController = controller;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final text = controller.text.trim();
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    widget.onItemAdded(text);
                  });
                  controller.clear();
                  focusNode.unfocus();
                }
              },
              tooltip: 'Agregar',
            ),
            border: const OutlineInputBorder(),
            hintText: widget.hintText,
            helperText: widget.helperText,
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              final text = value.trim();
              SchedulerBinding.instance.addPostFrameCallback((_) {
                widget.onItemAdded(text);
              });
              controller.clear();
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 300,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    leading: Icon(
                      Icons.history,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

}