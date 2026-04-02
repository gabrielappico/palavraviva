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
    const { messages, conversationId } = await req.json();
    console.log("Chat AI request:", { conversationId, messageCount: messages?.length });

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const {
      data: { user },
    } = await supabaseClient.auth.getUser();

    let emotionalContext = "";
    if (user) {
      const { data: profile } = await supabaseClient
        .from("user_emotional_profile")
        .select("*")
        .eq("user_id", user.id)
        .single();

      if (profile) {
        emotionalContext = `

CONTEXTO EMOCIONAL DO USUÁRIO:
- Humor atual: ${profile.current_mood || "não informado"} (intensidade: ${profile.mood_intensity || "N/A"}/5)
- Lutas frequentes: ${profile.frequent_struggles || "Nenhuma registrada"}
- Preferências: ${profile.preferred_topics || "Nenhuma registrada"}
- Estágio espiritual: ${profile.spiritual_stage || "iniciante"}

IMPORTANTE: Adapte seu tom e conteúdo ao estado emocional:
- Se ansioso: foque em versículos de paz, conforto e descanso em Deus
- Se triste: traga esperança, empatia e lembrança do amor de Deus
- Se confuso: ofereça clareza, sabedoria e direção bíblica
- Se grato/alegre: celebre com o usuário e aprofunde a gratidão`;
      }
    }

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) {
      console.error("LOVABLE_API_KEY not found");
      throw new Error("LOVABLE_API_KEY is not configured");
    }

    const systemPrompt = `Você é a Palavra Viva, uma IA teológica especializada em Bíblia Sagrada.
Sua missão é ajudar as pessoas a compreenderem as Escrituras de forma profunda e aplicável.

DIRETRIZES:
- Sempre cite versículos relevantes (com referência completa: livro, capítulo e versículo)
- Responda com compaixão, sabedoria e encorajamento
- Use linguagem acessível e evite jargões teológicos complexos
- Quando apropriado, faça conexões entre Antigo e Novo Testamento
- Seja sensível ao contexto emocional das perguntas
- Ofereça aplicações práticas para a vida diária
${emotionalContext}

Responda em português brasileiro de forma clara e amorosa.`;

    const response = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash",
        messages: [
          { role: "system", content: systemPrompt },
          ...messages,
        ],
        stream: true,
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

    return new Response(response.body, {
      headers: { ...corsHeaders, "Content-Type": "text/event-stream" },
    });
  } catch (error) {
    console.error("Chat AI error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
