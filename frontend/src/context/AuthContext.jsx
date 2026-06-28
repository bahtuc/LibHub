import {createContext, useContext, useEffect, useState} from "react";
import * as authService from "../services/AuthService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        authService
            .getCurrentUser()
            .then((data) => setUser(data))
            .catch(() => setUser(null))
            .finally(() => setLoading(false));
    }, []);

    async function handleLogin(usernameOrEmail, password) {
        const data = await authService.login({ usernameOrEmail, password });
        setUser(data);
        return data;
    }

    async function handleRegister(username, password, fullName, email) {
        return await authService.register({username, password, fullName, email});
    }

    async function handleLogout() {
        try {
            await authService.logout();
        } finally {
            setUser(null);
        }
    }

    const value = {
        user,
        loading,
        isAuthenticated: !!user,
        login: handleLogin,
        register: handleRegister,
        logout: handleLogout,
    };

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
{/*TODO: fix ESLint: Parsing error: Unterminated regular expression*/}
export function useAuth() {
    const ctx = useContext(AuthContext);
    if (!ctx) {
        throw new Error("useAuth phải được dùng bên trong <AuthProvider>");
    }
    return ctx;
}