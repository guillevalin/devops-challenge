# Usa la imagen base de Lambda para Node.js
FROM public.ecr.aws/lambda/nodejs:20

# Copia el archivo de código y dependencias
COPY package*.json ./
RUN npm install

COPY index.js ./

# Define el punto de entrada para la función Lambda
CMD ["index.handler"]