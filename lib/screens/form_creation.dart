import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormCreationScreen extends StatefulWidget {
  const FormCreationScreen({super.key});

  @override
  State<FormCreationScreen> createState() => _FormCreationScreenState();
}

class _FormCreationScreenState extends State<FormCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<FormComponent> _components = [];
  final Uuid uuid = const Uuid();

  void _addComponent(String type) {
    setState(() {
      _components.add(FormComponent(
        id: uuid.v4(),
        type: type,
        config: {},
      ));
    });
  }

  void _deleteComponent(String id) {
    setState(() {
      _components.removeWhere((c) => c.id == id);
    });
  }

  bool _isVariableNameDuplicate(String name, String currentId) {
    for (var comp in _components) {
      if (comp.id == currentId) continue;
      if (comp.config.containsKey('variables')) {
        for (var v in comp.config['variables']) {
          if (v['name'] == name) return true;
        }
      }
      if (comp.config.containsKey('variable')) {
        if (comp.config['variable']['name'] == name) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Template Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Implement save logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template saved!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Form Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Wrap(
              spacing: 8,
              children: [
                for (var type in ['grid', 'slider', 'checkbox', 'cardSwipe'])
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(type),
                    onPressed: () => _addComponent(type),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _components.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _components.removeAt(oldIndex);
                  _components.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final comp = _components[index];
                return Card(
                  key: ValueKey(comp.id),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${comp.type[0].toUpperCase()}${comp.type.substring(1)} Component',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteComponent(comp.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildComponentFields(comp),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentFields(FormComponent comp) {
    switch (comp.type) {
      case 'grid':
        comp.config['variables'] ??= [
          {'name': '', 'min': '', 'max': ''},
          {'name': '', 'min': '', 'max': ''}
        ];
        return Column(
          children: List.generate(2, (i) {
            final varData = comp.config['variables'][i];
            return _variableInput(comp, varData, i);
          }),
        );

      case 'slider':
        comp.config['variable'] ??= {'name': '', 'min': '', 'max': ''};
        return _variableInput(comp, comp.config['variable'], null);

      case 'checkbox':
      case 'cardSwipe':
        comp.config['questions'] ??= <String>[];
        return _questionList(comp);

      default:
        return const SizedBox();
    }
  }

  Widget _variableInput(FormComponent comp, Map varData, int? index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index != null) Text('Variable ${index + 1}'),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  if (_isVariableNameDuplicate(value, comp.id)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Duplicate variable name!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  setState(() => varData['name'] = value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Min'),
                keyboardType: TextInputType.number,
                onChanged: (value) => varData['min'] = value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Max'),
                keyboardType: TextInputType.number,
                onChanged: (value) => varData['max'] = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _questionList(FormComponent comp) {
    final questions = comp.config['questions'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < questions.length; i++)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: questions[i]),
                  decoration: InputDecoration(labelText: 'Question ${i + 1}'),
                  onChanged: (value) => questions[i] = value,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() => questions.removeAt(i));
                },
              ),
            ],
          ),
        TextButton.icon(
          onPressed: () {
            setState(() => questions.add(''));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Question'),
        ),
      ],
    );
  }
}

class FormComponent {
  final String id;
  final String type;
  final Map<String, dynamic> config;

  FormComponent({
    required this.id,
    required this.type,
    required this.config,
  });
}