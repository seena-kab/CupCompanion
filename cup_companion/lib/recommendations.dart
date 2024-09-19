import 'dart:math';

// Function to calculate cosine similarity between two vectors
double cosineSimilarity(List<int> vec1, List<int> vec2) {
  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;

  for (int i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    normA += pow(vec1[i], 2);
    normB += pow(vec2[i], 2);
  }

  if (normA == 0.0 || normB == 0.0) {
    return 0.0;
  }

  return dotProduct / (sqrt(normA) * sqrt(normB));
}

// Function to recommend products based on user preferences
List<int> recommendProducts(List<int> userPref) {
  // Product matrix (Example)
  List<List<int>> productMatrix = [
    [1, 0, 0, 0, 0],  // Product A (Latte Maker)
    [0, 1, 0, 0, 0],  // Product B (Espresso Machine)
    [0, 0, 1, 0, 0],  // Product C (Black Coffee Set)
    [0, 0, 0, 1, 0],  // Product D (Cappuccino Set)
    [0, 1, 0, 1, 0],  // Product E (Espresso & Cappuccino Maker)
  ];

  // List to store similarity scores for each product
  List<double> similarityScores = [];

  // Calculate cosine similarity between user preferences and each product
  for (var product in productMatrix) {
    similarityScores.add(cosineSimilarity(userPref, product));
  }

  // Sort product indices based on similarity scores in descending order
  List<int> sortedIndices = List.generate(productMatrix.length, (i) => i);
  sortedIndices.sort((a, b) => similarityScores[b].compareTo(similarityScores[a]));

  // Return top 3 recommended products
  return sortedIndices.sublist(0, 3);
}
