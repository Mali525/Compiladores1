Para poder ejecutar este compilador, es necesario tener en el equipo:
 - bison
 - flex
 - gcc
 - make


Para construir un ejecutable, en linux:

```$ make```

Luego compilar el archivo deseado de la siguiente manera:

```$ ./compilador /ruta/a/archivo.cmm```


- Análisis sintáctico: lexer.flex
- Análisis semántico: semantic/semantic.y (basado en el analizador léxico gram.y)
