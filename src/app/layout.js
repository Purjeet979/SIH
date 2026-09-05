import './globals.css';

export const metadata = {
  title: 'RuleScan - Legal Metrology Compliance',
  description: 'Legal Metrology (Packaged Commodities) Compliance Assistant',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
