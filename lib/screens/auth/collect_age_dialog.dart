import 'package:flutter/material.dart';
import 'widget/input_field.dart';

/// A simple dialog that requests the user's age and returns it as an `int`.
/// Returns `null` if the user cancels.
class CollectAgeDialog extends StatefulWidget {
  const CollectAgeDialog({super.key});

  @override
  State<CollectAgeDialog> createState() => _CollectAgeDialogState();
}

class _CollectAgeDialogState extends State<CollectAgeDialog> {
  final TextEditingController _ageController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _ageController.text.trim();
    final val = int.tryParse(text);
    if (val == null || val <= 0) {
      setState(() => _error = 'Please enter a valid age');
      return;
    }
    Navigator.of(context).pop(val);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your age'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField(
            hint: 'Age',
            controller: _ageController,
            keyboardType: TextInputType.number,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _onSave, child: const Text('Save')),
      ],
    );
  }
}
