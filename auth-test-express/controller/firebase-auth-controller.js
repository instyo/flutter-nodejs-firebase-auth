const { GoogleAuthProvider, OAuthProvider } = require('firebase/auth');
const {
    getAuth,
    createUserWithEmailAndPassword,
    signInWithEmailAndPassword,
    signOut,
    sendEmailVerification,
    sendPasswordResetEmail,
    signInWithCredential,
    admin
} = require('../config/firebase');
const auth = getAuth();

class FirebaseAuthController {

    registerUser(req, res) {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(422).json({
                email: "Email is required",
                password: "Password is required",
            });
        }
        createUserWithEmailAndPassword(auth, email, password)
            .then((userCredential) => {
                sendEmailVerification(auth.currentUser)
                    .then(() => {
                        res.status(201).json({
                            message: "Verification email sent! User created successfully!",
                            user: auth.currentUser.toJSON()
                        });
                    })
                    .catch((error) => {
                        console.error(error);
                        res.status(500).json({ error: "Error sending email verification" });
                    });
            })
            .catch((error) => {
                const errorMessage = error.message || "An error occurred while registering user";
                res.status(500).json({ error: errorMessage });
            });
    }

    async isEmailVerified(req, res) {
        const { userId } = req.body;

        const user = await admin.auth().getUser(userId)

        return res.status(200).json({
            user: user
        })
    }

    loginUser(req, res) {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(422).json({
                email: "Email is required",
                password: "Password is required",
            });
        }
        signInWithEmailAndPassword(auth, email, password)
            .then((userCredential) => {
                const idToken = userCredential._tokenResponse?.idToken;
                const refreshToken = userCredential._tokenResponse?.refreshToken || userCredential.user?.refreshToken;
                if (idToken) {
                    res.cookie('access_token', idToken, { httpOnly: true });
                    if (refreshToken) {
                        res.cookie('refresh_token', refreshToken, { httpOnly: true });
                    }
                    res.status(200).json({ message: "User logged in successfully", user: userCredential.user });
                } else {
                    res.status(500).json({ error: "Internal Server Error" });
                }
            })
            .catch((error) => {
                console.error(error);
                const errorMessage = error.message || "An error occurred while logging in";
                res.status(500).json({ error: errorMessage });
            });
    }

    logoutUser(req, res) {
        signOut(auth)
            .then(() => {
                res.clearCookie('access_token');
                res.status(200).json({ message: "User logged out successfully" });
            })
            .catch((error) => {
                console.error(error);
                res.status(500).json({ error: "Internal Server Error" });
            });
    }

    resetPassword(req, res) {
        const { email } = req.body;
        if (!email) {
            return res.status(422).json({
                email: "Email is required"
            });
        }
        sendPasswordResetEmail(auth, email)
            .then(() => {
                res.status(200).json({ message: "Password reset email sent successfully!" });
            })
            .catch((error) => {
                console.error(error);
                res.status(500).json({ error: "Internal Server Error" });
            });
    }

    googleLogin(req, res) {
        const { idToken } = req.body;
        if (!idToken) {
            return res.status(422).json({
                message: "token needed"
            });
        }

        const credential = GoogleAuthProvider.credential(idToken)
        signInWithCredential(auth, credential).then((userCredential) => {
            const idToken = userCredential._tokenResponse.idToken
            if (idToken) {
                res.cookie('access_token', idToken, {
                    httpOnly: true
                });
                res.status(200).json({ message: "User logged in successfully", user: userCredential.user });
            } else {
                res.status(500).json({ error: "Internal Server Error" });
            }
        })
            .catch((error) => {
                console.error(error);
                const errorMessage = error.message || "An error occurred while logging in";
                res.status(500).json({ error: errorMessage });
            });
    }

    async appleLogin(req, res) {
        try {
            const { idToken, appleUser } = req.body;

            if (!idToken) {
                return res.status(422).json({
                    message: "ID token needed"
                });
            }

            // Verify the Firebase ID token using the admin SDK
            const decodedToken = await admin.auth().verifyIdToken(idToken);

            // Get or create user data
            let user;
            try {
                user = await admin.auth().getUser(decodedToken.uid);
            } catch (error) {
                if (error.code === 'auth/user-not-found') {
                    // User doesn't exist, this shouldn't happen with Apple Sign In flow
                    return res.status(404).json({ error: "User not found" });
                }
                throw error;
            }

            // Update user profile if Apple provided additional info and it's missing
            const updates = {};
            if (appleUser?.givenName && !user.displayName) {
                updates.displayName = `${appleUser.givenName} ${appleUser.familyName || ''}`.trim();
            }
            if (appleUser?.email && !user.email) {
                updates.email = appleUser.email;
            }

            if (Object.keys(updates).length > 0) {
                await admin.auth().updateUser(decodedToken.uid, updates);
                user = await admin.auth().getUser(decodedToken.uid);
            }

            // Set authentication cookie
            res.cookie('access_token', idToken, {
                httpOnly: true
            });

            console.log(user)

            res.status(200).json({
                message: "User logged in successfully with Apple",
                user: {
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName,
                    emailVerified: user.emailVerified,
                    provider: 'apple.com'
                }
            });

        } catch (error) {
            console.error('Apple Sign In error:', error);
            const errorMessage = error.message || "An error occurred during Apple Sign In";
            res.status(500).json({ error: errorMessage });
        }
    }

    // Exchange a Firebase refresh token for a new ID token (access token).
    // Accepts the refresh token either from an httpOnly cookie named `refresh_token`
    // or from the request body { refresh_token }.
    async refreshToken(req, res) {
        try {
            const refreshToken = req.cookies?.refresh_token || req.body?.refresh_token;
            if (!refreshToken) {
                return res.status(401).json({ error: 'No refresh token provided' });
            }

            // Call Firebase Secure Token API to exchange refresh token for id_token
            const url = `https://securetoken.googleapis.com/v1/token?key=${process.env.FIREBASE_API_KEY}`;
            const params = new URLSearchParams({
                grant_type: 'refresh_token',
                refresh_token: refreshToken,
            });

            const response = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString(),
            });

            const data = await response.json();
            if (!response.ok) {
                const message = data?.error?.message || data?.error_description || 'Failed to refresh token';
                return res.status(400).json({ error: message });
            }

            // data contains: access_token (id_token), expires_in, token_type, refresh_token, user_id
            const newIdToken = data.id_token || data.access_token;
            const newRefreshToken = data.refresh_token;

            // rotate cookies (httpOnly)
            if (newIdToken) {
                res.cookie('access_token', newIdToken, { httpOnly: true });
            }
            if (newRefreshToken) {
                res.cookie('refresh_token', newRefreshToken, { httpOnly: true });
            }

            // Return minimal info — tokens are set as cookies
            return res.status(200).json({ message: 'Token refreshed', expires_in: data.expires_in });
        } catch (err) {
            console.error('Error refreshing token:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
    }

    async appleCallback(req, res) {
        const { code, id_token, state } = req.body;

        console.log('>> BODY :', code)
        console.log('>> RES :', id_token)
        console.log('>> State :', state)

        const redirect = `intent://callback?${new URLSearchParams(
            req.body
        ).toString()}#Intent;package=dev.ikhwan.authTest.auth_test;scheme=signinwithapple;end`;

        console.log(`Redirecting to ${redirect}`);

        res.redirect(307, redirect);
    }
}

module.exports = new FirebaseAuthController();