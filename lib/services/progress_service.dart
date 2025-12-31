import 'package:shared_preferences/shared_preferences.dart';

class QuestionProgressService {
  // Lưu đáp án + đánh dấu câu đã làm
  static Future<void> saveAnswer(String loaiBangLaiId, String chuDeId, String cauHoiId, String answer) async {
    final prefs = await SharedPreferences. getInstance();

    // Lưu đáp án
    final answerKey = 'answer_${loaiBangLaiId}_${chuDeId}_$cauHoiId';
    await prefs.setString(answerKey, answer);

    // Cập nhật danh sách câu đã hoàn thành
    final completedKey = 'completed_${loaiBangLaiId}_$chuDeId';
    Set<String> completed = await getCompletedQuestions(loaiBangLaiId, chuDeId);
    completed.add(cauHoiId);
    await prefs.setStringList(completedKey, completed.toList());
  }

  // Lấy đáp án đã chọn
  static Future<String?> getAnswer(String loaiBangLaiId, String chuDeId, String cauHoiId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'answer_${loaiBangLaiId}_${chuDeId}_$cauHoiId';
    return prefs.getString(key);
  }

  // Lấy danh sách ID câu hỏi đã làm
  static Future<Set<String>> getCompletedQuestions(String loaiBangLaiId, String chuDeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_${loaiBangLaiId}_$chuDeId';
    final List<String> completed = prefs.getStringList(key) ?? [];
    return completed.toSet();
  }

  // Xóa toàn bộ tiến độ của 1 chủ đề
  static Future<void> resetProgress(String loaiBangLaiId, String chuDeId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedKey = 'completed_${loaiBangLaiId}_$chuDeId';

    Set<String> completed = await getCompletedQuestions(loaiBangLaiId, chuDeId);

    // Xóa từng đáp án
    for (String cauHoiId in completed) {
      final answerKey = 'answer_${loaiBangLaiId}_${chuDeId}_$cauHoiId';
      await prefs.remove(answerKey);
    }

    // Xóa danh sách đã hoàn thành
    await prefs.remove(completedKey);
  }
  static Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Lọc ra các key liên quan đến tiến độ câu hỏi
    for (String key in keys) {
      if (key.startsWith('answer_') || key.startsWith('completed_')) {
        await prefs.remove(key);
      }
    }
  }
}