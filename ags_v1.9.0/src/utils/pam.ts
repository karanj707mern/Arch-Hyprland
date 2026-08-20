// Stubbed PAM auth for AGS installed via Arch-Hyprland.
// The desktop overview does not use PAM, and GUtils typelib support
// is unreliable across distros, so we disable these helpers here.

export function authenticate(password: string): Promise<number> {
    return Promise.reject(new Error("PAM authentication disabled on this system (no GUtils)"));
}

export function authenticateUser(username: string, password: string): Promise<number> {
    return Promise.reject(new Error("PAM authentication disabled on this system (no GUtils)"));
}
