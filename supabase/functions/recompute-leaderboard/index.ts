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

    // 1. Fetch all MRs
    const usersUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users`;
    const usersRes = await fetch(usersUrl, {
      headers: { "Authorization": `Bearer ${firestoreToken}` }
    });
    const usersData = await usersRes.json();
    const mrs = (usersData.documents || []).filter((doc: any) => 
      doc.fields?.role?.stringValue === "mr"
    );

    // 2. Fetch recent visits (simplification: we count all verified visits, or we can query by date range)
    // For MVP leaderboard, we fetch visits where geofence_verified == true
    const visitsUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/visits`;
    const visitsRes = await fetch(visitsUrl, {
      headers: { "Authorization": `Bearer ${firestoreToken}` }
    });
    const visitsData = await visitsRes.json();
    
    const visitCounts: Record<string, number> = {};
    for (const v of (visitsData.documents || [])) {
      if (v.fields?.status?.stringValue === "verified") {
        const mrId = v.fields.mr_id.stringValue;
        visitCounts[mrId] = (visitCounts[mrId] || 0) + 1;
      }
    }

    // 3. Compute Leaderboard
    const rankings = mrs.map((mrDoc: any) => {
      const mrId = mrDoc.name.split("/").pop();
      return {
        mr_id: mrId,
        name: mrDoc.fields?.name?.stringValue || "Unknown",
        territory: mrDoc.fields?.territory_id?.stringValue || "Unassigned",
        score: visitCounts[mrId] || 0
      };
    });

    // Sort descending by score
    rankings.sort((a, b) => b.score - a.score);
    
    // Add rank
    rankings.forEach((r, idx) => r.rank = idx + 1);

    // 4. Write snapshot to Firestore
    const period = "weekly"; // Could be dynamic
    const snapshotUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/leaderboard_snapshots/${period}?updateMask.fieldPaths=generated_at&updateMask.fieldPaths=rankings`;
    
    // Format rankings array for Firestore
    const rankingsArray = rankings.map(r => ({
      mapValue: {
        fields: {
          mr_id: { stringValue: r.mr_id },
          name: { stringValue: r.name },
          territory: { stringValue: r.territory },
          score: { integerValue: r.score },
          rank: { integerValue: r.rank }
        }
      }
    }));

    const snapshotDoc = {
      fields: {
        generated_at: { timestampValue: new Date().toISOString() },
        rankings: {
          arrayValue: { values: rankingsArray }
        }
      }
    };

    const snapRes = await fetch(snapshotUrl, {
      method: "PATCH",
      headers: {
        "Authorization": `Bearer ${firestoreToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(snapshotDoc)
    });

    if (!snapRes.ok) {
      console.error(await snapRes.text());
      throw new Error("Failed to write snapshot");
    }

    return new Response(JSON.stringify({ success: true, count: rankings.length }), {
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
  const exp = iat + 3600; // 1 hour

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
