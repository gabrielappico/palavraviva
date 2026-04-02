import { Link, useLocation } from "react-router-dom";
import { MessageCircle, BookOpen, Heart, Mic, Brain, Users, BookMarked, Home, Sparkles, X, Shield } from "lucide-react";
import { cn } from "@/lib/utils";

const menuItems = [
  { icon: Home, label: "Início", path: "/dashboard" },
  { icon: MessageCircle, label: "Palavra Viva", path: "/dashboard/palavra-viva" },
  { icon: BookOpen, label: "Bíblia", path: "/dashboard/biblia" },
  { icon: Heart, label: "Oração", path: "/dashboard/oracao" },
  { icon: Shield, label: "Confessionário", path: "/dashboard/confessionario" },
  { icon: Mic, label: "Pregações", path: "/dashboard/pregacoes" },
  { icon: Brain, label: "Quiz", path: "/dashboard/quiz" },
  { icon: Users, label: "Dinâmicas", path: "/dashboard/dinamicas" },
  { icon: BookMarked, label: "Diário", path: "/dashboard/diario" },
];

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export const Sidebar = ({ isOpen, onClose }: SidebarProps) => {
  const location = useLocation();

  return (
    <>
      {/* Overlay para mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={cn(
          "fixed lg:static inset-y-0 left-0 z-50 w-64 bg-card border-r border-border flex flex-col transition-transform duration-300",
          isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        )}
      >
        {/* Logo + Close button mobile */}
        <div className="p-6 border-b border-border flex items-center justify-between">
          <Link to="/dashboard" className="flex items-center gap-2" onClick={onClose}>
            <div className="relative">
              <Sparkles className="h-8 w-8 text-primary" />
              <Sparkles className="h-4 w-4 text-accent absolute -top-1 -right-1 animate-pulse" />
            </div>
            <span className="text-xl font-bold bg-gradient-divine bg-clip-text text-transparent">
              Palavra.AI
            </span>
          </Link>
          
          <button
            onClick={onClose}
            className="lg:hidden p-2 hover:bg-accent rounded-lg transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Menu Items */}
        <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;

            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={onClose}
                className={cn(
                  "flex items-center gap-3 px-4 py-3 rounded-lg transition-all",
                  isActive
                    ? "bg-gradient-divine text-white shadow-lg"
                    : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                )}
              >
                <Icon className="h-5 w-5" />
                <span className="font-medium">{item.label}</span>
              </Link>
            );
          })}
        </nav>
      </aside>
    </>
  );
};
