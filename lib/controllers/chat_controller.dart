import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/chat_service.dart';
import '../models/chat_message_model.dart';

class ChatController extends GetxController {
  ChatController(this.groupId);
  final String groupId;

  // UI state
  final messages = <ChatMessage>[].obs;
  final input = TextEditingController();
  final isSending = false.obs;

  // Optional: keep track of what you're editing
  final editingMessageId = RxnString();

  StreamSubscription<List<ChatMessage>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = ChatService.instance
        .messagesStream(groupId, limit: 200)
        .listen(messages.assignAll);
  }

  Future<void> send() async {
    final txt = input.text.trim();
    if (txt.isEmpty) return;

    isSending.value = true;
    try {
      await ChatService.instance.sendTextMessage(groupId: groupId, text: txt);
      input.clear();
    } catch (e) {
      Get.snackbar('Send failed', '$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> startEdit(ChatMessage m) async {
    editingMessageId.value = m.id;
    input.text = m.text;
  }

  Future<void> confirmEdit() async {
    final id = editingMessageId.value;
    final txt = input.text.trim();
    if (id == null || txt.isEmpty) return;
    try {
      await ChatService.instance.editMessage(
        groupId: groupId,
        messageId: id,
        newText: txt,
      );
      editingMessageId.value = null;
      input.clear();
    } catch (e) {
      // Will be permission-denied unless your rules allow author updates
      Get.snackbar('Edit failed', '$e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await ChatService.instance.deleteMessage(
        groupId: groupId,
        messageId: messageId,
      );
    } catch (e) {
      // If hard delete is blocked by rules, try soft delete instead
      try {
        await ChatService.instance.softDeleteMessage(
          groupId: groupId,
          messageId: messageId,
        );
      } catch (e2) {
        Get.snackbar('Delete failed', '$e2', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void onTypingChanged(bool isTyping) {
    ChatService.instance.setTyping(groupId, isTyping);
  }

  @override
  void onClose() {
    _sub?.cancel();
    input.dispose();
    super.onClose();
  }
}
