import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import userRouter from './routes/userRouter.js';
import productRouter from './routes/productRouter.js';
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', productRouter);
app.use('/api', userRouter);

// Default route
app.get('/', (req, res) => {
    res.send('FastFood API is running on port ' + PORT);
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});