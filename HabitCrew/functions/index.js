//
//  index.js
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 15/06/25.
//


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendFriendPush = functions.https.onRequest(async (req, res) => {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
    const { toUid, fromName, type } = req.body;
    if (!toUid || !fromName || !type) return res.status(400).send("Missing fields");

    // Get friend's FCM token from Firestore
    const userDoc = await admin.firestore().collection("users").doc(toUid).get();
    const fcmToken = userDoc.get("fcmToken");
    if (!fcmToken) return res.status(404).send("No FCM token");

    let notifTitle = "";
    let notifBody = "";
    if (type === "nudge") {
        notifTitle = "Nudge 👋";
        notifBody = `You were nudged by ${fromName}`;
    } else if (type === "checkin") {
        notifTitle = "Check-in ✅";
        notifBody = `${fromName} checked in with you!`;
    } else {
        notifTitle = "Habit Crew";
        notifBody = `${fromName} sent you a notification`;
    }

    const message = {
        token: fcmToken,
        notification: {
            title: notifTitle,
            body: notifBody,
        },
        data: {
            type: type,
            fromName: fromName
        }
    };

    try {
        await admin.messaging().send(message);
        return res.status(200).send("Notification sent");
    } catch (e) {
        console.error(e);
        return res.status(500).send("Push failed");
    }
});
