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
    // This is called by GitHub Actions cron, secure it with a simple shared secret
    const authHeader = req.headers.get("Authorization");
    const expectedSecret = Deno.env.get("SUPABASE_FUNCTION_SECRET");
    if (!authHeader || authHeader !== `Bearer ${expectedSecret}`) {
      throw new Error("Unauthorized");
    }

    const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountStr) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT secret");
    }
    const serviceAccount = JSON.parse(serviceAccountStr);
    const projectId = serviceAccount.project_id;
    const firestoreToken = await getGoogleOAuthToken(serviceAccount, "https://www.googleapis.com/auth/datastore");
    const fcmToken = await getGoogleOAuthToken(serviceAccount, "https://www.googleapis.com/auth/firebase.messaging");

    let notificationsSent = 0;

    // 1. Check for Low Stock Products
    const productsUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/products`;
    const prodRes = await fetch(productsUrl, { headers: { "Authorization": `Bearer ${firestoreToken}` } });
    const prodData = await prodRes.json();
    
    for (const p of (prodData.documents || [])) {
      const stockLevel = p.fields?.stock_level?.integerValue || 0;
      const reorderThreshold = p.fields?.reorder_threshold?.integerValue || 10;
      
      if (parseInt(stockLevel) <= parseInt(reorderThreshold)) {
        const prodName = p.fields?.name?.stringValue || "Unknown Product";
        await sendNotification(
          firestoreToken, fcmToken, projectId,
          "Low Stock Alert",
          `${prodName} is running low on stock.`,
          "all_mrs", // Or to specific territory/admins
          "inventory_alert"
        );
        notificationsSent++;
      }
    }

    // 2. Check for pending leave requests > 48h (omitted logic for brevity, would query leave_requests)

    return new Response(JSON.stringify({ success: true, notificationsSent }), {
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

async function sendNotification(fsToken: string, fcmToken: string, projectId: string, title: string, body: string, targetType: string, type: string) {
  // Write to Firestore
  const notificationDoc = {
    fields: {
      title: { stringValue: title },
      body: { stringValue: body },
      type: { stringValue: type },
      sent_to: { stringValue: targetType },
      sent_by_admin: { booleanValue: true },
      sent_at: { timestampValue: new Date().toISOString() },
      is_read: { booleanValue: false },
    },
  };
  await fetch(`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/notifications`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${fsToken}`, "Content-Type": "application/json" },
    body: JSON.stringify(notificationDoc),
  });

  // Send FCM
  const fcmPayload = {
    message: {
      topic: targetType,
      notification: { title, body },
      data: { type }
    }
  };
  await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${fcmToken}`, "Content-Type": "application/json" },
    body: JSON.stringify(fcmPayload),
  });
}

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
