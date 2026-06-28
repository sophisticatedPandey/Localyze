import axios from 'axios';
import { useDebugValue , useState , useEffect} from 'react';
import { Link } from 'react-router-dom'

export default function SignUp() {

const [username, setUsername] = useState('');
const [email, setEmail] = useState('');
const [password, setPassword] = useState('');
const [confirmPassword, setConfirmPassword] = useState('');
const [phoneNumber, setPhoneNumber] = useState(''); 

useEffect(() => {
    console.log('Username:', username);
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('Confirm Password:', confirmPassword);
}, [username, email, password, confirmPassword]);


const handleSubmit = (e) => {
    e.preventDefault();

    axios.post('http://localhost:5004/api/signup', {
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber
    })
    .then(response => {
        console.log(response.data);
        // Handle successful signup (e.g., redirect to login page)
    })
    .catch(error => {
        console.error('Error signing up:', error);
        // Handle signup error (e.g., display error message)
    });
}
    return (
        <div className="flex flex-col justify-center items-center h-screen md:flex-row">
            <img src="src\assets\full_logo.png" className='w-25 h-40 md:h-90 md:w-60' />
            <form className="bg-white p-6 rounded-lg shadow-md w-96" onSubmit={handleSubmit}>
                <h2 className="text-2xl text-center font-bold mb-4">Business SignUp</h2>
                <div className="mb-4">
                    <label htmlFor="username" className="block text-gray-700 font-semibold mb-2">Username</label>
                    <input type="text" id="username" name="username" placeholder="Enter your username" className="w-full px-3 py-2 border rounded focus:outline-none focus:ring focus:border-blue-300" required onChange={(e) => setUsername(e.target.value)} />
                </div>
                <div className="mb-4">
                    <label htmlFor="email" className="block text-gray-700 font-semibold mb-2">Email</label>
                    <input type="email" id="email" name="email" placeholder="example@business.com" className="w-full px-3 py-2 border rounded focus:outline-none focus:ring focus:border-blue-300" required onChange={(e) => setEmail(e.target.value)} />
                </div>
                <div className="mb-4">
                    <label htmlFor="password" className="block text-gray-700 font-semibold mb-2">Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" className="w-full px-3 py-2 border rounded focus:outline-none focus:ring focus:border-blue-300" required onChange={(e) => setPassword(e.target.value)} />
                </div>
                <div className="mb-4">
                    <label htmlFor="confirmPassword" className="block text-gray-700 font-semibold mb-2">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" className="w-full px-3 py-2 border rounded focus:outline-none focus:ring focus:border-blue-300" required onChange={(e) => setConfirmPassword(e.target.value)} />
                </div>
                <div className="mb-4">
                    <label htmlFor="phoneno" className="block text-gray-700 font-semibold mb-2">Phone Number</label>
                    <input type="tel" id="phoneno" pattern="[0-9]{10}" name="phoneno"  placeholder="+91 XXXXX XXXXX" className="w-full px-3 py-2 border rounded" />
                </div>
                <button type="submit" className="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition duration-300">SignUp</button>
                <div className="text-base m-1">Already a user? <Link to="/login" className="text-blue-500">Login</Link></div>
            </form>
        </div>
    )


}
