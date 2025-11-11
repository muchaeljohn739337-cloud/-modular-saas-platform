import { NextResponse } from 'next/server';

// Simple mock AI chat route. In production you can proxy to OpenAI or your preferred model.
export async function POST(req: Request) {
  try {
    const { prompt } = await req.json();

    // If you want to proxy to OpenAI, you can use process.env.OPENAI_API_KEY and fetch here.
    // For now, return a small canned response to enable local testing.
    const reply = `I received your prompt: "${String(prompt).slice(0, 200)}".\n\n(Configure OPENAI_API_KEY in the backend to enable real AI responses.)`;

    return NextResponse.json({ reply });
  } catch (err) {
    return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
  }
}
