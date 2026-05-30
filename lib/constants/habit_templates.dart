class HabitTemplate {
  final String name;
  final String description;
  final String goal;
  final String iconName;

  const HabitTemplate({
    required this.name,
    required this.description,
    required this.goal,
    required this.iconName,
  });
}

class HabitTemplateCategory {
  final String name;
  final String description;
  final List<HabitTemplate> templates;

  const HabitTemplateCategory({
    required this.name,
    required this.description,
    required this.templates,
  });
}

const List<HabitTemplateCategory> habitTemplateCategories = [
  HabitTemplateCategory(
    name: 'Essential Habits',
    description: 'Simple habits that form the foundation of a healthy lifestyle.',
    templates: [
      HabitTemplate(
        name: 'Drink 8 cups of water',
        description: 'Stay hydrated throughout the day',
        goal: 'Stay hydrated and improve energy levels',
        iconName: 'drop',
      ),
      HabitTemplate(
        name: 'Morning walk',
        description: 'Start the day with light movement',
        goal: 'Move your body and clear your mind daily',
        iconName: 'person-simple-walk',
      ),
      HabitTemplate(
        name: 'Sleep 8 hours',
        description: 'Prioritize quality rest every night',
        goal: 'Maintain a consistent sleep schedule',
        iconName: 'moon',
      ),
      HabitTemplate(
        name: 'Read 20 minutes',
        description: 'Expand your knowledge every day',
        goal: 'Build a consistent reading habit',
        iconName: 'book-open',
      ),
      HabitTemplate(
        name: 'Meditate',
        description: 'Find calm and clarity each morning',
        goal: 'Reduce stress and improve focus',
        iconName: 'peace',
      ),
    ],
  ),
  HabitTemplateCategory(
    name: 'Fitness',
    description: 'Build strength, endurance, and an active lifestyle.',
    templates: [
      HabitTemplate(
        name: 'Workout',
        description: 'Train consistently for strength and fitness',
        goal: 'Build strength and improve overall fitness',
        iconName: 'barbell',
      ),
      HabitTemplate(
        name: 'Morning run',
        description: 'Boost energy with a daily run',
        goal: 'Improve cardiovascular health',
        iconName: 'person-simple-run',
      ),
      HabitTemplate(
        name: 'Stretching',
        description: 'Keep your body flexible and injury-free',
        goal: 'Improve flexibility and reduce muscle tension',
        iconName: 'person-simple',
      ),
    ],
  ),
  HabitTemplateCategory(
    name: 'Mindfulness',
    description: 'Cultivate awareness, gratitude, and mental clarity.',
    templates: [
      HabitTemplate(
        name: 'Journal',
        description: 'Reflect on your thoughts and experiences',
        goal: 'Process emotions and track personal growth',
        iconName: 'notebook',
      ),
      HabitTemplate(
        name: 'Gratitude practice',
        description: 'Write down three things you are grateful for',
        goal: 'Build a positive mindset through daily gratitude',
        iconName: 'heart',
      ),
      HabitTemplate(
        name: 'Breathing exercises',
        description: 'Calm your nervous system anytime',
        goal: 'Reduce anxiety and sharpen focus',
        iconName: 'wind',
      ),
    ],
  ),
  HabitTemplateCategory(
    name: 'Trending',
    description: 'Popular habits people are building right now.',
    templates: [
      HabitTemplate(
        name: 'Cold shower',
        description: 'Build resilience and boost morning energy',
        goal: 'Increase mental toughness and alertness',
        iconName: 'shower',
      ),
      HabitTemplate(
        name: 'No phone after 9 PM',
        description: 'Protect your sleep and evening wind-down',
        goal: 'Improve sleep quality by reducing screen time',
        iconName: 'device-mobile-slash',
      ),
      HabitTemplate(
        name: 'Cook at home',
        description: 'Eat healthier and build kitchen confidence',
        goal: 'Build healthier eating habits and save money',
        iconName: 'cooking-pot',
      ),
    ],
  ),
];
