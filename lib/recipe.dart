class Recipe {
  int? id;
  String title;
  String ingredients;
  String instructions;
  String category;

  Recipe({this.id, required this.title, required this.ingredients, required this.instructions, required this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'category': category,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      ingredients: map['ingredients'],
      instructions: map['instructions'],
      category: map['category'],
    );
  }
}
