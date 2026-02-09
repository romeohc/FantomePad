import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

    // Check environment
    const isBrowser = typeof window !== 'undefined';

    if (!supabaseUrl || !supabaseAnonKey) {
        if (isBrowser) {
            // Runtime (Browser): CRITICAL ERROR
            // If variables are missing here, the app cannot work. We must fail fast.
            throw new Error(
                'Supabase configuration is missing in the browser. ' +
                'Check NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY.'
            );
        } else {
            // Build time or Server Side: WARNING
            // Netlify might not have secrets exposed during build. We use placeholders to prevent build failure.
            console.warn('⚠️ Supabase credentials not found. Using placeholders for build/server generation.');
        }
    }

    return createBrowserClient(
        supabaseUrl || 'https://placeholder.supabase.co',
        supabaseAnonKey || 'placeholder-key'
    )
}
