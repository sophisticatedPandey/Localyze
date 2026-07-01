import { useLocation } from 'react-router-dom';

export default function NavigationBar() {
    const location = useLocation();

    // Hide navigation bar on the dashboard page for full dashboard interface layout
    if (location.pathname === '/dashboard') {
        return null;
    }

    return (
        <div className="flex items-center rounded-2xl mx-4 justify-between p-4 text-indigo-950">
            <img src="src\assets\text_logo.png" alt="Logo" className="h-20 w-60" />
            <div className="space-x-4">
                <a href="/" className="hover:text-gray-400">Home</a>
                <a href="/about" className="hover:text-gray-400">About</a>
                <a href="/contact" className="hover:text-gray-400">Contact</a>
            </div>
        </div>
    );
}