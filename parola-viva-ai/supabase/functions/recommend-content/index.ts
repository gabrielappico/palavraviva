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
    // Obter user_id do body da requisição
    const { user_id } = await req.json();

    if (!user_id) {
      throw new Error("user_id é obrigatório");
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? ""
    );

    // Buscar perfil emocional
    const { data: profile } = await supabaseClient
      .from("user_emotional_profile")
      .select("*")
      .eq("user_id", user_id)
      .single();

    // Buscar últimos check-ins
    const { data: recentCheckIns } = await supabaseClient
      .from("mood_check_ins")
      .select("*")
      .eq("user_id", user_id)
      .order("created_at", { ascending: false })
      .limit(5);

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) {
      throw new Error("LOVABLE_API_KEY is not configured");
    }

    // Preparar contexto para IA
    const mood = profile?.current_mood || "tranquilo";
    const intensity = profile?.mood_intensity || 3;
    const struggles = profile?.frequent_struggles || [];
    const topics = profile?.preferred_topics || [];
    const stage = profile?.spiritual_stage || "iniciante";

    const prompt = `Com base no perfil emocional do usuário, crie uma recomendação personalizada:

PERFIL:
- Humor atual: ${mood} (intensidade ${intensity}/5)
- Lutas frequentes: ${struggles.join(", ") || "Nenhuma registrada"}
- Temas de interesse: ${topics.join(", ") || "Nenhum registrado"}
- Estágio espiritual: ${stage}
- Check-ins recentes: ${recentCheckIns?.map(c => c.mood).join(", ") || "Nenhum"}

Retorne um JSON com:
1. "verse": objeto com "reference" (ex: "João 3:16"), "text" (texto completo do versículo em português), e "reason" (por que este versículo é relevante para o estado atual)
2. "message": mensagem personalizada de encorajamento (50-80 palavras)
3. "prayer_suggestion": sugestão de tema para oração (uma frase)
4. "recommended_action": objeto com "type" e "label" e "path". O path DEVE ser uma dessas rotas válidas:
   - "/dashboard/palavra-viva" (para conversar com a IA)
   - "/dashboard/biblia" (para ler versículos)
   - "/dashboard/oracao" (para gerar oração)
   - "/dashboard/pregacoes" (para criar sermão)
   - "/dashboard/quiz" (para testar conhecimento)
   - "/dashboard/dinamicas" (para atividades em grupo)

Seja empático, compassivo e relevante ao estado emocional.`;

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
      throw new Error(`AI gateway error: ${response.status}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content;

    if (!content) {
      throw new Error("Failed to generate recommendation");
    }

    // Extrair JSON da resposta
    let recommendation;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      recommendation = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(content);
    } catch (e) {
      console.error("Failed to parse AI response:", content);
      throw new Error("Failed to parse recommendation");
    }

    return new Response(
      JSON.stringify({ recommendation }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Recommend content error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});