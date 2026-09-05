'use client';

import { useState, useEffect } from 'react';

export default function ThemeToggle() {
  const [theme, setTheme] = useState('light');

  useEffect(() => {
    // Check saved theme or system preference
    const savedTheme = localStorage.getItem('rulescan_theme');
    if (savedTheme) {
      setTheme(savedTheme);
      document.documentElement.setAttribute('data-theme', savedTheme);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setTheme('dark');
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  const toggleTheme = () => {
    const nextTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(nextTheme);
    document.documentElement.setAttribute('data-theme', nextTheme);
    localStorage.setItem('rulescan_theme', nextTheme);
  };

  return (
    <button className="theme-toggle-btn" onClick={toggleTheme} aria-label="Toggle theme">
      {theme === 'light' ? (
        <>
          <span>🌙</span> Dark Mode
        </>
      ) : (
        <>
          <span>☀️</span> Light Mode
        </>
      )}
    </button>
  );
}
