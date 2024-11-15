import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  bool myBool = false;
  String myString = '';
  int myInt = 0;
  List<String> myStringList = [];
  List<int> myIntList = [];

  final TextEditingController stringController = TextEditingController();
  final TextEditingController intController = TextEditingController();
  final TextEditingController stringListController = TextEditingController();
  final TextEditingController intListController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final bool? savedBool = await prefs.getBool('boolean');
    final String? savedString = await prefs.getString('string');
    final int? savedInt = await prefs.getInt('integer');
    final List<String>? savedStringList =
        await prefs.getStringList('stringList');
    final List<int>? savedIntList =
        (await prefs.getStringList('intList'))?.map(int.parse).toList();

    setState(() {
      myBool = savedBool ?? false;
      myString = savedString ?? '';
      myInt = savedInt ?? 0;
      myStringList = savedStringList ?? [];
      myIntList = savedIntList ?? [];
    });
  }

  Future<void> toggleBoolean() async {
    myBool = !myBool;
    await prefs.setBool('boolean', myBool);
    setState(() {});
  }

  Future<void> saveString() async {
    myString = stringController.text;
    await prefs.setString('string', myString);
    setState(() {});
  }

  Future<void> saveInteger() async {
    myInt = int.tryParse(intController.text) ?? 0;
    await prefs.setInt('integer', myInt);
    setState(() {});
  }

  Future<void> addToStringList() async {
    final value = stringListController.text;
    if (value.isNotEmpty) {
      myStringList.add(value);
      await prefs.setStringList('stringList', myStringList);
      setState(() {});
    }
  }

  Future<void> addToIntList() async {
    final value = int.tryParse(intListController.text);
    if (value != null) {
      myIntList.add(value);
      await prefs.setStringList(
          'intList', myIntList.map((e) => e.toString()).toList());
      setState(() {});
    }
  }

  Future<void> clearPreferences() async {
    await prefs.clear();
    setState(() {
      myBool = false;
      myString = '';
      myInt = 0;
      myStringList = [];
      myIntList = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 4,
          title: const Text('Preferences Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: clearPreferences,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BooleanSwitch(
                      label: 'Boolean Value',
                      currentValue: myBool,
                      onToggle: toggleBoolean,
                    ),
                    const SizedBox(height: 24),
                    ValueInputField(
                      controller: stringController,
                      label: 'Enter String Value',
                      savedValue: myString,
                      onSave: saveString,
                    ),
                    const SizedBox(height: 24),
                    ValueInputField(
                      controller: intController,
                      label: 'Enter Integer Value',
                      savedValue: myInt.toString(),
                      onSave: saveInteger,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 24),
                    ListInputField(
                      title: 'String List',
                      controller: stringListController,
                      listItems: myStringList,
                      onAdd: addToStringList,
                    ),
                    const SizedBox(height: 24),
                    ListInputField(
                      title: 'Integer List',
                      controller: intListController,
                      listItems: myIntList.map((e) => e.toString()).toList(),
                      onAdd: addToIntList,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ClearButton(
                    onPressed: clearPreferences,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stringController.dispose();
    intController.dispose();
    stringListController.dispose();
    intListController.dispose();
    super.dispose();
  }
}

class BooleanSwitch extends StatelessWidget {
  final String label;
  final bool currentValue;
  final VoidCallback onToggle;

  const BooleanSwitch({
    super.key,
    required this.label,
    required this.currentValue,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      subtitle: Text('Current value: $currentValue'),
      value: currentValue,
      onChanged: (value) => onToggle(),
    );
  }
}

class ValueInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String savedValue;
  final VoidCallback onSave;
  final bool isNumeric;

  const ValueInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.savedValue,
    required this.onSave,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SaveButton(onPressed: onSave),
            Text(
              'Saved: $savedValue',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class ListInputField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final List<String> listItems;
  final VoidCallback onAdd;
  final bool isNumeric;

  const ListInputField({
    super.key,
    required this.title,
    required this.controller,
    required this.listItems,
    required this.onAdd,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    isNumeric ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Add to $title',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AddButton(onPressed: onAdd),
          ],
        ),
        const SizedBox(height: 8),
        if (listItems.isEmpty)
          const Text('No items added', style: TextStyle(color: Colors.grey)),
        if (listItems.isNotEmpty)
          Wrap(
            children: listItems
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(item),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Save', style: TextStyle(color: Colors.white)),
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class ClearButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Clear All Preferences',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
