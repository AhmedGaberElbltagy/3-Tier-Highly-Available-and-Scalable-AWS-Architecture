const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 8080;

// In-memory data store
const submissions = [];

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Health check - IMPORTANT: This must work for ALB
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Add a root route for testing
app.get('/', (req, res) => {
    res.json({ message: 'Backend is running!', port: port });
});

// Routes
app.post('/submit', (req, res) => {
    try {
        console.log('Received submission:', req.body);
        
        const { name, email, message } = req.body;

        if (!name || !email || !message) {
            return res.status(400).json({ 
                success: false, 
                message: 'All fields are required.' 
            });
        }

        const newSubmission = {
            id: Date.now(),
            name,
            email,
            message,
            date: new Date().toISOString()
        };

        submissions.push(newSubmission);
        console.log('New submission saved:', newSubmission);

        res.status(200).json({ 
            success: true, 
            message: 'Form submitted successfully!',
            id: newSubmission.id
        });
        
    } catch (error) {
        console.error('Error in /submit:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error' 
        });
    }
});

app.get('/submissions', (req, res) => {
    try {
        res.status(200).json({ 
            success: true, 
            total: submissions.length,
            submissions: submissions.sort((a, b) => new Date(b.date) - new Date(a.date))
        });
    } catch (error) {
        console.error('Error in /submissions:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error' 
        });
    }
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ 
        success: false, 
        message: 'Route not found' 
    });
});

// Start the server - Listen on all interfaces
app.listen(port, '0.0.0.0', () => {
    console.log(`App server listening on all interfaces at port ${port}`);
    console.log(`Health check: http://localhost:${port}/health`);
    console.log(`Test endpoint: http://localhost:${port}/`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully');
    process.exit(0);
});
