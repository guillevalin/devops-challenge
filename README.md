# Parte 1: Infraestructura e IaC

## Diagrama Infraestructura
- Base de Datos: Se utilizará una base de datos relacional dado que es más compatible para procesar analítica avanzada y conectarla en un futuro con alguna solución de Data Analytics como Google BigQuery, Amazon Redshift o Snowflake, que es parte del requerimiento. Dado que en este caso estamos proponiendo una arquitectura en AWS, la tecnología escogida será Aurora PostgreSQL.
- Tecnología Pub/Sub: Existen diversas tecnologías para lograr este propósito, en particular por experiencia personal he utilizado SNS/SQS, RabbitMQ y Redis, sintiendo que todas en general cumplen el propósito y la elección en particular tiene que ir por decisiones previas (si ya se cuenta con una tecnología para Pub/Sub utilizada es mejor mantenerla para evitar fragmentación de tecnologías) o features específicos de una cola de mensajería (como AMQP). Dado que estamos proponiendo una solución simple administrada por AWS, escogeremos SNS/SQS para este ejemplo.
- Endpoint HTTP para servir datos almacenados: Soy muy fanático de armar arquitecturas de microservicios basadas en contenedores orquestadas por Kubernetes, utilizando las opciones administradas en la nube como Google Cloud GKE o Amazon EKS, si bien la curva de aprendizaje no es menor, permiten mucha flexibilidad y escalabilidad, y con un buen pipeline de CI/CD se pueden abstraer lo suficiente de los desarrolladores para que solo se centren en escribir código y no preocuparse por la infraestructura. En este caso sin embargo, por simplicidad escogeremos implementar funciones AWS Lambda para lograr el propósito, dado que por ejemplo, en un contexto de piloto, puede ser muy útil levantar una prueba de concepto de bajo costo antes de hacer un deploy más altamente disponible y enterprise grade.

Finalmente, esto se ve representado en el siguiente diagrama de arquitectura de la solución:
![Diagrama](diagrama-infra.png)

## Código Terraform
DISCLAIMER: Los códigos Terraform fueron generados mediante ChatGPT.

- VPC: Este código despliega una VPC con dos subnets privadas y dos públicas, en las zonas 1A y 1B de Virginia del Norte (us-east-1).
- SNS/SQS: Se utilizará SNS/SQS de AWS como tecnología para tener una arquitectura Pub/Sub. Existen otras tecnologías como Apache Kafka, RabbitMQ o Redis