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
    const { theme, baseText, targetAudience } = await req.json();
    console.log("Generate sermon request:", { theme, baseText, targetAudience });

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) {
      console.error("LOVABLE_API_KEY not found");
      throw new Error("LOVABLE_API_KEY is not configured");
    }

    const prompt = `Você é um pastor experiente. Crie um sermão/mensagem completo e estruturado com as seguintes informações:

TEMA: ${theme}
TEXTO BASE: ${baseText || "Escolha um texto apropriado"}
PÚBLICO-ALVO: ${targetAudience || "Congregação geral"}

O sermão deve conter:
1. INTRODUÇÃO (engajante e relevante)
2. CONTEXTO BÍBLICO (explicação do texto)
3. TÓPICOS PRINCIPAIS (3-5 pontos com versículos de apoio)
4. APLICAÇÃO PRÁTICA (como aplicar no dia a dia)
5. ILUSTRAÇÕES (exemplos práticos ou histórias)
6. CONCLUSÃO (chamado à ação)
7. ORAÇÃO FINAL

Use linguagem clara, acessível e inspiradora. Inclua referências bíblicas relevantes.
Responda em português brasileiro em formato JSON com esta estrutura:
{
  "introduction": "texto da introdução",
  "context": "contexto bíblico",
  "mainPoints": ["ponto 1", "ponto 2", "ponto 3"],
  "application": "aplicação prática",
  "illustrations": "ilustrações e exemplos",
  "conclusion": "conclusão",
  "closingPrayer": "oração final"
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
      throw new Error("Failed to generate sermon");
    }

    // Try to parse JSON from response
    let sermon;
    try {
      // Remove markdown code blocks if present
      const cleanContent = content.replace(/```json\n?/g, '').replace(/```\n?/g, '');
      sermon = JSON.parse(cleanContent);
    } catch {
      // If not JSON, return as plain text
      sermon = {
        introduction: content,
        context: "",
        mainPoints: [],
        application: "",
        illustrations: "",
        conclusion: "",
        closingPrayer: ""
      };
    }

    return new Response(
      JSON.stringify({ sermon }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Generate sermon error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
