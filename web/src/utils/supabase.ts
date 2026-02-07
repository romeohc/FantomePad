import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

    // During build time, these env vars might not be available
    // Provide fallback to prevent build crash (will fail at runtime if not set)
    if (!supabaseUrl || !supabaseAnonKey) {
        // Return a mock client during build/prerender to prevent crash
        // This is safe because the page uses 'use client' and will re-hydrate
        console.warn('Supabase credentials not found - using placeholder for build')
    }

    return createBrowserClient(
        supabaseUrl || 'https://placeholder.supabase.co',
        supabaseAnonKey || 'placeholder-key'
    )
}
