import { useState } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Search, BookmarkPlus, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

interface VerseResult {
  book: {
    name: string;
  };
  chapter: number;
  number: number;
  text: string;
  version?: string;
}

const Biblia = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [version, setVersion] = useState("nvi");
  const [searchResults, setSearchResults] = useState<VerseResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  const handleSearch = async () => {
    if (!searchQuery.trim()) {
      toast.error("Digite uma referência ou tema para pesquisar");
      return;
    }

    setIsSearching(true);
    try {
      const { data, error } = await supabase.functions.invoke('search-bible', {
        body: { query: searchQuery, version }
      });

      if (error) throw error;

      if (data.verses) {
        setSearchResults(data.verses);
        toast.success(`${data.verses.length} versículo(s) encontrado(s)`);
      } else if (data.text) {
        setSearchResults([data]);
        toast.success("Versículo encontrado!");
      } else {
        setSearchResults([]);
        toast.error("Nenhum versículo encontrado");
      }
    } catch (error) {
      console.error('Search error:', error);
      toast.error("Erro ao buscar versículo");
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleSaveFavorite = async (verse: VerseResult) => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        toast.error("Você precisa estar logado");
        return;
      }

      const { error } = await supabase.from('favorite_verses').insert({
        user_id: user.id,
        verse_reference: `${verse.book.name} ${verse.chapter}:${verse.number}`,
        verse_text: verse.text,
        version: version.toUpperCase()
      });

      if (error) throw error;
      toast.success("Versículo salvo nos favoritos!");
    } catch (error) {
      console.error('Save error:', error);
      toast.error("Erro ao salvar versículo");
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Bíblia Interativa</h1>
          <p className="text-muted-foreground">
            Explore as Escrituras com interpretações de IA
          </p>
        </div>

        {/* Search */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col gap-4">
              <div className="flex gap-2">
                <Select value={version} onValueChange={setVersion}>
                  <SelectTrigger className="w-32">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="nvi">NVI</SelectItem>
                    <SelectItem value="acf">ACF</SelectItem>
                    <SelectItem value="aa">AA</SelectItem>
                  </SelectContent>
                </Select>
                <Input
                  placeholder="Ex: João 3:16 ou amor"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                />
                <Button onClick={handleSearch} disabled={isSearching}>
                  {isSearching ? (
                    <Loader2 className="h-5 w-5 animate-spin" />
                  ) : (
                    <Search className="h-5 w-5" />
                  )}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Search Results */}
        {searchResults.length > 0 && (
          <div className="space-y-4">
            {searchResults.map((verse, index) => (
              <Card key={index} className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle className="text-xl">
                        {verse.book.name} {verse.chapter}:{verse.number}
                      </CardTitle>
                      <p className="text-sm text-muted-foreground mt-1">
                        {version.toUpperCase()}
                      </p>
                    </div>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      onClick={() => handleSaveFavorite(verse)}
                    >
                      <BookmarkPlus className="h-5 w-5" />
                    </Button>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="p-4 bg-background/50 rounded-lg">
                    <p className="text-lg leading-relaxed">{verse.text}</p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Info Box */}
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground">
              <strong>Dica:</strong> Use a busca para encontrar versículos por referência (ex: "João 3:16")
              ou por tema (ex: "amor", "fé", "esperança"). A IA fornecerá interpretações contextualizadas.
            </p>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Biblia;
