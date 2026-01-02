'use client';

import { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, Loader2, Sparkles, Globe, RefreshCw, Database } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { cn } from '@/lib/utils';

interface AIChatProps {
  leagueId: string;
  leagueName: string;
}

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  sources?: string[];
}

type Language = 'en' | 'es';

const TRANSLATIONS = {
  en: {
    title: 'AI Assistant',
    placeholder: 'Ask about standings, predictions, rules...',
    askMe: 'Ask me about your league',
    helpText: 'I can help with standings, statistics, predictions, and league information.',
    indexing: 'Index Data',
    indexingSuccess: 'League data indexed successfully!',
    sources: 'Sources',
    suggested: [
      "Who is leading the championship?",
      "Which driver has the most wins?",
      "When is the next race?",
      "Show me the constructor standings",
    ],
  },
  es: {
    title: 'Asistente IA',
    placeholder: 'Pregunta sobre clasificaciones, predicciones, reglas...',
    askMe: 'Pregúntame sobre tu liga',
    helpText: 'Puedo ayudarte con clasificaciones, estadísticas, predicciones e información de la liga.',
    indexing: 'Indexar Datos',
    indexingSuccess: '¡Datos de la liga indexados exitosamente!',
    sources: 'Fuentes',
    suggested: [
      "¿Quién lidera el campeonato?",
      "¿Qué piloto tiene más victorias?",
      "¿Cuándo es la próxima carrera?",
      "Muéstrame la clasificación de constructores",
    ],
  },
};

export function AIChat({ leagueId, leagueName }: AIChatProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isIndexing, setIsIndexing] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [language, setLanguage] = useState<Language>('en');
  const [indexStatus, setIndexStatus] = useState<{ indexed: boolean; count: number } | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const t = TRANSLATIONS[language];

  // Auto-scroll to bottom when messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Check indexing status on mount
  useEffect(() => {
    async function checkIndex() {
      try {
        const res = await fetch(`/api/embeddings?leagueId=${leagueId}`);
        if (res.ok) {
          const data = await res.json();
          setIndexStatus({ indexed: data.indexed, count: data.documentCount });
        }
      } catch {
        // Ignore errors
      }
    }
    checkIndex();
  }, [leagueId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: [...messages, userMessage].map((m) => ({
            role: m.role,
            content: m.content,
          })),
          leagueId,
          language,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to get response');
      }

      const data = await response.json();
      
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: data.content || 'I apologize, but I could not process your request.',
        sources: data.sources,
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setIsLoading(false);
    }
  };

  const handleIndexData = async () => {
    setIsIndexing(true);
    try {
      const res = await fetch('/api/embeddings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ leagueId }),
      });
      
      if (res.ok) {
        const data = await res.json();
        setIndexStatus({ indexed: true, count: data.documentsIndexed });
        
        // Add system message about indexing
        const systemMessage: Message = {
          id: Date.now().toString(),
          role: 'assistant',
          content: t.indexingSuccess + ` (${data.documentsIndexed} ${language === 'es' ? 'documentos' : 'documents'})`,
        };
        setMessages(prev => [...prev, systemMessage]);
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to index'));
    } finally {
      setIsIndexing(false);
    }
  };

  const handleSuggestedQuestion = (question: string) => {
    setInput(question);
  };

  const toggleLanguage = () => {
    setLanguage(l => l === 'en' ? 'es' : 'en');
  };

  return (
    <Card className="flex flex-col h-[600px]">
      <CardHeader className="border-b pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-[#39ff14]" />
            {t.title}
            <span className="text-sm font-normal text-muted-foreground">
              • {leagueName}
            </span>
          </CardTitle>
          <div className="flex items-center gap-2">
            {/* Index status badge */}
            {indexStatus && (
              <span className={cn(
                "text-xs px-2 py-1 rounded-full",
                indexStatus.indexed 
                  ? "bg-green-500/20 text-green-400" 
                  : "bg-yellow-500/20 text-yellow-400"
              )}>
                <Database className="h-3 w-3 inline mr-1" />
                {indexStatus.count} docs
              </span>
            )}
            {/* Index button */}
            <Button
              variant="ghost"
              size="sm"
              onClick={handleIndexData}
              disabled={isIndexing}
              title={t.indexing}
            >
              <RefreshCw className={cn("h-4 w-4", isIndexing && "animate-spin")} />
            </Button>
            {/* Language toggle */}
            <Button
              variant="ghost"
              size="sm"
              onClick={toggleLanguage}
              title={language === 'en' ? 'Switch to Spanish' : 'Cambiar a Inglés'}
            >
              <Globe className="h-4 w-4 mr-1" />
              {language.toUpperCase()}
            </Button>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="flex-1 flex flex-col p-0 overflow-hidden">
        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center">
              <Bot className="h-12 w-12 text-muted-foreground/50 mb-4" />
              <h3 className="font-semibold mb-2">{t.askMe}</h3>
              <p className="text-sm text-muted-foreground mb-6 max-w-sm">
                {t.helpText}
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 max-w-md">
                {t.suggested.map((question, idx) => (
                  <Button
                    key={idx}
                    variant="outline"
                    size="sm"
                    className="text-left justify-start h-auto py-2 px-3"
                    onClick={() => handleSuggestedQuestion(question)}
                  >
                    <Sparkles className="h-3 w-3 mr-2 flex-shrink-0 text-[#39ff14]" />
                    <span className="truncate">{question}</span>
                  </Button>
                ))}
              </div>
            </div>
          ) : (
            messages.map((message) => (
              <div
                key={message.id}
                className={cn(
                  'flex gap-3 max-w-[85%]',
                  message.role === 'user' ? 'ml-auto flex-row-reverse' : ''
                )}
              >
                <div
                  className={cn(
                    'flex h-8 w-8 shrink-0 items-center justify-center rounded-full',
                    message.role === 'user'
                      ? 'bg-[#39ff14] text-black'
                      : 'bg-muted'
                  )}
                >
                  {message.role === 'user' ? (
                    <User className="h-4 w-4" />
                  ) : (
                    <Bot className="h-4 w-4" />
                  )}
                </div>
                <div className="flex flex-col gap-1">
                  <div
                    className={cn(
                      'rounded-lg px-4 py-2.5',
                      message.role === 'user'
                        ? 'bg-[#39ff14]/20 border border-[#39ff14]/30'
                        : 'bg-muted'
                    )}
                  >
                    <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                  </div>
                  {/* Show sources for assistant messages */}
                  {message.role === 'assistant' && message.sources && message.sources.length > 0 && (
                    <div className="flex gap-1 text-xs text-muted-foreground">
                      <span>{t.sources}:</span>
                      {message.sources.map((src, i) => (
                        <span key={i} className="bg-muted/50 px-1.5 py-0.5 rounded">
                          {src}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
          
          {isLoading && (
            <div className="flex gap-3">
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted">
                <Bot className="h-4 w-4" />
              </div>
              <div className="rounded-lg px-4 py-2.5 bg-muted">
                <Loader2 className="h-4 w-4 animate-spin text-[#39ff14]" />
              </div>
            </div>
          )}

          {error && (
            <div className="p-4 rounded-lg bg-destructive/10 text-destructive text-sm">
              Error: {error.message}
            </div>
          )}
          
          {/* Auto-scroll anchor */}
          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="border-t p-4">
          <form onSubmit={handleSubmit} className="flex gap-2">
            <Input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={t.placeholder}
              disabled={isLoading}
              className="flex-1"
            />
            <Button 
              type="submit" 
              disabled={isLoading || !input.trim()}
              className="bg-[#39ff14] text-black hover:bg-[#32e612]"
            >
              {isLoading ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Send className="h-4 w-4" />
              )}
            </Button>
          </form>
        </div>
      </CardContent>
    </Card>
  );
}
