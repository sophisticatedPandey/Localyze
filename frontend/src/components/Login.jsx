import { Link } from 'react-router-dom'

export default function Login() {
    return (
        <div className="flex flex-col justify-center items-center h-screen md:flex-row">
            <img src="src\assets\full_logo.png" className='w-25 h-40 md:h-90 md:w-60' />
            <form className="bg-white p-6 rounded-lg shadow-md w-96">
                <h2 className="text-2xl text-center font-bold mb-4">Business Login</h2>
                <div className="mb-4">
                    <label htmlFor="email" className="block text-gray-700 font-semibold mb-2">Email</label>
                    <input type="email" id="email" name="email" placeholder="example@business.com" className="w-full px-3 py-2 border rounded focus:outline-none focus:ring focus:border-blue-300" required />
                </div>
                <div className="mb-4">
                    <label htmlFor="password" className="block text-gray-700 font-semibold mb-2">Password</label>
                    <input type="password" id="password" name="password" className="w-full px-3 py-2 border rounded" />
                </div>
                <button type="submit" className="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition duration-300">Login</button>
                <div className="text-base m-1">Not a user? <Link to="/signup" className="text-blue-500">Sign up</Link></div>
            </form>
        </div>
    )
}
