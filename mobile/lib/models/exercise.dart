class Exercise {
  final String id;
  final String name;
  final String target;
  final String equipment;
  final String image;

  const Exercise({
    required this.id,
    required this.name,
    required this.target,
    required this.equipment,
    required this.image,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      target: json['target'] as String,
      equipment: json['equipment'] as String,
      image: json['image'] as String? ?? '',
    );
  }
}
