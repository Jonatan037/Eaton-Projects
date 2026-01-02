/**
 * RAG Chat Service
 * AI-powered chat with retrieval-augmented generation for league data
 * Supports EN/ES responses with guardrails
 */

import { searchEmbeddings, getLeagueContext } from './embeddings';
import prisma from '@/lib/db';

export type SupportedLanguage = 'en' | 'es';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

interface ChatOptions {
  leagueId: string;
  messages: ChatMessage[];
  language?: SupportedLanguage;
  useRAG?: boolean;
}

interface ChatResponse {
  content: string;
  language: SupportedLanguage;
  sources: string[];
  tokensUsed?: number;
}

// System prompts for guardrails
const SYSTEM_PROMPTS = {
  en: `You are the AI assistant for a Formula 1 league management platform called ApexGrid AI.

IMPORTANT GUARDRAILS:
1. Only answer questions about the league data provided in the context
2. If you don't have information to answer a question, say "I don't have that information in my records"
3. Never make up race results, standings, or driver information
4. If asked about real-world F1, clarify that you only have data for this specific league
5. Be helpful but concise - keep responses under 300 words
6. Format standings and results clearly with numbers and positions
7. If the context is empty or missing, acknowledge you need the league to be indexed first

You have access to the following league data:
- Driver and Constructor standings
- Race calendar and schedule
- Team and driver rosters
- Scoring rules and league regulations
- Past race results

Respond in English.`,

  es: `Eres el asistente de IA para ApexGrid AI, una plataforma de gestión de ligas de Formula 1.

REGLAS IMPORTANTES:
1. Solo responde preguntas sobre los datos de la liga proporcionados en el contexto
2. Si no tienes información, di "No tengo esa información en mis registros"
3. Nunca inventes resultados de carreras, clasificaciones o información de pilotos
4. Si preguntan sobre F1 real, aclara que solo tienes datos de esta liga específica
5. Sé útil pero conciso - mantén las respuestas en menos de 300 palabras
6. Formatea las clasificaciones y resultados claramente con números y posiciones
7. Si el contexto está vacío, indica que la liga necesita ser indexada primero

Tienes acceso a los siguientes datos de la liga:
- Clasificación de pilotos y constructores
- Calendario de carreras
- Equipos y pilotos
- Reglas de puntuación
- Resultados de carreras anteriores

Responde en Español.`,
};

// Detect language from user message
function detectLanguage(text: string): SupportedLanguage {
  // Common Spanish words and patterns
  const spanishPatterns = [
    /\b(hola|cómo|qué|quién|cuándo|dónde|clasificación|piloto|carrera|puntos|equipo|resultado|próxima|calendario)\b/i,
    /[áéíóúñ¿¡]/,
  ];

  for (const pattern of spanishPatterns) {
    if (pattern.test(text)) {
      return 'es';
    }
  }

  return 'en';
}

// Build context from RAG search or full league context
async function buildContext(
  leagueId: string,
  query: string,
  useRAG: boolean
): Promise<{ context: string; sources: string[] }> {
  if (useRAG) {
    // Use semantic search for relevant documents
    const results = await searchEmbeddings(leagueId, query, 4);
    
    if (results.length === 0) {
      // Fallback to full context
      const fullContext = await getLeagueContext(leagueId);
      return {
        context: fullContext || 'No league data has been indexed yet.',
        sources: ['full-context'],
      };
    }

    const context = results
      .map(r => `[${r.documentType.toUpperCase()}]\n${r.content}`)
      .join('\n\n---\n\n');

    return {
      context,
      sources: results.map(r => r.documentType),
    };
  } else {
    // Use full league context
    const fullContext = await getLeagueContext(leagueId);
    return {
      context: fullContext || 'No league data has been indexed yet.',
      sources: ['full-context'],
    };
  }
}

// Call OpenAI API
async function callOpenAI(
  messages: ChatMessage[],
  systemPrompt: string
): Promise<{ content: string; tokensUsed: number } | null> {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return null;
  }

  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini', // Cost-effective model for chat
        messages: [
          { role: 'system', content: systemPrompt },
          ...messages,
        ],
        max_tokens: 500,
        temperature: 0.7,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('OpenAI chat error:', error);
      return null;
    }

    const data = await response.json();
    return {
      content: data.choices[0]?.message?.content ?? '',
      tokensUsed: data.usage?.total_tokens ?? 0,
    };
  } catch (error) {
    console.error('Failed to call OpenAI:', error);
    return null;
  }
}

// Fallback response when OpenAI is not available
async function generateFallbackResponse(
  leagueId: string,
  query: string,
  language: SupportedLanguage
): Promise<string> {
  const queryLower = query.toLowerCase();

  // Get league info
  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) {
    return language === 'es'
      ? 'No puedo encontrar información de esta liga.'
      : "I can't find information for this league.";
  }

  // Standings query
  if (queryLower.includes('standing') || queryLower.includes('clasificación') || 
      queryLower.includes('leading') || queryLower.includes('líder') ||
      queryLower.includes('championship') || queryLower.includes('campeonato')) {
    const results = await prisma.result.findMany({
      where: { round: { leagueId } },
      include: { driver: { include: { team: true } } },
    });

    const driverPoints: Record<string, { name: string; team: string; points: number }> = {};
    for (const result of results) {
      if (!driverPoints[result.driverId]) {
        driverPoints[result.driverId] = {
          name: result.driver.fullName,
          team: result.driver.team?.name ?? 'Unknown',
          points: 0,
        };
      }
      driverPoints[result.driverId].points += result.points;
    }

    const standings = Object.values(driverPoints)
      .sort((a, b) => b.points - a.points)
      .slice(0, 10);

    if (standings.length === 0) {
      return language === 'es'
        ? `No hay resultados registrados aún en ${league.name}.`
        : `No race results recorded yet in ${league.name}.`;
    }

    const title = language === 'es' ? 'Clasificación de Pilotos' : 'Driver Standings';
    let response = `**${title} - ${league.name}:**\n\n`;
    standings.forEach((d, i) => {
      response += `${i + 1}. ${d.name} (${d.team}) - ${d.points} ${language === 'es' ? 'puntos' : 'points'}\n`;
    });

    return response;
  }

  // Schedule/next race query
  if (queryLower.includes('next') || queryLower.includes('próxima') ||
      queryLower.includes('schedule') || queryLower.includes('calendario') ||
      queryLower.includes('when') || queryLower.includes('cuándo')) {
    const now = new Date();
    const upcomingRounds = await prisma.round.findMany({
      where: {
        leagueId,
        scheduledAt: { gt: now },
        status: 'SCHEDULED',
      },
      include: { track: true },
      orderBy: { scheduledAt: 'asc' },
      take: 3,
    });

    if (upcomingRounds.length === 0) {
      return language === 'es'
        ? `No hay carreras programadas en ${league.name}.`
        : `No upcoming races scheduled in ${league.name}.`;
    }

    const title = language === 'es' ? 'Próximas Carreras' : 'Upcoming Races';
    let response = `**${title} - ${league.name}:**\n\n`;
    
    upcomingRounds.forEach((round) => {
      const date = round.scheduledAt.toLocaleDateString(language === 'es' ? 'es-ES' : 'en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      });
      response += `• ${language === 'es' ? 'Ronda' : 'Round'} ${round.roundNumber}: ${round.track?.name ?? 'TBD'} - ${date}\n`;
    });

    return response;
  }

  // Teams/drivers query
  if (queryLower.includes('team') || queryLower.includes('equipo') ||
      queryLower.includes('driver') || queryLower.includes('piloto')) {
    const teams = await prisma.team.findMany({
      where: { leagueId, isActive: true },
      include: { drivers: { where: { isActive: true } } },
    });

    const title = language === 'es' ? 'Equipos y Pilotos' : 'Teams & Drivers';
    let response = `**${title} - ${league.name}:**\n\n`;
    
    for (const team of teams) {
      response += `**${team.name}**\n`;
      for (const driver of team.drivers) {
        response += `  • ${driver.fullName}${driver.isReserve ? (language === 'es' ? ' (Reserva)' : ' (Reserve)') : ''}\n`;
      }
      response += '\n';
    }

    return response;
  }

  // Default help response
  if (language === 'es') {
    return `¡Soy el asistente de IA de **${league.name}**! Puedo ayudarte con:\n\n` +
      `• **Clasificaciones** - "¿Quién lidera el campeonato?"\n` +
      `• **Calendario** - "¿Cuándo es la próxima carrera?"\n` +
      `• **Equipos** - "Muéstrame los equipos"\n` +
      `• **Puntuación** - "¿Cuántos puntos por ganar?"\n\n` +
      `¡Pregúntame sobre tu liga!`;
  }

  return `I'm the AI assistant for **${league.name}**! I can help you with:\n\n` +
    `• **Standings** - "Who is leading the championship?"\n` +
    `• **Schedule** - "When is the next race?"\n` +
    `• **Teams** - "Show me the teams"\n` +
    `• **Scoring** - "How many points for a win?"\n\n` +
    `Ask me anything about your league!`;
}

/**
 * Process a chat message with RAG
 */
export async function processChat(options: ChatOptions): Promise<ChatResponse> {
  const { leagueId, messages, useRAG = true } = options;
  
  // Get the last user message
  const lastUserMessage = [...messages].reverse().find(m => m.role === 'user');
  const query = lastUserMessage?.content ?? '';

  // Detect language from user message or use provided
  const language = options.language ?? detectLanguage(query);

  // Build context from embeddings
  const { context, sources } = await buildContext(leagueId, query, useRAG);

  // Try OpenAI first
  const systemPrompt = SYSTEM_PROMPTS[language] + `\n\nCURRENT LEAGUE CONTEXT:\n${context}`;
  
  const openAIResponse = await callOpenAI(
    messages.map(m => ({ role: m.role as 'user' | 'assistant', content: m.content })),
    systemPrompt
  );

  if (openAIResponse) {
    return {
      content: openAIResponse.content,
      language,
      sources,
      tokensUsed: openAIResponse.tokensUsed,
    };
  }

  // Fallback to rule-based response
  const fallbackContent = await generateFallbackResponse(leagueId, query, language);

  return {
    content: fallbackContent,
    language,
    sources: ['fallback'],
  };
}

/**
 * Stream chat response (for real-time UI)
 */
export async function* streamChat(options: ChatOptions): AsyncGenerator<string> {
  const response = await processChat(options);
  
  // Simulate streaming by yielding chunks
  const words = response.content.split(' ');
  for (const word of words) {
    yield word + ' ';
    // Small delay for visual effect
    await new Promise(r => setTimeout(r, 20));
  }
}
