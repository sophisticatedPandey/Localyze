import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Login from './components/Login'
import SignUp from './components/SignUp'
import NavigationBar from './components/NavigationBar'
import './App.css'
import UserSection from './views/UserSection'

function App() {
  return (
    <BrowserRouter>
      <NavigationBar />
      <Routes>
        
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/UserSection" element={<UserSection />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
