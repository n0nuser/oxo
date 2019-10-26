# 0X0

# Normas de entrega

- Se entregará un listado de la práctica en papel. El listado se hará con un tipo de letra de espaciado fijo (p.ej. Courier New) e impreso por ambas caras del folio usado. Este listado servirá como comprobación de la práctica entregada, de la cual no se podrá modificar nada a partir de la fecha de entrega.

- No se incluirá junto con la práctica memoria o documentación adjunta alguna. Dentro del listado se incluirán los comentarios relativos a novedades introducidad sobre lo visto en clase y solo eso. Esto se hace para facilitar el proceso de corrección. En la mayor parte de los casos, no añadiréis nada al listado.

- Si la práctica incluye salida por pantalla, hay que ajustarse exacta y literalmente a lo especificado, carácter a carácter, línea a línea, por si se automatiza parte del proceso de corrección. Es evidente que debéis borrar todos los comentarios de depuración que aparezcan por la pantalla, si es que los habéis usado.

- Por el mismo motivo, si la práctica especifica el nombre de algún fichero, utilizad los nombres propuestos tal cual, respetando las mayúsculas/minúsculas que se especificaron. Considerad que la corrección automática pueder dar resultados erróneos si no observáis estas reglas.

- En la primera hoja de la práctica, se especificará el número de práctica obligatoria (primera, segunda, etc.), el título, los nombres y apellidos y el login de los miembros del equipo y la fecha. En esta página podéis encontrar un formulario que os genera un fichero PDF con la portada. Por favor, usad esta.

- Para entregar la práctica, cuando se haya abierto el plazo correspondiente, hay que conectarse a DIAWEB y subir los ficheros que la componen. En el caso de que no se use un fichero (por ejemplo un .h) subid en todo caso un fichero con un espacio en blanco, para que conste como correctamente entregada. No os olvidéis de entregar también en plazo la copia impresa.

# Partes del juego

Archivo oxo.sh.<br>
La ejecución necesitará de un fichero de configuración oxo.cfg que obligatoriamente tendrá que existir en su mismo
directorio antes de su invocación. Si el fichero no existe o el formato no es correcto se debe informar al usuario y finalizar la
ejecución del guion.

El guion podrá ejecutarse sin argumentos o con el argumento siguiente: oxo.sh [-g] <br>
Los corchetes indican que el argumento ‘g’ es opcional, en caso de que el guión se invoque con dicho parámetro, la Shell
mostrará los datos de los componentes del grupo que ha implementado la Shell, luego finalizará.<br>
En caso de que se invoque sin el parámetro ‘g’ la ejecución del guión mostrará un menú con opciones igual al siguiente:
```
C)CONFIGURACIÓN
J)JUGAR
E)ESTADÍSTICAS
S)SALIR
“OXO”. Introduzca una opción >>
```

El sistema esperará a que el usuario elija una de las opciones, ejecutará dicha opción y después mostrará:<br>
`Pulse INTRO para continuar`<br>
Esperará un INTRO y volverá de nuevo al menú principal (menos en la opción de SALIR).<br>
Las opciones del menú se explican a continuación.

### C) CONFIGURACIÓN
Esta opción permite cambiar la configuración del juego durante la ejecución del guión (que estará guardada en el fichero
oxo.cfg). La configuración cambiada mediante esta opción debe mantenerse para sucesivas ejecuciones del guion.<br>
El formato del fichero oxo.cfg está formado por pares atributo-valor y se debe respetar en todos los detalles:
```cfg
COMIENZO=comienzo
FICHACENTRAL=central
ESTADISTICAS=[ruta]oxo.log 
```
Donde:
- `comienzo` será un número del 1 al 3 indicando lo siguiente:
  - 1: comienza el humano
  - 2: comienza la computadora
  - 3: el comienzo se decide de manera aleatoria
- `central` será un número del 1 al 2 indicando:
  - 1: la ficha que se sitúe en la posición central (5) no se puede mover durante el transcurso de la partida.
  - 2: la ficha que se sitúe en la posición central (5) se puede mover durante el transcurso de la partida.
- `[ruta]log.txt` será el nombre del fichero de log. El fichero puede venir acompañado por una ruta absoluta o
relativa.

### J) JUGAR
Se implementará una partida del juego “OXO” teniendo en cuenta que:<br>
- La versión del juego que vamos a desarrollar es una versión reducida del juego original en la que el humano se
enfrenta a la computadora y ésta realizará sus movimientos de una manera aleatoria, sin utilizar técnicas de
inteligencia artificial.
- Vamos a sustituir los ceros por la letra “O”.
- Las posiciones del tablero se identificarán con un número del 1 al 9 siguiendo la distribución siguiente:
```
1 2 3
4 5 6
7 8 9
```
- Se deja libertad para diseñar la interfaz del juego, aunque de manera obligatoria se debe mostrar la información
del progreso que se considere oportuna, por ejemplo, la situación del tablero, el número de movimientos
realizado, la hora de inicio de la partida, el turno, la ficha etc...

Dinámica del Juego
- El juego comenzará mostrando el tablero vacío.
- El jugador que comience tendrá asignada las fichas “X”.
- En los primeros turnos cada jugador irá colocando sus tres fichas en el tablero en turnos.
- Una vez los dos jugadores tengan todas sus fichas en el tablero:
  - Si el turno es del computador, se realizará un movimiento de una de las tres fichas a una de las posiciones libres.<br>Tanto la ficha que se mueve como la posición se elegirán de manera aleatoria.
  - Si el turno es del humano, se le preguntará por la ficha que quiere mover y por la nueva posición en el tablero.<br>Una vez recogidos esos datos se realizará el movimiento
  - Cada vez que se termine un turno:
    - si el juego no ha finalizado se mostrará la situación del tablero y se pasará al siguiente turno
    - si alguno de los dos jugadores ha conseguido hacer 3 en línea, el juego finaliza, mostrándose una pantalla con la enhorabuena al ganador y todos los datos de la partida.
    - En cada partida del juego se escribirá el registro de actividad en el fichero de estadísticas indicado en el fichero de configuración oxo.cfg. El fichero NO se ha de sobrescribir en las diferentes ejecuciones del guión. Cada línea del fichero representará una partida con el siguiente formato:<br>
`PARTIDA|FECHA|COMIENZOP|CENTRAL|GANADOR|TIEMPO|MOVIMIENTO|JUGADA`
Donde:
- PARTIDA: será un número que corresponde al PID del proceso
- FECHA: fecha de comienzo de la partida
- COMIENZOP: será un 1 o 2 según lo estipulado en el fichero de configuración (o el resultado en caso de que la
configuración fuera 3).
- CENTRAL: será un 1 o un 2 según lo estipulado en el fichero de configuración
- GANADOR: será un 1 indicando que ganó el humano o un 2 indicando que ganó la computadora.
- TIEMPO: segundos que ha durado la partida
- MOVIMIENTOS: número de movimientos de la partida.
- JUGADA: secuencia de movimientos de toda la partida en formato:
  `jugador.ficha.nuevaposicion:jugador.ficha.nuevaposicion:jugador.ficha.nuevaposicion:.........`

Ejemplo de fichero oxo.log:
```
183823|22-11-19|1|2|2|47|23|1.3.5:2.4.6:1.5.4:2.2.1 ……………….…..
9283823|23-12-19|1|2|1|25|12|1.3.5:2.4.6:1.5.4:2.2.1……………….….
9283824|23-12-19|2|2|1|19|5|2.3.5:1.4.6:2.5.4:1.2.1…………………….
```

### E) ESTADÍSTICAS.
Se mostrarán por pantalla estadísticas generales del juego que se muestran a continuación y todos los datos de las jugadas
especiales requeridas.

GENERALES
- Número total de partidas jugadas
- Media de las longitudes de los movimientos de todas las partidas jugadas
- Media de los tiempos de todas las partidas jugadas
- Tiempo total invertido en todas las partidas.

JUGADAS ESPECIALES
- Datos de la jugada más corta en tiempo
- Datos de la jugada más larga en tiempo
- Datos de la jugada de menos movimientos.
- Datos de la jugada de más movimientos
- Cálculo de número de veces que ha estado ocupada la posición central del tablero en la jugada de menos movimientos
respecto al total.
### S) SALIR. Sale del menú.
