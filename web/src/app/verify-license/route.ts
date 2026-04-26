import { NextRequest, NextResponse } from "next/server";

const UPSTREAM =
  "https://zxgkjytxqqxkizqcrdwf.functions.supabase.co/verify-license";

export async function POST(request: NextRequest) {
  const body = await request.text();

  const headers: Record<string, string> = {
    "Content-Type":
      request.headers.get("content-type") ?? "application/json",
  };
  const auth = request.headers.get("authorization");
  if (auth) headers.Authorization = auth;
  const apikey = request.headers.get("apikey");
  if (apikey) headers.apikey = apikey;

  const upstream = await fetch(UPSTREAM, {
    method: "POST",
    headers,
    body,
    cache: "no-store",
  });

  const text = await upstream.text();
  const contentType =
    upstream.headers.get("content-type") ?? "application/json";

  return new NextResponse(text, {
    status: upstream.status,
    headers: { "Content-Type": contentType },
  });
}
