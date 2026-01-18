import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { App } from './app';
import "./globals.css";

// Jednorazowe powiadomienie o gotowości React
if (process.env.NODE_ENV === "production" && typeof GetParentResourceName === "function") {
  setTimeout(() => {
    try {
      fetch(`https://${GetParentResourceName()}/multicharacter/reactReady`, {
        method: "POST"
      }).catch(() => {});
    } catch (e) {
      // Ignore errors
    }
  }, 50);
}

const rootElement = document.getElementById('root')!;

// StrictMode tylko w development - w produkcji spowalnia aplikację
if (process.env.NODE_ENV === "development") {
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>
  );
} else {
  createRoot(rootElement).render(<App />);
}
