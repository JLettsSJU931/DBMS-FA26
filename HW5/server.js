// server.js - My assignment
const express = require("express");
const app = express(); 
const pool = require('./mysql');
const port = 3000;     

//*** server waits indefinitely for incoming requests
app.listen(port, function () {
    console.log("NodeJS app listening on port " + port);
});

//*** create form parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.get('/', async (req, res) => {

    try {
        const { bookid, title, author, category, format } = req.query;

        let sql = 'SELECT * FROM books WHERE 1=1';
        const params = [];
        if(!bookid && !title && !author && !category){
            return res.status(400).json({
                error: 'Please provide a search parameter such as ?category=Sci-Fi or ?author=George%20Orwell',
            });
        }
        if(bookid){
            sql += ' AND bookid = ?';
            params.push(bookid);
        }
        if(title){
            sql += ' AND title = ?';
            params.push(title);
        }
        if(author){
            sql += ' AND author = ?';
            params.push(author);
        }
        if(category){
            sql += ' AND category = ?';
            params.push(category);
        }
        const [results] = await pool.execute(sql, params);
        if (format=='text') {
            let html = `
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Books Search Results</title>
                    <style>
                        body {
                            font-family: Arial, sans-serif;
                            margin: 30px;
                        }
                        table {
                            border-collapse: collapse;
                            width: 100%;
                        }
                        th, td {
                            border: 1px solid #e78888;
                            padding: 10px;
                            text-align: left;
                        }
                        th {
                            background-color: #919191;
                        }
                    </style>
                </head>
                <body>
                    <h1>Books Search Results</h1>
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Price</th>
                        </tr>
            `;
            results.forEach(books => {
                const escapeHTML = value =>
                    String(value ?? '').replace(/[&<>"']/g, char => ({
                        '&': '&amp;',
                        '<': '&lt;',
                        '>': '&gt;',
                        '"': '&quot;',
                        "'": '&#39;'
                    })[char]);

                html += `
                    <tr>
                        <td>${escapeHTML(books.bookid)}</td>
                        <td>${escapeHTML(books.title)}</td>
                        <td>${escapeHTML(books.author)}</td>
                        <td>${escapeHTML(books.category)}</td>
                        <td>${escapeHTML(books.price)}</td>
                    </tr>
                `;
            });
            html += `
                    </table>
                    <p>Total books found: ${results.length}</p>
                </body>
                </html>
            `;

            return res.type('html').send(html);
            }
        return res.json(results);
    }catch (error) {
        console.error('Database error:', error);

        return res.status(500).json({
            error: 'Internal server error',
            message: 'Unable to retrieve books from the database.'
        });
    }
});
