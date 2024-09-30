const mysql = require('mysql2/promise');
const fs = require('fs');

const host = process.env.DB_HOST;
const port = parseInt(process.env.DB_PORT, 10);
const user = process.env.DB_USER;
const password = process.env.DB_PASSWORD;
const database = process.env.DB_NAME;


exports.handler = async (event) => {
    const connection = await mysql.createConnection({
        host: host,
        port: port,
        user: user,
        password: password,
        database: database,
        ssl: {
            rejectUnauthorized: true,
            ca: fs.readFileSync('isrgrootx1.pem')
        }
    });

    console.log('Connected to MySQL');
    let id = parseInt(event?.queryStringParameters?.id) ? parseInt(event?.queryStringParameters?.id) : 1;
    // Thực hiện truy vấn
    const [rows, fields] = await connection.execute('SELECT * FROM fortune500_2018_2022  WHERE id = ?', [id]);
    console.log(rows);

    return {
        statusCode: 200,
        body: {
            rows: rows,
            content: 'test pull image dynamic test region'
        },
    };
};