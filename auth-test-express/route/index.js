const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware');

const firebaseAuthController = require('../controller/firebase-auth-controller');
const postController = require('../controller/post-controller');

// Auth routes
router.post('/api/register', firebaseAuthController.registerUser)
router.post('/api/login', firebaseAuthController.loginUser)
router.post('/api/logout', firebaseAuthController.logoutUser)
router.post('/api/reset-password', firebaseAuthController.resetPassword)
router.post('/api/google-sign-in', firebaseAuthController.googleLogin)
router.post('/api/apple-sign-in', firebaseAuthController.appleLogin)
router.post('/api/refresh', firebaseAuthController.refreshToken)
router.post('/api/checkEmail', firebaseAuthController.isEmailVerified)

//posts routes
router.get('/api/posts', verifyToken, postController.getPosts);

module.exports = router;