import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FantomePad | Setup",
  description: "The new standard is here.",
  icons: {
    icon: "/Logo/logo-blanc.svg",
  },
};

export const viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
