import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Card } from "@/components/ui/card";
import { Send, Sparkles, Loader2 } from "lucide-react";
import Navbar from "@/components/Navbar";
import { toast } from "sonner";

interface Message {
  role: "user" | "assistant";
  content: string;
}

const Chat = () => {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: "assistant",
      content: "Olá! Sou a Palavra Viva, sua assistente espiritual guiada por IA. Como posso ajudar você hoje? Pergunte sobre versículos, peça orientação ou compartilhe suas dúvidas.",
    },
  ]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage: Message = { role: "user", content: input };
    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsLoading(true);

    try {
      // TODO: Implement actual AI call via edge function
      // For now, simulating response
      setTimeout(() => {
        const aiResponse: Message = {
          role: "assistant",
          content: "Esta é uma resposta de demonstração. Em breve, conectaremos à IA teológica completa para fornecer interpretações bíblicas profundas e orientação espiritual baseada nas Escrituras.",
        };
        setMessages((prev) => [...prev, aiResponse]);
        setIsLoading(false);
      }, 1500);
    } catch (error) {
      toast.error("Erro ao enviar mensagem. Tente novamente.");
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-celestial">
      <Navbar />
      
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-8">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-8 animate-fade-up">
            <div className="inline-flex items-center space-x-2 bg-primary/10 px-4 py-2 rounded-full border border-primary/20 mb-4">
              <Sparkles className="h-4 w-4 text-primary animate-glow" />
              <span className="text-sm font-medium text-primary">Palavra Viva</span>
            </div>
            <h1 className="text-4xl font-bold mb-2">
              <span className="bg-gradient-divine bg-clip-text text-transparent">
                Converse com a Bíblia
              </span>
            </h1>
            <p className="text-muted-foreground">
              Faça perguntas, busque orientação e explore as Escrituras com IA
            </p>
          </div>

          {/* Chat Messages */}
          <Card className="mb-4 p-6 min-h-[500px] max-h-[600px] overflow-y-auto space-y-4">
            {messages.map((message, index) => (
              <div
                key={index}
                className={`flex ${message.role === "user" ? "justify-end" : "justify-start"} animate-fade-in`}
              >
                <div
                  className={`max-w-[80%] rounded-2xl px-6 py-4 ${
                    message.role === "user"
                      ? "bg-gradient-divine text-primary-foreground"
                      : "bg-muted text-foreground border-2 border-border"
                  }`}
                >
                  {message.role === "assistant" && (
                    <div className="flex items-center space-x-2 mb-2">
                      <Sparkles className="h-4 w-4 text-primary" />
                      <span className="text-sm font-semibold text-primary">IA Teológica</span>
                    </div>
                  )}
                  <p className="leading-relaxed whitespace-pre-wrap">{message.content}</p>
                </div>
              </div>
            ))}
            
            {isLoading && (
              <div className="flex justify-start animate-fade-in">
                <div className="bg-muted text-foreground border-2 border-border rounded-2xl px-6 py-4">
                  <Loader2 className="h-5 w-5 animate-spin text-primary" />
                </div>
              </div>
            )}
          </Card>

          {/* Input Area */}
          <div className="flex gap-2">
            <Textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  handleSend();
                }
              }}
              placeholder="Digite sua pergunta ou pedido de oração..."
              className="min-h-[60px] resize-none"
              disabled={isLoading}
            />
            <Button
              onClick={handleSend}
              disabled={isLoading || !input.trim()}
              className="bg-gradient-divine hover:opacity-90 transition-opacity px-6"
              size="lg"
            >
              <Send className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Chat;
