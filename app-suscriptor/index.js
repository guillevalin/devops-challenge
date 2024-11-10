const { Client } = require('pg');

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432
};

exports.handler = async (event) => {
  const client = new Client(dbConfig);

  try {
    await client.connect();

    for (const record of event.Records) {
      const message = JSON.parse(record.Sns.Message);
      const { name, email } = message;

      // Insertar los datos del mensaje en la base de datos PostgreSQL
      const insertQuery = 'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *';
      const res = await client.query(insertQuery, [name, email]);

      console.log(`Usuario insertado: ${res.rows[0].name}`);

      await client.end();
    }

    return { statusCode: 200, body: JSON.stringify({ message: "Datos insertados correctamente en la base de datos" }) };
  } catch (error) {
    console.error("Error al insertar en la base de datos:", error);
    return { statusCode: 500, body: JSON.stringify({ message: "Error al insertar en la base de datos" }) };
  }
};