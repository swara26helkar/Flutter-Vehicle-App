import 'dart:math';

class DummyValueGenerator {
  String getRandomSubject() {
    List<String> subjects = [
      "Mathematics",
      "Physics",
      "Chemistry",
      "Biology",
      "History",
      "Geography",
      "English",
      "Computer Science",
      "Economics",
      "Art",
      "Music",
      "Physical Education",
      "Java",
      "C++",
      "Python",
      "DSA",
      "Web Tech",
      "Blockchain",
      "AI/ML",
    ];

    Random random = Random();
    return subjects[random.nextInt(subjects.length)];
  }
}
