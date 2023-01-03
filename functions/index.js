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
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " replied to your comment";
      if (recipientLang == "ar") {
        notifDescription = " رد على تعليقك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " yourumunuza yanıt verdi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.commentsFunction = functions.firestore
    .document("Users/{docId}/PostCommentsNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " commented on your post";
      if (recipientLang == "ar") {
        notifDescription = " علّق على منشورك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " paylaşımınıza yorum ekledi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.linkedFunction = functions.firestore
    .document("Users/{docId}/NewLinkedNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      let user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = "You are now linked with ";
      if (recipientLang == "ar") {
        notifDescription = " أنت الآن تتابع ";
      }
      if (recipientLang == "tr") {
        notifDescription = user+" takip isteğinizi kabul etti";
        user = "";
      }
      return admin.messaging().sendToDevice(snap.data().token, {
        notification: {body: recipient+": "+notifDescription+user}});
    });
exports.requestsFunction = functions.firestore
    .document("Users/{docId}/LinkRequestsNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " wants to link with you";
      if (recipientLang == "ar") {
        notifDescription = " يطلب ان يتابعك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " size bir takip isteği gönderdi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.linksFunction = functions.firestore
    .document("Users/{docId}/NewLinksNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " is now linked with you";
      if (recipientLang == "ar") {
        notifDescription = " أصبح من متابعينك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " sizi takip ediyor";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.flareLikesFunction = functions.firestore
    .document("Flares/{docId}/LikeNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " likes your flare";
      if (recipientLang == "ar") {
        notifDescription = " أعجبه الفلير الخاصة بك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " sizin flare beğendi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.flareCommentsFunction = functions.firestore
    .document("Flares/{docId}/CommentNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " commented on your flare";
      if (recipientLang == "ar") {
        notifDescription = " علّق على الفلير الخاصة بك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " sizin flare'e yorum ekledi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
exports.likesFunction = functions.firestore
    .document("Users/{docId}/PostLikesNotifs/{notif}")
    .onCreate( async (snap, context) => {
      const db = admin.firestore();
      const user = snap.data().user;
      const recipient = snap.data().recipient;
      const recipientUser = await db.collection("Users").doc(recipient).get();
      const recipientLang = recipientUser.data().language;
      let notifDescription = " likes your post";
      if (recipientLang == "ar") {
        notifDescription = " أعجبه منشورك ";
      }
      if (recipientLang == "tr") {
        notifDescription = " paylaşımınızı beğendi";
      }
      return admin.messaging().sendToDevice(snap.data().token, {notification:
        {body: recipient + ": " + user + notifDescription}});
    });
