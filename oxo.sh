#!/bin/bash

#QUEDA CAMBIAR FUNCIONES: turnoPC, turnoHumano, Jugar
#QUEDA POR HACER f(Estadisticas) Y f(Configuracion)

function Comprobar-g(){
  if [ "$2" = "-g" ];then
    echo -e "\e[35mPablo\e[0m Jesus Gonzalez Rubio"
    echo -e "Francisco Javier Gallego Lahera"
    return 1
  fi
}

function ComprobarConf() {
  FILE='oxo.cfg'
  # Verificar si el fichero existe
  # No haría falta si no existiera la opcion de eliminar el archivo mientras se juega
  # Pero es mejor así por si acaso
  if [ ! -f "$FILE" ]; then
      echo -e "\e[1;31mERROR\e[0m. El archivo $FILE no existe."
      exit;
  fi

  if [ $(wc -l "$FILE" | cut -b 1) != "3" ];then
    echo -e "\e[1;31mERROR\e[0m. El fichero $FILE no tiene los 3 campos necesarios (COMIENZO, FICHACENTRAL, ESTADISTICAS)."
    exit;
  fi

  # Recoger los datos del fichero
  while IFS='=' read DATO VALOR
  do
    # Nos garantizamos que aun cambiando la linea de orden, sigue funcionando
    if [ $DATO = "COMIENZO" ]; then
      COMIENZO=$VALOR
    elif [ $DATO == "FICHACENTRAL" ]; then
      FICHACENTRAL=$VALOR
    elif [ $DATO == "ESTADISTICAS" ]; then
      ESTADISTICAS=$VALOR
    fi
  done < $FILE

  #AQUÍ DA ERROR
  if [ $COMIENZO != 1 ] && [ $COMIENZO != 2 ] && [ $COMIENZO != 3 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto del COMIENZO (1,2 o 3)."
    exit;
  fi

# AQUÍ DA ERROR
  if [ $FICHACENTRAL != 1 ] && [ $FICHACENTRAL != 2 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto de la FICHACENTRAL (1 o 2)."
    exit;
  fi
}

function comprobarTablero() {
  # Comprueba si el tablero está lleno
  # Comprueba el primero con el segundo y el segundo con el tercero
  if [ "POSICION[0]" = "POSICION[4]" ] && [ "POSICION[4]" = "POSICION[8]" ]; then
    return 1
  elif [ "POSICION[2]" = "POSICION[4]" ] && [ "POSICION[4]" = "POSICION[6]" ]; then
    return 1
  fi
  for (( i = 0; i < 2; i+3 )); do
    if [ "POSICION[$i]" = "POSICION[$i+1]" ] && [ "POSICION[$i+1]" = "POSICION[$i+2]" ]; then
      return 1
    fi
  done
  for (( i = 0; i < 2; i++ )); do
    if [ "POSICION[$i]" = "POSICION[$i+3]" ] && [ "POSICION[$i+3]" = "POSICION[$i+6]" ]; then
    return 1
    fi
  done
  return 0
}

function turnoHumano(){
  #CAMBIARLO PARA OTRO DIA
  read -p "Inserta posición de $FICHAHUMANO: " AUX
  if [ $AUX > 0 ] && [ $AUX < 9 ]; then
    while [ '$POSICION[$((AUX-1))]' != ' ' ]
    do
      echo "Posición Ya Ocupada."
    done
    POSICION[$((AUX-1))]="$FICHAHUMANO"
  else
    echo "Posición NO Válida."
  fi
  COMIENZO=2
}

function turnoPC(){
  #CAMBIARLO PARA OTRO DIA
  sleep 3
  POSICION_PC=$(( $RANDOM % 9 + 1  ))
  while [ '$POSICION[$POSICION_PC]' != ' ' ]
  do
    POSICION_PC=$(( $RANDOM % 9 + 1  ))
  done
  POSICION[$POSICION_PC]="$FICHAPC"
  COMIENZO=1
}

function Configuracion(){
  echo
}

function Jugar(){
  clear
  echo -e "\nEl tablero es de la siguiente forma:"
  echo -e "\n\n\t 1 | 2 | 3 "
  echo -e "\t===·===·==="
  echo -e "\t 4 | 5 | 6 "
  echo -e "\t===·===·==="
  echo -e "\t 7 | 8 | 9 "

  sleep 3
  clear

  declare -a POSICION=(' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ');
  declare -a TABLERO=('\n\n\t|' ' $POSICION[0] |' ' $POSICION[1] |' ' $POSICION[2] |\n\t===·===·===\n\t|' ' $POSICION[3] |' ' $POSICION[4] |' ' $POSICION[5] |\n\t===·===·===\n\t|' ' $POSICION[6] |' ' $POSICION[7] |' ' $POSICION[8] |\n\n');
  declare -a FICHA=('O' 'X')
  #ASIGNA A COMIENZO UN VALOR ALEATORIO ENTRE 1 Y 2
  if [ $COMIENZO -eq 3 ]; then
    COMIENZO=$(( $RANDOM % 2 + 1  ))
  fi
  #ASIGNA LAS FICHAS A ORDENADOR Y HUMANO
  if [ $COMIENZO -eq 1 ];then
    FICHAHUMANO=$FICHA[1]
    FICHAPC=$FICHA[0]
  elif [ $COMIENZO -eq 2 ];then
    FICHAHUMANO=$FICHA[0]
    FICHAPC=$FICHA[1]
  fi

  while [ comprobarTablero != 1 ]
  do
    #declare -a TABLERO=('\n\n\t|' ' $POSICION[0] |' ' $POSICION[1] |' ' $POSICION[2] |\n\t===·===·===\n\t|' ' $POSICION[3] |' ' $POSICION[4] |' ' $POSICION[5] |\n\t===·===·===\n\t|' ' $POSICION[6] |' ' $POSICION[7] |' ' $POSICION[8] |\n\n');
    echo ${TABLERO[@]}
    #ESTO CAMBIARLO PARA OTRO DIA
    if [ $COMIENZO -eq 3 ]; then
      COMIENZO=$(( $RANDOM % 2 + 1  ))
      if [ $COMIENZO -eq 1 ]; then
        turnoHumano
      elif [ $COMIENZO -eq 2 ]; then
        turnoPC
      fi
    fi
  done
}

function Estadisticas(){
  echo
}

function Menu(){
  echo -e "\e[1;5;33m  __     _  _     __  ";
  echo -e " /  \   ( \/ )   /  \ ";
  echo -e "(  O )   )  (   (  O )";
  echo -e " \__/   (_/\_)   \__/ \e[0m\n\n";
  echo -e "\e[1;33m== MENU ==\e[0m"
  echo -e "\n\e[1;33m C)\e[0m CONFIGURACIÓN"
  echo -e "\e[1;33m E)\e[0m ESTADÍSTICAS"
  echo -e "\e[1;33m J)\e[0m JUGAR"
  echo -e "\e[1;33m S)\e[0m SALIR\n"
  # Leer la opción del menú
  # -p Muestra el texto y pregunta sin meter salto de línea
  echo -en "\e[1;4mOXO\e[0m. Introduzca una opción >> "; read OPCION
  case $OPCION in
    C)
      Configuracion
    ;;
    J)
      Jugar
    ;;
    E)
      Estadisticas
    ;;
    S)
      echo -e "\n\t\e[1;33mSaliendo\e[0m del programa...\n"
      exit;
    ;;
    *)
      echo -e "\n\nNo se ha introducido una opción válida.\n"
      sleep 5
      clear
      Menu
    ;;
  esac
}

Comprobar-g
ComprobarConf
# DESPUÉS DE JUGAR VUELVE AQUÍ
#clear
Menu
