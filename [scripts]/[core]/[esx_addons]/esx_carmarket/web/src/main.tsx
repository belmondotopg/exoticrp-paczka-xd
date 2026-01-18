import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'jotai';
import { VisibilityProvider } from './providers/VisibilityProvider';
import App from './components/App';
import './index.scss';
import { VehicleStats } from './components/VehicleStats';
import { TestDriveTimer } from './components/TestDriveTimer';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Provider>
      <VehicleStats/>
      <TestDriveTimer/>
      
      <VisibilityProvider>
        <App />
      </VisibilityProvider>
    </Provider>
  </React.StrictMode>,
);