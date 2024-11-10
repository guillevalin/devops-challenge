const { Pool } = require('pg');
const AWS = require('aws-sdk');

// Parámetros de configuración de la base de datos
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432
};

const snsTopicArn = process.env.SNS_TOPIC_ARN; // ARN del tópico SNS que usaremos

exports.handler = async (event) => {
    const sns = new AWS.SNS();
    const client = new Pool(dbConfig);

    try {
        if (event.httpMethod === "GET") {
            await client.connect();
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

            const message = JSON.stringify({
                name: name,
                email: email
            });

            try {
                await sns.publish({
                    Message: message,
                    TopicArn: snsTopicArn
                }).promise();

                return {
                    statusCode: 201,
                    body: JSON.stringify({ message: "Usuario publicado en el tópico SNS correctamente" })
                };
            } catch (error) {
                console.error("Ha ocurrido un error al publicar en el tópico SNS: ", error);

                return {
                    statusCode: 500,
                    body: JSON.stringify({ message: "Ha ocurrido un error inesperado al enviar la información." })
                };
            }
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
            body: JSON.stringify({ message: "Ha ocurrido un error inesperado." })
        };
    }
};