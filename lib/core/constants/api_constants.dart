// core/constants/api_constants.dart
// 📁 JAMOCHI_APP/lib/core/constants/api_constants.dart

class ApiConstants {
  // ── Môi trường ──────────────────────────────────────────────────────────────
  static const bool isProduction = false;

  static const String _devBase  = "http://192.168.0.104:5000/api"; // ← IP của bạn
  static const String _prodBase = "https://your-api.com/api";
  static String get baseUrl => isProduction ? _prodBase : _devBase;

  static const String _devSocket  = "http://192.168.0.104:5000";
  static const String _prodSocket = "wss://your-api.com";
  static String get socketUrl => isProduction ? _prodSocket : _devSocket;

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login          = "/auth/login";
  static const String register       = "/auth/register";
  static const String me             = "/auth/me";
  static const String generateInvite = "/auth/invite/generate";
  static const String acceptInvite   = "/auth/invite/accept";
  static const String updateFcmToken = "/auth/fcm-token";

  // ── Mood / Dự Báo ─────────────────────────────────────────────────────────
  // 🛡️ FIX: tách rõ GET today vs POST forecast để không nhầm lẫn
  static const String moodToday    = "/mood/forecast/today";   // GET
  static const String moodForecast = "/mood/forecast";         // POST
  static const String moodHistory  = "/mood/forecast/history"; // GET
  static const String moodThemes   = "/mood/theme-palettes";   // GET

  // ── Messages ──────────────────────────────────────────────────────────────
  static const String messages = "/messages";
  static String messageReact(String id)  => "/messages/$id/react";
  static String messageDelete(String id) => "/messages/$id";

  // ── Locket ────────────────────────────────────────────────────────────────
  static const String locketSend     = "/locket";
  static const String locketUnviewed = "/locket/unviewed";
  static String locketView(String id)  => "/locket/$id/view";
  static const String locketVault    = "/locket/vault";

  // ── Vault ─────────────────────────────────────────────────────────────────
  static const String vaultProfile  = "/vault/profile";
  static const String vaultMeasure  = "/vault/measurements";
  static const String vaultPartner  = "/vault/partner";
  static const String cycleStart    = "/vault/cycle/start";
  static String cycleEnd(String id)   => "/vault/cycle/$id/end";
  static const String cycleHistory   = "/vault/cycle/history";
  static const String cyclePrediction = "/vault/cycle/prediction";
  static const String specialDates   = "/vault/dates";
  static String specialDate(String id) => "/vault/dates/$id";

  // ── Achievement ───────────────────────────────────────────────────────────
  static const String rating        = "/achievements/rating";
  static const String ratingHistory = "/achievements/rating/history";
  static const String achieveSummary = "/achievements/summary";
  static String badgeSeen(String id)  => "/achievements/badges/$id/seen";

  // ── Bro AI ────────────────────────────────────────────────────────────────
  static const String aiSessions = "/ai";
  static String aiChat(String sid)    => "/ai/$sid/chat";
  static String aiSession(String sid) => "/ai/$sid";
}