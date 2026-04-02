import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { confession } = await req.json();
    console.log("Confession counsel request received");

    if (!confession || confession.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: "Confissão não pode estar vazia" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (confession.length > 5000) {
      return new Response(
        JSON.stringify({ error: "Confissão muito longa. Limite de 5000 caracteres." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) {
      console.error("LOVABLE_API_KEY not found");
      throw new Error("LOVABLE_API_KEY is not configured");
    }

    const prompt = `Você é um conselheiro espiritual compassivo e sábio, no estilo de um padre experiente. Alguém está compartilhando uma confissão com você de forma confidencial:

"${confession}"

IMPORTANTE:
- Trate esta confissão com absoluto sigilo e respeito
- Não julgue, apenas acolha com compaixão
- Ofereça orientação espiritual baseada na Bíblia
- Sugira passos práticos para arrependimento e reconciliação
- Inclua uma oração específica para a situação
- Use tom pastoral, amoroso mas firme quando necessário

Responda em português brasileiro com:
1. Acolhimento compassivo (2-3 frases)
2. Reflexão bíblica relevante com versículo
3. Orientação espiritual prática (3-4 passos concretos)
4. Oração de arrependimento e restauração (100-150 palavras)
5. Encorajamento final

Lembre-se: "Se confessarmos os nossos pecados, ele é fiel e justo para nos perdoar os pecados e nos purificar de toda injustiça." (1 João 1:9)`;

    const response = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash",
        messages: [{ role: "user", content: prompt }],
        stream: false,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("AI gateway error:", response.status, errorText);
      
      if (response.status === 429) {
        return new Response(
          JSON.stringify({ error: "Limite de requisições excedido. Tente novamente em alguns instantes." }),
          { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      
      if (response.status === 402) {
        return new Response(
          JSON.stringify({ error: "Créditos insuficientes. Entre em contato com o suporte." }),
          { status: 402, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      
      throw new Error(`AI gateway error: ${response.status}`);
    }

    const data = await response.json();
    const counsel = data.choices?.[0]?.message?.content;

    if (!counsel) {
      throw new Error("Failed to generate counsel");
    }

    return new Response(
      JSON.stringify({ counsel }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Confession counsel error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});