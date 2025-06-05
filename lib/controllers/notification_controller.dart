import 'package:get/get.dart';
import 'package:kipost/models/notification.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final RxList<AppNotification> _notifications = <AppNotification>[].obs;
  final RxInt _unreadCount = 0.obs;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;

  @override
  void onInit() {
    super.onInit();
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    final now = DateTime.now();
    _notifications.assignAll([
      AppNotification(
        id: '1',
        title: 'Nouvelle proposition reçue',
        message: 'Jean Dupont a soumis une proposition pour votre projet de développement web.',
        createdAt: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.proposal,
        isRead: false,
        relatedId: 'prop1',
      ),
      AppNotification(
        id: '2',
        title: 'Annonce publiée avec succès',
        message: 'Votre annonce "Développement application mobile" a été publiée et est maintenant visible.',
        createdAt: now.subtract(const Duration(hours: 2)),
        type: NotificationType.announcement,
        isRead: false,
        relatedId: 'ann1',
      ),
      AppNotification(
        id: '3',
        title: 'Rappel de rendez-vous',
        message: 'Vous avez un entretien prévu demain à 14h avec Marie Martin.',
        createdAt: now.subtract(const Duration(hours: 5)),
        type: NotificationType.reminder,
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Nouveau message',
        message: 'Sophie Blanc vous a envoyé un message concernant le projet e-commerce.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.message,
        isRead: true,
        relatedId: 'msg1',
      ),
      AppNotification(
        id: '5',
        title: 'Proposition acceptée',
        message: 'Félicitations ! Votre proposition pour le projet de refonte a été acceptée.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.proposal,
        isRead: true,
        relatedId: 'prop2',
      ),
      AppNotification(
        id: '6',
        title: 'Mise à jour du système',
        message: 'Une nouvelle version de Kipost est disponible avec des améliorations.',
        createdAt: now.subtract(const Duration(days: 3)),
        type: NotificationType.system,
        isRead: true,
      ),
    ]);
    _updateUnreadCount();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    _notifications.value = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _updateUnreadCount();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
  }
}
