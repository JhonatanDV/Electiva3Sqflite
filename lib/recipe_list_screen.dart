import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'recipe.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _dbHelper = DatabaseHelper.instance;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
  final recipes = await _dbHelper.getRecipes();
  setState(() {
    _recipes = recipes.map((map) => Recipe.fromMap(map)).toList();
  });
  print('Loaded recipes: $_recipes'); 
}

  Future<void> _addRecipe(String title, String ingredients, String instructions, String category) async {
    final recipe = Recipe(title: title, ingredients: ingredients, instructions: instructions, category: category);
    await _dbHelper.insertRecipe(recipe.toMap());
    _loadRecipes();
  }

  Future<void> _deleteRecipe(int id) async {
    await _dbHelper.deleteRecipe(id);
    _loadRecipes();
  }

  Future<void> _editRecipe(Recipe recipe) async {
  final titleController = TextEditingController(text: recipe.title);
  final ingredientsController = TextEditingController(text: recipe.ingredients);
  final instructionsController = TextEditingController(text: recipe.instructions);
  final categoryController = TextEditingController(text: recipe.category);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Recipe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Recipe Title'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: const InputDecoration(hintText: 'Ingredients'),
            ),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(hintText: 'Instructions'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(hintText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  ingredientsController.text.isNotEmpty &&
                  instructionsController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                final updatedRecipe = Recipe(
                  id: recipe.id,
                  title: titleController.text,
                  ingredients: ingredientsController.text,
                  instructions: instructionsController.text,
                  category: categoryController.text,
                );
                print('Updating recipe: ${updatedRecipe.toMap()}'); 

                await _dbHelper.updateRecipe(updatedRecipe.toMap());
                await _loadRecipes(); 
                Navigator.of(context).pop(); 
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController instructionsController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Recipe Title'),
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(hintText: 'Ingredients (comma separated)'),
                ),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(hintText: 'Instructions'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(hintText: 'Category'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        ingredientsController.text.isNotEmpty &&
                        instructionsController.text.isNotEmpty &&
                        categoryController.text.isNotEmpty) {
                      _addRecipe(
                        titleController.text,
                        ingredientsController.text,
                        instructionsController.text,
                        categoryController.text,
                      );
                      titleController.clear();
                      ingredientsController.clear();
                      instructionsController.clear();
                      categoryController.clear();
                    }
                  },
                  child: const Text('Add Recipe'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return ListTile(
                  title: Text(recipe.title),
                  subtitle: Text('${recipe.category}\n${recipe.ingredients}\n${recipe.instructions}'), 
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editRecipe(recipe);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteRecipe(recipe.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
