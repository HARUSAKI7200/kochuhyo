class KouchuhyoTemplate {
  final String name;
  final Map<String, dynamic> values;

  KouchuhyoTemplate({required this.name, required this.values});

  Map<String, dynamic> toJson() => {
        'name': name,
        'values': values,
      };

  factory KouchuhyoTemplate.fromJson(Map<String, dynamic> json) =>
      KouchuhyoTemplate(
        name: json['name'],
        values: Map<String, dynamic>.from(json['values']),
      );
}
