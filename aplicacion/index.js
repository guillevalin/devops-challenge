const { Pool } = require('pg');

// Parámetros de configuración de la base de datos
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432
};

exports.handler = async (event) => {
    const client = new Pool(dbConfig);

    try {
        await client.connect();

        if (event.httpMethod === "GET") {
            const res = await client.query('SELECT * FROM users;');
            await client.end();

            return {
                statusCode: 200,
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(res.rows)
            };
        } else if (event.httpMethod === "POST") {
            const body = JSON.parse(event.body);
            const { name, email } = body;

            if (!name || !email) {
                return {
                    statusCode: 400,
                    body: JSON.stringify({ message: "Los campos 'name' y 'email' son obligatorios" })
                };
            }

            const insertQuery = 'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *';
            const res = await client.query(insertQuery, [name, email]);
            await client.end();

            return {
                statusCode: 201,
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ message: "Usuario insertado correctamente", user: res.rows[0] })
            };
        } else {
            return {
                statusCode: 405,
                headers: { "Allow": "GET, POST" },
                body: JSON.stringify({ message: "El método utilizado no está permitido." })
            };
        }
    } catch (error) {
        console.error("Ha ocurrido un error al procesar la request:", error);

        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Ha ocurrido un error inesperado, por favor intentarlo nuevamente." })
        };
    }
};