import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Sparkles, BookOpen, MessageCircle, Heart } from "lucide-react";

const Navbar = () => {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-lg border-b border-border">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <Link to="/" className="flex items-center space-x-2 group">
            <div className="relative">
              <Sparkles className="h-6 w-6 text-primary animate-glow" />
            </div>
            <span className="text-xl font-bold bg-gradient-divine bg-clip-text text-transparent">
              Appi Palavra.AI
            </span>
          </Link>

          <div className="hidden md:flex items-center space-x-8">
            <Link 
              to="/chat" 
              className="flex items-center space-x-2 text-muted-foreground hover:text-primary transition-colors"
            >
              <MessageCircle className="h-4 w-4" />
              <span>Palavra Viva</span>
            </Link>
            <Link 
              to="/bible" 
              className="flex items-center space-x-2 text-muted-foreground hover:text-primary transition-colors"
            >
              <BookOpen className="h-4 w-4" />
              <span>Bíblia</span>
            </Link>
            <Link 
              to="/prayer" 
              className="flex items-center space-x-2 text-muted-foreground hover:text-primary transition-colors"
            >
              <Heart className="h-4 w-4" />
              <span>Oração</span>
            </Link>
          </div>

          <div className="flex items-center space-x-4">
            <Button variant="outline" size="sm">
              Entrar
            </Button>
            <Button 
              size="sm"
              className="bg-gradient-divine hover:opacity-90 transition-opacity"
            >
              Começar Agora
            </Button>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
