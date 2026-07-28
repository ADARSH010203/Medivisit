import { serve } from "https://deno.land/std/http/server.ts";
import { createSign } from "node:crypto";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { visitId } = await req.json();

    if (!visitId) {
      throw new Error("Missing visitId");
    }

    const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountStr) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT secret");
    }
    const serviceAccount = JSON.parse(serviceAccountStr);

    const firestoreToken = await getGoogleOAuthToken(serviceAccount, "https://www.googleapis.com/auth/datastore");
    const projectId = serviceAccount.project_id;
    
    // Fetch the visit to get MR ID (Optional but good for detailed notification)
    const getVisitUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/visits/${visitId}`;
    const visitRes = await fetch(getVisitUrl, {
      headers: { "Authorization": `Bearer ${firestoreToken}` },
    });
    
    let title = "New Visit Approval Required";
    let body = "A new self-reported visit requires your review.";
    
    if (visitRes.ok) {
      const visitData = await visitRes.json();
      const doctorName = visitData.fields?.doctor_name?.stringValue || "Unknown Doctor";
      body = `A self-reported visit to ${doctorName} is waiting for your review.`;
    }

    // 2. Write to Firestore `notifications` collection for admins
    const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/notifications`;

    const notificationDoc = {
      fields: {
        title: { stringValue: title },
        body: { stringValue: body },
        imageUrl: { stringValue: "" },
        type: { stringValue: "approval_request" },
        sent_to: { stringValue: "admins" },
        target_id: { stringValue: visitId },
        sent_by_admin: { booleanValue: false },
        sent_at: { timestampValue: new Date().toISOString() },
        is_read: { booleanValue: false },
      },
    };

    const fsResponse = await fetch(firestoreUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${firestoreToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(notificationDoc),
    });
    
    if (!fsResponse.ok) {
      const err = await fsResponse.text();
      console.error("Firestore write error:", err);
      throw new Error("Failed to write to Firestore");
    }

    // 3. Send FCM Push Notification to admins
    const fcmToken = await getGoogleOAuthToken(serviceAccount, "https://www.googleapis.com/auth/firebase.messaging");
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    
    const fcmPayload = {
      message: {
        topic: "admins",
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "approval_request",
          visitId: visitId
        }
      }
    };

    const fcmResponse = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${fcmToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(fcmPayload),
    });

    if (!fcmResponse.ok) {
      const err = await fcmResponse.text();
      console.error("FCM error:", err);
      // We don't fail the request if FCM fails, as the notification is safely in Firestore
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

// Helper: Get OAuth2 token using Service Account JWT
async function getGoogleOAuthToken(serviceAccount: any, scope: string): Promise<string> {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600;

  const header = { alg: "RS256", typ: "JWT" };

  const payload = {
    iss: serviceAccount.client_email,
    scope: scope,
    aud: "https://oauth2.googleapis.com/token",
    exp: exp,
    iat: iat,
  };

  const b64Header = btoa(JSON.stringify(header)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const b64Payload = btoa(JSON.stringify(payload)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  const unsignedToken = `${b64Header}.${b64Payload}`;
  const sign = createSign("RSA-SHA256");
  sign.update(unsignedToken);
  sign.end();
  
  let privateKey = serviceAccount.private_key;
  if (!privateKey.includes("-----BEGIN PRIVATE KEY-----")) {
    privateKey = `-----BEGIN PRIVATE KEY-----\n${privateKey}\n-----END PRIVATE KEY-----\n`;
  }
  
  const signature = sign.sign(privateKey, "base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const jwt = `${unsignedToken}.${signature}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  if (!response.ok) {
    throw new Error(`Auth failed: ${await response.text()}`);
  }

  const data = await response.json();
  return data.access_token;
}
