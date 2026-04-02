import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { Search, BookOpen, Sparkles } from "lucide-react";
import Navbar from "@/components/Navbar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const Bible = () => {
  const [version, setVersion] = useState("NVI");
  const [searchQuery, setSearchQuery] = useState("");

  // Sample verse for demonstration
  const sampleVerse = {
    reference: "João 3:16",
    text: "Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.",
    version: "NVI",
  };

  return (
    <div className="min-h-screen bg-gradient-celestial">
      <Navbar />
      
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-8">
        <div className="max-w-5xl mx-auto">
          {/* Header */}
          <div className="text-center mb-8 animate-fade-up">
            <div className="inline-flex items-center space-x-2 bg-primary/10 px-4 py-2 rounded-full border border-primary/20 mb-4">
              <BookOpen className="h-4 w-4 text-primary animate-glow" />
              <span className="text-sm font-medium text-primary">Bíblia Interativa</span>
            </div>
            <h1 className="text-4xl font-bold mb-2">
              <span className="bg-gradient-divine bg-clip-text text-transparent">
                Explore as Escrituras
              </span>
            </h1>
            <p className="text-muted-foreground">
              Busque versículos, temas e receba interpretações com IA
            </p>
          </div>

          {/* Search and Filters */}
          <Card className="p-6 mb-6 animate-fade-up" style={{ animationDelay: "100ms" }}>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1 relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                <Input
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Buscar por versículo, palavra ou tema..."
                  className="pl-10"
                />
              </div>
              
              <Select value={version} onValueChange={setVersion}>
                <SelectTrigger className="w-full md:w-[180px]">
                  <SelectValue placeholder="Versão" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="NVI">NVI</SelectItem>
                  <SelectItem value="ARC">ARC</SelectItem>
                  <SelectItem value="ARA">ARA</SelectItem>
                  <SelectItem value="NVT">NVT</SelectItem>
                </SelectContent>
              </Select>
              
              <Button className="bg-gradient-divine hover:opacity-90 transition-opacity">
                Buscar
              </Button>
            </div>
          </Card>

          {/* Sample Verse Display */}
          <Card className="p-8 animate-fade-up" style={{ animationDelay: "200ms" }}>
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-primary">{sampleVerse.reference}</h2>
                <span className="text-sm text-muted-foreground bg-muted px-3 py-1 rounded-full">
                  {sampleVerse.version}
                </span>
              </div>
              
              <p className="text-lg leading-relaxed text-foreground">
                {sampleVerse.text}
              </p>

              <div className="border-t border-border pt-6">
                <div className="flex items-start space-x-3">
                  <Sparkles className="h-5 w-5 text-primary mt-1 flex-shrink-0 animate-glow" />
                  <div className="space-y-2">
                    <h3 className="font-semibold text-primary">Interpretação com IA</h3>
                    <p className="text-muted-foreground leading-relaxed">
                      Este versículo é considerado o coração do Evangelho. Ele revela o amor incondicional de Deus 
                      pela humanidade e o propósito supremo da vinda de Jesus Cristo. A expressão "de tal maneira" 
                      demonstra a profundidade e intensidade deste amor divino, que se manifesta através do maior 
                      sacrifício possível.
                    </p>
                    <p className="text-muted-foreground leading-relaxed">
                      <strong>Aplicação prática:</strong> Este versículo nos convida a refletir sobre o amor de Deus 
                      e a responder com fé genuína, transformando nossa vida através da crença em Jesus Cristo.
                    </p>
                  </div>
                </div>
              </div>

              <div className="flex gap-2 pt-4">
                <Button variant="outline" size="sm">
                  <BookOpen className="h-4 w-4 mr-2" />
                  Adicionar Anotação
                </Button>
                <Button variant="outline" size="sm">
                  Compartilhar
                </Button>
              </div>
            </div>
          </Card>

          {/* Info Box */}
          <div className="mt-6 p-4 bg-primary/5 border border-primary/20 rounded-lg">
            <p className="text-sm text-muted-foreground text-center">
              💡 <strong>Dica:</strong> Use a busca para encontrar versículos sobre temas como "amor", "fé", "esperança" ou digite referências diretas como "Salmos 23"
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Bible;
