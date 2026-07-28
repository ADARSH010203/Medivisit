import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { HmacSha1 } from "https://deno.land/std@0.160.0/hash/sha1.ts"

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*' } })
  }

  try {
    const apiSecret = Deno.env.get('CLOUDINARY_API_SECRET')
    if (!apiSecret) {
      throw new Error('CLOUDINARY_API_SECRET not set')
    }

    const { folder = 'medivisit_uploads' } = await req.json()
    const timestamp = Math.round((new Date).getTime() / 1000)

    // String to sign: folder=medivisit_uploads&timestamp=1234567890
    const strToSign = `folder=${folder}&timestamp=${timestamp}${apiSecret}`
    
    // Hash using SHA-1
    const hash = new HmacSha1().update(strToSign).hex()

    return new Response(
      JSON.stringify({ 
        signature: hash,
        timestamp,
        folder
      }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
