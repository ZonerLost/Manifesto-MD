const admin = require("firebase-admin");
const { logger } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

function chunk(arr, size) {
  const result = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
}

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

async function fetchUserTokens(userIds) {
  const uniqueIds = [...new Set(userIds.filter(isNonEmptyString))];
  if (!uniqueIds.length) return [];
  const docs = await Promise.all(
    uniqueIds.map((uid) => db.collection("users").doc(uid).get())
  );
  return docs.map((doc) => doc.get("fcmToken")).filter(isNonEmptyString);
}

async function sendMulticast(tokens, message) {
  if (!tokens.length) return;
  const batches = chunk(tokens, 500);
  await Promise.all(
    batches.map(async (batch) => {
      try {
        await messaging.sendEachForMulticast({
          tokens: batch,
          notification: { title: message.title, body: message.body },
          data: message.data,
        });
      } catch (error) {
        logger.error("Failed to send FCM batch", error);
      }
    })
  );
}

async function buildUserName(userId) {
  const snap = await db.collection("users").doc(userId).get();
  if (!snap.exists) return "New Member";
  const data = snap.data() || {};
  return data.name || data.displayName || data.email?.split("@")[0] || "New Member";
}

/** ------------------------
 *   NOTIFICATION TRIGGERS
 * ------------------------ **/

exports.notifyOnGroupInvite = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    const context = event;

    const data = snap.data();
    if (!data || data.type !== "group_invite") return;

    const receiverId = context.params.userId;
    const tokens = await fetchUserTokens([receiverId]);
    if (!tokens.length) return;

    await sendMulticast(tokens, {
      title: "New group invitation",
      body: `${data.senderName || "Someone"} invited you to join ${data.groupName || "a group"}`,
      data: {
        type: "group_invite",
        groupId: data.groupId || "",
        notificationId: context.params.notificationId,
      },
    });
  }
);

exports.notifyGroupOwnerOnInviteAccepted = onDocumentCreated(
  "groups/{groupId}/members/{memberId}",
  async (event) => {
    const { groupId, memberId } = event.params;

    const groupSnap = await db.collection("groups").doc(groupId).get();
    if (!groupSnap.exists) return;

    const groupData = groupSnap.data() || {};
    const ownerId = groupData.ownerId || groupData.createdBy || "";
    if (!ownerId || ownerId === memberId) return;

    const tokens = await fetchUserTokens([ownerId]);
    if (!tokens.length) return;

    const groupName = groupData.name || "your group";
    const memberNameFromGroup = groupData.memberNames?.[memberId];
    const memberName = memberNameFromGroup || (await buildUserName(memberId)) || "A member";

    await sendMulticast(tokens, {
      title: "Invitation accepted",
      body: `${memberName} just joined ${groupName}`,
      data: {
        type: "invite_accept",
        groupId,
        memberId,
      },
    });
  }
);

exports.notifyGroupMembersOnNewMessage = onDocumentCreated(
  "groups/{groupId}/messages/{messageId}",
  async (event) => {
    const snap = event.data;
    const context = event;
    const messageData = snap.data();
    if (!messageData) return;

    const { groupId, messageId } = context.params;
    const senderId = messageData.userId || "";
    const senderName = messageData.userName || "Someone";
    const messageType = messageData.type || "text";
    const messageText = messageData.message || "";

    const groupSnap = await db.collection("groups").doc(groupId).get();
    if (!groupSnap.exists) return;

    const groupData = groupSnap.data() || {};
    const groupName = groupData.name || "Group chat";
    const memberIds = Array.isArray(groupData.memberIds) ? groupData.memberIds : [];
    const recipientIds = memberIds.filter((uid) => typeof uid === "string" && uid !== senderId);

    if (!recipientIds.length) return;

    const tokens = await fetchUserTokens(recipientIds);
    if (!tokens.length) return;

    const snippet =
      messageType === "text" && messageText.trim().length > 0
        ? messageText.trim()
        : `[${messageType.toUpperCase()}]`;

    await sendMulticast(tokens, {
      title: groupName,
      body: `${senderName}: ${snippet}`,
      data: {
        type: "group_message",
        groupId,
        messageId,
        senderId,
        senderName,
        messageType,
      },
    });
  }
);
