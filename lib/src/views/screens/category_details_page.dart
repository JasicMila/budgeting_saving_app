import 'package:budgeting_saving_app/src/models/category.dart' as category_model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/category_service.dart';



class CategoryDetailsPage extends StatefulWidget {
  final category_model.Category? category;
  final bool isNew;

  const CategoryDetailsPage({super.key, this.category, required this.isNew});

  @override
  CategoryDetailsPageState createState() => CategoryDetailsPageState();
}

class CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? 'expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final categoryService = Provider.of<CategoryService>(context, listen: false);
      category_model.Category newCategory = category_model.Category(
        id: widget.category?.id ?? '',
        userId: FirebaseAuth.instance.currentUser!.uid,
        name: _nameController.text,
        type: _selectedType ?? 'expense',
        iconPath: widget.category?.iconPath ?? '',
      );

      if (widget.isNew) {
        categoryService.addCategory(newCategory);
      } else {
        categoryService.updateCategory(newCategory);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                items: <String>['income', 'expense'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
