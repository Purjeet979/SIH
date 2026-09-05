import './globals.css';
import { AuthProvider } from '@/context/AuthContext';

export const metadata = {
  title: 'RuleScan - Legal Metrology Compliance',
  description: 'Legal Metrology (Packaged Commodities) Compliance Assistant — Offline-first inspection, OCR, and rule engine for field officers.',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
