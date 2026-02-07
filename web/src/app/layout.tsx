import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FantomePad | Dashboard",
  description: "The new standard in trading technology activation and management.",
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
