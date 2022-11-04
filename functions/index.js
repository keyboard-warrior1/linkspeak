const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.messageFunction = functions.firestore
    .document("Users/{docId}/chats/{chat}/messages/{message}")
    .onCreate((snap, context) => {
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {title: snap.data().user, body: snap.data().description}});
    });
exports.mentionFunction = functions.firestore
    .document("Users/{docId}/Mention Box/{mention}")
    .onCreate((snap, context) => {
      const field = "mentioned user";
      const recipient = snap.get(field);
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + snap.data().description}});
    });
exports.repliesFunction = functions.firestore
    .document("Users/{docId}/CommentRepliesNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " replied to your comment"}});
    });
exports.commentsFunction = functions.firestore
    .document("Users/{docId}/PostCommentsNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " commented on your post"}});
    });
exports.linkedFunction = functions.firestore
    .document("Users/{docId}/NewLinkedNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {
        notification: {body: recipient+": "+"You are now linked with "+user}});
    });
exports.requestsFunction = functions.firestore
    .document("Users/{docId}/LinkRequestsNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " wants to link with you"}});
    });
exports.linksFunction = functions.firestore
    .document("Users/{docId}/NewLinksNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " is now linked with you"}});
    });
exports.flareLikesFunction = functions.firestore
    .document("Flares/{docId}/LikeNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " likes your flare"}});
    });
exports.flareCommentsFunction = functions.firestore
    .document("Flares/{docId}/CommentNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " commented on your flare"}});
    });
exports.likesFunction = functions.firestore
    .document("Users/{docId}/PostLikesNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + " likes your post"}});
    });
