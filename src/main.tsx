import React from 'react'
    import ReactDOM from 'react-dom/client'
    import { BrowserRouter, Routes, Route } from 'react-router-dom'
    import App from './App.tsx'
    import DashboardPage from './pages/DashboardPage.tsx'
    import ProjectPage from './pages/ProjectPage.tsx'
    import './index.css'

    ReactDOM.createRoot(document.getElementById('root')!).render(
      <React.StrictMode>
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<App />}>
              <Route index element={<DashboardPage />} />
              <Route path="projects/:projectId" element={<ProjectPage />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </React.StrictMode>,
    )
