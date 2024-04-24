import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/services/category_service.dart';
import 'package:provider/provider.dart';
import 'category_details_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CategoryDetailsPage(category: null, isNew: true)),
            ),
          ),
        ],
      ),
      body: Consumer<CategoryService>(
        builder: (context, categoryService, child) {
          return ListView.builder(
            itemCount: categoryService.categories.length,
            itemBuilder: (context, index) {
              final category = categoryService.categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text(category.type),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CategoryDetailsPage(category: category, isNew: false)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => categoryService.deleteCategory(category.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}