import 'package:budgeting_saving_app/src/models/category.dart' as category_model;
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
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
        name: _nameController.text,
        type: widget.category?.type ?? 'expense',  // Assuming the type is predefined as 'expense'
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
