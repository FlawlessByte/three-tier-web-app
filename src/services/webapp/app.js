var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var routes = require('./routes/index');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));

// // CloudFront request logging middleware
// // This helps debug issues with CloudFront by logging important headers
// app.use((req, res, next) => {
//     const requestDetails = {
//         timestamp: new Date().toISOString(),
//         method: req.method,
//         path: req.path,
//         cloudfront: {
//             requestId: req.headers['x-amz-cf-id'],
//             viewer: req.headers['cloudfront-viewer-country'],
//             forwardedHost: req.headers['x-forwarded-host'],
//             originalHost: req.headers.host
//         }
//     };
//     console.log('CloudFront Request:', JSON.stringify(requestDetails));
//     next();
// });

// // CloudFront caching and headers middleware
// // This middleware sets appropriate headers for CloudFront caching
// app.use((req, res, next) => {
//     // Set cache control headers based on the request path
//     // Adjust these values based on your caching needs
//     const cacheRules = {
//         // Cache API responses for 5 minutes
//         '/api/': 'public, max-age=60',
//         // Cache static assets for 1 day
//         '/public/': 'public, max-age=86400',
//         // Default to no caching for other routes
//         default: 'no-store'
//     };

//     // Find the matching cache rule based on the request path
//     const cacheRule = Object.entries(cacheRules).find(([path]) => 
//         req.path.startsWith(path)
//     );
    
//     // Apply the cache rule or default
//     res.set('Cache-Control', cacheRule ? cacheRule[1] : cacheRules.default);

//     // Required for proper CloudFront caching with compression
//     res.set('Vary', 'Accept-Encoding');

//     // Add security headers
//     res.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    
//     // Store CloudFront information for potential use in routes
//     req.isFromCloudFront = Boolean(req.headers['x-amz-cf-id']);
    
//     next();
// });

// // CORS middleware for CloudFront
// // This is important if your API is accessed from different domains
// app.use((req, res, next) => {
//     // Allow requests from CloudFront domains
//     const allowedOrigins = [
//         process.env.CLOUDFRONT_DOMAIN, // Your CloudFront domain
//         process.env.APP_DOMAIN         // Your application domain
//     ].filter(Boolean);

//     const origin = req.headers.origin;
//     if (allowedOrigins.includes(origin)) {
//         res.set('Access-Control-Allow-Origin', origin);
//     }

//     res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
//     res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
//     res.set('Access-Control-Allow-Credentials', 'true');

//     // Handle preflight requests
//     if (req.method === 'OPTIONS') {
//         return res.status(200).end();
//     }

//     next();
// });

// Original middleware setup
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
// app.use(express.static(path.join(__dirname, 'public'), {
//     // Set cache control headers for static files
//     maxAge: '1d',
//     etag: true
// }));

app.use('/', routes);

// Custom 404 handler with proper cache headers
app.use(function(req, res, next) {
    // res.set('Cache-Control', 'no-store');
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// Development error handler
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        // res.set('Cache-Control', 'no-store');
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// Production error handler
app.use(function(err, req, res, next) {
    res.set('Cache-Control', 'no-store');
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});

module.exports = app;