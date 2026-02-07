# FantomePad Web Hub

## Overview
The **FantomePad Web Hub** is the central management portal for the FantomePad ecosystem. It provides users with a premium onboarding experience and a comprehensive dashboard to manage their trading terminal licenses and hardware bindings.

## Tech Stack
- **Framework:** [Next.js 15](https://nextjs.org/) (App Router)
- **Language:** [TypeScript](https://www.typescriptlang.org/)
- **Styling:** [Tailwind CSS 4](https://tailwindcss.com/)
- **Animations:** [Framer Motion](https://www.framer.com/motion/)
- **Backend/Auth:** [Supabase](https://supabase.com/) (SSR)
- **Deployment:** [Netlify](https://www.netlify.com/)

## Key Features
- **Modern Dashboard:** A sleek, high-performance interface to monitor license status and terminal connectivity.
- **Interactive Onboarding:** A step-by-step guided flow for new users to set up their accounts and link their MT4 terminals.
- **Real-time Integration:** Seamless synchronization with the Supabase backend used by the MQL4 Expert Advisor.
- **Responsive Design:** Fully optimized for all screen sizes with a focus on ease of use.

## Getting Started

### Prerequisites
- Node.js 20+
- npm or yarn

### Installation
1. Navigate to the `web` directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables:
   Create a `.env.local` file with your Supabase credentials.

### Development
Run the development server:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the results.

## Deployment
This project is configured for deployment on **Netlify**.
- Build Command: `npm run build`
- Publish Directory: `.next`

---
*Part of the FantomePad Ecosystem*
