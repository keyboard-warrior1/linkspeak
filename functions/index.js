const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.messageFunction = functions.firestore
    .document("Users/{docId}/chats/{chat}/messages/{message}")
    .onCreate((snap, context) => {
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {title: snap.data().user, body: snap.data().description}});
    });
exports.repliesFunction = functions.firestore
    .document("Users/{docId}/CommentRepliesNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: user + " replied to your comment"}});
    });
exports.commentsFunction = functions.firestore
    .document("Users/{docId}/PostCommentsNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: user + " commented on your post"}});
    });
exports.linkedFunction = functions.firestore
    .document("Users/{docId}/NewLinkedNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {
        notification: {body: "You are now linked with " + user}});
    });
exports.requestsFunction = functions.firestore
    .document("Users/{docId}/LinkRequestsNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: user + " wants to link with you"}});
    });
exports.linksFunction = functions.firestore
    .document("Users/{docId}/NewLinksNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: user + " is now linked with you"}});
    });
exports.likesFunction = functions.firestore
    .document("Users/{docId}/PostLikesNotifs/{notif}")
    .onCreate((snap, context) => {
      const user = snap.data().user;
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: user + " likes your post"}});
    });
