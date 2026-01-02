import { NextRequest, NextResponse } from 'next/server';
import { processChat, SupportedLanguage } from '@/lib/rag-chat';

/**
 * AI Chat API with RAG
 * Supports EN/ES responses with pgvector similarity search
 */

interface RequestBody {
  messages: Array<{ role: 'user' | 'assistant'; content: string }>;
  leagueId: string;
  language?: SupportedLanguage;
  stream?: boolean;
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json() as RequestBody;
    const { messages, leagueId, language, stream = false } = body;

    // Validation
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return NextResponse.json(
        { error: 'Messages array is required' },
        { status: 400 }
      );
    }

    if (!leagueId) {
      return NextResponse.json(
        { error: 'League ID is required' },
        { status: 400 }
      );
    }

    // Process chat with RAG
    const response = await processChat({
      leagueId,
      messages: messages.map(m => ({
        role: m.role,
        content: m.content,
      })),
      language,
      useRAG: true,
    });

    // Return response
    if (stream) {
      // For streaming, we'd use Server-Sent Events
      // For now, return the full response
      return new NextResponse(response.content, {
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'X-Language': response.language,
          'X-Sources': response.sources.join(','),
        },
      });
    }

    return NextResponse.json({
      content: response.content,
      language: response.language,
      sources: response.sources,
      tokensUsed: response.tokensUsed,
    });
  } catch (error) {
    console.error('Chat API error:', error);
    return NextResponse.json(
      { error: 'An error occurred processing your request' },
      { status: 500 }
    );
  }
}

// Health check
export async function GET() {
  return NextResponse.json({
    status: 'ok',
    service: 'AI Chat with RAG',
    features: ['pgvector', 'openai', 'en/es'],
  });
}
