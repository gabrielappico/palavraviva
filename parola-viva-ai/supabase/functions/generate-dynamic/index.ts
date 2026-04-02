import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { groupType, theme } = await req.json();
    console.log("Generate dynamic request:", { groupType, theme });

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) {
      console.error("LOVABLE_API_KEY not found");
      throw new Error("LOVABLE_API_KEY is not configured");
    }

    const prompt = `Você é um facilitador de dinâmicas cristãs experiente. Crie uma dinâmica completa e prática:

TIPO DE GRUPO: ${groupType}
TEMA: ${theme}

A dinâmica deve incluir:
1. TÍTULO (criativo e atraente)
2. OBJETIVO (o que se espera alcançar)
3. TEMPO ESTIMADO (duração prevista)
4. MATERIAIS NECESSÁRIOS (lista de itens)
5. PASSO A PASSO (instruções detalhadas e numeradas)
6. LIÇÃO BÍBLICA (versículos e reflexão final)
7. DICAS PARA O FACILITADOR

Seja criativo, prático e relevante para o contexto brasileiro.
Responda em português brasileiro em formato JSON com esta estrutura:
{
  "title": "título da dinâmica",
  "objective": "objetivo",
  "estimatedTime": "tempo estimado",
  "materials": ["material 1", "material 2"],
  "steps": ["passo 1", "passo 2", "passo 3"],
  "biblicalLesson": "lição bíblica com versículos",
  "facilitatorTips": "dicas para o facilitador"
}`;

    const response = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash",
        messages: [
          { role: "user", content: prompt },
        ],
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
    const content = data.choices?.[0]?.message?.content;

    if (!content) {
      throw new Error("Failed to generate dynamic");
    }

    // Try to parse JSON from response
    let dynamic;
    try {
      // Remove markdown code blocks if present
      const cleanContent = content.replace(/```json\n?/g, '').replace(/```\n?/g, '');
      dynamic = JSON.parse(cleanContent);
    } catch {
      // If not JSON, return as plain text
      dynamic = {
        title: theme,
        objective: content,
        estimatedTime: "",
        materials: [],
        steps: [],
        biblicalLesson: "",
        facilitatorTips: ""
      };
    }

    return new Response(
      JSON.stringify({ dynamic }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Generate dynamic error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
