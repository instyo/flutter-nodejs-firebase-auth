const { admin } = require("../config/firebase");
const verifyToken = async (req, res, next) => {
    // Accept "Bearer <token>" from Authorization header, fallback to cookie
    let idToken;
    const authHeader = req.headers.authorization || req.get && req.get('Authorization');

    console.log(authHeader)

    if (authHeader && typeof authHeader === 'string' && authHeader.toLowerCase().startsWith('bearer ')) {
        idToken = authHeader.split(' ')[1];
    } else if (req.cookies && req.cookies.access_token) {
        idToken = req.cookies.access_token;
    }

    if (!idToken) {
        return res.status(403).json({ error: 'No token provided' });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken;
        next();
    } catch (error) {
        console.error('Error verifying token:', error);
        return res.status(403).json({ error: 'Unauthorized' });
    }
};

module.exports = verifyToken;